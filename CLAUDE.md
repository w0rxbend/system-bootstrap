# CLAUDE.md

Guidance for working in this repository.

## What this is

`system-bootstrap` is a personal, multi-distro Linux workstation automation repo — **not an
application**. It provisions a dev machine from scratch across **Arch, Fedora and Ubuntu** from
per-host module lists (`hosts/`, `modules/`) run by a `Justfile`, plus Dotbot-managed dotfiles. There is no build, test
suite, or runtime; "correctness" means the scripts run cleanly and pass the format/lint gate.

## Layout

- `Justfile` — the entry point: `hosts`, `host <h>`, `dry <h>`, `module <h> <m>`, plus
  `format`/`lint`/`check`. `host` and `module` are `[confirm]` recipes; `just --yes` skips the prompt.
- `bootstrap.sh` — POSIX first-run entry: checks the host's `DISTRO`, installs git, curl, zsh and
  just, then `just --yes host <h>`.
- `hosts/<host>/host.env` — one machine: `DISTRO` (`arch|fedora|ubuntu`) and the ordered `MODULES`
  list; optional `GIT_USER_NAME`, `GIT_USER_EMAIL`, `OBS=1`. Optional `hosts/<host>/dotbot.yaml` +
  `files/` hold links for that machine only (e.g. the arch-sway Kanshi profile).
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
- `modules/<m>/files/` — config sources linked by the module manifests. Links use `force: true` —
  applying overwrites matching local config paths. Neovim config (`modules/cli/files/nvim/`) is an
  AstroNvim setup with a pinned `lazy-lock.json`.
- DankMaterialShell writes its settings through the niri-dms links, so its saves land in
  `modules/niri-dms/files/`.
- `docs/`, `assets/` — notes (keyrings, fonts, Sway) and wallpapers/icons.
- `others/` — backups kept for manual restore (e.g. Vesktop/Vencord settings); nothing links or
  installs them.

## Conventions

- **Every script must be reachable** from a `Justfile` recipe, or from a module `setup.sh` run by
  `just host`; `bootstrap.sh` is the one entry outside the Justfile. Don't leave orphan scripts or
  recipes pointing at non-existent files; `just lint` checks both.
- One owner per link target per host; `just lint` fails on a duplicate within a host's module set.
- New shell scripts: start with `set -euo pipefail` (bash) and quote variable expansions. Match
  `format.sh`/`lint.sh` for anything new or reworked.
- Prefer `${HOME}` / `$XDG_*` over hardcoded `/home/<user>` paths.
- Pin tool versions in `modules/cli/files/binstaller/config.yaml` (`spec.versions`, each with a
  checksum and a `# renovate:` comment); binstaller itself is pinned in `scripts/binary-dist.sh`
  (`BINSTALLER_VERSION`). helm, kustomize, yq and nerd-fonts-installer come from that
  profile, not curl installers; starship uses its official script (`scripts/cli-tools.sh`). dotbot-go is pinned twice (`scripts/lib/dotbot.sh` and the profile);
  `just lint` fails when they differ. Go is pinned in `scripts/install_golang.sh` (version and
  SHA-256 together).
- A module with any `packages.*` needs a `packages.<distro>` for every host distro that lists it
  (a comment-only file when it needs nothing); `just lint` checks this.

## Quality gate

```bash
just format   # shfmt, stylua, taplo, prettier (yaml/json/jsonc/md/css), xmllint, just --fmt
just lint     # shellcheck + syntax checks across shell/lua/toml/yaml/json/…
just check    # == lint
```

CI (`.github/workflows/format-and-lint.yml`) runs `just format`, auto-commits any diff as
`style: autoformat`, then `just lint`. Formatter/linter binaries are installed via
`taiki-e/install-action` (just, taplo-cli, stylua, selene) plus apt and npm. A second job runs
`just dry ubuntu-vm` in an `ubuntu:24.04` container. CI may push `style: autoformat` to main, so
run `git pull --rebase` after pushing.

Arch hosts install the gate tools (`modules/dev/packages.arch`). Elsewhere, when a tool is
missing, `just lint` skips that check; sanity-check edited shell scripts with `bash -n <file>`.

## Safety

Scripts install system packages, enable services, write system config, use `sudo`, and force-link
dotfiles over existing ones. This repo targets the maintainer's real machines — prefer minimal,
reviewable changes over broad rewrites, and never fabricate package/extension lists.
