#!/usr/bin/env bash
set -euo pipefail

# Base system: upgrade, distro repos and services, then git and time settings.
# Run by scripts/host.sh after packages.<distro>, which sets HOST, DISTRO and
# REPO_ROOT. The Fedora repos added here serve later modules (dev: code,
# desktop: ffmpeg), which is why base comes first in MODULES.

: "${REPO_ROOT:?run through scripts/host.sh}"
: "${DISTRO:?run through scripts/host.sh}"

# shellcheck source=scripts/lib/common.sh
. "${REPO_ROOT}/scripts/lib/common.sh"

enable_network_manager() {
    if systemctl cat NetworkManager.service >/dev/null 2>&1; then
        sudo systemctl enable NetworkManager.service
    else
        skip "NetworkManager.service not installed; not enabled"
    fi
}

add_rpm_fusion() {
    local version

    if rpm -q rpmfusion-free-release rpmfusion-nonfree-release >/dev/null 2>&1; then
        skip "RPM Fusion already configured"
        return 0
    fi
    version="$(rpm -E %fedora)"
    sudo dnf install -y \
        "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-${version}.noarch.rpm" \
        "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${version}.noarch.rpm"
}

add_vscode_repo() {
    local repo=/etc/yum.repos.d/vscode.repo

    if [ -f "${repo}" ]; then
        skip "${repo} already exists"
        return 0
    fi
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    printf '%s\n' \
        '[code]' \
        'name=Visual Studio Code' \
        'baseurl=https://packages.microsoft.com/yumrepos/vscode' \
        'enabled=1' \
        'gpgcheck=1' \
        'gpgkey=https://packages.microsoft.com/keys/microsoft.asc' |
        sudo tee "${repo}" >/dev/null
}

case "${DISTRO}" in
    arch)
        info "Upgrading the system"
        sudo pacman -Syu --noconfirm
        enable_network_manager
        ;;
    fedora)
        info "Upgrading the system"
        sudo dnf upgrade -y
        info "Adding RPM Fusion and the VS Code repo"
        add_rpm_fusion
        add_vscode_repo
        ;;
    ubuntu)
        skip "no Ubuntu package step yet; install packages by hand"
        ;;
    *)
        die "unsupported DISTRO: ${DISTRO}"
        ;;
esac

"${REPO_ROOT}/scripts/configurations.sh"
