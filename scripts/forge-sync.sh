#!/usr/bin/env bash
# forge-sync.sh — compare this project's Forge STRUCTURE against the upstream template and, on
# --apply, pull the structural updates. Dry-run by default. NEVER touches instance data
# (workstream/, the seeded Project Stack in CLAUDE.md, settings.local.json, .forge/instance.json).
#
# Transport:
#   git   (default) : upstream via a git remote, configured in .forge/instance.json
#                     (.upstream.git_remote / .git_url / .git_ref). Works across machines.
#   path  (--from D): upstream is local directory D (same-machine fallback).
#
# Usage:
#   scripts/forge-sync.sh                    # dry-run, git transport
#   scripts/forge-sync.sh --from ../template # dry-run, local-path transport
#   scripts/forge-sync.sh --apply            # apply (git); refuses on a dirty tree
#   scripts/forge-sync.sh --apply --from D [--force]
#
# Classes: UPDATE (template changed, local pristine)  NEW (add)  CONFLICT (local edits — skipped
# unless --force)  REMOVED (gone upstream; left in place)  UNCHANGED.
# Safety: --apply refuses on a dirty git tree so the auto-commit checkpoint stays your rollback.
#
# Deps: git, jq, one of sha256sum|shasum|openssl. (Windows jq emits CRLF; jqr() strips it.)

set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel 2>/dev/null || echo "$SCRIPT_DIR/..")"
cd "$ROOT" || { echo "cannot cd to repo root"; exit 2; }
VJSON=".forge/version.json"
IJSON=".forge/instance.json"

APPLY=0; FORCE=0; FROM=""
while [ $# -gt 0 ]; do
  case "$1" in
    --apply) APPLY=1 ;;
    --force) FORCE=1 ;;
    --from)  shift; FROM="${1:-}" ;;
    --from=*) FROM="${1#--from=}" ;;
    -h|--help) sed -n '2,20p' "$0"; exit 0 ;;
    *) echo "unknown arg: $1"; exit 2 ;;
  esac
  shift
done

for t in git jq; do command -v "$t" >/dev/null 2>&1 || { echo "FAIL: '$t' required"; exit 2; }; done
[ -f "$VJSON" ] || { echo "FAIL: $VJSON missing — is this a Forge project?"; exit 2; }

jqr() { jq -r "$@" | tr -d '\r'; }   # jq -r, hardened against Windows jq's CRLF output

hash_file() {
  if   command -v sha256sum >/dev/null 2>&1; then sha256sum "$1" 2>/dev/null | awk '{print $1}'
  elif command -v shasum    >/dev/null 2>&1; then shasum -a 256 "$1" 2>/dev/null | awk '{print $1}'
  else openssl dgst -sha256 "$1" 2>/dev/null | awk '{print $NF}'; fi
}

# ---------- resolve transport, load upstream version.json ----------
TRANSPORT="git"; REMOTE=""; REF="main"; UPDIR=""
if [ -n "$FROM" ]; then
  TRANSPORT="path"; UPDIR="${FROM%/}"
  [ -f "$UPDIR/$VJSON" ] || { echo "FAIL: $UPDIR/$VJSON not found"; exit 2; }
  UP_VJSON="$(cat "$UPDIR/$VJSON")"
else
  [ -f "$IJSON" ] || { echo "FAIL: no $IJSON and no --from. Copy .forge/instance.json.example to $IJSON and set the upstream, or pass --from <path>."; exit 2; }
  REMOTE="$(jqr '.upstream.git_remote // "forge-upstream"' "$IJSON")"
  GITURL="$(jqr '.upstream.git_url // ""' "$IJSON")"
  REF="$(jqr '.upstream.git_ref // "main"' "$IJSON")"
  if ! git remote get-url "$REMOTE" >/dev/null 2>&1; then
    [ -n "$GITURL" ] && [ "$GITURL" != "null" ] || { echo "FAIL: remote '$REMOTE' not configured and no .upstream.git_url in $IJSON"; exit 2; }
    git remote add "$REMOTE" "$GITURL" || { echo "FAIL: could not add remote $REMOTE"; exit 2; }
  fi
  echo "fetching $REMOTE/$REF ..."
  git fetch -q "$REMOTE" "$REF" || { echo "FAIL: git fetch $REMOTE $REF (check git_url / network / auth)"; exit 2; }
  UP_VJSON="$(git show "$REMOTE/$REF:$VJSON" 2>/dev/null)" || { echo "FAIL: cannot read upstream $VJSON at $REMOTE/$REF"; exit 2; }
fi

upstream_file() { # $1 = repo-relative path -> stdout
  if [ "$TRANSPORT" = "path" ]; then cat "$UPDIR/$1"; else git show "$REMOTE/$REF:$1"; fi
}

LOCAL_VER="$(jqr '.forge_version // "0.0.0"' "$VJSON")"
UP_VER="$(printf '%s' "$UP_VJSON" | jqr '.forge_version // "0.0.0"')"
UP_MAN="$(printf '%s' "$UP_VJSON" | jq -c '.manifest // {}' | tr -d '\r')"
LOCAL_MAN="$(jq -c '.manifest // {}' "$VJSON" | tr -d '\r')"

