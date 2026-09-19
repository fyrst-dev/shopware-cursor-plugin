@README.md

## 🗂️ Directory & File Structure

```
plugins/dev-tooling/
├── README.md                           # User documentation (usage, configuration, troubleshooting)
├── SETUP.md                            # Setup walkthrough consumed by the plugin-setup plugin
├── docs/                               # User-facing documentation
│   ├── configuration.md                # Config files, environments, troubleshooting
│   ├── mcp-enforcement.md              # Hook enforcement, blocked commands, plugin integration
│   └── reference.md                    # Full tool parameter docs and examples (30 tools across 3 servers)
├── AGENTS.md                           # LLM navigation guide (this file)
├── CHANGELOG.md                        # Version history
├── LICENSE                             # MIT license
├── mcp.json                            # MCP server registration (php-tooling, js-admin-tooling, js-storefront-tooling)
│
├── agents/                             # AGENTS (dev-tooling check/fix executor)
│   └── dev-tooling-runner.md           # Lean runner; given targets + checks/fixes, runs them and returns a pass/fail report (haiku)
│
├── hooks/                              # HOOKS (MCP tool enforcement)
│   ├── hooks.json                      # Hook configuration (sessionStart + beforeShellExecution + postToolUse)
│   ├── prompts/
│   │   └── mcp-tool-directives.md      # sessionStart prompt: MCP tool listing and usage rules
│   └── scripts/
│       ├── session-start.sh            # sessionStart hook: reads prompt file, checks enforcement, outputs JSON
│       ├── check-php-tools.sh          # Blocks PHPStan, ECS, PHPUnit, Rector, bin/console bash commands
│       ├── check-js-admin-tools.sh     # Blocks Administration npm/npx commands (ESLint, Stylelint, Prettier, Jest, TSC, Vite)
│       ├── check-js-storefront-tools.sh # Blocks Storefront npm/npx/composer commands (ESLint, Stylelint, Jest, Vitest, ludtwig, Webpack)
│       ├── check-phpstan-baseline.sh   # postToolUse hook: warns when analyzed paths appear in phpstan-baseline.neon
│       ├── worktree-directives.sh      # beforeShellExecution hook on git worktree add/remove: set_project_root reminder; on enter also the repair command for an absolute gitdir pointer when the path already exists
│       └── lib/
│           └── common.sh               # Shared: parse_hook_input(), load_mcp_config(), block_tool()
│
├── shared/                             # SHARED FRAMEWORK (language-agnostic)
│   ├── mcpserver_core.sh              # JSON-RPC 2.0 protocol handler + validate_tool_arguments()
│   ├── config.sh                      # Config discovery & merging (parameterized via CONFIG_PREFIX)
│   ├── environment.sh                 # Environment detection, PHP & JS command wrapping, argument quoting, path guards, environment-side path mapping, noise filtering
│   ├── worktree.sh                    # Per-call root resolution and worktree validation: worktree_enter(), set_project_root, cwd (dev-tooling-owned, not templated)
│   ├── server_run.sh                  # Shared server tail: run_mcp_server() call and why it is not isolated in a subshell (dev-tooling-owned, not templated)
│   ├── scope.sh                       # Scope resolution: resolve_scope(), scope_get_tool_field()
│   ├── docker-compose.sh              # Docker Compose environment: call-time resolution of container/workdir
│   └── mcp-js-tooling.schema.json     # JSON Schema for .mcp-js-tooling.json (shared by JS servers)
│
├── mcp-server-php/                     # PHP TOOLS MCP SERVER
│   ├── server.sh                      # Entry point - sets CONFIG_PREFIX="php-tooling"
│   ├── config.json                    # Server metadata (name="php-tooling")
│   ├── tools.json                     # PHPStan, ECS, PHPUnit, Console, Rector tool schemas
│   ├── mcp-php-tooling.schema.json    # JSON Schema for .mcp-php-tooling.json
│   └── lib/
│       ├── phpstan.sh                 # tool_phpstan_analyze()
│       ├── ecs.sh                     # tool_ecs_check(), tool_ecs_fix()
│       ├── phpunit.sh                 # tool_phpunit_run()
│       ├── phpunit_coverage.sh        # tool_phpunit_coverage_gaps()
│       ├── rector.sh                  # tool_rector_check(), tool_rector_fix()
│       ├── console.sh                 # tool_console_run(), tool_console_list()
│       └── prepare.sh                 # tool_worktree_prepare() — composer install for a fresh worktree
│
├── mcp-server-js-admin/                   # ADMIN JS TOOLS MCP SERVER
│   ├── server.sh                      # Entry point - sets CONFIG_PREFIX="js-tooling" (shared)
│   ├── config.json                    # Server metadata (name="js-admin-tooling")
│   ├── tools.json                     # ESLint, Stylelint, Prettier, Jest, TSC, lint_all, lint_twig, unit_setup, Vite tools
│   └── lib/
│       ├── eslint.sh                  # tool_eslint_check(), tool_eslint_fix()
│       ├── stylelint.sh               # tool_stylelint_check(), tool_stylelint_fix()
│       ├── prettier.sh                # tool_prettier_check(), tool_prettier_fix()
│       ├── jest.sh                    # tool_jest_run()
│       ├── tsc.sh                     # tool_tsc_check()
│       ├── lint-all.sh                # tool_lint_all(), tool_lint_twig(), tool_unit_setup()
│       ├── build.sh                   # tool_vite_build()
│       └── prepare.sh                 # tool_worktree_prepare() — npm ci for a fresh worktree
│
└── mcp-server-js-storefront/              # STOREFRONT JS TOOLS MCP SERVER
    ├── server.sh                      # Entry point - sets CONFIG_PREFIX="js-tooling" (shared)
    ├── config.json                    # Server metadata (name="js-storefront-tooling")
    ├── tools.json                     # ESLint, Stylelint, Jest, Vitest, ludtwig, Webpack tools
    └── lib/
        ├── eslint.sh                  # tool_eslint_check(), tool_eslint_fix() — routes paths to eslint:app / eslint:components
        ├── stylelint.sh               # tool_stylelint_check(), tool_stylelint_fix()
        ├── jest.sh                    # tool_jest_run() — app/storefront package suite only
        ├── vitest.sh                  # tool_vitest_run() — views/components component suite
        ├── ludtwig.sh                 # tool_ludtwig_check(), tool_ludtwig_fix()
        ├── build.sh                   # tool_webpack_build()
        └── prepare.sh                 # tool_worktree_prepare() — npm ci for a fresh worktree
```

