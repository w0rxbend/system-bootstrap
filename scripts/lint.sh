#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${REPO_ROOT}"

# shellcheck source=scripts/lib/common.sh
. "${REPO_ROOT}/scripts/lib/common.sh"

failures=0

run() {
    if ! "$@"; then
        failures=1
    fi
}

fail() {
    printf 'error: %s\n' "$*" >&2
    failures=1
}

collect_files() {
    find . \
        -path ./.git -prune -o \
        -path ./assets -prune -o \
        -path ./.agents -prune -o \
        -path ./.codex -prune -o \
        -type f "$@" -print
}

is_shell_file() {
    local file="$1" first_line

    case "$(basename "$file")" in
        .zshrc | *.zsh) return 0 ;;
    esac

    case "$file" in
        *.sh) return 0 ;;
    esac

    IFS= read -r first_line <"$file" || first_line=""
    [[ "$first_line" == "#!"*"sh"* ]]
}

shell_dialect() {
    local file="$1" first_line

    case "$(basename "$file")" in
        .zshrc | *.zsh)
            echo "zsh"
            return
            ;;
    esac

    IFS= read -r first_line <"$file" || first_line=""
    case "$first_line" in
        *bash*) echo "bash" ;;
        *zsh*) echo "zsh" ;;
        *) echo "bash" ;;
    esac
}

mapfile -t all_files < <(collect_files)
shell_files=()
for file in "${all_files[@]}"; do
    if is_shell_file "$file"; then
        shell_files+=("$file")
    fi
done

mapfile -t yaml_files < <(collect_files \( -name "*.yaml" -o -name "*.yml" \))
mapfile -t json_files < <(collect_files \( -name "*.json" \))
mapfile -t jsonc_files < <(collect_files \( -name "*.jsonc" \))
mapfile -t toml_files < <(collect_files \( -name "*.toml" \))
mapfile -t lua_files < <(collect_files \( -name "*.lua" \))
mapfile -t xml_files < <(collect_files \( -name "*.xml" \))
mapfile -t md_files < <(collect_files \( -name "*.md" \))
mapfile -t css_files < <(collect_files \( -name "*.css" \))

json_files_with_comments=()
strict_json_files=()
for file in "${json_files[@]}"; do
    if grep -qE '^[[:space:]]*//|/\*' "$file"; then
        json_files_with_comments+=("$file")
    else
        strict_json_files+=("$file")
    fi
done

info "Checking Justfile"
run env JUST_UNSTABLE=1 just --fmt --check

info "Checking shell syntax"
for file in "${shell_files[@]}"; do
    case "$(shell_dialect "$file")" in
        zsh) run zsh -n "$file" ;;
        bash) run bash -n "$file" ;;
    esac
done

if have shellcheck; then
    info "Linting shell scripts with shellcheck"
    for file in "${shell_files[@]}"; do
        if [ "$(shell_dialect "$file")" = "zsh" ]; then
            skip "shellcheck does not support zsh: $file"
        else
            run shellcheck --severity=error "$file"
        fi
    done
else
    skip "shellcheck not found; shell semantic lint skipped"
fi

if have shfmt; then
    info "Checking shell formatting with shfmt"
    mapfile -t sh_files < <(collect_files \( -name "*.sh" \))
    if [ "${#sh_files[@]}" -gt 0 ]; then
        run shfmt -d -i 4 -ci -bn "${sh_files[@]}"
    fi
else
    skip "shfmt not found; shell format check skipped"
fi

info "Checking YAML syntax"
if have ruby; then
    run ruby -e 'require "yaml"; ARGV.each { |file| YAML.load_file(file) }' "${yaml_files[@]}"
elif have python3 && python3 -c 'import yaml' 2>/dev/null; then
    run python3 -c 'import sys, yaml
for path in sys.argv[1:]:
    with open(path, encoding="utf-8") as handle:
        list(yaml.safe_load_all(handle))' "${yaml_files[@]}"
else
    skip "ruby and python3 yaml not found; YAML syntax check skipped"
fi

if have yamllint; then
    info "Linting YAML with yamllint"
    run yamllint "${yaml_files[@]}"
else
    skip "yamllint not found; YAML style lint skipped"
fi

info "Checking JSON syntax"
if have jq; then
    for file in "${strict_json_files[@]}"; do
        run jq empty "$file"
    done
else
    skip "jq not found; JSON syntax check skipped"
fi

info "Checking JSONC syntax"
jsonc_parse_targets=("${jsonc_files[@]}" "${json_files_with_comments[@]}")
if ! have python3; then
    skip "python3 not found; JSONC syntax check skipped"
