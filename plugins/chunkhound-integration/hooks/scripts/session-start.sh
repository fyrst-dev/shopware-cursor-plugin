#!/usr/bin/env bash
# sessionStart hook: inject directive to run ChunkHound operations
# sequentially across subagents.
set -euo pipefail

# Drain stdin so the harness write cannot block on a large payload.
cat > /dev/null

HOOK_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROMPT_FILE="${HOOK_DIR}/prompts/sequential-chunkhound-directives.md"

[[ ! -f "${PROMPT_FILE}" ]] && exit 0

context=$(cat "${PROMPT_FILE}")
json_context=$(printf '%s' "${context}" | jq -Rs '.')

cat <<EOF
{
  "additional_context": ${json_context}
}
EOF

exit 0
