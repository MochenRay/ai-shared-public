# Skills Infrastructure Handover

> Public-safe handover template derived from the private skills-governance
> project. Private local paths, migration logs, backup names, and machine-specific
> state are intentionally omitted.

## Current Snapshot

- Universal skills use `${HOME}/.agents/skills/` as the shared truth layer.
- Host-specific skill directories are treated as discovery or projection layers.
- Cross-model skill installation should default to the universal layer unless a
  user explicitly requests a single host target.

## Important Files

- `rules/skills-governance.md`
- `playbooks/unified-dev-pipeline-sync.md`
- `projects/SkillsInfrastructure/project.md`
- `EXTERNAL_REFERENCES.md`

## Operating Rules

- Edit universal skill content only in the shared skills truth layer.
- Use host-specific skill homes only for tool-native/plugin-managed exceptions.
- After adding or updating a universal skill, verify visibility from each target
  host or its documented mirror.
- Keep upstream-diff and sync procedures separate from project memory.

## Next Checks

- Confirm host-specific mirrors still point back to the universal skill layer.
- Re-run upstream drift checks for skills that track external GitHub sources.
- Update this handover when the public governance model changes.
