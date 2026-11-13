#!/usr/bin/env bash
set -euo pipefail

# GNOME: workspace keybindings, Extension Manager and Refine flatpaks, and
# PaperWM settings when PaperWM is installed.
# PaperWM itself is installed by hand; this only loads its settings.
# Run by scripts/host.sh.

: "${REPO_ROOT:?run through scripts/host.sh}"

# shellcheck source=scripts/lib/common.sh
. "${REPO_ROOT}/scripts/lib/common.sh"

PAPERWM_DIR="${XDG_DATA_HOME:-${HOME}/.local/share}/gnome-shell/extensions/paperwm@paperwm.github.com"
PAPERWM_CONF="${REPO_ROOT}/.files/paperwm.conf"

# Set a key only when its schema exists; GNOME versions differ.
gset() {
    local schema="$1"
    shift
    if grep -qx "${schema}" <<<"${schemas}"; then
        gsettings set "${schema}" "$@"
    else
        skip "schema ${schema} not found; $1 not set"
    fi
}

if have gsettings; then
    info "Setting GNOME workspace keybindings"
    schemas="$(gsettings list-schemas)"
    for i in 1 2 3 4 5 6 7 8 9; do
        gset org.gnome.shell.keybindings "switch-to-application-${i}" "[]"
        gset org.gnome.desktop.wm.keybindings "switch-to-workspace-${i}" "['<Super>${i}']"
        gset org.gnome.desktop.wm.keybindings "move-to-workspace-${i}" "['<Super><Shift>${i}']"
    done
    gset org.gnome.mutter dynamic-workspaces false
    gset org.gnome.desktop.wm.preferences num-workspaces 9
    gset org.gnome.shell.keybindings show-screenshot-ui "['<Super>Print', 'Print']"
else
    skip "gsettings not found; GNOME keybindings not set"
fi

if have flatpak; then
    info "Installing GNOME flatpaks"
    flatpak install -y --noninteractive flathub com.mattjakeman.ExtensionManager page.tesk.Refine
else
    skip "flatpak not found; Extension Manager and Refine not installed"
fi

if [ ! -d "${PAPERWM_DIR}" ]; then
    skip "PaperWM is not installed (${PAPERWM_DIR}); its settings are not loaded"
elif ! have dconf; then
    die "PaperWM is installed but dconf is missing; cannot load ${PAPERWM_CONF}"
else
    info "Loading PaperWM settings"
    dconf load /org/gnome/shell/extensions/paperwm/ <"${PAPERWM_CONF}"
fi
