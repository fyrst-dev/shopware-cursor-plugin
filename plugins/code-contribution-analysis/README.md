# Code Contribution Analysis

Two skills for analyzing GitHub pull requests and issues in depth. Given a PR or issue number, the skills fetch the contribution data and research its architectural context, producing a structured analysis covering scope, impact, and code relationships.

## ⚡ Quick Start

Install `chunkhound-integration` and `code-contribution-analysis` from **Customize** after adding this repo as a Cursor team marketplace (track **`main`**). See [docs/cursor-setup.md](../../docs/cursor-setup.md).

Then ask the agent to analyze a PR or issue:

```
Analyze PR #4521 in shopware/shopware
Analyze issue #8910 in shopware/shopware
```

The relevant skill activates automatically.

## 🎯 Skills

| Skill             | Triggers on                                                      | What it produces                                                                |
|-------------------|------------------------------------------------------------------|---------------------------------------------------------------------------------|
| `pr-analyzing`    | "Analyze PR #N", "What's the impact of this PR?", similar        | Summary, scope, architectural impact, key findings, research method             |
| `issue-analyzing` | "Analyze issue #N", "What code does this issue affect?", similar | Summary, affected area, code context, scope, resolution status, research method |

Both skills use an **incremental research strategy** with ChunkHound: broad queries first, then focused follow-ups only if warranted. Not every contribution needs deep research.

## 📦 Prerequisites

The skills require the **[chunkhound-integration](../chunkhound-integration)** companion plugin for semantic code research. It must be configured before using this one — see its README for setup. If ChunkHound is not available at runtime, the skills stop with an error instead of producing partial analysis.

GitHub data (PR and issue metadata, diffs, reviews, comments) is fetched using whatever GitHub access the session has available — a GitHub MCP server, the `gh` CLI, or direct API calls. No specific GitHub tool is required; the model will use what's there.

## 🔬 What the Skills Do

### pr-analyzing

1. Fetches PR metadata, diff, files, reviews, and inline comments from GitHub
2. Assesses scope from file spread, volume, labels, and review activity
3. Researches architectural impact incrementally via ChunkHound:
   - **Stage 1** — identify points of interest in the changed code
   - **Stage 2** — understand how those components connect to the broader codebase
   - **Stage 3** (optional) — deep dive on specific relationships discovered in Stage 2
4. Produces a structured text analysis

### issue-analyzing

1. Fetches issue metadata and comments from GitHub
2. Identifies the affected code area from the description, labels, and linked PRs
3. Researches the affected area incrementally via ChunkHound:
   - **Stage 1** — locate the components referenced in the issue
   - **Stage 2** — understand how they work and what depends on them
   - **Stage 3** (optional) — deep dive on cross-component effects
4. Produces a structured text analysis

## 🧩 Passing Triage Context

Both skills accept optional context from the caller about why analysis was requested. A developer can say:

```
Analyze PR #4521 — it was flagged because it touches 12 files across Checkout and Payment
```

A caller can pass the same kind of context in its prompt. The skills use this as a hint for research focus, not as required input.

## 🏗️ Developer Guide

See `AGENTS.md` for plugin architecture and development guidance.

## ⚖️ License

MIT
