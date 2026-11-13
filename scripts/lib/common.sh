# shellcheck shell=bash
# Shared helpers for the bootstrap scripts. Source it; do not run it.
# Callers set `set -euo pipefail` themselves.

have() {
    command -v "$1" >/dev/null 2>&1
}

info() {
    printf '\n==> %s\n' "$*"
}

skip() {
    printf 'skip: %s\n' "$*"
}

die() {
    printf 'error: %s\n' "$*" >&2
    exit 1
}

# Print the supported distro family of this machine (arch, fedora or ubuntu),
# or nothing when /etc/os-release names none of them.
os_id() {
    local id id_like candidate

    [ -r /etc/os-release ] || return 0

    # shellcheck disable=SC1091
    id="$(. /etc/os-release && echo "${ID:-}")"
    # shellcheck disable=SC1091
    id_like="$(. /etc/os-release && echo "${ID_LIKE:-}")"

    # Intentionally unquoted: ID_LIKE is a space-separated list.
    # shellcheck disable=SC2086
    for candidate in ${id} ${id_like}; do
        case "${candidate}" in
            arch | fedora | ubuntu)
                printf '%s\n' "${candidate}"
                return 0
                ;;
        esac
    done
}

# Print the package names in a list file: one or more names per line, `#` starts a comment.
pkg_names() {
    awk '{ sub(/#.*/, ""); for (i = 1; i <= NF; i++) print $i }' "$1"
}

# Install the packages in modules/<m>/packages.<distro>. The file suffix names
# the distro; installing a foreign list is refused.
pkg_install() {
    local list="$1" distro="${1##*.}" this_os
    local -a names

    [ -r "${list}" ] || die "package list not readable: ${list}"
    this_os="$(os_id)"
    [ "${distro}" = "${this_os}" ] || die "${list} is for ${distro}, this machine is '${this_os}'"

    mapfile -t names < <(pkg_names "${list}")
    if [ "${#names[@]}" -eq 0 ]; then
        skip "no packages in ${list}"
        return 0
    fi

    pkg_install_names "${distro}" "${names[@]}"
}

# Install packages by name with the package manager of <distro>.
pkg_install_names() {
    local distro="$1"
    shift

    case "${distro}" in
        # -Syu, not -S: a stale sync database 404s on new packages, and a
        # bare -Sy would be a partial upgrade.
        arch) sudo pacman -Syu --needed --noconfirm "$@" ;;
        fedora) sudo dnf -y install "$@" ;;
        ubuntu)
            sudo apt-get update
            sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "$@"
            ;;
        *) die "pkg_install does not support ${distro} yet" ;;
    esac
}

# Check, read-only and without sudo, that every package in a list resolves in
# the configured repos. Skips with a message when the distro's tool is absent.
pkg_check() {
    local list="$1" distro="${1##*.}" name missing=0
    local -a names

    [ -r "${list}" ] || die "package list not readable: ${list}"
    mapfile -t names < <(pkg_names "${list}")
    [ "${#names[@]}" -gt 0 ] || return 0

    case "${distro}" in
        arch)
            if ! have pacman; then
                skip "pacman not found; cannot check ${list}"
                return 0
            fi
            pacman -Sp "${names[@]}" >/dev/null
            ;;
        fedora)
            if ! have dnf; then
                skip "dnf not found; cannot check ${list}"
                return 0
            fi
            for name in "${names[@]}"; do
                if [ -z "$(dnf -q repoquery --whatprovides "${name}" 2>/dev/null)" ]; then
                    printf 'not found: %s (%s)\n' "${name}" "${list}" >&2
                    missing=1
                fi
            done
            return "${missing}"
            ;;
        ubuntu)
            if ! have apt-get; then
                skip "apt-get not found; cannot check ${list}"
                return 0
            fi
            # A simulation needs no root; it fails on any name apt cannot find.
            apt-get -s -q install "${names[@]}" >/dev/null
            ;;
        *) die "pkg_check does not support ${distro} yet: ${list}" ;;
    esac
}

# Enable and start a system service; skipped when systemd is not running.
enable_service() {
    if [ -d /run/systemd/system ]; then
        sudo systemctl enable --now "$1"
    else
        skip "systemd is not running; $1 not enabled"
    fi
}

# Add the current user to <group>. Takes effect after the next login.
ensure_user_in_group() {
    local group="$1" user="${USER:-$(id -un)}"

    if [[ " $(id -nG "${user}") " == *" ${group} "* ]]; then
        skip "${user} is already in the ${group} group"
    else
        sudo usermod -aG "${group}" "${user}"
    fi
}
