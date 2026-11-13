#!/usr/bin/env bash
set -euo pipefail

# Developer toolchains: language installers, Go, SDKMAN, conda settings.
# Run by scripts/host.sh.

: "${REPO_ROOT:?run through scripts/host.sh}"

# shellcheck source=scripts/lib/common.sh
. "${REPO_ROOT}/scripts/lib/common.sh"

"${REPO_ROOT}/scripts/cli-tools.sh"
"${REPO_ROOT}/scripts/install_golang.sh"
"${REPO_ROOT}/scripts/sdkman-packages.sh"

# Miniforge was possibly installed a moment ago, so it is not on PATH yet.
conda_bin="$(command -v conda || printf '%s' "${HOME}/.miniforge3/bin/conda")"
if [ -x "${conda_bin}" ]; then
    "${conda_bin}" config --set changeps1 False
else
    skip "conda not found; changeps1 not set"
fi
