# Recommended Cursor Setup

This marketplace ships Cursor plugin manifests next to the existing Claude Code ones. The plugin directories are shared: skills, agents, MCP servers, and hook scripts live once and load from both clients.

Nothing in this file is required to use the plugins, but the install path is different from Claude Code's `/plugin marketplace add`.

---

## 1. Add the marketplace

### Team marketplace (Teams and Enterprise)

1. Open the Cursor dashboard → **Plugins**.
2. Under **Team Marketplaces**, choose **Add Marketplace** → **Import from Repo**.
3. Point it at this repository (`fyrst-dev/shopware-cursor-plugin` or your fork) and the branch you want to track (`main` after merge).
4. Confirm Cursor finds `.cursor-plugin/marketplace.json` and the ten plugin entries.
5. Set marketplace access and, if you use the Cursor GitHub App, turn on **Auto Refresh**.

Developers then install individual plugins from **Customize** in the sidebar.

### Local development (before publishing)

Cursor loads plugins from `~/.cursor/plugins/local/<plugin-name>/` when local plugin imports are allowed (Dashboard → Settings → Marketplace and Plugins on Teams/Enterprise).

Copy or worktree a **plugin directory** (not the repo root) into that folder, then reload the window:

```bash
mkdir -p ~/.cursor/plugins/local
cp -R plugins/dev-tooling ~/.cursor/plugins/local/dev-tooling
```

Each copied directory must contain `.cursor-plugin/plugin.json`. After **Developer: Reload Window**, open **Customize** and confirm skills, agents, hooks, and MCP servers.

Cursor skips a symlink whose target sits outside `~/.cursor/plugins/local`. Copy or place a worktree *inside* that folder.

---

## 2. Install the plugins you need

From **Customize**, install the same plugins you would in Claude Code. A typical Shopware setup:

1. `dev-tooling` — PHP and JavaScript MCP tools
2. `plugin-setup` — walk through `.mcp-php-tooling.json` / `.mcp-js-tooling.json` (uninstall after setup)
3. `test-writing` — PHPUnit generation and review (needs `dev-tooling`)
4. `chunkhound-integration` — semantic research (run its setup skill)
5. Any writing / env / migration plugins you actually use

Enable each plugin's MCP servers under **Customize → MCP** (or Settings → Tools & MCP) after install. Cursor expands `${CLAUDE_PLUGIN_ROOT}` in `.mcp.json` to the plugin install path, so the existing server entrypoints keep working.

Project config files are unchanged:

| File | Used by |
|------|---------|
| `.mcp-php-tooling.json` | `dev-tooling` PHP server, `shopware-env` lifecycle tools |
| `.mcp-js-tooling.json` | `dev-tooling` Administration and Storefront servers |
| `.lsp-php-tooling.json` | phpactor LSP (**Claude Code only**) |
| `.chunkhound.json` | `chunkhound-integration` |

`plugin-setup` skills still create those MCP config files. Ask the agent to set up `dev-tooling` or `chunkhound-integration` after install.

---

## 3. How components map

| Claude Code | Cursor | Notes |
|-------------|--------|--------|
| `skills/*/SKILL.md` | Skills | Same files. Invoke with `/skill-name` or let the agent decide. |
| `agents/*.md` | Custom agents | `name` / `description` load. Claude-only frontmatter (`tools`, `disallowedTools`, `permissionMode`, `model`, `color`, `skills`, `context: fork`) is ignored. |
| `commands/` | Commands | This marketplace currently has none. |
| `.mcp.json` | MCP servers | Cursor plugin.json points at `./.mcp.json`. |
| `hooks/hooks.json` | `hooks/cursor-hooks.json` | Same scripts. Cursor uses `sessionStart`, `beforeShellExecution`, `postToolUse`. |
| `.lsp.json` / phpactor | — | No Cursor plugin LSP equivalent. Use an editor PHP language server separately. |
| Claude Workflows (`Workflow` tool) | — | `test-writing` team-review workflow does not run in Cursor. Single-reviewer skills still work. |
| Claude Agent SDK | — | `code-contribution-analysis` skills still run in chat; SDK embedding is Claude-only. |

Hook scripts accept both Claude (`tool_input.command`, `CLAUDE_PROJECT_DIR`) and Cursor (`command`, `CURSOR_PROJECT_DIR`, `workspace_roots`) payloads. SessionStart output includes both `hookSpecificOutput.additionalContext` and `additional_context`.

`test-writing`'s `rules/` directory is the PHPUnit catalog served by MCP. The Cursor manifest sets `"rules": []` so those files are **not** loaded as always-on Cursor rules.

---

## 4. MCP tool names in skills

Skills and agents still mention Claude Code MCP names such as `mcp__plugin_dev-tooling_php-tooling__phpstan_analyze`. Cursor surfaces the same servers (`php-tooling`, `js-admin-tooling`, …) under its own tool IDs.

When a skill names a Claude-prefixed tool, call the matching Cursor MCP tool (`phpstan_analyze` on the `php-tooling` server, and so on). SessionStart directives already list the short tool names.

---

## 5. Related

- [Claude Code setup](./claude-code-setup.md) — still valid if you also run Claude Code against this marketplace
- [Cursor plugins reference](https://cursor.com/docs/reference/plugins)
- [Cursor hooks](https://cursor.com/docs/hooks)
