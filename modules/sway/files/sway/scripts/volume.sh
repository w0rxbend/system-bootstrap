#!/usr/bin/env bash
# Change the default sink and show the level on wob.
# Usage: volume.sh up|down|mute
set -euo pipefail

dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
action="${1:-}"

percent() {
    pactl get-sink-volume @DEFAULT_SINK@ | awk '
        NR == 1 {
            for (i = 1; i <= NF; i++) {
                if ($i ~ /^[0-9]+%$/) {
                    gsub(/%/, "", $i)
                    print $i
                    exit
                }
            }
        }
    '
}

case "${action}" in
    up) pactl set-sink-volume @DEFAULT_SINK@ +5% ;;
    down) pactl set-sink-volume @DEFAULT_SINK@ -5% ;;
    mute) pactl set-sink-mute @DEFAULT_SINK@ toggle ;;
    *)
        printf 'usage: volume.sh up|down|mute\n' >&2
        exit 2
        ;;
esac

if [[ "${action}" == "mute" ]] && pactl get-sink-mute @DEFAULT_SINK@ | grep -q 'yes'; then
    "${dir}/osd.sh" 0 muted
    exit 0
fi

level="$(percent)"
[[ -n "${level}" ]] || exit 0
"${dir}/osd.sh" "${level}"
