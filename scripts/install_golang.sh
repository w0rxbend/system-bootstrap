#!/usr/bin/env bash
set -euo pipefail

# Go toolchain in ~/.go, pinned and checksum-verified. Run by
# modules/dev/setup.sh. Does nothing when ~/.go already has this version.
# Bump GO_VERSION and GO_SHA256 together; the checksum is on https://go.dev/dl/.

GO_VERSION=1.26.5
GO_SHA256=5c2c3b16caefa1d968a94c1daca04a7ca301a496d9b086e17ad77bb81393f053

GO_ROOT="${HOME}/.go"
ARCHIVE="go${GO_VERSION}.linux-amd64.tar.gz"

if [ -x "${GO_ROOT}/bin/go" ] && [ "$("${GO_ROOT}/bin/go" env GOVERSION)" = "go${GO_VERSION}" ]; then
    printf 'skip: go%s already installed in %s\n' "${GO_VERSION}" "${GO_ROOT}"
    exit 0
fi

workdir="$(mktemp -d)"
trap 'rm -rf -- "${workdir}"' EXIT

printf '\n==> Installing go%s into %s\n' "${GO_VERSION}" "${GO_ROOT}"
curl --proto '=https' --tlsv1.2 -fsSL -o "${workdir}/${ARCHIVE}" "https://dl.google.com/go/${ARCHIVE}"
printf '%s  %s\n' "${GO_SHA256}" "${workdir}/${ARCHIVE}" | sha256sum -c -
tar -xzf "${workdir}/${ARCHIVE}" -C "${workdir}"

rm -rf "${GO_ROOT}"
mv "${workdir}/go" "${GO_ROOT}"
mkdir -p "${HOME}/.go-workspace"
