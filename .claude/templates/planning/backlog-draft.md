# Backlog — Draft
<!-- Items being shaped, not yet Ready. Maintained by backlog-planner. -->
<!-- One block per item, highest priority first. When an item's Definition of Ready passes,
     backlog-planner MOVES the whole block out of this file and into backlog-ready.md. -->

---
## [{{item-id}}] {{Item title}}
priority: {{1..n}}  |  status: Draft  |  tier: {{suggested tier}}
traces-to: {{prd.md, functional-spec.md, design-doc.md, threat-model.md, ...}}
depends-on: {{item-id(s) or none}}

**Goal:** {{one sentence — the deliverable outcome}}

**Acceptance criteria**
- {{checkable AC}}
- {{security AC appended by security-engineer, if any}}

**Definition of Ready** (all must pass before the block moves to backlog-ready.md)
- [ ] Referenced design specs exist and are internally consistent
- [ ] Acceptance criteria stated and checkable
- [ ] Dependencies resolved or sequenced
- [ ] Independently deliverable (or split into items that are)

**Blocking gap:** {{exact gap keeping this item out of Ready}}
**Stub flag:** {{stub: active — <patch-id> + expiry, or none}}
---
