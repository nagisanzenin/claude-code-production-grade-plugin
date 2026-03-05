---
name: production-grade
description: Orchestrates a fully autonomous production pipeline from idea to deployed system. Triggers on "production grade", "build a SaaS", "full stack", "production ready", "build me a", "build a platform", or any greenfield project needing the complete define-build-harden-ship-sustain pipeline. The user sits at the CEO/CTO seat — this skill handles everything else.
hooks:
  - event: UserPromptSubmit
    pattern: "production.grade|build.a.saas|full.stack|production.ready|build.me|build.a.platform"
    action: "evaluate-activate-implement"
---

# Production Grade

!`git status 2>/dev/null || echo "No git repo detected"`
!`cat CLAUDE.md 2>/dev/null || echo "No CLAUDE.md found"`
!`ls Claude-Production-Grade-Suite/ 2>/dev/null || echo "No existing workspace"`
!`cat .production-grade.yaml 2>/dev/null || echo "No config file — defaults apply"`

## Overview

Fully autonomous meta-skill orchestrator using Claude Code **Teams** and **TaskList** for native pipeline state management. The user gives a high-level vision; this skill runs the DEFINE → BUILD → HARDEN → SHIP → SUSTAIN pipeline with 13 coordinated tasks and 7 parallel execution points.

**All skills are bundled in this plugin. Single install, everything included.**

**Partial execution:** Parse `$ARGUMENTS` for subset requests — "just define", "just build", "just harden", "just ship", "just document". Use `$0` for the command and `$1` onward for scope qualifiers.

## When to Use

- Starting a new SaaS, platform, or service from scratch
- Building a complete production-ready system end-to-end
- Going from idea to working, tested, secured, deployed code
- User says "build me a...", "production grade", "production ready"

## Auto-Update Check

Run BEFORE Pipeline Kickoff. Silent if current. One prompt max if update exists.

**Step 0 — version check:**

1. Read `~/.claude/plugins/installed_plugins.json` → find the `production-grade@nagisanzenin` entry → extract `version` (this is your local version)
2. WebFetch `https://raw.githubusercontent.com/nagisanzenin/claude-code-production-grade-plugin/main/.claude-plugin/plugin.json` → extract `version` (this is the remote version)
3. **If WebFetch fails** (offline, timeout, 404) → silently continue. Never block the pipeline over an update check.
4. **If remote ≤ local** → continue silently (user sees nothing)
5. **If remote > local** → prompt:

```python
AskUserQuestion(questions=[{
  "question": "production-grade v{remote} is available (you have v{local})",
  "header": "Update Available",
  "options": [
    {"label": "Update to v{remote} (Recommended)", "description": "Auto-update and restart pipeline"},
    {"label": "Skip — continue with v{local}", "description": "Use current version"}
  ],
  "multiSelect": false
}])
```

6. **If skip** → continue pipeline with current version
7. **If update** → execute in sequence:
   ```bash
   git clone --depth 1 https://github.com/nagisanzenin/claude-code-production-grade-plugin.git /tmp/pg-update
   ```
   - Read new SHA: `git -C /tmp/pg-update rev-parse HEAD`
   - Create cache dir: `mkdir -p ~/.claude/plugins/cache/nagisanzenin/production-grade/{remote_version}`
   - Copy files: `cp -r /tmp/pg-update/skills /tmp/pg-update/.claude-plugin /tmp/pg-update/README.md /tmp/pg-update/VISION.md ~/.claude/plugins/cache/nagisanzenin/production-grade/{remote_version}/`
   - Update `~/.claude/plugins/installed_plugins.json` → set `version` to remote version, `installPath` to new cache dir, `gitCommitSha` to new SHA, `lastUpdated` to current ISO timestamp
   - Clean up: `rm -rf /tmp/pg-update`
   - Print: `✓ Updated to v{remote_version}. Re-invoke /production-grade to use the new version.`
   - **STOP** — do not continue pipeline. The current session loaded the old SKILL.md; the user must re-invoke to pick up new content.

**If any update step fails**, print a warning and continue with the current version. Never let the updater break the pipeline.

## Pipeline Kickoff

When triggered, follow this EXACT sequence:

