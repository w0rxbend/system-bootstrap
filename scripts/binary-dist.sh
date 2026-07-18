#!/usr/bin/env bash
set -euo pipefail

# Install portable binary tools into ~/.apps via worxbend/binstaller.
# https://github.com/worxbend/binstaller
#
# The tool set is declared in a BinaryDistributionProfile (see config below) rather
# than hand-rolled curl/tar steps. binstaller resolves versions, downloads, extracts,
# installs into ${HOME}/.apps/<tool>/bin, and creates the (sudo) symlinks.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALL_DIR="${BINSTALLER_INSTALL_DIR:-${HOME}/.local/bin}"
BINSTALLER="${INSTALL_DIR}/binstaller"

# Prefer the installed/linked config; fall back to the in-repo copy when dotfiles
# have not been applied yet (this script runs before `just apply-dotfiles`).
CONFIG_PATH="${BINSTALLER_CONFIG:-${HOME}/.config/binstaller/config.yaml}"
if [ ! -f "${CONFIG_PATH}" ]; then
    CONFIG_PATH="${REPO_ROOT}/.files/.config/binstaller/config.yaml"
fi

if [ ! -f "${CONFIG_PATH}" ]; then
    echo "binstaller config not found: ${CONFIG_PATH}" >&2
    exit 1
fi

# Install binstaller (latest release) if it is not already available.
if ! command -v binstaller >/dev/null 2>&1 && [ ! -x "${BINSTALLER}" ]; then
    echo "Installing binstaller (latest release)..."
    curl --proto '=https' --tlsv1.2 -sSfL \
        https://github.com/worxbend/binstaller/releases/latest/download/install.sh | sh
fi

# ~/.local/bin may not be on PATH in this shell yet; fall back to the absolute path.
binstaller_cmd="binstaller"
command -v binstaller >/dev/null 2>&1 || binstaller_cmd="${BINSTALLER}"

echo "Applying binary distribution profile: ${CONFIG_PATH}"
"${binstaller_cmd}" plan --config "${CONFIG_PATH}"
"${binstaller_cmd}" apply --config "${CONFIG_PATH}"
