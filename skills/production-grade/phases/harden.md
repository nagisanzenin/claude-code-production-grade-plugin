# HARDEN Phase — Dispatcher

This phase manages tasks T5 (QA), T6a (Security), T6b (Code Review). All three run in parallel (PARALLEL #3 and #4).

## Authority Boundaries — CRITICAL

Enforce these boundaries strictly:
- **security-engineer** is SOLE authority on OWASP Top 10, STRIDE, PII, encryption
- **code-reviewer** does architecture conformance, code quality, performance — does NOT perform security review
- **code-reviewer** is READ-ONLY — produces findings and patch files, does NOT modify source code
- See `Claude-Production-Grade-Suite/.protocols/conflict-resolution.md` for full authority table

## Re-Anchor

Before creating HARDEN agent tasks, re-read key artifacts from disk:
- `Claude-Production-Grade-Suite/solution-architect/system-design.md`
- `docs/architecture/adr/*.md` (Glob to list)
- Directory listing of `services/`, `frontend/`, `libs/shared/` (what BUILD actually produced)
- `Claude-Production-Grade-Suite/.orchestrator/receipts/T3a-*.json`, `T3b-*.json` (BUILD receipts — what was built, metrics)

Use this freshly-read data when writing agent task prompts below.

## PARALLEL #3 + #4: T5 + T6a + T6b

All three start together:

Read `Claude-Production-Grade-Suite/.orchestrator/settings.md` to check if `Worktrees: enabled`. If enabled, add `isolation="worktree"` to each Agent call below.

```python
# T5: QA Testing
TaskUpdate(taskId=t5_id, status="in_progress")
Agent(
  prompt="""You are the QA Engineer.
Use the Skill tool to invoke 'production-grade:qa-engineer' to load your complete methodology and follow it.
Read implementation: services/, frontend/ (if exists), api/
Read protocols from: Claude-Production-Grade-Suite/.protocols/
Read .production-grade.yaml for paths.tests and paths.services.
Write tests to project root: tests/
Write workspace artifacts to: Claude-Production-Grade-Suite/qa-engineer/
You are the ORACLE OWNER (loop-protocol Rule 4): the tests/ tree is yours exclusively.
RUN every suite you write — a written-but-never-executed test is not an oracle. Use .orchestrator/oracle-full.sh where it fits; report pass/fail counts, never "written".
TEST-INTEGRITY REVIEW (TDD pair close-out): diff tests/ against your Wave A failing scaffolds. Any weakening by another agent (.skip, loosened assertion, deleted case) is a CRITICAL finding.
Distinguish test bugs (fix immediately — you own tests) from implementation bugs (log as findings; NEVER weaken the test to make the implementation pass).
When complete, write a receipt JSON to Claude-Production-Grade-Suite/.orchestrator/receipts/T5-qa-engineer.json with task, agent, phase, status, artifacts, metrics (including tests_run, tests_passing), effort, verification, loops. Then mark your task as completed.""",
  subagent_type="general-purpose",
  mode="bypassPermissions",
  run_in_background=True,
  isolation="worktree"  # Omit if Worktrees: disabled
)

# T6a: Security Audit (SOLE OWASP AUTHORITY)
TaskUpdate(taskId=t6a_id, status="in_progress")
Agent(
  prompt="""You are the Security Engineer — SOLE authority on OWASP, STRIDE, PII, encryption.
Use the Skill tool to invoke 'production-grade:security-engineer' to load your complete methodology and follow it.
No other skill performs security review. This is YOUR exclusive domain.
Read all implementation code: services/, frontend/, infrastructure/
Read protocols from: Claude-Production-Grade-Suite/.protocols/
Perform STRIDE threat modeling + OWASP Top 10 audit + dependency scan.
Write findings to: Claude-Production-Grade-Suite/security-engineer/
Auto-fix Critical/High issues with regression tests.
Document Medium/Low for remediation plan.
When complete, write a receipt JSON to Claude-Production-Grade-Suite/.orchestrator/receipts/T6a-security-engineer.json with task, agent, phase, status, artifacts, metrics, effort, verification. Then mark your task as completed.""",
  subagent_type="general-purpose",
  mode="bypassPermissions",
  run_in_background=True,
  isolation="worktree"  # Omit if Worktrees: disabled
)

# T6b: Code Review (NO OWASP — architecture + quality only)
TaskUpdate(taskId=t6b_id, status="in_progress")
Agent(
  prompt="""You are the Code Reviewer — architecture conformance and code quality ONLY.
Use the Skill tool to invoke 'production-grade:code-reviewer' to load your complete methodology and follow it.
DO NOT perform OWASP, STRIDE, or any security review — security-engineer is sole authority.
Cross-reference: "See security-engineer findings for security context."
Read architecture: docs/architecture/, api/
Read implementation: services/, frontend/
Read protocols from: Claude-Production-Grade-Suite/.protocols/
Review: SOLID/DRY/KISS, performance, N+1 queries, resource leaks, test quality.
Write findings to: Claude-Production-Grade-Suite/code-reviewer/
READ-ONLY: produce findings only, do NOT modify source code.
ADVERSARIAL STANCE: Your job is to find where this code breaks, not confirm it works. Assume every function has an edge case, every endpoint accepts bad input, every concurrent operation has a race condition. Hunt for the bugs the author can't see.
When complete, write a receipt JSON to Claude-Production-Grade-Suite/.orchestrator/receipts/T6b-code-reviewer.json with task, agent, phase, status, artifacts, metrics, effort, verification. Then mark your task as completed.""",
  subagent_type="general-purpose",
  mode="bypassPermissions",
  run_in_background=True,
  isolation="worktree"  # Omit if Worktrees: disabled
)
```

## Visual Output

Print pipeline dashboard with HARDEN ● active on phase start. Then print wave announcement:
```
┌─ HARDEN ─────────────────────────────── 3 agents ─┐
│                                                     │
│  T5   QA Engineer          implementing tests       │
│  T6a  Security Engineer    code audit + dep scan    │
│  T6b  Code Reviewer        arch + quality review    │
│                                                     │
│  All agents launched. Working autonomously...       │
└─────────────────────────────────────────────────────┘
```

## Worktree Merge-Back

If worktrees were used, merge each HARDEN agent's branch back after the wave completes:

```python
for branch in harden_worktree_branches:
  Bash(f"git merge --no-ff {branch} -m 'production-grade: merge {branch}'")
  Bash(f"git branch -d {branch}")
# If merge conflicts: git merge --abort, escalate to user
```

## Functional Drive — Execute the Dead Element Rule (Loop Protocol Rule 7)

After the three HARDEN agents complete (and worktree merge-back), dispatch the Functional Drive loop. **This is a GATE, not a report — HARDEN does not complete while any Dead Element (Critical) is open.** It replaces human hand-testing: the Dead Element Rule gets EXECUTED against the running app, not reviewed in source. (BUILD already ran a deep boot smoke as its exit gate; this is the exhaustive drive of every control.)

```python
Agent(
  prompt="""You are the Functional Drive agent (loop-protocol Rule 7).
Boot the app via .orchestrator/oracle-full.sh boot smoke (or docker-compose up) and DRIVE it as a user:
- Browser path (preferred): if a Playwright/browser MCP tool or a headless browser (`google-chrome --headless`, `chromium`) is available (check via ToolSearch / PATH), open every page from the navigation graph; CLICK every button, SUBMIT every form (valid + one invalid case), FOLLOW every link.
- Fallback path (no browser tooling): exercise every API endpoint per the OpenAPI spec with real HTTP calls (auth included), AND fetch each rendered page and assert every control resolves to a wired action (form `action` returns non-404; button/link has a handler/href). This is weaker than a real click — many client-side dead elements are invisible to it — so record in the receipt that the drive was API+static only and flag the coverage gap. Never report a clean drive you could not actually perform.
Oracle: every interactive element produces its intended effect (navigation lands, form persists + feedback renders, buttons act). Any element that renders but does nothing = CRITICAL finding (Dead Element Rule).
Loop: fix-worthy findings go to remediation; re-drive affected flows after fixes until 0 Critical or plateau (Rule 3). Scope by engagement mode (Rule 10): Express = critical flows smoke; Standard+ = full drive.
Write findings to Claude-Production-Grade-Suite/qa-engineer/functional-drive.md, loop log to .orchestrator/loops/, receipt to .orchestrator/receipts/T5c-functional-drive.json with metrics (elements_driven, dead_elements, flows_passed) and loops.""",
  subagent_type="general-purpose",
  mode="bypassPermissions",
  run_in_background=True
)
```

## Post-HARDEN: Receipt Verification & Remediation Preparation

After all HARDEN tasks complete:
1. **Verify receipts:** Read `.orchestrator/receipts/T5-qa-engineer.json`, `T6a-security-engineer.json`, `T6b-code-reviewer.json`, `T5c-functional-drive.json`. Verify all listed artifacts exist on disk. Surface any `loops` entry with exit `plateau|oscillation|budget`.
2. Collect all findings from T5, T5c, T6a, T6b workspace folders
2. Deduplicate by file:line — keep highest severity rating
3. Filter Critical/High severity findings
4. If any Critical/High exist → T8 (Remediation in SHIP phase) receives the findings list. **Remediation is a convergence loop, not a fixed pass** (loop-protocol Rule 3): ratchet = open Critical/High count; each cycle ends with the ORIGINAL finding agents re-scanning (verification receipts); exit on 0 Critical/High, plateau (2 no-progress cycles), or oscillation — hard cap 3 cycles as backstop, then escalate with the ratchet trajectory.
5. Medium/Low → documented but do not block pipeline
6. Print the checkmark cascade, then findings summary:
```
┌─ HARDEN COMPLETE ─────────────────────── ⏱ {time} ─┐
│                                                      │
│  ✓ QA Engineer          {N} tests, {M} passing       │
│  ✓ Security Engineer    {N} findings ({M} Crit/High) │
│  ✓ Code Reviewer        {N} findings ({M} Crit/High) │
│                                                      │
│  3/3 complete                                        │
└──────────────────────────────────────────────────────┘

━━━ Findings ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Critical   {N}    {top finding description}
                    {second finding if applicable}
  High       {N}    {summary}
  Medium     {N}    —
  Low        {N}    —
  ─────────────
  Total      {N}    deduplicated by file:line

  → {N} Critical/High items entering remediation
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Handoff to SHIP

**Re-anchor:** Before transitioning, re-read from disk:
- `Claude-Production-Grade-Suite/security-engineer/findings/` (what was found)
- `Claude-Production-Grade-Suite/code-reviewer/findings/critical.md`, `high.md`
- `Claude-Production-Grade-Suite/qa-engineer/` test results
- All HARDEN receipts from `.orchestrator/receipts/`

Read `phases/ship.md` and begin SHIP phase — use freshly-read findings data for remediation agent prompt.
