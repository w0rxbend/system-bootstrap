#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALL_DIR="${NERDFONT_INSTALLER_BIN_DIR:-${HOME}/.local/bin}"
INSTALLER="${INSTALL_DIR}/nerd-fonts-installer"
INSTALLER_REPO="${NERDFONT_INSTALLER_REPO:-worxbend/nerd-fonts-installer}"

# Prefer the installed/linked config; fall back to the in-repo copy if not applied yet.
CONFIG_PATH="${NERDFONT_CONFIG:-${HOME}/.config/nerd-fonts-installer/config.yaml}"
if [ ! -f "${CONFIG_PATH}" ]; then
    CONFIG_PATH="${REPO_ROOT}/.files/.config/nerd-fonts-installer/config.yaml"
fi

detect_os() {
    case "$(uname -s)" in
        Linux) echo "linux" ;;
        Darwin) echo "darwin" ;;
        *)
            echo "Unsupported OS: $(uname -s)" >&2
            return 1
            ;;
    esac
}

detect_arch() {
    case "$(uname -m)" in
        x86_64 | amd64) echo "amd64" ;;
        arm64 | aarch64) echo "arm64" ;;
        *)
            echo "Unsupported architecture: $(uname -m)" >&2
            return 1
            ;;
    esac
}

install_nerd_fonts_installer() {
    local os arch archive workdir base_url

    os="$(detect_os)"
    arch="$(detect_arch)"
    archive="nerd-fonts-installer_latest_${os}_${arch}.tar.gz"
    base_url="https://github.com/${INSTALLER_REPO}/releases/download/latest"
    workdir="$(mktemp -d)"

    trap 'rm -rf "${workdir}"' RETURN

    mkdir -p "${INSTALL_DIR}"
    curl -fsSLo "${workdir}/${archive}" "${base_url}/${archive}"
    curl -fsSLo "${workdir}/checksums.txt" "${base_url}/checksums.txt"

    (
        cd "${workdir}"
        if command -v sha256sum >/dev/null 2>&1; then
            sha256sum --check --ignore-missing checksums.txt
        fi
        tar -xzf "${archive}"
        find . -type f -name nerd-fonts-installer -exec chmod +x {} \; -exec mv {} "${INSTALLER}" \;
    )

    if [ ! -x "${INSTALLER}" ]; then
        echo "Downloaded archive did not contain nerd-fonts-installer" >&2
        exit 1
    fi
}

if [ ! -f "${CONFIG_PATH}" ]; then
    echo "Nerd Fonts installer config not found: ${CONFIG_PATH}" >&2
    exit 1
fi

if ! command -v nerd-fonts-installer >/dev/null 2>&1 && [ ! -x "${INSTALLER}" ]; then
    install_nerd_fonts_installer
fi

if command -v nerd-fonts-installer >/dev/null 2>&1; then
    exec nerd-fonts-installer --config "${CONFIG_PATH}"
fi

exec "${INSTALLER}" --config "${CONFIG_PATH}"
