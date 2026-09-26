# Cursor plugin setup

This repository is a **Cursor-only** plugin marketplace. There is no Claude Code packaging and no dual runtime.

---

## 1. Add the marketplace

### Team marketplace (Teams and Enterprise)

1. Open the Cursor dashboard → **Plugins**.
2. Under **Team Marketplaces**, choose **Add Marketplace** → **Import from Repo**.
3. Point it at this repository (`fyrst-dev/shopware-cursor-plugin` or your fork) and track **`main`**.
4. Confirm Cursor finds `.cursor-plugin/marketplace.json` and the eleven plugin entries.
5. Set marketplace access and, if you use the Cursor GitHub App, turn on **Auto Refresh**.

Developers then install individual plugins from **Customize** in the sidebar.

`upstream` is the preserved Claude Code marketplace history. Do not install from `upstream` if you want this Cursor plugin set.

### Local development

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

From **Customize**, a typical Shopware setup:

1. `dev-tooling` — PHP and JavaScript MCP tools
2. `plugin-setup` — walk through `.mcp-php-tooling.json` / `.mcp-js-tooling.json` (uninstall after setup)
3. `test-writing` — PHPUnit generation and review (needs `dev-tooling`)
4. `chunkhound-integration` — semantic research (run its setup skill)
5. Any writing / env / migration plugins you actually use

Enable each plugin's MCP servers under **Customize → MCP** (or Settings → Tools & MCP) after install. Cursor expands `${CURSOR_PLUGIN_ROOT}` in `mcp.json` to the plugin install path.

Project config files:

| File | Used by |
|------|---------|
| `.mcp-php-tooling.json` | `dev-tooling` PHP server, `shopware-env` lifecycle tools |
| `.mcp-js-tooling.json` | `dev-tooling` Administration and Storefront servers |
| `.chunkhound.json` | `chunkhound-integration` |

Prefer `.cursor/` copies of those files when you want them off the project root. `plugin-setup` skills create the MCP config files. Ask the agent to set up `dev-tooling` or `chunkhound-integration` after install.

---

## 3. Component layout

| Path | Role |
|------|------|
| `.cursor-plugin/marketplace.json` | Marketplace registry |
| `plugins/<name>/.cursor-plugin/plugin.json` | Plugin manifest |
| `skills/*/SKILL.md` | Skills (short MCP tool names) |
| `agents/*.md` | Custom agents (`name` + `description`; tool policy in the body) |
| `commands/` | Commands — `views-theme` ships `/vi-implement`, `/vi-new-component`, `/vi-review-conventions` |
| `mcp.json` | MCP servers (`${CURSOR_PLUGIN_ROOT}`) |
| `hooks/hooks.json` | Cursor hooks (`sessionStart`, `beforeShellExecution`, `postToolUse`) |

`test-writing`'s `rules/` directory is the PHPUnit catalog served by MCP. The Cursor manifest sets `"rules": []` so those files are **not** loaded as always-on Cursor rules. `views-theme` ships always-apply `.mdc` rules under `rules/` on purpose.

Hook scripts read Cursor payloads (`.command` or `.tool_input.command`, `CURSOR_PROJECT_DIR`, `workspace_roots`) and emit `{ "additional_context": "..." }`. Shell enforcement denies with `{ "permission": "deny", ... }` and exit 2.

---

## 4. What cannot exist as Cursor-only

| Removed Claude surface | Cursor substitute |
|------------------------|-------------------|
| Plugin LSP (`.lsp.json` / phpactor) | Use a normal editor PHP language server |
| Claude Workflows (`Workflow`, `team-review.workflow.mjs`) | Team review uses Cursor `Task` plus the bash verify scripts |
| Claude Agent SDK embedding | Chat skills only |
| Agent frontmatter `tools` / `model` / `color` / `skills` | Documented in the agent body |
| `${PLUGIN_DATA}` / `CURSOR_PLUGIN_DATA` | `CURSOR_PLUGIN_DATA` or `<workspace>/.cursor/test-writing` |

---

## 5. Related

- [Cursor plugins reference](https://cursor.com/docs/reference/plugins)
- [Cursor hooks](https://cursor.com/docs/hooks)
