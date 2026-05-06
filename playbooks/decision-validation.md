# Decision Validation Checklist

Use this checklist before a significant feature, architecture plan, or workflow
change enters implementation. For each item, mark: aligned, uncertain, or
violated.

If any item is violated, stop and repair the plan before execution.

## Checks

### 1. Tool Fit

Does each task use the right execution surface?

- local code and file edits -> local coding agent
- long-running batch work -> async worker
- broad research or multimodal work -> research-capable model/tool
- docs, PRDs, and review -> writing/review-capable model/tool
- workspace databases or notes -> the relevant workspace connector

### 2. Execution Boundary

Does the plan distinguish interactive judgment work from batch/background work?

- judgment-heavy work should keep a human review point
- batch work should have clear input, output, timeout, and reporting expectations

### 3. Safety Boundary

Does the plan include high-risk operations?

- bulk edits
- deletes
- directory moves
- overwrite-style replacements
- credential, account, payment, legal, medical, or financial surfaces

If yes, add an explicit confirmation or verification gate.

### 4. Causal Chain

Before presenting the plan, ask:

1. Is the causal chain verified?
2. Is the current state checked?
3. What happens if this fails?

### 5. Human Checkpoint

Does the plan preserve human judgment where it matters?

- AI proposes
- human approves irreversible or strategic choices
- implementation proceeds after boundaries are clear

### 6. Complexity Fit

Does the plan match the actual problem size?

- simple need -> simple solution
- avoid speculative abstraction
- solve the present known problem first

## Trigger

Use for new feature plans, architecture changes, and plans that feel unusually
complex. Skip for small bug fixes and narrow single-file edits.
