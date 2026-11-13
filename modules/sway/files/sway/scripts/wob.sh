#!/usr/bin/env bash
# Toxic-green volume and brightness bar. Writers use osd.sh.
set -euo pipefail

runtime="${XDG_RUNTIME_DIR:-/tmp}"
sock="${runtime}/wob.sock"
pidfile="${runtime}/sway-wob.pid"

if [[ -f "${pidfile}" ]]; then
    read -r old_pid old_pgid <"${pidfile}" || true
    if [[ "${old_pid:-}" =~ ^[0-9]+$ && "${old_pid}" != "$$" ]]; then
        kill "${old_pid}" 2>/dev/null || true
    fi
    if [[ "${old_pgid:-}" =~ ^[0-9]+$ ]]; then
        kill -- "-${old_pgid}" 2>/dev/null || true
    fi
    sleep 0.1
fi

if ! command -v wob >/dev/null 2>&1; then
    notify-send "OSD" "wob is not installed" || true
    exit 0
fi

rm -f "${sock}"
mkfifo "${sock}"

set -m
tail -f "${sock}" | wob &
wob_pid="$!"
pgid="$(ps -o pgid= -p "${wob_pid}" | tr -d '[:space:]')"
printf '%s %s\n' "$$" "${pgid}" >"${pidfile}"
wait "${wob_pid}"
