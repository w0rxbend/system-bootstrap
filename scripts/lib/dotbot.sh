# shellcheck shell=bash
# Resolve a dotbot-go binary pinned to one release. Source it; do not run it.
# https://github.com/worxbend/dotbot-go
#
# Environment:
#   DOTBOT  path to a dotbot binary to use as is (no version check)

# shellcheck source=scripts/lib/common.sh
. "$(dirname "${BASH_SOURCE[0]}")/common.sh"

DOTBOT_PINNED_VERSION="0.4.2"

dotbot_sha256() {
    local file="$1" sum

    if have sha256sum; then
        sum="$(sha256sum "${file}")"
    elif have shasum; then
        sum="$(shasum -a 256 "${file}")"
    else
        die "sha256sum or shasum is required to verify dotbot-go"
    fi
    printf '%s\n' "${sum%% *}"
}

# Download the pinned release into <workdir>, verify it, and print its path.
dotbot_download() {
    local workdir="$1" arch expected url archive actual

    case "$(uname -m)" in
        x86_64 | amd64)
            arch="amd64"
            expected="a7229b8d098454ffeb2858ddcf1b63602dfc7be06e08b57c39d839c08f9dbd01"
            ;;
        aarch64 | arm64)
            arch="arm64"
            expected="21e94e915de43f2cbe086973437ec6a5f81e46ddbc5280707165c0ebb6090b45"
            ;;
        *) die "no pinned dotbot-go build for $(uname -m)" ;;
    esac

    url="https://github.com/worxbend/dotbot-go/releases/download/v${DOTBOT_PINNED_VERSION}/dotbot-linux-${arch}.tar.gz"
    archive="${workdir}/dotbot.tar.gz"
    printf 'downloading dotbot-go %s from %s\n' "${DOTBOT_PINNED_VERSION}" "${url}" >&2
    curl --proto '=https' --tlsv1.2 -fsSL "${url}" -o "${archive}"
    actual="$(dotbot_sha256 "${archive}")"
    [ "${actual}" = "${expected}" ] || die "dotbot-go checksum mismatch for ${url}: ${actual} != ${expected}"
    printf 'checksum ok: %s\n' "${actual}" >&2
    tar -xzf "${archive}" -C "${workdir}" dotbot
    chmod +x "${workdir}/dotbot"
    printf '%s\n' "${workdir}/dotbot"
}

# Print the dotbot binary to run: $DOTBOT, else an installed binary that reports
# the pinned version, else a verified download into <workdir>. The caller owns
# <workdir> and removes it.
resolve_dotbot() {
    local workdir="$1" candidate

    if [ -n "${DOTBOT:-}" ]; then
        [ -x "${DOTBOT}" ] || die "DOTBOT is set but not executable: ${DOTBOT}"
        printf '%s\n' "${DOTBOT}"
        return 0
    fi

    for candidate in "${HOME}/.apps/dotbot/bin/dotbot" "${HOME}/.local/bin/dotbot"; do
        if [ -x "${candidate}" ] && [[ "$("${candidate}" --version 2>/dev/null)" == *"version ${DOTBOT_PINNED_VERSION}" ]]; then
            printf '%s\n' "${candidate}"
            return 0
        fi
    done

    dotbot_download "${workdir}"
}
