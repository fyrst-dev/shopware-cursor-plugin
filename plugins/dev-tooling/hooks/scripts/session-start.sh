#!/usr/bin/env bash
# sessionStart hook: inject MCP dev tool usage directives + scopes metadata.
set -euo pipefail

# Cursor writes hook-event JSON to stdin; drain it so the harness write
# cannot block on a payload larger than the pipe buffer.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"
resolve_project_dir "$(cat)"

HOOK_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROMPT_FILE="${HOOK_DIR}/prompts/mcp-tool-directives.md"

_config_locations() {
    local prefix="$1"
    printf '%s\n' ".cursor/.mcp-${prefix}.json" ".mcp-${prefix}.json"
}

is_enforced() {
    local config_prefix="$1"
    [[ -z "${PROJECT_DIR:-}" ]] && return 0
    local config_file="" location
    while IFS= read -r location; do
        if [[ -f "${PROJECT_DIR}/${location}" ]]; then
            config_file="${PROJECT_DIR}/${location}"
            break
        fi
    done < <(_config_locations "$config_prefix")
    [[ -z "$config_file" ]] && return 0
    command -v jq &>/dev/null || return 0
    local val
    val=$(jq -r 'if .enforce_mcp_tools == false then "false" else "true" end' "$config_file" 2>/dev/null || echo "true")
    [[ "$val" == "true" ]]
}

# _render_scopes_section <config-prefix>
# Echoes a markdown block describing the declared scopes, or nothing when
# no scopes are present.
_render_scopes_section() {
    local prefix="$1"
    [[ -z "${PROJECT_DIR:-}" ]] && return 0
    command -v jq &>/dev/null || return 0

    local config_file="" location
    while IFS= read -r location; do
        if [[ -f "${PROJECT_DIR}/${location}" ]]; then
            config_file="${PROJECT_DIR}/${location}"
            break
        fi
    done < <(_config_locations "$prefix")
    [[ -z "${config_file}" ]] && return 0

    local has_scopes
    has_scopes=$(jq -r '.scopes // {} | keys | length' "${config_file}" 2>/dev/null || echo "0")
    [[ "${has_scopes}" -eq 0 ]] && return 0

    local default_scope names
    default_scope=$(jq -r '.default_scope // "shopware"' "${config_file}")
    names=$(jq -r '.scopes | keys | join(", ")' "${config_file}")

    cat <<EOF

## ${prefix} scopes

Default scope: ${default_scope}
Declared scopes: shopware (implicit), ${names}

Scope determines cwd, configs, and bootstrap prereqs for ${prefix} MCP tools.
Tools accept an optional \`scope\` argument that overrides the default for
one call. Pass \`scope: "shopware"\` to target project-root code while a plugin
scope is the default.
EOF
}

is_enforced "php-tooling" || is_enforced "js-tooling" || exit 0

context=""
if [[ -f "$PROMPT_FILE" ]]; then
    context=$(cat "$PROMPT_FILE")
fi

# Append scopes sections (one per config prefix that declares scopes).
scopes_block=""
for prefix in php-tooling js-tooling; do
    section=$(_render_scopes_section "${prefix}")
    [[ -n "${section}" ]] && scopes_block+="${section}"
done

[[ -n "${scopes_block}" ]] && context+="${scopes_block}"

emit_additional_context "sessionStart" "${context}"
exit 0
