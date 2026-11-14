#!/usr/bin/env bash
set -euo pipefail

# Global git settings and the system clock. Run by modules/base/setup.sh.
# GIT_USER_NAME and GIT_USER_EMAIL come from hosts/<host>/host.env.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# shellcheck source=scripts/lib/common.sh
. "${REPO_ROOT}/scripts/lib/common.sh"

# Set <key> to <given> when given, else to <default> only when <key> is unset,
# so a re-run keeps an identity set by hand on this machine.
set_git_identity() {
    local key="$1" given="$2" default="$3"

    if [ -n "${given}" ] || ! git config --global "${key}" >/dev/null; then
        git config --global "${key}" "${given:-${default}}"
    fi
}

info "Configuring git"
set_git_identity user.email "${GIT_USER_EMAIL:-}" balyszyn@gmail.com
set_git_identity user.name "${GIT_USER_NAME:-}" w0rxbend
git config --global pull.rebase true
git config --global init.defaultBranch main
git config --global core.autocrlf input

info "Configuring time"
if [ -d /run/systemd/system ]; then
    sudo timedatectl set-local-rtc 0
    sudo timedatectl set-ntp true
fi