elif [ "${#jsonc_parse_targets[@]}" -gt 0 ]; then
    run python3 - "${jsonc_parse_targets[@]}" <<'PY'
import json
import re
import sys

def strip_jsonc(text: str) -> str:
    out = []
    i = 0
    in_string = False
    escaped = False
    while i < len(text):
        ch = text[i]
        nxt = text[i + 1] if i + 1 < len(text) else ""
        if in_string:
            out.append(ch)
            if escaped:
                escaped = False
            elif ch == "\\":
                escaped = True
            elif ch == '"':
                in_string = False
            i += 1
            continue
        if ch == '"':
            in_string = True
            out.append(ch)
            i += 1
            continue
        if ch == "/" and nxt == "/":
            i = text.find("\n", i)
            if i == -1:
                break
            out.append("\n")
            i += 1
            continue
        if ch == "/" and nxt == "*":
            end = text.find("*/", i + 2)
            i = len(text) if end == -1 else end + 2
            continue
        out.append(ch)
        i += 1
    return re.sub(r",(\s*[}\]])", r"\1", "".join(out))

for path in sys.argv[1:]:
    with open(path, encoding="utf-8") as handle:
        json.loads(strip_jsonc(handle.read()))
PY
fi

info "Checking TOML syntax"
if ! have python3; then
    skip "python3 not found; TOML syntax check skipped"
elif [ "${#toml_files[@]}" -gt 0 ]; then
    run python3 - "${toml_files[@]}" <<'PY'
import sys
import tomllib

for path in sys.argv[1:]:
    with open(path, "rb") as handle:
        tomllib.load(handle)
PY
fi

if have taplo; then
    info "Checking TOML style with taplo"
    run taplo format --check "${toml_files[@]}"
else
    skip "taplo not found; TOML style check skipped"
fi

info "Checking Lua syntax"
if have luac; then
    for file in "${lua_files[@]}"; do
        run luac -p "$file"
    done
else
    skip "luac not found; Lua syntax check skipped"
fi

if have stylua; then
    info "Checking Lua formatting with stylua"
    run stylua --check "${lua_files[@]}"
else
    skip "stylua not found; Lua format check skipped"
fi

if have selene; then
    info "Linting Lua with selene"
    run selene --config .files/nvim/selene.toml .files/nvim
else
    skip "selene not found; Lua semantic lint skipped"
fi

info "Checking XML syntax"
if have xmllint; then
    for file in "${xml_files[@]}"; do
        run xmllint --noout "$file"
    done
else
    skip "xmllint not found; XML syntax check skipped"
fi

if have prettier; then
    info "Checking Prettier-managed files"
    prettier_targets=("${yaml_files[@]}" "${strict_json_files[@]}" "${md_files[@]}" "${css_files[@]}")
    if [ "${#prettier_targets[@]}" -gt 0 ]; then
        run prettier --check "${prettier_targets[@]}"
    fi
    prettier_jsonc_targets=("${jsonc_files[@]}" "${json_files_with_comments[@]}")
    if [ "${#prettier_jsonc_targets[@]}" -gt 0 ]; then
        run prettier --check --parser jsonc "${prettier_jsonc_targets[@]}"
    fi
else
    skip "prettier not found; Markdown/CSS/YAML/JSON style check skipped"
fi

if have markdownlint-cli2; then
    info "Linting Markdown with markdownlint-cli2"
    run markdownlint-cli2
elif have markdownlint; then
    info "Linting Markdown with markdownlint"
    run markdownlint "${md_files[@]}"
else
    skip "markdownlint not found; Markdown lint skipped"
fi

