#!/usr/bin/env bash
# Auto-commit hook for Forge.
#
# Fires on SubagentStop (after each subagent) and Stop (after each orchestrator turn).
# Stages the whole working tree (git add -A, honoring .gitignore) and creates ONE local
# commit per step, giving a granular, attributable history with zero manual effort.
#
# Design contract (matches the other hooks):
#   - Commit-only, NEVER push. Local commits are reversible and are not a hard gate;
#     push / publish / deploy remain hard gates the human performs.
#   - Main project tree only ($CLAUDE_PROJECT_DIR). Implementers (incl. parallel ones) work on
#     the active branch in this tree, so their changes ARE committed here — snapshots interleave
#     across concurrent slices (lock-serialized below, no work lost). Manual fallback worktrees
#     live outside this tree and are NOT auto-committed; their commits belong to the merge flow.
#   - Always-on with an env opt-out: set FORGE_AUTOCOMMIT=0 to disable for a session.
#   - Safe no-op outside a git repo (so the template scaffold itself is untouched).
#   - NEVER breaks the session: any failure is a silent exit 0. (No `set -e`.)

set -uo pipefail

# --- opt-out ---
[ "${FORGE_AUTOCOMMIT:-1}" = "0" ] && exit 0

# --- git must be present ---
command -v git >/dev/null 2>&1 || exit 0

INPUT="$(cat || true)"
ROOT="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
ACTIVE="$ROOT/workstream/active.md"
EVENT="${1:-Stop}"
TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

# --- must be inside a git work tree (this is why the un-gitted template is left alone) ---
git -C "$ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

extract() { printf '%s' "$INPUT" | jq -r "$1 // empty" 2>/dev/null || true; }

# --- agent label (mirror the logging hooks) ---
if command -v jq >/dev/null 2>&1; then
  AGENT="$(extract '.agent_type')"
  [ -z "$AGENT" ] && AGENT="$(extract '.subagent_type')"
else
  AGENT=""
fi
[ -z "$AGENT" ] && AGENT="$([ "$EVENT" = "Stop" ] && echo orchestrator || echo unknown-agent)"
# Unattributable internal events: skip silently.
[ "$AGENT" = "unknown-agent" ] && exit 0

# --- mode / tier from active.md (best-effort, same idiom as log-tokens.sh) ---
MODE=""; TIER=""
if [ -f "$ACTIVE" ]; then
  MODE="$(grep -iE '^[*-]?[[:space:]]*mode:' "$ACTIVE" | head -1 | sed -E 's/.*mode:[[:space:]]*//' | tr -d '\r')"
  TIER="$(grep -iE '^[*-]?[[:space:]]*tier:' "$ACTIVE" | head -1 | sed -E 's/.*tier:[[:space:]]*//' | tr -d '\r')"
fi
MODE="${MODE:-?}"; TIER="${TIER:-?}"

# --- serialize commits: avoid index.lock races across parallel SubagentStop events ---
CACHE="$ROOT/.claude/.cache"
mkdir -p "$CACHE" 2>/dev/null || true
LOCK="$CACHE/commit.lock"
acquired=0
for _ in $(seq 1 50); do
  if mkdir "$LOCK" 2>/dev/null; then acquired=1; break; fi
  sleep 0.2
done
[ "$acquired" = "1" ] || exit 0
trap 'rmdir "$LOCK" 2>/dev/null || true' EXIT

# --- nothing to commit -> never create an empty commit ---
[ -n "$(git -C "$ROOT" status --porcelain 2>/dev/null)" ] || exit 0

MSG="forge($MODE/$TIER): $AGENT $EVENT @ $TS"

# Only apply a fallback identity when git has NONE configured. Otherwise we keep the repo's
# own user.name/user.email so commits attribute correctly on GitHub etc.
IDENT=()
if ! git -C "$ROOT" config user.email >/dev/null 2>&1; then
  IDENT=(-c user.name="${FORGE_GIT_NAME:-forge-bot}" -c user.email="${FORGE_GIT_EMAIL:-forge@local}")
fi

git -C "$ROOT" add -A 2>/dev/null || exit 0
git -C "$ROOT" "${IDENT[@]}" commit -q --no-verify -m "$MSG" 2>/dev/null || exit 0

exit 0
