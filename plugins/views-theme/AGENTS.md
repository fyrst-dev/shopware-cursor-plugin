@README.md

## Directory Structure

```
plugins/views-theme/
├── .cursor-plugin/
│   └── plugin.json
├── agents/
│   └── views-theme-developer.md
├── commands/
│   ├── vi-implement.md
│   ├── vi-new-component.md
│   └── vi-review-conventions.md
├── hooks/
│   └── hooks.json
├── references/
│   ├── doc-resolution.md
│   ├── docs.sha
│   └── docs/                         # vendored fyrst-digital/views-theme docs/
├── rules/
│   └── views-theme-critical.mdc      # alwaysApply
├── scripts/
│   ├── deny-theme-builds.sh
│   ├── refresh-docs.sh
│   └── resolve-docs.sh
├── skills/
│   ├── building-views-theme-component/
│   │   └── SKILL.md
│   ├── extending-views-theme-child/
│   │   └── SKILL.md
│   ├── following-views-theme-conventions/
│   │   └── SKILL.md
│   ├── implementing-views-theme-feature/
│   │   └── SKILL.md
│   └── writing-views-theme-javascript/
│       └── SKILL.md
├── README.md
├── AGENTS.md                         # This file
└── CHANGELOG.md
```

No `mcp.json`. No Claude packaging. No Cloud Agent shop scripts.

## Runtime vs Developer Docs

| Runtime | Developer docs |
|---------|----------------|
| `skills/*/SKILL.md` | `README.md` |
| `agents/views-theme-developer.md` | `AGENTS.md` (this file) |
| `commands/vi-*.md` | `CHANGELOG.md` |
| `rules/views-theme-critical.mdc` | |
| `hooks/hooks.json`, `scripts/*.sh` | |
| `references/doc-resolution.md`, `references/docs/**` | |

`references/docs/` is a snapshot of ViewsTheme topic pages. Skills route into it (or into live docs). Do not rewrite convention prose in skills.

## When to Modify

| Task | File |
|------|------|
| Change always-on critical bullets | `rules/views-theme-critical.mdc` |
| Change doc lookup order | `references/doc-resolution.md` + `scripts/resolve-docs.sh` |
| Refresh the snapshot | `scripts/refresh-docs.sh` (do not hand-edit `references/docs/`) |
| Deny additional build commands | `scripts/deny-theme-builds.sh` |
| Skill routing / triggers | the skill's `SKILL.md` |
| Agent identity or child-theme policy | `agents/views-theme-developer.md` |
| Slash command behavior | `commands/vi-*.md` only — no unprefixed aliases |

Convention changes belong in **ViewsTheme** `docs/`, then a snapshot refresh — not in this plugin's skills.

## Tests

Tests live in `plugin-tests/views-theme/`. Run `.bats/bats-core/bin/bats plugin-tests/views-theme/*.bats` from the repo root.

## Version Sync

`plugin.json` version, every skill `SKILL.md` frontmatter `version`, and the latest `CHANGELOG.md` header stay in lockstep. Bump with the `plugin-updating` skill.
