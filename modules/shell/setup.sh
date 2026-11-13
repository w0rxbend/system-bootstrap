#!/usr/bin/env bash
set -euo pipefail

# Shell: a host-local ~/.zshrc stub, Oh My Zsh, zsh as login shell,
# Oh My Zsh plugins and tmux plugins.
# Run by scripts/host.sh after this module's dotbot.yaml linked
# ~/.config/zsh/zshrc and ~/.tmux.conf.
#
# ~/.zshrc is not linked into the repo: installers (conda, pnpm, juliaup, ...)
# append to it, and those lines belong to this machine, not to the repo.

: "${REPO_ROOT:?run through scripts/host.sh}"

# shellcheck source=scripts/lib/common.sh
. "${REPO_ROOT}/scripts/lib/common.sh"

ZSHRC="${HOME}/.zshrc"
SHARED_ZSHRC="${REPO_ROOT}/.files/.zshrc"
STUB_LINE='[[ -r ~/.config/zsh/zshrc ]] && source ~/.config/zsh/zshrc'

# Writing through the old link would edit the repo file, so remove the link
# first. Only a link to the repo copy (or a dead link) is removed.
if [ -L "${ZSHRC}" ]; then
    if [ ! -e "${ZSHRC}" ] || [ "$(readlink -f "${ZSHRC}")" = "$(readlink -f "${SHARED_ZSHRC}")" ]; then
        info "Replacing the ${ZSHRC} link with a local stub"
        rm -- "${ZSHRC}"
    else
        skip "${ZSHRC} links to $(readlink "${ZSHRC}"); left as is"
    fi
fi

if [ ! -e "${ZSHRC}" ]; then
    printf '%s\n' "${STUB_LINE}" >"${ZSHRC}"
elif ! grep -qF '.config/zsh/zshrc' "${ZSHRC}"; then
    skip "${ZSHRC} does not load the shared config; add: ${STUB_LINE}"
fi

# Oh My Zsh after the stub: KEEP_ZSHRC=yes keeps it, and RUNZSH/CHSH=no stop
# the installer from starting zsh or prompting.
OMZ_DIR="${ZSH:-${HOME}/.oh-my-zsh}"
if [ -f "${OMZ_DIR}/oh-my-zsh.sh" ]; then
    skip "Oh My Zsh already installed in ${OMZ_DIR}"
else
    info "Installing Oh My Zsh"
    omz_tmp="$(mktemp -d)"
    trap 'rm -rf -- "${omz_tmp}"' EXIT
    curl -fsSL -o "${omz_tmp}/install.sh" https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh "${omz_tmp}/install.sh" --unattended
fi

zsh_path="$(command -v zsh)" || die "zsh is not installed; it is in this module's package list"
user="${USER:-$(id -un)}"
if [ "$(getent passwd "${user}" | cut -d: -f7)" = "${zsh_path}" ]; then
    skip "login shell of ${user} is already ${zsh_path}"
else
    info "Setting the login shell of ${user} to ${zsh_path}"
    sudo chsh -s "${zsh_path}" "${user}"
fi

"${REPO_ROOT}/scripts/oh-my-zsh-plugins.sh"
"${REPO_ROOT}/scripts/oh-tmux-plugin-manager.sh"
