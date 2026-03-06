# BUILD Phase — Dispatcher

This phase manages tasks T3a (Backend), T3b (Frontend), and T4 (DevOps Containerization). Features PARALLEL #1 and #2.

## Visual Output

Print pipeline dashboard with BUILD ● active on phase start. Then print Wave A announcement:
```
┌─ WAVE A: BUILD + ANALYSIS ────────────── {N} agents ─┐
│                                                        │
│  T3a  Software Engineer    {services from architecture}│
│  T3b  Frontend Engineer    {pages from BRD}            │
│  T4a  DevOps               Dockerfiles + CI skeleton   │
│  T5a  QA Engineer          test plan from BRD          │
│  T6a  Security Engineer    STRIDE threat model         │
│  T6b  Code Reviewer        conformance checklist       │
│  T9a  SRE                  SLO definitions             │
│                                                        │
│  All agents launched. Working autonomously...          │
└────────────────────────────────────────────────────────┘
```

When Wave A completes, print the checkmark cascade:
```
┌─ WAVE A COMPLETE ─────────────────────── ⏱ {time} ─┐
│                                                      │
│  ✓ Software Engineer    {N} services, {M} endpoints  │
│  ✓ Frontend Engineer    {N} pages, {M} components    │
│  ✓ DevOps               {N} Dockerfiles, 1 compose   │
│  ✓ QA Engineer          {N} test cases planned       │
│  ✓ Security Engineer    STRIDE: {N} threats          │
│  ✓ Code Reviewer        {N} checkpoints defined      │
│  ✓ SRE                  {N} SLOs, {M} alerts         │
│                                                      │
│  {N}/{N} complete                                    │
│  → Starting Wave B ({M} agents against written code) │
└──────────────────────────────────────────────────────┘
```

Then print Wave B announcement and completion similarly. Each agent's completion line MUST include concrete numbers.

## Pre-Flight

Read `.production-grade.yaml` to determine:
- `features.frontend` → if false, skip T3b
- `project.architecture` → monolith vs microservices (affects containerization)
- `paths.services`, `paths.frontend`, `paths.shared_libs` → output locations

## PARALLEL #1: T3a + T3b

Spawn backend and frontend agents simultaneously as background Agents:

```python
# T3a: Backend Engineering
TaskUpdate(taskId=t3a_id, status="in_progress")
Agent(
  prompt="""You are the Backend Engineer.
Read architecture from: api/, schemas/, docs/architecture/
Read protocols from: Claude-Production-Grade-Suite/.protocols/
Read .production-grade.yaml for paths and preferences.
Invoke the software-engineer skill pattern.
Write services to project root: services/, libs/shared/
Write workspace artifacts to: Claude-Production-Grade-Suite/software-engineer/
TDD enforced: write test → watch fail → implement → watch pass → refactor.
When complete, mark your task as completed.""",
  subagent_type="general-purpose",
  mode="bypassPermissions",
  run_in_background=True
)

# T3b: Frontend Engineering (skip if features.frontend is false)
TaskUpdate(taskId=t3b_id, status="in_progress")
Agent(
  prompt="""You are the Frontend Engineer.
Read API contracts from: api/
Read BRD user stories from: Claude-Production-Grade-Suite/product-manager/BRD/
Read protocols from: Claude-Production-Grade-Suite/.protocols/
Read .production-grade.yaml for framework and styling preferences.
Invoke the frontend-engineer skill pattern.
Write frontend to project root: frontend/
Write workspace artifacts to: Claude-Production-Grade-Suite/frontend-engineer/
When complete, mark your task as completed.""",
  subagent_type="general-purpose",
  mode="bypassPermissions",
  run_in_background=True
)
```

## PARALLEL #2: T4 Starts When T3a Completes

T4 begins containerization as soon as backend is done, even if frontend is still building:

```python
# Wait for T3a completion (check TaskList or receive agent result)
TaskUpdate(taskId=t4_id, status="in_progress")
Agent(
  prompt="""You are the DevOps Containerization Engineer.
Read services from: services/
Read architecture from: docs/architecture/
Read .production-grade.yaml for paths and preferences.
Write Dockerfiles per service, docker-compose.yml at project root.
Write workspace artifacts to: Claude-Production-Grade-Suite/devops/containers/
Validate: docker build succeeds for each service, docker-compose up starts all.
When complete, mark your task as completed.""",
  subagent_type="general-purpose",
  mode="bypassPermissions",
  run_in_background=True
)
```

## Completion

When all BUILD tasks complete:
1. Verify all services compile and start
2. Verify docker-compose brings up the full stack
3. Log BUILD completion to workspace
4. Read `phases/harden.md` and begin HARDEN phase

## Failure Handling

- Build failure after 3 retries → escalate to user via AskUserQuestion
- Frontend fails but backend succeeds → continue backend-only pipeline
- Agents self-debug: read errors, fix, retry before escalating
