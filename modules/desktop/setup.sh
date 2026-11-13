#!/usr/bin/env bash
set -euo pipefail

# Desktop apps: Flathub remote, flatpaks, Nerd Fonts, and OBS when OBS=1.
# Run by scripts/host.sh; OBS comes from hosts/<host>/host.env.

: "${REPO_ROOT:?run through scripts/host.sh}"

# shellcheck source=scripts/lib/common.sh
. "${REPO_ROOT}/scripts/lib/common.sh"

have flatpak || die "flatpak is not installed; the base module installs it"

info "Adding the Flathub remote"
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

"${REPO_ROOT}/scripts/flatpak.sh"

if [ "${OBS:-0}" = 1 ]; then
    "${REPO_ROOT}/scripts/flatpak-obs-plugins.sh"
else
    skip "OBS is not 1 in host.env; OBS Studio not installed"
fi

"${REPO_ROOT}/scripts/nerd-fonts.p0.sh"
