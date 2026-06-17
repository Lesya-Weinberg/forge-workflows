# Backlog — Ready
<!-- The delivery queue: items whose Definition of Ready has passed. -->
<!-- backlog-planner MOVES Ready items in from backlog-draft.md (status → Ready).
     The orchestrator flips status Ready → In-Sprint when a sprint takes the item, and MOVES the
     block out to backlog-done.md when the item passes review / the sprint closes.
     One block per item, highest priority first. This file stays small and hot — it is the
     read list for tech-lead, security-engineer (delivery), and patcher. -->

---
## [{{item-id}}] {{Item title}}
priority: {{1..n}}  |  status: {{Ready|In-Sprint}}  |  tier: {{suggested tier}}
traces-to: {{prd.md, functional-spec.md, design-doc.md, threat-model.md, ...}}
depends-on: {{item-id(s) or none}}

**Goal:** {{one sentence — the deliverable outcome}}

**Acceptance criteria**
- {{checkable AC}}
- {{security AC appended by security-engineer, if any}}

**Definition of Ready** (all passed — recorded for audit)
- [x] Referenced design specs exist and are internally consistent
- [x] Acceptance criteria stated and checkable
- [x] Dependencies resolved or sequenced
- [x] Independently deliverable (or split into items that are)

**Stub flag:** {{stub: active — <patch-id> + expiry, or none}}
---
