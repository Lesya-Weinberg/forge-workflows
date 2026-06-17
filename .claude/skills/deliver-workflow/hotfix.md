# Deliver profile — Hotfix (the bypass lane)

The lowest rung of the tier ladder. A bounded, already-decided change that does not warrant
planning or a sprint. ONLY the `patcher` runs. NO sprint folder is created.

## Scope gate (orchestrator runs this BEFORE delegating)
A change qualifies as Hotfix only if ALL are true:
1. The human already knows what they want — no design decision is needed.
2. It touches at most two files (one code file, optionally one spec to sync).
3. It does not alter acceptance criteria, system rules, or architecture.
4. The orchestrator can describe it in one sentence before delegating.
If any fails → re-route to Nano (or higher). A hotfix that silently changes behaviour is a spec
conflict in disguise.

## Change types and obligations
| Type | Code change | Spec to sync | Patch record notes |
|---|---|---|---|
| Bug fix | logic fix | none (spec is correct) | the defect and the fix |
| Constant / config tweak | value | the spec table row if one exists | old → new value |
| Copy / string fix | string | the spec line if one exists | corrected line |
| Stub / mockup | new stub | none (spec unchanged) | flag in backlog + expiry condition |
| Micro-refactor | rename/move | none | files touched |

## Stub specifics
A stub is the cleanest hotfix: the design is decided, you just need the real feature replaced
temporarily so something else can be tested. The patcher must:
1. Mark it in code: `// STUB — expires when <backlog-item-id> ships`.
2. Add `stub: active — <patch-id>` to the relevant backlog item.
3. Record the expiry condition in the patch record so it surfaces at sprint planning.

## Delegation prompt must include
Change type · the one-sentence description · exact file(s) · the spec to sync (or "none — pure
code") · the backlog item id (stubs only) · output path `workstream/patches/patch-<id>.md`
(create `workstream/patches/` if absent).

## Hard gates still apply
A hotfix never deploys, never runs a migration. If the fix needs a schema change, it is not a
hotfix — re-route.

## Logging & close
Patch record → `workstream/patches/patch-<id>.md`. Log to the active sprint log if one is open,
else `development-log.md`. No sprint folder, no state rewrite unless a stub flag changes an item.
The orchestrator reads the patcher's `DONE:` line and adds a one-line summary.