# Print "target<TAB>source" for every link in a dotbot manifest. Only the
# restricted form used in this repo is understood (`- link:` followed by
# 4-space `target: source` lines); anything else fails instead of being
# silently skipped.
manifest_links() {
    awk -v file="$1" '
        /^[[:space:]]*(#|$)/ { next }
        /^- / {
            key = $2
            sub(/:.*/, "", key)
            if (key !~ /^(defaults|link|create|clean|shell)$/) {
                printf "%s:%d: unsupported dotbot directive: %s\n", file, NR, key > "/dev/stderr"
                bad = 1
            }
            in_link = (key == "link")
            next
        }
        /^[^ ]/ { in_link = 0 }
        in_link && /^    [^ ]/ {
            if (NF != 2) {
                printf "%s:%d: unsupported link entry: %s\n", file, NR, $0 > "/dev/stderr"
                bad = 1
                next
            }
            target = $1
            sub(/:$/, "", target)
            sub(/\/$/, "", target)
            print target "\t" $2
        }
        END { exit bad }
    ' "$1"
}

# Legacy dotbot manifests and the base dir each one is applied with.
declare -A manifest_base=(
    [.files/install.conf.yaml]=.files
    [.files/niri.conf.yaml]=.files
    [.files/arch/install.conf.yaml]=.files/arch
    [.files/fedora/install.conf.yaml]=.files/fedora
    [.files/arch/sway/install.conf.yaml]=.files/arch/sway
)

# Manifest sets applied together on one machine today.
manifest_sets=(
    ".files/install.conf.yaml .files/arch/install.conf.yaml"
    ".files/install.conf.yaml .files/arch/install.conf.yaml .files/arch/sway/install.conf.yaml"
    ".files/install.conf.yaml .files/fedora/install.conf.yaml"
    ".files/install.conf.yaml .files/niri.conf.yaml"
)

# The Sway overlay overrides the shared alacritty files on purpose until the
# host/module split gives each target one owner.
known_duplicate_targets=(
    '~/.config/alacritty/alacritty.toml'
    '~/.config/alacritty/theme.toml'
)

declare -A manifest_targets=()

info "Checking dotbot manifests"
mapfile -t manifests < <(printf '%s\n' "${!manifest_base[@]}" | sort)
for manifest in "${manifests[@]}"; do
    base="${manifest_base[$manifest]}"
    if [ ! -f "${manifest}" ]; then
        fail "dotbot manifest missing: ${manifest}"
        continue
    fi
    if ! links="$(manifest_links "${manifest}")"; then
        failures=1
    fi
    manifest_targets[$manifest]="$(cut -f1 <<<"${links}")"
    while IFS=$'\t' read -r target source; do
        [ -n "${target}" ] || continue
        [ -e "${base}/${source}" ] || fail "${manifest}: ${target} -> ${base}/${source} does not exist"
    done <<<"${links}"
done

for manifest_set in "${manifest_sets[@]}"; do
    read -r -a set_members <<<"${manifest_set}"
    while IFS= read -r target; do
        [ -n "${target}" ] || continue
        if [[ " ${known_duplicate_targets[*]} " == *" ${target} "* ]]; then
            printf 'warn: %s is linked twice in: %s\n' "${target}" "${manifest_set}"
        else
            fail "${target} is linked twice in: ${manifest_set}"
        fi
    done < <(for member in "${set_members[@]}"; do printf '%s\n' "${manifest_targets[$member]:-}"; done | sort | uniq -d)
done

info "Checking Justfile and script references"
while IFS= read -r script; do
    [ -f "${script}" ] || fail "Justfile runs a missing script: ${script}"
done < <(grep -oE '\./scripts/[^[:space:]]+' Justfile | sort -u)

if have git && git rev-parse --git-dir >/dev/null 2>&1; then
    while IFS= read -r script; do
        if ! git grep -qF "${script}" -- Justfile 'scripts/*.sh' 'modules/*/setup.sh' ":(exclude)${script}"; then
            fail "${script} is not run by the Justfile, a module setup.sh, or another script"
        fi
    done < <(git ls-files -- 'scripts/*.sh')

    info "Checking tracked symlinks"
    while IFS= read -r -d '' entry; do
        path="${entry#*$'\t'}"
        [ "${entry%% *}" = "120000" ] || continue
        [ -e "${path}" ] || fail "tracked symlink does not resolve: ${path}"
    done < <(git ls-files -s -z)

    info "Checking for hardcoded home paths"
    # Allowlisted until those files are reworked: .zshrc (installer blocks),
    # danksearch and zellij (absolute paths in app config), the Sway
    # alacritty.toml (imports the repo by clone path), btop (upstream comment).
    grep_status=0
    home_paths="$(git grep -nE '/home/[a-z]|\.system-bootstrap' -- .files modules \
        ':(exclude).files/.zshrc' \
        ':(exclude).files/.config/danksearch/config.toml' \
        ':(exclude).files/.config/zellij/layouts/default.kdl' \
        ':(exclude).files/arch/sway/config/alacritty/alacritty.toml' \
        ':(exclude).files/.config/btop/btop.conf')" || grep_status=$?
    case "${grep_status}" in
        0)
            fail "hardcoded home or clone path; use \$HOME or a relative path:"
            printf '%s\n' "${home_paths}" >&2
            ;;
        1) ;;
        *) fail "git grep failed with exit ${grep_status}" ;;
    esac
else
    skip "not a git checkout; script reference, symlink and home path checks skipped"
fi

skip "SVG files are intentionally ignored"
skip "No standard parser configured for INI, KDL, Rasi, or app-specific .conf files"

exit "${failures}"
