#!/bin/sh
# First run on a fresh machine: install git, curl, zsh and just, then provision
# the host with `just host <host>`. POSIX sh, so it runs before anything
# else is installed.
#
# Usage: ./bootstrap.sh <host>     (a directory under hosts/)
set -eu

host="${1:?usage: ./bootstrap.sh <host>}"
cd "$(dirname "$0")"
[ -f "hosts/${host}/host.env" ] || {
    echo "error: unknown host '${host}': hosts/${host}/host.env not found" >&2
    exit 1
}

if command -v pacman >/dev/null 2>&1; then
    sudo pacman -Syu --needed --noconfirm git curl zsh just
elif command -v dnf >/dev/null 2>&1; then
    sudo dnf -y install git curl zsh just
elif command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y git curl zsh
    if command -v just >/dev/null 2>&1; then
        :
    elif apt-cache show just >/dev/null 2>&1; then
        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y just
    else
        # No just package in this release: use the upstream installer.
        mkdir -p "${HOME}/.local/bin"
        curl --proto '=https' --tlsv1.2 -fsSL https://just.systems/install.sh |
            bash -s -- --to "${HOME}/.local/bin"
    fi
else
    echo "error: no pacman, dnf or apt-get found; unsupported distro" >&2
    exit 1
fi

PATH="${HOME}/.local/bin:${PATH}"
export PATH
exec just host "${host}"
