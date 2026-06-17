# Plan profile — Meticulous

Complex, data-heavy, or security-sensitive features.

**Everything in Standard, deepened, plus:** `business-analyst` adds a requirements traceability
matrix; `ux-researcher` runs a full research plan + journey maps; `solution-architect` adds a
spike/PoC for novel tech and may run a formal architecture review; `security-engineer` runs full
STRIDE + a compliance checklist; `data-analyst` adds experiment design; `data-engineer` fires
(data-model + pipeline-design) whenever any data movement exists.

**Advisory checkpoints offered at every phase boundary** (the human can still waive via
`auto-proceed`). HIGH/CRITICAL security findings and any unresolved compliance item are hard
`BLOCKED`s. Any database change is authored as a migration and queued in
`workstream/operations/db/pending.md` — never run during planning.
