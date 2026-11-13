#!/usr/bin/env bash
# Toggle a wf-recorder capture of the focused output or a selected region.
# Usage: record.sh toggle-output|toggle-region|stop
set -euo pipefail

dir_scripts="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
runtime="${XDG_RUNTIME_DIR:-/tmp}"
pidfile="${runtime}/sway-record.pid"
pathfile="${runtime}/sway-record.path"
logfile="${runtime}/sway-record.log"
videos="$(xdg-user-dir VIDEOS 2>/dev/null || printf '%s\n' "${HOME}/Videos")"
dir="${videos}/recordings"

notify() {
    notify-send "Recording" "$1" || true
}

refresh_bar() {
    pkill -RTMIN+8 waybar 2>/dev/null || true
}

recording() {
    [[ -f "${pidfile}" ]] || return 1
    local pid
    pid="$(<"${pidfile}")"
    [[ -n "${pid}" ]] && kill -0 "${pid}" 2>/dev/null
}

stop() {
    local path=""
    if recording; then
        kill -INT "$(<"${pidfile}")" 2>/dev/null || true
        if [[ -f "${pathfile}" ]]; then
            path="$(<"${pathfile}")"
        fi
        notify "Stopped ${path}"
    fi
    rm -f "${pidfile}" "${pathfile}"
    refresh_bar
}

focused_output() {
    swaymsg -t get_outputs | python3 -c '
import json, sys
outputs = json.load(sys.stdin)
for output in outputs:
    if output.get("focused"):
        print(output["name"])
        break
else:
    if outputs:
        print(outputs[0]["name"])
'
}

start() {
    local mode="$1" file monitor pid
    if ! command -v wf-recorder >/dev/null 2>&1; then
        notify "wf-recorder is not installed"
        exit 1
    fi
    mkdir -p "${dir}"
    file="${dir}/$(date +%Y%m%d-%H%M%S).mp4"
    monitor="$(pactl get-default-sink).monitor"
    if [[ "${mode}" == "region" ]]; then
        local geom
        geom="$("${dir_scripts}/slurp.sh")" || exit 0
        [[ -n "${geom}" ]] || exit 0
        nohup wf-recorder -g "${geom}" --audio "${monitor}" -f "${file}" >"${logfile}" 2>&1 &
    else
        nohup wf-recorder -o "$(focused_output)" --audio "${monitor}" -f "${file}" >"${logfile}" 2>&1 &
    fi
    pid="$!"
    disown "${pid}" 2>/dev/null || true
    printf '%s\n' "${pid}" >"${pidfile}"
    printf '%s\n' "${file}" >"${pathfile}"
    sleep 0.4
    if ! kill -0 "${pid}" 2>/dev/null; then
        rm -f "${pidfile}" "${pathfile}"
        notify "Failed. $(tail -n 3 "${logfile}" 2>/dev/null || true)"
        refresh_bar
        exit 1
    fi
    notify "Started ${file}"
    refresh_bar
}

action="${1:-toggle-output}"
case "${action}" in
    stop)
        stop
        ;;
    toggle-output | toggle-region)
        if recording; then
            stop
        elif [[ "${action}" == "toggle-region" ]]; then
            start region
        else
            start output
        fi
        ;;
    *)
        printf 'usage: record.sh toggle-output|toggle-region|stop\n' >&2
        exit 2
        ;;
esac
