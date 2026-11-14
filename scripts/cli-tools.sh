#!/usr/bin/env bash
set -euo pipefail

# Install user-level language toolchains and CLI installers.
# Run by modules/dev/setup.sh. Every installer runs non-interactively and is
# skipped when its tool is already there; ~/system-update.sh updates them.
# SDKMAN is installed by scripts/sdkman-packages.sh; helm and kustomize by the
# binstaller profile (scripts/binary-dist.sh). starship uses its official script.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# shellcheck source=scripts/lib/common.sh
. "${REPO_ROOT}/scripts/lib/common.sh"

WORKDIR="$(mktemp -d)"
trap 'rm -rf -- "${WORKDIR}"' EXIT

# Download <url> into the work dir as <name> and print the path.
fetch() {
    local name="$1" url="$2"

    curl --proto '=https' --tlsv1.2 -fsSL -o "${WORKDIR}/${name}" "${url}" || die "download failed: ${url}"
    printf '%s\n' "${WORKDIR}/${name}"
}

# True, with a message, when <command> is on PATH or <path> exists.
installed() {
    if have "$1" || [ -e "$2" ]; then
        skip "$1 already installed"
        return 0
    fi
    return 1
}

install_rustup() {
    installed rustup "${HOME}/.cargo/bin/rustup" && return 0
    sh "$(fetch rustup.sh https://sh.rustup.rs)" -y
}

install_nvm() {
    installed nvm "${NVM_DIR:-${HOME}/.nvm}/nvm.sh" && return 0
    bash "$(fetch nvm.sh https://raw.githubusercontent.com/nvm-sh/nvm/v0.41.0/install.sh)"
}

install_pyenv() {
    installed pyenv "${PYENV_ROOT:-${HOME}/.pyenv}/bin/pyenv" && return 0
    bash "$(fetch pyenv.sh https://pyenv.run)"
}

install_poetry() {
    installed poetry "${HOME}/.local/bin/poetry" && return 0
    have python3 || die "python3 is required to install poetry"
    python3 "$(fetch poetry.py https://install.python-poetry.org)"
}

install_starship() {
    installed starship /usr/local/bin/starship && return 0
    sh "$(fetch starship.sh https://starship.rs/install.sh)" -y
}

install_pnpm() {
    installed pnpm "${HOME}/.local/share/pnpm/pnpm" && return 0
    sh "$(fetch pnpm.sh https://get.pnpm.io/install.sh)"
}

install_juliaup() {
    installed juliaup "${HOME}/.juliaup/bin/juliaup" && return 0
    sh "$(fetch juliaup.sh https://install.julialang.org)" --yes
}

install_dotenvx() {
    installed dotenvx "${HOME}/.local/bin/dotenvx" && return 0
    sh "$(fetch dotenvx.sh "https://dotenvx.sh?directory=${HOME}/.local/bin")"
}

# Batch mode into ~/.miniforge3, the prefix .zshrc expects.
install_miniforge() {
    local installer

    installed miniforge "${HOME}/.miniforge3/bin/conda" && return 0
    installer="Miniforge3-$(uname)-$(uname -m).sh"
    bash "$(fetch "${installer}" "https://github.com/conda-forge/miniforge/releases/latest/download/${installer}")" \
        -b -p "${HOME}/.miniforge3"
}

install_uv() {
    installed uv "${HOME}/.local/bin/uv" && return 0
    sh "$(fetch uv.sh https://astral.sh/uv/install.sh)"
}

install_cargo_binstall() {
    installed cargo-binstall "${HOME}/.cargo/bin/cargo-binstall" && return 0
    bash "$(fetch cargo-binstall.sh https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh)"
}

have curl || die "curl is required"

for tool in rustup nvm pyenv poetry starship pnpm juliaup dotenvx miniforge uv cargo_binstall; do
    info "${tool}"
    "install_${tool}"
done
