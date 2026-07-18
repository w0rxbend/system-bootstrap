#!/usr/bin/env zsh

# Ensure system is updated
sudo pacman -Syu --noconfirm

# Terminal and utilities
sudo pacman -S --noconfirm alacritty bat kitty hyperfine asciinema wl-clipboard yq jq stacer net-tools xsensors stress

# Media tools
sudo pacman -S --noconfirm vlc ffmpeg ffmpegthumbs mpv \
    gstreamer gst-plugins-base gst-plugins-good gst-plugin-pipewire \
    gst-plugins-bad gst-plugins-ugly gst-libav \
    libva-utils libva \
    libvdpau-va-gl v4l2loopback-dkms

# GPU-specific tools
if lspci | grep -i amd | grep -i vga >/dev/null; then
    echo "AMD GPU found."
    sudo pacman -S --noconfirm radeontop
fi

if lspci | grep -i intel | grep -i vga >/dev/null; then
    echo "Intel GPU found."
    sudo pacman -S --noconfirm intel-media-driver
fi

# UI tools
sudo pacman -S --noconfirm gnome-tweaks

# Developer tools
sudo pacman -S --noconfirm llvm clang cmake make gcc \
    clang-tools-extra lldb lld ninja meson \
    flex bison gperf ccache openssl libffi dfu-util unzip \
    readline base-devel

# GTK and GUI dev
sudo pacman -S --noconfirm gtk3 gtk4 \
    gobject-introspection libxrandr libxi libxinerama libxcursor libxxf86vm \
    libx11 libxext libxft libxrender libxfixes mesa mesa-utils \
    mesa-vdpau mesa-libgl
# Fonts
sudo pacman -S --noconfirm ttf-fira-code ttf-font-awesome noto-fonts noto-fonts-emoji

# PDF + document tools
sudo pacman -S --noconfirm zathura zathura-pdf-mupdf mupdf

# LaTeX
sudo pacman -S --noconfirm texlive-core texlive-bin texlive-xetex

# Crystal language (AUR) — disabled: no AUR helper on CachyOS by default
# paru -S --noconfirm crystal

# Done
echo "✅ All packages installed and configured."

sudo pacman -S --noconfirm qemu-full virt-manager libvirt dnsmasq vde2 openbsd-netcat
sudo systemctl enable --now libvirtd
sudo usermod -aG libvirt $(whoami)

# --- Install Visual Studio Code (AUR) — disabled: no AUR helper on CachyOS by default ---
# VS Code is in AUR as 'visual-studio-code-bin' (official binary with MS telemetry)
# paru -S --noconfirm visual-studio-code-bin

# --- Install Docker ---
# Real Docker is preferred over podman-docker (whose /usr/bin/docker shim conflicts).
sudo pacman -S --needed --noconfirm docker docker-compose docker-buildx
sudo systemctl enable --now docker.service
sudo usermod -aG docker "$(whoami)"

# --- Time Sync ---
sudo timedatectl set-local-rtc 0
sudo timedatectl set-ntp true
