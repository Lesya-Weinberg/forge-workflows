# Development State
updated: {{YYYY-MM-DDTHH:MMZ}}  |  owner: orchestrator
<!-- Whole-project SNAPSHOT — current state plus pointers to history, NEVER the history itself.
     Rewritten in full from this template at session end; resume/audit from this alone.
     Keep every table bounded: show what is ACTIVE now, not every row ever recorded. If a section
     grows on each rewrite, it's holding history that belongs in an append-only log or archive this
     file points to (development-log.md / backlog-done.md) — move it there and leave a pointer. -->

## Current focus
{{One line: what the project is working on now.}}

## Design status  <!-- only areas still in flux; settled designs live in workstream/design/ & decisions/ -->
| Area | Latest artifact | status |
|---|---|---|
| {{feature/system still evolving}} | {{path}} | {{draft/settled}} |

## Sprints  <!-- active sprint + most recent closed only; full history → development-log.md, shipped items → backlog-done.md -->
| sprint-id | tier | phase | shipped | folder |
|---|---|---|---|---|
| {{id}} | {{}} | {{planning/executing/closed}} | {{summary}} | {{path}} |

## Backlog health
- Ready: {{n}}  |  Draft: {{n}}  |  Done: {{n}}

## Pending hard gates (human)
- {{queued migration / deploy, or none}}

## Open decisions (human)
- {{any standing BLOCKED, or none}}

## Next milestone
{{What "done enough to matter" looks like next.}}
