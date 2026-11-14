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
  <img alt="Ubuntu" src="https://img.shields.io/badge/Ubuntu-24.04-E95420?logo=ubuntu&logoColor=white">
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
| 💻 Desktop   | GNOME, Niri + DankMaterialShell, Sway, Waybar, Fuzzel               |
| 🎨 Terminal  | Alacritty, Kitty, WezTerm, Ghostty, Starship, Zellij                |
| 🔤 Fonts     | Nerd Font installer config stored in the repo and linked via Dotbot |
| 🧹 Quality   | `just format`, `just lint`, and GitHub Actions auto-format + lint   |
| 🧲 Dotfiles  | Force-linked repo dotfiles through Dotbot                           |

## 📦 Quick Start

```bash
git clone --filter=blob:none https://github.com/w0rxbend/system-bootstrap.git ~/.system-bootstrap
cd ~/.system-bootstrap
./bootstrap.sh arch-sway   # fresh machine: installs git, curl, zsh and just, then runs `just --yes host arch-sway`
```

With `just` installed:

```bash
just hosts            # list hosts and their modules
just dry arch-sway    # preview: read-only package check, dotbot -n, setup.sh syntax only
just host arch-sway   # provision for real (asks for confirmation; `just --yes host ...` skips it)
```

A machine is a host under `hosts/`. Each `hosts/<host>/host.env` sets `DISTRO` and the ordered `MODULES` list:

| Host           | Distro | Modules                                                   |
| -------------- | ------ | --------------------------------------------------------- |
| `arch-niri`    | arch   | base shell dev cli containers virt desktop gnome niri-dms |
| `arch-sway`    | arch   | base shell dev cli containers virt desktop sway           |
| `fedora-gnome` | fedora | base shell dev cli containers virt desktop gnome          |
| `ubuntu-vm`    | ubuntu | base shell dev cli containers desktop gnome               |

`host.env` may also set `GIT_USER_NAME`, `GIT_USER_EMAIL` and `OBS=1`. A host dir may also hold a `dotbot.yaml` and
`files/` for links that belong to that machine only, such as the `arch-sway` Kanshi monitor profile.

## 🕹 Commands

| Command               | Purpose                                                                      |
| --------------------- | ---------------------------------------------------------------------------- |
| `just`                | Show all available recipes                                                   |
| `just hosts`          | List every host and its `MODULES`                                            |
| `just host <h>`       | Provision host `<h>`: packages, dotfiles and setup of every module, in order |
| `just dry <h>`        | Dry run: package lists resolved read-only, `dotbot -n`, `bash -n` on setup   |
| `just module <h> <m>` | Run one module of host `<h>` for real                                        |
| `just format`         | Format supported repo files                                                  |
| `just lint`           | Syntax-check and lint supported repo files                                   |
| `just check`          | Run the repo quality gate                                                    |

`just host` and `just module` ask for confirmation before they change anything. A real run refuses a host whose
`DISTRO` is not this machine's distro, and refuses to run as root.

After provisioning, `~/system-update.sh` (zsh alias `update`) updates system packages, Flatpaks and the user
toolchains on every distro. The base module links it.

## 🗂 Layout

```text
.system-bootstrap/
├── bootstrap.sh               # First run: installs just, then `just host <host>`
├── hosts/<host>/host.env      # DISTRO and MODULES of one machine
├── hosts/<host>/dotbot.yaml   # optional host-only links (sources in hosts/<host>/files/)
├── modules/<module>/          # every file optional:
│   ├── packages.<distro>      #   package names, one or more per line
│   ├── dotbot.yaml            #   links, applied with the repo root as base dir
│   ├── setup.sh               #   idempotent, non-interactive bash
│   └── files/                 #   config sources owned by the module
├── scripts/                   # host.sh runner, shared installers, lib/, format and lint
├── assets/                    # Wallpapers and icons
├── docs/                      # Notes for fonts, keyrings, and desktop quirks
├── others/                    # Backups kept for manual restore; nothing links or installs them
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
Per-machine shell settings live in two untracked files the shared config sources when present: `~/.custom.pre.zsh`
(before Oh My Zsh, for `fpath` and plugin settings) and `~/.custom.zsh` (after it, for `PATH` entries such as AI
CLIs).

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

Portable DMS settings and the Niri config live under `modules/niri-dms/files/` and are linked by the `niri-dms` module.
DMS writes its settings through these links, so changes land in the repo. Runtime state, caches, generated
themes, and plugin checkout directories stay local. See [modules/niri-dms/README.md](modules/niri-dms/README.md) for
the plugin lock commands.

## 🧰 Binary Tools

The cli module runs `scripts/binary-dist.sh`, which installs
[binstaller](https://github.com/worxbend/binstaller) at the release pinned in `BINSTALLER_VERSION` and applies
`modules/cli/files/binstaller/config.yaml`. Every tool there is pinned in `spec.versions` with a checksum, and
Renovate bumps the pins. Each tool lands in `~/.apps/<tool>/bin`, which `.zshrc` puts at the front of `PATH`, so the
pinned copy wins over an older system one. binstaller owns helm, kustomize, yq (mikefarah) and
nerd-fonts-installer, among others; no curl installer is used for them any more. Starship is the exception:
it uses its official script (`https://starship.rs/install.sh`) and lives in `/usr/local/bin`.

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

