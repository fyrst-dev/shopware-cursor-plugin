#!/bin/bash
#
# validate-cursor-plugins.sh
#
# Validates the Cursor marketplace sidecar against the Claude Code marketplace:
# - .cursor-plugin/marketplace.json exists and lists the same plugin names
# - each plugin has .cursor-plugin/plugin.json
# - Cursor plugin names match the directory / Claude manifest
# - MCP plugins point mcpServers at ./.mcp.json and that file exists
# - hook plugins point hooks at ./hooks/cursor-hooks.json and that file exists
# - test-writing sets rules to [] so the PHPUnit catalog is not loaded as Cursor rules
#
# Usage:
#   ./validate-cursor-plugins.sh
#
# Exit Codes:
#   0 - Cursor marketplace is consistent
#   1 - One or more problems
#   2 - Fatal error

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CLAUDE_MARKETPLACE="$REPO_ROOT/.claude-plugin/marketplace.json"
CURSOR_MARKETPLACE="$REPO_ROOT/.cursor-plugin/marketplace.json"

# shellcheck source=./lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

failed=0

require_file() {
  local path="$1"
  local label="$2"
  if [ ! -f "$path" ]; then
    log_error "$label missing: ${path#"$REPO_ROOT/"}"
    failed=$((failed + 1))
    return 1
  fi
  return 0
}

if [ ! -f "$CLAUDE_MARKETPLACE" ]; then
  log_error "Claude marketplace.json not found"
  exit 2
fi

require_file "$CURSOR_MARKETPLACE" "Cursor marketplace.json" || exit 2

if ! jq -e '.name and .owner.name and .plugins' "$CURSOR_MARKETPLACE" >/dev/null; then
  log_error "Cursor marketplace.json is missing name, owner.name, or plugins"
  exit 1
fi

claude_names=$(jq -r '.plugins[].name' "$CLAUDE_MARKETPLACE" | sort)
cursor_names=$(jq -r '.plugins[].name' "$CURSOR_MARKETPLACE" | sort)

if [ "$claude_names" != "$cursor_names" ]; then
  log_error "Cursor marketplace plugin names do not match Claude marketplace"
  log_info "Claude: $(echo "$claude_names" | tr '\n' ' ')"
  log_info "Cursor: $(echo "$cursor_names" | tr '\n' ' ')"
  failed=$((failed + 1))
fi

while IFS= read -r plugin_name; do
  [ -z "$plugin_name" ] && continue
  source_path=$(jq -r --arg name "$plugin_name" '.plugins[] | select(.name == $name) | .source // empty' "$CURSOR_MARKETPLACE")
  plugin_dir="$REPO_ROOT/${source_path#./}"
  cursor_json="${plugin_dir}/.cursor-plugin/plugin.json"
  claude_json="${plugin_dir}/.claude-plugin/plugin.json"

  log_info "Checking $plugin_name"

  if ! require_file "$cursor_json" "Cursor plugin.json"; then
    continue
  fi
  if ! require_file "$claude_json" "Claude plugin.json"; then
    continue
  fi

  cursor_name=$(jq -r '.name // empty' "$cursor_json")
  if [ "$cursor_name" != "$plugin_name" ]; then
    log_error "$plugin_name: Cursor plugin.json name '$cursor_name' does not match marketplace entry"
    failed=$((failed + 1))
  fi

  mcp_path=$(jq -r '.mcpServers // empty' "$cursor_json")
  if [ -n "$mcp_path" ]; then
    mcp_file="${plugin_dir}/${mcp_path#./}"
    require_file "$mcp_file" "$plugin_name mcpServers" || true
  elif [ -f "${plugin_dir}/.mcp.json" ]; then
    log_error "$plugin_name: has .mcp.json but Cursor plugin.json does not set mcpServers"
    failed=$((failed + 1))
  fi

  hooks_path=$(jq -r '.hooks // empty' "$cursor_json")
  if [ -n "$hooks_path" ]; then
    hooks_file="${plugin_dir}/${hooks_path#./}"
    if require_file "$hooks_file" "$plugin_name hooks"; then
      if ! jq -e '.hooks | type == "object"' "$hooks_file" >/dev/null; then
        log_error "$plugin_name: $hooks_path is not a Cursor hooks object"
        failed=$((failed + 1))
      fi
      pascal=$(jq -r '.hooks | keys[]' "$hooks_file" | grep -E '^[A-Z]' || true)
      if [ -n "$pascal" ]; then
        log_error "$plugin_name: Cursor hooks file still uses Claude PascalCase events: $pascal"
        failed=$((failed + 1))
      fi
    fi
  elif [ -f "${plugin_dir}/hooks/hooks.json" ]; then
    log_error "$plugin_name: has Claude hooks.json but Cursor plugin.json does not set hooks"
    failed=$((failed + 1))
  fi

  if [ "$plugin_name" = "test-writing" ]; then
    rules_type=$(jq -r '.rules | type' "$cursor_json")
    rules_len=$(jq -r 'if (.rules | type) == "array" then (.rules | length) else -1 end' "$cursor_json")
    if [ "$rules_type" != "array" ] || [ "$rules_len" != "0" ]; then
      log_error "test-writing: Cursor plugin.json must set \"rules\": [] so the PHPUnit catalog is not loaded as Cursor rules"
      failed=$((failed + 1))
    fi
  fi
done <<< "$(jq -r '.plugins[].name' "$CURSOR_MARKETPLACE")"

if [ "$failed" -eq 0 ]; then
  log_success "Cursor marketplace is consistent with the Claude marketplace"
  exit 0
fi

log_error "$failed Cursor marketplace check(s) failed"
exit 1
