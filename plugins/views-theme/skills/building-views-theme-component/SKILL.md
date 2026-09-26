---
name: building-views-theme-component
version: 1.0.0
description: Use this skill when creating or migrating a ViewsTheme or child-theme UX Twig component — phrases like "new ViewsTheme component", "add a twig:ViewsTheme tag", "migrate this storefront include to components/", "vi_define_cva", or scaffolding UI under views/components/.
---

# Build a ViewsTheme UX component

Resolve docs, then follow the UX and component topic pages. Do not copy their prose here.

## 1. Resolve docs

Follow [doc-resolution.md](../../references/doc-resolution.md).

```bash
bash "${CURSOR_PLUGIN_ROOT}/scripts/resolve-docs.sh"
```

`DOCS` is the printed path.

## 2. Detect namespace

| Workspace | New component tag | `data-component` |
|-----------|-------------------|------------------|
| views-theme (`fyrst/views-theme`) | `<twig:ViewsTheme:…>` | `ViewsTheme:…` |
| Child theme / shop | Child bundle UX tag | Child bundle name, same colon path |

Compose parent primitives with `<twig:ViewsTheme:…>` from a child. Do not fork parent templates into the child.

## 3. Open (required)

- `$DOCS/conventions/hard-rules.md`
- `$DOCS/conventions/ux-components.md` — props, class components, CVA, attributes, nested slots
- `$DOCS/conventions/components.md` — template checklist
- `$DOCS/conventions/css-classes.md` — CVA vs CSS; px lengths
- Twig helpers as needed: `$DOCS/twig/vi-cva.md`, `$DOCS/twig/vi-attrs.md`, `$DOCS/twig/vi-block.md`, `$DOCS/twig/vi-icon.md`

If the component is interactive, also run `writing-views-theme-javascript` (or open `$DOCS/conventions/javascript.md`).

## 4. Workflow

1. Place the component under `src/Resources/views/components/` (PascalCase path). Do **not** create new files under `views/storefront/`.
2. Follow the checklist in `$DOCS/conventions/components.md` on disk — props, `vi_define_cva` / `vi_class`, `vi_define_attrs` / `vi_attrs`, `{% vi_block %}` for nested host slots.
3. Heavy view-model → class component (`Name.php`) per `$DOCS/conventions/ux-components.md#class-components-php-backed`.
4. Interactive root → co-located `Name.js` + `data-component`. No `index.*` leaf names.
5. Surgical edits. Never compile or watch.
6. Update the matching `$DOCS/features/…` page when this is ViewsTheme and behavior is new or changed.

## 5. Done

Files exist under `views/components/` with the correct UX namespace. No new `views/storefront/` templates. No build was run.
