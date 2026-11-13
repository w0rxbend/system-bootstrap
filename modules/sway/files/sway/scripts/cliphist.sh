#!/usr/bin/env bash
# Fuzzel clipboard history. Usage: cliphist.sh pick|delete
set -euo pipefail

action="${1:-pick}"
case "${action}" in
    pick) prompt='clip> ' ;;
    delete) prompt='drop> ' ;;
    *)
        printf 'usage: cliphist.sh pick|delete\n' >&2
        exit 2
        ;;
esac

choice="$(cliphist list | fuzzel --dmenu --prompt "${prompt}" --width 72)" || exit 0
[[ -n "${choice}" ]] || exit 0

case "${action}" in
    pick) printf '%s\n' "${choice}" | cliphist decode | wl-copy ;;
    delete) printf '%s\n' "${choice}" | cliphist delete ;;
esac
