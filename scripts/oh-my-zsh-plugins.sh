#!/usr/bin/env bash
set -euo pipefail

# Clone or fast-forward the Oh My Zsh custom plugins used by .files/.zshrc.
# Safe to re-run: existing checkouts are pulled instead of cloned again.

PLUGINS_DIR="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/plugins"

PLUGIN_REPOS=(
    "https://github.com/zsh-users/zsh-syntax-highlighting.git"
    "https://github.com/zsh-users/zsh-autosuggestions"
    "https://github.com/zsh-users/zsh-history-substring-search"
)

if ! command -v git >/dev/null 2>&1; then
    echo "git is required to install Oh My Zsh plugins" >&2
    exit 1
fi

mkdir -p "${PLUGINS_DIR}"

for repo in "${PLUGIN_REPOS[@]}"; do
    name="$(basename "${repo}" .git)"
    dest="${PLUGINS_DIR}/${name}"
    if [ -d "${dest}/.git" ]; then
        printf '\n==> Updating %s\n' "${name}"
        # A dirty or diverged checkout is not worth aborting the bootstrap over.
        git -C "${dest}" pull --ff-only || printf 'skip: could not fast-forward %s\n' "${name}"
    else
        printf '\n==> Cloning %s\n' "${name}"
        git clone "${repo}" "${dest}"
    fi
done
