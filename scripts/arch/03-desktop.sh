#!/usr/bin/env bash
set -euo pipefail

# GNOME + COSMIC desktops for Arch (replaces the former Hyprland setup).
#
# GDM (shipped with the `gnome` group) serves both sessions — pick GNOME or COSMIC
# from the login-screen gear menu. GNOME keybinding/workspace tweaks are applied by
# Dotbot from .files/arch/install.conf.yaml when you run `just apply-dotfiles`.

# Extras not in the base group
sudo pacman -S --needed --noconfirm \
    gnome-tweaks gnome-shell-extensions gnome-browser-connector \
    xdg-desktop-portal-gtk

sudo pacman -S --noconfirm snapd
