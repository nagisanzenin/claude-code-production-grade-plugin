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

## Re-Anchor

Before creating any agent tasks, re-read key artifacts from disk:
- `Claude-Production-Grade-Suite/product-manager/BRD/brd.md`
- `Claude-Production-Grade-Suite/solution-architect/system-design.md`
- `docs/architecture/adr/*.md` (Glob to list, Read key ADRs)
- `api/openapi/*.yaml` (Glob to list)
- `.orchestrator/receipts/T1-*.json`, `.orchestrator/receipts/T2-*.json`

Use this freshly-read data when writing agent task prompts below — not your compressed memory of DEFINE phase.

## Pre-Flight

Read `.production-grade.yaml` to determine:
- `features.frontend` → if false, skip T3b
- `project.architecture` → monolith vs microservices (affects containerization)
- `paths.services`, `paths.frontend`, `paths.shared_libs` → output locations

## Worktree Pre-Flight

Before launching parallel agents, check if worktree isolation is available:

```python
# Check for clean git state (worktrees require committed state)
result = Bash("git status --porcelain 2>/dev/null | head -5")
if result.strip():
  # Dirty repo — ask user
  AskUserQuestion(questions=[{
    "question": "Parallel agents work best with worktree isolation, but you have uncommitted changes.",
    "header": "Worktree Isolation",
    "options": [
      {"label": "Auto-commit and use worktrees (Recommended)", "description": "Commit current state, isolate each agent in its own worktree"},
      {"label": "Skip worktrees — run in shared directory", "description": "Agents share the working directory (risk of file conflicts)"},
      {"label": "Chat about this", "description": "Free-form input"}
    ],
    "multiSelect": False
  }])
  # If auto-commit: git add -A && git commit -m "production-grade: pre-BUILD checkpoint"
  # If skip: set use_worktrees = False
else:
  use_worktrees = True
```

Store the worktree decision in `Claude-Production-Grade-Suite/.orchestrator/settings.md` by appending:
```
Worktrees: [enabled|disabled]
```

## Oracle Bootstrap — Foundation Before Waves (Loop Protocol)

**Sequential, BEFORE launching any parallel agent.** Same rule as `libs/shared/`: shared foundations before parallel execution. Without this step, no downstream loop has anything to execute (loop-protocol Rule 1: no oracle, no loop).

Write two executable scripts to the workspace, tailored to this project's stack (detected in Pre-Flight / codebase discovery):

1. `Claude-Production-Grade-Suite/.orchestrator/oracle.sh` — the **fast oracle**: typecheck + lint only. Hard target: **under 15 seconds** (the oracle-gate hook runs it after every file edit and times out at 20s). Incremental/changed-file flags where the toolchain supports them. Brownfield: wire to the project's existing commands (`npm run typecheck`, `ruff check`, `go vet`, ...) — never introduce new tools when equivalents exist.
2. `Claude-Production-Grade-Suite/.orchestrator/oracle-full.sh` — the **full oracle**: test suite + build + boot smoke (compose up, health endpoint, compose down). Run at loop exits, wave merges, and phase transitions — not per edit.

Then:
- `chmod +x` both. **Execute both once** to prove they run (fast oracle may be red in greenfield — that is fine; it must *run*, not pass).
- If the fast oracle cannot get under 15s, move the slow part to `oracle-full.sh` and keep `oracle.sh` minimal. Never ship a fast oracle that times out — a timed-out gate is a silent gate.
- Escape hatch: touching `.orchestrator/oracle.off` disables the edit-gate temporarily (use during mass scaffolding bursts; DELETE it before the wave completes — a wave may not finish with the gate off).
- Write the **oracle inventory** receipt `T0-oracle-bootstrap.json`: every executable check now available (fast oracle, full oracle, per-service test commands, e2e driver if present), plus `metrics.fast_oracle_seconds`.

```
  ✓ Oracle Bootstrap    oracle.sh 6s (tsc --incremental + eslint) · oracle-full.sh 74s (jest + build + boot)
```

