#!/bin/bash
#
# validate-cursor-plugins.sh
#
# Validates the Cursor-only marketplace:
# - .cursor-plugin/marketplace.json exists and lists plugins
# - each plugin has .cursor-plugin/plugin.json
# - no Claude Code marketplace or plugin manifests remain
# - MCP plugins ship mcp.json (default discovery) with CURSOR_PLUGIN_ROOT
# - hook plugins ship hooks/hooks.json with camelCase Cursor events
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

if [ -e "$REPO_ROOT/.claude-plugin" ]; then
  log_error "Claude marketplace directory must not exist: .claude-plugin/"
  failed=$((failed + 1))
fi

require_file "$CURSOR_MARKETPLACE" "Cursor marketplace.json" || exit 2

if ! jq -e '.name and .owner.name and .plugins' "$CURSOR_MARKETPLACE" >/dev/null; then
  log_error "Cursor marketplace.json is missing name, owner.name, or plugins"
  exit 1
fi

while IFS= read -r plugin_name; do
  [ -z "$plugin_name" ] && continue
  source_path=$(jq -r --arg name "$plugin_name" '.plugins[] | select(.name == $name) | .source // empty' "$CURSOR_MARKETPLACE")
  plugin_dir="$REPO_ROOT/${source_path#./}"
  cursor_json="${plugin_dir}/.cursor-plugin/plugin.json"

  log_info "Checking $plugin_name"

  if [ -e "${plugin_dir}/.claude-plugin" ]; then
    log_error "$plugin_name: Claude plugin directory must not exist: ${plugin_dir#"$REPO_ROOT/"}/.claude-plugin/"
    failed=$((failed + 1))
  fi

  if [ -f "${plugin_dir}/.mcp.json" ]; then
    log_error "$plugin_name: Claude .mcp.json must not exist; use mcp.json"
    failed=$((failed + 1))
  fi

  if [ -f "${plugin_dir}/hooks/cursor-hooks.json" ]; then
    log_error "$plugin_name: hooks/cursor-hooks.json is a dual-compat leftover; use hooks/hooks.json"
    failed=$((failed + 1))
  fi

  if ! require_file "$cursor_json" "Cursor plugin.json"; then
    continue
  fi

  cursor_name=$(jq -r '.name // empty' "$cursor_json")
  if [ "$cursor_name" != "$plugin_name" ]; then
    log_error "$plugin_name: Cursor plugin.json name '$cursor_name' does not match marketplace entry"
    failed=$((failed + 1))
  fi

  if jq -e '.mcpServers != null' "$cursor_json" >/dev/null; then
    log_error "$plugin_name: plugin.json should omit mcpServers and use default mcp.json discovery"
    failed=$((failed + 1))
  fi

  if jq -e '.hooks != null' "$cursor_json" >/dev/null; then
    log_error "$plugin_name: plugin.json should omit hooks and use default hooks/hooks.json discovery"
    failed=$((failed + 1))
  fi

  if [ -f "${plugin_dir}/mcp.json" ]; then
    if grep -q 'CLAUDE_PLUGIN_ROOT' "${plugin_dir}/mcp.json"; then
      log_error "$plugin_name: mcp.json still references CLAUDE_PLUGIN_ROOT"
      failed=$((failed + 1))
    fi
    if ! jq -e '.mcpServers | type == "object"' "${plugin_dir}/mcp.json" >/dev/null; then
      log_error "$plugin_name: mcp.json is missing an mcpServers object"
      failed=$((failed + 1))
    fi
  fi

  if [ -f "${plugin_dir}/hooks/hooks.json" ]; then
    if ! jq -e '.hooks | type == "object"' "${plugin_dir}/hooks/hooks.json" >/dev/null; then
      log_error "$plugin_name: hooks/hooks.json is not a Cursor hooks object"
      failed=$((failed + 1))
    fi
    pascal=$(jq -r '.hooks | keys[]' "${plugin_dir}/hooks/hooks.json" | grep -E '^[A-Z]' || true)
    if [ -n "$pascal" ]; then
      log_error "$plugin_name: hooks/hooks.json still uses Claude PascalCase events: $pascal"
      failed=$((failed + 1))
    fi
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
  log_success "Cursor marketplace is consistent"
  exit 0
fi

log_error "$failed Cursor marketplace check(s) failed"
exit 1
