#!/bin/bash
# Cursor hook: Worktree Project-Root Directives
# ================================================================
# After a worktree switch — `git worktree add` / `git worktree remove`
# via beforeShellExecution, or an EnterWorktree / ExitWorktree-shaped
# payload — reminds the session to repoint the three dev-tooling MCP
# servers. Each server is a separate process holding its own sticky
# project root, so one set_project_root call never reaches the other two.
#
# Exit codes:
#   0 - always; input this hook cannot use leaves the session untouched

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

INPUT=$(cat)

# One jq process for the whole input. Every subprocess counts against the hook
# timeout, and this hook has no reason to spend more than one.
#
# The separator is the ASCII unit separator rather than a tab: a tab is an IFS
# whitespace character, so bash collapses a run of them into one delimiter and
# drops leading ones — an absent "worktreePath" would then shift "cwd" into its
# variable and the fallback would look like it never fired. \x1f is not IFS
# whitespace, so every empty field survives as an empty field.
#
# tool_response is type-tested before it is indexed: a tool that answers with a
# string rather than an object would otherwise abort the whole filter, and the
# hook would go quiet on exactly the shape change the diagnostic below exists to
# surface.
TOOL_NAME=""
RESPONSE_PATH=""
CWD_PATH=""
COMMAND=""
IFS=$'\x1f' read -r TOOL_NAME RESPONSE_PATH CWD_PATH COMMAND < <(
    printf '%s' "$INPUT" | jq -r '[
        (.tool_name // ""),
        (if (.tool_response | type) == "object" then (.tool_response.worktreePath // "") else "" end),
        (.cwd // ""),
        (.command // .tool_input.command // "")
    ] | join("")' 2>/dev/null
) || true

SERVERS="php-tooling, js-admin-tooling and js-storefront-tooling"

# _emit_enter_message <worktree-path>
# Builds the enter directive, inspecting .git for an absolute pointer when the
# path already exists (a structured payload after the worktree was created).
# A beforeShellExecution `git worktree add` path usually does not exist yet,
# so the repair hint is omitted there and the session still gets the reminder.
_emit_enter_message() {
    local worktree_path="$1"
    local message gitdir_line

    if [[ -z "$worktree_path" ]]; then
        printf '%s' "dev-tooling worktree hook: the worktree switch carried no worktree path — neither \"tool_response.worktreePath\" nor \"cwd\" held one — so this reminder cannot name the directory. The dev-tooling MCP servers ${SERVERS} each still target the root they were launched in; call set_project_root on all three with the worktree path before running any dev-tooling tool."
        return
    fi

    message="Worktree entered: ${worktree_path}. The dev-tooling MCP servers ${SERVERS} each hold their own project root, so call set_project_root with project_root \"${worktree_path}\" on all three before running any dev-tooling tool. Three separate processes, three separate sticky values — one call does not cover the others."

    gitdir_line=""
    if [[ -f "${worktree_path}/.git" ]]; then
        # `read` populates the variable and still returns 1 at EOF on a
        # final line without a trailing newline, so the status must not
        # clear what it read.
        IFS= read -r gitdir_line < "${worktree_path}/.git" || true
        gitdir_line="${gitdir_line%$'\r'}"
    fi
    case "$gitdir_line" in
        "gitdir: /"*)
            message="${message} This worktree's \".git\" file carries an absolute gitdir pointer, which the dev-tooling servers refuse in every environment; relink it first with \`git -c worktree.useRelativePaths=true worktree repair \"${worktree_path}\"\` (needs git 2.48 or newer)."
            ;;
    esac

    message="${message} Confirm the worktree carries the code you mean to test before running tools against it — \`git worktree add\` without a starting point branches from the repository's default branch, not necessarily HEAD."
    printf '%s' "$message"
}

# _parse_git_worktree_add_path <command>
# First path-like operand after `worktree add`, skipping flags and the
# arguments those flags consume. `git worktree add <path> [<commit-ish>]`
# puts the path first; `-b <branch>` and friends sit before it.
_parse_git_worktree_add_path() {
    local cmd="$1"
    local -a words=()
    local i word skip_next=0 seen_add=0

    # shellcheck disable=SC2206  # word-split the command the same way the shell did
    words=($cmd)
    for (( i = 0; i < ${#words[@]}; i++ )); do
        word="${words[${i}]}"
        if [[ "$seen_add" -eq 0 ]]; then
            if [[ "$word" == "add" && "$i" -gt 0 && "${words[$((i - 1))]}" == "worktree" ]]; then
                seen_add=1
            fi
            continue
        fi
        if [[ "$skip_next" -eq 1 ]]; then
            skip_next=0
            continue
        fi
        case "$word" in
            -b|-B|--track|--no-track|--reason)
                skip_next=1
                continue
                ;;
            -*)
                continue
                ;;
            *)
                printf '%s' "$word"
                return
                ;;
        esac
    done
}

ACTION=""
WORKTREE_PATH=""

case "$TOOL_NAME" in
    EnterWorktree)
        ACTION="enter"
        WORKTREE_PATH="$RESPONSE_PATH"
        if [[ -z "$WORKTREE_PATH" ]]; then
            WORKTREE_PATH="$CWD_PATH"
        fi
        ;;
    ExitWorktree)
        ACTION="exit"
        ;;
    *)
        if [[ "$COMMAND" =~ git[[:space:]]+([^[:space:]]+[[:space:]]+)*worktree[[:space:]]+add([[:space:]]|$) ]]; then
            ACTION="enter"
            WORKTREE_PATH="$(_parse_git_worktree_add_path "$COMMAND")"
        elif [[ "$COMMAND" =~ git[[:space:]]+([^[:space:]]+[[:space:]]+)*worktree[[:space:]]+remove([[:space:]]|$) ]]; then
            ACTION="exit"
        fi
        ;;
esac

if [[ -z "$ACTION" ]]; then
    exit 0
fi

case "$ACTION" in
    enter)
        MESSAGE="$(_emit_enter_message "$WORKTREE_PATH")"
        ;;
    exit)
        MESSAGE="Worktree exited. Call set_project_root with no project_root argument on each of the dev-tooling MCP servers ${SERVERS}, so all three return to the root they were launched in. Three separate processes, three separate sticky values — a sticky root left behind names a directory that may no longer exist."
        ;;
    *)
        exit 0
        ;;
esac

emit_additional_context "beforeShellExecution" "$MESSAGE"
exit 0
