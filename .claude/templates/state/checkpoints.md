# Checkpoints — {{feature-slug}}
<!-- Advisory checkpoints + hard gates. Orchestrator and human write; subagents never do.
     Advisory statuses: PENDING | APPROVED | CHANGES-REQUESTED. Hard gates: OPEN | DONE-BY-HUMAN. -->

## Advisory checkpoints  (skippable per gate_policy)
| Boundary | Status | Note |
|---|---|---|
| {{after-architecture}} | {{PENDING/APPROVED/CHANGES-REQUESTED}} | {{}} |
| {{after-security}} | {{}} | {{}} |
| {{before-build}} | {{}} | {{}} |

## Hard gates  (always require explicit human action)
| Gate | Status | Detail |
|---|---|---|
| {{deploy/release}} | {{OPEN/DONE-BY-HUMAN}} | {{}} |
| {{run migration(s)}} | {{}} | {{see operations/db/pending.md}} |
