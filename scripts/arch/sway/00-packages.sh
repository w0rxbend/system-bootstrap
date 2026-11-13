#!/usr/bin/env bash
# Arch + Sway UI packages only. Does not update the system or touch other desktops.
set -euo pipefail

if ! command -v pacman >/dev/null 2>&1; then
    echo "pacman is required; this script is for Arch and CachyOS" >&2
    exit 1
fi

sudo pacman -S --needed --noconfirm \
    sway \
    python \
    libpulse \
    alacritty \
    just \
    fuzzel \
    kanshi \
    waybar \
    mako \
    foot \
    ttf-terminus-nerd \
    ttf-recursive-nerd \
    brightnessctl \
    playerctl \
    grim \
    slurp \
    wl-clipboard \
    wf-recorder \
    swaylock \
    swayidle \
    libnotify \
    wlsunset \
    wpaperd \
    autotiling \
    wob \
    cliphist

echo "Arch + Sway packages are installed."
echo "Next, from ~/.system-bootstrap: just arch-sway-dotfiles"