echo "local Forge structure version : $LOCAL_VER"
echo "upstream version              : $UP_VER   (transport: $TRANSPORT)"

# ---------- classify every upstream-managed file ----------
UPDATE=(); NEW=(); CONFLICT=(); UNCHANGED=0
while IFS= read -r p; do
  [ -z "$p" ] && continue
  up="$(printf '%s' "$UP_MAN"    | jqr --arg p "$p" '.[$p] // ""')"
  base="$(printf '%s' "$LOCAL_MAN" | jqr --arg p "$p" '.[$p] // ""')"
  if [ -f "$p" ]; then cur="$(hash_file "$p")"; else cur=""; fi
  if   [ -z "$cur" ];                          then NEW+=("$p")
  elif [ "$cur" = "$up" ];                     then UNCHANGED=$((UNCHANGED+1))
  elif [ -n "$base" ] && [ "$cur" = "$base" ]; then UPDATE+=("$p")
  else                                              CONFLICT+=("$p")
  fi
done < <(printf '%s' "$UP_MAN" | jqr 'keys[]')

REMOVED=()
while IFS= read -r p; do
  [ -z "$p" ] && continue
  [ "$(printf '%s' "$UP_MAN" | jqr --arg p "$p" 'has($p)')" = "false" ] && REMOVED+=("$p")
done < <(printf '%s' "$LOCAL_MAN" | jqr 'keys[]')

plist() { local n="$1"; shift; if [ "$n" -eq 0 ]; then echo "   (none)"; else printf '   - %s\n' "$@"; fi; }
echo
echo "==================== forge-sync plan ===================="
echo "UPDATE   (template changed, local pristine) : ${#UPDATE[@]}";   plist "${#UPDATE[@]}"   "${UPDATE[@]}"
echo "NEW      (add to this project)              : ${#NEW[@]}";      plist "${#NEW[@]}"      "${NEW[@]}"
echo "CONFLICT (local edits; --force to overwrite): ${#CONFLICT[@]}"; plist "${#CONFLICT[@]}" "${CONFLICT[@]}"
echo "REMOVED  (gone upstream; left in place)     : ${#REMOVED[@]}";  plist "${#REMOVED[@]}"  "${REMOVED[@]}"
echo "UNCHANGED                                   : $UNCHANGED"
echo "========================================================="

TO_APPLY=("${UPDATE[@]}" "${NEW[@]}")
[ "$FORCE" = "1" ] && TO_APPLY+=("${CONFLICT[@]}")

if [ "$APPLY" != "1" ]; then
  echo
  echo "dry-run only. Re-run with --apply to write ${#TO_APPLY[@]} file(s)."
  [ "${#CONFLICT[@]}" -gt 0 ] && echo "NOTE: ${#CONFLICT[@]} conflict(s) need review; add --force to overwrite local edits."
  exit 0
fi

# ---------- apply ----------
if [ -n "$(git status --porcelain --untracked-files=no 2>/dev/null)" ]; then
  echo "FAIL: working tree has uncommitted changes to tracked files. Commit or stash first so you keep a clean rollback point."
  exit 2
fi
if [ "$LOCAL_VER" = "$UP_VER" ] && [ "${#TO_APPLY[@]}" -eq 0 ]; then
  echo "already up to date (v$LOCAL_VER)."
  exit 0
fi

applied=0
for p in "${TO_APPLY[@]}"; do
  mkdir -p "$(dirname "$p")"
  if upstream_file "$p" > "$p.forge-sync.tmp" 2>/dev/null; then
    mv "$p.forge-sync.tmp" "$p"; applied=$((applied+1)); echo "  wrote $p"
  else
    rm -f "$p.forge-sync.tmp"; echo "  WARN: could not fetch $p"
  fi
done

# adopt upstream version.json (carries the new manifest), stamp instance.json
printf '%s' "$UP_VJSON" | tr -d '\r' > "$VJSON"
if [ -f "$IJSON" ]; then
  tmp="$(mktemp)"; jq --arg t "$(date -u +%Y-%m-%dT%H:%M:%SZ)" '.last_synced = $t' "$IJSON" | tr -d '\r' > "$tmp" && mv "$tmp" "$IJSON"
fi

echo
echo "applied $applied file(s); structure version $LOCAL_VER -> $UP_VER"
echo
echo "============ migration notes (read for versions above $LOCAL_VER) ============"
upstream_file ".forge/CHANGELOG.md" 2>/dev/null | sed -n '1,70p' || echo "(no CHANGELOG upstream)"
echo "=============================================================================="
echo "IMPORTANT: agent/skill/manual files may have changed — RESTART the Claude session to load them."
[ "${#CONFLICT[@]}" -gt 0 ] && echo "REVIEW: ${#CONFLICT[@]} conflicted file(s) were left as-is (your local edits). Reconcile manually."
exit 0
