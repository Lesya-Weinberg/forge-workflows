---
name: deliver-workflow
description: The strict, sequential delivery process for the Forge agent team. Use whenever the human (via the orchestrator) wants to execute a sprint — turning Ready backlog items into implemented, tested, reviewed, and built code — or to apply a Hotfix (a small, already-decided change). Defines the mandatory per-item gate sequence, when to parallelize implementers in worktrees, the review loop, hard gates, and sprint folder/log/state discipline. The depth and which roles fire come from the per-tier profile (hotfix.md / nano.md / lite.md / standard.md / meticulous.md / full.md) in this skill folder — read the one matching the tier in active.md. Always consult this in delivery mode.
---

# Deliver workflow (strict by design)

Delivery is controlled and sequential so quality is repeatable. Every item moves through the same
gates in the same order. No skipping.

## First: resolve depth from the tier
Read `tier` from `active.md`, then read the matching profile in this folder. **Hotfix tier reads
`hotfix.md` and follows the bypass — no sprint, no planning.** All other tiers (`nano`, `lite`,
`standard`, `meticulous`, `full`) read their profile for which roles fire and how deep. The role
matrix is in `.claude/skills/reference/tier-matrix.md`; the artifact graph in
`.claude/skills/reference/artifact-flow.md`.

## Opening a sprint (Nano and above)
1. Confirm with the human which Ready items (from `workstream/backlog-ready.md`) are in scope.
2. Create `workstream/sprints/<sprint-id>/` with a fresh `sprint-state.md` (state template), an
   empty `sprint-log.md`, and an empty `token-log.md`.
3. Point `workstream/active.md` at it: set `sprint_path`, `mode: deliver`, the `tier`, and phase
   `executing`. Summarize "sprint opened" into `development-log.md`.
4. Refuse to start any item that is not `Ready` — send it back to planning instead.

## Per-item gate sequence (mandatory order)
```
1. tech-lead       -> tech-design-<item>.md     (the ticket: AC, NFR, plan, task breakdown, DoD)
2. implementer ×N  -> code + impl-report         (on the active branch; parallel across file-disjoint parallel-safe slices, else sequential)
3. tester          -> tests + test-report        (one tester per item, after all slices land)
4. reviewer        -> review-<item>.md           (PASS or CHANGES-REQUESTED)
5. devops-engineer -> build-report               (only after PASS; deploy/release is a HARD GATE)
```
Each step's output is the next step's input — always pass the prior artifact's path in the next
delegation. Which of steps 3–5 run, and how deep, is set by the tier profile.

## Sequencing & parallelizing implementers
Implementers always work **on the active branch**, never in automatic worktrees (those branch from
the default branch and their commits are skipped by the auto-commit hook). Read the tech-design's
task breakdown and run slices in dependency order. Never parallelize tech-lead, tester, or reviewer
for the same item.

**Parallel on the branch — the way to parallelize.** Spawn one `implementer` per slice marked
`parallel-safe: yes` whose `touches` set is disjoint from the others running, concurrently in the
same working directory (no worktree). Disjoint file ownership is what prevents collisions. Guards:
- co-run only slices with pairwise-disjoint `touches` sets that share no mutable manifest (lockfile,
  barrel/index, route/DI registry, generated code, migration sequence); if touch sets weren't
  declared, run sequentially;
- never run the full build/test suite in two slices at once — each runs only its own unit tests, the
  suite runs once at the tester gate;
- auto-commit interleaves snapshots (lock-serialized, no work lost); use `FORGE_AUTOCOMMIT=0` for the
  parallel window if you want clean per-slice commits;
- a slice that hits a real cross-slice dependency must `BLOCKED` so the orchestrator re-sequences.

Dependent or non-parallel-safe slices run **sequentially** on the branch. Sequential is the safe
default whenever parallel-safety isn't clearly established.

