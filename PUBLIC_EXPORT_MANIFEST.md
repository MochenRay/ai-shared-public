# Public Export Manifest

> Generated from a private AI-Shared working tree.
> This repository is a sanitized public export, not the private source of truth.

## Export Goal

Publish the mechanism, design, and reusable operating logic of a cross-model
shared context repository without publishing private memory, credentials,
personal profile material, private project records, or local runtime state.

## Included Paths

- `README.md`
- `manifest.md`
- `AGENTS.md`
- `CLAUDE.md`
- `GEMINI.md`
- `agents/*.md`
- `entrypoints/**/*.md`
- `rules/README.md`
- `rules/core.md`
- `rules/memory-policy.md`
- `rules/output-style.md`
- `rules/policy.md`
- `rules/skills-governance.md`
- `rules/sync-policy.md`
- `playbooks/*.md`
- `scripts/*.sh`
- `projects/SharedAIContext/project.md`
- `projects/SkillsInfrastructure/project.md`

## Excluded Paths

- `.git/`
- `backups/`
- `archive/`
- `profile/`
- `memory/`
- `handoff/`
- private project folders under `projects/`
- local runtime folders such as `.codex`, `.claude`, `.gemini`, `.kimi`
- any deploy keys, credentials, sqlite/jsonl files, logs, sessions, caches, or lock files

## Sanitization Rules

- Private absolute paths are replaced with placeholders such as `/path/to/AI-Shared` or `${HOME}`.
- Private names, domains, host names, project names, and notification channel IDs are replaced with generic terms.
- Historical migration notes and project handover snapshots are not included unless they are already generic.
- The public export should be initialized as a new Git repository with clean history.

## Pre-Publish Checks

Run from the public export root:

```bash
find . -type d -name .git -o -path './backups*' -o -path './profile*' -o -path './memory*' -o -path './handoff*' -o -path './archive*'
rg -n --hidden --glob '!/.git/**' 'PRIVATE_USER|PRIVATE_ORG|PRIVATE_DOMAIN|PRIVATE_CHANNEL_ID'
rg -n --hidden --glob '!/.git/**' 'password|credential|credentials|api_key|apikey|bearer|oauth'
```

If `gitleaks` is available:

```bash
gitleaks detect --no-git --source .
```
