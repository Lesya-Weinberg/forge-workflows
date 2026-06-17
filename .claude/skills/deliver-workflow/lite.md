# Deliver profile — Lite

Small feature / internal tool.

**Roles:** `tech-lead` (◐ task list only, no separate test strategy), `implementer` (✅, on the
active branch — parallel across file-disjoint slices, else sequential), `tester` (◐ unit + integration), `reviewer` (✅), `devops-engineer`
(◐ basic CI check, no runbooks), `technical-writer` (◐ changelog + README section),
`scrum-master` (◐ brief completion note).
**Skipped:** sre.

**Sequence:** the full per-item gate sequence, but tech-lead produces a task list (not a full
tech-design), and devops does a CI check rather than a deploy pipeline. Deploy remains a hard gate.

**Gate:** default `review-on-open-issues`.
