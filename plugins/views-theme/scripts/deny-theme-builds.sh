#!/usr/bin/env bash
# Cursor hook: deny ViewsTheme / storefront asset builds.
# ========================================================
# Agents must never compile or watch theme, storefront, JS, or CSS.
# Humans rebuild. See conventions/agent-workflow.md.
#
# Exit codes:
#   0 - Command allowed
#   2 - Command blocked

set -euo pipefail

COMMAND=""

resolve_command() {
    local input
    input=$(cat)

    if ! command -v jq >/dev/null 2>&1; then
        exit 0
    fi

    COMMAND=$(printf '%s' "$input" | jq -r '.command // .tool_input.command // empty' 2>/dev/null || true)
    if [[ -z "$COMMAND" ]]; then
        exit 0
    fi
}

deny_build() {
    local message

    message="$(cat <<EOF
Theme and asset builds are human-only.

Bad command detected: ${COMMAND}

Do not run theme:compile, storefront/JS/CSS build, or watch. Leave rebuilds to the human.
See ViewsTheme conventions/agent-workflow.md.
EOF
)"

    printf '%s\n' "$message" >&2
    jq -n --arg msg "$message" '{permission: "deny", user_message: $msg, agent_message: $msg}'
    exit 2
}

# Matches the forbidden list in conventions/agent-workflow.md, including
# wrapped forms (docker exec, ddev, shopware-cli).
resolve_command

if printf '%s' "$COMMAND" | grep -qE \
    'theme:(compile|refresh)\b|\bbuild-storefront(\.sh)?\b|\bbuild-js\.sh\b|make[[:space:]]+(build-storefront|dev-storefront)\b|composer[[:space:]]+build:|composer[[:space:]]+storefront:|(npm|yarn|pnpm)([[:space:]]+run)?[[:space:]]+(build|watch)(:|[[:space:]]|$)|shopware-cli[[:space:]]+(project[[:space:]]+)?storefront-build\b'; then
    deny_build
fi

exit 0
