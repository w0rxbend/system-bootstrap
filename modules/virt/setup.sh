#!/usr/bin/env bash
set -euo pipefail

# Virtualization: on Arch, start libvirtd and add the user to the libvirt
# group. Run by scripts/host.sh. The group change applies after the next login.

: "${REPO_ROOT:?run through scripts/host.sh}"
: "${DISTRO:?run through scripts/host.sh}"

# shellcheck source=scripts/lib/common.sh
. "${REPO_ROOT}/scripts/lib/common.sh"

case "${DISTRO}" in
    arch)
        enable_service libvirtd
        ensure_user_in_group libvirt
        ;;
    *)
        skip "nothing to set up for virtualization on ${DISTRO}"
        ;;
esac
