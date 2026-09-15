#!/usr/bin/env bats
# bats file_tags=dev-tooling,cursor
bats_require_minimum_version 1.11.0

load 'test_helper/common_setup'

CONFIG_PREFIX="php-tooling"

# ============================================================================
# Cursor beforeShellExecution payload ({command} instead of tool_input.command)
# ============================================================================

# bats test_tags=blocking
@test "Cursor payload blocks vendor/bin/phpstan" {
    run_hook_cursor "check-php-tools.sh" "vendor/bin/phpstan analyze src/"
    assert_failure 2
    assert_output --partial "phpstan_analyze"
}

@test "Cursor payload allows unrelated commands" {
    run_hook_cursor "check-php-tools.sh" "composer install"
    assert_success
}

# bats test_tags=config
@test "CURSOR_PROJECT_DIR honors enforce_mcp_tools false" {
    unset CURSOR_PROJECT_DIR
    export CURSOR_PROJECT_DIR="${BATS_TEST_TMPDIR}"
    echo '{"environment": "native", "enforce_mcp_tools": false}' > "${BATS_TEST_TMPDIR}/.mcp-php-tooling.json"
    run_hook_cursor "check-php-tools.sh" "vendor/bin/phpstan analyze"
    assert_success
}

@test "workspace_roots from hook JSON locates project config" {
    unset CURSOR_PROJECT_DIR
    unset CURSOR_PROJECT_DIR
    echo '{"environment": "native", "enforce_mcp_tools": false}' > "${BATS_TEST_TMPDIR}/.mcp-php-tooling.json"
    local payload
    payload=$(jq -cn --arg cmd "vendor/bin/phpstan analyze" --arg root "$BATS_TEST_TMPDIR" \
        '{command: $cmd, workspace_roots: [$root]}')
    run bash -c 'printf "%s" "$1" | bash "$2"' _ "$payload" "${SCRIPTS_DIR}/check-php-tools.sh"
    assert_success
}

@test ".cursor/.mcp-php-tooling.json is consulted" {
    mkdir -p "${BATS_TEST_TMPDIR}/.cursor"
    echo '{"environment": "native", "enforce_mcp_tools": false}' > "${BATS_TEST_TMPDIR}/.cursor/.mcp-php-tooling.json"
    rm -f "${BATS_TEST_TMPDIR}/.mcp-php-tooling.json"
    export CURSOR_PROJECT_DIR="${BATS_TEST_TMPDIR}"
    run_hook "check-php-tools.sh" "vendor/bin/phpstan analyze"
    assert_success
}
