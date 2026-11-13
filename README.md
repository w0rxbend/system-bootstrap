<h1 align="center">System Bootstrap</h1>

<p align="center">
  <strong>Multi-distro dotfiles, workstation bootstrap scripts, and desktop rice for a sharp Linux dev setup.</strong>
</p>

<p align="center">
  <a href="https://github.com/w0rxbend/system-bootstrap/actions/workflows/format-and-lint.yml">
    <img
      alt="Format and lint"
      src="https://github.com/w0rxbend/system-bootstrap/actions/workflows/format-and-lint.yml/badge.svg"
    >
  </a>
  <img alt="Fedora" src="https://img.shields.io/badge/Fedora-ready-51A2DA?logo=fedora&logoColor=white">
  <img alt="Arch Linux" src="https://img.shields.io/badge/Arch-ready-1793D1?logo=archlinux&logoColor=white">
  <img alt="License" src="https://img.shields.io/badge/license-GPL--3.0-blue">
</p>

<p align="center">
  <img src="assets/fedora-black-4k.png" width="49%" alt="Fedora desktop wallpaper">
</p>

## ✨ What This Is

`system-bootstrap` is a personal workstation automation repo for setting up a polished development environment across
Arch Linux, Fedora and Ubuntu.

It brings together package installation, binary tool installs, Dotbot-managed dotfiles, Nerd Fonts, terminal/editor
configuration, desktop environments, wallpapers, and maintenance workflows.

## 🚀 Highlights

| Area         | What You Get                                                        |
| ------------ | ------------------------------------------------------------------- |
| 🐧 Distros   | Arch Linux, Fedora and Ubuntu, per-host module lists                |
| 🧰 Dev tools | Zsh, tmux, Neovim, Go, Rust, Java, Node, Python, Kubernetes tools   |
| 🖥 Desktop    | GNOME, Niri + DankMaterialShell, Sway, Waybar, Fuzzel               |
| 🎨 Terminal  | Alacritty, Kitty, WezTerm, Ghostty, Starship, Zellij                |
| 🔤 Fonts     | Nerd Font installer config stored in the repo and linked via Dotbot |
| 🧹 Quality   | `just format`, `just lint`, and GitHub Actions auto-format + lint   |
| 🧲 Dotfiles  | Force-linked repo dotfiles through Dotbot                           |

## 📦 Quick Start

```bash
git clone --filter=blob:none https://github.com/w0rxbend/system-bootstrap.git ~/.system-bootstrap
cd ~/.system-bootstrap
./bootstrap.sh arch-sway   # fresh machine: installs git, curl, zsh and just, then runs `just host arch-sway`
```

With `just` installed:

```bash
just dry arch-sway    # preview: read-only package check, dotbot -n, setup.sh syntax only
just host arch-sway   # provision for real
```

A machine is a host under `hosts/`. Each `hosts/<host>/host.env` sets `DISTRO` and the ordered `MODULES` list:

| Host           | Distro | Modules                                                   |
| -------------- | ------ | --------------------------------------------------------- |
| `arch-niri`    | arch   | base shell dev cli containers virt desktop gnome niri-dms |
| `arch-sway`    | arch   | base shell dev cli containers virt desktop sway           |
| `fedora-gnome` | fedora | base shell dev cli containers virt desktop gnome          |
| `ubuntu-vm`    | ubuntu | base shell dev cli containers desktop gnome               |

`host.env` may also set `GIT_USER_NAME`, `GIT_USER_EMAIL` and `OBS=1`.

## 🕹 Commands

| Command               | Purpose                                                                      |
| --------------------- | ---------------------------------------------------------------------------- |
| `just`                | Show all available recipes                                                   |
| `just host <h>`       | Provision host `<h>`: packages, dotfiles and setup of every module, in order |
| `just dry <h>`        | Dry run: package lists resolved read-only, `dotbot -n`, `bash -n` on setup   |
| `just module <h> <m>` | Run one module of host `<h>` for real                                        |
| `just format`         | Format supported repo files                                                  |
| `just lint`           | Syntax-check and lint supported repo files                                   |
| `just check`          | Run the repo quality gate                                                    |

A real run refuses a host whose `DISTRO` is not this machine's distro.

After provisioning, `~/system-update.sh` (zsh alias `update`) updates system packages, Flatpaks and the user
toolchains on every distro. The base module links it.

## 🗂 Layout