## 🧱 Component Overview

This plugin provides:
- **Three MCP Servers** via `mcp.json`:
  - `php-tooling` - PHP linting/testing tools
  - `js-admin-tooling` - Administration JavaScript tools (Vue 3/Vite)
  - `js-storefront-tooling` - Storefront JavaScript tools (vanilla JS/Webpack): `eslint_check`, `eslint_fix`, `stylelint_check`, `stylelint_fix`, `jest_run`, `vitest_run`, `ludtwig_check`, `ludtwig_fix`, `webpack_build`, `worktree_prepare`
- **Subagent** via `agents/`:
  - `dev-tooling-runner` — executor for dev-tooling checks (and rule-driven fixes); run it to keep verbose output out of the conversation and get back a lean pass/fail report (runs on haiku); see [Agents](#agents)
- **sessionStart Hook** via `hooks/hooks.json`:
  - Injects MCP tool directives into conversation context at session start
  - Prompt maintained in `hooks/prompts/mcp-tool-directives.md`
  - Outputs JSON `{ "additional_context": ... }`
  - Also steers the active session to delegate heavy dev-tool runs to `dev-tooling-runner`
- **beforeShellExecution Hooks** via `hooks/hooks.json`:
  - Blocks bash commands that should use MCP tools instead
  - PHP hook: blocks PHPStan, ECS, PHPUnit, Rector, bin/console
  - Admin JS hook: blocks ESLint, Stylelint, Prettier, Jest, TSC, lint_all/lint_twig, Vite commands
  - Storefront JS hook: blocks ESLint, Stylelint, Jest, Vitest, ludtwig, Webpack commands
  - `worktree-directives.sh` fires on `git worktree add` / `git worktree remove` and reminds the session to call `set_project_root` on all three servers; on enter it additionally names the repair command when the worktree's `.git` file already carries an absolute gitdir pointer
- **postToolUse Hook** via `hooks/hooks.json`:
  - `check-phpstan-baseline.sh` warns when a targeted `phpstan_analyze` run covers paths listed in `phpstan-baseline.neon` (or `.php`)
  - Ignores `enforce_mcp_tools` and always runs
- The sessionStart directive and the MCP-enforcement beforeShellExecution hooks are configurable via `enforce_mcp_tools: false` in config files; `worktree-directives.sh` and the postToolUse baseline check ignore the flag
- **Shared Framework** in `shared/` - reusable across all servers

## 🤖 Agents

### dev-tooling-runner

**Purpose**: Executor for Shopware dev-tooling checks and rule-driven fixes. Given explicit targets + check/fix-kinds, it maps each target to its toolchain by path, runs the matching MCP tools, and returns a lean (~1–2k token) pass/fail report. Invoke it via Cursor `Task` to keep verbose tool output out of the conversation. Unlike the `test-writing` agents, it is meant to be invoked directly.

**Scope ownership**: none. It acts only on the targets and checks it is given — no git diffing, file discovery, or blast-radius guessing — and never decides on its own to fix something it was told only to check. Deciding what to check (paths + any affected tests) and whether to apply a fix is the caller's job.

**Bounded mutation, not freeform editing**: the rule-driven fixers (`ecs_fix`, `rector_fix`, `eslint_fix`, `stylelint_fix`, `prettier_fix`, `ludtwig_fix`) are available — the agent does not choose *what* changes, the linter ruleset does. It has no `Edit`/`Write`, so it cannot freeform-edit; its only file changes come from those deterministic fixers. Do not call `console_run`, `console_list`, `unit_setup`, `worktree_prepare`, or `set_project_root`. `worktree_prepare` rewrites `vendor/`/`node_modules` — a setup mutation outside the fixer boundary, and one the dependency refusals would otherwise steer the agent into. `set_project_root` is sticky and would redirect every later tool call in the session that spawned it; the agent still reaches a worktree by passing `project_root` on the individual call. No `Bash`/`Glob`/`Grep` — scope discovery is the caller's job; `Read` is the only non-MCP tool, for quoting a flagged line.

**Model**: Haiku | **Mutation boundary**: documented in the agent body — no `Edit`/`Write`, no `console_*` / `unit_setup` / `worktree_prepare` / `set_project_root`

**Tools**: `Read` plus the short MCP tool names on `php-tooling`, `js-admin-tooling`, and `js-storefront-tooling` (never `console_run` / `console_list` / `unit_setup` / `worktree_prepare` / `set_project_root`)

## 🏗️ Architecture

### Shared Framework Pattern

All MCP servers source shared framework files:
```bash
source "${SHARED_DIR}/mcpserver_core.sh"  # JSON-RPC protocol
source "${SHARED_DIR}/config.sh"           # Config discovery
source "${SHARED_DIR}/environment.sh"      # Command execution
```

### CONFIG_PREFIX Parameterization

The `config.sh` module uses `CONFIG_PREFIX` to determine:
- Config file name: `.mcp-${CONFIG_PREFIX}.json`
- Environment variable: `MCP_${PREFIX}_CONFIG` (uppercased, hyphens→underscores)

```bash
# In mcp-server-php/server.sh
CONFIG_PREFIX="php-tooling"
source "${SHARED_DIR}/config.sh"
# Looks for: .mcp-php-tooling.json, MCP_PHP_TOOLING_CONFIG

# In mcp-server-js-admin/server.sh
CONFIG_PREFIX="js-tooling"
JS_CONTEXT="admin"
source "${SHARED_DIR}/config.sh"
# Looks for: .mcp-js-tooling.json, MCP_JS_TOOLING_CONFIG
# JS_CONTEXT determines workdir: src/Administration/Resources/app/administration

# In mcp-server-js-storefront/server.sh
CONFIG_PREFIX="js-tooling"
JS_CONTEXT="storefront"
source "${SHARED_DIR}/config.sh"
# Looks for: .mcp-js-tooling.json, MCP_JS_TOOLING_CONFIG
# JS_CONTEXT determines workdir: src/Storefront/Resources/app/storefront
```

### Protocol Flow

```
Cursor → stdin → server.sh → mcpserver_core.sh → tool_* function
                                                           ↓
Cursor ← stdout ← JSON-RPC response ← formatted output
```

### Tool Dispatch Convention

Tools in `tools.json` map to bash functions with `tool_` prefix:

```bash
# Admin/Storefront servers - hardcoded npm script names from Shopware package.json.
# Two routes per tool, selected by whether the caller supplied paths: appending
# to the aggregate script only ever widens it (npm appends `--` args to the end
# of the whole script body), so a path-scoped call is routed at a separate
# target-less base script instead, and refuses when that script is unusable.
tool_eslint_check() {
    local args="$1"
    # No paths: aggregate script's own targets stay authoritative.
    local cmd="npm run lint -- ..."  # Admin uses "lint", Storefront uses "lint:js"
    # Paths supplied: routed at a target-less base script instead, so the
    # given paths are the ONLY targets (Admin: "lint:debugging"; Storefront:
    # "eslint:app" / "eslint:components", picked per path).
    exec_npm_command "${cmd}"
}
```

### Command Execution

- **PHP tools**: Use `exec_command()` which wraps via `wrap_command()`
- **JS tools**: Use `exec_npm_command()` which wraps via `wrap_npm_command()`

Both handle environment-specific execution (native/docker/docker-compose/vagrant/ddev).

## 🧭 Key Navigation Points

| Task | Primary File | Secondary File | Key Concepts |
|------|--------------|----------------|--------------|
| Add PHP tool | `mcp-server-php/lib/<tool>.sh` | `mcp-server-php/tools.json` | `tool_*()`, `exec_command()` |
| Add Admin JS tool | `mcp-server-js-admin/lib/<tool>.sh` | `mcp-server-js-admin/tools.json` | `tool_*()`, `exec_npm_command()` |
| Add Storefront JS tool | `mcp-server-js-storefront/lib/<tool>.sh` | `mcp-server-js-storefront/tools.json` | `tool_*()`, `exec_npm_command()` |
| Edit sessionStart prompt | `hooks/prompts/mcp-tool-directives.md` | `hooks/scripts/session-start.sh` | Plain markdown, read by script |
| Edit dev-tooling runner agent | `agents/dev-tooling-runner.md` | - | Tool policy in the body (no Edit/Write, no console_*/unit_setup/worktree_prepare/set_project_root), check/fix-kind→tool table, report template |
| Add blocked PHP command | `hooks/scripts/check-php-tools.sh` | - | `block_tool()`, grep pattern |
| Add blocked Admin JS command | `hooks/scripts/check-js-admin-tools.sh` | - | `block_tool()`, `is_admin_context()` |
| Add blocked Storefront JS command | `hooks/scripts/check-js-storefront-tools.sh` | - | `block_tool()`, `is_storefront_context()` |
| Modify shared hook logic | `hooks/scripts/lib/common.sh` | - | `parse_hook_input()`, `load_mcp_config()`, `block_tool()` |
| Disable hook enforcement | `.mcp-*-tooling.json` | - | `enforce_mcp_tools: false` |
| Adjust hook timeout | `hooks/hooks.json` | - | `timeout` field (default: 5s) |
| Add config location | `templates/mcp-shared/config.sh` (edit template, sync per `.cursor/rules/template-sync.mdc`) | - | `CONFIG_LOCATIONS` array |
| Add environment type | `templates/mcp-shared/environment.sh` (edit template, sync per `.cursor/rules/template-sync.mdc`) | - | `wrap_command()`, `wrap_npm_command()` |
| Configure docker-compose | `templates/mcp-shared/docker-compose.sh` (edit template, sync per `.cursor/rules/template-sync.mdc`) | `templates/mcp-shared/environment.sh` | `_compose_*()`, call-time resolution |
| Add noise filter pattern | `templates/mcp-shared/environment.sh` (edit template, sync per `.cursor/rules/template-sync.mdc`) | - | `ENV_NOISE_PATTERNS` array, `_filter_env_noise()` |
| Modify protocol | upstream `shopwareLabs/bash-mcp-sdk` (release pinned in `.mcp-sdk.lock`; never edit `shared/mcpserver_core.sh` in place) | - | `process_request()`, `handle_*()` |
| Update tool schemas | `mcp-server-*/tools.json` | - | JSON Schema Draft 7 |
| Register new server | `mcp.json` | - | `mcpServers` object |

## ✏️ When to Modify What

**Adding a new PHP linting tool:**
1. Create `mcp-server-php/lib/<tool>.sh` with `tool_<name>()`
2. Add tool definition to `mcp-server-php/tools.json`
3. Source in `mcp-server-php/server.sh`
4. Update README.md

**Adding a new Admin JS tool:**
1. Create `mcp-server-js-admin/lib/<tool>.sh` with `tool_<name>()` using hardcoded npm script name
2. Add tool definition to `mcp-server-js-admin/tools.json`
3. Source the file in `mcp-server-js-admin/server.sh`
4. Update README.md

**Adding a new Storefront JS tool:**
1. Create `mcp-server-js-storefront/lib/<tool>.sh` with `tool_<name>()` using hardcoded npm script name
2. Add tool definition to `mcp-server-js-storefront/tools.json`
3. Source the file in `mcp-server-js-storefront/server.sh`
4. Update README.md

**Adding new environment type** (e.g., podman):
1. For complex types (like `docker-compose`), create a separate module in `shared/`
2. Edit `shared/environment.sh` — add case in `_set_workdir_from_config()`, `wrap_command()`, `wrap_npm_command()`
3. Document in README.md

**Adding new config location** (e.g., `.github/`):
1. Add to `CONFIG_LOCATIONS` array in `shared/config.sh`
2. Update README.md

**Adding a third language** (e.g., Python):
1. Create `mcp-server-python/` with same structure
2. Set `CONFIG_PREFIX="python-tooling"` in server.sh
3. Add to `mcp.json` as `python-tooling` server
4. Optionally add `wrap_python_command()` to environment.sh

## 🔗 Integration with Other Plugins

MCP tool names are the short names on each server (`phpstan_analyze`, `eslint_check`, `webpack_build`).

```yaml
# PHP tools
tools: phpstan_analyze, ecs_check

# Admin JS tools
tools: eslint_check, jest_run

# Storefront JS tools
tools: eslint_check, webpack_build
```

## 🧪 Testing

This plugin's own suites are in `plugin-tests/dev-tooling/`:

| Test File                        | Coverage                                                                            |
|----------------------------------|-------------------------------------------------------------------------------------|
| `php_tools.bats`                 | PHP tool blocking (PHPStan, ECS, PHPUnit, Rector, bin/console)                      |
| `js_admin_tools.bats`            | Admin JS tool blocking (ESLint, Stylelint, Prettier, Jest, TSC, Vite)               |
| `js_storefront_tools.bats`       | Storefront JS tool blocking (ESLint, Stylelint, Jest, Vitest, ludtwig, Webpack)     |
| `phpstan_baseline.bats`          | postToolUse baseline-overlap warning                                                |
| `session_start.bats`             | sessionStart directive output and enforcement flags                                 |
| `mcp_tool_console.bats`          | Console tool command construction                                                   |
| `mcp_tool_ecs.bats`              | ECS tool command construction                                                       |
| `mcp_tool_rector.bats`           | Rector tool command construction                                                    |
| `mcp_tool_js_admin.bats`         | Admin JS MCP tool command construction                                              |
| `mcp_tool_js_storefront.bats`    | Storefront JS MCP tool command construction (ESLint routing, Jest, Vitest, ludtwig) |
| `mcp_tool_phpstan.bats`          | PHPStan tool command construction                                                   |
| `mcp_tool_phpunit.bats`          | PHPUnit tool command construction (coverage, config, drivers)                       |
| `mcp_tool_phpunit_coverage.bats` | PHPUnit coverage gap parsing (clover XML, filtering, ranges)                        |
| `tool_schema.bats`               | Every server's `tools.json` refuses an undeclared parameter                          |
| `scope_resolution.bats`          | `resolve_scope()` and scope field lookup                                            |
| `scope_php_tools.bats`           | Scope handling in the PHP MCP tools                                                 |
| `scope_js_tools.bats`            | Scope handling in the JS MCP tools                                                  |
| `scope_session_start.bats`       | Scope surfacing in the sessionStart output                                          |
| `worktree_resolution.bats`       | Worktree resolution, identity, linkage, charset, probe, config, deps, path guard   |
| `worktree_state.bats`            | State file: sticky read-back, reset, a removed root, probe cache, atomic writes    |
| `worktree_hook.bats`             | `worktree-directives.sh`: the Cursor `additional_context` envelope, enter/exit directive text, `git worktree` command payloads, the `.cwd` fallback, the no-path diagnostic, exit 0 on malformed input |
| `worktree_php_tools.bats`        | `phpunit_coverage_gaps`: clover paths relative to the mapped workdir, refused read |
| `worktree_js_tools.bats`         | `project_root` reaching the JS package directory, which the conformance scan does not capture |
| `worktree_conformance.bats`      | Every enumerated `tool_*` function runs in the named worktree and runs nothing against a refused one, with the enumeration reconciled against `tools.json` |

The modules this plugin consumes from `templates/mcp-shared/` are covered once, for every consuming plugin, in `plugin-tests/mcp-shared/`:

| Test File                     | Coverage                                                                |
|-------------------------------|---------------------------------------------------------------------------|
| `environment.bats`            | Environment wrapping, argument quoting, `parse_paths_json`, path guards   |
| `docker_compose.bats`         | Docker Compose call-time container/workdir resolution                     |
| `scope_wrap.bats`             | Scope-aware command wrapping per environment                              |
| `config.bats`                 | Config filename and env-var prefix parameterization                       |

Run tests:
```bash
.bats/bats-core/bin/bats plugin-tests/dev-tooling/*.bats plugin-tests/mcp-shared/*.bats
```

## 📖 External References

- [bash-mcp-sdk](https://github.com/shopwareLabs/bash-mcp-sdk) - the server's protocol handler is vendored from here
- [MCP Protocol Specification](https://modelcontextprotocol.io/specification) - JSON-RPC 2.0 protocol details
