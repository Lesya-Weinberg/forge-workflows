# Deliver profile — Nano

Single-file feature or small script. Thin path, but a real sprint folder (unlike Hotfix).

**Roles:** `implementer` (✅), `tester` (◐ unit tests only), `technical-writer` (◐ changelog).
**Skipped:** tech-lead (the PM brief + backlog task is enough of a ticket), reviewer (light
self-review by implementer), devops (manual deploy by human), sre, scrum-master.

**Sequence:** implementer builds the task and writes unit tests in the same pass → writes an
impl-report → technical-writer appends a changelog entry. The implementer runs the tests before
marking DONE.

**Gate:** default `auto-proceed`. Surface only `BLOCKED:` and hard gates (e.g. a needed migration).
