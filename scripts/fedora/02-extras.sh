#!/usr/bin/env zsh

# ── Visual Studio Code ────────────────────────────────────────────────────────────
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
sudo dnf -y check-update
sudo dnf -y install code

# ── Containers ────────────────────────────────────────────────────────────────────
sudo dnf -y install podman podman-docker

# ── Other packages ────────────────────────────────────────────────────────────────
sudo dnf install -y toolbox zoxide
