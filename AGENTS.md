@README.md

# Shopware Cursor Plugin Marketplace — Technical Reference

This repository is a **Cursor-only** plugin marketplace. Do not add Claude Code packaging (`.claude-plugin/`, Claude `hooks.json` PascalCase events, `mcp.json`, `.lsp.json`). The `upstream` branch keeps the historical Claude marketplace; merge **from** `upstream` into working branches when syncing, never the other way around.

## Understanding Skills

**Skills are executable code, not documentation.** Markdown files in `skills/[skill-name]/` directories (`SKILL.md`, `references/*.md`) are instruction files the Cursor agent reads and executes. Modifying these files changes the skill's behavior directly — treat them as you would Python or JavaScript code.

## Understanding Slash Commands

**Slash commands are executable code, not documentation.** Markdown files in `commands/` are instruction files Cursor reads when users invoke the command. This marketplace currently has none.

## Understanding Developer Documentation

`AGENTS.md`, `README.md`, and `CHANGELOG.md` inside plugins are developer documentation, not runtime code. Cursor does not load them when the plugin is installed.

Runtime files (executed by Cursor):

- `skills/*/SKILL.md` and `skills/*/references/*.md`
- `agents/*.md`
- `commands/*.md`
- `hooks/hooks.json` and hook scripts
- `mcp.json`
- `.cursor-plugin/plugin.json`

Repo-level `.claude/` (plugin-updating skill, commit-message overlay, template-sync rule) is **maintainer tooling** for this repository, not installed plugin packaging.

When modifying runtime behavior, edit only runtime files. When updating architectural descriptions or usage guides, edit the developer documentation.

## Marketplace Architecture

Plugin metadata lives in each plugin's `.cursor-plugin/plugin.json`. The root marketplace is a name + source registry.

```
.cursor-plugin/marketplace.json   # Registry (name + source)
plugins/
  [plugin-name]/
    .cursor-plugin/plugin.json    # Authoritative metadata + version
    mcp.json                      # MCP servers (default discovery)
    hooks/hooks.json              # Cursor camelCase events
    skills/ agents/ commands/
```

`test-writing` must set `"rules": []` so `rules/` (the PHPUnit catalog) is not loaded as Cursor `.mdc` rules.

### marketplace.json Schema

**Required fields:**

- `name` — Marketplace identifier in kebab-case
- `owner` — Object with at least `name`
- `plugins` — Array of `{ "name", "source" }` (`source` is a relative path starting with `./`)

### plugin.json Schema

```json
{
  "name": "plugin-name",
  "version": "1.0.0",
  "description": "Plugin description",
  "author": { "name": "Author Name" },
  "license": "MIT",
  "keywords": ["tag1", "tag2"],
  "homepage": "https://github.com/...",
  "repository": "https://github.com/..."
}
```

Omit `mcpServers` and `hooks` so Cursor discovers `mcp.json` and `hooks/hooks.json` by default.

## Plugin Component Types

- **Commands** — markdown files in `commands/`
- **Agents** — markdown files in `agents/` (`name` + `description` frontmatter; tool policy in the body)
- **Skills** — `skills/[skill-name]/SKILL.md` using short MCP tool names (`phpstan_analyze`, `get_rules`, `code_research`, …)
- **Hooks** — `hooks/hooks.json` (`sessionStart`, `beforeShellExecution`, `postToolUse`)
- **MCP Servers** — `mcp.json` with `${CURSOR_PLUGIN_ROOT}`

### MCP Server Cross-Plugin Dependencies

Do not use relative paths like `${CURSOR_PLUGIN_ROOT}/../other-plugin/`. Plugin cache uses versioned subdirectories.

Use a wrapper that discovers the dependency under the cache root, then:

```json
"command": "${CURSOR_PLUGIN_ROOT}/run-server.sh"
```

See `plugins/dev-tooling/` for the pattern.

## Commit Messages

All commit messages in this repository MUST be generated using the `commit-message-writer:writing-commit-messages` skill from the `commit-message-writer` plugin (installed via the `itb-ai-tools` marketplace). Do not write commit messages manually. Project-specific type and scope rules ride on top of the plugin via the overlay at `.claude/hook-contexts/writing-commit-messages.md`, delivered through the hook entries in `.claude/settings.json`.

## Development Workflow

### Adding a New Plugin

1. Create `plugins/[plugin-name]/`
2. Create `plugins/[plugin-name]/.cursor-plugin/plugin.json`
3. Add components (`commands/`, `agents/`, `skills/`, `hooks/hooks.json`, `mcp.json`)
4. Register `{ "name", "source": "./plugins/..." }` in `.cursor-plugin/marketplace.json`
5. Update README.md "Available Plugins"
6. Validate: `.github/scripts/validate-cursor-plugins.sh` and `.github/scripts/validate-versions.sh`

### Version Management

Use the `plugin-updating` skill at `.claude/skills/plugin-updating/SKILL.md`. It updates `.cursor-plugin/plugin.json`, every `SKILL.md` frontmatter, CHANGELOG entries, and template-synced setup-skill versions. Do not bump versions manually.

## Testing & Validation

```bash
.github/scripts/validate-cursor-plugins.sh
.github/scripts/validate-versions.sh

# Local Cursor install (copy a plugin directory, then reload)
cp -R plugins/dev-tooling ~/.cursor/plugins/local/dev-tooling
```

### Hook Script Testing

```bash
./.github/scripts/setup-bats.sh
.bats/bats-core/bin/bats plugin-tests/**/*.bats
```

Tests live in `plugin-tests/<plugin-name>/`. Shared templates under `templates/mcp-shared/` are tested in `plugin-tests/mcp-shared/` and sourced from the template. The MCP protocol handler (`plugins/*/shared/mcpserver_core.sh`) is vendored from [shopwareLabs/bash-mcp-sdk](https://github.com/shopwareLabs/bash-mcp-sdk) at the release pinned in `.mcp-sdk.lock`; `vendor-mcp-sdk.sh --check` verifies the copies.

### Pre-release Checklist

- [ ] `.github/scripts/validate-cursor-plugins.sh` passes
- [ ] Plugin versions updated in `.cursor-plugin/plugin.json`
- [ ] Skill versions in `SKILL.md` frontmatter match the plugin version
- [ ] README.md "Available Plugins" section current
- [ ] Issue template dropdowns current (`.github/scripts/validate-issue-templates.sh`)
- [ ] Hook tests pass (`.bats/bats-core/bin/bats plugin-tests/**/*.bats`)

## Distribution

The public repository root must contain `.cursor-plugin/marketplace.json`. Import that repo as a Cursor team marketplace, or copy plugin directories into `~/.cursor/plugins/local/<name>/`.

## Agent Skills Export

Some skills are exported as portable packages following the [Agent Skills](https://agentskills.io) specification. Skills opt in via an empty `.agent-skills` marker file next to `SKILL.md`.

```bash
uv run --project agent-skills-export build-agent-skill <skill-dir> /tmp/agent-skills-out
uv run --project agent-skills-export skills-ref validate /tmp/agent-skills-out/<skill-name>
```

## What cannot exist as Cursor-only

- Plugin LSP (`.lsp.json` / phpactor) — use an editor PHP language server
- Claude Workflows — team review uses Cursor `Task`
- Claude Agent SDK embedding — chat skills only
- Claude agent frontmatter (`tools`, `model`, `color`, `skills`, `permissionMode`)
- `CURSOR_PLUGIN_DATA` as a Cursor-provided directory — use `CURSOR_PLUGIN_DATA` or `<workspace>/.cursor/test-writing`
