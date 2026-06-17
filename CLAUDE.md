# Forge — Agent Operating Manual

This file auto-loads into every agent (orchestrator and all subagents). It is the single
source of truth for the workspace layout, the control plane (modes, tiers, gates), and the
rules every agent obeys. Keep it lean. Deep process lives in skills; artifact shape lives in
templates; project specifics live in the Project Stack block below — not scattered in prose.

Forge is technology-agnostic. It builds webapps, services, scripts, integrations, libraries —
anything that is code. The only project-specific part of this scaffold is the Project Stack
block in this file and the artifact templates. Everything else carries over unchanged.

## How the team runs

- **You (the human)** act as Product Owner. You talk only to the **orchestrator**.
- The **orchestrator** is the main session (`claude --agent orchestrator`). It is the ONLY
  agent that can spawn others. Subagents cannot spawn subagents.
- Subagents run in isolated context. They see nothing except this file, their own role prompt,
  and whatever the orchestrator hands them in the delegation prompt. **All shared memory lives
  on disk.** If the orchestrator does not name a path, the subagent cannot see it.

## Project Stack  <!-- HUMAN-SEEDED. The orchestrator must verify this is filled at session start. -->

> If the block below still reads `[UNSEEDED]`, the project is not initialized. The orchestrator
> loads the `project-init` skill and helps the human fill it before any other work.

- **Product type:** [UNSEEDED]            <!-- e.g. web app, CLI, API service, library, integration -->
- **Language(s) / runtime:** [UNSEEDED]
- **Frameworks / key libs:** [UNSEEDED]
- **Persistence:** [UNSEEDED]             <!-- db engine + access pattern, or "none" -->
- **Test stack:** [UNSEEDED]
- **Build / deploy target:** [UNSEEDED]
- **Architecture hard rules:** [UNSEEDED] <!-- the "never do this" list: layering, boundaries, forbidden deps -->

## The control plane: modes × tiers × gates

**Mode** = the shape of the work. The orchestrator picks it from your request:
- **Plan** — loose, creative, any order. Define/revise vision, requirements, UX, architecture,
  security, data, backlog. Skill: `plan-workflow`.
- **Deliver** — strict, sequential, sprint-scoped. Turn Ready backlog items into reviewed,
  tested, built code, one item at a time. Skill: `deliver-workflow`.

**Tier** = the depth dial, recorded in `active.md`. It decides which roles fire and how deep.
The orchestrator reads the tier, then loads that one profile from the skill folder.

```
Hotfix → Nano → Lite → Standard → Meticulous → Full
```
- **Hotfix** — a bounded, already-decided change (bug, constant, copy, stub). NO planning, NO
  sprint folder. `patcher` only → patch record. The deliver-workflow `hotfix.md` profile.
- **Nano** — smallest unit that still warrants a sliver of planning. Thin deliver path.
- **Lite / Standard / Meticulous / Full** — progressively more roles, deeper artifacts. The
  per-tier role activation lives in `.claude/skills/reference/tier-matrix.md`.

**Gates** = how the human stays in the loop. Set `gate_policy` in `active.md`:
- `auto-proceed` — flow continuously; stop only on a hard gate or a `BLOCKED:`.
- `review-on-open-issues` — **(default)** at each phase boundary the orchestrator surfaces a
  digest (artifacts + open questions + any `[MISSING INPUT]` flags) and pauses only if open
  issues exist; otherwise it proceeds.
- `review-all` — pause for human approval at every phase boundary.

**Hard gates always stop, regardless of tier or policy.** These are irreversible or
side-effectful actions the agent must NOT perform itself:
- deploying / releasing / publishing,
- destructive data operations,
- spending money or changing accounts/permissions,
- **running any migration queued in `workstream/operations/db/pending.md`** (agents author
  migrations; only the human runs them).

After each subagent and each orchestrator turn, `.claude/hooks/auto-commit.sh` makes ONE local
commit of the working tree (`git add -A`). Local commits are reversible and are **not** a hard
gate — but the hook never pushes; push / publish / deploy stay hard gates. Disable per session
with `FORGE_AUTOCOMMIT=0`; it is a safe no-op outside a git repo.

## Workspace layout

