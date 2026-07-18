<p align="center">
  <img src="assets/main.png" width="128" alt="System Bootstrap logo">
</p>

<h1 align="center">System Bootstrap</h1>

<p align="center">
  <strong>Multi-distro dotfiles, workstation bootstrap scripts, and desktop rice for a sharp Linux dev setup.</strong>
</p>

<p align="center">
  <a href="https://github.com/limpid-kzonix/system-bootstrap/actions/workflows/format-and-lint.yml">
    <img
      alt="Format and lint"
      src="https://github.com/limpid-kzonix/system-bootstrap/actions/workflows/format-and-lint.yml/badge.svg"
    >
  </a>
  <img alt="Fedora" src="https://img.shields.io/badge/Fedora-ready-51A2DA?logo=fedora&logoColor=white">
  <img alt="Arch Linux" src="https://img.shields.io/badge/Arch-ready-1793D1?logo=archlinux&logoColor=white">
  <img alt="openSUSE" src="https://img.shields.io/badge/openSUSE-ready-73BA25?logo=opensuse&logoColor=white">
  <img alt="License" src="https://img.shields.io/badge/license-MIT-green">
</p>

<p align="center">
  <img src="assets/fedora-black-4k.png" width="49%" alt="Fedora desktop wallpaper">
  <img src="assets/opensuse-black-4k.png" width="49%" alt="openSUSE desktop wallpaper">
</p>

## ✨ What This Is

`system-bootstrap` is a personal workstation automation repo for setting up a polished development environment across
Fedora, Arch Linux, and openSUSE.

It brings together package installation, binary tool installs, Dotbot-managed dotfiles, Nerd Fonts, terminal/editor
configuration, desktop environments, wallpapers, and maintenance workflows.

## 🚀 Highlights

| Area         | What You Get                                                        |
| ------------ | ------------------------------------------------------------------- |
| 🐧 Distros   | Fedora, Arch Linux, and openSUSE bootstrap scripts                  |
| 🧰 Dev tools | Zsh, tmux, Neovim, Go, Rust, Java, Node, Python, Kubernetes tools   |
| 🖥 Desktop    | GNOME, COSMIC, Sway, Waybar, Fuzzel, GDM/SDDM tweaks                |
| 🎨 Terminal  | Alacritty, Kitty, WezTerm, Ghostty, Starship, Zellij                |
| 🔤 Fonts     | Nerd Font installer config stored in the repo and linked via Dotbot |
| 🧹 Quality   | `just format`, `just lint`, and GitHub Actions auto-format + lint   |
| 🧲 Dotfiles  | Force-linked repo dotfiles through Dotbot                           |

## 📦 Quick Start

```bash
git clone --recursive https://github.com/limpid-kzonix/system-bootstrap.git ~/.system-bootstrap
cd ~/.system-bootstrap
just
```

Then run the path for your machine:

```bash
# Fedora
just fedora-step-0
just fedora-step-1
just fedora-step-2

# Arch + Hyprland
just arch-install

# openSUSE + Sway
just opensuse-install
just opensuse-sddm
```

Finish with the shared setup:

```bash
just configure-system
just install-cli-tools
just install-binaries
just install-zsh-plugins
just install-fonts
just install-flatpaks
just install-dev-tools
just apply-dotfiles
```

## 🕹 Commands

| Command                  | Purpose                                                           |
| ------------------------ | ----------------------------------------------------------------- |
| `just`                   | Show all available recipes                                        |
| `just configure-system`  | Configure Git, tmux plugin manager, and time settings             |
| `just install-cli-tools` | Install language/toolchain managers and CLI installers            |
| `just install-binaries`  | Install portable binary tools into `~/.apps`                      |
| `just install-fonts`     | Install configured Nerd Fonts with `worxbend/nerd-fonts-installer` |
| `just apply-dotfiles`    | Force-link dotfiles from `.files`                                 |
| `just format`            | Format supported repo files                                       |
| `just lint`              | Syntax-check and lint supported repo files                        |
| `just check`             | Run the repo quality gate                                         |

## 🗂 Layout

```text
.system-bootstrap/
├── .files/                    # Dotfiles managed by Dotbot
│   ├── .config/               # Shared XDG configs
│   ├── arch/                  # Arch profile (GNOME + COSMIC)
│   ├── fedora/                # Fedora profile
│   ├── nvim/                  # Neovim Lua config
│   ├── opensuse/              # openSUSE + Sway profile
│   └── install.conf.yaml      # Shared Dotbot manifest
├── .github/workflows/         # Auto-format and lint workflow
├── assets/                    # Wallpapers, icons, and visual resources
├── docs/                      # Notes for fonts, keyrings, SDDM, and desktop quirks
├── scripts/                   # Bootstrap, package, formatter, and lint scripts
├── Justfile                   # Command runner
└── README.md
```

## 🧬 Dotfiles

Dotfiles live under `.files` and are linked with Dotbot.

The repo is intentionally opinionated: link defaults use `force: true`, so repo-managed files replace local targets.
Run this only when you want this repository to own those config paths.

```bash
just apply-dotfiles
```

Managed highlights:

- 🐚 Zsh + Oh My Zsh plugins
- 🧠 Neovim Lua setup
- 🧱 tmux, Zellij, Starship
- 🖥 Alacritty, Kitty, WezTerm, Ghostty
- 📁 Yazi, Lazygit, LSD, Btop
- 🪟 GNOME, COSMIC, Sway, Waybar, Fuzzel

## 🔤 Nerd Fonts

Nerd Fonts are installed through
[worxbend/nerd-fonts-installer](https://github.com/worxbend/nerd-fonts-installer).

The config is stored in the repo at:

```text
.files/.config/nerd-fonts-installer/config.yaml
```

Dotbot links it to:

```text
~/.config/nerd-fonts-installer/config.yaml
```

Install the configured font set:

```bash
just install-fonts
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

| Distro     | Profile                                   | Desktop Focus              |
| ---------- | ----------------------------------------- | -------------------------- |
| Fedora     | `scripts/fedora/*`, `.files/fedora/*`     | GNOME-oriented workstation |
| Arch Linux | `scripts/arch/*`, `.files/arch/*`         | GNOME + COSMIC             |
| openSUSE   | `scripts/opensuse/*`, `.files/opensuse/*` | Sway + SDDM Wayland        |

Some scripts install system packages, enable services, write system config, or require `sudo`.
Read a script before running it on a machine you care about.

## ⚠️ Operational Notes

- Docker or virtualization group changes require logout/login.
- Kernel, driver, and desktop stack changes may require a reboot.
- Dotbot force-linking replaces matching local config paths.
- Some install scripts are intentionally personal and may include preferred apps or services.

## 📚 Docs

- [Font fallback and emoji rendering](docs/fonts.md)
- [Fedora GNOME keyring notes](docs/fedora/gnome/ssh-keyring.md)
- [Fedora Sway keyring notes](docs/fedora/sway/ssh-keyring.md)
- [openSUSE Sway keyring notes](docs/suse/sway/ssh-keyring.md)
- [openSUSE SDDM Wayland notes](docs/suse/sway/sddm-wayland.md)

## 📄 License

MIT. See [LICENSE](LICENSE).
