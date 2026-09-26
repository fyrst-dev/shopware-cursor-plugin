#!/usr/bin/env bats
# bats file_tags=views-theme,docs
bats_require_minimum_version 1.11.0

load 'test_helper/common_setup'

# bats test_tags=paths
@test "refresh-docs copies a local source tree and writes the pin" {
    local src="${BATS_TEST_TMPDIR}/views-theme"
    local plugin="${BATS_TEST_TMPDIR}/plugin"
    mkdir -p "${src}" "${plugin}/references"
    make_docs_tree "${src}/docs"
    printf '%s\n' "from-source" > "${src}/docs/conventions/hard-rules.md"
    printf '%s\n' "# index" > "${src}/docs/README.md"

    run bash "${SCRIPTS_DIR}/refresh-docs.sh" --source "${src}" --sha "deadbeef" --plugin-root "${plugin}"
    assert_success
    [[ -f "${plugin}/references/docs/conventions/hard-rules.md" ]]
    grep -q "from-source" "${plugin}/references/docs/conventions/hard-rules.md"
    grep -q "deadbeef" "${plugin}/references/docs.sha"
}

# bats test_tags=paths
@test "refresh-docs refuses a source without hard-rules" {
    local src="${BATS_TEST_TMPDIR}/empty"
    mkdir -p "${src}/docs"

    run bash "${SCRIPTS_DIR}/refresh-docs.sh" --source "${src}" --plugin-root "${BATS_TEST_TMPDIR}/plugin"
    assert_failure 1
    [[ ! -d "${BATS_TEST_TMPDIR}/plugin/references/docs" ]]
}

# bats test_tags=paths
@test "refresh-docs records git HEAD when the source is a repo" {
    local src="${BATS_TEST_TMPDIR}/repo"
    local plugin="${BATS_TEST_TMPDIR}/plugin-git"
    mkdir -p "${src}"
    make_docs_tree "${src}/docs"
    git init -b main "${src}" >/dev/null
    git -C "${src}" config user.email "test@example.com"
    git -C "${src}" config user.name "Test"
    git -C "${src}" config commit.gpgsign false
    git -C "${src}" add docs
    git -C "${src}" commit -m "docs" >/dev/null
    local head
    head="$(git -C "${src}" rev-parse HEAD)"

    run bash "${SCRIPTS_DIR}/refresh-docs.sh" --source "${src}" --plugin-root "${plugin}"
    assert_success
    [[ "$(tr -d '[:space:]' < "${plugin}/references/docs.sha")" == "${head}" ]]
}
