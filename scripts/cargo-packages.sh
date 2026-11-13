#!/usr/bin/env bash
set -euo pipefail

# Rust CLI tools as prebuilt binaries via cargo-binstall.
# Run by modules/cli/setup.sh; scripts/cli-tools.sh (dev module) installs
# cargo-binstall first.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# shellcheck source=scripts/lib/common.sh
. "${REPO_ROOT}/scripts/lib/common.sh"

CRATES=(
    eza lsd fd-find ripgrep bingrep hx just sd procs du-dust gping
    tree-sitter-cli
    macchina multibg-wayland bottom broot
)

# cargo-binstall may have been installed earlier in this run, before PATH knew it.
PATH="${CARGO_HOME:-${HOME}/.cargo}/bin:${PATH}"
have cargo-binstall || die "cargo-binstall not found; run the dev module first"

cargo-binstall -y "${CRATES[@]}"