```
CLAUDE.md                         ← this file
.claude/agents/                   ← orchestrator + planning/ + delivery/ role definitions
.claude/skills/                   ← plan-workflow, deliver-workflow (with per-tier profiles),
                                     project-init, and reference/ (artifact-flow, tier-matrix)
.claude/templates/                ← the ONLY allowed shape for every deliverable
.claude/hooks/log-subagent.sh     ← timestamps every subagent lifecycle event into the log
.claude/hooks/log-tokens.sh       ← records token usage per step into the token log
.claude/hooks/auto-commit.sh      ← commits the working tree after each subagent/orchestrator step
workstream/
  vision.md, roadmap.md           ← human-seeded product direction (durable)
  active.md                       ← pointer ONLY: feature, mode, tier, phase, gate_policy, sprint_path
                                     + a fixed "where state lives" index. No status/progress/narrative.
                                     REGENERATED in full from its template at session end (a hard reset).
  checkpoints.md                  ← advisory + hard gate status (human + orchestrator)
  backlog-draft.md                ← items being shaped (backlog-planner owns)
  backlog-ready.md                ← Ready/In-Sprint delivery queue, with Definition of Ready (backlog-planner owns)
  backlog-done.md                 ← shipped-item archive, grouped by sprint (orchestrator owns)
  development-state.md            ← whole-project snapshot (OVERWRITTEN at session end; current state + pointers, never history)
  development-log.md              ← project log, append-only human milestones (orchestrator writes)
  events-log.md                   ← machine lifecycle trace, non-sprint fallback (hook writes; append-only)
  token-log.md                    ← non-sprint token accounting (append-only)
  insights.md                     ← cross-sprint lessons learned (scrum-master feeds this)
  decisions/ADR-NNN-*.md          ← durable architecture decisions
  design/<feature>/               ← durable design artifacts (planning output)
  operations/db/migrations/       ← migration files agents author but must NOT run
  operations/db/pending.md        ← ledger of migrations awaiting human execution
  operations/runbooks/, slo.md    ← durable ops artifacts
  sprints/<sprint-id>/            ← execution artifacts + sprint-state + sprint-log (human) + events-log (machine) + token-log
```

**Rule of thumb:** durable design artifacts live in `workstream/design/` and
`workstream/decisions/`; sprint-bound execution artifacts live in
`workstream/sprints/<id>/`; product code lives in the real project tree, never in a sprint folder.

## Artifact flow & tier depth

Who consumes what and who produces what is defined in `.claude/skills/reference/artifact-flow.md`.
Which roles activate at which tier is in `.claude/skills/reference/tier-matrix.md`. Agents do not
restate these; they read them. The orchestrator consults both when routing.

## Agent operating rules (every subagent obeys these)

1. **Read first.** Open `workstream/active.md` to learn the current feature, tier, and sprint
   path. Read every input artifact named in your task before producing anything.
2. **Consume ≥1, produce ≥1.** Never run without reading an upstream artifact; never finish
   without writing your deliverable.
3. **Template is law.** Copy the matching template from `.claude/templates/` and fill it. Do
   not add, drop, or rename sections. Scale depth to the tier named in your prompt — only the
   necessary information, no bloat. **Produce only the artifact(s) your task names, each from its
   template. Never invent a new file or tracker that has no template** (e.g. an ad-hoc `activity.md`,
   `bugs.md`, or notes file). If you feel you need one, you are out of scope — stop and flag it per
   rule 7 instead of creating it.
4. **Stay in your lane.** Write only your own deliverable (and, for delivery roles that touch
   code, only the files your task names). Never edit another agent's artifact.
5. **Flag missing inputs, don't paper over them.** If an artifact you should consume is absent,
   write `[MISSING INPUT: <path>]` at the top of your output and note it for the orchestrator.
6. **Mark uncertainty explicitly.** Use `[ASSUMPTION: <reason>]`, `[TODO: <reason>]`, and
   `[OBSOLETE — see <path>]`. Never leave two conflicting versions standing silently.
7. **When blocked, stop — do not guess.** If a required decision is missing, ambiguous, or
   contradictory, end your turn with the LAST line:
   `BLOCKED: <the exact decision the human must make, as a yes/no or multiple-choice question>`
   You cannot prompt the human; the orchestrator relays it.
8. **Never perform a hard gate.** Author the migration / deploy config; never execute it.
9. **Report for the log.** End every successful run with a one-line summary:
   `DONE: <verb> <relative/path/to/artifact> — <≤15-word note>`
   The hook stamps the time and token usage; the orchestrator writes the summary.

## Cross-cutting rules

- Never hardcode secrets — reference the secrets-store key name only.
- Logs are append-only; state files are overwritten in full at session end.
- Reference, don't duplicate. If a fact lives in another artifact, cite its path.
- Significant architecture decisions get an ADR (`workstream/decisions/`). ADRs are durable;
  never contradict one without a new ADR.
