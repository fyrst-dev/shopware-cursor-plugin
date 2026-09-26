---
name: writing-views-theme-javascript
version: 1.0.0
description: Use this skill when writing or changing ViewsTheme or child-theme storefront JavaScript — phrases like "ShopwareComponent", "data-component", "lazy shell", "emitQueued", "callMethod", or adding JS next to a UX Twig component.
---

# Write ViewsTheme JavaScript

Resolve docs, then follow `$DOCS/conventions/javascript.md`. Do not copy selector tables or the component inventory into this skill.

## 1. Resolve docs

Follow [doc-resolution.md](../../references/doc-resolution.md).

```bash
bash "${CURSOR_PLUGIN_ROOT}/scripts/resolve-docs.sh"
```

`DOCS` is the printed path.

## 2. Open (required)

- `$DOCS/conventions/hard-rules.md`
- `$DOCS/conventions/javascript.md` — modules, selectors, `ShopwareComponent`, lazy shells, event bus
- The matching `$DOCS/features/…` page when the work is a named feature

## 3. Namespace

Parent theme: `data-component="ViewsTheme:…"`. Child theme: the child's bundle name with the same colon path. Find nested instances by `data-component` identity, not CSS classes.

## 4. Workflow

1. Co-locate `<Name>.js` next to `<Name>.html.twig`. Every `data-component` must have that module.
2. Extend `ShopwareComponent`. Do **not** register a new `PluginManager` plugin.
3. Follow `$DOCS/conventions/javascript.md` for selectors, `emit` / `emitQueued` / `on` / `off`, `callMethod`, PascalCase events, and lazy-shell open/close (no HTML/DOM cache).
4. Shared logic: `@views-theme/modules/…` per that page. Child themes import parent modules the same way when the package is available; do not invent a parallel helper tree under `app/storefront/src/helper/`.
5. Surgical edits. Never run `composer build:js:storefront`, Vite/Webpack, or watch.

## 5. Done

Each new `data-component` has co-located JS. No CSS-class selectors, `data-ref`, or `data-vi`. No build was run.
