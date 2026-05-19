---
name: "playwright"
description: "Use when the task requires automating a real browser from the terminal (navigation, form filling, snapshots, screenshots, data extraction, UI-flow debugging) via `playwright-cli` or the bundled wrapper script."
---


# Playwright CLI Skill

Drive a real browser from the terminal using `playwright-cli`. Prefer the bundled wrapper script so the CLI works even when it is not globally installed.
Treat this skill as CLI-first automation. Do not pivot to `@playwright/test` unless the user explicitly asks for test files.

## Prerequisite check (required)

Before proposing commands, check whether `npx` is available (the wrapper depends on it):

```bash
command -v npx >/dev/null 2>&1
```

If it is not available, pause and ask the user to install Node.js/npm (which provides `npx`). Provide these steps verbatim:

```bash
# Verify Node/npm are installed
node --version
npm --version

# If missing, install Node.js/npm, then:
npm install -g @playwright/cli@latest
playwright-cli --help
```

Once `npx` is present, proceed with the wrapper script. A global install of `playwright-cli` is optional.

## Skill path (set once)

```bash
export CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
export PWCLI="$CODEX_HOME/skills/playwright/scripts/playwright_cli.sh"
```

User-scoped skills install under `$CODEX_HOME/skills` (default: `~/.codex/skills`).

## Windows prerequisite (required when daemon creation fails)

On Windows, if Playwright fails before the browser opens with errors around `ms-playwright/daemon`, treat it as an environment-path problem first, not a page problem.

Typical symptom:

```text
EPERM: operation not permitted, mkdir 'C:\Users\<user>\AppData\Local\ms-playwright\daemon'
```

In that case, redirect writable runtime folders into the current workspace before using the CLI:

```powershell
$env:LOCALAPPDATA = "$PWD/tmp/playwright-temp/localappdata"
$env:APPDATA = "$PWD/tmp/playwright-temp/roaming"
$env:TEMP = "$PWD/tmp/playwright-temp/temp"
$env:TMP = "$PWD/tmp/playwright-temp/temp"
```

Do this before calling `open`, `snapshot`, or `screenshot`. If the workspace-local directories are writable, browser startup should proceed normally. Keep all Playwright temporary runtime files under `tmp/playwright-temp/` so they can be deleted in one cleanup step.

## Quick start

Use the wrapper script:

```bash
"$PWCLI" open https://playwright.dev --headed
"$PWCLI" snapshot
"$PWCLI" click e15
"$PWCLI" type "Playwright"
"$PWCLI" press Enter
# For visual verification, show the screenshot in the conversation instead of saving it locally.
```

If the user prefers a global install, this is also valid:

```bash
npm install -g @playwright/cli@latest
playwright-cli --help
```

## Core workflow

1. Open the page with the wrapper.
2. Snapshot to get stable element refs.
3. Interact using refs from the latest snapshot.
4. Re-snapshot after navigation or significant DOM changes.
5. For visual verification, display screenshots in the conversation only; do not save local screenshot files unless the user explicitly asks for an artifact.
6. If a command fails, record the command, exit code, and stderr before trying a workaround.

Minimal loop:

```bash
"$PWCLI" open https://example.com
"$PWCLI" snapshot
"$PWCLI" click e3
"$PWCLI" snapshot
```

## Failure triage order

When Playwright "fails", diagnose in this order:

1. Environment startup
   - Did browser startup fail before any page opened?
   - Look for permission errors around `ms-playwright`, `daemon`, temp/profile directories.
2. CLI command outcome
   - Check exit code and stderr from the shell command.
   - Do not infer success or failure from an empty output file alone.
3. Page-level evidence
   - Use `snapshot`, browser console logs, and screenshots only after startup succeeds.
   - A page console error like missing `favicon.ico` is usually noise, not the main failure.

## When to snapshot again

Snapshot again after:

- navigation
- clicking elements that change the UI substantially
- opening/closing modals or menus
- tab switches

Refs can go stale. When a command fails due to a missing ref, snapshot again.

## Recommended patterns

### Form fill and submit

```bash
"$PWCLI" open https://example.com/form
"$PWCLI" snapshot
"$PWCLI" fill e1 "user@example.com"
"$PWCLI" fill e2 "password123"
"$PWCLI" click e3
"$PWCLI" snapshot
```

### Debug a UI flow with traces

```bash
"$PWCLI" open https://example.com --headed
"$PWCLI" tracing-start
# ...interactions...
"$PWCLI" tracing-stop
```

### Multi-tab work

```bash
"$PWCLI" tab-new https://example.com
"$PWCLI" tab-list
"$PWCLI" tab-select 0
"$PWCLI" snapshot
```

## Wrapper script

The wrapper script uses `npx --package @playwright/cli playwright-cli` so the CLI can run without a global install:

```bash
"$PWCLI" --help
```

Prefer the wrapper unless the repository already standardizes on a global install.

## References

Open only what you need:

- CLI command reference: `references/cli.md`
- Practical workflows and troubleshooting: `references/workflows.md`

## Guardrails

- Always snapshot before referencing element ids like `e12`.
- Re-snapshot when refs seem stale.
- Prefer explicit commands over `eval` and `run-code` unless needed.
- When you do not have a fresh snapshot, use placeholder refs like `eX` and say why; do not bypass refs with `run-code`.
- Use `--headed` when a visual check will help.
- Use the wrapper workflow as the default path: `open -> snapshot -> interact -> snapshot`.
- Do not replace the CLI workflow with ad hoc render scripts, temporary HTML inliners, or shell-redirection chains unless the user explicitly asks for that approach.
- If you must generate local artifacts, save them under `tmp/playwright-temp/` by default. Use subfolders like `tmp/playwright-temp/screenshots/`, `tmp/playwright-temp/.playwright-cli/`, and `tmp/playwright-temp/localappdata/`; do not scatter temporary Playwright files across the repo.
- For screenshots and visual verification, prefer showing the image in the conversation. Do not save screenshots to the local workspace unless the user explicitly requests a file artifact.
- When the user explicitly requests saved artifacts such as PDFs, traces, or screenshot files, still place them under `tmp/playwright-temp/` unless the user explicitly asks for a persistent output location.
- If a command fails, preserve stderr and exit code in the transcript before trying a workaround. Do not treat an empty `.yml`, `.json`, or output file as enough evidence of what failed.
- Default to CLI commands and workflows, not Playwright test specs.

