# Design Doc — {{Feature Name}}
feature: {{feature-slug}}  |  owner: solution-architect  |  consumes: prd.md, functional-spec.md
last-revised: {{YYYY-MM-DD}}
<!-- The technical skeleton. Honors the Project Stack hard rules in CLAUDE.md. -->
<!-- Lite: implementation notes only; record an ADR for any durable decision. -->

## Component structure
{{Modules/components and their responsibilities, within the existing architecture.}}

## Interface / API contracts
| Contract | Shape (request/response or signature) | Errors |
|---|---|---|
| {{}} | {{}} | {{}} |

## Data flow
{{What data moves where, who owns it, how it's transformed.}}

## Non-functional requirements
- {{perf / scale / availability target}}
- Architecture hard rules honored: {{which, from CLAUDE.md}}

## Decisions (ADRs)
- ADR-{{NNN}}: {{title}} — see workstream/decisions/ADR-{{NNN}}-{{title}}.md

## Open architectural questions
- {{question or "none"}}
