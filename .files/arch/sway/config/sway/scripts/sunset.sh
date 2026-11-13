#!/usr/bin/env bash
# Restart wlsunset from ~/.config/wlsunset/config.
set -euo pipefail

config="${XDG_CONFIG_HOME:-${HOME}/.config}/wlsunset/config"
latitude=50.5
longitude=30.5
high_temp=6500
low_temp=4000

number() {
    [[ "$1" =~ ^-?[0-9]+([.][0-9]+)?$ ]]
}

if [[ -f "${config}" ]]; then
    while IFS= read -r line || [[ -n "${line}" ]]; do
        line="${line%%#*}"
        line="${line#"${line%%[![:space:]]*}"}"
        [[ -z "${line}" || "${line}" != *=* ]] && continue
        key="${line%%=*}"
        value="${line#*=}"
        key="${key%"${key##*[![:space:]]}"}"
        value="${value#"${value%%[![:space:]]*}"}"
        value="${value%"${value##*[![:space:]]}"}"
        case "${key}" in
            latitude) latitude="${value}" ;;
            longitude) longitude="${value}" ;;
            high_temp) high_temp="${value}" ;;
            low_temp) low_temp="${value}" ;;
        esac
    done <"${config}"
fi

if ! number "${latitude}" || ! number "${longitude}" || ! number "${high_temp}" || ! number "${low_temp}"; then
    notify-send "Sunset" "Invalid ${config}" || true
    exit 0
fi

if ! command -v wlsunset >/dev/null 2>&1; then
    notify-send "Sunset" "wlsunset is not installed" || true
    exit 0
fi

pkill -x wlsunset 2>/dev/null || true
exec wlsunset -l "${latitude}" -L "${longitude}" -T "${high_temp}" -t "${low_temp}"
