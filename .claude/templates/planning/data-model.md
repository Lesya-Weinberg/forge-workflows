# Data Model — {{Feature Name}}
feature: {{feature-slug}}  |  owner: data-engineer  |  consumes: design-doc.md, functional-spec.md
last-revised: {{YYYY-MM-DD}}
<!-- Entities, relationships, integrity, movement. Migrations are authored, NEVER run. -->

## Entities & relationships
{{Entities, keys, relationships, ownership.}}

## Integrity & retention
{{Constraints, validation, retention/lifecycle.}}

## Migrations (authored — queued for human execution)
| Migration file | Target env | Reversible? | Depends-on | Ledger entry |
|---|---|---|---|---|
| operations/db/migrations/{{file}} | {{}} | {{yes/no}} | {{}} | operations/db/pending.md |

## Pipeline design  <!-- Meticulous+ -->
{{Sources, transforms, sinks, scheduling.}}
