#!/usr/bin/env bash
set -euo pipefail

# CLI tools: binstaller profile and cargo-binstall packages.
# Run by scripts/host.sh after the dev module installed cargo-binstall.

: "${REPO_ROOT:?run through scripts/host.sh}"

"${REPO_ROOT}/scripts/binary-dist.sh"
"${REPO_ROOT}/scripts/cargo-packages.sh"
