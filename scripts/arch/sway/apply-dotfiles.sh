#!/usr/bin/env bash
# Link the Arch + Sway overlay only.
# Does not apply the shared dotfiles or the Fedora, Hyprland, Niri, or DankMaterialShell configs.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
OVERLAY="${REPO_ROOT}/.files/arch/sway"
CONFIG="${OVERLAY}/install.conf.yaml"
DOTBOT_VERSION="0.4.2"
WORKDIR=""

have() {
    command -v "$1" >/dev/null 2>&1
}

cleanup() {
    if [ -n "${WORKDIR}" ]; then
        rm -rf "${WORKDIR}"
    fi
}
trap cleanup EXIT

sha256_file() {
    local file="$1" sum
    if have sha256sum; then
        sum="$(sha256sum "${file}")"
    elif have shasum; then
        sum="$(shasum -a 256 "${file}")"
    else
        echo "sha256sum or shasum is required to verify dotbot-go" >&2
        exit 1
    fi
    printf '%s\n' "${sum%% *}"
}

resolve_dotbot() {
    if [ -n "${DOTBOT:-}" ]; then
        if [ ! -x "${DOTBOT}" ]; then
            echo "DOTBOT is set but not executable: ${DOTBOT}" >&2
            exit 1
        fi
        printf '%s\n' "${DOTBOT}"
        return 0
    fi
    if [ -x "${HOME}/.local/bin/dotbot" ]; then
        printf '%s\n' "${HOME}/.local/bin/dotbot"
        return 0
    fi
    download_dotbot
}

download_dotbot() {
    local arch expected url archive actual
    case "$(uname -m)" in
        x86_64 | amd64) arch="amd64" ;;
        aarch64 | arm64) arch="arm64" ;;
        *)
            echo "unsupported architecture: $(uname -m)" >&2
            exit 1
            ;;
    esac
    case "${arch}" in
        amd64) expected="a7229b8d098454ffeb2858ddcf1b63602dfc7be06e08b57c39d839c08f9dbd01" ;;
        arm64) expected="21e94e915de43f2cbe086973437ec6a5f81e46ddbc5280707165c0ebb6090b45" ;;
        *)
            echo "no pinned dotbot-go build for linux-${arch}" >&2
            exit 1
            ;;
    esac

    url="https://github.com/worxbend/dotbot-go/releases/download/v${DOTBOT_VERSION}/dotbot-linux-${arch}.tar.gz"
    WORKDIR="$(mktemp -d)"
    archive="${WORKDIR}/dotbot.tar.gz"
    echo "dotbot not found; downloading ${url}" >&2
    curl --proto '=https' --tlsv1.2 -fsSL "${url}" -o "${archive}"
    actual="$(sha256_file "${archive}")"
    if [ "${actual}" != "${expected}" ]; then
        echo "dotbot-go checksum mismatch for ${url}: ${actual} != ${expected}" >&2
        exit 1
    fi
    tar -xzf "${archive}" -C "${WORKDIR}" dotbot
    chmod +x "${WORKDIR}/dotbot"
    printf '%s\n' "${WORKDIR}/dotbot"
}

if [ ! -f "${CONFIG}" ]; then
    echo "missing ${CONFIG}" >&2
    exit 1
fi

dotbot_bin="$(resolve_dotbot)"

echo "Linking Arch + Sway dotfiles with ${dotbot_bin}"
"${dotbot_bin}" -d "${OVERLAY}" -c "${CONFIG}"
echo "Linked. Log out of Sway and back in so ~/.config/sway/config is the one that loads."
