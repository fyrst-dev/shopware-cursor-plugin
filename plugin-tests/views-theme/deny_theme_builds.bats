#!/usr/bin/env bats
# bats file_tags=views-theme,hooks
bats_require_minimum_version 1.11.0

load 'test_helper/common_setup'

deny_blocks() { assert_hook_blocks "deny-theme-builds.sh" "$1" "human-only"; }

# bats test_tags=blocking
bats_test_function --description "blocks bin/console theme:compile" \
    -- deny_blocks "bin/console theme:compile"
# bats test_tags=blocking
bats_test_function --description "blocks php bin/console theme:refresh" \
    -- deny_blocks "php bin/console theme:refresh --active-only"
# bats test_tags=blocking
bats_test_function --description "blocks make build-storefront" \
    -- deny_blocks "make build-storefront"
# bats test_tags=blocking
bats_test_function --description "blocks make dev-storefront" \
    -- deny_blocks "make dev-storefront"
# bats test_tags=blocking
bats_test_function --description "blocks bin/build-storefront.sh" \
    -- deny_blocks "./bin/build-storefront.sh"
# bats test_tags=blocking
bats_test_function --description "blocks composer build:js:storefront" \
    -- deny_blocks "composer build:js:storefront"
# bats test_tags=blocking
bats_test_function --description "blocks composer storefront:dev-server" \
    -- deny_blocks "composer storefront:dev-server"
# bats test_tags=blocking
bats_test_function --description "blocks npm run build:css" \
    -- deny_blocks "npm run build:css"
# bats test_tags=blocking
bats_test_function --description "blocks npm run watch" \
    -- deny_blocks "npm run watch"
# bats test_tags=blocking
bats_test_function --description "blocks yarn build" \
    -- deny_blocks "yarn build"
# bats test_tags=blocking
bats_test_function --description "blocks shopware-cli storefront-build" \
    -- deny_blocks "shopware-cli project storefront-build"
# bats test_tags=blocking
bats_test_function --description "blocks theme:compile through ddev exec" \
    -- deny_blocks "ddev exec bin/console theme:compile"

# bats test_tags=blocking
@test "Cursor payload blocks theme:compile" {
    run_hook_cursor "deny-theme-builds.sh" "bin/console theme:compile"
    assert_failure 2
    assert_output --partial "human-only"
}

# bats test_tags=allow
@test "allows cache:clear" {
    run_hook "deny-theme-builds.sh" "bin/console cache:clear"
    assert_success
    refute_output --partial "human-only"
}

# bats test_tags=allow
@test "allows plugin:refresh" {
    run_hook "deny-theme-builds.sh" "bin/console plugin:refresh"
    assert_success
}

# bats test_tags=allow
@test "allows npm run lint" {
    run_hook "deny-theme-builds.sh" "npm run lint"
    assert_success
}

# bats test_tags=allow
@test "allows git status" {
    run_hook_cursor "deny-theme-builds.sh" "git status"
    assert_success
    refute_output --partial "permission"
}
