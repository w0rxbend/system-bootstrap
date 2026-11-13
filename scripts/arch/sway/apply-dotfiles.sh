#!/usr/bin/env bash
# Link the Arch + Sway overlay only.
# Does not apply the shared dotfiles or the Fedora, Hyprland, Niri, or DankMaterialShell configs.
#
# Environment overrides:
#   DOTBOT       dotbot binary to use as is (default: pinned dotbot-go, see scripts/lib/dotbot.sh)
#   DOTBOT_ARGS  extra flags passed through to dotbot (e.g. "-n" for a dry run)
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
OVERLAY="${REPO_ROOT}/.files/arch/sway"
CONFIG="${OVERLAY}/install.conf.yaml"

# shellcheck source=scripts/lib/dotbot.sh
. "${REPO_ROOT}/scripts/lib/dotbot.sh"

read -r -a dotbot_args <<<"${DOTBOT_ARGS:-}"

[ -f "${CONFIG}" ] || die "missing ${CONFIG}"

WORKDIR="$(mktemp -d)"
trap 'rm -rf -- "${WORKDIR}"' EXIT

dotbot_bin="$(resolve_dotbot "${WORKDIR}")"

echo "Linking Arch + Sway dotfiles with ${dotbot_bin}"
"${dotbot_bin}" -d "${OVERLAY}" -c "${CONFIG}" "${dotbot_args[@]}"
echo "Linked. Log out of Sway and back in so ~/.config/sway/config is the one that loads."
