# Production Grade Plugin for Claude Code

<p align="center">
  <img src="assets/banner.png" alt="Meet the Production Grade crew — 14 AI agents" width="700">
</p>

<p align="center">
  <a href="https://github.com/nagisanzenin/claude-code-production-grade-plugin"><img src="https://img.shields.io/github/stars/nagisanzenin/claude-code-production-grade-plugin?style=social" alt="GitHub stars"></a>
  <a href="https://discord.gg/3ux2c5xz"><img src="https://img.shields.io/badge/Discord-Join%20Community-5865F2?logo=discord&logoColor=white" alt="Discord"></a>
  <img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="MIT License">
  <img src="https://img.shields.io/badge/version-5.5.2-blue.svg" alt="Version">
  <img src="https://img.shields.io/badge/agents-14-green.svg" alt="14 agents">
  <img src="https://img.shields.io/badge/protocols-9-red.svg" alt="9 protocols">
  <img src="https://img.shields.io/badge/execution%20modes-10-purple.svg" alt="10 modes">
</p>

<h3 align="center">14 AI agents, one install, idea to production.</h3>

```bash
/plugin marketplace add nagisanzenin/claude-code-plugins
/plugin install production-grade@nagisanzenin
```

> **New in v5.5 — The Loop Engine.** Agents stop claiming "done" and start proving it. Every stage now loops against a check it can't argue with — typecheck, tests, or the running app clicking its own buttons — until it converges. [How it works.](#the-loop-engine)

<br>

## Built With This Plugin

