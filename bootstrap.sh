#!/bin/sh
# First run on a fresh machine: install git, curl, zsh and just, then provision
# the host with `just host <host>`. POSIX sh, so it runs before anything
# else is installed.
#
# Usage: ./bootstrap.sh <host>     (a directory under hosts/)
set -eu

host="${1:?usage: ./bootstrap.sh <host>}"
[ "$(id -u)" -ne 0 ] || {
    echo "error: run as your user, not root; the scripts call sudo themselves" >&2
    exit 1
}
cd "$(dirname "$0")"
[ -f "hosts/${host}/host.env" ] || {
    echo "error: unknown host '${host}': hosts/${host}/host.env not found" >&2
    exit 1
}

# Refuse a host for another distro before upgrading anything. Same match as
# os_id in scripts/lib/common.sh: DISTRO is this machine's ID or in ID_LIKE.
# shellcheck source=/dev/null
. "./hosts/${host}/host.env"
[ -n "${DISTRO:-}" ] || {
    echo "error: hosts/${host}/host.env does not set DISTRO" >&2
    exit 1
}
# shellcheck disable=SC1091
os="$(. /etc/os-release && echo " ${ID:-} ${ID_LIKE:-} ")"
case "${os}" in
    *" ${DISTRO} "*) ;;
    *)
        echo "error: ${host} is a ${DISTRO} host; this machine is${os}" >&2
        exit 1
        ;;
esac

case "${DISTRO}" in
    arch)
        sudo pacman -Syu --needed --noconfirm git curl zsh just
        ;;
    fedora)
        sudo dnf -y install git curl zsh just
        ;;
    ubuntu)
        sudo apt-get update
        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y git curl zsh
        if command -v just >/dev/null 2>&1; then
            :
        elif apt-cache show just >/dev/null 2>&1; then
            sudo DEBIAN_FRONTEND=noninteractive apt-get install -y just
        else
            # No just package in this release: use the upstream installer.
            mkdir -p "${HOME}/.local/bin"
            curl --proto '=https' --tlsv1.2 -fsSL https://just.systems/install.sh \
                | bash -s -- --to "${HOME}/.local/bin"
        fi
        ;;
    *)
        echo "error: unsupported DISTRO '${DISTRO}' in hosts/${host}/host.env" >&2
        exit 1
        ;;
esac

PATH="${HOME}/.local/bin:${PATH}"
export PATH
# --yes: the host recipe asks for confirmation; the first run stays unattended.
exec just --yes host "${host}"
