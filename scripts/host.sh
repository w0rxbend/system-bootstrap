#!/usr/bin/env bash
set -euo pipefail

# Provision one machine from hosts/<host>/host.env.
#
# Usage: scripts/host.sh <host> [--dry] [--only <module>]
#
# For each module in MODULES, in order, then hosts/<host>/ as a last module:
#   1. packages.<DISTRO>  installed          (--dry: resolved read-only)
#   2. dotbot.yaml        applied, base dir is the repo root  (--dry: dotbot -n)
#   3. setup.sh           run with HOST, DISTRO, REPO_ROOT    (--dry: syntax check only)
# Every file is optional. --only runs one module of the host and skips hosts/<host>/.
# A real run refuses a host whose DISTRO is not this machine's distro.
#
# Environment overrides:
#   DOTBOT       dotbot binary to use as is (default: pinned dotbot-go, see scripts/lib/dotbot.sh)
#   DOTBOT_ARGS  extra flags passed through to dotbot

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# shellcheck source=scripts/lib/dotbot.sh
. "${REPO_ROOT}/scripts/lib/dotbot.sh"

usage() {
    printf 'usage: %s <host> [--dry] [--only <module>]\n' "$0" >&2
    exit 2
}

host=""
dry=0
only=""
while [ "$#" -gt 0 ]; do
    case "$1" in
        --dry) dry=1 ;;
        --only)
            [ "$#" -ge 2 ] || usage
            only="$2"
            shift
            ;;
        -*) usage ;;
        *)
            [ -z "${host}" ] || usage
            host="$1"
            ;;
    esac
    shift
done
[ -n "${host}" ] || usage

HOST_DIR="${REPO_ROOT}/hosts/${host}"
[ -f "${HOST_DIR}/host.env" ] || die "unknown host '${host}': ${HOST_DIR}/host.env not found"

# host.env is repo content: plain VAR=value lines. Export them for setup.sh.
set -a
# shellcheck source=/dev/null
. "${HOST_DIR}/host.env"
set +a
[ -n "${DISTRO:-}" ] || die "${HOST_DIR}/host.env does not set DISTRO"
[ -n "${MODULES:-}" ] || die "${HOST_DIR}/host.env does not set MODULES"
export HOST="${host}" REPO_ROOT

read -r -a modules <<<"${MODULES}"
if [ -n "${only}" ]; then
    [[ " ${modules[*]} " == *" ${only} "* ]] || die "module '${only}' is not in MODULES of ${host}: ${MODULES}"
    modules=("${only}")
fi

units=()
for module in "${modules[@]}"; do
    [ -d "${REPO_ROOT}/modules/${module}" ] || die "${host} lists module '${module}', but modules/${module} does not exist"
    units+=("${REPO_ROOT}/modules/${module}")
done
[ -n "${only}" ] || units+=("${HOST_DIR}")

if [ "${dry}" -eq 0 ]; then
    this_os="$(os_id)"
    [ "${DISTRO}" = "${this_os}" ] || die "${host} is a ${DISTRO} host, this machine is '${this_os}'; use --dry"
fi

read -r -a dotbot_args <<<"${DOTBOT_ARGS:-}"
[ "${dry}" -eq 0 ] || dotbot_args+=(-n)

WORKDIR="$(mktemp -d)"
trap 'rm -rf -- "${WORKDIR}"' EXIT
dotbot_bin=""
dry_failures=0

# Real run: stop at the first failure. Dry run: report it and go on.
run_step() {
    if [ "${dry}" -eq 0 ]; then
        "$@"
    elif ! "$@"; then
        printf 'dry: failed: %s\n' "$*" >&2
        dry_failures=1
    fi
}

install_packages() {
    local list="$1/packages.${DISTRO}"

    [ -f "${list}" ] || return 0
    if [ "${dry}" -eq 1 ]; then
        pkg_check "${list}"
    else
        pkg_install "${list}"
    fi
}

link_dotfiles() {
    local config="$1/dotbot.yaml"

    [ -f "${config}" ] || return 0
    if [ -z "${dotbot_bin}" ]; then
        dotbot_bin="$(resolve_dotbot "${WORKDIR}")" || return 1
    fi
    "${dotbot_bin}" -d "${REPO_ROOT}" -c "${config}" "${dotbot_args[@]}"
}

run_setup() {
    local script="$1/setup.sh"

    [ -f "${script}" ] || return 0
    if [ "${dry}" -eq 1 ]; then
        bash -n "${script}"
        printf 'would run: %s\n' "${script#"${REPO_ROOT}/"}"
    else
        bash "${script}"
    fi
}

mode="real run"
[ "${dry}" -eq 0 ] || mode="dry run"
info "${host} (${DISTRO}, ${mode}): ${modules[*]}"

for unit in "${units[@]}"; do
    info "${unit#"${REPO_ROOT}/"}"
    run_step install_packages "${unit}"
    run_step link_dotfiles "${unit}"
    run_step run_setup "${unit}"
done

exit "${dry_failures}"
