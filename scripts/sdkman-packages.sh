#!/usr/bin/env bash
set -euo pipefail

# SDKMAN and the JVM toolchains it manages. Run by modules/dev/setup.sh.
# Candidates that already have a current version are skipped.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# shellcheck source=scripts/lib/common.sh
. "${REPO_ROOT}/scripts/lib/common.sh"

SDKMAN_DIR="${SDKMAN_DIR:-${HOME}/.sdkman}"
CANDIDATES=(java gradle maven sbt scala micronaut vertx visualvm)

if [ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]; then
    skip "SDKMAN already installed"
else
    info "Installing SDKMAN"
    workdir="$(mktemp -d)"
    trap 'rm -rf -- "${workdir}"' EXIT
    curl --proto '=https' --tlsv1.2 -fsSL -o "${workdir}/sdkman.sh" "https://get.sdkman.io"
    bash "${workdir}/sdkman.sh"
fi

missing=()
for candidate in "${CANDIDATES[@]}"; do
    if [ -e "${SDKMAN_DIR}/candidates/${candidate}/current" ]; then
        skip "${candidate} already installed"
    else
        missing+=("${candidate}")
    fi
done
[ "${#missing[@]}" -gt 0 ] || exit 0

# sdkman-init.sh is not safe under `set -u`, so sdk runs in a child shell.
# shellcheck disable=SC2016
bash -c '
    source "$1/bin/sdkman-init.sh"
    sdkman_auto_answer=true
    shift
    status=0
    for candidate in "$@"; do
        sdk install "${candidate}" || status=1
    done
    exit "${status}"
' _ "${SDKMAN_DIR}" "${missing[@]}"
