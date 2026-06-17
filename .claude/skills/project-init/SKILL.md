---
name: project-init
description: One-time project bootstrap for the Forge scaffold. Use when the Project Stack block in CLAUDE.md still reads [UNSEEDED], or when workstream/vision.md is empty or absent — i.e. the project has not been initialized. Walks the human through seeding the technology stack, architecture hard rules, and product vision so every downstream agent has the context it needs. The orchestrator checks for this condition at the start of every session and loads this skill if seeding is incomplete. Do not run delivery or planning work on an unseeded project.
---

# Project initialization

A fresh Forge project is inert until two things are seeded: the **Project Stack** block in
`CLAUDE.md` (so every agent knows the technology and the hard rules) and **`workstream/vision.md`**
(so planning has a root to consume). This skill is how the orchestrator helps the human do that.

## When to run
At session start the orchestrator checks:
- Does `CLAUDE.md`'s Project Stack block still contain `[UNSEEDED]`?
- Is `workstream/vision.md` empty or missing?

If either is true, run this skill before anything else. If both are seeded, skip it entirely.

## Steps (orchestrator-led, human-answered)

1. **Detect.** Read `CLAUDE.md` and `workstream/vision.md`. Report to the human exactly what is
   missing. Do not guess any of it.

2. **Seed the stack.** Ask the human for each Project Stack field, one batched question set
   (use AskUserQuestion where the choices are bounded):
   - product type, language/runtime, frameworks/libs, persistence, test stack, build/deploy target;
   - the **architecture hard rules** — the "never do this" list (layering, module boundaries,
     forbidden dependencies, the one or two invariants that must never be violated).
   Write the answers into the Project Stack block, replacing every `[UNSEEDED]`.

3. **Seed the vision.** Capture the human's product direction into `workstream/vision.md`:
   the problem, who it's for, the shape of the solution, and what "good" looks like. Keep it to
   what planning genuinely needs — this is a root artifact, not a spec.

4. **Optional roadmap.** If the human has a sequence of features in mind, capture it in
   `workstream/roadmap.md`. Otherwise leave it as a stub.

5. **Confirm and record.** Re-read the Project Stack block to confirm no `[UNSEEDED]` remains.
   Append a milestone line to `workstream/development-log.md` ("project initialized") and write
   `development-state.md` from the state template.

## Rules
- The architecture hard rules you seed here become law for every implementer and reviewer. Be
  specific; vague rules can't be enforced.
- If the human is unsure of a field, mark it `[TODO: confirm]` rather than inventing a value, and
  surface it again before the first delivery sprint.
- Do not author product code or design artifacts during init — this skill only establishes context.
