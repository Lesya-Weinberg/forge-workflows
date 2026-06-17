---
name: forge-sync
description: Check whether THIS project's Forge scaffold (everything template-managed — .claude/**, CLAUDE.base.md, scripts, .forge) is behind the upstream Forge template, and pull structural updates on request. Use when the human asks to "update/sync the Forge structure", "check for scaffold updates", "am I on the latest Forge/template", or after they announce the template was bumped. Never auto-runs; it is human-initiated. Applying updates modifies the project's own operating structure, so it is gated like a hard action — always confirm before --apply.
---

# Forge structure sync

This project was seeded from a Forge template. The template evolves; this skill compares this
project's **structure version** against the template and, on explicit approval, pulls the changed
managed files — without ever touching instance data (`workstream/`, the seeded Project Stack block in
`CLAUDE.md`, `.claude/settings.local.json`, `.forge/instance.json`).

The boundary between managed and instance files is declared in `.forge/version.json`
(`managed_globs` vs `instance_owned`). Trust it; do not copy anything outside `managed_globs`.

## Preconditions
- `git`, `jq`, and a sha256 tool must be present (see README prerequisites).
- The upstream must be reachable: either `.forge/instance.json` has a working `upstream.git_url`
  (preferred), or you pass a local path with `--from`. If neither exists, ask the human for the
  template's GitHub URL or local path and write it into `.forge/instance.json` (copy from
  `.forge/instance.json.example`) before proceeding.
- A clean git tree is required to APPLY (so the auto-commit checkpoint is a clean rollback). If the
  tree is dirty, commit current work first.

## Procedure (orchestrator-run)
1. **Dry-run.** Run `bash scripts/forge-sync.sh` (git transport) or
   `bash scripts/forge-sync.sh --from <local_path>` (fallback). It prints a plan:
   UPDATE / NEW / CONFLICT / REMOVED / UNCHANGED counts and file lists.
2. **Gate the result.** Present the plan to the human as a digest — this is a structural change to
   the project's own operating rules, so treat it like a hard gate: **always pause for explicit
   approval before applying, regardless of `gate_policy`.** Call out CONFLICTs (managed files edited
   locally) specifically — applying will NOT overwrite them unless the human chooses `--force`.
3. **Apply on approval.** Run `bash scripts/forge-sync.sh --apply` (add `--force` only if the human
   accepts overwriting the listed local edits). The script writes the files, bumps
   `.forge/version.json`, stamps `last_synced`, and prints the upstream CHANGELOG migration notes.
4. **Surface migration notes.** Relay any migration steps for versions above the old one verbatim —
   some (e.g. reshaping `workstream/` data, a moved Project Stack field) are manual and may need a
   follow-up plan/hotfix. Do not perform a hard gate to satisfy one.
5. **Restart reminder.** Agent, skill, and `CLAUDE.base.md` changes only load in a fresh session —
   tell the human to restart `claude` after a sync.
6. **Log it.** Append a one-line summary to `workstream/development-log.md`
   (e.g. "forge-sync: structure 1.0.0 → 1.2.0, 6 files updated, 1 conflict deferred").

## Conflicts & limits
- A **CONFLICT** means a managed file was edited locally (drift). The right fix is usually to move
  that customization into an instance-owned file (`settings.local.json`, the Project Stack block) so
  it survives future syncs, then re-run. Only `--force` past it when the human is sure.
- Sync updates *structure*, not *data*. If a version reshapes existing instance data, that is a
  migration the human/orchestrator performs separately, guided by the CHANGELOG note.
- Never run this against a project mid-sprint without the human's explicit go-ahead — changing agent
  definitions under a running sprint can invalidate in-flight assumptions.

## Maintainers (working in the template itself)
When you change a managed file in the template, run `bash scripts/forge-manifest.sh` to refresh the
hash manifest, bump `forge_version` in `.forge/version.json`, and add a `.forge/CHANGELOG.md` entry
(with migration notes if needed). `bash scripts/forge-manifest.sh --check` is also a scaffold doctor.
