---
name: following-views-theme-conventions
version: 1.0.0
description: Use this skill when writing or reviewing ViewsTheme or child-theme storefront code and you need the convention checklist — phrases like "follow ViewsTheme conventions", "hard rules", "CVA vs CSS", "px only", "no theme compile", or before any Twig/JS/CSS change in a ViewsTheme shop.
---

# Follow ViewsTheme conventions

Resolve docs, then open the checklist and the **linked topic pages**. Do not restate or invent convention prose.

## 1. Resolve docs

Follow [doc-resolution.md](../../references/doc-resolution.md).

```bash
bash "${CURSOR_PLUGIN_ROOT}/scripts/resolve-docs.sh"
```

Treat the printed path as `DOCS`. When `${CURSOR_PLUGIN_ROOT}` is unset, run `plugins/views-theme/scripts/resolve-docs.sh` from this marketplace or two directories above this skill.

## 2. Open

1. `$DOCS/conventions/hard-rules.md` — checklist only; follow every linked topic that the change touches
2. `$DOCS/conventions/agent-workflow.md` — holistic refactors; no builds; surgical edits
3. `$DOCS/README.md` — full index

When the change is CSS/CVA, also `$DOCS/conventions/css-classes.md`. When it is UX Twig, `$DOCS/conventions/ux-components.md` and `$DOCS/conventions/components.md`. When it is JS, `$DOCS/conventions/javascript.md`.

## 3. Parent vs child

Use the table in [doc-resolution.md](../../references/doc-resolution.md). Child-theme new UI uses the **child** UX namespace; compose parent pieces with `<twig:ViewsTheme:…>`.

## 4. Apply

- Read the topic page. Follow it.
- Surgical edits; holistic refactors — `$DOCS/conventions/agent-workflow.md`
- Never run theme/JS/CSS compile or watch
- In ViewsTheme itself, update the relevant `$DOCS` page when behavior or conventions change. In a child theme, update the child's docs if it keeps any — do not edit vendor/static-plugin ViewsTheme docs unless the task is a ViewsTheme change

## 5. Done

The change matches the checklist. Reply with which `DOCS` root you used (`workspace` / `static-plugins` / `vendor` / `snapshot`) and which topic pages you followed.
