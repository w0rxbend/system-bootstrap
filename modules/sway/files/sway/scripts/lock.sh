#!/usr/bin/env bash
# Dux purple swaylock. Used by the keybind, the power menu, and swayidle.
# Text, ring, and thickness are 1.25× the old sizes, matching this panel.
# swaylock 1.8 does not scale a fixed font with the fractional output scale.
set -euo pipefail

if ! command -v swaylock >/dev/null 2>&1; then
    notify-send "Lock" "swaylock is not installed" || true
    exit 1
fi

exec swaylock -f \
    --ignore-empty-password \
    --font "RecMonoLinear Nerd Font Mono" \
    --font-size 23 \
    --color 141218 \
    --inside-color 141218 \
    --inside-clear-color 141218 \
    --inside-caps-lock-color 49454e \
    --inside-ver-color 141218 \
    --inside-wrong-color 141218 \
    --ring-color 948f99 \
    --ring-clear-color ccc2dc \
    --ring-caps-lock-color 4f378b \
    --ring-ver-color d0bcff \
    --ring-wrong-color f2b8b5 \
    --line-color 141218 \
    --line-clear-color 141218 \
    --line-caps-lock-color 141218 \
    --line-ver-color 141218 \
    --line-wrong-color 141218 \
    --separator-color 00000000 \
    --text-color e6e0e9 \
    --text-clear-color ccc2dc \
    --text-caps-lock-color d0bcff \
    --text-ver-color d0bcff \
    --text-wrong-color f2b8b5 \
    --key-hl-color d0bcff \
    --bs-hl-color ccc2dc \
    --caps-lock-key-hl-color d0bcff \
    --caps-lock-bs-hl-color ccc2dc \
    --layout-bg-color 141218 \
    --layout-border-color d0bcff \
    --layout-text-color e6e0e9 \
    --indicator-radius 112 \
    --indicator-thickness 10
