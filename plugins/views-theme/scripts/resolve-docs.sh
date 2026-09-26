#!/usr/bin/env bash
# Resolve the ViewsTheme docs directory to read.
# =================================================
# Prefers live ViewsTheme docs in the project tree, then this plugin's snapshot.
#
# Usage:
#   resolve-docs.sh [--project-dir DIR] [--plugin-root DIR] [--kind]
#
# stdout: absolute path to the docs directory
# --kind: print workspace|static-plugins|vendor|snapshot on stderr
#
# Exit codes:
#   0 - A docs directory was printed
#   1 - Usage error or no docs found

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_PLUGIN_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

PROJECT_DIR="${CURSOR_PROJECT_DIR:-${PWD}}"
PLUGIN_ROOT="${CURSOR_PLUGIN_ROOT:-${DEFAULT_PLUGIN_ROOT}}"
PRINT_KIND=0

usage() {
    printf '%s\n' "Usage: resolve-docs.sh [--project-dir DIR] [--plugin-root DIR] [--kind]" >&2
    exit 1
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --project-dir)
            [[ $# -ge 2 ]] || usage
            PROJECT_DIR="$2"
            shift 2
            ;;
        --plugin-root)
            [[ $# -ge 2 ]] || usage
            PLUGIN_ROOT="$2"
            shift 2
            ;;
        --kind)
            PRINT_KIND=1
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            usage
            ;;
    esac
done

has_docs() {
    local dir="$1"
    [[ -f "${dir}/conventions/hard-rules.md" ]]
}

is_views_theme_root() {
    local dir="$1"
    [[ -f "${dir}/composer.json" ]] || return 1
    has_docs "${dir}/docs" || return 1
    grep -qE '"name"[[:space:]]*:[[:space:]]*"fyrst/views-theme"' "${dir}/composer.json"
}

emit() {
    local kind="$1"
    local path="$2"
    if [[ "${PRINT_KIND}" -eq 1 ]]; then
        printf '%s\n' "${kind}" >&2
    fi
    printf '%s\n' "${path}"
    exit 0
}

# Walk from PROJECT_DIR to filesystem root. Prefer a views-theme workspace,
# then a Shopware tree that vendors or statically includes ViewsTheme.
current="$(cd "${PROJECT_DIR}" && pwd)"
workspace_hit=""
static_hit=""
vendor_hit=""

while true; do
    if [[ -z "${workspace_hit}" ]] && is_views_theme_root "${current}"; then
        workspace_hit="${current}/docs"
    fi
    if [[ -z "${static_hit}" ]] && has_docs "${current}/custom/static-plugins/ViewsTheme/docs"; then
        static_hit="${current}/custom/static-plugins/ViewsTheme/docs"
    fi
    if [[ -z "${vendor_hit}" ]] && has_docs "${current}/vendor/fyrst/views-theme/docs"; then
        vendor_hit="${current}/vendor/fyrst/views-theme/docs"
    fi

    parent="$(dirname "${current}")"
    if [[ "${parent}" == "${current}" ]]; then
        break
    fi
    current="${parent}"
done

if [[ -n "${workspace_hit}" ]]; then
    emit workspace "${workspace_hit}"
fi
if [[ -n "${static_hit}" ]]; then
    emit static-plugins "${static_hit}"
fi
if [[ -n "${vendor_hit}" ]]; then
    emit vendor "${vendor_hit}"
fi

snapshot="${PLUGIN_ROOT}/references/docs"
if has_docs "${snapshot}"; then
    emit snapshot "${snapshot}"
fi

printf '%s\n' "No ViewsTheme docs found (live tree or plugin snapshot)." >&2
exit 1
