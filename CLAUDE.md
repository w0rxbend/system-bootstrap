# CLAUDE.md

Guidance for working in this repository.

## What this is

`system-bootstrap` is a personal, multi-distro Linux workstation automation repo — **not an
application**. It provisions a dev machine from scratch across **Fedora, Arch, and openSUSE** using
shell scripts orchestrated by a `Justfile`, plus Dotbot-managed dotfiles. There is no build, test
suite, or runtime; "correctness" means the scripts run cleanly and pass the format/lint gate.

## Layout

- `Justfile` — the entry point. Every workflow is a recipe (`just --list` to see them). Recipes just
  call scripts in `scripts/`.
- `scripts/` — Bash/zsh provisioning. Shared setup at the top level (`cli-tools.sh`,
  `binary-dist.sh`, `configurations.sh`, `install_golang.sh`, …); distro-specific under
  `scripts/arch/`, `scripts/fedora/`, `scripts/opensuse/` (numbered `00-`, `01-`, … run order).
- `scripts/format.sh`, `scripts/lint.sh` — the quality gate (well-structured, `set -euo pipefail`,
  degrade gracefully when a tool is absent). Treat these as the reference style for new scripts.
- `.files/` — dotfiles linked into `$HOME` by **Dotbot** via `install.conf.yaml` (root + per-distro
  overlays). Links use `force: true` — applying dotfiles overwrites matching local config paths.
  Neovim config (`.files/nvim/`) is an AstroNvim setup with a pinned `lazy-lock.json`.
- `docs/`, `assets/` — notes (keyrings, SDDM, fonts) and wallpapers/icons.

## Conventions

- **Every script must be reachable from a `Justfile` recipe.** Don't leave orphan scripts or recipes
  pointing at non-existent files — the two must stay in sync.
- New shell scripts: start with `set -euo pipefail` (bash) and quote variable expansions. The older
  top-level installer scripts predate this and are looser; match `format.sh`/`lint.sh` for anything
  new or reworked.
- Prefer `${HOME}` / `$XDG_*` over hardcoded `/home/<user>` paths.
- Pin tool versions in `binary-dist.sh` via the `*_VERSION` variables at the top.

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
