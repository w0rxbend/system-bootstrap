# Arch + Sway

The `sway` module (`modules/sway/`) for the `arch-sway` host. Only hosts that list `sway` in `MODULES` get it; it does not change GNOME, Niri, or DankMaterialShell.

The look follows the Dux dark purple theme: square corners, no blur. Window borders are 1 pixel and hide when a workspace has a single window. The focused frame stays lavender. Only the edge where the next window opens is marked, in deep purple, whether that window opens beside this one or below it. Urgent windows, a wrong password, and errors use the Dux urgent pink.

| Role              | Hex       | Dux token           |
| ----------------- | --------- | ------------------- |
| Background        | `#141218` | surface, background |
| Text              | `#e6e0e9` | surface text        |
| Outline           | `#948f99` | inactive border     |
| Primary           | `#d0bcff` | focused frame       |
| Primary text      | `#381e72` | text on primary     |
| Primary container | `#4f378b` | spawn edge          |
| Secondary         | `#ccc2dc` | match, warning      |
| Error             | `#f2b8b5` | urgent, wrong       |

Region select dims the screen with the background and draws a lavender border. The bar shows the binding mode (for example `resize`) in lavender while a mode is active.

Waybar is a flat full-width strip, the same shape as stock swaybar, in the Dux purple colors. Workspace numbers sit on the left. The focused one is a lavender block with deep purple text. Next to them: `cpu`, `mem`, `disk`. On the right, first is `us` or `ua`, then CO2, PM2.5, and AQI from the AirGradient monitor, then `vol`, the network, secondary `rec` while recording, and a 24-hour clock. The far right is `idle` (or `awake` while the screen is held on). Click `idle` to stop the lock and the panel power-off. Click `awake` to allow them again. Fuzzel replaces Wofi and wmenu. App icons in Fuzzel stay off. Kanshi sets the monitor. Sway does not set resolution, position, or scale. Alacritty and Foot use the same colors. The shared Catppuccin file stays at `modules/desktop/files/alacritty/theme.toml`.

## Apply

From `~/.system-bootstrap`. On a fresh machine, `./bootstrap.sh arch-sway` installs `just` and runs `just host arch-sway`.

```bash
just dry arch-sway                # preview: package check, dotbot -n, no changes
just host arch-sway               # every module of the host
just module arch-sway sway        # only this module: packages.arch, links, setup.sh
```

Then log out of Sway and back in. Sway chooses `~/.config/sway/config` at startup. A reload of the current session keeps using `/etc/sway/config` if that is what it started with.

The desktop module owns `~/.config/alacritty/alacritty.toml`, `base.toml` and `theme.toml`. This module adds `wm.toml` with the Dux colors and the RecMono font, which alacritty loads after the shared theme. The base module's `clean` step only removes dead links that point into this repo.

## What gets linked

| Repo path                                 | Home path                             |
| ----------------------------------------- | ------------------------------------- |
| `modules/sway/files/sway/config`          | `~/.config/sway/config`               |
| `modules/sway/files/sway/scripts/`        | `~/.config/sway/scripts`              |
| `assets/wallpapers/`                      | `~/Pictures/walls`                    |
| `modules/sway/files/wpaperd/config.toml`  | `~/.config/wpaperd/config.toml`       |
| `modules/sway/files/waybar/config.jsonc`  | `~/.config/waybar/config.jsonc`       |
| `modules/sway/files/waybar/style.css`     | `~/.config/waybar/style.css`          |
| `modules/sway/files/alacritty/wm.toml`    | `~/.config/alacritty/wm.toml`         |
| `modules/sway/files/fuzzel/fuzzel.ini`    | `~/.config/fuzzel/fuzzel.ini`         |
| `modules/sway/files/kanshi/config`        | `~/.config/kanshi/config`             |
| `modules/sway/files/mako/config`          | `~/.config/mako/config`               |
| `modules/sway/files/foot/foot.ini`        | `~/.config/foot/foot.ini`             |
| `modules/sway/files/swaynag/config`       | `~/.config/swaynag/config`            |
| `modules/sway/files/wlsunset/config`      | `~/.config/wlsunset/config`           |
| `modules/sway/files/wob/wob.ini`          | `~/.config/wob/wob.ini`               |
| `modules/sway/files/systemd/skbd.service` | `~/.config/systemd/user/skbd.service` |