1. **Print kickoff banner:**
```
━━━ Production Grade Pipeline v{local_version} ━━━━━━━━━━━━━━━━━━
Project: [extracted from user's message]
⧖ Bootstrapping workspace...
```

2. **Bootstrap workspace:**
```bash
mkdir -p Claude-Production-Grade-Suite/.protocols/
mkdir -p Claude-Production-Grade-Suite/.orchestrator/
```

3. **Write shared protocols** to `Claude-Production-Grade-Suite/.protocols/`:

| Protocol File | Content |
|---------------|---------|
| `ux-protocol.md` | 6 UX rules: never open-ended questions, "Chat about this" last, recommended first, continuous execution, real-time progress, autonomy |
| `input-validation.md` | 5-step validation: read config → probe inputs in parallel → classify Critical/Degraded/Optional → print gap summary → adapt scope |
| `tool-efficiency.md` | Parallel tool calls, smart_outline before Read, Glob not find, Grep not grep, config-aware paths |
| `conflict-resolution.md` | Authority hierarchy, dedup by file:line (keep highest severity), HARDEN→BUILD feedback loops (2 cycle max) |

Read these from the plugin's `skills/_shared/protocols/` directory and copy them. If plugin path is unavailable, write from the summaries above.

4. **Detect or generate config:**
   - If `.production-grade.yaml` exists → read it, use `paths.*` and `preferences.*`
   - If not → auto-detect from project structure (package.json → typescript, go.mod → go, etc.), offer to generate via AskUserQuestion

5. **Detect existing workspace** — if `Claude-Production-Grade-Suite/.orchestrator/` has prior state, offer to resume or restart via AskUserQuestion.

6. **Polymath pre-flight check:**
   - If `Claude-Production-Grade-Suite/polymath/handoff/context-package.md` exists → read it, pass to PM as pre-loaded context. Log: `✓ Polymath context loaded — skipping redundant discovery`
   - If no polymath context, assess the user's request for knowledge gaps:
     - **Vague scope** (no specific problem domain), **no constraints** (scale, budget, team), **complex domain with no domain language**, **contradictory signals**
     - If gaps detected → invoke `Skill("polymath")` for pre-flight consultation before proceeding. The polymath will research, clarify with the user, and write a context package when ready.
     - If no gaps → proceed directly. Log: `✓ Request is clear — proceeding to PM`
   - If user explicitly requests to skip polymath ("just build it", clear detailed spec) → proceed immediately.

7. **Research the domain** — use WebSearch before asking the user anything (skip if polymath already researched).

8. **Create team and task graph:**
```python
TeamCreate(team_name="production-grade")
```
Create all 13 tasks with dependencies (see Task Dependency Graph). Use TaskCreate for each, then TaskUpdate to set `addBlockedBy` relationships using the returned task IDs.

9. **Begin Phase 1** — read `phases/define.md` and start immediately. Do NOT ask "should I proceed?"

**Key principle:** The user already told you what to build. Research, plan, start building. Only pause at the 3 approval gates.

## User Experience Protocol

Follow the shared UX Protocol at `Claude-Production-Grade-Suite/.protocols/ux-protocol.md`. Key rules:
1. **NEVER** ask open-ended questions — always use AskUserQuestion with predefined options
2. **"Chat about this"** always last option
3. **Recommended option first** with `(Recommended)` suffix
4. **Continuous execution** — work until next gate or completion
5. **Real-time progress** — constant ⧖/✓ terminal updates
6. **Autonomy** — sensible defaults, self-resolve, report decisions

### Gate Companion — Polymath Integration

When the user selects **"Chat about this"** at any gate, invoke the polymath in translate mode:

```python
Skill(skill="polymath")
# Polymath reads the gate artifacts, explains in plain language,
# answers the user's questions via structured options,
# then re-presents the original gate options when the user is ready.
```

This ensures non-technical users can understand what they're approving without the orchestrator needing to be the translator.

### Strategic Gates (3 total)

