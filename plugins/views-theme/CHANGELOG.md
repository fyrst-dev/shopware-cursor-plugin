# Changelog

## [1.0.0] - 2026-09-26

### Added
- Initial Cursor-only `views-theme` plugin: always-apply critical rules, five routing skills, `views-theme-developer` agent, and `/vi-implement`, `/vi-new-component`, `/vi-review-conventions`.
- Vendored [fyrst-digital/views-theme](https://github.com/fyrst-digital/views-theme) `docs/` snapshot pinned at `48192594c34d62b7cf1adc8900dd018ae6b15d23`, with `scripts/resolve-docs.sh` (live docs first) and `scripts/refresh-docs.sh`.
- `beforeShellExecution` hook (`scripts/deny-theme-builds.sh`) that denies theme and storefront asset compile/watch commands.
- Child-theme routing: prefer live ViewsTheme docs under `custom/static-plugins/ViewsTheme/docs` or `vendor/fyrst/views-theme/docs`; new child UI uses the child UX namespace.
