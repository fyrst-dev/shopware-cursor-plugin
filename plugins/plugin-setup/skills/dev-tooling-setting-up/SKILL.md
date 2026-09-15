---
name: dev-tooling-setting-up
version: 2.0.0
description: Use this skill when the user just installed the dev-tooling plugin and needs to configure it for a Shopware project, asks "help me set up dev-tooling" or for guidance on configuring the PHP and JavaScript tool chains, or when dev-tooling MCP tools fail with missing-config errors. Also use when reconfiguring the environment type (native, Docker, Docker Compose, Vagrant, DDEV) for the PHP and JS MCP servers. Checks prerequisites (jq), creates .mcp-php-tooling.json and .mcp-js-tooling.json, validates that the three MCP servers (PHP — PHPStan, ECS, Rector, PHPUnit; Administration JS; Storefront JS) connect, and walks through optional scope setup.
allowed-tools: Bash, Read, Write, Glob
---

# Plugin Setup

Interactive setup assistant. Read references/plugin-setup.md for all plugin-specific details including prerequisites, configuration files, validation steps, and post-setup instructions.

## Workflow

### Phase 1: Detect Current State

Read the plugin setup guide reference file. It contains all plugin-specific information organized in standard sections.

For each prerequisite listed under `## Prerequisites`:
1. Run its check command (the **Check** field) via Bash
2. Record the result: installed (with version) or missing

For each config file listed under `## Configuration Files`:
1. Check if it exists at the specified location using Glob
2. Record the result: exists or missing

Report findings to the user:
- Installed prerequisites with versions
- Missing prerequisites (distinguish required vs optional)
- Existing config files
- Missing config files

If everything is already configured, skip to Phase 5 (Enable MCP) — MCP enablement is always offered.

### Phase 2: Fix Prerequisites

For each missing prerequisite:

1. Tell the user what is missing, what requires it (the **Required by** field), and provide the install link
2. If the prerequisite is marked as optional, ask whether they want to install it. Skip if they decline.
3. For required prerequisites, tell the user to install it and ask them to confirm when done
4. After confirmation, re-run the check command to verify

If a required prerequisite cannot be installed, stop and explain which config files and features depend on it. Do not proceed to Phase 3 for config files that depend on missing prerequisites.

### Phase 3: Create Config Files

For each config file from the guide that does not exist:

1. If the file is marked `Required: No`, ask whether the user wants to configure it. Skip if they decline.
2. Read the **Setup Questions** section for this config file
3. Ask each question one at a time, presenting the options and descriptions exactly as written in the guide
4. Skip conditional questions when their condition is not met (conditions are noted in parentheses, e.g., "only if environment = docker")
5. Build the config JSON object from the answers
6. Present the complete config to the user and ask for confirmation
7. Write the file to the specified location using Write

Prefer `.cursor/` for optional config-directory destinations.

### Phase 4: Plugin Scope Setup (optional)

Read the `## Plugin Scope Setup` section of the guide and walk the dialogue. Skip this phase entirely if the user answers No to the gate question.

### Phase 5: Enable MCP

Read the `## Permission Groups` section of the guide. Each group is an MCP server (or server set) the user should enable in Cursor.

1. Tell the user to open **Customize → MCP** (or Settings → Tools & MCP).
2. For each group listed in the guide, skip it if its **Optional** condition is not met. Otherwise ask them to enable that server and confirm when it is on.
3. Do not write Claude Code permission files. Cursor does not use `.claude/settings.local.json`.

### Phase 6: Validate

Read the `## Validation` section of the guide. For each validation step:

1. Run the described check or MCP tool call
2. Report pass or fail
3. If a check fails, diagnose the likely cause and offer to fix it (e.g., wrong container name, container not running, missing PHP extension)

### Phase 7: Post-Setup

Read the `## Post-Setup` section of the guide. Report the remaining steps the user must take (for example, Developer: Reload Window so MCP servers pick up new config files).

## Rules

- Ask one question at a time. Never batch multiple questions.
- Skip phases and individual steps that are already satisfied (prerequisite installed, config file exists, MCP server already enabled).
- Never proceed to config file creation if a required prerequisite it depends on is missing.
- Always show the user the complete config content before writing it.
- If validation fails, attempt to diagnose the cause before giving up.
- Use the exact options, descriptions, defaults, and permission groups from the plugin setup guide. Do not improvise.
