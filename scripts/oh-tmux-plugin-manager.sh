#!/usr/bin/env bash
set -euo pipefail

# Install TPM (Tmux Plugin Manager) and the plugins declared in .tmux.conf.
# https://github.com/tmux-plugins/tpm
#
# The plugin list lives in `.files/.tmux.conf` (`set -g @plugin ...`), which
# ends with `run '~/.tmux/plugins/tpm/tpm'` — so TPM must sit at that exact
# path. Plugins are installed non-interactively via TPM's own `bin/install_plugins`
# instead of the in-tmux `prefix + I` binding.

TPM_REPO="https://github.com/tmux-plugins/tpm"
TPM_DIR="${HOME}/.tmux/plugins/tpm"

# This repo links ~/.tmux.conf, but TPM also honours the XDG location; accept either.
TMUX_CONFS=(
    "${HOME}/.tmux.conf"
    "${XDG_CONFIG_HOME:-${HOME}/.config}/tmux/tmux.conf"
)

info() {
    printf '\n==> %s\n' "$*"
}

skip() {
    printf 'skip: %s\n' "$*"
}

have() {
    command -v "$1" >/dev/null 2>&1
}

if ! have git; then
    echo "git is required to install TPM" >&2
    exit 1
fi

if [ -d "${TPM_DIR}/.git" ]; then
    info "Updating TPM in ${TPM_DIR}"
    # A dirty or diverged checkout is not worth aborting the bootstrap over.
    git -C "${TPM_DIR}" pull --ff-only || skip "could not fast-forward TPM; keeping the existing checkout"
else
    info "Cloning TPM into ${TPM_DIR}"
    mkdir -p "$(dirname "${TPM_DIR}")"
    git clone "${TPM_REPO}" "${TPM_DIR}"
fi

# Installing the plugins needs both tmux and a linked .tmux.conf to read the
# `@plugin` list from. Either can legitimately be missing when this runs before
# the distro packages or `just apply-dotfiles`, so degrade instead of failing.
if ! have tmux; then
    skip "tmux not installed; TPM is in place, plugins will install on first run"
    exit 0
fi

tmux_conf=""
for candidate in "${TMUX_CONFS[@]}"; do
    if [ -e "${candidate}" ]; then
        tmux_conf="${candidate}"
        break
    fi
done

if [ -z "${tmux_conf}" ]; then
    skip "no tmux.conf found (${TMUX_CONFS[*]}); run 'just apply-dotfiles' first, then re-run this"
    exit 0
fi

info "Installing tmux plugins declared in ${tmux_conf}"
"${TPM_DIR}/bin/install_plugins"

info "Updating tmux plugins"
"${TPM_DIR}/bin/update_plugins" all
