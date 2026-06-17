# Deliver profile — Meticulous

Complex / data-heavy / security-sensitive. Everything in Standard, plus:

- `tech-lead` adds a test-harness validation step and reviews all prior artifacts for consistency
  before breakdown.
- `tester` adds a performance baseline.
- `reviewer` PASS requires the security review's acceptance criteria to be satisfied.
- `devops-engineer` uses a canary rollout in the deploy runbook.
- `sre` defines SLOs and runs a reliability review (not just a checklist).
- `data-engineer` fires for any data movement; its migrations are queued for human execution.

**Advisory checkpoints offered at every boundary.** HIGH/CRITICAL bugs or security findings are
hard `BLOCKED`s — no item passes with one open. Deploy and migrations remain hard gates.
