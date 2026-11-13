#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${REPO_ROOT}"

# shellcheck source=scripts/lib/common.sh
. "${REPO_ROOT}/scripts/lib/common.sh"

collect_files() {
    find . \
        -path ./.git -prune -o \
        -path ./assets -prune -o \
        -path ./.agents -prune -o \
        -path ./.codex -prune -o \
        -type f "$@" -print
}

mapfile -t sh_files < <(collect_files \( -name "*.sh" \))
mapfile -t lua_files < <(collect_files \( -name "*.lua" \))
mapfile -t toml_files < <(collect_files \( -name "*.toml" \))
mapfile -t prettier_files < <(
    collect_files \( \
        -name "*.yaml" -o -name "*.yml" -o \
        -name "*.md" -o -name "*.css" \
        \)
)
mapfile -t json_files < <(collect_files \( -name "*.json" \))
mapfile -t jsonc_files < <(collect_files \( -name "*.jsonc" \))
mapfile -t xml_files < <(collect_files \( -name "*.xml" \))

json_files_with_comments=()
strict_json_files=()
for file in "${json_files[@]}"; do
    if grep -qE '^[[:space:]]*//|/\*' "$file"; then
        json_files_with_comments+=("$file")
    else
        strict_json_files+=("$file")
    fi
done

if have just; then
    info "Formatting Justfile"
    JUST_UNSTABLE=1 just --fmt
fi

if have shfmt; then
    info "Formatting shell scripts with shfmt"
    if [ "${#sh_files[@]}" -gt 0 ]; then
        shfmt -w -i 4 -ci -bn "${sh_files[@]}"
    fi
else
    skip "shfmt not found; shell formatting skipped"
fi

if have stylua; then
    info "Formatting Lua with stylua"
    if [ "${#lua_files[@]}" -gt 0 ]; then
        stylua "${lua_files[@]}"
    fi
else
    skip "stylua not found; Lua formatting skipped"
fi

if have taplo; then
    info "Formatting TOML with taplo"
    if [ "${#toml_files[@]}" -gt 0 ]; then
        taplo format "${toml_files[@]}"
    fi
else
    skip "taplo not found; TOML formatting skipped"
fi

if have prettier; then
    info "Formatting YAML, JSON, JSONC, Markdown, and CSS with prettier"
    if [ "${#prettier_files[@]}" -gt 0 ]; then
        prettier --write "${prettier_files[@]}"
    fi
    if [ "${#strict_json_files[@]}" -gt 0 ]; then
        prettier --write "${strict_json_files[@]}"
    fi
    jsonc_targets=("${jsonc_files[@]}" "${json_files_with_comments[@]}")
    if [ "${#jsonc_targets[@]}" -gt 0 ]; then
        prettier --write --parser jsonc "${jsonc_targets[@]}"
    fi
else
    skip "prettier not found; YAML/JSON/Markdown/CSS formatting skipped"
fi

if have xmllint; then
    info "Formatting XML with xmllint"
    for file in "${xml_files[@]}"; do
        tmp="$(mktemp)"
        if xmllint --format "$file" >"$tmp"; then
            mv "$tmp" "$file"
        else
            rm -f "$tmp"
            exit 1
        fi
    done
else
    skip "xmllint not found; XML formatting skipped"
fi

skip "SVG files are intentionally ignored"
skip "No standard formatter configured for INI, KDL, Rasi, or app-specific .conf files"