**TDD pair kickoff (loop-protocol Rule 7):** as part of Wave A, QA's test-plan task ALSO produces failing acceptance-test scaffolds under `tests/` for the top BRD criteria — executable and red. These are the oracle of record engineers build against. Engineers never modify anything under `tests/`.

## PARALLEL #1: T3a + T3b

Spawn backend and frontend agents simultaneously as background Agents.
When `use_worktrees` is True, add `isolation="worktree"` to each Agent call. Each agent gets its own isolated copy of the repo — no file race conditions.

```python
# T3a: Backend Engineering
TaskUpdate(taskId=t3a_id, status="in_progress")
Agent(
  prompt="""You are the Backend Engineer.
Use the Skill tool to invoke 'production-grade:software-engineer' to load your complete methodology and follow it.
Read architecture from: api/, schemas/, docs/architecture/
Read protocols from: Claude-Production-Grade-Suite/.protocols/
Read .production-grade.yaml for paths and preferences.
Write services to project root: services/, libs/shared/
Write workspace artifacts to: Claude-Production-Grade-Suite/software-engineer/
TDD enforced: write test → watch fail → implement → watch pass → refactor.
LOOP PROTOCOL (Claude-Production-Grade-Suite/.protocols/loop-protocol.md):
- Inner loop per unit: after edits, run .orchestrator/oracle.sh (fast) — keep it green; run your unit tests red→green.
- Oracle immutability: NEVER edit/skip/weaken anything under tests/ (QA-owned). If an acceptance test looks wrong, STOP and report it in your receipt.
- Exit each unit only when: fast oracle green + your unit tests green + relevant tests/ scaffolds passing.
- Log loops to .orchestrator/loops/ and include the loops array in your receipt (iterations, ratchet, exit).
When complete, write a receipt JSON to Claude-Production-Grade-Suite/.orchestrator/receipts/T3a-software-engineer.json with task, agent, phase, status, artifacts, metrics, effort, verification, loops. Then mark your task as completed.""",
  subagent_type="general-purpose",
  mode="bypassPermissions",
  run_in_background=True,
  isolation="worktree"  # Remove this line if use_worktrees is False
)

# T3b: Frontend Engineering (skip if features.frontend is false)
TaskUpdate(taskId=t3b_id, status="in_progress")
Agent(
  prompt="""You are the Frontend Engineer.
Read API contracts from: api/
Read BRD user stories from: Claude-Production-Grade-Suite/product-manager/BRD/
Read protocols from: Claude-Production-Grade-Suite/.protocols/
Read .production-grade.yaml for framework and styling preferences.

Use the Skill tool to invoke 'production-grade:frontend-engineer'. This loads your complete SKILL.md with a 6-phase build process. You MUST follow all 6 phases in order:
  Phase 1: Analysis — read BRD, API contracts, select framework
  Phase 2: Design System — functional defaults (tokens, theme, Tailwind)
  Phase 3: Components — UI primitives first (sequential), then layout+feature (parallel)
  Phase 4: Pages + Routing — parallel by route group, then functional verification (4b)
  Phase 5: Design & Polish — Style selection is engagement-mode-aware:
    Express: auto-select best style for the domain, report choice, proceed.
    Standard+: ask user via AskUserQuestion (Creative | Elegance | High Tech | Corporate | Custom).
  Phase 6: Testing & A11y — component tests, accessibility audit

Write frontend to project root: frontend/
Write workspace artifacts to: Claude-Production-Grade-Suite/frontend-engineer/
LOOP PROTOCOL (Claude-Production-Grade-Suite/.protocols/loop-protocol.md):
- Inner loop per component/page: after edits, run .orchestrator/oracle.sh (fast) — keep it green.
- Oracle immutability: NEVER edit/skip/weaken anything under tests/ (QA-owned).
- Phase 4b (Functional Verification) is a loop, not a pass: fix → re-verify until 0 dead elements or plateau (then escalate per Rule 6).
- Log loops to .orchestrator/loops/ and include the loops array in your receipt.
When complete, write a receipt JSON to Claude-Production-Grade-Suite/.orchestrator/receipts/T3b-frontend-engineer.json with task, agent, phase, status, artifacts, metrics, effort, verification, loops. Then mark your task as completed.""",
  subagent_type="general-purpose",
  mode="bypassPermissions",
  run_in_background=True,
  isolation="worktree"  # Remove this line if use_worktrees is False
)
```

