#!/usr/bin/env bash
# Token-accounting logger for Forge.  (v2 — schema-corrected)
#
# SubagentStop: attributes the tokens of the FINISHED SUBAGENT, read from its OWN transcript
#               (.agent_transcript_path). Each subagent has its own file, so summing it = that
#               subagent's total.
# Stop:         attributes the MAIN (orchestrator) turn, read from .transcript_path, counting ONLY
#               lines added since the previous Stop (a cursor), and EXCLUDING sidechain (subagent)
#               lines so they aren't double-counted against the SubagentStop totals.
#
# Routing mirrors the lifecycle logger: sprint work -> sprint folder token-log, else
# workstream/token-log.md.
#
# Failures are LOUD, never silent: a missing jq or transcript writes a tagged row, never zeros.
#
# !! Still validate field names against your installed Claude Code version (see the diagnostic in
# the README). Probes both `.message.usage` and `.usage` usage shapes.

set -uo pipefail

INPUT="$(cat || true)"
ROOT="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
ACTIVE="$ROOT/workstream/active.md"
CACHE="$ROOT/.claude/.cache/token-cursors"
mkdir -p "$CACHE" 2>/dev/null || true
TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
EVENT="${1:-token}"

extract() { printf '%s' "$INPUT" | jq -r "$1 // empty" 2>/dev/null || true; }

# --- resolve target token log (sprint-scoped if a sprint is active) ---
LOG="$ROOT/workstream/token-log.md"
MODE=""; TIER=""
if [ -f "$ACTIVE" ]; then
  SPRINT_PATH="$(grep -iE '^[*-]?[[:space:]]*sprint_path:' "$ACTIVE" | head -1 | sed -E 's/.*sprint_path:[[:space:]]*//' | tr -d '\r')"
  if [ -n "${SPRINT_PATH:-}" ] && [ "$SPRINT_PATH" != "none" ] && [ -d "$ROOT/$SPRINT_PATH" ]; then
    LOG="$ROOT/$SPRINT_PATH/token-log.md"
  fi
  MODE="$(grep -iE '^[*-]?[[:space:]]*mode:' "$ACTIVE" | head -1 | sed -E 's/.*mode:[[:space:]]*//' | tr -d '\r')"
  TIER="$(grep -iE '^[*-]?[[:space:]]*tier:' "$ACTIVE" | head -1 | sed -E 's/.*tier:[[:space:]]*//' | tr -d '\r')"
fi

ensure_header() {
  [ -f "$LOG" ] || printf '# Token Log\n\n| time | mode | tier | agent | in | out | cache_read | cache_write | total |\n|---|---|---|---|---|---|---|---|---|\n' > "$LOG"
}
row() { ensure_header; printf -- '| %s | %s | %s | %s | %s | %s | %s | %s | %s |\n' \
  "$TS" "${MODE:-?}" "${TIER:-?}" "$1" "$2" "$3" "$4" "$5" "$6" >> "$LOG"; }

# --- agent label ---
AGENT="$(extract '.agent_type')"
[ -z "$AGENT" ] && AGENT="$(extract '.subagent_type')"
[ -z "$AGENT" ] && AGENT="$([ "$EVENT" = "Stop" ] && echo orchestrator || echo unknown-agent)"

# Internal Claude Code events with no identifiable agent and no transcript are unattributable.
# Skip silently rather than writing a noise row.
[ "$AGENT" = "unknown-agent" ] && exit 0

# --- jq presence: fail loud ---
if ! command -v jq >/dev/null 2>&1; then
  row "$AGENT" _ _ _ _ "[jq-missing: install jq]"; exit 0
fi

# --- pick the right transcript per event ---
if [ "$EVENT" = "SubagentStop" ]; then
  TRANSCRIPT="$(extract '.agent_transcript_path')"
  [ -z "$TRANSCRIPT" ] && TRANSCRIPT="$(extract '.transcript_path')"   # older versions
  SIDE_FILTER=""                                                       # own transcript: keep all
else
  TRANSCRIPT="$(extract '.transcript_path')"
  SIDE_FILTER="| select((.isSidechain // false) | not)"               # main: drop subagent lines
fi

if [ -z "$TRANSCRIPT" ] || [ ! -f "$TRANSCRIPT" ]; then
  row "$AGENT" _ _ _ _ "[unresolved: no transcript for $EVENT]"; exit 0
fi

# --- cursor: only count lines added since last time for THIS transcript ---
KEY="$(printf '%s' "$TRANSCRIPT" | cksum | awk '{print $1}')"
CURF="$CACHE/$KEY"
START=0
[ -f "$CURF" ] && START="$(cat "$CURF" 2>/dev/null || echo 0)"
case "$START" in (*[!0-9]*|"") START=0 ;; esac
TOTAL_LINES="$(wc -l < "$TRANSCRIPT" 2>/dev/null | tr -d ' ')"
case "$TOTAL_LINES" in (*[!0-9]*|"") TOTAL_LINES=0 ;; esac
[ "$TOTAL_LINES" -lt "$START" ] && START=0    # transcript was compacted/rewritten

NEW="$(tail -n +"$((START + 1))" "$TRANSCRIPT" 2>/dev/null || true)"
printf '%s' "$TOTAL_LINES" > "$CURF" 2>/dev/null || true

# nothing new -> don't log a noise row
[ -z "$NEW" ] && exit 0

# --- sum usage over the new assistant lines ---
JQ_TEMPLATE='def u: (.message.usage // .usage // {});
  ( [ .[] | select((.type // "") == "assistant") __SF__ | u ] ) as $a
  | [ ( [ $a[].input_tokens // 0 ] | add // 0 ),
      ( [ $a[].output_tokens // 0 ] | add // 0 ),
      ( [ $a[].cache_read_input_tokens // 0 ] | add // 0 ),
      ( [ $a[].cache_creation_input_tokens // 0 ] | add // 0 ) ] | @tsv'
JQ_PROG="${JQ_TEMPLATE/__SF__/$SIDE_FILTER}"

USAGE="$(printf '%s\n' "$NEW" | jq -rs "$JQ_PROG" 2>/dev/null || true)"
if [ -z "$USAGE" ]; then
  row "$AGENT" _ _ _ _ "[unresolved: usage shape — check transcript schema]"; exit 0
fi
IN="$(printf '%s' "$USAGE" | cut -f1)";  OUT="$(printf '%s' "$USAGE" | cut -f2)"
CR="$(printf '%s' "$USAGE" | cut -f3)";  CW="$(printf '%s' "$USAGE" | cut -f4)"
IN=${IN:-0}; OUT=${OUT:-0}; CR=${CR:-0}; CW=${CW:-0}
TOTAL=$(( IN + OUT ))
row "$AGENT" "$IN" "$OUT" "$CR" "$CW" "$TOTAL"
exit 0
