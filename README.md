# Production Grade Plugin for Claude Code

<p align="center">
  <img src="assets/banner.png" alt="Meet the Production Grade crew — 14 AI agents" width="700">
</p>

[![GitHub stars](https://img.shields.io/github/stars/nagisanzenin/claude-code-production-grade-plugin?style=social)](https://github.com/nagisanzenin/claude-code-production-grade-plugin)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-5.0.0-blue.svg)]()
[![Skills](https://img.shields.io/badge/skills-14-green.svg)]()
[![Protocols](https://img.shields.io/badge/protocols-7-red.svg)]()
[![Modes](https://img.shields.io/badge/execution%20modes-10-purple.svg)]()

**14 AI agents, one install, idea to production.**

```bash
/plugin marketplace add nagisanzenin/claude-code-plugins
/plugin install production-grade@nagisanzenin
```

---

## What It Does

You describe what you want. 14 specialized agents handle requirements, architecture, backend, frontend, testing, security audit, code review, infrastructure, CI/CD, SRE, documentation, and custom skills — coordinated through a parallel pipeline with 3 approval gates.

Not just greenfield builds. Add a feature, harden before launch, review code, set up CI/CD, write tests, design architecture, optimize performance, or explore an idea with a thinking partner.

**10 execution modes** — the orchestrator reads your request and routes to the right skills automatically:

| Mode | What Runs | Example |
|------|-----------|---------|
| **Full Build** | All 14 agents, 5 phases, 3 gates | *"Build a SaaS for multi-vendor e-commerce"* |
| **Feature** | PM + Architect + Engineers + QA | *"Add Stripe billing to my API"* |
| **Harden** | Security + QA + Code Review | *"Audit this codebase before launch"* |
| **Ship** | DevOps + SRE + Data Scientist | *"Set up CI/CD and monitoring"* |
| **Test** | QA Engineer | *"Write integration tests for the auth module"* |
| **Review** | Code Reviewer | *"Review this PR for quality"* |
| **Architect** | Solution Architect | *"Design the system for a booking platform"* |
| **Document** | Technical Writer | *"Generate API docs and dev guides"* |
| **Explore** | Polymath | *"Help me think about building a fintech app"* |
| **Optimize** | Software Engineer + Data Scientist | *"Reduce our API latency"* |

---

## Why This Plugin

### 1. Verified execution — receipts prove every gate ran

Every agent writes a JSON receipt as proof of completion. Receipts list artifacts produced, concrete metrics, and verification summary. The orchestrator verifies receipts and artifact existence at every phase transition and before every gate. No receipt = task not complete.

For Critical/High security findings, a **remediation chain** requires three receipts: finding receipt, fix receipt, and verification receipt from the original finder confirming the fix. All three must exist before Gate 3 opens.

### 2. Accurate across long runs — re-anchoring protocol

Claude Code compresses context automatically in long conversations. Over a multi-hour pipeline run, agents can drift from the original specs. The re-anchoring protocol forces the orchestrator to **re-read key workspace artifacts from disk** at every phase transition (DEFINE to BUILD, BUILD to HARDEN, HARDEN to SHIP, SHIP to SUSTAIN). Agents work from what's on disk, not degraded memory.

### 3. Adversarial code review — finds bugs the author can't see

The code reviewer operates as an **adversarial challenger**, not a neutral observer. Assumes code is wrong until proven right. Scaled with engagement mode:

| Mode | Stance |
|------|--------|
| Express | Critical-only bug hunt |
| Standard | Critical + High severity |
| Thorough | All severities with edge case analysis |
| Meticulous | Hostile review with reproducible break scenarios |

Each review phase (architecture conformance, code quality, performance, test quality) has explicit adversarial framing directing the reviewer to assume violations exist.

### 4. Always-current data — freshness protocol

LLMs produce stale information: wrong model IDs, deprecated APIs, outdated pricing. The freshness protocol gives all 14 agents **temporal sensitivity to volatile data**. Before implementing, agents classify data volatility and WebSearch to verify:

| Tier | Volatility | Action | Examples |
|------|-----------|--------|----------|
| Critical | Days-weeks | MUST search | LLM model IDs, API pricing, CVEs |
| High | Weeks-months | Search when writing config | Package versions, Docker tags |
| Medium | Months-quarters | Search if uncertain | Browser APIs, crypto practices |
| Stable | Years+ | Trust training data | Language fundamentals, protocols |

### 5. Architecture from constraints, not templates

The Solution Architect derives architecture from your actual constraints — scale, team size, budget, compliance, data patterns, geographic distribution, growth model, uptime SLA. A 100-user internal tool gets a monolith. A 10M-user global platform gets microservices with multi-region deployment.

### 6. Non-technical users can drive the entire pipeline

Every interaction is multiple choice (arrow keys + Enter). At approval gates, "Chat about this" invokes the Polymath to explain decisions in plain language. You don't need to understand "modular monolith with row-level multi-tenancy" — the Polymath translates it.

---

## The Crew

14 specialized agents. Each owns its domain exclusively — no overlap, no contradiction.

| # | Agent | Domain |
|---|-------|--------|
| 1 | **Orchestrator** | Routes requests, manages pipeline, enforces gates, verifies receipts |
| 2 | **Polymath** | Thinking partner — research, ideation, onboarding, advice, translation |
| 3 | **Product Manager** | Requirements — BRD, user stories, acceptance criteria, prioritization |
| 4 | **Solution Architect** | System design — ADRs, tech stack, API contracts, data models, scaffold |
| 5 | **Software Engineer** | Backend — handlers, services, repositories, business logic |
| 6 | **Frontend Engineer** | Web UI — design system, components, pages, API clients, accessibility |
| 7 | **QA Engineer** | Testing — unit, integration, e2e, performance, contract tests |
| 8 | **Security Engineer** | Security (sole authority) — STRIDE, OWASP, PII, dependency scanning |
| 9 | **Code Reviewer** | Quality (adversarial) — architecture conformance, anti-patterns, performance |
| 10 | **DevOps** | Infrastructure — Docker, Terraform, CI/CD, monitoring, containers |
| 11 | **SRE** | Reliability (sole authority) — SLOs, chaos engineering, runbooks, capacity |
| 12 | **Data Scientist** | AI/ML — LLM optimization, prompt engineering, cost modeling, experiments |
| 13 | **Technical Writer** | Documentation — API reference, dev guides, architecture overviews |
| 14 | **Skill Maker** | Automation — generates 3-5 project-specific reusable Claude Code skills |

### Sole Authority Domains

| Domain | Owner | Others Must Not |
|--------|-------|-----------------|
| OWASP, STRIDE, PII | Security Engineer | Code Reviewer skips security |
| SLOs, error budgets, runbooks | SRE | DevOps skips SLO definitions |
| Code quality, arch conformance | Code Reviewer | Read-only analysis, never modifies code |
| Requirements | Product Manager | Architect flags gaps, doesn't change requirements |
| Architecture | Solution Architect | Implementation follows, doesn't redesign |

---

## Technology

### Pipeline Architecture

```
DEFINE ──→ BUILD ──→ HARDEN ──→ SHIP ──→ SUSTAIN
  │          │         │          │         │
  re-anchor  re-anchor re-anchor  re-anchor re-anchor
  ↓          ↓         ↓          ↓         ↓
  receipts   receipts  receipts   receipts  receipts
```

**Two-wave parallel execution.** Wave A runs build + analysis simultaneously (up to 7+ concurrent agents). Wave B executes against the written code (4+ agents). Analysis tasks like test planning, threat modeling, and SLO definitions start alongside build instead of waiting for code.

**Internal skill parallelism.** 8 skills spawn parallel sub-agents for independent work units: software-engineer (1 agent per service), frontend-engineer (1 agent per page group), qa-engineer (unit/integration/e2e/performance), security-engineer (code/auth/data/supply-chain), code-reviewer (arch/quality/performance), devops (IaC/CI-CD/containers), sre (chaos/incidents/capacity), technical-writer (API ref/dev guides).

**Dynamic task generation.** The orchestrator reads architecture output (number of services, pages, modules) and creates tasks accordingly. No hardcoded task count.

### 7 Shared Protocols

Every agent loads the same protocol stack at startup:

| Protocol | Purpose |
|----------|---------|
| **UX Protocol** | All user interactions are structured — arrow keys + Enter, never open-ended |
| **Input Validation** | Classify and validate all external inputs |
| **Tool Efficiency** | Use dedicated tools over shell commands |
| **Conflict Resolution** | Sole-authority domains, severity-based dedup |
| **Visual Identity** | Consistent output formatting — Unicode symbols, container hierarchy, no emoji |
| **Freshness Protocol** | Detect volatile data, WebSearch before implementing |
| **Receipt Protocol** | Write JSON receipts as proof of completion, verified at gates |

### Token-Efficient Design

Large skills use a **router + on-demand phase** pattern. Only the relevant phase loads. Independent phases run as parallel agents, each carrying minimal context.

| Skill | Phases |
|-------|--------|
| Polymath | 6 modes: onboard, research, ideate, advise, translate, synthesize |
| Software Engineer | 5: context, implementation, cross-cutting, integration, local dev |
| Frontend Engineer | 5: analysis, design system, components, pages, testing/a11y |
| Security Engineer | 6: threat model, code audit, auth, data, supply chain, remediation |
| SRE | 5: readiness, SLOs, chaos, incidents, capacity |
| Data Scientist | 6: audit, LLM optimization, experiments, pipeline, ML infra, cost |
| Technical Writer | 4: audit, API reference, dev guides, Docusaurus |

### 4 Engagement Modes

Choose your interaction depth at pipeline start:

| Mode | Depth | For |
|------|-------|-----|
| **Express** | Minimal interaction, auto-derive everything | Quick tasks, experienced users |
| **Standard** | Balanced — surface 1-2 critical decisions | Most users |
| **Thorough** | Deep discovery, trade-off analysis | Complex systems, senior engineers |
| **Meticulous** | Approve each decision individually | Regulated industries, learning |

Engagement mode propagates to all 14 agents. Express PM asks 2-3 questions. Meticulous PM runs 8-12 across multiple rounds with co-authored acceptance criteria.

---

## By the Numbers

| Metric | Value |
|--------|-------|
| Specialized agents | 14 |
| Shared protocols | 7 |
| Execution modes | 10 |
| Parallel execution points | 10+ |
| Approval gates | 3 |
| Engagement modes | 4 |
| Execution speed vs sequential | ~3x faster |
| Token savings from parallelism | ~45% fewer input tokens |
| Supported languages | TypeScript, Go, Python, Rust, Java/Kotlin |
| Open-ended questions asked | 0 — every interaction is structured |

---

## Installation

```bash
# Marketplace (recommended)
/plugin marketplace add nagisanzenin/claude-code-plugins
/plugin install production-grade@nagisanzenin

# Or load directly from source
git clone https://github.com/nagisanzenin/claude-code-production-grade-plugin.git
claude --plugin-dir /path/to/claude-code-production-grade-plugin
```

**Requirements:** Claude Code (with plugin support), Docker & Docker Compose, Git.

### Brownfield Support

Works on existing codebases. The orchestrator scans for source files, frameworks, and infrastructure at startup. Creates `.production-grade.yaml` from discovered structure and `codebase-context.md` with safety rules for all agents. No overwriting — extend, don't replace.

---

## FAQ

**Does it write working code?**
Yes. Every agent: write, build, test, debug, fix. No stubs. No TODOs.

**Can I use it on existing projects?**
Yes. Brownfield detection auto-maps your project. Run specific modes or the full pipeline.

**How do I know the pipeline actually ran everything?**
Receipts. Every agent writes a JSON receipt with artifacts and metrics. The orchestrator verifies them at gates.

**Does context degrade in long pipeline runs?**
Not anymore. Re-anchoring re-reads workspace artifacts from disk at every phase transition.

**What if I'm not technical?**
Every interaction is multiple choice. Polymath translates technical decisions to plain language at any gate.

---

## Release Timeline

```
2026-03-06  v5.0  --- Verified & Resilient: receipts, re-anchoring, adversarial review
2026-03-06  v4.4  --- Freshness protocol: agents verify volatile data before implementing
2026-03-06  v4.3  --- Visual identity, pipeline dashboard, gate ceremonies
2026-03-06  v4.2  --- Adaptive routing, 10 execution modes
2026-03-05  v4.1  --- Engagement modes, scale-driven architecture
2026-03-04  v4.0  --- Two-wave parallelism, internal skill agents
2026-03-04  v3.3  --- Brownfield-safe: works on existing codebases
2026-03-03  v3.2  --- Auto-update, MECE intent routing
2026-03-02  v3.1  --- Polymath co-pilot (14th skill)
2026-03-01  v3.0  --- Full rewrite: Teams/TaskList, shared protocols
2026-02-28  v2.0  --- 13 bundled skills, unified workspace
2026-02-24  v1.0  --- Initial release: DEFINE > BUILD > HARDEN > SHIP > SUSTAIN
```

---

## Contributing

1. Fork the repo
2. Create a branch: `git checkout -b feature/your-feature`
3. Commit changes
4. Open a Pull Request

**Adding a skill:** Create `skills/your-skill-name/SKILL.md` with `---` frontmatter. For large skills, use the router + phases pattern.

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

MIT

---

<p align="center">
  <strong>14 AI agents. 7 protocols. 10 execution modes. One install.</strong>
</p>
