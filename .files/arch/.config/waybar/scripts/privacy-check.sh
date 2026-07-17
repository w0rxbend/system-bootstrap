#!/bin/bash

# Waybar custom widget script for microphone and camera usage indicators
# This script monitors microphone recording and camera usage

# Colors for different states
COLOR_ACTIVE="#e64553"   # Red when active
COLOR_INACTIVE="#f4dbd6" # Gray when inactive
COLOR_MUTED="#f5a97f"    # Gray when muted
# Icons
MIC_ICON=""              # Microphone icon
MIC_INACTIVE_ICON=" "    # Inactive microphone icon
MIC_MUTED_ICON="󰍮"        # Muted microphone icon
CAMERA_ICON="󰞡 "          # Camera icon
CAMERA_INACTIVE_ICON="󱦿 " # Inactive camera icon
SEPARATOR=""             # Separator between indicators

# Check if microphone is being used (PulseAudio/PipeWire)
check_microphone() {
    local mic_active=false
    local mic_muted=false

    active_streams=$(pw-dump | jq '.[] | select(.type=="PipeWire:Interface:Node" and .info.props."media.class"=="Stream/Input/Audio") | .info.props | select(."node.name"!="cava") | ."application.name"')
    if [[ -n "$active_streams" ]]; then
        mic_active=true
    fi

    # Check if default source is muted (WirePlumber)
    if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q "MUTED"; then
        mic_muted=true
    fi

    # Return status
    if $mic_active && ! $mic_muted; then
        echo "active"
    elif $mic_muted; then
        echo "muted"
    else
        echo "inactive"
    fi
}

# Check if camera is being used
check_camera() {
    local camera_active=false
    if ls /dev/video* >/dev/null 2>&1; then
        for video_dev in /dev/video*; do
            # Check if device is being used by checking if it's opened
            if lsof "$video_dev" >/dev/null 2>&1; then
                camera_active=true
                break
            fi
        done
    fi
    if $camera_active; then
        echo "active"
    else
        echo "inactive"
    fi
}

# Get microphone status
mic_status=$(check_microphone)

# Get camera status
camera_status=$(check_camera)

# Build output for Waybar
output=""
tooltip="Privacy Status:\n"

# Microphone indicator
case $mic_status in
    "active")
        output="<span color='$COLOR_ACTIVE'>$MIC_ICON</span>"
        tooltip+=" Microphone: Recording"
        ;;
    "muted")
        output="<span color='$COLOR_MUTED'>$MIC_MUTED_ICON</span>"
        tooltip+="󰢳 Microphone: Muted"
        ;;
    "inactive")
        output="<span color='$COLOR_INACTIVE'>$MIC_INACTIVE_ICON</span>"
        tooltip+=" Microphone: Inactive"
        ;;
esac

# Add separator if both indicators are shown
if [[ -n "$output" ]]; then
    output+="$SEPARATOR"
fi

# Camera indicator
case $camera_status in
    "active")
        output+="<span color='$COLOR_ACTIVE'>$CAMERA_ICON</span>"
        tooltip+="\n📹 Camera: Active"
        ;;
    "inactive")
        output+="<span color='$COLOR_INACTIVE'>$CAMERA_INACTIVE_ICON</span>"
        tooltip+="\n📹 Camera: Inactive"
        ;;
esac

# if camera and mic are both inactive then exit 0
if [[ mic_status == "inactive" && camera_status == "inactive" ]]; then
    exit 0
fi
# Output JSON for Waybar
printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' \
    "$output" \
    "$tooltip" \
    "privacy-indicator"