The cli module installs the pinned installer to `~/.apps/nerd-fonts-installer/bin/` through binstaller and links
`~/.local/bin/nerd-fonts-installer` to it. The desktop
module runs it (`scripts/nerd-fonts.p0.sh`) to install the configured font set, so run the cli module first:

```bash
just module <host> desktop
```

## 🧪 Formatting And Linting

This repo has a quality workflow for shell, YAML, JSON/JSONC, TOML, Lua, Markdown, CSS, and Justfile syntax. `just lint`
also checks the dotbot manifests, each host's module set (a module with package lists needs one for the host's
distro), script references, tracked symlinks, that both dotbot-go pins match, and the Sway config (`sway -C`, skipped
when sway is not installed). Arch hosts get the gate tools from `modules/dev/packages.arch`.

```bash
just format
just lint
just check
```

GitHub Actions runs the same flow:

1. Install formatter and linter binaries/packages.
2. Run `just format`.
3. On `main`, commit formatting changes with `style: autoformat` and push them. Run `git pull --rebase` after you push.
4. Run `just lint`.

A second job runs `just dry ubuntu-vm` in an `ubuntu:24.04` container, so the Ubuntu package lists are resolved with
`apt-get -s` and the host's manifests go through the pinned dotbot-go with `-n`.

## 🧭 Distro Notes

| Distro     | Package lists               | Notes                                               |
| ---------- | --------------------------- | --------------------------------------------------- |
| Arch Linux | `modules/*/packages.arch`   | Arch and CachyOS. `niri-dms` uses the DMS installer |
| Fedora     | `modules/*/packages.fedora` | base adds RPM Fusion and the VS Code repo           |
| Ubuntu     | `modules/*/packages.ubuntu` | 24.04 names; `# unverified:` lines need a check     |

Module setup scripts install system packages, enable services, write system config, and use `sudo`.
Run `just dry <host>` and read a module before running it on a machine you care about.

## ⚠️ Operational Notes

- Docker or virtualization group changes require logout/login.
- Kernel, driver, and desktop stack changes may require a reboot.
- Dotbot force-linking replaces matching local config paths.
- Some install scripts are intentionally personal and may include preferred apps or services.

## 🔁 After Pulling On An Existing Machine

binstaller now owns tools that older runs installed elsewhere. Those old copies are not removed for you:

- Delete `/usr/local/bin/helm` (`sudo rm`).
- On Arch, remove the `yq` package (`sudo pacman -R yq`); mikefarah yq comes from binstaller now.
- binstaller does not upgrade itself. Delete `~/.local/bin/binstaller` so the next run installs the pinned version.

Then re-run the host (`just host <h>`) or `~/system-update.sh`, and open a new shell.

## 📚 Docs

- [Development guide](DEVELOPMENT.md): add hosts, modules, dotfiles, packages and binaries
- [Arch Sway host](docs/arch/sway/README.md)
- [Fedora GNOME keyring notes](docs/fedora/gnome/ssh-keyring.md)

Reference only, no host uses these setups:

- [Fedora Sway keyring notes](docs/fedora/sway/ssh-keyring.md)
- [Arch Hyprland keyring notes](docs/arch/hypr/ssh-keyring.md)

## 📄 License

GPL-3.0. See [LICENSE](LICENSE).
