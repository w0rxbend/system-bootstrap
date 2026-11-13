# CLAUDE.md

Guidance for working in this repository.

## What this is

`system-bootstrap` is a personal, multi-distro Linux workstation automation repo — **not an
application**. It provisions a dev machine from scratch across **Arch, Fedora and Ubuntu** from
per-host module lists (`hosts/`, `modules/`) run by a `Justfile`, plus Dotbot-managed dotfiles. There is no build, test
suite, or runtime; "correctness" means the scripts run cleanly and pass the format/lint gate.

## Layout

- `Justfile` — the entry point: `host <h>`, `dry <h>`, `module <h> <m>`, plus `format`/`lint`/`check`.
- `bootstrap.sh` — POSIX first-run entry: installs git, curl, zsh and just, then `just host <h>`.
- `hosts/<host>/host.env` — one machine: `DISTRO` (`arch|fedora|ubuntu`) and the ordered `MODULES`
  list; optional `GIT_USER_NAME`, `GIT_USER_EMAIL`, `OBS=1`.
- `modules/<module>/` — every file optional: `packages.<distro>` (names, `#` comments),
  `dotbot.yaml` (links only: `defaults|link|create|clean`, sources relative to the repo root),
  `setup.sh` (bash, idempotent, non-interactive; gets `HOST DISTRO REPO_ROOT`), `files/` (sources
  owned by the module).
- `scripts/host.sh` — the runner. Per module, in `MODULES` order: packages → dotbot → setup.sh, then
  `hosts/<host>/` as a last module. `--dry` never runs `sudo` or `setup.sh`.
- `scripts/lib/` — `common.sh` (helpers, `os_id`, `pkg_install`/`pkg_check`) and `dotbot.sh`
  (pinned dotbot-go, SHA-256 checked). Other `scripts/*.sh` are shared installers that module
  `setup.sh` files call.
- `scripts/format.sh`, `scripts/lint.sh` — the quality gate (well-structured, `set -euo pipefail`,
  degrade gracefully when a tool is absent). Treat these as the reference style for new scripts.
- `.files/` — config sources linked by the module manifests. Links use `force: true` — applying
  overwrites matching local config paths. DankMaterialShell writes through its links, so the
  `niri-dms` sources stay at their `.files/` paths. Neovim config (`.files/nvim/`) is an AstroNvim
  setup with a pinned `lazy-lock.json`.
- `docs/`, `assets/` — notes (keyrings, fonts, Sway) and wallpapers/icons.

## Conventions

- **Every script must be reachable** from a `Justfile` recipe, or from a module `setup.sh` run by
  `just host`; `bootstrap.sh` is the one entry outside the Justfile. Don't leave orphan scripts or
  recipes pointing at non-existent files; `just lint` checks both.
- One owner per link target per host; `just lint` fails on a duplicate within a host's module set.
- New shell scripts: start with `set -euo pipefail` (bash) and quote variable expansions. Match
  `format.sh`/`lint.sh` for anything new or reworked.
- Prefer `${HOME}` / `$XDG_*` over hardcoded `/home/<user>` paths.
- Pin tool versions in `.files/.config/binstaller/config.yaml` (`spec.versions`); Go is pinned in
  `scripts/install_golang.sh` (version and SHA-256 together).

## Quality gate

```bash
just format   # shfmt, stylua, taplo, prettier (yaml/json/jsonc/md/css), xmllint, just --fmt
just lint     # shellcheck + syntax checks across shell/lua/toml/yaml/json/…
just check    # == lint
```

CI (`.github/workflows/format-and-lint.yml`) runs `just format`, auto-commits any diff as
`style: autoformat`, then `just lint`. Formatter/linter binaries are installed via
`taiki-e/install-action` (just, taplo-cli, stylua, selene) plus apt and npm.

The linters (`shellcheck`, `shfmt`, `stylua`, `selene`, `just`) are often **not installed locally**.
When you can't run the gate, sanity-check edited shell scripts with `bash -n <file>` and keep changes
conservative.

## Safety

Scripts install system packages, enable services, write system config, use `sudo`, and force-link
dotfiles over existing ones. This repo targets the maintainer's real machines — prefer minimal,
reviewable changes over broad rewrites, and never fabricate package/extension lists.
