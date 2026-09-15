# User-Scoped Cursor Rules

Rules files are markdown (or `.mdc`) files stored in `~/.cursor/rules/` (user-scoped) or `.cursor/rules/` (project-scoped) that Cursor auto-loads. They're a way to split standing guidance into smaller, topical files — same idea as always-on project rules, better organization.

Two loading modes, depending on frontmatter:

- **Unscoped rules** (no `globs` / `paths` frontmatter) load **once at session start** and stay in context for the whole session.
- **Path-scoped rules** (with a glob in frontmatter) **lazy-load** the first time the agent reads a file matching the glob. Useful for language- or tool-specific guidance that shouldn't occupy context when it's not relevant.

Unlike skills, rules are not invoked on demand — once loaded, they shape the agent's behavior unconditionally.

This directory collects the rules we've found useful when working on Shopware (and everything else) in Cursor. Each file is self-contained: copy the ones you want into `~/.cursor/rules/` and reload the window.

This marketplace's own maintainer rules already live under [`.cursor/rules/`](../../.cursor/rules/).

## 📦 Installation

```bash
mkdir -p ~/.cursor/rules
cp calibrated-honesty.md ~/.cursor/rules/
# ...repeat for the rules you want
```

Rules take effect after **Developer: Reload Window**. You can also scope rules per-project by placing them in `.cursor/rules/` inside a repository.

## 🧩 Available Rules

General behavioral steering (apply to every session):

| Rule                                                                 | What it does                                                                                         |
|----------------------------------------------------------------------|------------------------------------------------------------------------------------------------------|
| [calibrated-honesty.md](./calibrated-honesty.md)                     | Suppresses sycophancy AND reflexive contrarianism. Agree or disagree based on evidence, not vibes.   |
| [calibrated-honesty-in-coding.md](./calibrated-honesty-in-coding.md) | Coding-specific honesty rules: trust the code not the description, reproduce before diagnosing.     |
| [fail-hard-rules.md](./fail-hard-rules.md)                           | Hard failure is the default. Bans silent degradation, defensive fallbacks, and "sensible defaults".  |
| [research-rules.md](./research-rules.md)                             | Forces real web tools for research tasks. Bans silent fallback to training knowledge.                |

Tool-specific rules (apply only when the relevant tool is in use):

| Rule                                               | What it does                                                                                   |
|----------------------------------------------------|------------------------------------------------------------------------------------------------|
| [npm-registry-access.md](./npm-registry-access.md) | Routes npm package metadata lookups to `registry.npmjs.org` instead of the WAF-blocked web UI. |

## 💡 Why Rules And Not Skills?

Skills are invoked on demand when their description matches a task, then loaded and followed for that turn. Rules are auto-loaded (at session start or on first matching file read, depending on frontmatter) and then shape behavior unconditionally for the rest of the session — use them for things that must hold regardless of what the agent is doing, like honesty calibration or failure semantics.

Rough decision test:

- **"The agent should do X when working on Y"** → skill
- **"The agent should never do X"** → rule
- **"The agent should always do X"** → rule

> [!NOTE]
> These rules are opinionated. They reflect preferences built up over many Cursor sessions on this marketplace. Read each file before installing — if you disagree with the reasoning, don't install it.
