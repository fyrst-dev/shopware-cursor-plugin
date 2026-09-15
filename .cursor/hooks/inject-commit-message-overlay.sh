#!/usr/bin/env bash
# Inject the marketplace commit-message overlay when a commit-message skill
# or slash command is in play. Fail open: never block the agent loop.
set -euo pipefail

input=$(cat)
repo="${CURSOR_PROJECT_DIR:-${PWD}}"
overlay="${repo}/.cursor/hooks/writing-commit-messages.md"

if [ ! -f "$overlay" ]; then
  exit 0
fi

if printf '%s' "$input" | jq -e '
  (.tool_input.skill // "" | test("writing-commit-messages|commit-message-writer"))
  or (.tool_name // "" | test("writing-commit-messages|commit-message-writer"; "i"))
  or (.prompt // "" | test("writing-commit-messages|commit-message-writer"))
' >/dev/null 2>&1; then
  jq -n --rawfile ctx "$overlay" '{additional_context: $ctx}'
fi

exit 0
