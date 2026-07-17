#!/bin/env zsh
echo "Initializing user env..."
source "$HOME/.zshrc"
echo "\n"
echo "## shell: $SHELL ##"
echo "\n"
echo "------------------------"
echo "-  Updating system...  -"
echo "------------------------"
echo "System info: $(uname -a)"
echo "\n"
echo "Updating system via 'dnf'..."
# Paru handles both official repos and AUR
# -Syu: Sync, Refresh, Upgrade
# --noconfirm: Equivalent to -y
echo ""
echo "Updating system via 'paru'..."
paru -Syu --noconfirm

echo ""
echo "Flatpak update..."
flatpak update -y

echo ""
echo "Updating rust toolchain..."
rustup update

echo ""
echo "Updating julia toolchain..."
juliaup update

echo ""
echo "Updating SDKMAN..."
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk update
sdk upgrade

echo ""
echo "Updating NVM..."
nvm install node --reinstall-packages-from=current --latest-npm

echo ""
echo "Updating Miniforge3"
mamba update --all

echo ""
echo "Updating astral.uv"
uv self update
