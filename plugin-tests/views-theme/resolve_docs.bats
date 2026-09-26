#!/usr/bin/env bats
# bats file_tags=views-theme,docs
bats_require_minimum_version 1.11.0

load 'test_helper/common_setup'

resolve_docs() {
    run bash "${SCRIPTS_DIR}/resolve-docs.sh" --plugin-root "${PLUGIN_DIR}" "$@"
}

# bats test_tags=paths
@test "falls back to the plugin snapshot" {
    resolve_docs --project-dir "${BATS_TEST_TMPDIR}" --kind
    assert_success
    assert_output --partial "${PLUGIN_DIR}/references/docs"
    [[ "${output}" == *"/references/docs" ]]
}

# bats test_tags=paths
@test "prefers a views-theme workspace" {
    local root="${BATS_TEST_TMPDIR}/views-theme"
    mkdir -p "${root}"
    printf '%s\n' '{"name": "fyrst/views-theme"}' > "${root}/composer.json"
    make_docs_tree "${root}/docs"
    printf '%s\n' "workspace-copy" > "${root}/docs/conventions/hard-rules.md"

    resolve_docs --project-dir "${root}" --kind
    assert_success
    assert_output --partial "${root}/docs"
}

# bats test_tags=paths
@test "prefers custom/static-plugins/ViewsTheme/docs" {
    local shop="${BATS_TEST_TMPDIR}/shop"
    mkdir -p "${shop}/custom/plugins/ChildTheme"
    printf '%s\n' '{"name": "acme/child-theme"}' > "${shop}/custom/plugins/ChildTheme/composer.json"
    make_docs_tree "${shop}/custom/static-plugins/ViewsTheme/docs"
    printf '%s\n' "static-copy" > "${shop}/custom/static-plugins/ViewsTheme/docs/conventions/hard-rules.md"

    resolve_docs --project-dir "${shop}/custom/plugins/ChildTheme" --kind
    assert_success
    assert_output --partial "${shop}/custom/static-plugins/ViewsTheme/docs"
}

# bats test_tags=paths
@test "prefers vendor/fyrst/views-theme/docs" {
    local shop="${BATS_TEST_TMPDIR}/vendor-shop"
    mkdir -p "${shop}/custom/plugins/ChildTheme"
    make_docs_tree "${shop}/vendor/fyrst/views-theme/docs"

    resolve_docs --project-dir "${shop}/custom/plugins/ChildTheme"
    assert_success
    assert_output --partial "${shop}/vendor/fyrst/views-theme/docs"
}

# bats test_tags=priority
@test "workspace docs beat vendor docs" {
    local root="${BATS_TEST_TMPDIR}/both"
    mkdir -p "${root}"
    printf '%s\n' '{"name": "fyrst/views-theme"}' > "${root}/composer.json"
    make_docs_tree "${root}/docs"
    make_docs_tree "${root}/vendor/fyrst/views-theme/docs"
    printf '%s\n' "workspace" > "${root}/docs/conventions/hard-rules.md"
    printf '%s\n' "vendor" > "${root}/vendor/fyrst/views-theme/docs/conventions/hard-rules.md"

    resolve_docs --project-dir "${root}"
    assert_success
    assert_output --partial "${root}/docs"
    refute_output --partial "/vendor/"
}

# bats test_tags=paths
@test "prints kind on stderr when --kind is set" {
    run --separate-stderr bash "${SCRIPTS_DIR}/resolve-docs.sh" --plugin-root "${PLUGIN_DIR}" --project-dir "${BATS_TEST_TMPDIR}" --kind
    assert_success
    [[ "${stderr}" == "snapshot" ]]
    [[ "${output}" == *"/references/docs" ]]
}
