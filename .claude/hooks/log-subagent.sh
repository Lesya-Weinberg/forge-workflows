#!/usr/bin/env bash
# SubagentStart / SubagentStop lifecycle logger for Forge.
# Appends a timestamped MACHINE lifecycle event to the active sprint's events-log.md,
# falling back to workstream/events-log.md when no sprint is active.
#
# This is the mechanical trace only. The human-readable activity summary is the orchestrator's
# own write to sprint-log.md (sprint) / development-log.md (project) — kept in SEPARATE files so a
# skipped summary shows up as a conspicuously empty sprint-log, not hidden under machine noise.

set -euo pipefail

INPUT="$(cat || true)"
ROOT="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
ACTIVE="$ROOT/workstream/active.md"
EVENTS_LOG="$ROOT/workstream/events-log.md"
TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

extract() { printf '%s' "$INPUT" | jq -r "$1 // empty" 2>/dev/null || true; }

AGENT="$(extract '.agent_type')"
[ -z "$AGENT" ] && AGENT="$(extract '.subagent_type')"
[ -z "$AGENT" ] && AGENT="$(extract '.matcher')"
[ -z "$AGENT" ] && AGENT="unknown-agent"
[ "$AGENT" = "unknown-agent" ] && exit 0
EVENT="$(extract '.hook_event_name')"
[ -z "$EVENT" ] && EVENT="${1:-lifecycle}"

LOG="$EVENTS_LOG"
if [ -f "$ACTIVE" ]; then
  SPRINT_PATH="$(grep -iE '^[*-]?[[:space:]]*sprint_path:' "$ACTIVE" | head -1 | sed -E 's/.*sprint_path:[[:space:]]*//' | tr -d '\r')"
  if [ -n "${SPRINT_PATH:-}" ] && [ "$SPRINT_PATH" != "none" ] && [ -d "$ROOT/$SPRINT_PATH" ]; then
    LOG="$ROOT/$SPRINT_PATH/events-log.md"
  fi
fi

[ -f "$LOG" ] || printf '# Log\n\n' > "$LOG"
printf -- '- [%s] event=%s agent=%s\n' "$TS" "$EVENT" "$AGENT" >> "$LOG"
exit 0
