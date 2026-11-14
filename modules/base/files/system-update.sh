#!/usr/bin/env bash
set -euo pipefail

# User-facing updater for every host, linked to ~/system-update.sh by the
# base module. System packages: Shelly on CachyOS (repos, AUR, Flatpak,
# AppImage), else pacman, dnf or apt, then Flatpak.
# User toolchains match scripts/cli-tools.sh, cargo-packages.sh, binary-dist.sh,
# sdkman-packages.sh, oh-my-zsh-plugins.sh, and oh-tmux-plugin-manager.sh.

failures=0

add_path() {
    local dir="$1"
    case ":${PATH}:" in
        *":${dir}:"*) ;;
        *) PATH="${dir}:${PATH}" ;;
    esac
}

run_step() {
    local label="$1"
    shift
    info "${label}"
    if "$@"; then
        return 0
    fi
    printf 'failed: %s\n' "${label}" >&2
    failures=1
    return 0
}

# ~/system-update.sh is a symlink into the repo, so resolve the real path
# before asking git for the root.
script_dir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
repo_root="$(git -C "${script_dir}" rev-parse --show-toplevel)"

# shellcheck source=scripts/lib/common.sh
. "${repo_root}/scripts/lib/common.sh"

add_path "${HOME}/.local/bin"
add_path "${HOME}/.cargo/bin"
add_path "${HOME}/.juliaup/bin"
add_path "${HOME}/.go/bin"
add_path "${HOME}/.local/share/pnpm"
add_path "${HOME}/.local/share/pnpm/bin"
add_path "${HOME}/.miniforge3/bin"
add_path "${HOME}/.pyenv/bin"
export PATH

if [[ -f "${HOME}/.cargo/env" ]]; then
    # shellcheck source=/dev/null
    source "${HOME}/.cargo/env"
fi

printf 'System info: %s\n' "$(uname -a)"
printf 'shell: %s\n' "${SHELL:-unknown}"

update_system_packages() {
    case "$(os_id)" in
        arch)
            if have shelly; then
                # CachyOS default: one transaction for repos, AUR, Flatpak, AppImage.
                shelly upgrade all --no-confirm
                return
            fi
            sudo pacman -Syu --noconfirm || return
            ;;
        fedora)
            sudo dnf upgrade -y || return
            sudo dnf distro-sync -y || return
            ;;
        ubuntu)
            sudo apt-get update || return
            sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y || return
            ;;
        *)
            skip "unsupported distro; system packages not updated"
            return 0
            ;;
    esac
    if have flatpak; then
        flatpak update -y
    fi
}

installed_cargo_binstall_crates() {
    cargo binstall --list 2>/dev/null | awk '
        NR <= 2 { next }
        /^-+/ { next }
        /^Total:/ { next }
        NF >= 1 { print $1 }
    '
}

