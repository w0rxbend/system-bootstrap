#!/usr/bin/env bash
# Change the backlight and show the level on wob. No backlight device is a no-op.
# Usage: brightness.sh up|down
set -euo pipefail

dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
action="${1:-}"

case "${action}" in
    up) delta='5%+' ;;
    down) delta='5%-' ;;
    *)
        printf 'usage: brightness.sh up|down\n' >&2
        exit 2
        ;;
esac

line="$(brightnessctl -m -c backlight set "${delta}")" || exit 0
level="$(printf '%s\n' "${line}" | awk -F, 'NR == 1 { gsub(/%/, "", $4); print $4 }')"
[[ "${level}" =~ ^[0-9]+$ ]] || exit 0
"${dir}/osd.sh" "${level}"