**Gate 1 — BRD Approval** (after T1):
```python
AskUserQuestion(questions=[{
  "question": "BRD complete: [X] user stories, [Y] acceptance criteria. Approve?",
  "header": "Gate 1: BRD",
  "options": [
    {"label": "Approve — start architecture (Recommended)", "description": "BRD locked, proceed to Solution Architect"},
    {"label": "Show BRD details", "description": "Display the full BRD before deciding"},
    {"label": "I have changes", "description": "Request modifications to requirements"},
    {"label": "Chat about this", "description": "Free-form input about the BRD"}
  ],
  "multiSelect": false
}])
```

**Gate 2 — Architecture Approval** (after T2):
```python
AskUserQuestion(questions=[{
  "question": "Architecture complete: [tech stack summary]. Approve to start building?",
  "header": "Gate 2: Arch",
  "options": [
    {"label": "Approve — start building (Recommended)", "description": "Architecture locked, begin autonomous BUILD phase"},
    {"label": "Show architecture details", "description": "Walk through ADRs, diagrams, and API spec"},
    {"label": "I have concerns", "description": "Flag issues with architecture decisions"},
    {"label": "Chat about this", "description": "Free-form input about the architecture"}
  ],
  "multiSelect": false
}])
```

**Gate 3 — Production Readiness** (after T9):
```python
AskUserQuestion(questions=[{
  "question": "All phases complete. [summary]. Ship it?",
  "header": "Gate 3: Ship",
  "options": [
    {"label": "Ship it — production ready (Recommended)", "description": "Finalize assembly and deploy"},
    {"label": "Show full report", "description": "Display complete pipeline summary"},
    {"label": "Fix issues first", "description": "Address remaining findings before shipping"},
    {"label": "Chat about this", "description": "Free-form input about production readiness"}
  ],
  "multiSelect": false
}])
```

## Task Dependency Graph

13 tasks, 7 parallel execution points:

```
T1: product-manager (BRD)
    ↓ [GATE 1]
T2: solution-architect (Architecture)
    ↓ [GATE 2]
T3a: software-engineer (Backend) ─────┐
T3b: frontend-engineer (Frontend) ────┘ ← PARALLEL #1
    ↓ (T4 starts when T3a done)
T4: devops (Containerization) ─────────── PARALLEL #2 (runs while T3b may still be going)
    ↓ (all BUILD done)
T5: qa-engineer (Testing) ────────────┐
T6a: security-engineer (Audit) ───────┤ ← PARALLEL #3
T6b: code-reviewer (Quality) ─────────┘ ← PARALLEL #4 (no OWASP)
    ↓
T7: devops (IaC + CI/CD) ────────────┐
T8: Remediation (HARDEN fixes) ──────┘ ← PARALLEL #5
    ↓
T9: sre (Production Readiness) ──────┐
T10: data-scientist (conditional) ───┘ ← PARALLEL #6
    ↓ [GATE 3]
T11: technical-writer (Docs) ────────┐
T12: skill-maker (Custom Skills) ────┘ ← PARALLEL #7
    ↓
T13: Compound Learning + Assembly
```

### Task Dependencies

Create tasks with TaskCreate, then set dependencies with TaskUpdate using the returned IDs.

| Task | Blocked By | Notes |
|------|-----------|-------|
| T1 | — | First task, no blockers |
| T2 | T1 | Needs BRD |
| T3a | T2 | Needs architecture |
| T3b | T2 | Needs architecture |
| T4 | T3a | Starts when backend done (not frontend) |
| T5 | T3a, T3b, T4 | Needs all BUILD output |
| T6a | T3a, T3b, T4 | Needs all BUILD output |
| T6b | T3a, T3b, T4 | Needs all BUILD output |
| T7 | T5, T6a, T6b | Needs HARDEN output |
| T8 | T5, T6a, T6b | Needs HARDEN findings |
| T9 | T7, T8 | Needs IaC + remediation |
| T10 | T7, T8 | Conditional on AI/ML usage |
| T11 | T9 | Needs all prior output |
| T12 | T9 | Needs all prior output |
| T13 | T11, T12 | Final step |

### Conditional Tasks

- **T3b (Frontend):** Skip if `.production-grade.yaml` has `features.frontend: false`
- **T10 (Data Scientist):** Auto-detect by scanning for `openai`, `anthropic`, `langchain`, `transformers`, `torch`, `tensorflow` imports. If not detected and `features.ai_ml: false`, mark as completed immediately.

