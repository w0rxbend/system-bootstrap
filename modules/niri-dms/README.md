# niri-dms

Niri with DankMaterialShell (DMS). `dotbot.yaml` links the Niri config and the
DMS settings from `.files/`. DMS writes its settings through these links, so
the sources stay at their `.files/` paths.

`setup.sh` installs niri and DMS with the official installer
(`https://install.duxlabs.dev`) in unattended mode: `--compositor niri --term
alacritty --dux-search --yes`. It deploys no configs, so the links above stay.
It skips when `dms` and `niri` are already installed.

DMS plugins are not linked: DMS replaces `plugins.lock.json` during updates. Run
these by hand from the repo root.

```sh
# Refresh the snapshot on the Niri host
dms plugins lock --output "$PWD/.files/.config/dms/plugins.lock.json"
# Restore it on another machine
dms plugins restore "$PWD/.files/.config/dms/plugins.lock.json"
```
