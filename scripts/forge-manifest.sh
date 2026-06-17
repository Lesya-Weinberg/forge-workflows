#!/usr/bin/env bash
# forge-manifest.sh — (re)generate and verify the Forge structure manifest.
#
#   regenerate (default) : hash every managed file and write the hashes into
#                          .forge/version.json ".manifest" (sorted, deterministic).
#                          Run this whenever you change a managed file, before bumping the version.
#   --check / check      : recompute and diff against the stored manifest, then run scaffold
#                          "doctor" checks (CLAUDE split, hooks, jq). Exit non-zero if anything is off.
#
# Managed paths come from .forge/version.json ".managed_globs": either a directory glob ("a/b/**")
# or a literal file. The manifest never includes .forge/version.json itself (it holds the manifest).
#
# Deps: jq + one of sha256sum|shasum|openssl. Safe on Git Bash / macOS / Linux.
# Note: Windows jq emits CRLF; jqr() strips the CR so values compare and pattern-match correctly.

set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel 2>/dev/null || echo "$SCRIPT_DIR/..")"
cd "$ROOT" || { echo "cannot cd to repo root"; exit 2; }
VJSON=".forge/version.json"

MODE="regenerate"
case "${1:-}" in
  --check|check) MODE="check" ;;
  ""|--regenerate|regenerate) MODE="regenerate" ;;
  -h|--help) sed -n '2,18p' "$0"; exit 0 ;;
  *) echo "usage: forge-manifest.sh [--check]"; exit 2 ;;
esac

command -v jq >/dev/null 2>&1 || { echo "FAIL: jq not installed (required)"; exit 2; }
[ -f "$VJSON" ] || { echo "FAIL: $VJSON missing"; exit 2; }

jqr() { jq -r "$@" | tr -d '\r'; }   # jq -r, hardened against Windows jq's CRLF output

hash_file() {
  if   command -v sha256sum >/dev/null 2>&1; then sha256sum "$1" | awk '{print $1}'
  elif command -v shasum    >/dev/null 2>&1; then shasum -a 256 "$1" | awk '{print $1}'
  else openssl dgst -sha256 "$1" | awk '{print $NF}'; fi
}

# expand managed_globs -> sorted, deduped file list, excluding version.json
list_managed_files() {
  local g dir
  while IFS= read -r g; do
    [ -z "$g" ] && continue
    case "$g" in
      */'**') dir="${g%/'**'}"; [ -d "$dir" ] && find "$dir" -type f ;;
      *)      [ -f "$g" ] && printf '%s\n' "$g" ;;
    esac
  done < <(jqr '.managed_globs[]?' "$VJSON") \
    | sed 's#^\./##' | grep -vxF "$VJSON" | LC_ALL=C sort -u
}

build_manifest() {
  list_managed_files | while IFS= read -r f; do
    printf '%s\t%s\n' "$f" "$(hash_file "$f")"
  done | jq -Rn '[inputs | split("\t") | {(.[0]): .[1]}] | add // {}' | tr -d '\r'
}

if [ "$MODE" = "regenerate" ]; then
  NEW="$(build_manifest)"
  tmp="$(mktemp)"
  jq --argjson m "$NEW" '.manifest = $m' "$VJSON" | tr -d '\r' > "$tmp" && mv "$tmp" "$VJSON"
  echo "regenerated manifest: $(printf '%s' "$NEW" | jq 'length') managed files hashed into $VJSON"
  exit 0
fi

# ---- check mode ----
rc=0
STORED="$(jq -c '.manifest // {}' "$VJSON" | tr -d '\r')"
CURRENT="$(build_manifest)"
drift="$(jq -rn --argjson s "$STORED" --argjson c "$CURRENT" '
  ($s|keys) as $sk | ($c|keys) as $ck
  | ( [ $sk[] | select(($c[.]//null) == null)                    | "MISSING   " + . ]
    + [ $sk[] | select(($c[.]//null) != null and $c[.] != $s[.]) | "CHANGED   " + . ]
    + [ $ck[] | select(($s[.]//null) == null)                    | "UNTRACKED " + . ] )
  | .[]' | tr -d '\r')"
if [ -n "$drift" ]; then echo "manifest drift vs $VJSON:"; echo "$drift"; rc=1; else echo "manifest: clean"; fi

echo "--- doctor ---"
chk() { if eval "$2" >/dev/null 2>&1; then echo "ok:   $1"; else echo "FAIL: $1"; rc=1; fi; }
chk "CLAUDE.base.md present"             '[ -f CLAUDE.base.md ]'
chk "CLAUDE.md imports @CLAUDE.base.md"  'grep -qx "@CLAUDE.base.md" CLAUDE.md'
chk "hook: auto-commit.sh"               '[ -f .claude/hooks/auto-commit.sh ]'
chk "hook: log-subagent.sh"              '[ -f .claude/hooks/log-subagent.sh ]'
chk "hook: log-tokens.sh"                '[ -f .claude/hooks/log-tokens.sh ]'
chk "templates dir present"              '[ -d .claude/templates ]'
chk "jq installed"                       'command -v jq'
[ "$rc" = "0" ] && echo "DOCTOR: PASS" || echo "DOCTOR: ISSUES"
exit "$rc"
