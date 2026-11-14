#!/usr/bin/env bash
set -euo pipefail

# Install the configured Nerd Fonts with worxbend/nerd-fonts-installer.
# The cli module installs the pinned installer through the binstaller profile
# (modules/cli/files/binstaller/config.yaml); this script only runs it.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# Absolute path, so an older copy elsewhere on PATH never wins over the pinned one.
INSTALLER="${HOME}/.apps/nerd-fonts-installer/bin/nerd-fonts-installer"

# Prefer the installed/linked config; fall back to the in-repo copy if not applied yet.
CONFIG_PATH="${NERDFONT_CONFIG:-${HOME}/.config/nerd-fonts-installer/config.yaml}"
if [ ! -f "${CONFIG_PATH}" ]; then
    CONFIG_PATH="${REPO_ROOT}/modules/desktop/files/nerd-fonts-installer/config.yaml"
fi

if [ ! -f "${CONFIG_PATH}" ]; then
    echo "Nerd Fonts installer config not found: ${CONFIG_PATH}" >&2
    exit 1
fi

if [ ! -x "${INSTALLER}" ]; then
    echo "nerd-fonts-installer not found: ${INSTALLER}" >&2
    echo "Run the cli module first (scripts/binary-dist.sh installs it)." >&2
    exit 1
fi

exec "${INSTALLER}" --config "${CONFIG_PATH}"