**Manual worktree (narrow fallback):** only when slices need isolated *concurrent* build/test runs.
Create each from the current branch (`git worktree add <path> HEAD`) so the base is correct, then
merge back deliberately. Never use automatic `isolation: worktree`.

## Review loop
- `CHANGES-REQUESTED` → re-delegate the listed changes to an implementer, then re-run tester and
  reviewer. Repeat until PASS, subject to the rework cap in "Defects, rework & scope" below. Log each loop.
- `PASS` → proceed to build (per tier).

## Defects, rework & scope (the unhappy path)
Things go wrong — bug storms, work that balloons. Handle it through defined channels; never by
inventing files or expanding an item in place. This is what keeps the sprint folder from bloating.
- **Where defects live.** The tester's `test-report` ("Failures → rule violated") and the reviewer's
  `review` ("Required changes") ARE the defect record. They're regenerated each rework loop, so the
  *latest* report is always the current bug list — there is no separate, growing bug file. Do NOT
  create ad-hoc trackers (`activity.md`, `bugs.md`, notes files). If you feel you need one, the item
  has outgrown its scope — apply the circuit-breaker.
- **Rework circuit-breaker.** Loop implement→test→review on `CHANGES-REQUESTED`, but cap it: after
  **3 rework loops** on one item, OR when cumulative required changes exceed the item's original
  acceptance criteria, STOP. Fail the item, record it as a carry-over in `sprint-state.md`, and send it
  back to planning to be re-scoped or split. Surface this to the human. A non-converging item is a
  planning problem, not a grind-it-out problem.
- **Scope-change protocol.** Never grow an in-flight item's scope in place. Work discovered mid-sprint
  becomes a NEW backlog item (draft → Ready) for a later sprint, or — if it must ship now — a
  deliberate, human-approved sprint re-scope summarized in `development-log.md`. Either way it goes
  through the backlog, never ad hoc into the sprint folder.

## Hard gates (always stop, regardless of gate_policy)
Never deploy/release/publish, run destructive data operations, spend money, change
accounts/permissions, or **run a migration from `workstream/operations/db/pending.md`**. The
devops-engineer authors the pipeline/migration; the orchestrator surfaces it to the human to
execute. Mark it in `checkpoints.md` as a hard gate.

## Blocks (human-in-the-loop)
If any agent ends with `BLOCKED:`, stop that item. Relay the question to the human verbatim
(AskUserQuestion for multiple-choice). Do not guess. When answered, re-delegate with the answer in
the prompt. Independent items may continue meanwhile.

## Gate policy at phase boundaries
Apply the `gate_policy` from active.md exactly as in plan-workflow: `auto-proceed` /
`review-on-open-issues` (default) / `review-all`. The hard gates above override the policy.

## Logging
Two separate streams, by design:
- **Machine trace (hooks).** Every subagent lifecycle event is stamped to `events-log.md` and its
  token usage to `token-log.md`, automatically. You never write these.
- **Human activity (orchestrator).** You write the one-line human summary from each `DONE:` line to
  `sprint-log.md` — that file holds *only* your summaries, so a skipped one is a visibly empty log,
  not noise buried under machine rows. Milestones (item passed, sprint closed) also summarize into
  `development-log.md`.

## Closing a sprint
When all in-scope items reach PASS (and build, if in scope):
1. Run `scrum-master` → `sprint-review.md` + `retrospective.md`; it distills lessons into
   `workstream/insights.md`. Run `technical-writer` for the changelog/docs.
2. Rewrite `sprint-state.md` in full — final status of every item, what shipped, carry-overs.
3. Rewrite `development-state.md` — project status after this sprint.
4. Move every shipped item's block from `backlog-ready.md` to `backlog-done.md` (under the sprint's
   `## Sprint <id>` section). Summarize "sprint closed" into `development-log.md`; set `active.md`
   phase to `closed`.
Both state files must let a cold, memoryless session resume or audit the project from disk alone.
