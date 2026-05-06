# Rule Index

## Public Rule Files

- `policy.md`: shared-layer boundary, sync, conflict, and writeback rules
- `skills-governance.md`: cross-tool Agent Skills governance
- `core.md`: compatibility pointer to `policy.md`
- `memory-policy.md`: compatibility pointer to `policy.md`
- `sync-policy.md`: compatibility pointer to `policy.md`
- `output-style.md`: public output-style pointer

## Private Overlay

Private deployments may add local rule files for user profile, interaction style,
tool routing, or domain-specific preferences. Those files are intentionally not
included in this public export.

## Loading Rule

Start with `README.md` and `agents/<model>.md`. Read `rules/policy.md` only when
writing back to the shared layer or when boundaries are unclear.
