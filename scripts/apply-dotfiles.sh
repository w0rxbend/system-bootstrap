#!/usr/bin/env bash
set -euo pipefail

# Apply the repo dotfiles with dotbot-go.
# https://github.com/worxbend/dotbot-go
#
# Dotbot is not vendored in `.files/` (no submodule, no committed `install`
# wrapper). scripts/lib/dotbot.sh uses an installed binary of the pinned version,
# or downloads and verifies that release into a temporary directory that is
# removed again on exit.
#
# Configs are applied in two passes because their relative paths resolve against
# different base directories:
#   1. `.files/*.conf.yaml`                  — shared, base dir `.files`
#   2. `.files/<profile>/install.conf.yaml`  — distro overlay, base dir `.files/<profile>`
#
# The shared pass hands dotbot every config in SHARED_CONFIGS at once (`-c` is
# repeatable), so topic-specific link sets live in their own file next to
# `install.conf.yaml` rather than being appended to it.
#
# Environment overrides:
#   DOTBOT            dotbot binary to use as is (default: pinned dotbot-go, see scripts/lib/dotbot.sh)
#   DOTFILES_PROFILE  distro overlay to apply (default: detected from /etc/os-release)
#   DOTBOT_ARGS       extra flags passed through to dotbot (e.g. "-n" for a dry run)

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOTFILES_DIR="${REPO_ROOT}/.files"

# shellcheck source=scripts/lib/dotbot.sh
. "${REPO_ROOT}/scripts/lib/dotbot.sh"

# Shared configs, applied together with base dir `.files`.
SHARED_CONFIGS=(
    install.conf.yaml
)

read -r -a dotbot_args <<<"${DOTBOT_ARGS:-}"

# Pick the distro overlay under .files/ that matches this machine.
detect_profile() {
    local id

    id="$(os_id)"
    case "${id}" in
        arch | fedora) printf '%s\n' "${id}" ;;
    esac
}

shared_args=()
for config in "${SHARED_CONFIGS[@]}"; do
    if [ ! -f "${DOTFILES_DIR}/${config}" ]; then
        echo "Dotbot config not found: ${DOTFILES_DIR}/${config}" >&2
        exit 1
    fi
    shared_args+=(-c "${DOTFILES_DIR}/${config}")
done

WORKDIR="$(mktemp -d)"
trap 'rm -rf -- "${WORKDIR}"' EXIT

dotbot_bin="$(resolve_dotbot "${WORKDIR}")"
"${dotbot_bin}" --version

info "Applying shared dotfiles: ${SHARED_CONFIGS[*]}"
"${dotbot_bin}" -d "${DOTFILES_DIR}" "${shared_args[@]}" "${dotbot_args[@]}"

profile="${DOTFILES_PROFILE:-$(detect_profile)}"
if [ -z "${profile}" ]; then
    skip "no distro overlay matched this system; shared dotfiles only"
elif [ ! -f "${DOTFILES_DIR}/${profile}/install.conf.yaml" ]; then
    echo "Unknown dotfiles profile '${profile}': ${DOTFILES_DIR}/${profile}/install.conf.yaml not found" >&2
    exit 1
else
    info "Applying ${profile} overlay: ${DOTFILES_DIR}/${profile}/install.conf.yaml"
    "${dotbot_bin}" -d "${DOTFILES_DIR}/${profile}" -c "${DOTFILES_DIR}/${profile}/install.conf.yaml" "${dotbot_args[@]}"
fi
