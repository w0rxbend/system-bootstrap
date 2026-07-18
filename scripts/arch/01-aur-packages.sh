#!/usr/bin/env bash
set -euo pipefail

# Official-repo packages are installed with pacman. AUR packages are installed only
# when an AUR helper (paru) is already present — this script does not install paru.
#
# Nerd Fonts are handled separately by `just install-fonts` (scripts/nerd-fonts.p0.sh),
# so they are not installed here.

# ── Audio production (official repo) ────────────────────────────────────────────────
sudo pacman -S --needed --noconfirm easyeffects

# ── Browser (AUR) — disabled ────────────────────────────────────────────────────────
# CachyOS has no AUR helper by default. Install manually if desired, e.g.:
# paru -S --needed --noconfirm google-chrome