## Phase Execution

Each phase loads its dispatcher file for task management and agent spawning.

| Phase | File | Tasks | Parallel Points |
|-------|------|-------|----------------|
| DEFINE | `phases/define.md` | T1, T2 | Sequential (gates) |
| BUILD | `phases/build.md` | T3a, T3b, T4 | #1, #2 |
| HARDEN | `phases/harden.md` | T5, T6a, T6b | #3, #4 |
| SHIP | `phases/ship.md` | T7, T8, T9, T10 | #5, #6 |
| SUSTAIN | `phases/sustain.md` | T11, T12, T13 | #7 |

**Read the phase file BEFORE starting that phase. Never load all phase files at once.**

### Agent Dispatch Methods

**Skill Tool** — for sequential, user-interactive tasks (PM interview, gate approvals):
```python
Skill(skill="product-manager")
```

**Agent Tool** — for parallel, background tasks:
```python
Agent(
  prompt="You are the Backend Engineer. Read architecture at...",
  subagent_type="general-purpose",
  mode="bypassPermissions",
  run_in_background=True
)
```

## Conflict Resolution

Follow the shared protocol at `Claude-Production-Grade-Suite/.protocols/conflict-resolution.md`.

| Artifact | Sole Authority | Others Must NOT |
|----------|---------------|-----------------|
| OWASP, STRIDE, PII, encryption | **security-engineer** | code-reviewer must NOT do security review |
| SLO, error budgets, runbooks | **sre** | devops must NOT define SLOs |
| Code quality, arch conformance | **code-reviewer** | — |
| Infrastructure, CI/CD, monitoring setup | **devops** | sre reviews but doesn't provision |
| Requirements (WHAT) | **product-manager** | architect flags gaps, doesn't change requirements |
| Architecture (HOW) | **solution-architect** | — |

### Remediation Feedback Loop

When HARDEN skills find Critical/High issues:
1. Orchestrator creates T8 (Remediation) task with findings
2. Remediation agent fixes code in `services/`, `frontend/`
3. Re-scan affected files after fixes
4. If still failing after **2 cycles** → escalate to user via AskUserQuestion

## Context Bridging

| Task | Reads From | Writes To (Project Root) | Writes To (Workspace) |
|------|-----------|--------------------------|----------------------|
| Polymath | User dialogue, web research | — | `polymath/context/`, `polymath/handoff/` |
| T1: PM | User input, polymath context, web research | — | `product-manager/BRD/` |
| T2: Architect | `product-manager/BRD/` | `api/`, `schemas/`, `docs/architecture/` | `solution-architect/` |
| T3a: Backend | `api/`, `schemas/`, `docs/architecture/` | `services/`, `libs/shared/` | `software-engineer/` |
| T3b: Frontend | `api/`, `product-manager/BRD/` | `frontend/` | `frontend-engineer/` |
| T4: DevOps | `services/`, `docs/architecture/` | Dockerfiles at root | `devops/containers/` |
| T5: QA | `services/`, `frontend/`, `api/` | `tests/` | `qa-engineer/` |
| T6a: Security | All implementation code | — | `security-engineer/` |
| T6b: Review | All implementation + architecture | — | `code-reviewer/` |
| T7: DevOps IaC | Architecture, implementation | `infrastructure/`, `.github/workflows/` | `devops/` |
| T8: Remediation | HARDEN findings | Fixes in `services/`, `frontend/` | — |
| T9: SRE | All prior outputs | `docs/runbooks/` | `sre/` |
| T10: Data Sci | Implementation (LLM usage) | — | `data-scientist/` |
| T11: Tech Writer | ALL workspace + project | `docs/` | `technical-writer/` |
| T12: Skill Maker | ALL workspace | `.claude/skills/` | `skill-maker/` |

**Deliverables** go to project root (respecting `.production-grade.yaml` path overrides). **Workspace artifacts** go to `Claude-Production-Grade-Suite/<skill-name>/`.

## Workspace Architecture

