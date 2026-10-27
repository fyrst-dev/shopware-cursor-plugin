#!/bin/bash
# Shared functions for MCP tool enforcement hooks
# ================================================
# This library provides common functionality for Cursor beforeShellExecution
# and preToolUse hooks that block bash commands in favor of MCP tools.
#
# Usage:
#   source "${SCRIPT_DIR}/lib/common.sh"
#   parse_hook_input
#   load_mcp_config "php-tooling"  # or "js-tooling"
#   # ... pattern matching ...
#   block_tool "php-tooling" "Description" "phpstan_analyze"

# Global variables set by this library:
#   COMMAND - The shell command being checked
#   HOOK_INPUT - Raw hook JSON from stdin (set by parse_hook_input)
#   PROJECT_DIR - Workspace root
#   CONFIG_FILE - Path to loaded config file (or empty)
#   ENVIRONMENT - Environment from config (native/docker/docker-compose/vagrant/ddev)
#   ENFORCE_MCP_TOOLS - Whether to enforce MCP tools (true/false)

# Resolve the project directory from Cursor hook payloads.
# Prefers CURSOR_PROJECT_DIR, then workspace_roots/cwd from the hook JSON.
# Args: $1 = optional hook JSON string
resolve_project_dir() {
    local input="${1:-}"
    if [[ -n "${PROJECT_DIR:-}" ]]; then
        return 0
    fi
    if [[ -n "${CURSOR_PROJECT_DIR:-}" ]]; then
        PROJECT_DIR="${CURSOR_PROJECT_DIR}"
        return 0
    fi
    if [[ -n "$input" ]]; then
        local root
        root=$(printf '%s' "$input" | jq -r '.workspace_roots[0] // .cwd // empty' 2>/dev/null || true)
        if [[ -n "$root" ]]; then
            PROJECT_DIR="$root"
        fi
    fi
}

# Emit Cursor sessionStart / postToolUse context.
# Args: $1 = unused (kept so callers can pass the event name)
#       $2 = context string
emit_additional_context() {
    local context="$2"
    local json_context
    json_context=$(printf '%s' "${context}" | jq -Rs '.')
    cat <<EOF
{
  "additional_context": ${json_context}
}
EOF
}

# Parse hook input from stdin
# Sets: COMMAND, HOOK_INPUT, PROJECT_DIR (globals)
# Exits 0 if command is empty
parse_hook_input() {
    local input
    input=$(cat)
    HOOK_INPUT="$input"
    resolve_project_dir "$input"
    COMMAND=$(printf '%s' "$input" | jq -r '.command // .tool_input.command // empty')
    if [[ -z "$COMMAND" ]]; then
        exit 0
    fi
}

# Load MCP config from project directory
# Args: $1 = config prefix (e.g., "php-tooling", "js-tooling")
# Sets: CONFIG_FILE, ENVIRONMENT, ENFORCE_MCP_TOOLS (globals)
# Exits 0 if enforcement is disabled
load_mcp_config() {
    local config_prefix="$1"
    CONFIG_FILE=""
    ENVIRONMENT=""
    ENFORCE_MCP_TOOLS="true"

    resolve_project_dir "${HOOK_INPUT:-}"

    if [[ -n "${PROJECT_DIR:-}" ]]; then
        for location in ".cursor/.mcp-${config_prefix}.json" ".mcp-${config_prefix}.json"; do
            if [[ -f "${PROJECT_DIR}/${location}" ]]; then
                CONFIG_FILE="${PROJECT_DIR}/${location}"
                break
            fi
        done

        if [[ -n "$CONFIG_FILE" ]]; then
            ENVIRONMENT=$(jq -r '.environment // empty' "$CONFIG_FILE" 2>/dev/null || true)
            local enforce_value
            enforce_value=$(jq -r 'if .enforce_mcp_tools == false then "false" else "true" end' "$CONFIG_FILE" 2>/dev/null || echo "true")
            if [[ "$enforce_value" == "false" ]]; then
                ENFORCE_MCP_TOOLS="false"
            fi
        fi
    fi

    if [[ "$ENFORCE_MCP_TOOLS" == "false" ]]; then
        exit 0
    fi
}

# Block a tool with formatted message.
# Tool names carry no host prefix. The message names the tool and its server.
# Args: $1 = MCP server name (e.g., "php-tooling")
#       $2 = description of what to use instead
#       $3... = tool names, one or more (e.g., "ecs_check" "ecs_fix")
# Outputs Cursor deny JSON on stdout, a human message on stderr, exits 2
block_tool() {
    local server="$1"
    local description="$2"
    shift 2

    local tools="" name
    for name in "$@"; do
        tools+="${tools:+ or }\`${name}\`"
    done

    local message
    message="Use ${tools} on the \`${server}\` MCP server instead!"
    message+=$'\n\n'"Bad command detected: ${COMMAND}"
    message+=$'\n\n'"${description}"

    if [[ -n "$ENVIRONMENT" ]]; then
        message+=$'\n\n'"MCP tools handle the '${ENVIRONMENT}' environment and project configuration automatically."
    else
        message+=$'\n\n'"MCP tools handle environment detection (native/docker/docker-compose/vagrant/ddev) and directory context automatically."
    fi

    printf '%s\n' "$message" >&2
    jq -n --arg msg "$message" '{permission: "deny", user_message: $msg, agent_message: $msg}'
    exit 2
}
