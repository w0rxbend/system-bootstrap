#!/usr/bin/env bash
set -euo pipefail

# CLI tools: binstaller profile and cargo-binstall packages.
# Run by scripts/host.sh after the dev module installed cargo-binstall.

: "${REPO_ROOT:?run through scripts/host.sh}"

"${REPO_ROOT}/scripts/binary-dist.sh"

# binstaller replaces a whole installDir, so it cannot install into ~/.local/bin.
# Link the pinned copy there instead; -f replaces an older standalone binary.
mkdir -p "${HOME}/.local/bin"
ln -sfn "${HOME}/.apps/nerd-fonts-installer/bin/nerd-fonts-installer" "${HOME}/.local/bin/nerd-fonts-installer"

"${REPO_ROOT}/scripts/cargo-packages.sh"
