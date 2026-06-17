# Active
<!-- POINTER ONLY. This file answers two questions and nothing else:
     "what is current?" (the fields below) and "where do I look for more?" (the index below).
     NEVER put status, progress, history, narrative, backlog, or task lists here — those live in
     the files named in the index. If you're tempted to write a sentence of status, it belongs in
     development-state.md or sprint-state.md, not here. Keep this file scannable at a glance.
     Orchestrator may update individual fields mid-session, but REGENERATES this file in full from
     .claude/templates/state/active.md at session end — exactly like development-state.md and
     sprint-state.md. The full rewrite is a hard reset: anything outside these fixed slots is
     dropped, so drift cannot accumulate.
     The human may set feature, tier, and gate_policy. Hooks read sprint_path/mode/tier. -->

feature: none
name:
mode:
tier:
phase:
gate_policy: review-on-open-issues
sprint_path: none
started:
last_updated:

## Where state lives  <!-- fixed index. Update paths only, never inline their contents. -->
- Project snapshot & status → workstream/development-state.md
- Sprint snapshot & status  → {{sprint_path}}/sprint-state.md (when a sprint is active)
- Backlog (being shaped)    → workstream/backlog-draft.md
- Backlog (Ready / queue)   → workstream/backlog-ready.md
- Backlog (shipped archive) → workstream/backlog-done.md
- Gate / checkpoint status  → workstream/checkpoints.md
