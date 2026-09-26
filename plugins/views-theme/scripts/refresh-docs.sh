#!/usr/bin/env bash
# Re-copy ViewsTheme docs/ into this plugin's snapshot.
# =====================================================
# Usage:
#   refresh-docs.sh [--source PATH] [--sha SHA] [--plugin-root PATH]
#
# --source PATH  Copy PATH/docs from a local views-theme checkout
# --sha SHA      Pin / fetch this commit when cloning (default: references/docs.sha)
# Without --source, clones https://github.com/fyrst-digital/views-theme at SHA.
#
# Exit codes:
#   0 - Snapshot updated
#   1 - Usage or copy failure
#   2 - Missing dependency (git) when cloning

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_PLUGIN_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

PLUGIN_ROOT="${CURSOR_PLUGIN_ROOT:-${DEFAULT_PLUGIN_ROOT}}"
SOURCE=""
SHA=""
REPO_URL="https://github.com/fyrst-digital/views-theme.git"
DEFAULT_SHA="48192594c34d62b7cf1adc8900dd018ae6b15d23"

usage() {
    printf '%s\n' "Usage: refresh-docs.sh [--source PATH] [--sha SHA] [--plugin-root PATH]" >&2
    exit 1
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --source)
            [[ $# -ge 2 ]] || usage
            SOURCE="$2"
            shift 2
            ;;
        --sha)
            [[ $# -ge 2 ]] || usage
            SHA="$2"
            shift 2
            ;;
        --plugin-root)
            [[ $# -ge 2 ]] || usage
            PLUGIN_ROOT="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            usage
            ;;
    esac
done

PIN_FILE="${PLUGIN_ROOT}/references/docs.sha"
DEST="${PLUGIN_ROOT}/references/docs"

if [[ -z "${SHA}" && -f "${PIN_FILE}" ]]; then
    SHA="$(tr -d '[:space:]' < "${PIN_FILE}")"
fi
if [[ -z "${SHA}" ]]; then
    SHA="${DEFAULT_SHA}"
fi

has_docs() {
    [[ -f "$1/conventions/hard-rules.md" ]]
}

copy_docs() {
    local from="$1"
    if ! has_docs "${from}"; then
        printf '%s\n' "Not a ViewsTheme docs tree (missing conventions/hard-rules.md): ${from}" >&2
        exit 1
    fi
    mkdir -p "${PLUGIN_ROOT}/references"
    rm -rf "${DEST}"
    mkdir -p "${DEST}"
    cp -R "${from}/." "${DEST}/"
}

write_pin() {
    local value="$1"
    mkdir -p "${PLUGIN_ROOT}/references"
    printf '%s\n' "${value}" > "${PIN_FILE}"
}

TMP=""
cleanup() {
    if [[ -n "${TMP}" && -d "${TMP}" ]]; then
        rm -rf "${TMP}"
    fi
}
trap cleanup EXIT

if [[ -n "${SOURCE}" ]]; then
    if [[ ! -d "${SOURCE}" ]]; then
        printf '%s\n' "Source path is not a directory: ${SOURCE}" >&2
        exit 1
    fi
    copy_docs "${SOURCE}/docs"
    if [[ -d "${SOURCE}/.git" ]] && command -v git >/dev/null 2>&1; then
        write_pin "$(git -C "${SOURCE}" rev-parse HEAD)"
    else
        write_pin "${SHA}"
    fi
    printf '%s\n' "Updated ${DEST} from ${SOURCE}/docs (pin $(tr -d '[:space:]' < "${PIN_FILE}"))"
    exit 0
fi

if ! command -v git >/dev/null 2>&1; then
    printf '%s\n' "git is required to clone fyrst-digital/views-theme" >&2
    exit 2
fi

TMP="$(mktemp -d)"
git init "${TMP}" >/dev/null
git -C "${TMP}" remote add origin "${REPO_URL}"
git -C "${TMP}" fetch --depth 1 origin "${SHA}"
git -C "${TMP}" checkout FETCH_HEAD -- docs
FULL="$(git -C "${TMP}" rev-parse FETCH_HEAD)"
copy_docs "${TMP}/docs"
write_pin "${FULL}"
printf '%s\n' "Updated ${DEST} from ${REPO_URL} @ ${FULL}"
