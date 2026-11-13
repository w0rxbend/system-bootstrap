#!/usr/bin/env bash
set -euo pipefail

# Sway: reload user units so the linked skbd.service is seen.
# Run by scripts/host.sh after packages.arch and this module's dotbot.yaml.

: "${REPO_ROOT:?run through scripts/host.sh}"

# shellcheck source=scripts/lib/common.sh
. "${REPO_ROOT}/scripts/lib/common.sh"

SKBD_UNIT="${XDG_CONFIG_HOME:-${HOME}/.config}/systemd/user/skbd.service"
if [ ! -e "${SKBD_UNIT}" ]; then
    skip "${SKBD_UNIT} not linked; user units not reloaded"
elif ! systemctl --user daemon-reload; then
    skip "no user systemd session; run 'systemctl --user daemon-reload' after login"
fi
