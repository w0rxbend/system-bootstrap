# niri-dms

Niri with DankMaterialShell (DMS). `dotbot.yaml` links the Niri config and the
DMS settings from `.files/`. DMS writes its settings through these links, so
the sources stay at their `.files/` paths.

`packages.arch` lists the repo packages with a stated source. The DMS shell
(dms, dgop, danksearch) comes from the DMS installer, not pacman. TODO: confirm
the `# unverified:` names against the Niri host's `pacman -Qqe`.

DMS plugins are not linked: DMS replaces `plugins.lock.json` during updates. Run
these by hand from the repo root.

```sh
# Refresh the snapshot on the Niri host
dms plugins lock --output "$PWD/.files/.config/dms/plugins.lock.json"
# Restore it on another machine
dms plugins restore "$PWD/.files/.config/dms/plugins.lock.json"
```
