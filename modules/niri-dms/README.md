# niri-dms

Niri with DankMaterialShell (DMS). `dotbot.yaml` links the Niri config and the
DMS settings from `files/`. DMS writes its settings through these links, so
changes land in the repo. Qt's QSaveFile follows symlink chains, so the compat
links under `.files/.config/` work until arch-niri re-applies.

`setup.sh` installs niri and DMS with the official installer
(`https://install.duxlabs.dev`) in unattended mode: `--compositor niri --term
alacritty --dux-search --yes`. It deploys no configs, so the links above stay.
It skips when `dms` and `niri` are already installed.

DMS plugins are not linked: DMS replaces `plugins.lock.json` during updates. Run
these by hand from the repo root.

```sh
# Refresh the snapshot on the Niri host
dms plugins lock --output "$PWD/modules/niri-dms/files/dms/plugins.lock.json"
# Restore it on another machine
dms plugins restore "$PWD/modules/niri-dms/files/dms/plugins.lock.json"
```

`modules/niri-dms/files/dms/monitors.json` is an unlinked snapshot of the arch-niri
monitor layout. It holds that machine's monitor ids, so nothing links it.

`~/.config/mimeapps.list` is linked, but GLib and GNOME save it by replacing the
link with a plain file. Copy default-app changes back to
`modules/niri-dms/files/mimeapps.list` before you re-apply, or the re-apply overwrites
them.
