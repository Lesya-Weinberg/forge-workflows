# Deliver profile — Standard (default)

Most features. The full per-item gate sequence at full depth.

**Roles:** `tech-lead` (tech-design + task breakdown + test strategy + DoD), `implementer` (✅,
on the active branch — parallel across file-disjoint parallel-safe slices, else sequential; see SKILL.md), `tester` (✅ unit + integration + e2e),
`reviewer` (✅ vs DoD), `devops-engineer` (✅ pipeline + deploy/rollback runbooks),
`sre` (◐ pre-deploy checklist), `technical-writer` (✅ README + API ref + changelog),
`scrum-master` (✅ sprint-review + retrospective).

**Tech-lead pre-flight (cross-cutting rule):** before task breakdown, confirm the design and
requirements artifacts are internally consistent (resolve conflicts here, not mid-implementation),
and validate one throwaway test per layer (unit/integration/e2e) executes — catch environment
issues now, not at the tester gate.

**Hard gates:** deploy/release and any queued migration. **Advisory checkpoint** offered before
build. Gate policy decides whether it pauses.
