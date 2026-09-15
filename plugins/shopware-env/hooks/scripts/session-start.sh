#!/usr/bin/env bash
# SessionStart hook: inject lifecycle tool directives.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"
# Drain stdin so the harness write cannot block on a large payload.
cat > /dev/null

HOOK_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROMPT_FILE="${HOOK_DIR}/prompts/mcp-tool-directives.md"

context=""
if [[ -f "$PROMPT_FILE" ]]; then
    context=$(cat "$PROMPT_FILE")
fi

emit_additional_context "SessionStart" "${context}"
exit 0
