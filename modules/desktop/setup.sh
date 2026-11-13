#!/usr/bin/env bash
set -euo pipefail

# Desktop apps: GPU tools, Fedora ffmpeg, Flathub remote, flatpaks, Nerd
# Fonts, and OBS when OBS=1.
# Run by scripts/host.sh; OBS comes from hosts/<host>/host.env.

: "${REPO_ROOT:?run through scripts/host.sh}"
: "${DISTRO:?run through scripts/host.sh}"

# shellcheck source=scripts/lib/common.sh
. "${REPO_ROOT}/scripts/lib/common.sh"

# radeontop for AMD and intel-media-driver for Intel; same names on Arch and Fedora.
install_gpu_tools() {
    local vga
    local -a tools=()

    if ! have lspci; then
        skip "lspci not found; GPU tools not installed"
        return 0
    fi
    vga="$(lspci | grep -i vga || true)"
    if grep -qi amd <<<"${vga}"; then
        tools+=(radeontop)
    fi
    if grep -qi intel <<<"${vga}"; then
        tools+=(intel-media-driver)
    fi
    if [ "${#tools[@]}" -eq 0 ]; then
        skip "no AMD or Intel GPU found"
        return 0
    fi
    info "Installing GPU tools: ${tools[*]}"
    pkg_install_names "${DISTRO}" "${tools[@]}"
}

# Replace Fedora's ffmpeg-free with the RPM Fusion build (base adds RPM Fusion).
install_fedora_ffmpeg() {
    info "Installing ffmpeg from RPM Fusion"
    if rpm -q ffmpeg-free >/dev/null 2>&1; then
        sudo dnf -y swap ffmpeg-free ffmpeg --allowerasing
    fi
    sudo dnf -y install ffmpeg ffmpeg-devel --allowerasing
}

case "${DISTRO}" in
    arch)
        install_gpu_tools
        ;;
    fedora)
        install_gpu_tools
        install_fedora_ffmpeg
        ;;
    *)
        skip "no GPU tool names for ${DISTRO}; GPU tools not installed"
        ;;
esac

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
