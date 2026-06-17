# Instrumentation Spec — {{Feature Name}}
feature: {{feature-slug}}  |  owner: data-analyst  |  consumes: prd.md, design-doc.md
last-revised: {{YYYY-MM-DD}}
<!-- The events that make each success criterion measurable. Precise enough to implement. -->

## Events
| Event | Trigger | Properties | Measures (success criterion) |
|---|---|---|---|
| {{event_name}} | {{when emitted}} | {{props}} | {{which PRD criterion}} |

## Metrics
- {{metric}} = {{definition from the events above}}

## Deferral note (filled by implementer if any event is deferred)
- {{event}} deferred because {{reason}} → backlog item {{id}}
