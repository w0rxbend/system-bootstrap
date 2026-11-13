#!/usr/bin/env bash
set -euo pipefail

# Containers: on Arch, start Docker and add the user to the docker group.
# Fedora uses rootless podman and needs no service. Run by scripts/host.sh.
# The group change applies after the next login.

: "${REPO_ROOT:?run through scripts/host.sh}"
: "${DISTRO:?run through scripts/host.sh}"

# shellcheck source=scripts/lib/common.sh
. "${REPO_ROOT}/scripts/lib/common.sh"

case "${DISTRO}" in
    arch)
        enable_service docker.service
        ensure_user_in_group docker
        ;;
    *)
        skip "nothing to set up for containers on ${DISTRO}"
        ;;
esac
