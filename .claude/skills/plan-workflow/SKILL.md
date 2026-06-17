---
name: plan-workflow
description: The loose, creative planning process for the Forge agent team. Use whenever the human (via the orchestrator) wants to define or revise product direction before a sprint executes — vision, requirements, UX, architecture, security, data, or the backlog. Defines the planning artifact graph, the consume-and-produce rule, how planning is logged, the gate policy, and how a backlog item becomes Ready for delivery. The depth and which roles fire come from the per-tier profile (nano.md / lite.md / standard.md / meticulous.md / full.md) in this skill folder — read the one matching the tier in active.md. Always consult this in planning mode, even for a one-off design tweak.
---

# Plan workflow (loose by design)

Planning is deliberately non-sequential. The human may invoke any planner in any order, revisit a
spec, branch an idea, or reshape the backlog — and keep doing so until they choose to execute a
sprint. The orchestrator's job is to route, keep inputs honest, log, and apply the gate policy;
not to force a pipeline.

## First: resolve depth from the tier
Read `tier` from `active.md`, then read the matching profile in this folder
(`nano.md`, `lite.md`, `standard.md`, `meticulous.md`, `full.md`). That profile tells you which
planners fire and at what depth. Do not load profiles for other tiers. The full activation matrix
is in `.claude/skills/reference/tier-matrix.md`; the producer/consumer graph is in
`.claude/skills/reference/artifact-flow.md`.

## The artifact graph (depth-gated by tier)

```
vision ─► product-manager ─► prd
prd ─► business-analyst ─► functional-spec
prd ─► ux-researcher ─► research-brief
functional-spec (+research-brief) ─► ux-designer ─► ux-spec
prd + functional-spec ─► solution-architect ─► design-doc + ADRs
design-doc ─► security-engineer ─► threat-model (+ ACs onto backlog)
prd + design-doc ─► data-analyst ─► instrumentation-spec
data-model needs? ─► data-engineer ─► data-model
design-doc ─► config-manager ─► flags-catalog
all design artifacts ─► backlog-planner ─► draft items, then promote to Ready (DoR passes)
insights.md (prior-sprint lessons) ─► informs product-manager + backlog-planner
```

Planning artifacts live in `workstream/design/<feature>/`; ADRs in `workstream/decisions/`;
`vision.md`, `roadmap.md`, `backlog-draft.md`, and `backlog-ready.md` at `workstream/` root. Edits
revise the file in place. The backlog is split: `backlog-draft.md` (being shaped) → `backlog-ready.md`
(Ready queue) → `backlog-done.md` (shipped archive, written by the orchestrator). backlog-planner
moves an item from draft to ready when its Definition of Ready passes.

## How to route a planning request
1. Identify the deliverable the human wants; pick the one planner that owns it.
2. Confirm that planner fires at the current tier (profile + matrix). If the human wants a planner
   the tier would skip, allow it but note it's above-tier.
3. Check the planner's input artifact(s) exist. If an upstream artifact is missing and the human
   wants to skip ahead anyway, allow it but state what's being assumed; prefer commissioning the
   upstream artifact first.
4. Delegate with explicit input/output paths, the template to use, and the tier (for depth).
5. On return: log, then apply the gate policy (below). Offer the natural next step without forcing it.

## Parallel planning fan-out (agility)
Planning is read-mostly: each planner consumes shared upstream artifacts and writes its OWN file, so
independent planners don't collide the way implementers can. Spawn them concurrently in one batch
whenever their inputs already exist and their outputs are disjoint. Common safe fan-outs:
- after `prd.md` + `functional-spec.md`: `ux-designer` ∥ `solution-architect`;
- after `design-doc.md`: `security-engineer` ∥ `data-analyst` ∥ `data-engineer` ∥ `config-manager`.
Guards: every planner in a batch must (a) already have all its inputs on disk and (b) write a
different artifact — never co-spawn two planners that edit the same file. `backlog-planner` runs
*after* a batch, never inside it (it consumes the batch's outputs). Apply the gate policy once, when
the batch returns. Sequential routing is always a safe fallback.

## Gate policy (set in active.md)
- `auto-proceed` — keep routing; surface only `BLOCKED:` and hard gates.
- `review-on-open-issues` (default) — at a phase boundary, present a digest (artifacts produced,
  open questions, `[MISSING INPUT]` flags). Pause only if open issues exist; else proceed.
- `review-all` — present the digest and wait for human approval at every boundary.
Hard gates never apply in pure planning (no deploys/migrations are executed), but a planner that
*authors* a migration still only queues it — it is never run here.

## Looseness in practice
The human can say "change the threat model" or "add three backlog items" at any time. Re-invoke the
relevant planner; never tell them a phase is closed. Do not auto-advance to delivery.

## Readiness (the bridge to delivery)
An item becomes deliverable only when `backlog-planner` moves it from `backlog-draft.md` into
`backlog-ready.md` (status `Ready`) after its Definition of Ready passes (referenced specs exist and
are internally consistent; acceptance criteria stated; dependencies resolved; independently
deliverable). Until then it stays in `backlog-draft.md`.

## Logging
The orchestrator writes a one-line human summary from each `DONE:` line: to the sprint's
`sprint-log.md` if a sprint is in a planning phase (active.md points to it), otherwise to
`workstream/development-log.md`. Append-only, one line per action. The hooks separately stamp the raw
lifecycle event to `events-log.md` and token usage to `token-log.md` — those are the machine trace and
are not your write.

## Closing a planning session
Rewrite `development-state.md` (and `sprint-state.md` if a sprint is in planning) so the design
state is fully recoverable from disk alone.
