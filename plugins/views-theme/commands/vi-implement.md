---
name: vi-implement
description: Implement an agreed ViewsTheme or child-theme plan without compiling theme or storefront assets. Use after planning, or with a goal typed after /vi-implement.
---

# Implement (ViewsTheme)

## Goal

The text the user typed after `/vi-implement`.

Resolve the goal in this order:

1. **Non-empty text after `/vi-implement`** — that text is the goal (may refine or override).
2. **No extra text** — the goal is the **refined implementation plan already agreed in this session**. Treat that plan as source of truth and implement it fully.
3. **No plan in context and no extra text** — ask one clarifying question and stop. Do not invent a large scope.
4. **Plan present but ambiguous or conflicting** — ask one clarifying question and stop. Do not guess.

## Repo snapshot

Before coding, run:

```bash
git status -sb
git diff --stat HEAD
```

## Required conventions

Resolve docs ([doc-resolution.md](../references/doc-resolution.md)):

```bash
bash "${CURSOR_PLUGIN_ROOT}/scripts/resolve-docs.sh" --kind
```

Then open and follow:

- `$DOCS/conventions/hard-rules.md`
- `$DOCS/conventions/agent-workflow.md`
- The matching `$DOCS/features/…` page when the goal touches a named feature

Use `following-views-theme-conventions`, `building-views-theme-component`, `writing-views-theme-javascript`, `extending-views-theme-child`, or `implementing-views-theme-feature` when that skill owns the work. Prefer the `views-theme-developer` agent for storefront coding.

Child theme: new UI uses the child UX namespace; compose `<twig:ViewsTheme:…>` for parent primitives. Do not edit vendor/static-plugin ViewsTheme unless asked.

## Rules for this run

- Implement the goal fully in this turn: explore → edit → docs → verify.
- Surgical edits; prefer holistic refactors over hacky dual paths.
- Never run asset/theme/JS build or watch (`theme:compile`, `npm run build*`, `watch*`, storefront build scripts, etc.).
- Do not commit unless the goal explicitly asks to commit.
- Write code directly; do not delegate the edits to a readonly subagent.
- Never print secrets (passwords, tokens, full `.env` dumps).

## Auth (optional)

If a ViewsTheme plugin `.env` exists and verification needs it, load it without echoing values. Missing `.env` does not block coding.

| Variable | Use |
|----------|-----|
| `USER_ACCOUNT_NAME` | Storefront customer login |
| `USER_ACCOUNT_PASSWORT` | Storefront password (exact spelling) |
| `ADMIN_ACCOUNT_USER` | Admin UI / admin API |
| `ADMIN_ACCOUNT_PASSWORD` | Admin UI / admin API |

Storefront base URL: Shopware `APP_URL` (typically `http://localhost:8000`).

## Verification

Classify the goal, then verify. If verification finds a bug you can fix in code, fix and re-verify.

**Assumption:** the human keeps the storefront app and `make dev-storefront` running. **Never** start builds or watch.

| Domain | How |
|--------|-----|
| Storefront / frontend | Chrome DevTools MCP against the live storefront when available |
| API / `/vi/…` | `curl` status + body markers. Prefer routes from `$DOCS/architecture.md` |
| Docs-only / pure refactor | Skip live verify; state why |

Login only when needed and credentials exist. Login failure or unreachable storefront → `verify: blocked (reason)`. Still deliver the code. Do not compile to unblock.

## Done when

- Goal is implemented (or blocked only by missing clarification).
- Relevant docs updated when behavior or conventions changed (parent `docs/` in views-theme; child docs in a child theme).
- Reply: files touched, `DOCS` kind, `verify: ok | skipped | blocked`. No secrets. Do not default to “please rebuild”.
