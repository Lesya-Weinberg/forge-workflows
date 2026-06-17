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

## Prerequisites
Forge's hooks and structure-sync scripts are POSIX shell. You need **git**, **bash** (Git Bash on
Windows), and **jq**; the manifest/sync also use a sha256 tool (`sha256sum`, `shasum`, or
`openssl`). Without `jq`, token logging and commit attribution degrade. Verify with
`bash scripts/forge-manifest.sh --check` (it also acts as a scaffold doctor).

## CLAUDE.md is split (managed vs. instance)
`CLAUDE.md` holds only your seeded **Project Stack** plus `@CLAUDE.base.md`, which imports the
managed operating manual. The manual (`CLAUDE.base.md`) and everything under `.claude/` are
template-owned and updated by `forge-sync`; your Project Stack and `workstream/` are never touched.
Put per-project harness tweaks in `.claude/settings.local.json`, not `settings.json`, so they
survive updates.

## To start a new project from this scaffold
1. `git clone <your-forge-template-repo> my-project && cd my-project` (or copy the folder).
2. Repurpose `origin` for the new project's own repo, and add the template as the update upstream:
   `git remote add forge-upstream <your-forge-template-repo>`.
3. Clear `workstream/` of any prior feature artifacts.
4. Launch `claude --agent orchestrator`; `project-init` walks you through seeding the Project Stack
   and vision, and writes `.forge/instance.json` (your upstream link).

## Keeping a project in sync with the template
The template is a versioned checkpoint (`.forge/version.json`). When it advances, an instance can
pull the structural changes — ask the orchestrator to "sync the Forge structure" (the `forge-sync`
skill). It dry-runs a diff first, pauses for your approval (structural changes are gated like a hard
action), then applies only template-owned files — never your `workstream/`, Project Stack, or
`settings.local.json`. Transport is the `forge-upstream` git remote, with a local-path fallback
(`bash scripts/forge-sync.sh --from <path>`). Restart `claude` after a sync so changed agents load.

### Maintaining the template itself
After changing any managed file here: run `bash scripts/forge-manifest.sh` to refresh the hash
manifest, bump `forge_version` in `.forge/version.json`, and add a `.forge/CHANGELOG.md` entry (with
migration notes if a change needs manual follow-up in instances).