```text
.system-bootstrap/
├── bootstrap.sh               # First run: installs just, then `just host <host>`
├── hosts/<host>/host.env      # DISTRO and MODULES of one machine
├── modules/<module>/          # every file optional:
│   ├── packages.<distro>      #   package names, one or more per line
│   ├── dotbot.yaml            #   links, applied with the repo root as base dir
│   ├── setup.sh               #   idempotent, non-interactive bash
│   └── files/                 #   config sources owned by the module
├── .files/                    # Niri/DMS sources and compat links to moved sources
├── scripts/                   # host.sh runner, shared installers, lib/, format and lint
├── assets/                    # Wallpapers and icons
├── docs/                      # Notes for fonts, keyrings, and desktop quirks
└── Justfile                   # Command runner
```

For each module in `MODULES`, `scripts/host.sh` installs `packages.<distro>`, applies `dotbot.yaml`, then runs
`setup.sh`, and finally does the same for `hosts/<host>/`.

## 🧬 Dotfiles

Dotbot is not vendored in this repo. `scripts/host.sh` uses an installed
[dotbot-go](https://github.com/worxbend/dotbot-go) binary that reports the pinned version (`scripts/lib/dotbot.sh`), or
downloads that release into a temporary directory, checks it against the pinned SHA-256, and discards it afterwards.

The repo is intentionally opinionated: link defaults use `force: true`, so repo-managed files replace local targets.
Run this only when you want this repository to own those config paths. `~/.zshrc` is not linked: the shell module
writes a local stub that sources `~/.config/zsh/zshrc`, so installers that append to `~/.zshrc` do not edit the repo.

```bash
# Use a specific dotbot binary, or pass extra flags to it
DOTBOT=~/.apps/dotbot/bin/dotbot just host arch-sway
DOTBOT_ARGS=-v just module arch-sway sway
```

Managed highlights:

- 🐚 Zsh + Oh My Zsh plugins
- 🧠 Neovim Lua setup
- 🧱 tmux, Zellij, Starship
- 🖥 Alacritty, Kitty, WezTerm, Ghostty
- 📁 Yazi, Lazygit, LSD, Btop
- 🪟 GNOME, Niri + DankMaterialShell, Sway, Waybar, Fuzzel

### DankMaterialShell

Portable DMS settings and the Niri config live under `.files/.config/` and are linked by the `niri-dms` module. DMS
writes its settings through these links, so the sources stay at their `.files/` paths. Runtime state, caches, generated
themes, and plugin checkout directories stay local. See [modules/niri-dms/README.md](modules/niri-dms/README.md) for
the plugin lock commands.

## 🔤 Nerd Fonts

Nerd Fonts are installed through
[worxbend/nerd-fonts-installer](https://github.com/worxbend/nerd-fonts-installer).

The config is stored in the repo at:

```text
modules/desktop/files/nerd-fonts-installer/config.yaml
```

Dotbot links it to:

```text
~/.config/nerd-fonts-installer/config.yaml
```

The desktop module installs the configured font set:

```bash
just module <host> desktop
```

## 🧪 Formatting And Linting

This repo has a quality workflow for shell, YAML, JSON/JSONC, TOML, Lua, Markdown, CSS, XML, SVG, and Justfile syntax.

```bash
just format
just lint
just check
```

GitHub Actions runs the same flow:

1. Install formatter and linter binaries/packages.
2. Run `just format`.
3. Commit formatting changes with `style: autoformat`.
4. Run `just lint`.

## 🧭 Distro Notes

| Distro     | Package lists               | Notes                                                |
| ---------- | --------------------------- | ---------------------------------------------------- |
| Arch Linux | `modules/*/packages.arch`   | Arch and CachyOS. `niri-dms` has no package list yet |
| Fedora     | `modules/*/packages.fedora` | base adds RPM Fusion and the VS Code repo            |
| Ubuntu     | `modules/*/packages.ubuntu` | 24.04 names; `# unverified:` lines need a check      |

Module setup scripts install system packages, enable services, write system config, and use `sudo`.
Run `just dry <host>` and read a module before running it on a machine you care about.

## ⚠️ Operational Notes

- Docker or virtualization group changes require logout/login.
- Kernel, driver, and desktop stack changes may require a reboot.
- Dotbot force-linking replaces matching local config paths.
- Some install scripts are intentionally personal and may include preferred apps or services.

## 📚 Docs

- [Font fallback and emoji rendering](docs/fonts.md)
- [Fedora GNOME keyring notes](docs/fedora/gnome/ssh-keyring.md)
- [Fedora Sway keyring notes](docs/fedora/sway/ssh-keyring.md)

## 📄 License

GPL-3.0. See [LICENSE](LICENSE).
