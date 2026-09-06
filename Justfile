# Justfile for System Bootstrap

# List available commands
default:
    @just --list

# --- Common Setup ---

# Format supported repository files
format:
    ./scripts/format.sh

# Lint and syntax-check supported repository files
lint:
    ./scripts/lint.sh

# Run all repository quality checks
check: lint

# Run basic system configurations (git, time)
configure-system:
    ./scripts/configurations.sh

# Install common CLI tools (zsh, fzf, etc.)
install-cli-tools:
    ./scripts/cli-tools.sh

# Install Binary Distributions (Dotbot, Yazi, Neovim, etc.)
install-binaries:
    ./scripts/binary-dist.sh

# Install Oh-My-Zsh Plugins
install-zsh-plugins:
    ./scripts/oh-my-zsh-plugins.sh

# Install TPM (Tmux Plugin Manager) and tmux plugins
install-tmux-plugins:
    ./scripts/oh-tmux-plugin-manager.sh

# Install Flatpaks
install-flatpaks:
    ./scripts/flatpak.sh

# Install OBS Studio and Flatpak plugins
install-obs:
    ./scripts/flatpak-obs-plugins.sh

# Install Nerd Fonts
install-fonts:
    ./scripts/nerd-fonts.p0.sh

# Install Development Tools (Go, Cargo, SDKMan)
install-dev-tools:
    ./scripts/install_golang.sh
    ./scripts/cargo-packages.sh
    ./scripts/sdkman-packages.sh

# Apply Dotfiles (using Dotbot)
apply-dotfiles:
    ./scripts/apply-dotfiles.sh

# Run the shared setup that follows any distro package step
shared-setup: configure-system install-cli-tools install-binaries install-zsh-plugins install-fonts install-flatpaks install-dev-tools apply-dotfiles install-tmux-plugins

# --- Distro Specific ---

# Install Fedora packages (Step 0)
fedora-step-0:
    ./scripts/fedora/00-system-update.sh

# Install Fedora packages (Step 1)
fedora-step-1:
    ./scripts/fedora/01-packages.sh

# Install Fedora packages (Step 2)
fedora-step-2:
    ./scripts/fedora/02-extras.sh

# Full Fedora bootstrap (packages + shared setup)
fedora-full-install: fedora-step-0 fedora-step-1 fedora-step-2 shared-setup

# Install Arch packages
arch-install:
    ./scripts/arch/00-system-update.sh
    ./scripts/arch/02-base-packages.sh

# Full Arch bootstrap (packages + shared setup)
arch-full-install: arch-install shared-setup