## PARALLEL #2: T4 Starts When T3a Completes

T4 begins containerization as soon as backend is done, even if frontend is still building:

```python
# Wait for T3a completion (check TaskList or receive agent result)
# If T3a used worktree: merge its branch first so T4 sees the code
TaskUpdate(taskId=t4_id, status="in_progress")
Agent(
  prompt="""You are the DevOps Containerization Engineer.
Use the Skill tool to invoke 'production-grade:devops' to load your complete methodology and follow it.
Read services from: services/
Read architecture from: docs/architecture/
Read .production-grade.yaml for paths and preferences.
Write Dockerfiles per service, docker-compose.yml at project root.
Write workspace artifacts to: Claude-Production-Grade-Suite/devops/containers/
Validate: docker build succeeds for each service, docker-compose up starts all.
When complete, write a receipt JSON to Claude-Production-Grade-Suite/.orchestrator/receipts/T4-devops.json with task, agent, phase, status, artifacts, metrics, effort, verification. Then mark your task as completed.""",
  subagent_type="general-purpose",
  mode="bypassPermissions",
  run_in_background=True,
  isolation="worktree"  # Remove this line if use_worktrees is False
)
```

## Worktree Merge-Back

If worktrees were used, merge each agent's branch back to the working branch after the wave completes:

```python
# For each completed agent that used a worktree:
# The Agent result includes the worktree branch name.
# Merge each branch in sequence (should be conflict-free — agents write to different directories).
for branch in worktree_branches:
  Bash(f"git merge --no-ff {branch} -m 'production-grade: merge {branch}'")
  Bash(f"git branch -d {branch}")  # Clean up merged branch

# If any merge has conflicts:
#   1. Run: git merge --abort
#   2. Escalate to user via AskUserQuestion
#   3. Offer: "Resolve conflicts manually" or "Retry without worktrees"
```

After merging, all agent outputs are unified in the working directory.

**Integration loop (loop-protocol Rule 7) — run immediately after every merge-back:** execute `.orchestrator/oracle-full.sh` against the merged tree. Agents that were green in isolated worktrees can be red together — this is where cross-agent seam defects (mismatched contracts, duplicate handlers, broken imports) surface. If red: open a remediation loop (ratchet = failing checks; delta = failing output only; escalate per Rule 6 on plateau/oscillation). Do NOT proceed to the next wave on a red merge. Log the loop to `.orchestrator/loops/`.

## Completion

When all BUILD tasks complete:
1. **Merge worktree branches** (if worktrees enabled) — see Worktree Merge-Back above, including the post-merge integration loop.
2. **Verify receipts:** Read all BUILD receipts from `.orchestrator/receipts/` (T3a, T3b, T4). Verify all listed artifacts exist on disk. Surface any receipt whose `loops` array has an exit of `plateau|oscillation|budget`.
3. **Re-anchor:** Re-read from disk before transitioning to HARDEN:
   - Directory listing of `services/`, `frontend/`, `libs/shared/` (what was actually built)
   - `Claude-Production-Grade-Suite/solution-architect/system-design.md` (architecture reference for HARDEN agents)
3. Verify all services compile and start
4. Verify docker-compose brings up the full stack
5. Log BUILD completion to workspace
6. Read `phases/harden.md` and begin HARDEN phase — use freshly-read data for agent prompts

## Failure Handling

Follow the loop-protocol escalation ladder (Rule 6) — escalate STRATEGY, not effort:
- Agent self-debug loop: delta-only feedback, ratchet on the error count, plateau after 2 no-progress rounds (hard cap 3 attempts).
- On plateau/oscillation → fresh agent with a different stated approach → re-plan one altitude up → only then escalate to user via AskUserQuestion (include: what was tried, oracle output, ratchet trajectory).
- Frontend fails but backend succeeds → continue backend-only pipeline
- Never mark a wave complete with `.orchestrator/oracle.off` present or a red integration loop.
