# SHIP Phase — Dispatcher

This phase manages tasks T7 (DevOps IaC), T8 (Remediation), T9 (SRE), T10 (Data Scientist). Features PARALLEL #5 and #6.

## Visual Output

Print pipeline dashboard with SHIP ● active on phase start, then:

```
  → Starting SHIP phase
```

On PARALLEL #5 completion:
```
┌─ SHIP: Infra + Remediation COMPLETE ────── ⏱ {time} ─┐
│                                                        │
│  ✓ DevOps         {N} Terraform modules, {M} workflows │
│  ✓ Remediation    {N} Critical/{M} High fixed          │
│                                                        │
│  → Starting SRE + Data Scientist                       │
└────────────────────────────────────────────────────────┘
```

On PARALLEL #6 completion:
```
┌─ SHIP COMPLETE ───────────────────────────── ⏱ {time} ─┐
│                                                          │
│  ✓ SRE              {N} SLOs, {M} alerts, {K} runbooks  │
│  ✓ Data Scientist    {N} optimizations (or skipped)      │
│                                                          │
│  → Presenting Gate 3: Production Readiness               │
└──────────────────────────────────────────────────────────┘
```

## Authority Boundaries

- **devops** owns infrastructure provisioning, CI/CD, monitoring setup — does NOT define SLOs
- **sre** owns SLO/SLI definitions, error budgets, runbooks, chaos engineering — does NOT provision infrastructure
- See `Claude-Production-Grade-Suite/.protocols/conflict-resolution.md`

## PARALLEL #5: T7 + T8

```python
# T7: DevOps IaC + CI/CD
TaskUpdate(taskId=t7_id, status="in_progress")
Agent(
  prompt="""You are the DevOps Engineer — IaC and CI/CD.
Read architecture: docs/architecture/
Read implementation: services/, frontend/
Read .production-grade.yaml for paths and preferences.
Read protocols from: Claude-Production-Grade-Suite/.protocols/
Generate: Terraform/Pulumi, K8s manifests (if microservices), CI/CD pipelines, monitoring dashboards.
Write to project root: infrastructure/, .github/workflows/
Write workspace artifacts to: Claude-Production-Grade-Suite/devops/
DO NOT define SLOs — add placeholder: "SLO thresholds defined by SRE."
DO NOT write runbooks — SRE writes runbooks to docs/runbooks/.
Validate: terraform validate, pipeline syntax lint.
When complete, mark your task as completed.""",
  subagent_type="general-purpose",
  mode="bypassPermissions",
  run_in_background=True
)

# T8: Remediation (fix HARDEN findings)
TaskUpdate(taskId=t8_id, status="in_progress")
Agent(
  prompt="""You are the Remediation Engineer.
Read HARDEN findings from workspace: Claude-Production-Grade-Suite/security-engineer/, code-reviewer/, qa-engineer/
Focus on Critical and High severity findings only.
For each finding:
  1. Read the affected file
  2. Apply the fix
  3. Run affected tests to verify no regressions
  4. Re-scan the affected code
If findings persist after 2 fix-rescan cycles → document and escalate.
Medium/Low findings: document but do not block.
When complete, mark your task as completed.""",
  subagent_type="general-purpose",
  mode="bypassPermissions",
  run_in_background=True
)
```

## PARALLEL #6: T9 + T10 (after T7 + T8 complete)

```python
# T9: SRE — Production Readiness (SOLE SLO AUTHORITY)
TaskUpdate(taskId=t9_id, status="in_progress")
Agent(
  prompt="""You are the SRE — SOLE authority on SLO definitions, error budgets, runbooks, capacity planning.
Read all prior outputs: architecture, implementation, infrastructure, HARDEN findings.
Read protocols from: Claude-Production-Grade-Suite/.protocols/
Perform production readiness review (checklist).
Define SLIs/SLOs per service, error budgets, burn-rate alerts.
Design chaos engineering scenarios and game-day playbook.
Write runbooks to project root: docs/runbooks/
Write workspace artifacts to: Claude-Production-Grade-Suite/sre/
When complete, mark your task as completed.""",
  subagent_type="general-purpose",
  mode="bypassPermissions",
  run_in_background=True
)

# T10: Data Scientist (conditional — auto-detect LLM/ML usage)
# Scan imports for: openai, anthropic, langchain, transformers, torch, tensorflow
# If detected OR features.ai_ml is true:
TaskUpdate(taskId=t10_id, status="in_progress")
Agent(
  prompt="""You are the Data Scientist.
Read implementation for LLM/ML usage patterns (imports, API calls, prompts).
Read protocols from: Claude-Production-Grade-Suite/.protocols/
Optimize: prompt engineering, token usage, semantic caching, fallback chains.
Design: A/B testing infrastructure, experiment framework, data pipeline.
Write workspace artifacts to: Claude-Production-Grade-Suite/data-scientist/
When complete, mark your task as completed.""",
  subagent_type="general-purpose",
  mode="bypassPermissions",
  run_in_background=True
)
# If NOT detected AND features.ai_ml is false:
#   TaskUpdate(taskId=t10_id, status="completed")  # Skip
```

## Gate 3 — Production Readiness

After T9 completes, present Gate 3 using the orchestrator's gate pattern.

On approval → read `phases/sustain.md` and begin SUSTAIN phase.
On "Fix issues first" → create additional remediation tasks.
