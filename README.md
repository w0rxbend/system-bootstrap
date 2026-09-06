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
  <img alt="License" src="https://img.shields.io/badge/license-MIT-green">
</p>

<p align="center">
  <img src="assets/fedora-black-4k.png" width="49%" alt="Fedora desktop wallpaper">
</p>

## ✨ What This Is

`system-bootstrap` is a personal workstation automation repo for setting up a polished development environment across
Fedora and Arch Linux.

It brings together package installation, binary tool installs, Dotbot-managed dotfiles, Nerd Fonts, terminal/editor
configuration, desktop environments, wallpapers, and maintenance workflows.

## 🚀 Highlights

| Area         | What You Get                                                        |
| ------------ | ------------------------------------------------------------------- |
| 🐧 Distros   | Fedora and Arch Linux bootstrap scripts                             |
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

Then run the full bootstrap for your machine — distro packages followed by the shared setup:

```bash
# Fedora
just fedora-full-install

# Arch + Hyprland
just arch-full-install
```

Or drive the steps yourself if you want to stop and inspect between them:

```bash
# Fedora
just fedora-step-0
just fedora-step-1
just fedora-step-2

# Arch + Hyprland
just arch-install

# Shared setup (what `*-full-install` runs after the packages)
just shared-setup
```

## 🕹 Commands

| Command                    | Purpose                                                            |
| -------------------------- | ------------------------------------------------------------------ |
| `just`                     | Show all available recipes                                         |
| `just fedora-full-install` | Fedora packages plus the full shared setup                         |
| `just arch-full-install`   | Arch packages plus the full shared setup                           |
| `just shared-setup`        | Run every shared step: config, tools, fonts, flatpaks, dotfiles    |
| `just configure-system`    | Configure Git, tmux plugin manager, and time settings              |
| `just install-cli-tools`   | Install language/toolchain managers and CLI installers             |
| `just install-binaries`    | Install portable binary tools into `~/.apps`                       |
| `just install-fonts`       | Install configured Nerd Fonts with `worxbend/nerd-fonts-installer` |
| `just apply-dotfiles`      | Force-link dotfiles from `.files`                                  |
| `just format`              | Format supported repo files                                        |
| `just lint`                | Syntax-check and lint supported repo files                         |
| `just check`               | Run the repo quality gate                                          |

## 🗂 Layout

```text
.system-bootstrap/
├── .files/                    # Dotfiles managed by Dotbot
│   ├── .config/               # Shared XDG configs
│   ├── arch/                  # Arch profile (GNOME + COSMIC)
│   ├── fedora/                # Fedora profile
│   ├── nvim/                  # Neovim Lua config
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

Dotbot is not vendored in this repo. `scripts/apply-dotfiles.sh` downloads the
[dotbot-go](https://github.com/worxbend/dotbot-go) release binary into a temporary directory on demand, verifies its
published SHA-256, applies the configs, and discards it. It runs two passes: the shared `.files/install.conf.yaml`,
then the distro overlay (`.files/arch/`, `.files/fedora/`) matching `ID`/`ID_LIKE` in `/etc/os-release`.

The repo is intentionally opinionated: link defaults use `force: true`, so repo-managed files replace local targets.
Run this only when you want this repository to own those config paths.

```bash
just apply-dotfiles

# Preview without touching anything
DOTBOT_ARGS=-n just apply-dotfiles

# Force a specific overlay, or pin the dotbot release
DOTFILES_PROFILE=arch just apply-dotfiles
DOTBOT_VERSION=v0.4.2 just apply-dotfiles
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

## 📄 License

MIT. See [LICENSE](LICENSE).