Links are forced. A real file already at one of those paths is replaced by the symlink.

## Keys

Same as the stock Sway config, with two launcher changes:

| Key              | Action                                                            |
| ---------------- | ----------------------------------------------------------------- |
| Super+Space      | Switch keyboard layout: English (US), then Ukrainian              |
| Super+Ctrl+Space | Move focus between floating and tiled windows                     |
| Super+Return     | Alacritty                                                         |
| Super+D          | Fuzzel app launcher                                               |
| Super+Shift+E    | Power menu: lock, suspend, log out, reboot, shut down             |
| Super+Escape     | Lock the screen                                                   |
| Super+Shift+A    | Audio menu: choose the output, then the input                     |
| Super+Shift+C    | Reload Sway                                                       |
| Print            | Region screenshot, saved and copied                               |
| Shift+Print      | Full-screen screenshot, saved and copied                          |
| Super+Print      | Focused window screenshot, saved and copied                       |
| Super+Shift+R    | Start or stop a recording of the focused output, with its audio   |
| Super+Alt+R      | Start or stop a region recording, with the default output's audio |
| Super+Shift+V    | Clipboard history                                                 |
| Super+Alt+V      | Delete one clipboard entry                                        |
| Super+Shift+G    | Cycle sunset: day, night, then automatic                          |

Screenshots go to `~/Pictures/screenshots`. Recordings go to `~/Videos/recordings`. The bar shows `rec` while `wf-recorder` is running. Click `vol` to open the audio menu; right-click still mutes. The screen locks after 5 idle minutes and before sleep.

Volume and brightness keys draw a blue bar at the bottom of the screen. Mute draws that bar in gray. Brightness keys only affect a backlight; this desktop has none, so those keys do nothing. New windows split horizontally or vertically to match the container shape. autotiling leaves tabbed, stacked, floating, and fullscreen containers alone.

## Sunset

wlsunset shifts the display gamma from 6500 K during the day to 4000 K at night. The coordinates in `~/.config/wlsunset/config` are 50.5 N, 30.5 E, matching the system timezone Europe/Kyiv. wlsunset only uses one decimal place. Change them if the machine is somewhere else. Super+Shift+G cycles day, night, and automatic.

## Wallpaper

`~/Pictures/walls` links to the repo's `assets/wallpapers` directory. It includes `pmxrh3o9rdgb1.png` from [laggy-tux/sway-Dots](https://github.com/laggy-tux/sway-Dots). wpaperd shows a random image from that directory on every output and switches every minute with a fade. Add images to the directory to rotate them; subdirectories count too. `wpaperctl next` skips to the next image. Change the interval, order, or scaling in `~/.config/wpaperd/config.toml`; wpaperd reloads it on save. The path must stay a directory, because wpaperd rejects `duration` on a single file.

## Clipboard

cliphist stores text and image copies. Super+Shift+V pastes an older entry back to the clipboard. Super+Alt+V deletes one entry. The menu uses the same Fuzzel theme as the launcher.

## Monitor

The Kanshi profile `dell-p3223qe` matches the connected panel:

- Output description: `Dell Inc. DELL P3223QE 6BVG3P3`
- Mode: `3840x2160@59.997Hz`
- Position: `0,0`
- Scale: `1.25`

Sway sets the same scale and `scale_filter linear` for that description. Kanshi still chooses the mode and the position. 1.25 turns 3840x2160 into a logical 3072x1728, a small step up on this 32-inch panel. Use 1.5 in both files if that is still too small.

Kanshi only enables a profile when every currently connected output is listed in it. Another display needs a new profile that names both outputs. Names come from `swaymsg -t get_outputs`.

## Font

The bar, titles, launcher, notifications, lock, swaynag, region readout, Foot, and Alacritty use RecMono Linear (`RecMonoLinear Nerd Font Mono`), Recursive Mono 1.085. The bar is 15px. The lock text is 23px and the ring radius is 112. Titles, menus, notifications, swaynag, and Foot are 16px. Alacritty stays at 14px and keeps the shared keybinds. `modules/sway/packages.arch` installs `ttf-recursive-nerd`, which also includes Casual, Duotone, and SemiCasual.
