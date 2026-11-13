#!/usr/bin/env bash
set -euo pipefail

# Base system: distro packages and repos, then git and time settings.
# Run by scripts/host.sh, which sets HOST, DISTRO and REPO_ROOT.
# For now this calls the legacy distro scripts as they are; their package
# lists move into modules/*/packages.<distro> later.

: "${REPO_ROOT:?run through scripts/host.sh}"
: "${DISTRO:?run through scripts/host.sh}"

# shellcheck source=scripts/lib/common.sh
. "${REPO_ROOT}/scripts/lib/common.sh"

case "${DISTRO}" in
    arch)
        "${REPO_ROOT}/scripts/arch/00-system-update.sh"
        "${REPO_ROOT}/scripts/arch/02-base-packages.sh"
        ;;
    fedora)
        "${REPO_ROOT}/scripts/fedora/00-system-update.sh"
        "${REPO_ROOT}/scripts/fedora/01-packages.sh"
        "${REPO_ROOT}/scripts/fedora/02-extras.sh"
        ;;
    ubuntu)
        skip "no Ubuntu package step yet; install packages by hand"
        ;;
    *)
        die "unsupported DISTRO: ${DISTRO}"
        ;;
esac

"${REPO_ROOT}/scripts/configurations.sh"
