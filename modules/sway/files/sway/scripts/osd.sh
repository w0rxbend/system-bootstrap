#!/usr/bin/env bash
# Show a percentage on the wob bar. Optional second argument is a wob style name.
set -euo pipefail

value="${1:?}"
style="${2:-}"
sock="${XDG_RUNTIME_DIR:-/tmp}/wob.sock"

[[ "${value}" =~ ^[0-9]+$ ]] || exit 0
[[ -p "${sock}" ]] || exit 0

if [[ -n "${style}" ]]; then
    line="${value} ${style}"
else
    line="${value}"
fi

printf '%s\n' "${line}" | timeout 0.2 tee "${sock}" >/dev/null || true
