#!/usr/bin/env bash
set -euo pipefail

# CLI tools: binstaller profile, yazi plugins and cargo-binstall packages.
# Run by scripts/host.sh after the dev module installed cargo-binstall.

: "${REPO_ROOT:?run through scripts/host.sh}"

# shellcheck source=scripts/lib/common.sh
. "${REPO_ROOT}/scripts/lib/common.sh"

"${REPO_ROOT}/scripts/binary-dist.sh"

# binstaller replaces a whole installDir, so it cannot install into ~/.local/bin.
# Link the pinned copy there instead; -f replaces an older standalone binary.
mkdir -p "${HOME}/.local/bin"
ln -sfn "${HOME}/.apps/nerd-fonts-installer/bin/nerd-fonts-installer" "${HOME}/.local/bin/nerd-fonts-installer"

# Yazi plugins and flavor from the linked ~/.config/yazi/package.toml. Installing
# what package.toml pins is a no-op when it is already there.
ya_bin="$(command -v ya || true)"
ya_bin="${ya_bin:-${HOME}/.apps/yazi/bin/ya}"
if [ -x "${ya_bin}" ]; then
    "${ya_bin}" pkg install
else
    skip "ya not found; run 'ya pkg install' after yazi is installed"
fi

"${REPO_ROOT}/scripts/cargo-packages.sh"
