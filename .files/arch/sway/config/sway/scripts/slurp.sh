#!/usr/bin/env bash
# Dux purple region select. Callers treat cancel as "do nothing".
set -euo pipefail

exec slurp \
    -b '#141218b0' \
    -c '#d0bcffff' \
    -s '#d0bcff33' \
    -B '#141218ff' \
    -w 2 \
    -F "RecMonoLinear Nerd Font Mono" \
    "$@"
