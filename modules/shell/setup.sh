#!/usr/bin/env bash
set -euo pipefail

# Shell: Oh My Zsh plugins and tmux plugins.
# Run by scripts/host.sh after this module's dotbot.yaml linked ~/.tmux.conf.

: "${REPO_ROOT:?run through scripts/host.sh}"

"${REPO_ROOT}/scripts/oh-my-zsh-plugins.sh"
"${REPO_ROOT}/scripts/oh-tmux-plugin-manager.sh"
