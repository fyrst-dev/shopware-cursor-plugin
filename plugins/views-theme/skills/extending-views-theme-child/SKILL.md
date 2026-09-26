---
name: extending-views-theme-child
version: 1.0.0
description: Use this skill when working in a ViewsTheme child theme or a Shopware shop that depends on ViewsTheme — phrases like "child theme", "extend ViewsTheme", "override a ViewsTheme component", "custom/plugins theme on ViewsTheme", or adding storefront UI that should compose parent UX tags.
---

# Extend ViewsTheme from a child theme

Prefer **live** ViewsTheme docs for the installed parent. Child-theme structure is plugin routing, not a new convention set — UI/JS/CSS rules stay in ViewsTheme topic pages.

## 1. Resolve docs

Follow [doc-resolution.md](../../references/doc-resolution.md). Live `static-plugins` or `vendor` docs beat the plugin snapshot.

```bash
bash "${CURSOR_PLUGIN_ROOT}/scripts/resolve-docs.sh" --kind
```

`DOCS` is stdout. Kind on stderr should be `static-plugins` or `vendor` when the parent is installed. If you only have `snapshot`, still apply parent conventions from the snapshot and say so.

## 2. Open

- `$DOCS/conventions/hard-rules.md` and the linked topic pages the change touches
- `$DOCS/conventions/ux-components.md` and `$DOCS/conventions/components.md` for composition
- `$DOCS/features/…` when overriding a named parent feature
- `$DOCS/configuration.md` / `$DOCS/architecture.md` when theme config or `/vi/…` routes are involved

## 3. Child-theme rules (this plugin)

These are workspace rules, not replacements for ViewsTheme topic docs:

- New UI lives in the **child** `src/Resources/views/components/` as `<twig:{ChildBundle}:…>` (the child's Shopware UX namespace).
- Compose parent UI with `<twig:ViewsTheme:…>`. Do not copy parent component trees into the child.
- Do not create new child files under `views/storefront/` except when wiring an existing storefront include to a component.
- Interactive JS: co-located `ShopwareComponent` + `data-component="{ChildBundle}:…"`.
- Do **not** edit `vendor/fyrst/views-theme` or `custom/static-plugins/ViewsTheme` unless the user asked for a parent-theme change.
- Same no-build, surgical-edit, px, and CVA rules as the parent topic pages.
- Optional ViewsTheme plugin `.env` logins are optional when present; never required.

## 4. Workflow

1. Confirm the child bundle / UX namespace from the child's plugin class or `theme.json`.
2. Open the parent topic + feature page for the piece being extended.
3. Add or edit child components that wrap or slot into parent tags.
4. Update child-theme docs if the child keeps them. Do not rewrite the parent snapshot.

## 5. Done

Child files only (unless a parent change was requested). Parent conventions followed from `DOCS`. No build was run.
