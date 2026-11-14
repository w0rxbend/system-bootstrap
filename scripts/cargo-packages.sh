#!/usr/bin/env bash
set -euo pipefail

# Rust CLI tools as prebuilt binaries via cargo-binstall.
# Run by modules/cli/setup.sh; scripts/cli-tools.sh (dev module) installs
# cargo-binstall first.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# shellcheck source=scripts/lib/common.sh
. "${REPO_ROOT}/scripts/lib/common.sh"

# The crate list lives in modules/cli/crates; ~/system-update.sh reads it too.
mapfile -t CRATES < <(pkg_names "${REPO_ROOT}/modules/cli/crates")
[ "${#CRATES[@]}" -gt 0 ] || die "no crates listed in modules/cli/crates"

# cargo-binstall may have been installed earlier in this run, before PATH knew it.
PATH="${CARGO_HOME:-${HOME}/.cargo}/bin:${PATH}"
have cargo-binstall || die "cargo-binstall not found; run the dev module first"

cargo-binstall -y "${CRATES[@]}"
