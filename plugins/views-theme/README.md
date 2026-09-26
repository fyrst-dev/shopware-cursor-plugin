# views-theme

Cursor plugin for [ViewsTheme](https://github.com/fyrst-digital/views-theme) storefront work on Shopware 6.7. Ships always-on critical rules, five routing skills, a child-theme-aware agent, three `/vi-…` commands, and a hook that denies theme and asset builds.

Convention prose is not duplicated here. Skills and the agent open ViewsTheme `docs/` — live in the project when present, otherwise the snapshot vendored under `references/docs/` (pinned in `references/docs.sha`).

## 📦 Installation

Install `views-theme` from **Customize** after adding this repo as a Cursor team marketplace (track **`main`**). See [docs/cursor-setup.md](../../docs/cursor-setup.md).

This plugin has no MCP server and no setup skill. Reload the window after install.

## ⚡ Quick Start

Use it in a ViewsTheme checkout, a child theme, or a Shopware shop that contains ViewsTheme (`custom/static-plugins/ViewsTheme` or `vendor/fyrst/views-theme`).

```
Follow ViewsTheme conventions for this Twig change
Add a ViewsTheme:Drawer header component
Write the cart drawer JS
Extend ViewsTheme from this child theme
Implement the search overlay feature
/vi-implement
/vi-new-component Product:Badge:Dot
/vi-review-conventions
```

Do not run `theme:compile`, storefront JS/CSS builds, or watch tasks — the `beforeShellExecution` hook denies them.

## 🎯 Skills

| Skill | When |
|-------|------|
| `following-views-theme-conventions` | Checklist + topic-page routing before any storefront change |
| `building-views-theme-component` | New or migrated UX Twig under `views/components/` |
| `writing-views-theme-javascript` | Co-located `ShopwareComponent` + `data-component` |
| `extending-views-theme-child` | Child theme or shop that depends on ViewsTheme |
| `implementing-views-theme-feature` | Named feature pages under `docs/features/` |

Skills **route** to topic pages. They do not rewrite rule text.

## ⌨️ Commands

No unprefixed aliases (`/implement` is not shipped).

| Command | Purpose |
|---------|---------|
| `/vi-implement` | Plan-then-implement; surgical edits; verify without compiling |
| `/vi-new-component` | Scaffold a UX component under `views/components/` |
| `/vi-review-conventions` | Review a path or the working tree against hard-rules |

## 🤖 Agent

`views-theme-developer` — storefront implementation for ViewsTheme and child themes. Prefers live parent docs. Tool policy is in the agent body (no Claude `tools` / `model` frontmatter).

## 🪝 Hook

`beforeShellExecution` runs `scripts/deny-theme-builds.sh` and denies theme/storefront/JS/CSS compile or watch (`theme:compile`, `build-storefront`, `composer build:js:*`, `npm run build*` / `watch*`, and equivalents). Cache, plugin, and migration commands stay allowed.

## 📚 Docs snapshot

`references/docs/` is a copy of [fyrst-digital/views-theme](https://github.com/fyrst-digital/views-theme) `docs/` at the commit in `references/docs.sha`. Refresh when conventions change:

```bash
bash plugins/views-theme/scripts/refresh-docs.sh --source /path/to/views-theme
# or: bash plugins/views-theme/scripts/refresh-docs.sh --sha <commit>
```

Live resolution order: views-theme workspace → `custom/static-plugins/ViewsTheme/docs` → `vendor/fyrst/views-theme/docs` → snapshot. See `references/doc-resolution.md` and `scripts/resolve-docs.sh`.

## 🧪 Tests

```bash
.bats/bats-core/bin/bats plugin-tests/views-theme/*.bats
```

## ⚖️ License

MIT
