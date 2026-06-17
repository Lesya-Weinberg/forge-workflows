# Tier Activation Matrix

The orchestrator consults this when routing. Tier is recorded in `active.md`. It decides which
roles fire and at what depth. `✅` = full depth · `◐` = reduced scope (see note) · `—` = skip.
Depth is conveyed to each agent in the delegation prompt and reflected in tier-aware templates;
roles are NOT duplicated per tier.

| Role / Phase | Hotfix | Nano | Lite | Standard | Meticulous | Full |
|---|---|---|---|---|---|---|
| **PLAN** |
| product-manager | — | ◐ brief + task list | ◐ short PRD + stories | ✅ PRD + stories | ✅ + dependency map | ✅ + compliance hooks |
| business-analyst | — | — | — | ✅ functional spec + rules | ✅ + traceability matrix | ✅ + compliance mapping |
| ux-researcher | — | — | — | ◐ synthesized personas | ✅ research plan + journeys | ✅ + primary research |
| ux-designer | — | — | — | ✅ ux-spec + flows | ✅ + design tokens | ✅ + usability test plan |
| solution-architect | — | — | ◐ impl notes, no design doc | ✅ design-doc + contracts + ADRs | ✅ + spike/PoC | ✅ + formal arch review |
| security-engineer | — | — | ◐ inline OWASP self-check | ✅ threat-model + review | ✅ + STRIDE + compliance | ✅ + pen-test plan |
| data-analyst | — | — | — | ✅ instrumentation spec | ✅ + experiment design | ✅ + ML/BI requirements |
| data-engineer | — | — | — | ◐ if pipelines in scope | ✅ data-model + pipeline | ✅ + data catalog |
| config-manager | — | — | ◐ env vars inline | ✅ flags + env | ✅ + secrets rotation | ✅ + access controls |
| backlog-planner | — | ◐ tasks only | ✅ items + DoR | ✅ items + DoR | ✅ + risk notes | ✅ + risk notes |
| **DELIVER** |
| tech-lead (tech-design) | — | ◐ task list only | ◐ task list, no test strategy | ✅ tech-design + tests + DoD | ✅ + harness validation | ✅ + arch alignment |
| implementer (on active branch) | — | ✅ | ✅ | ✅ | ✅ | ✅ |
| tester | — | ◐ unit only | ◐ unit + integration | ✅ unit + integration + e2e | ✅ + perf baseline | ✅ + perf + a11y audit |
| reviewer | — | ◐ light | ✅ | ✅ | ✅ | ✅ + security validation |
| devops-engineer (build/deploy) | — | — manual | ◐ basic CI, no runbook | ✅ pipeline + runbooks | ✅ + canary | ✅ + progressive delivery |
| sre | — | — | — | ◐ pre-deploy checklist | ✅ SLOs + reliability review | ✅ + chaos readiness |
| **CLOSEOUT** |
| technical-writer | ◐ changelog | ◐ changelog | ◐ changelog + README | ✅ README + API ref + changelog | ✅ + arch notes | ✅ + KB update |
| scrum-master | — | — | ◐ completion note | ✅ sprint-review + retrospective | ✅ + risk register | ✅ |
| **HOTFIX** |
| patcher | ✅ only role | — | — | — | — | — |

## Notes
- **Hotfix tier** runs ONLY the `patcher` via the deliver-workflow `hotfix.md` profile: no
  planning, no sprint folder, one-sentence scope gate, patch record only.
- **Nano** keeps a sliver of planning (PM brief) then a thin deliver path (implementer + unit
  tests + changelog). Use for single-file features and small scripts.
- **Upgrade tier mid-stream if scope expands; never downgrade** (you would lose required gates).
- `data-engineer` and `data-analyst` activate at Standard only if the feature actually involves
  pipelines / instrumentation; otherwise skip even at Standard.

## Model dial (per-tier model override)
Tier scales not just *which* roles fire but *how much model* they deserve. The orchestrator sets a
per-spawn model through the `Agent` tool's `model` override (it takes precedence over the agent's
frontmatter, which holds only the default). Apply this dial when delegating:

| Tier | Reasoning-critical roles* | Everyone else |
|---|---|---|
| Hotfix / Nano / Lite / Standard | agent default (sonnet) | agent default |
| Meticulous / Full | **opus** | agent default |

*Reasoning-critical = `solution-architect`, `security-engineer`, `tech-lead`, `reviewer` — the roles
whose misses are expensive (a weak ADR, a missed threat, a shallow review). `config-manager` and
`technical-writer` stay `haiku` at every tier (mechanical work). The dial only ever *raises* model
strength at high tiers; it never lowers the already-lean floor. The orchestrator's own model is fixed
at launch and is not part of this dial.
