# ViewsTheme doc resolution

Convention prose lives only in ViewsTheme `docs/`. Skills, the agent, and commands **route** to those pages. Do not copy rule text into this plugin.

## Order

1. Live docs if found (first match, walking from the project directory toward filesystem root):
   - The workspace **is** views-theme: `composer.json` name `fyrst/views-theme` and `docs/conventions/hard-rules.md`
   - `custom/static-plugins/ViewsTheme/docs`
   - `vendor/fyrst/views-theme/docs`
2. Else this plugin's snapshot: `references/docs/`, pinned by `references/docs.sha`

Prefer live docs in a child theme or Shopware shop so the installed ViewsTheme version wins over the snapshot.

## Resolve

```bash
bash "${CURSOR_PLUGIN_ROOT}/scripts/resolve-docs.sh"
```

`${CURSOR_PLUGIN_ROOT}` is the installed plugin root. When unset (this marketplace checkout), use `plugins/views-theme/scripts/resolve-docs.sh`.

Stdout is the absolute docs directory. `--kind` prints `workspace`, `static-plugins`, `vendor`, or `snapshot` on stderr.

## Child theme vs parent

| Workspace | Meaning | New UI namespace |
|-----------|---------|------------------|
| `composer.json` name is `fyrst/views-theme` | Parent theme | `<twig:ViewsTheme:…>` and `data-component="ViewsTheme:…"` |
| Live ViewsTheme docs found under static-plugins or vendor, workspace is not views-theme | Child theme or shop | Child plugin's Shopware bundle / UX namespace (e.g. `<twig:MyChildTheme:…>`). Compose parent primitives with `<twig:ViewsTheme:…>` |
| Snapshot only | Same detection from the workspace `composer.json` | Same as above |

In a child theme, do **not** edit vendored ViewsTheme files under `vendor/` or `custom/static-plugins/ViewsTheme/` unless the task is explicitly a ViewsTheme change. Update the child's own `docs/` when the child keeps documentation.

## Refresh the snapshot

When ViewsTheme conventions change upstream:

```bash
bash plugins/views-theme/scripts/refresh-docs.sh --source /path/to/views-theme
# or fetch fyrst-digital/views-theme at the SHA in references/docs.sha (or --sha)
```

Do not rewrite snapshot pages by hand.
