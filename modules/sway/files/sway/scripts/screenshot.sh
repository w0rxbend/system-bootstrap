#!/usr/bin/env bash
# Save a PNG under Pictures/screenshots and copy it to the clipboard.
# Usage: screenshot.sh region|window|output
set -euo pipefail

mode="${1:-region}"
dir_scripts="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
pictures="$(xdg-user-dir PICTURES 2>/dev/null || printf '%s\n' "${HOME}/Pictures")"
dir="${pictures}/screenshots"
mkdir -p "${dir}"
file="${dir}/$(date +%Y%m%d-%H%M%S).png"

geometry() {
    case "${mode}" in
        region)
            "${dir_scripts}/slurp.sh"
            ;;
        window)
            swaymsg -t get_tree | python3 -c '
import json, sys

def walk(node):
    if node.get("focused"):
        rect = node["rect"]
        if rect["width"] > 0 and rect["height"] > 0:
            print("%d,%d %dx%d" % (rect["x"], rect["y"], rect["width"], rect["height"]))
            return True
    for child in node.get("nodes", []) + node.get("floating_nodes", []):
        if walk(child):
            return True
    return False

sys.exit(0 if walk(json.load(sys.stdin)) else 1)
'
            ;;
        *)
            printf 'usage: screenshot.sh region|window|output\n' >&2
            return 2
            ;;
    esac
}

if [[ "${mode}" == "output" ]]; then
    grim "${file}"
else
    geom="$(geometry)" || exit 0
    [[ -n "${geom}" ]] || exit 0
    grim -g "${geom}" "${file}"
fi

wl-copy <"${file}"
notify-send "Screenshot" "${file}" || true
