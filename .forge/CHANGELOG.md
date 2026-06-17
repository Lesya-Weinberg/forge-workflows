# Forge scaffold changelog

Structural (template-owned) changes only. Instance data — `workstream/`, the seeded Project Stack
block, `.claude/settings.local.json` — is never tracked here. Each release may carry **migration
notes**: manual steps `forge-sync` cannot perform automatically (e.g. reshaping existing instance
data, or a Project Stack field that moved). `forge-sync` prints this file on apply; read every note
for versions above the one you were on.

<!-- newest version on top; prepend new releases above the line below -->

## 1.0.0 — 2026-06-17

First versioned checkpoint. Establishes Forge structure version-control and the CLAUDE.md split.

- **Added** `.forge/` (version manifest + this changelog), `scripts/forge-manifest.sh`,
  `scripts/forge-sync.sh`, and the `forge-sync` skill — projects can now detect when their scaffold
  is behind the template and pull updates.
- **Added** `.gitattributes` to force LF endings (keeps bash hooks/scripts runnable on every OS).
- **Changed** `CLAUDE.md` is now split: an instance `CLAUDE.md` (Project Stack + `@CLAUDE.base.md`)
  and a managed `CLAUDE.base.md` (the operating manual). Sync updates `CLAUDE.base.md`; your seeded
  Project Stack in `CLAUDE.md` is never touched.
- **Added** earlier scaffold refinements now part of the baseline: per-tier model dial, parallel
  planning fan-out, the insights→planning loop, and the sprint token-cost rollup.

### Migration notes (only for projects created before 1.0.0)

1. **Adopt the CLAUDE.md split.** Move the operating-manual body of your old `CLAUDE.md` into
   `CLAUDE.base.md` (or just take the template's), and reduce your `CLAUDE.md` to the Project Stack
   block plus a final `@CLAUDE.base.md` line. Keep your seeded Project Stack values.
2. **Move local settings tweaks.** If you hand-edited `.claude/settings.json`, move project-specific
   changes into `.claude/settings.local.json` so future syncs don't conflict.
3. **Create the upstream link.** Copy `.forge/instance.json.example` to `.forge/instance.json` and
   fill your template's git URL (and/or a local path).
