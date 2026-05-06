# External References

> Public export note: these are structural references used by this shared-context
> pattern. They are not included in this repository and may differ by machine or
> tool installation.

## Repository Path

- `/path/to/AI-Shared`

Use this as the local path to the shared context repository. Scripts also support
`AI_SHARED_ROOT` where applicable.

## Entrypoint Projections

These files are optional local projections of the shared entrypoints:

- `${HOME}/AGENTS.md`
- `${HOME}/CLAUDE.md`
- `${HOME}/GEMINI.md`
- `${HOME}/.codex/AGENTS.md`
- `${HOME}/.claude/CLAUDE.md`
- `${HOME}/.gemini/GEMINI.md`
- `${HOME}/.kimi/AGENTS.md`

The source templates live under `entrypoints/`. Treat deployed local copies as
projections, not as the canonical source.

## Tool Runtime Homes

These directories belong to their host tools. They can contain history, sessions,
SQLite/jsonl state, credentials, caches, plugin data, plans, and current settings.

- `${HOME}/.codex`
- `${HOME}/.claude`
- `${HOME}/.gemini`
- `${HOME}/.kimi`

They are intentionally outside the public export. Do not publish them.

## Universal Skills

Universal Agent Skills use a separate truth layer:

- `${HOME}/.agents/skills/`
- `${HOME}/.agents/.skill-lock.json`

This repository may document skill governance, but the skill files themselves are
external assets. Install or update universal skills in `${HOME}/.agents/skills/`,
not inside this shared context repository.

## Claude Skill Mirror

Claude Code may need a symlink mirror:

- `${HOME}/.claude/skills/`
- `${HOME}/.claude/scripts/sync-claude-skills.sh`

The mirror points back to `${HOME}/.agents/skills/`. It is a discovery layer, not
the skill truth layer.

## Skill Upstream And Plugins

Common referenced helper paths:

- `${HOME}/.claude/scripts/upstream-diff.py`
- `${HOME}/.claude/plugins/cache/`
- `${HOME}/.codex/skills/`
- `${HOME}/.gemini/skills/`

Plugin-managed skills and tool-native skills may live in host-specific locations.
Only universal cross-tool skills belong in `${HOME}/.agents/skills/`.

## Environment Variables

- `AI_SHARED_ROOT`: override shared repository root for scripts.
- `AI_SHARED_MANIFEST`: override manifest path for validation.
- `SYNC_QUEUE_PATH`: override sync queue path.
- `AI_SHARED_PUBLIC_ROOT`: override public export destination.

## External Commands

The workflow may reference:

- `rg`
- `git`
- `bash`
- `jq`
- `npx skills`
- `uvx detect-secrets`
- `gitleaks`

Only `git`, `bash`, and common POSIX utilities are required for basic reading.
Secret scanners are recommended before publishing a public export.
