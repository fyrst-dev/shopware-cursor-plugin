#!/usr/bin/env bats
# bats file_tags=shopware-env,session-start
bats_require_minimum_version 1.11.0

load 'test_helper/common_setup'

@test "session-start: outputs additional_context with lifecycle tool directives" {
    run bash "${PLUGIN_DIR}/hooks/scripts/session-start.sh" < /dev/null
    assert_success

    local context
    context=$(printf '%s' "$output" | jq -r '.additional_context')

    assert [ -n "$context" ]
    echo "$output" | jq -e '.additional_context | type == "string"' >/dev/null
    assert_regex "$context" "install_dependencies"
    assert_regex "$context" "database_install"
    assert_regex "$context" "plugin_create"
}
