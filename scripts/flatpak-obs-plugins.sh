#!/usr/bin/env bash
set -euo pipefail

# OBS Studio and its plugins from Flathub. Run by modules/desktop/setup.sh
# when host.env sets OBS=1.

APPS=(
    com.obsproject.Studio
    com.obsproject.Studio.Plugin.DroidCam
    com.obsproject.Studio.Plugin.BackgroundRemoval
    com.obsproject.Studio.Plugin.Gstreamer
    com.obsproject.Studio.Plugin.GStreamerVaapi
    com.obsproject.Studio.Plugin.OBSPWVideo
    com.obsproject.Studio.Plugin.AitumMultistream
    com.obsproject.Studio.Plugin.CompositeBlur
    com.obsproject.Studio.Plugin.AdvancedMasks
    com.obsproject.Studio.Plugin._3DEffect
    com.obsproject.Studio.Plugin.Shaderfilter
)

flatpak install -y --noninteractive flathub "${APPS[@]}"
