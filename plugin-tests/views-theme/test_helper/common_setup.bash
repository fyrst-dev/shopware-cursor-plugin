#!/bin/bash
# Test fixtures for views-theme scripts

load "${BATS_TEST_DIRNAME}/../test_helper/common_setup"

PLUGIN_DIR="${REPO_ROOT}/plugins/views-theme"
SCRIPTS_DIR="${PLUGIN_DIR}/scripts"

make_docs_tree() {
    local root="$1"
    mkdir -p "${root}/conventions"
    printf '%s\n' "# Hard rules" > "${root}/conventions/hard-rules.md"
}
