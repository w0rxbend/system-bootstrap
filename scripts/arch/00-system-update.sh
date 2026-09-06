#!/usr/bin/env bash

# Update system
sudo pacman -Syu --noconfirm

# Install base packages from official repos
sudo pacman -S --noconfirm \
    ca-certificates \
    curl \
    gnupg \
    wget \
    git \
    fuse3 \
    util-linux \
    zsh \
    fzf \
    pipewire-alsa

# Networking, Bluetooth, audio session, power, and flatpak
sudo pacman -S --needed --noconfirm \
    pipewire pipewire-pulse wireplumber \
    power-profiles-daemon upower flatpak

sudo systemctl enable NetworkManager.service

# Change default shell to zsh
chsh -s $(which zsh)

# Install Oh My Zsh
if [ ! -d "${ZSH:-$HOME/.oh-my-zsh}" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "Oh My Zsh already installed."
fi

sudo pacman -S --needed --noconfirm easyeffects
