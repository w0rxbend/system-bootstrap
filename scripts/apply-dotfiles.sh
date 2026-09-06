#!/usr/bin/env bash
set -euo pipefail

# Apply the repo dotfiles with dotbot-go.
# https://github.com/worxbend/dotbot-go
#
# Dotbot is not vendored in `.files/` (no submodule, no committed `install`
# wrapper). This script downloads the release binary into a temporary directory
# on demand, runs the configs, and throws the download away again.
#
# Configs are applied in two passes because their relative paths resolve against
# different base directories:
#   1. `.files/install.conf.yaml`            — shared, base dir `.files`
#   2. `.files/<profile>/install.conf.yaml`  — distro overlay, base dir `.files/<profile>`
#
# Environment overrides:
#   DOTBOT_VERSION    release tag to fetch (default: latest)
#   DOTFILES_PROFILE  distro overlay to apply (default: detected from /etc/os-release)
#   DOTBOT_ARGS       extra flags passed through to dotbot (e.g. "-n" for a dry run)

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOTFILES_DIR="${REPO_ROOT}/.files"
DOTBOT_REPO="worxbend/dotbot-go"
DOTBOT_VERSION="${DOTBOT_VERSION:-latest}"

read -r -a dotbot_args <<<"${DOTBOT_ARGS:-}"

info() {
    printf '\n==> %s\n' "$*"
}

skip() {
    printf 'skip: %s\n' "$*"
}

have() {
    command -v "$1" >/dev/null 2>&1
}

detect_os() {
    case "$(uname -s)" in
        Linux) echo "linux" ;;
        Darwin) echo "darwin" ;;
        *)
            echo "Unsupported OS: $(uname -s)" >&2
            return 1
            ;;
    esac
}

detect_arch() {
    case "$(uname -m)" in
        x86_64 | amd64) echo "amd64" ;;
        arm64 | aarch64) echo "arm64" ;;
        *)
            echo "Unsupported architecture: $(uname -m)" >&2
            return 1
            ;;
    esac
}

# Pick the distro overlay under .files/ that matches this machine.
detect_profile() {
    local id id_like candidate

    [ -r /etc/os-release ] || return 0

    # shellcheck disable=SC1091
    id="$(. /etc/os-release && echo "${ID:-}")"
    # shellcheck disable=SC1091
    id_like="$(. /etc/os-release && echo "${ID_LIKE:-}")"

    # Intentionally unquoted: ID_LIKE is a space-separated list.
    # shellcheck disable=SC2086
    for candidate in ${id} ${id_like}; do
        case "${candidate}" in
            arch) echo "arch" && return 0 ;;
            fedora) echo "fedora" && return 0 ;;
        esac
    done
}

# Releases ship a <archive>.sha256 next to each tarball. Its filename field is
# the upstream build path (dist/...), so compare the digest itself rather than
# feeding the file straight to `sha256sum -c`.
verify_checksum() {
    local file="$1" sha_url="$2" expected actual sum_cmd

    if have sha256sum; then
        sum_cmd=(sha256sum)
    elif have shasum; then
        sum_cmd=(shasum -a 256)
    else
        skip "no sha256sum/shasum available; skipping checksum verification"
        return 0
    fi

    if ! expected="$(curl --proto '=https' --tlsv1.2 -fsSL "${sha_url}" 2>/dev/null)"; then
        skip "no checksum published at ${sha_url}; skipping verification"
        return 0
    fi

    expected="${expected%% *}"
    actual="$("${sum_cmd[@]}" "${file}")"
    actual="${actual%% *}"

    if [ "${expected}" != "${actual}" ]; then
        echo "Checksum mismatch for ${file}: expected ${expected}, got ${actual}" >&2
        return 1
    fi

    printf 'checksum ok: %s\n' "${actual}"
}

install_dotbot() {
    local os arch archive url

    os="$(detect_os)"
    arch="$(detect_arch)"
    archive="dotbot-${os}-${arch}.tar.gz"

    if [ "${DOTBOT_VERSION}" = "latest" ]; then
        url="https://github.com/${DOTBOT_REPO}/releases/latest/download/${archive}"
    else
        url="https://github.com/${DOTBOT_REPO}/releases/download/${DOTBOT_VERSION}/${archive}"
    fi

    info "Downloading dotbot-go (${DOTBOT_VERSION}) from ${url}" >&2
    curl --proto '=https' --tlsv1.2 -fsSL "${url}" -o "${WORKDIR}/${archive}"
    verify_checksum "${WORKDIR}/${archive}" "${url}.sha256" >&2
    tar -xzf "${WORKDIR}/${archive}" -C "${WORKDIR}" dotbot
    chmod +x "${WORKDIR}/dotbot"

    echo "${WORKDIR}/dotbot"
}

if [ ! -f "${DOTFILES_DIR}/install.conf.yaml" ]; then
    echo "Dotbot config not found: ${DOTFILES_DIR}/install.conf.yaml" >&2
    exit 1
fi

WORKDIR="$(mktemp -d)"
trap 'rm -rf "${WORKDIR}"' EXIT

DOTBOT="$(install_dotbot)"
"${DOTBOT}" --version

info "Applying shared dotfiles: ${DOTFILES_DIR}/install.conf.yaml"
"${DOTBOT}" -d "${DOTFILES_DIR}" -c "${DOTFILES_DIR}/install.conf.yaml" "${dotbot_args[@]}"

profile="${DOTFILES_PROFILE:-$(detect_profile)}"
if [ -z "${profile}" ]; then
    skip "no distro overlay matched this system; shared dotfiles only"
elif [ ! -f "${DOTFILES_DIR}/${profile}/install.conf.yaml" ]; then
    echo "Unknown dotfiles profile '${profile}': ${DOTFILES_DIR}/${profile}/install.conf.yaml not found" >&2
    exit 1
else
    info "Applying ${profile} overlay: ${DOTFILES_DIR}/${profile}/install.conf.yaml"
    "${DOTBOT}" -d "${DOTFILES_DIR}/${profile}" -c "${DOTFILES_DIR}/${profile}/install.conf.yaml" "${dotbot_args[@]}"
fi
