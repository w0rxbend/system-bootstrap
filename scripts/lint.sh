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
if [ "${#yaml_files[@]}" -gt 0 ]; then
    run ruby -e 'require "yaml"; ARGV.each { |file| YAML.load_file(file) }' "${yaml_files[@]}"
fi

if have yamllint; then
    info "Linting YAML with yamllint"
    run yamllint "${yaml_files[@]}"
else
    skip "yamllint not found; YAML style lint skipped"
fi

info "Checking JSON syntax"
for file in "${strict_json_files[@]}"; do
    run jq empty "$file"
done

info "Checking JSONC syntax"
jsonc_parse_targets=("${jsonc_files[@]}" "${json_files_with_comments[@]}")
if [ "${#jsonc_parse_targets[@]}" -gt 0 ]; then
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
if [ "${#toml_files[@]}" -gt 0 ]; then
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
for file in "${lua_files[@]}"; do
    run luac -p "$file"
done

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
for file in "${xml_files[@]}"; do
    run xmllint --noout "$file"
done

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

skip "SVG files are intentionally ignored"
skip "No standard parser configured for INI, KDL, Rasi, or app-specific .conf files"

exit "${failures}"
