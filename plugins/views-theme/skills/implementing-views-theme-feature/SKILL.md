---
name: implementing-views-theme-feature
version: 1.0.0
description: Use this skill when implementing or changing a named ViewsTheme storefront feature — phrases like "cart drawer", "search overlay", "product listing", "address manager", "implement the feature page", or any work that matches a docs/features/*.md topic.
---

# Implement a ViewsTheme feature

Resolve docs, open the feature page and architecture/configuration as needed, then implement. Do not duplicate feature prose in this skill.

## 1. Resolve docs

Follow [doc-resolution.md](../../references/doc-resolution.md).

```bash
bash "${CURSOR_PLUGIN_ROOT}/scripts/resolve-docs.sh"
```

`DOCS` is the printed path.

## 2. Open

1. `$DOCS/conventions/hard-rules.md` and `$DOCS/conventions/agent-workflow.md`
2. The matching `$DOCS/features/<topic>.md` (see `$DOCS/README.md` for the index)
3. `$DOCS/architecture.md` when routes (`/vi/…`), XHR, or controllers change
4. `$DOCS/configuration.md` when plugin/theme tokens change
5. UX / JS / CSS topic pages when those layers change

If no feature page exists, still follow conventions. In a **views-theme** workspace, add or update `$DOCS/features/…` when you introduce a named feature. In a child theme, document in the child's docs if it has them.

## 3. Parent vs child

[doc-resolution.md](../../references/doc-resolution.md): child work uses `extending-views-theme-child` for placement and namespace. This skill still owns reading the parent feature page so the child extension matches the live contract.

## 4. Workflow

1. Read the feature page end to end before editing.
2. Plan the smallest holistic change (shared pattern, not a call-site hack).
3. Implement with surgical edits. New UI under `views/components/`.
4. Verify without compiling — live storefront / curl against `/vi/…` as the feature page and `$DOCS/architecture.md` describe. Optional plugin `.env` credentials only when a login is required and the file exists.
5. Update the feature page (parent workspace) or child docs when behavior changed.

Never run theme/JS/CSS compile or watch. If verification is blocked (no storefront, missing env), still deliver the code and say `verify: blocked (reason)`.

## 5. Done

Feature page followed. Docs updated when behavior changed. Reply: `DOCS` kind, files touched, `verify: ok | skipped | blocked`.
