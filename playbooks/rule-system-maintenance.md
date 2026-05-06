# Rule System Maintenance

This playbook defines a compact audit frame for shared rule repositories.

## Layers

### Entrypoints

Entrypoint files should only load and route:

- root-level `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`
- tool-home entrypoints under `entrypoints/homes/`
- model adapters under `agents/`

They should not carry full policy bodies.

### Rules

Rules describe how agents should work:

- shared boundaries
- writeback rules
- sync rules
- safety constraints
- output style defaults

### Memory

Memory describes what is known:

- stable facts
- decisions
- project knowledge
- open questions

## Audit Checklist

### 1. Cross-File Contradiction

- Does one file allow what another forbids?
- Do two files define different step orders for the same workflow?
- Are tools, roles, or paths described inconsistently?

### 2. Buried Rules

- Are important constraints hidden after long background sections?
- Should a long rule file be split into an index plus topic files?

### 3. File Growth

- Are project details leaking into the rule layer?
- Are old narratives kept where a current rule would suffice?
- Are command templates repeated across files?

### 4. Duplication

- Is the same rule repeated in multiple places?
- Can secondary locations become references instead of copies?

### 5. Stale References

- Do referenced paths still exist?
- Are named tools, commands, agents, schedules, or versions still current?
- Do date-sensitive notes have refresh dates?

### 6. Layer Violation

- Style files should not carry operational runbooks.
- Rule files should not carry project memory.
- Memory files should not carry policy-level rules.

## Repair Order

1. Fix contradictions and safety issues.
2. Move content to the correct layer.
3. Replace duplicate bodies with references.
4. Split oversized files into an index plus topic files.
5. Update indexes and validation scripts.
