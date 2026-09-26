---
name: vi-new-component
description: Scaffold a new ViewsTheme or child-theme UX Twig component under views/components/ without compiling assets. Name or path may follow /vi-new-component.
---

# New ViewsTheme component

## Goal

The text after `/vi-new-component` is the component name, path, or short brief (e.g. `Alert:Inline`, `views/components/Foo/Bar`, “quantity stepper with size sm”).

If that text is empty, ask one question for the component name and stop.

## Docs

Resolve docs ([doc-resolution.md](../references/doc-resolution.md)):

```bash
bash "${CURSOR_PLUGIN_ROOT}/scripts/resolve-docs.sh" --kind
```

Open and follow:

- `$DOCS/conventions/hard-rules.md`
- `$DOCS/conventions/ux-components.md`
- `$DOCS/conventions/components.md`
- `$DOCS/conventions/css-classes.md`
- `$DOCS/twig/vi-cva.md`, `$DOCS/twig/vi-attrs.md`, `$DOCS/twig/vi-block.md` as needed
- `$DOCS/conventions/javascript.md` when the component is interactive

Use `building-views-theme-component` (and `writing-views-theme-javascript` when interactive). Prefer the `views-theme-developer` agent.

## Namespace

- views-theme workspace → `<twig:ViewsTheme:…>` / `data-component="ViewsTheme:…"`
- Child theme → child UX namespace; compose parent with `<twig:ViewsTheme:…>`

## Rules

- Create files only under `src/Resources/views/components/` (PascalCase path, named leaf files — not `index.*`).
- Do not create new `views/storefront/` files.
- Follow the component checklist on disk. No wasteful `resolved*` locals. `vi_define_cva` / `vi_class` and `vi_define_attrs` / `vi_attrs`.
- Interactive: co-located `Name.js` + `data-component`.
- Surgical edits. Never compile or watch.
- Do not commit unless asked.

## Done when

The new component files exist and match the topic pages. Reply with paths, UX tag, `DOCS` kind, and whether JS was added. `verify: skipped` unless the user asked for a live check.
