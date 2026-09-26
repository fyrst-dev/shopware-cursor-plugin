---
name: vi-review-conventions
description: Review ViewsTheme or child-theme changes against the hard-rules checklist and linked topic docs. Optional path or feature name after /vi-review-conventions.
---

# Review ViewsTheme conventions

## Scope

The text after `/vi-review-conventions` is the path, feature, or diff to review. If empty, review the current working tree (`git status` / `git diff`).

Do not implement fixes unless the user asked to fix. This command is a review.

## Docs

Resolve docs ([doc-resolution.md](../references/doc-resolution.md)):

```bash
bash "${CURSOR_PLUGIN_ROOT}/scripts/resolve-docs.sh" --kind
```

Open `$DOCS/conventions/hard-rules.md` and every linked topic page that the scoped files touch. Use `following-views-theme-conventions`. Do not quote or rewrite rule essays — cite the topic page and the failing snippet.

## Checks (route only)

Walk the hard-rules checklist. For each row that applies, open the linked page and judge the scoped files against **that page**. Typical hits:

- Agent workflow: builds, holistic vs hacky, surgical edits
- UX / components / Twig helpers
- CVA vs CSS; px lengths; CSS tokens
- JavaScript: `data-component`, lazy shells
- Architecture: `/vi/…`, XHR render helpers
- Child theme: wrong namespace, forked parent templates, edits under vendor/static-plugins

## Report

```
docs: <kind> <path>
scope: <paths or feature>
result: PASS | ISSUES

findings:
- <file>:<line> — <checklist topic> — <topic page> — <what is wrong>
```

No build was run. Do not start one to “verify” CSS.
