# Artifact Flow Map

Defines every artifact, who produces it, and who must consume it. The Consumer column drives each
agent's read list — agents read every artifact named as their input. If an expected upstream
artifact is missing, the agent writes `[MISSING INPUT: <path>]` and flags it; the orchestrator
escalates before advancing. Activation is gated by tier (see `tier-matrix.md`) — an artifact is
only expected if its producer fires at the current tier.

Durable design artifacts live in `workstream/design/<feature>/`; ADRs in `workstream/decisions/`;
execution artifacts in `workstream/sprints/<id>/`; ops artifacts in `workstream/operations/`.

## PLAN mode

| Producer | Artifact | Template | Consumed by |
|---|---|---|---|
| product-manager | `prd.md` | planning/prd | business-analyst, ux-*, solution-architect, security, data-*, tech-lead, backlog-planner |
| business-analyst | `functional-spec.md` | planning/functional-spec | solution-architect, ux-designer, tech-lead, tester, security |
| ux-researcher | `research-brief.md` | planning/research-brief | ux-designer |
| ux-designer | `ux-spec.md` | planning/ux-spec | tech-lead, implementer, tester |
| solution-architect | `design-doc.md` | planning/design-doc | tech-lead, security, data-*, devops, sre, technical-writer |
| solution-architect | `ADR-NNN-*.md` | planning/adr | tech-lead, implementer, technical-writer |
| security-engineer | `threat-model.md` + appends ACs to the item's backlog block | planning/threat-model | tech-lead, implementer, tester |
| data-analyst | `instrumentation-spec.md` | planning/instrumentation-spec | implementer, data-engineer, scrum-master |
| data-engineer | `data-model.md` | planning/data-model | implementer, tech-lead |
| config-manager | `flags-catalog.md` | planning/flags-catalog | implementer, devops, config-manager |
| backlog-planner | `backlog-draft.md` + `backlog-ready.md` (items + Definition of Ready; promotes draft→ready) | planning/backlog-draft, planning/backlog-ready | tech-lead, tester, scrum-master |
| orchestrator | `backlog-done.md` (shipped-item archive, by sprint) | planning/backlog-done | scrum-master, future planning |

## DELIVER mode

| Producer | Artifact | Template | Consumed by |
|---|---|---|---|
| tech-lead | `tech-design-<item>.md` | delivery/tech-design | implementer, tester, reviewer, technical-writer |
| implementer | code in project tree + `impl-report-<item>[-<task>].md` | delivery/impl-report | tester, reviewer |
| tester | test code + `test-report-<item>.md` | delivery/test-report | reviewer |
| reviewer | `review-<item>.md` (PASS / CHANGES-REQUESTED) | delivery/review | devops (on PASS), orchestrator |
| devops-engineer | build/CI config + `build-report-<item>.md` | delivery/build-report | sre, technical-writer |
| devops/data-engineer | migration file + ledger entry | operations/migration-record | **human (hard gate)** |
| sre | `slo.md` updates + runbook | operations/runbook | technical-writer |
| technical-writer | `changelog`, README, API ref updates | (project docs) | scrum-master |
| scrum-master | `sprint-review.md`, `retrospective.md` + feeds `insights.md` | delivery/sprint-review, delivery/retrospective | human; `backlog-planner` + `product-manager` (next planning cycle) |

## HOTFIX tier

| Producer | Artifact | Template | Consumed by |
|---|---|---|---|
| patcher | fixed/stubbed code + `patch-<id>.md` | delivery/patch-record | human; backlog (for stubs, with expiry) |

## Consumption-gap protocol
1. Missing input → write `[MISSING INPUT: <path>]` at the top of your output.
2. Note it in your return to the orchestrator under blockers.
3. Do not silently proceed past a missing dependency the artifact materially needs.
The orchestrator reads these flags after each phase and escalates per the gate policy.
