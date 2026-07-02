# Receipt Protocol — Verifiable Gate Enforcement

**Core principle: Every completed task must have proof it actually ran. No receipt = not done.**

---

## Receipt Schema

Every agent writes a JSON receipt as its LAST action before `TaskUpdate(status="completed")`.

**File path:** `Claude-Production-Grade-Suite/.orchestrator/receipts/{task_id}-{agent_name}.json`

**Required fields:**

```json
{
  "task": "T6b",
  "agent": "code-reviewer",
  "phase": "HARDEN",
  "status": "complete",
  "artifacts": [
    "Claude-Production-Grade-Suite/code-reviewer/review-report.md",
    "Claude-Production-Grade-Suite/code-reviewer/findings/critical.md",
    "Claude-Production-Grade-Suite/code-reviewer/metrics/complexity.json"
  ],
  "metrics": {
    "findings_critical": 2,
    "findings_high": 5,
    "findings_medium": 12,
    "findings_low": 8
  },
  "effort": {
    "files_read": 47,
    "files_written": 6,
    "tool_calls": 83
  },
  "loops": [
    { "id": "t6b-review-round", "iterations": 2, "ratchet": "critical 3→1→0", "exit": "converged" }
  ],
  "verification": "all 4 review phases executed, review-report.md written with executive summary"
}
```

**Field rules:**

| Field | Type | Rule |
|-------|------|------|
| `task` | string | Task ID from the orchestrator (T1, T2, T3a, etc.) |
| `agent` | string | Skill name (product-manager, software-engineer, etc.) |
| `phase` | string | Pipeline phase (DEFINE, BUILD, HARDEN, SHIP, SUSTAIN) |
| `status` | string | Always `"complete"` — only write receipt on success |
| `artifacts` | string[] | Every file the agent created or modified. Each path MUST exist on disk at time of writing. |
| `metrics` | object | Key-value pairs with concrete numbers. At least one metric required. No empty objects. |
| `effort` | object | Tracking: `files_read` (int), `files_written` (int), `tool_calls` (int). Count your actual tool invocations during this task. |
| `verification` | string | One-line summary of what the agent checked to confirm its work is correct. |
| `loops` | object[] | One entry per loop run (loop-protocol Rule 9): `id`, `iterations` (int), `ratchet` (trajectory string), `exit` (`converged\|plateau\|oscillation\|budget`). Required whenever the task iterated; `[]` only for genuinely single-pass tasks. Any non-`converged` exit is surfaced at the next gate. |

---

## When to Write

Write the receipt as your ABSOLUTE LAST action, after all files are written and verified:

```
1. Do all your work (write files, run tests, generate reports)
2. Verify your outputs exist and are valid
3. Write receipt JSON to .orchestrator/receipts/
4. THEN call TaskUpdate(status="completed")
```

Never write the receipt before the work is done. Never skip the receipt.

---

## Remediation Chain

For findings that require remediation, the chain is:

1. **Finding receipt** — the agent that found the issue (security-engineer, code-reviewer, qa-engineer) writes its normal completion receipt listing findings
2. **Remediation receipt** — the remediation agent writes a receipt listing which findings were fixed and which files were modified
3. **Verification receipt** — the ORIGINAL finding agent re-scans and writes a verification receipt: `{task_id}-{agent_name}-verification.json`

All three must exist for a Critical/High finding to be considered resolved. The orchestrator checks this chain before Gate 3.

**Verification receipt schema:**

```json
{
  "task": "T6a-verify",
  "agent": "security-engineer",
  "phase": "SHIP",
  "status": "complete",
  "artifacts": [],
  "metrics": {
    "original_critical": 3,
    "remaining_critical": 0,
    "original_high": 5,
    "remaining_high": 1
  },
  "verification": "re-scanned all previously flagged files, 0 Critical remaining, 1 High accepted with justification"
}
```

---

## Orchestrator Verification

At every phase transition and before every gate, the orchestrator:

1. **Lists expected receipts** for the completed phase
2. **Reads each receipt** from `.orchestrator/receipts/`
3. **Verifies artifacts exist** — for each path in `receipt.artifacts`, confirm the file exists on disk
4. **If receipt missing** — the task did not complete properly. Investigate before proceeding.
5. **If artifacts missing** — the agent claimed a file it didn't persist (e.g. its Write tool was blocked on a report `.md`). RECOVER it: persist the artifact from the agent's returned content, or re-dispatch the task, then re-verify. NEVER open a gate with a missing artifact.
6. **Extracts metrics** for gate ceremony display — users see verified data, not agent claims

---

## Anti-Patterns

| Wrong | Right |
|-------|-------|
| Writing receipt before work is done | Receipt is the LAST action, after all files verified |
| Empty `artifacts` array when files were created | List every file the agent produced |
| `"metrics": {}` | At least one concrete number in metrics |
| `"verification": "done"` | Describe what was actually verified |
| Skipping receipt because "it's a small task" | Every task gets a receipt, regardless of size |
| Writing receipt but not checking artifacts exist | Verify each artifact path before writing receipt |
| `"effort": {}` or missing effort field | Count files_read, files_written, tool_calls from your actual work |
| Iterated work with no `loops` entry | Every loop is registered: contract in `.orchestrator/loops/`, summary in the receipt. Unregistered loops are invisible cost. |
| Reporting a `plateau`/`budget` exit as success | Non-convergence is information. State it in the receipt; the orchestrator surfaces it at the gate. |
| Receipt lists a report/doc file the Write tool couldn't create (blocked/sandboxed) | Persist it via Bash heredoc (`cat > file <<'EOF'`), verify it exists, THEN write the receipt. An artifact you couldn't write is not done. |
