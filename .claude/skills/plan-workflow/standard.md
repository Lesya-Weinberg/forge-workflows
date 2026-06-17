# Plan profile — Standard (default)

Most user-facing features.

**Planners that fire (full depth unless noted):** `product-manager` (PRD + stories),
`business-analyst` (functional-spec + business rules), `ux-researcher` (◐ synthesized personas
only), `ux-designer` (ux-spec + flows), `solution-architect` (design-doc + API/interface contracts
+ ADRs), `security-engineer` (threat-model + review), `data-analyst` (instrumentation-spec — only
if the feature has measurable behaviour), `data-engineer` (only if pipelines are in scope),
`config-manager` (flags + env), `backlog-planner` (items + DoR).

**Advisory checkpoints offered at:** after architecture & ADRs (ADRs are durable — review
carefully), and after security if any HIGH/CRITICAL finding exists (that finding is a `BLOCKED`
until resolved). Gate policy decides whether each pauses.

**Synthesize before the backlog:** the orchestrator checks that the functional-spec, ux-spec, and
design-doc are mutually consistent (same entities, flows, contracts) before backlog-planner runs.
Note conflicts in development-state.md.
