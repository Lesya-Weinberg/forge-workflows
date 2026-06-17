# Forge — Agnostic Agent Team Scaffold

A Claude Code subagent + skill architecture that emulates a full product team for **any code
project** (webapps, services, scripts, integrations, libraries). You act as Product Owner and
talk only to the **orchestrator** (the main session); it spawns specialists.

## Launch
```bash
# from the repo root
claude --agent orchestrator
```
`.claude/settings.json` sets `orchestrator` as the default agent and wires the logging + token
hooks, so plain `claude` works too. Restart the session after editing any agent file on disk.

## First run: seed the project
On the first session the orchestrator checks whether the **Project Stack** block in `CLAUDE.md`
and `workstream/vision.md` are filled. If not, it loads the `project-init` skill and walks you
through seeding them. Nothing else runs until the project is initialized.

## The control plane
- **Mode** (orchestrator picks from your request): **Plan** (loose, creative) or **Deliver**
  (strict, sprint-scoped). Processes live in `.claude/skills/plan-workflow` and `deliver-workflow`.
- **Tier** (depth dial, recorded in `active.md`): `Hotfix → Nano → Lite → Standard →
  Meticulous → Full`. The orchestrator loads only that tier's profile from the skill folder, so
  a small job never pays for the full process. Role activation per tier lives in
  `.claude/skills/reference/tier-matrix.md`.
- **Gates** (`gate_policy` in `active.md`): `auto-proceed` / `review-on-open-issues` (default) /
  `review-all`. Hard gates (deploy, destructive data ops, spending, running queued DB
  migrations) always stop and ask, regardless of policy.

## What holds it together
- Subagents can't spawn subagents, so the **orchestrator must be the main session** (`--agent`).
- Subagents start blind — **all shared memory is on disk**. The orchestrator passes file paths
  in every delegation; agents read/write via the templates in `.claude/templates/`.
- **Every agent consumes ≥1 artifact and produces ≥1 artifact.** Templates keep deliverables atomic.
- **Logging runs on two streams.** The hooks write the *machine trace* — lifecycle events
  (`.claude/hooks/log-subagent.sh` → `events-log.md`) and token usage (`.claude/hooks/log-tokens.sh`
  → `token-log.md`), routed to the active sprint folder or the project level. The orchestrator writes
  the *human activity summary* separately to `sprint-log.md` / `development-log.md`, so a missed
  summary shows as an empty log rather than hiding under machine rows.
- **Work is auto-committed** (`.claude/hooks/auto-commit.sh`): after each subagent and each
  orchestrator turn the working tree is committed locally (`git add -A`), giving a granular,
  per-step history. It never pushes (push/deploy stay hard gates), no-ops outside a git repo,
  and is disabled per session with `FORGE_AUTOCOMMIT=0`.
- **Blocks surface to you**: an agent that lacks a decision ends with `BLOCKED:`; the orchestrator
  relays it. Agents never guess, never self-deploy.
- **Database operations are queued, not run.** Agents author migrations into
  `workstream/operations/db/migrations/` and log them in `pending.md`; you run them manually.

## Where things live
See `CLAUDE.md` for the full layout, the control plane, and the operating rules — it auto-loads
into every agent. The artifact flow map and tier activation matrix live in
`.claude/skills/reference/`.

## To start a new project from this scaffold
Copy the folder, clear `workstream/` of any prior feature artifacts, and re-seed the Project
Stack block in `CLAUDE.md`. The agents, skills, hooks, and templates carry over unchanged.