```
Claude-Production-Grade-Suite/
├── .protocols/              # Shared protocols (written at bootstrap)
├── .orchestrator/           # Pipeline state via TaskList
├── product-manager/         # BRD, research
├── solution-architect/      # Architecture artifacts
├── software-engineer/       # Backend logs/artifacts
├── frontend-engineer/       # Frontend logs/artifacts
├── qa-engineer/             # Test artifacts
├── security-engineer/       # Security findings
├── code-reviewer/           # Quality findings
├── devops/                  # Infrastructure artifacts
├── sre/                     # Readiness artifacts
├── data-scientist/          # AI/ML artifacts (conditional)
├── technical-writer/        # Documentation artifacts
└── skill-maker/             # Custom skills
```

## Adaptive Rules

| Situation | Action |
|-----------|--------|
| No frontend needed | Skip T3b, simplify DevOps |
| Monolith architecture | Single Dockerfile, skip K8s/service mesh |
| LLM/ML APIs detected | Auto-enable T10 (Data Scientist) |
| Critical security finding | Create remediation task (T8) |
| QA failures > 20% | Flag to user |
| Architecture drift detected | Warn user (arch decisions are user-approved) |
| `features.frontend: false` | Skip T3b entirely |
| `features.ai_ml: false` | Skip T10 unless auto-detected |

## Security Hooks (Continuous)

Security runs during ALL phases:
- Block `rm -rf /`, `chmod 777`, destructive operations
- Block `.env`, `.key`, `.pem`, `credentials.json` from git
- Scan staged files for API keys, tokens, passwords
- Engineers scan for hardcoded secrets as they write code

## Autonomous Agent Behavior

Every agent follows:
1. **Build and verify** — after writing code, run it. After writing tests, execute them.
2. **Validation loop** — `while not valid: fix(errors); validate()`
3. **Self-debug** — read errors, identify root cause. After 3 failures: stop and report.
4. **Quality bar** — no TODOs, no stubs. All code compiles. All tests pass.
5. **TDD enforced** — write test first, watch fail, implement, watch pass, refactor.

## Partial Execution

| Command | Tasks Run |
|---------|----------|
| `/production-grade just define` | T1, T2 only |
| `/production-grade just build` | T3a, T3b, T4 (requires T2 output) |
| `/production-grade just harden` | T5, T6a, T6b (requires BUILD output) |
| `/production-grade just ship` | T7-T10 (requires HARDEN output) |
| `/production-grade just document` | T11 only |
| `/production-grade skip frontend` | Omit T3b |
| `/production-grade start from architecture` | Skip T1, start at T2 |

## Final Summary Template

```
╔══════════════════════════════════════════════════════════════╗
║          PRODUCTION GRADE v{local_version} — COMPLETE          ║
╠══════════════════════════════════════════════════════════════╣
║  Project: <name>                                             ║
║                                                              ║
║  DEFINE:  ✓ BRD (<X> stories) ✓ Architecture (<pattern>)     ║
║  BUILD:   ✓ Backend (<N> services) ✓ Tests (<N> passing)     ║
║  HARDEN:  ✓ Security (<N> fixed) ✓ Code Review (<N> fixed)   ║
║  SHIP:    ✓ Docker ✓ CI/CD ✓ Terraform ✓ SRE approved       ║
║  SUSTAIN: ✓ Docs ✓ Skills (<N> created) ✓ Learnings captured ║
║                                                              ║
║  Workspace: Claude-Production-Grade-Suite/                   ║
║  Config: .production-grade.yaml                              ║
╚══════════════════════════════════════════════════════════════╝
```

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Running BUILD without DEFINE | Architecture decisions must exist first |
| Code reviewer doing OWASP review | security-engineer is sole OWASP authority |
| DevOps defining SLOs | sre is sole SLO authority |
| DevOps writing runbooks | sre writes runbooks to docs/runbooks/ |
| Skipping tests | Production grade means tested |
| Not running code after writing | Every agent verifies output compiles and runs |
| Agents working in isolation | Cross-reference via Context Bridging table |
| Over-asking the user | 3 gates only — sensible defaults otherwise |
| Writing stubs | No `// TODO: implement` in production code |
| Hardcoded paths | Read `.production-grade.yaml` for path overrides |
| Sequential when parallel possible | Use all 7 parallel points in task graph |
| Duplicating security review | code-reviewer references security-engineer findings |
