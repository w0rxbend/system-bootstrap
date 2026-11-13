#!/usr/bin/env bash
set -euo pipefail

# Global git settings and the system clock. Run by modules/base/setup.sh.
# GIT_USER_NAME and GIT_USER_EMAIL come from hosts/<host>/host.env.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# shellcheck source=scripts/lib/common.sh
. "${REPO_ROOT}/scripts/lib/common.sh"

info "Configuring git"
git config --global user.email "${GIT_USER_EMAIL:-balyszyn@gmail.com}"
git config --global user.name "${GIT_USER_NAME:-w0rxbend}"
git config --global pull.rebase true
git config --global init.defaultBranch main
git config --global core.autocrlf input

info "Configuring time"
if [ -d /run/systemd/system ]; then
    sudo timedatectl set-local-rtc 0
    sudo timedatectl set-ntp true
fi
