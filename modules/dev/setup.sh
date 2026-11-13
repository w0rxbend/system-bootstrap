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

if have conda; then
    conda config --set changeps1 False
else
    skip "conda is not on PATH; changeps1 not set (open a new shell and re-run this module)"
fi
