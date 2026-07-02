#!/usr/bin/env bash
# Production-Grade Oracle Gate — PostToolUse hook (loop-protocol Rule 7: inner loop)
#
# Runs the project's FAST oracle after a source-file edit, but ONLY while a
# production-grade pipeline is active (an oracle.sh exists in the workspace).
#
# v5.5.1 hardening:
#  - resolves the workspace by walking UP from the EDITED FILE (worktree-safe),
#    then falling back to CLAUDE_PROJECT_DIR / CWD  (fixes B3)
#  - skips non-source edits (docs/config/data) so a README edit does not run a
#    full typecheck  (fixes B4)
#  - "arm after first green": does NOT block while the tree is still red for the
#    first time (greenfield scaffolding is red by construction) — only enforces
#    once the oracle has gone green at least once this run  (fixes B1 thrash)
#  - scopes the feedback to the file that triggered it  (fixes B1 misattribution)
#  - passes the edited file to oracle.sh as $1 so a good oracle can be incremental
#
# PostToolUse cannot undo the edit; exit 2 surfaces stderr to the agent as
# feedback so it fixes before the next edit.

INPUT=$(timeout 2 cat 2>/dev/null)

# --- which file was edited? (parse hook stdin; no hard jq/python dependency) ---
edited=$(printf '%s' "$INPUT" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)
[ -z "$edited" ] && edited=$(printf '%s' "$INPUT" | sed -n 's/.*"notebook_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)

# --- skip non-source edits: the fast oracle is for code, not docs/config/data ---
case "$edited" in
  *.md|*.mdx|*.txt|*.rst|*.json|*.yaml|*.yml|*.toml|*.ini|*.cfg|*.conf|*.lock|*.csv|*.tsv|*.svg|*.png|*.jpg|*.jpeg|*.gif|*.ico|*.webp|*.pdf|*.env|*.gitignore|*.dockerignore|*.editorconfig|*.log|*.map)
    exit 0 ;;
esac

# --- locate the workspace by walking UP from the edited file (worktree-safe) ---
ws=""
d=$(dirname "$edited" 2>/dev/null)
n=0
while [ -n "$d" ] && [ "$d" != "/" ] && [ "$d" != "." ] && [ $n -lt 40 ]; do
  if [ -f "$d/Claude-Production-Grade-Suite/.orchestrator/oracle.sh" ]; then ws="$d"; break; fi
  d=$(dirname "$d"); n=$((n + 1))
done
if [ -z "$ws" ]; then
  for cand in "$CLAUDE_PROJECT_DIR" "$PWD" "."; do
    [ -n "$cand" ] && [ -f "$cand/Claude-Production-Grade-Suite/.orchestrator/oracle.sh" ] && { ws="$cand"; break; }
  done
fi
# No active pipeline workspace anywhere → silent no-op (the common case).
[ -z "$ws" ] && exit 0

ORCH="$ws/Claude-Production-Grade-Suite/.orchestrator"

# Escape hatch: pipeline can park the gate during mass scaffolding bursts.
[ -f "$ORCH/oracle.off" ] && exit 0

# --- run the fast oracle, passing the edited file so it can scope/incremental ---
OUT=$(cd "$ws" && timeout 20 bash "$ORCH/oracle.sh" "$edited" 2>&1); RC=$?

# Timeout → never punish an edit for a slow oracle (bootstrap owns keeping it fast).
[ "$RC" -eq 124 ] && exit 0

if [ "$RC" -eq 0 ]; then
  # First green arms the gate for the rest of the run.
  [ -f "$ORCH/oracle.armed" ] || : > "$ORCH/oracle.armed"
  exit 0
fi

# Oracle is RED but the tree has never been green yet → greenfield scaffolding.
# Report softly, do NOT block (avoids per-edit thrash before anything compiles).
if [ ! -f "$ORCH/oracle.armed" ]; then
  echo "[oracle-gate] fast oracle still red (pre-green scaffolding); not blocking yet. Last edit: ${edited##*/}" >&2
  exit 0
fi

# Armed + red → enforce, attributed to the triggering edit.
{
  echo "ORACLE FAILED (exit $RC) — fast oracle is red after editing: ${edited:-<unknown>}"
  echo "It is a project-wide typecheck/lint, so the failure may be in another file;"
  echo "read the output and fix before the next edit (loop-protocol Rule 3: ratchet must not regress)."
  echo "If a TEST is wrong, do not weaken it — report it to its owner (Rule 4)."
  echo "── oracle output (tail) ──"
  printf '%s\n' "$OUT" | tail -40
} >&2
exit 2
