#!/usr/bin/env bash
# Lock after 5 idle minutes, turn panels off after 10, and lock before sleep.
set -euo pipefail

dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
lock_after=300
screen_off_after=600

exec swayidle -w \
    timeout "${lock_after}" "${dir}/lock.sh" \
    timeout "${screen_off_after}" 'swaymsg "output * power off"' \
    resume 'swaymsg "output * power on"' \
    before-sleep "${dir}/lock.sh"
