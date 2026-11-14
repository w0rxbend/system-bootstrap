# Development

This guide covers how the repo provisions a machine and how to change it. Read it before you edit `hosts/`,
`modules/` or `scripts/`. The README covers usage; this file covers changes.

## Rules

1. **Dotfiles go through dotbot-go.** Link every config file from a `dotbot.yaml` manifest. Do not create links in
   scripts. Two exceptions exist, both in a `setup.sh`: the `~/.zshrc` stub, a local file that sources the shared
   zshrc (shell), and the `~/.local/bin/nerd-fonts-installer` link (cli).
2. **Binaries go through binstaller.** Pin each tool in `modules/cli/files/binstaller/config.yaml` with a version and a
   checksum. Exceptions use an official installer script: starship, DMS, and the toolchains in `scripts/cli-tools.sh`
   (rustup, nvm, pyenv, poetry, pnpm, juliaup, dotenvx, Miniforge, uv, cargo-binstall).
3. **Distro packages go in `packages.<distro>` lists.** Never write a package name you have not resolved (see
   [Packages](#packages)).
4. **One owner per link target per host.** Two manifests in one host's set must not link the same path. `just lint`
   fails on a duplicate.
5. **Every script is reachable.** The Justfile, a module `setup.sh` or another script must run it. `bootstrap.sh` is
   the only entry point outside the Justfile.
6. **Dry run first.** Run `just dry <host>` before `just host <host>`, every time.
7. **Run the gate before you commit.** `just format`, then `just lint`.

## Layout

```text
Justfile                 entry point: host, dry, module, hosts, format, lint
bootstrap.sh             first run on a fresh machine (POSIX sh)
hosts/<host>/
  host.env               DISTRO and MODULES (required)
  dotbot.yaml, files/    links for this machine only (optional)
modules/<module>/        every file optional
  packages.<distro>      arch | fedora | ubuntu
  dotbot.yaml            links; sources are relative to the repo root
  setup.sh               everything that is not a package or a link
  files/                 config sources owned by the module
scripts/
  host.sh                the runner
  lib/common.sh          helpers: have, info, skip, die, os_id, pkg_install, pkg_check, pkg_names
  lib/dotbot.sh          pinned dotbot-go loader (SHA-256 checked)
  *.sh                   shared installers that module setup.sh files call
others/                  backups for manual restore; nothing links or installs them
assets/, docs/           wallpapers and icons; notes
```

## How a run works

`scripts/host.sh <host> [--dry] [--only <module>]` reads `hosts/<host>/host.env`. For each module in `MODULES`, in
order, and then for `hosts/<host>/` as a last unit, it runs three steps:

| Step | Real run                                    | `--dry`                               |
| ---- | ------------------------------------------- | ------------------------------------- |
| 1    | install `packages.<DISTRO>`                 | resolve each name read-only, no sudo  |
| 2    | apply `dotbot.yaml` (base dir: repo root)   | `dotbot -n`                           |
| 3    | run `setup.sh` with `HOST DISTRO REPO_ROOT` | `bash -n` only; `setup.sh` never runs |

- A missing file skips its step.
- A real run refuses when `DISTRO` does not match this machine (`os_id`), and refuses to run as root.
- A real run asks for sudo once and keeps the credentials alive until it exits.
- A real run stops at the first failure and prints `just module <host> <module>` to resume.
- A dry run reports every failure and exits 1 at the end. It never calls sudo and may run as root (CI does).
- `--only <module>` runs one module and skips `hosts/<host>/`.
- On Arch, every package install is `pacman -Syu --needed`, so the first module also upgrades the system.

| Command                  | Does                                                                       |
| ------------------------ | -------------------------------------------------------------------------- |
| `just hosts`             | list hosts and their `MODULES`                                             |
| `just dry <host>`        | dry run, read-only                                                         |
| `just host <host>`       | real run; asks for confirmation                                            |
| `just module <host> <m>` | one module for real; asks for confirmation                                 |
| `just format`            | run every formatter                                                        |
| `just lint`              | run every check (same as `just check`)                                     |
| `./bootstrap.sh <host>`  | fresh machine: install git, curl, zsh, just, then `just --yes host <host>` |

## Add a host

1. Create `hosts/<host>/host.env`. It is sourced by bash: plain `VAR=value` lines only.

   ```sh
   # Arch/CachyOS with Sway.
   # Optional: GIT_USER_NAME, GIT_USER_EMAIL, OBS=1
   DISTRO=arch
   MODULES="base shell dev cli containers virt desktop sway"
   ```

2. Order `MODULES` by dependency. Keep this order:
   - `base` first. It adds the Fedora repos (RPM Fusion, VS Code) that later modules need.
   - `dev` before `cli`. `dev` installs cargo-binstall; `cli` uses it.
   - `desktop` before `gnome`. `desktop` adds the flathub remote; `gnome` installs from it.
   - Window-manager modules (`gnome`, `sway`, `niri-dms`) last.
3. Add machine-only links, if any: put the sources in `hosts/<host>/files/` and link them from
   `hosts/<host>/dotbot.yaml`. Use it for monitor layouts and other per-machine values. Example:
   `hosts/arch-sway/` links the kanshi profile.
4. Run `just lint`. It fails when a module is missing, a module has no `packages.<DISTRO>`, or two manifests in the
   set link the same target.
5. Run `just dry <host>` on the target machine, then `just host <host>`.

## Add a module

1. Create `modules/<module>/` with only the files it needs:

   | File                | Contract                                                             |
   | ------------------- | -------------------------------------------------------------------- |
   | `packages.<distro>` | Package names separated by spaces or newlines. `#` starts a comment. |
   | `dotbot.yaml`       | Only `defaults`, `link`, `create`, `clean`. No `shell` steps.        |
   | `setup.sh`          | Bash, `set -euo pipefail`, idempotent, non-interactive, executable.  |
   | `files/`            | Sources this module links. Mirror the app's config path under it.    |

2. If the module has any package list, give it one for every distro of every host that lists it. A distro that needs
   no packages gets a list that holds only a comment.
3. Write `dotbot.yaml` with the shared defaults. Sources are relative to the repo root:

   ```yaml
   # Applied with the repo root as base dir (scripts/host.sh).
   - defaults:
       link:
         relink: true
         create: true
         force: true

   - link:
       ~/.config/<app>/config: modules/<module>/files/<app>/config
   ```

4. Write `setup.sh` from this skeleton:

   ```bash
   #!/usr/bin/env bash
   set -euo pipefail

   # <Module>: <what it does that is not a package or a link>.
   # Run by scripts/host.sh.

   : "${REPO_ROOT:?run through scripts/host.sh}"

   # shellcheck source=scripts/lib/common.sh
   . "${REPO_ROOT}/scripts/lib/common.sh"
   ```

   - Check before you change: skip work that is already done (`have <cmd> && exit 0`, `grep -q`, `--if-not-exists`).
   - Never prompt. Pass `-y`, `--noconfirm` or the installer's unattended flags.
   - Use `${HOME}` and `${XDG_*}`, never `/home/<user>`.
   - Use `skip` for an optional step that cannot run; use `die` for a required one.
   - Keep `sudo` out of Flatpak commands.
   - Download a remote installer to a temp file, then run it. Do not pipe `curl` into a shell.

5. Add the module to a host's `MODULES`, then run `just lint` and `just dry <host>`.

## Dotfiles

### Add a config file

1. Put the file in `modules/<module>/files/<app>/...`, mirroring its path under `~/.config`.
2. Add one `link:` line to that module's `dotbot.yaml`.
3. Run `just lint`. It fails when the source does not exist or another manifest in a host's set links the same target.
4. Run `just dry <host>`, then `just module <host> <module>`.

Links use `force: true`. Applying replaces a real file at the target path. Move it into the repo first if you need it.

### Choose where a file lives

| Scope                    | Location                                                               |
| ------------------------ | ---------------------------------------------------------------------- |
| Every host with module X | `modules/X/files/`, linked by `modules/X/dotbot.yaml`                  |
| One machine              | `hosts/<host>/files/`, linked by `hosts/<host>/dotbot.yaml`            |
| One machine, not in git  | `~/.custom.pre.zsh`, `~/.custom.zsh`, `~/.config/alacritty/local.toml` |

- `~/.custom.pre.zsh` runs before Oh My Zsh. Put `fpath` entries and plugin `zstyle`s there.
- `~/.custom.zsh` runs after Oh My Zsh. Put `PATH` entries for machine-only tools (AI CLIs, for example) there.
- Do not add machine-only tools to `modules/shell/files/zshrc`.

### Shared targets

Split a file when two modules need to change it, so each part has one owner. Alacritty is the pattern:
`~/.config/alacritty/alacritty.toml` only imports, and later files win.

| File         | Owner                               |
| ------------ | ----------------------------------- |
| `base.toml`  | `desktop`                           |
| `theme.toml` | `desktop`                           |
| `wm.toml`    | the window-manager module, optional |
| `local.toml` | the machine, untracked, optional    |

### Move or remove a source

- **Move:** `git mv` the source, then update its `link:` line. Re-run `just host` on every machine that links it. A
  machine that has not re-run keeps a dangling link until it does.
- **Remove:** delete the `link:` line and the source. On the next run, the `clean` step in `base` deletes dangling links
  into the repo.
- Find dangling links on a machine: `find ~ -maxdepth 4 -xtype l -lname '*system-bootstrap*'`.

### Apps that write to their config

- **DankMaterialShell** saves through its links (Qt `QSaveFile` follows symlinks), so its changes land in
  `modules/niri-dms/files/`. Commit them like any edit.
- **GLib/GNOME** replaces the `mimeapps.list` link with a plain file. Copy default-app changes back to the repo before
  you re-apply, or the re-apply overwrites them.
- **Installers that append to `~/.zshrc`** write into the local stub, not the repo. Move what you want to keep into
  `~/.custom.zsh`.

## Packages

1. Add the name to `modules/<module>/packages.<distro>`.
2. Resolve every new name before you commit:

   | Distro | Check                                 |
   | ------ | ------------------------------------- |
   | arch   | `pacman -Si <name>`                   |
   | fedora | `dnf repoquery --whatprovides <name>` |
   | ubuntu | `apt-cache policy <name>`             |

3. A name you cannot resolve on that distro goes on a commented `# unverified:` line, not an active line.
4. Run `just dry <host>`. Step 1 resolves every list read-only.

## Binaries

Add a tool to `modules/cli/files/binstaller/config.yaml`:

1. Pin the version in `spec.versions` with a Renovate comment:

   ```yaml
   # renovate: datasource=github-releases depName=<owner>/<repo>
   <tool>: v1.2.3
   ```

2. Add a `plan` entry. Install to `${appsDir}/<tool>/bin` and configure a checksum: `discover` when upstream ships a
   sha256sum file, a static `value` otherwise.

   ```yaml
   - name: <tool>
     kind: binary-tool
     description: <one line>
     spec:
       versionRef: <tool>
       installDir: ${appsDir}/<tool>/bin
       download:
         url: https://github.com/<owner>/<repo>/releases/download/${version}/<asset>
         filename: <tool>
         checksum:
           algorithm: sha256
           discover:
             type: sha256sum
             url: https://github.com/<owner>/<repo>/releases/download/${version}/<sums-file>
             file: <asset>
       executables:
         - path: <tool>
           mode: "0755"
   ```

3. Check it without installing. Options go before the command:

   ```sh
   binstaller --config modules/cli/files/binstaller/config.yaml plan --only <tool>
   ```

   The plan must show a checksum, not `checksum: missing`.

- Take versions and checksums from the upstream release. Never invent them.
- A static `value` must be refreshed in the same change that bumps the version.
- binstaller replaces the whole `installDir` on apply. Never point it at a shared directory such as `~/.local/bin`.
- The zshrc puts `~/.apps/*/bin` first on `PATH`, so a new tool needs no shell edit.
- dotbot-go is pinned twice: in the profile and in `scripts/lib/dotbot.sh`. Bump both together; `just lint` fails when
  they differ.

### Rust crates

Add the crate to `modules/cli/crates` (same format as package lists). `scripts/cargo-packages.sh` installs it with
cargo-binstall, and `~/system-update.sh` updates it.

## Add a distro

The supported distros are `arch`, `fedora` and `ubuntu`. A new one needs every item below:

1. `scripts/lib/common.sh`: `os_id`, `pkg_install_names` and `pkg_check`.
2. `bootstrap.sh`: the DISTRO case that installs git, curl, zsh and just.
3. `scripts/lint.sh`: the accepted `DISTRO` values.
4. `modules/base/setup.sh`: the system upgrade and repo setup.
5. `modules/base/files/system-update.sh`: the package-manager update step.
6. A `packages.<distro>` file in every module a host on that distro lists.

## Quality gate and commits

- `just format` runs shfmt, stylua, taplo, prettier, xmllint and `just --fmt`.
- `just lint` runs syntax checks and linters for shell, YAML, JSON, TOML, Lua, XML and Markdown. It skips a check when
  its tool is missing. It also checks:
  - every manifest source exists, and no target is linked twice within a host's set;
  - every module in a host has `packages.<DISTRO>` when it has any package list;
  - every script is run by something, and every Justfile script exists;
  - every tracked symlink resolves, and no file under `modules/` hardcodes `/home/<user>` or the clone path;
  - both dotbot-go pins match, and the Sway config passes `sway -C`.
- Arch hosts install the gate tools through `modules/dev/packages.arch`.
- CI runs `just format`, pushes any diff to `main` as `style: autoformat`, runs `just lint`, then runs
  `just dry ubuntu-vm` in an `ubuntu:24.04` container. Run `git pull --rebase` after every push.
- Commit messages follow Conventional Commits: `feat(sway): ...`, `fix(base): ...`, `docs: ...`.

## Troubleshooting

| Symptom                                          | Action                                                                                |
| ------------------------------------------------ | ------------------------------------------------------------------------------------- |
| A real run stopped                               | Fix the cause, then run the printed `just module <host> <module>`.                    |
| `<target> is linked twice for hosts/<host>`      | Give the target one owner, or split the file (see [Shared targets](#shared-targets)). |
| `module '<m>' has no packages.<distro>`          | Add the list. Use a comment-only file if the distro needs no packages.                |
| `<script> is not run by ...`                     | Call it from a `setup.sh` or the Justfile, or delete it.                              |
| `<host> is a <distro> host, this machine is ...` | Wrong host name for this machine. Check `just hosts`.                                 |
| A tool runs an old copy                          | Remove the stale system copy (for example `/usr/local/bin/helm`).                     |
