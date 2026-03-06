# HARDEN Phase — Dispatcher

This phase manages tasks T5 (QA), T6a (Security), T6b (Code Review). All three run in parallel (PARALLEL #3 and #4).

## Authority Boundaries — CRITICAL

Enforce these boundaries strictly:
- **security-engineer** is SOLE authority on OWASP Top 10, STRIDE, PII, encryption
- **code-reviewer** does architecture conformance, code quality, performance — does NOT perform security review
- **code-reviewer** is READ-ONLY — produces findings and patch files, does NOT modify source code
- See `Claude-Production-Grade-Suite/.protocols/conflict-resolution.md` for full authority table

## PARALLEL #3 + #4: T5 + T6a + T6b

All three start together:

```python
# T5: QA Testing
TaskUpdate(taskId=t5_id, status="in_progress")
Agent(
  prompt="""You are the QA Engineer.
Read implementation: services/, frontend/ (if exists), api/
Read protocols from: Claude-Production-Grade-Suite/.protocols/
Read .production-grade.yaml for paths.tests and paths.services.
Write tests to project root: tests/
Write workspace artifacts to: Claude-Production-Grade-Suite/qa-engineer/
Run integration, e2e, and performance tests.
Distinguish test bugs (fix immediately) from implementation bugs (log as findings).
When complete, mark your task as completed.""",
  subagent_type="general-purpose",
  mode="bypassPermissions",
  run_in_background=True
)

# T6a: Security Audit (SOLE OWASP AUTHORITY)
TaskUpdate(taskId=t6a_id, status="in_progress")
Agent(
  prompt="""You are the Security Engineer — SOLE authority on OWASP, STRIDE, PII, encryption.
No other skill performs security review. This is YOUR exclusive domain.
Read all implementation code: services/, frontend/, infrastructure/
Read protocols from: Claude-Production-Grade-Suite/.protocols/
Perform STRIDE threat modeling + OWASP Top 10 audit + dependency scan.
Write findings to: Claude-Production-Grade-Suite/security-engineer/
Auto-fix Critical/High issues with regression tests.
Document Medium/Low for remediation plan.
When complete, mark your task as completed.""",
  subagent_type="general-purpose",
  mode="bypassPermissions",
  run_in_background=True
)

# T6b: Code Review (NO OWASP — architecture + quality only)
TaskUpdate(taskId=t6b_id, status="in_progress")
Agent(
  prompt="""You are the Code Reviewer — architecture conformance and code quality ONLY.
DO NOT perform OWASP, STRIDE, or any security review — security-engineer is sole authority.
Cross-reference: "See security-engineer findings for security context."
Read architecture: docs/architecture/, api/
Read implementation: services/, frontend/
Read protocols from: Claude-Production-Grade-Suite/.protocols/
Review: SOLID/DRY/KISS, performance, N+1 queries, resource leaks, test quality.
Write findings to: Claude-Production-Grade-Suite/code-reviewer/
READ-ONLY: produce findings only, do NOT modify source code.
When complete, mark your task as completed.""",
  subagent_type="general-purpose",
  mode="bypassPermissions",
  run_in_background=True
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

## Post-HARDEN: Remediation Preparation

After all HARDEN tasks complete:
1. Collect all findings from T5, T6a, T6b workspace folders
2. Deduplicate by file:line — keep highest severity rating
3. Filter Critical/High severity findings
4. If any Critical/High exist → T8 (Remediation in SHIP phase) receives the findings list
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

Read `phases/ship.md` and begin SHIP phase.
