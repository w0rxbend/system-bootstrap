#!/bin/bash

metadata_type=$1

# Check if Spotify is running and active
player_status=$(playerctl -p spotify status 2>/dev/null)

if [ "$player_status" = "Playing" ] || [ "$player_status" = "Paused" ]; then
    title=$(playerctl -p spotify metadata title 2>/dev/null)
    artist=$(playerctl -p spotify metadata artist 2>/dev/null)
    # Get total time and position for progress bar if you want to go extra
    # duration=$(playerctl -p spotify metadata mpris:length 2>/dev/null) # in microseconds
    # position=$(playerctl -p spotify position 2>/dev/null) # in seconds
    truncated=$(echo "$title" | cut -c1-20)
    # Check if we got valid info
    if [ -n "$title" ]; then
        echo "{\"text\": \"$truncated\",  \"tooltip\": \"$artist\", \"class\": \"spotify-playing\"}"
    else
        echo "{\"text\": \"No Spotify info\", \"class\": \"spotify-idle\"}"
    fi
else
    exit 0
fi
