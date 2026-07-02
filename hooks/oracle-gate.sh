#!/usr/bin/env bash
# Production-Grade Oracle Gate — PostToolUse hook (loop-protocol Rule 7: inner loop)
#
# Runs the project's FAST oracle (typecheck + lint) after every file edit,
# but ONLY while a production-grade pipeline is active in this project —
# i.e. the BUILD Oracle Bootstrap step has written oracle.sh into the
# workspace. Everywhere else this is a single [ -f ] test and an instant
# no-op. On oracle failure, the failing output is returned to Claude
# (exit 2 → stderr feeds back as context) so the inner red-green loop is
# enforced by the harness, not by prompt discipline.

ROOT="${CLAUDE_PROJECT_DIR:-.}"
ORACLE="$ROOT/Claude-Production-Grade-Suite/.orchestrator/oracle.sh"

# No active pipeline (or no bootstrap yet) → stay silent
[ -f "$ORACLE" ] || exit 0

# Escape hatch: pipeline can park the gate (e.g. during scaffolding bursts)
[ -f "$ROOT/Claude-Production-Grade-Suite/.orchestrator/oracle.off" ] && exit 0

OUT=$(cd "$ROOT" && timeout 20 bash "$ORACLE" 2>&1)
RC=$?

# Green → silent
[ "$RC" -eq 0 ] && exit 0

# Timeout → never punish edits for a slow oracle; bootstrap owns keeping it fast
[ "$RC" -eq 124 ] && exit 0

{
  echo "ORACLE FAILED (exit $RC) — fast oracle is red after this edit."
  echo "Fix before proceeding (loop-protocol Rule 3: ratchet must not regress)."
  echo "If a TEST is wrong, do not weaken it — report it to its owner (Rule 4)."
  echo "── oracle.sh output (tail) ──"
  echo "$OUT" | tail -40
} >&2
exit 2
