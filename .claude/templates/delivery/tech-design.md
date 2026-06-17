# Tech Design — {{Item title}}
item: {{item-id}}  |  sprint: {{sprint-id}}  |  owner: tech-lead  |  tier: {{tier}}
consumes: backlog item {{item-id}} + {{design-doc.md, functional-spec.md, ux-spec.md, threat-model.md, ...}}
last-revised: {{YYYY-MM-DD}}
<!-- The delivery unit / ticket. No product code. Lite: task list section only. -->

## Acceptance criteria (each traces to a rule)
- AC1: {{given … → …}} ⟵ {{functional/security rule ref}}

## Non-functional requirements
- {{perf budget}}
- Architecture hard rules honored: {{which, from CLAUDE.md}}
- Persistence: {{integrity/round-trip requirement, or n/a}}

## Implementation approach
{{Concrete against the Project Stack: modules, interfaces, contracts, files that change.}}

## Pre-flight (Standard+)
- [ ] Design & requirements artifacts internally consistent (conflicts resolved here)
- [ ] One throwaway test per layer executes (env validated)

## Task breakdown
<!-- `touches` = the exact files/dirs this slice will create or edit (its ownership set).
     `parallel-safe: yes` ONLY when this slice's touch set is disjoint from every other
     parallel-safe slice AND none of them co-edit a shared mutable file (manifest/lockfile,
     barrel/index, route or DI registry, generated code, migration sequence). If a shared file
     must change, pull that change into its own prerequisite slice (parallel-safe: no) that runs
     first. The orchestrator runs parallel-safe slices concurrently on the active branch. -->
| task-id | description | depends-on | parallel-safe | touches (file/dir ownership set) |
|---|---|---|---|---|
| T1 | {{}} | {{T- or none}} | yes/no | {{paths this slice owns — must be disjoint from co-running slices}} |

## Test plan
{{What the tester must cover; which AC/rule maps to which assertion. Layers per tier.}}

## Definition of Done
AC met + NFRs honored + tests green + review PASS.