update_cargo_binstall_crates() {
    local crates=()

    if ! have cargo-binstall; then
        skip "cargo-binstall not installed"
        return 0
    fi

    mapfile -t crates < <(installed_cargo_binstall_crates)
    if [[ ${#crates[@]} -eq 0 ]]; then
        # Nothing recorded yet: fall back to the shared list in modules/cli/crates.
        mapfile -t crates < <(pkg_names "${repo_root}/modules/cli/crates")
        crates=(cargo-binstall "${crates[@]}")
    fi

    cargo binstall --force --continue-on-failure "${crates[@]}"
}

update_nvm_and_node() {
    local nvm_dir="${NVM_DIR:-${HOME}/.nvm}"
    local latest_tag

    if [[ ! -s "${nvm_dir}/nvm.sh" ]]; then
        skip "nvm not installed"
        return 0
    fi

    if [[ -d "${nvm_dir}/.git" ]]; then
        git -C "${nvm_dir}" fetch --tags origin || return
        latest_tag="$(git -C "${nvm_dir}" describe --abbrev=0 --tags --match 'v[0-9]*' "$(git -C "${nvm_dir}" rev-list --tags --max-count=1)")" || return
        git -C "${nvm_dir}" checkout "${latest_tag}" || return
    fi

    # nvm.sh is not safe under `set -u`; run it in a child shell so an
    # unbound variable fails this step instead of aborting the updater.
    # shellcheck disable=SC2016
    bash -c '
        source "$1/nvm.sh"
        current_node="$(nvm current 2>/dev/null || true)"
        if [[ -n "${current_node}" && "${current_node}" != "none" ]]; then
            nvm install node --reinstall-packages-from=current --latest-npm
        else
            nvm install node --latest-npm
        fi
    ' _ "${nvm_dir}"
}

update_sdkman() {
    local init="${HOME}/.sdkman/bin/sdkman-init.sh"
    if [[ ! -s "${init}" ]]; then
        skip "SDKMAN not installed"
        return 0
    fi
    # sdkman-init.sh reads unset variables; run it in a child shell so
    # `set -u` here cannot abort the whole updater.
    # shellcheck disable=SC2016
    bash -c '
        source "$1"
        sdkman_auto_answer=true
        sdk selfupdate
        sdk update
        sdk upgrade
    ' _ "${init}"
}

update_pyenv() {
    local pyenv_root="${PYENV_ROOT:-${HOME}/.pyenv}"
    if ! have pyenv && [[ ! -x "${pyenv_root}/bin/pyenv" ]]; then
        skip "pyenv not installed"
        return 0
    fi
    add_path "${pyenv_root}/bin"
    if pyenv commands 2>/dev/null | grep -qx update; then
        pyenv update
    elif [[ -d "${pyenv_root}/.git" ]]; then
        git -C "${pyenv_root}" pull --ff-only
    else
        skip "pyenv has no update plugin and is not a git checkout"
    fi
}

update_oh_my_zsh() {
    local zsh_home="${ZSH:-${HOME}/.oh-my-zsh}"
    local custom="${ZSH_CUSTOM:-${zsh_home}/custom}"
    local plugin

    if [[ ! -x "${zsh_home}/tools/upgrade.sh" ]]; then
        skip "Oh My Zsh not installed"
        return 0
    fi

    DISABLE_UPDATE_PROMPT=true ZSH="${zsh_home}" "${zsh_home}/tools/upgrade.sh"

    for plugin in zsh-syntax-highlighting zsh-autosuggestions zsh-history-substring-search; do
        if [[ -d "${custom}/plugins/${plugin}/.git" ]]; then
            if ! git -C "${custom}/plugins/${plugin}" pull --ff-only; then
                skip "could not fast-forward ${plugin}"
            fi
        fi
    done
}

update_tmux_plugins() {
    local tpm_dir="${HOME}/.tmux/plugins/tpm"
    if [[ ! -d "${tpm_dir}/.git" ]]; then
        skip "TPM not installed"
        return 0
    fi
    if ! git -C "${tpm_dir}" pull --ff-only; then
        skip "could not fast-forward TPM; keeping existing checkout"
    fi
    if have tmux && [[ -x "${tpm_dir}/bin/update_plugins" ]]; then
        "${tpm_dir}/bin/update_plugins" all
    fi
}

update_starship() {
    curl -sS https://starship.rs/install.sh | sh -s -- -y
}

update_dotenvx() {
    curl -sfS "https://dotenvx.sh?directory=${HOME}/.local/bin" | sh
}

run_step "System packages" update_system_packages

if have rustup; then
    run_step "rustup" rustup update
else
    skip "rustup not installed"
fi

run_step "cargo-binstall crates" update_cargo_binstall_crates

if have juliaup; then
    run_step "juliaup self" juliaup self update
    run_step "julia channels" juliaup update
else
    skip "juliaup not installed"
fi

if have poetry; then
    run_step "poetry" poetry self update --no-interaction
else
    skip "poetry not installed"
fi

run_step "pyenv" update_pyenv

if have uv; then
    run_step "uv" uv self update
else
    skip "uv not installed"
fi

if have mamba; then
    run_step "Miniforge/mamba" mamba update --all -y -n base
else
    skip "mamba not installed"
fi

run_step "SDKMAN" update_sdkman
run_step "nvm / Node" update_nvm_and_node

if have pnpm; then
    run_step "pnpm" pnpm self-update --yes
else
    skip "pnpm not installed"
fi

if have starship; then
    run_step "starship" update_starship
else
    skip "starship not installed"
fi

if have dotenvx; then
    run_step "dotenvx" update_dotenvx
else
    skip "dotenvx not installed"
fi

# binary-dist.sh owns the binstaller pin, the config lookup and the apply.
# helm, kustomize, yq and nerd-fonts-installer are pinned in that profile.
run_step "binstaller binaries" "${repo_root}/scripts/binary-dist.sh"
# nerd-fonts.p0.sh runs the pinned installer from ~/.apps and finds the config.
run_step "Nerd Fonts" "${repo_root}/scripts/nerd-fonts.p0.sh"
run_step "Oh My Zsh" update_oh_my_zsh
run_step "tmux plugins" update_tmux_plugins

if have tldr; then
    run_step "tldr cache" tldr --update
else
    skip "tldr not installed"
fi

# Go is pinned in scripts/install_golang.sh; bump it there.

printf '\n'
if [[ "${failures}" -ne 0 ]]; then
    printf 'Completed with failures.\n' >&2
    exit 1
fi
printf 'Update finished.\n'
