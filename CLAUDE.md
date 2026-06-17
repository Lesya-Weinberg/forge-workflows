# Forge — Project Manifest

This is the per-project entry point and auto-loads into every agent. It holds exactly two things:
the **Project Stack** seeded for THIS project (below), and an import of the managed Forge operating
manual (`CLAUDE.base.md`). Keep project-specific facts here; everything under `.claude/` plus
`CLAUDE.base.md` is template-managed and updated by `forge-sync` — do not hand-edit managed files
inside a project (local drift blocks clean updates). Per-project harness tweaks go in
`.claude/settings.local.json`, not `settings.json`.

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

## Forge operating manual (managed — do not edit here)

The full operating manual — team model, control plane, workspace layout, agent rules — is imported
below from `CLAUDE.base.md`, which `forge-sync` keeps in step with the upstream template. If the
import line is removed, agents lose the manual, so leave it in place.

@CLAUDE.base.md
