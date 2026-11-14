#!/usr/bin/env bash
set -euo pipefail

# Sway: reload user units so the linked skbd.service is seen, select the
# adw-gtk3-dark theme that reads the linked gtk-3.0/gtk.css, and make Thunar
# the default file manager and xarchiver the default archive manager.
# Run by scripts/host.sh after packages.arch and this module's dotbot.yaml.

: "${REPO_ROOT:?run through scripts/host.sh}"

# shellcheck source=scripts/lib/common.sh
. "${REPO_ROOT}/scripts/lib/common.sh"

SKBD_UNIT="${XDG_CONFIG_HOME:-${HOME}/.config}/systemd/user/skbd.service"
if [ ! -e "${SKBD_UNIT}" ]; then
    skip "${SKBD_UNIT} not linked; user units not reloaded"
elif ! systemctl --user daemon-reload; then
    skip "no user systemd session; run 'systemctl --user daemon-reload' after login"
fi

if have gsettings; then
    info "Setting GTK theme to adw-gtk3-dark"
    gsettings set org.gnome.desktop.interface gtk-theme adw-gtk3-dark
    gsettings set org.gnome.desktop.interface color-scheme prefer-dark
else
    skip "gsettings not found; GTK theme not set"
fi

if have xdg-mime; then
    info "Setting Thunar as the default file manager"
    xdg-mime default thunar.desktop inode/directory
    # thunar-archive-plugin runs the .tap of the archive's default app, so
    # Extract Here works only while xarchiver owns these types.
    info "Setting xarchiver as the default archive manager"
    xdg-mime default xarchiver.desktop \
        application/zip application/x-7z-compressed application/vnd.rar \
        application/x-rar application/x-tar application/gzip \
        application/x-compressed-tar application/x-bzip2 \
        application/x-bzip2-compressed-tar application/x-xz \
        application/x-xz-compressed-tar application/zstd \
        application/x-zstd-compressed-tar
else
    skip "xdg-mime not found; default file and archive managers not set"
fi