**Built something with this plugin? [Open a PR](https://github.com/nagisanzenin/claude-code-production-grade-plugin/pulls) to add your project here.**

| Project | Live | Description |
|---------|------|-------------|
| **PingBase** | [pingbasez.vercel.app](https://pingbasez.vercel.app/) | Free uptime monitoring — get emailed when your website goes down. GitHub OAuth, Stripe billing, Turso DB. |
| **LLM Matrix Arena** | [llm-matrix.vercel.app](https://llm-matrix.vercel.app/) | Browse and compare LLM models across N dimensions. Community-driven voting from real developers — not benchmarks, real opinions. |
| **SkyClaw** | [github.com/nagisanzenin/skyclaw](https://github.com/nagisanzenin/skyclaw) | Cloud-native Rust AI agent runtime. Telegram-native — deploy one binary, paste your API key, and control your server through chat. |

---

## Release Timeline

```
2026-07-02  v5.5.2 ●━━━ Loop-engine robustness — resilient report-artifact writes + orchestrator recovery; deep-smoke requires an adversarial input
                  │
2026-07-02  v5.5.1 ●━━━ Loop-engine hardening — trustworthy BUILD-exit deep-smoke gate, worktree-safe scoped oracle-gate, brownfield toolchain adoption
                  │
2026-07-02  v5.5  ●━━━ The Loop Engine — oracle-driven iteration: edit-gate hook, TDD pair, functional drive replaces hand-testing
                  │
2026-03-07  v5.4  ●━━━ Harmonization — mode-aware autonomy, cross-session enforcement, agent skill loading
                  │
2026-03-07  v5.3  ●━━━ Worktree isolation, self-healing gates, cost dashboard
                  │
2026-03-07  v5.2  ●━━━ Frontend overhaul — functional-first, design polish, 4 visual style presets
                  │
2026-03-07  v5.1  ●━━━ Boundary Safety — 6 patterns for system boundary bugs, from real deployment
                  │
2026-03-06  v5.0  ●━━━ Verified & Resilient — receipt enforcement, re-anchoring, adversarial review
                  │
2026-03-06  v4.4  ●━━━ Freshness protocol — agents WebSearch to verify volatile data before implementing
                  │
2026-03-06  v4.3  ●━━━ Visual identity, pipeline dashboard, gate ceremonies
                  │
2026-03-06  v4.2  ●━━━ Adaptive routing, 10 execution modes, everyday SWE work
                  │
2026-03-05  v4.1  ●━━━ Engagement modes, scale-driven architecture, adaptive interviews
                  │
2026-03-04  v4.0  ●━━━ Two-wave parallelism, internal skill agents, dynamic task generation
                  │
2026-03-04  v3.3  ●━━━ Brownfield-safe — works on existing codebases
                  │
2026-03-03  v3.2  ●━━━ Auto-update, MECE intent routing, protocol crash fix
                  │
2026-03-02  v3.1  ●━━━ Polymath co-pilot — the 14th skill
                  │
2026-03-01  v3.0  ●━━━ Full rewrite — Teams/TaskList, 7 parallel points, shared protocols
                  │
2026-02-28  v2.0  ●━━━ 13 bundled skills, unified workspace, prescriptive UX
                  │
2026-02-24  v1.0  ●━━━ Initial release — autonomous DEFINE>BUILD>HARDEN>SHIP>SUSTAIN
```

---

## The Pipeline

```
  YOU ──→ "Build a SaaS for ..."
           │
           ▼
  ┌─────────────────────────────────────────────────────────────────┐
  │                    DEFINE                                       │
  │  T1  Product Manager ─── BRD, user stories, acceptance criteria│
  │  T2  Solution Architect ─ ADRs, API contracts, data models     │
  │                                                                 │
  │  ┌─────────────┐  ┌──────────────┐                             │
  │  │ GATE 1      │  │ GATE 2       │                             │
  │  │ Requirements│  │ Architecture │                             │
  │  └─────────────┘  └──────────────┘                             │
  └─────────────────────────────────────────────────────────────────┘
           │
           ▼
  ┌─────────────────────────────────────────────────────────────────┐
  │               BUILD + ANALYZE  (Wave A — parallel)             │
  │                                                                 │
  │  Backend ──── N agents (1 per service)    QA ──── test plan    │
  │  Frontend ─── N agents (1 per page)       Security ── STRIDE   │
  │  DevOps ──── Dockerfiles + CI skeleton    Review ── checklist  │
  │                                           SRE ───── SLOs       │
  └─────────────────────────────────────────────────────────────────┘
           │
           ▼
  ┌─────────────────────────────────────────────────────────────────┐
  │               HARDEN  (Wave B — parallel against code)         │
  │                                                                 │
  │  QA ─────── unit / integration / e2e / performance tests       │
  │  Security ── code audit + dependency scan (4 parallel phases)  │
  │  Review ──── arch / quality / performance (adversarial)        │
  │  DevOps ──── build + push containers                           │
  └─────────────────────────────────────────────────────────────────┘
           │
           ▼
  ┌─────────────────────────────────────────────────────────────────┐
  │                          SHIP                                   │
  │                                                                 │
  │  DevOps ── IaC + CI/CD  ┐                                      │
  │  Remediation ───────────┘ parallel    ┌──────────────┐         │
  │  SRE ── chaos + capacity ┐            │ GATE 3       │         │
  │  Data Scientist ─────────┘ parallel   │ Production   │         │
  │                                       │ Readiness    │         │
  │                                       └──────────────┘         │
  └─────────────────────────────────────────────────────────────────┘
           │
           ▼
  ┌─────────────────────────────────────────────────────────────────┐
  │                        SUSTAIN                                  │
  │                                                                 │
  │  Technical Writer ── API ref + dev guides (parallel)           │
  │  Skill Maker ─────── 3-5 project-specific reusable skills     │
  │  Compound Learning ── pipeline insights for next run           │
  └─────────────────────────────────────────────────────────────────┘
           │
           ▼
        DONE ── receipts verified, agents cleaned up
```

> **3 gates. 2 waves. 10+ parallel execution points. ~3x faster than sequential.**
> **Every stage loops against an executable oracle until it converges — [The Loop Engine](#the-loop-engine).**

---

## The Loop Engine

*New in v5.5 — the reason the agents stop lying about "done."*

Software is never one pass. It's write, run, fail, fix, run again, until a check passes. Through v5.4 the pipeline was mostly feed-forward: each agent did its job, handed the artifact down, and correctness leaned on human review at the gates. v5.5 makes iteration the main path, on a single rule:

> **A task is done when a check it cannot argue with says so — not when the agent claims it.**

That check is an *oracle*: a compiler, a type checker, a test suite, or the running app clicking its own buttons. No oracle, no loop.

```
        ┌──────────────┐
        │   PRODUCE    │   agent writes / fixes
        └──────┬───────┘
               ▼
        ┌──────────────┐   red    ┌────────────────┐
        │    ORACLE    │ ───────▶ │  DELTA BACK    │
        │ test·type·app│          │ failing output │
        └──────┬───────┘          │ only → re-loop │
          green │                 └────────┬───────┘
               ▼                           │
        ┌──────────────┐  no progress ×2   │
        │  CONVERGED   │ ◀─────────────────┘
        └──────────────┘  plateau → escalate strategy, not effort
```

What it adds, concretely:

- **Oracle bootstrap.** Before any parallel wave, the pipeline writes two check scripts for your project: a fast one (typecheck + lint, under 15s) and a full one (tests + build + boot smoke).
- **Enforced by a hook, not a prompt.** A `PostToolUse` hook runs the fast oracle after *every* file edit. Break something and the error lands back in the agent's lap immediately, not at the end.
- **Separated duties.** QA writes failing tests first and owns the `tests/` folder. A coding agent that weakens a test to go green gets flagged with a Critical finding. No grading their own homework.
- **Functional drive.** Before the final gate, an agent boots the real app and drives it — every button, every form, every link. A control that renders but does nothing is a Critical bug. This is the hand-testing replacement.
- **Convergence, not retries.** Each loop tracks a number (failing tests, open findings) and stops when it hits zero or stops improving, shows the trend, then escalates. No retrying the same fix five times.

Fully backward compatible: a pipeline that never needs to loop runs exactly as before. Full design rationale in [docs/LOOPS.md](docs/LOOPS.md).

---

## 10 Execution Modes

Not just full builds. The orchestrator reads your request and routes automatically.

```
┌──────────────────────────────────────────────────────────────┐
│                                                              │
│   Full Build ████████████████████████  all 14 agents         │
│   Feature    █████████████            PM+Arch+Eng+QA        │
│   Harden     ████████                 Sec+QA+Review         │
│   Ship       ██████                   DevOps+SRE+DS         │
│   Architect  ████                     Solution Architect     │
│   Test       ███                      QA Engineer            │
│   Review     ███                      Code Reviewer          │
│   Document   ███                      Technical Writer       │
│   Optimize   █████                    SWE+Data Scientist     │
│   Explore    ███                      Polymath               │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

```
"Build a SaaS for e-commerce"           → Full Build
"Add Stripe billing to my API"          → Feature
"Audit this codebase before launch"     → Harden
"Set up CI/CD and monitoring"           → Ship
"Review this PR for quality"            → Review
"Help me think about a fintech app"     → Explore
```

---

## The Crew

```
                    ┌─────────────────┐
                    │  ORCHESTRATOR   │
                    │  routes, gates, │
                    │  receipts       │
                    └────────┬────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                     │
   ┌────▼─────┐     ┌───────▼────────┐    ┌──────▼───────┐
   │  DEFINE  │     │     BUILD      │    │   HARDEN     │
   │          │     │                │    │              │
   │ PM       │     │ Software Eng   │    │ QA Engineer  │
   │ Architect│     │ Frontend Eng   │    │ Security Eng │
   │          │     │ DevOps         │    │ Code Review  │
   └──────────┘     └────────────────┘    └──────────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                     │
   ┌────▼─────┐     ┌───────▼────────┐    ┌──────▼───────┐
   │   SHIP   │     │    SUSTAIN     │    │   ANYTIME    │
   │          │     │                │    │              │
   │ DevOps   │     │ Tech Writer    │    │ Polymath     │
   │ SRE      │     │ Skill Maker    │    │ Data Sci     │
   └──────────┘     └────────────────┘    └──────────────┘
```

| # | Agent | Domain | Sole Authority |
|---|-------|--------|:-:|
| 1 | **Orchestrator** | Routes, gates, receipts, re-anchoring | |
| 2 | **Polymath** | Research, ideation, onboarding, translation | |
| 3 | **Product Manager** | BRD, user stories, acceptance criteria | Requirements |
| 4 | **Solution Architect** | ADRs, tech stack, API contracts, data models | Architecture |
| 5 | **Software Engineer** | Handlers, services, repositories, business logic | |
| 6 | **Frontend Engineer** | Design system, components, pages, accessibility | |
| 7 | **QA Engineer** | Unit, integration, e2e, performance tests | |
| 8 | **Security Engineer** | STRIDE, OWASP, PII, dependency scanning | Security |
| 9 | **Code Reviewer** | Architecture conformance, anti-patterns (adversarial) | Code Quality |
| 10 | **DevOps** | Docker, Terraform, CI/CD, containers | Infrastructure |
| 11 | **SRE** | SLOs, chaos engineering, runbooks, capacity | Reliability |
| 12 | **Data Scientist** | LLM optimization, prompt engineering, cost modeling | |
| 13 | **Technical Writer** | API reference, dev guides, architecture docs | |
| 14 | **Skill Maker** | Generates project-specific reusable Claude Code skills | |

---

## What Makes It Different

```
  ┌──────────────────────────────────────────────────────────────┐
  │                                                              │
  │  ORACLE-DRIVEN LOOPS          FUNCTIONAL DRIVE               │
  │  ──────────────────           ────────────────               │
  │  No oracle, no loop. A loop   A separate agent boots the     │
  │  exits on an executable       running app and drives it:     │
  │  check: tests, typecheck,     every button, every form,      │
  │  the running app. Never on    every link. A dead element     │
  │  "looks done." Converge or    is a Critical bug — this is    │
  │  escalate, never blind-retry. the hand-testing killer.       │
  │                                                              │
  │  RECEIPT ENFORCEMENT          RE-ANCHORING                   │
  │  ─────────────────            ────────────                   │
  │  Every agent writes a         Orchestrator re-reads specs    │
  │  JSON receipt as proof.       FROM DISK at every phase       │
  │  No receipt = not done.       transition. No context drift   │
  │  Gate won't open without      in multi-hour runs.            │
  │  verified artifacts.                                         │
  │                                                              │
  │  ADVERSARIAL REVIEW           FRESHNESS PROTOCOL             │
  │  ──────────────────           ──────────────────             │
  │  Code reviewer assumes        Agents detect volatile data    │
  │  code is WRONG until          (model IDs, pricing, CVEs)     │
  │  proven right. Scales         and WebSearch to verify        │
  │  from critical-only to        BEFORE implementing.           │
  │  hostile break scenarios.                                    │
  │                                                              │
  │  CONSTRAINT-DRIVEN ARCH       ZERO OPEN-ENDED QUESTIONS      │
  │  ─────────────────────        ─────────────────────────      │
  │  Architecture derived from    Every interaction is arrow     │
  │  YOUR scale, budget, team,    keys + Enter. Polymath         │
  │  compliance — not templates.  translates at every gate.      │
  │  100 users → monolith.                                       │
  │  10M users → microservices.                                  │
  │                                                              │
  │  MODE-AWARE AUTONOMY          CROSS-SESSION PERSISTENCE      │
  │  ───────────────────          ─────────────────────────      │
  │  Express: zero questions,     SessionStart hook detects      │
  │  auto-resolve everything.     production-grade projects.     │
  │  Meticulous: every decision   New sessions get a courteous   │
  │  surfaced. Agent questions    prompt: use plugin, work       │
  │  scale independently of       directly, or chat about it.    │
  │  pipeline gates.              Your workflow persists.        │
  │                                                              │
  └──────────────────────────────────────────────────────────────┘
```

---

## Protocol Stack

All 14 agents load the same 9 protocols at startup:

```
  ┌──────────────────────────────────────────────┐
  │          Loop Protocol                        │  ← oracle-driven iteration
  ├──────────────────────────────────────────────┤
  │          Boundary Safety                      │  ← system boundary patterns
  ├──────────────────────────────────────────────┤
  │          Receipt Protocol                     │  ← proof of completion
  ├──────────────────────────────────────────────┤
  │          Freshness Protocol                   │  ← verify volatile data
  ├──────────────────────────────────────────────┤
  │          Visual Identity                      │  ← consistent formatting
  ├──────────────────────────────────────────────┤
  │          Conflict Resolution                  │  ← sole-authority domains
  ├──────────────────────────────────────────────┤
  │          Tool Efficiency                      │  ← dedicated tools > shell
  ├──────────────────────────────────────────────┤
  │          Input Validation                     │  ← classify external inputs
  ├──────────────────────────────────────────────┤
  │          UX Protocol                          │  ← structured interactions
  └──────────────────────────────────────────────┘
```

---

## Engagement Modes

Choose your depth at pipeline start. Propagates to all 14 agents.

```
  Express     ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  zero agent questions, auto-resolve all
  Standard    ████░░░░░░░░░░░░░░░░░░░░░░░░░░  1-2 per skill, subjective/irreversible only
  Thorough    █████████████░░░░░░░░░░░░░░░░░░  all major decisions surfaced
  Meticulous  ██████████████████████████████░░  every decision point, full user control
```

> **3 pipeline gates (BRD, Architecture, Production Readiness) always fire regardless of mode.**
> Agent questions are separate — they scale from zero (Express) to exhaustive (Meticulous).

---

## Token-Efficient Architecture

Large skills split into **router + on-demand phases**. Only what's needed loads. Independent phases run as parallel agents with minimal context.

```
  Polymath ─────────── 6 modes    onboard | research | ideate | advise | translate | synthesize
  Software Engineer ── 5 phases   context | implement | cross-cutting | integration | local dev
  Frontend Engineer ── 6 phases   analysis | functional foundation | components | pages | design polish | testing
  Security Engineer ── 6 phases   threat model | code audit | auth | data | supply chain | remediation
  SRE ─────────────── 5 phases   readiness | SLOs | chaos | incidents | capacity
  Data Scientist ──── 6 phases   audit | LLM optimization | experiments | pipeline | ML infra | cost
  Technical Writer ── 4 phases   audit | API reference | dev guides | Docusaurus
```

---

## By the Numbers

```
  ┌─────────────────────────────────────────────────────┐
  │                                                     │
  │   14  specialized agents                            │
  │    9  shared protocols                              │
  │    2  oracle scripts generated per project          │
  │    1  fast oracle check after every single edit     │
  │   10  execution modes                               │
  │   10+ parallel execution points                     │
  │    3  approval gates                                │
  │    4  engagement modes                              │
  │   ~3x faster than sequential execution              │
  │  ~45% fewer input tokens from parallelism           │
  │    0  open-ended questions — all structured         │
  │   11  governing principles                          │
  │    5  languages: TS, Go, Python, Rust, Java/Kotlin  │
  │                                                     │
  └─────────────────────────────────────────────────────┘
```

---

## Installation

```bash
# Marketplace (recommended)
/plugin marketplace add nagisanzenin/claude-code-plugins
/plugin install production-grade@nagisanzenin

# Or from source
git clone https://github.com/nagisanzenin/claude-code-production-grade-plugin.git
claude --plugin-dir /path/to/claude-code-production-grade-plugin
```

**Requirements:** Claude Code (with plugin support), Docker & Docker Compose, Git.

Works on existing codebases — brownfield detection auto-maps your project structure.

---

## FAQ

**Does it write working code?** Yes. Write, build, test, debug, fix. No stubs. No TODOs.

**Existing projects?** Yes. Brownfield detection auto-maps. Run specific modes or full pipeline.

**How do I know it ran everything?** Receipts. JSON proof from every agent, verified at gates.

**Context degrade in long runs?** No. Re-anchoring re-reads from disk at every phase transition.

**Not technical?** Every interaction is multiple choice. Polymath translates at any gate.

---

## Contributing

1. Fork the repo
2. Create a branch: `git checkout -b feature/your-feature`
3. Commit changes
4. Open a Pull Request

**Adding a skill:** Create `skills/your-skill-name/SKILL.md` with `---` frontmatter.

---

## Community

Join the Discord to share what you've built, discuss workflows, report bugs, and request features.

<a href="https://discord.gg/3ux2c5xz"><img src="https://img.shields.io/badge/Discord-Join%20Community-5865F2?style=for-the-badge&logo=discord&logoColor=white" alt="Join Discord"></a>

---

## Star History

<a href="https://star-history.com/#nagisanzenin/claude-code-production-grade-plugin&Date">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=nagisanzenin/claude-code-production-grade-plugin&type=Date&theme=dark" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=nagisanzenin/claude-code-production-grade-plugin&type=Date" />
   <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=nagisanzenin/claude-code-production-grade-plugin&type=Date" />
 </picture>
</a>

---

## License

## More from the same workshop

- **[engram](https://github.com/nagisanzenin/engram)** — an evidence-based learning engine: first-principles curricula, generation-first tutoring, blind-graded free recall, FSRS scheduling. The receipt-and-assessor discipline in this plugin started there.
- **[effortmining](https://github.com/nagisanzenin/effortmining)** — benchmark-calibrated reasoning-effort dispatch for Claude Code subagents (64.7% fewer output tokens at equal quality, pre-registered). Built *with* this pipeline — its repo carries the receipts.

MIT

---

<p align="center">
  <strong>14 agents. 9 protocols. 10 modes. One install.</strong>
</p>
