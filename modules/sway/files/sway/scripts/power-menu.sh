#!/usr/bin/env bash
# Fuzzel menu for lock, suspend, logout, reboot, and shutdown.
set -euo pipefail

dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
choice="$(
    printf '%s\n' Lock Suspend 'Log out' Reboot 'Shut down' \
        | fuzzel --dmenu --prompt 'power> ' --width 24 --lines 5
)" || exit 0

case "${choice}" in
    Lock) "${dir}/lock.sh" ;;
    Suspend)
        "${dir}/lock.sh"
        systemctl suspend
        ;;
    "Log out") swaymsg exit ;;
    Reboot) systemctl reboot ;;
    "Shut down") systemctl poweroff ;;
    *) exit 0 ;;
esac
