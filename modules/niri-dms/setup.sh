#!/usr/bin/env bash
set -euo pipefail

# Niri + DankMaterialShell: install both with the official DMS installer.
# The installer resolves the latest duxinstall release, checks its SHA-256,
# and installs niri, DMS and their dependencies for this distro.
# No --replace-configs: it deploys no configs, so the dotbot links stay.
# Run by scripts/host.sh.

: "${REPO_ROOT:?run through scripts/host.sh}"

# shellcheck source=scripts/lib/common.sh
. "${REPO_ROOT}/scripts/lib/common.sh"

DMS_INSTALL_URL="https://install.duxlabs.dev"

if have dms && have niri; then
    skip "dms and niri already installed; update them with dms or the package manager"
    exit 0
fi

info "Installing niri and DankMaterialShell with the official installer"
# Download first, then run: a dropped connection must not run half a script.
# scripts/host.sh keeps sudo credentials cached for the unattended mode.
tmp="$(mktemp -d)"
trap 'rm -rf -- "${tmp}"' EXIT
curl --proto '=https' --tlsv1.2 -fsSL -o "${tmp}/dms-install.sh" "${DMS_INSTALL_URL}"
bash "${tmp}/dms-install.sh" --compositor niri --term alacritty --dux-search --yes
