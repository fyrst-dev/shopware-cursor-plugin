#!/usr/bin/env bash
# SessionStart hook: inject directive to run ChunkHound operations
# sequentially across subagents. Reads the static prompt from hooks/prompts/
# and emits it as JSON additionalContext.
set -euo pipefail

cat > /dev/null  # drain stdin

HOOK_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROMPT_FILE="${HOOK_DIR}/prompts/sequential-chunkhound-directives.md"

[[ ! -f "${PROMPT_FILE}" ]] && exit 0

context=$(cat "${PROMPT_FILE}")
json_context=$(printf '%s' "${context}" | jq -Rs '.')

cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": ${json_context}
  },
  "additional_context": ${json_context}
}
EOF

exit 0
