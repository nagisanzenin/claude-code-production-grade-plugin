# Changelog

All notable changes to the Production Grade Plugin.

## [4.3.0] — 2026-03-06

### Added
- **Visual identity protocol** — new shared protocol (`visual-identity.md`) defining the complete design language: sleek, elegant, high-tech aesthetic. Container hierarchy (Tier 1 double-line for key moments, Tier 2 single-line for data grids, Tier 3 heavy rules for section headers). Standardized icon vocabulary (`◆ ⬥ ● ○ ✓ ✗ ⧖ ⚠ →`). No emoji — Unicode symbols only for monospace alignment.
- **Pipeline dashboard** — `╔═══╗` status board printed at kickoff and every phase transition. Shows all 5 phases with status (`○ pending` → `● active` → `✓ complete`), elapsed time per phase, and total elapsed time. The dashboard re-rendering IS the progress animation.
- **Gate ceremonies** — visual framing before each approval gate. Prints concrete metrics block (key-value pairs with numbers) between `━━━` rules with `⬥ GATE N` header and elapsed time. Gives decision moments visual weight and authority.
- **Wave announcements** — Tier 2 boxes showing all agents in a parallel wave on launch, then checkmark cascade with concrete metrics on completion. Peak visual moment: rapid `✓` lines with per-agent results.
- **Transition announcements** — `→` prefixed lines between phases and waves explaining what's next. Eliminates "what's happening?" anxiety.
- **Numbered phase progress** — every skill prints `[1/N]` phase progress with `✓`/`⧖`/`○` step indicators and concrete counts. Users always know where each skill is in its work.
- **Concrete completion summaries** — every agent completion line MUST include numbers. `✓ Security Engineer    12 findings (2 Critical, 3 High, 7 Medium)` not `✓ Security Engineer — complete`.
- **Before→after deltas** — `12 findings → 0 Critical remaining`, `0% → 94% coverage`. Proves transformation happened.
- **Findings severity grid** — structured display with Critical/High detail, Medium/Low counts, dedup total.
- **Elapsed timing** — tracked at 3 levels: total pipeline, per-phase, per-wave. Not per-step (too granular).
- **Streaming as animation** — documented that Claude's token-by-token streaming IS our animation channel. Visual blocks designed for progressive reveal consumption.

### Changed
- **UX Protocol Rule 5** updated to reference visual identity protocol with concrete formatting requirements.
- **Orchestrator kickoff** replaced bare `━━━` banner with full pipeline dashboard.
- **All 3 gate templates** upgraded with ceremony framing (metrics block + `⬥` header).
- **Final summary** expanded from compact box to detailed per-phase breakdown with bottom-line stats (agents used, tasks completed, files created, tests passing, vulnerabilities remaining).
- **All 5 phase dispatchers** updated with visual output sections: phase banners, wave start/completion templates, transition announcements.
- **All 13 sub-skills** updated with visual-identity protocol loading, numbered phase progress patterns, and structured completion summaries.
- **Upgraded findings summary** in HARDEN phase from simple `✓` list to severity grid with critical finding details.

## [4.2.0] — 2026-03-06

### Added
- **Adaptive routing** — orchestrator now analyzes the user's request and routes to the right skills automatically. No longer requires full pipeline for every task.
- **10 execution modes**: Full Build, Feature, Harden, Ship, Test, Review, Architect, Document, Explore, Optimize, Custom. Each with appropriate skill composition, gates, and parallelism.
- **Request classification** — automatic intent detection maps user requests to modes. "Add auth to my API" → Feature mode (PM + Architect + Backend + QA). "Review my code" → Review mode (Code Reviewer only).
- **Execution plan presentation** — user sees which skills will run and can adjust, escalate to full pipeline, or proceed.
- **Custom mode** — multi-select skill menu for requests that don't fit standard patterns.
- **Lightweight mode execution** — non-Full-Build modes skip unnecessary overhead (engagement/parallelism prompts only for 3+ skill modes).

### Changed
- Plugin description broadened from "build a complete production-ready system" to "any software engineering work that benefits from structured, production-quality execution."
- "When to Use" expanded to cover: adding features, hardening, deploying, testing, reviewing, documenting, optimizing, exploring — not just greenfield builds.
- Full Build pipeline preserved unchanged as one mode within the adaptive orchestrator.

## [4.1.0] — 2026-03-05

### Added
- **Engagement modes** — 4-level interaction depth (Express, Standard, Thorough, Meticulous) chosen at pipeline start. Controls PM interview depth, architect discovery depth, and phase summary visibility. Persisted in `Claude-Production-Grade-Suite/.orchestrator/settings.md`.
- **Architecture Fitness Function** — Solution Architect now DERIVES architecture from constraints instead of picking templates. Scale, team size, budget, compliance, data patterns, geographic distribution, growth model, and uptime SLA all feed into architecture decisions. A 100-user internal tool gets a monolith; a 10M-user platform gets microservices.
- **Scale & Fitness Interview** — Adaptive 1-4 round interview (depth scales with engagement mode). Covers: users, CCU, data patterns, team size, budget, compliance, latency, uptime SLA, geographic distribution, growth model, vendor strategy, extensibility.
- **Adaptive PM interview** — Express: 2-3 questions. Standard: 3-5. Thorough: 5-8 with competitive analysis. Meticulous: 8-12 across multiple rounds with co-authored acceptance criteria.

### Changed
- **Engagement mode propagated to ALL 14 skills** — every agent reads `settings.md` and adapts decision surfacing. Express: fully autonomous. Standard: surface 1-2 critical decisions. Thorough: surface all major decisions. Meticulous: surface every decision point.
- Solution Architect Phase 1 rewritten from 5 shallow questions to a comprehensive adaptive discovery process with structured AskUserQuestion options at every step.
- Product Manager Phase 1 rewritten with 4 interview depth profiles matching engagement modes.
- Pipeline kickoff now asks engagement mode before parallelism preference (step 5, renumbered to 11 total steps).
- **Software Engineer parallelism revised** — shared foundations (libs/shared: types, errors, middleware, auth, logging, config) established SEQUENTIALLY before parallel service agents. Each service agent reads shared foundations. Prevents N different error handling/auth implementations.
- **Frontend Engineer parallelism revised** — UI Primitives built SEQUENTIALLY first (foundational atoms), then Layout + Feature components in PARALLEL (both import from primitives). Prevents duplicate Button/Input implementations.
- Orchestrator internal skill parallelism table updated to reflect foundations-first pattern.

## [4.0.0] — 2026-03-05

### Changed
- **Two-wave parallel execution** — orchestrator splits work into Wave A (build + analysis in parallel) and Wave B (execution against code in parallel). Analysis tasks (QA test plan, STRIDE threat model, SLO definitions, arch conformance checklist) start alongside build instead of waiting for code. Up to 7+ concurrent agents in Wave A, 4+ in Wave B.
- **Internal skill parallelism** — 8 skills now spawn parallel Agents for independent work units: software-engineer (1 agent per service), frontend-engineer (1 agent per page group), qa-engineer (unit/integration/e2e/performance in parallel), security-engineer (code audit/auth/data/supply chain in parallel), code-reviewer (arch/quality/performance in parallel), devops (IaC/CI-CD/containers in parallel), sre (chaos/incidents/capacity in parallel), technical-writer (API ref/dev guides in parallel).
- **Dynamic task generation** — orchestrator reads architecture output (number of services, pages, modules) and creates tasks accordingly. No hardcoded task count.

### Added
- **Parallelism preference** — user selects performance mode at pipeline start: Maximum (recommended), Standard, or Sequential. No config file needed.
- **Token economics** — parallel execution is both faster AND cheaper. Each agent carries minimal context instead of accumulating prior work. ~45% fewer total input tokens for 3+ services.

## [3.3.0] — 2026-03-05

### Added
- **Brownfield awareness** — orchestrator detects greenfield vs existing codebase at startup. Scans for source files, frameworks, and infrastructure. Generates `.production-grade.yaml` from discovered structure. Writes `codebase-context.md` with safety rules for all agents.
- **Codebase discovery** — parallel scan of project root for package.json, go.mod, pyproject.toml, existing src/, services/, frontend/, tests/, Dockerfiles, CI configs.
- All 8 BUILD/SHIP skills (software-engineer, frontend-engineer, devops, qa-engineer, solution-architect, sre, technical-writer, and orchestrator) now load brownfield context and follow "never overwrite, extend don't replace" rules.

### Changed
- **MECE intent-based skill routing** — all 14 skill descriptions rewritten from keyword triggers to intent descriptions. Each skill has a unique precondition and domain. No overlap.

### Fixed
- **Protocol loading crash** — all 13 sub-skills crashed on load when protocol files didn't exist. Added `|| true` fallback.
- **Polymath priority** — uncertainty expressions now correctly route to polymath before product-manager.

## [3.2.0] — 2026-03-05

### Added
- **Auto-update with consent** — orchestrator checks for new versions on pipeline start, prompts user only when update is available. Silent if current, graceful fallback if offline.
- Dynamic version display in pipeline banner and completion summary.

### Fixed
- **Protocol loading crash** — all 13 sub-skills crashed on load when protocol files didn't exist yet. Added `|| true` fallback to all `cat` commands.
- **MECE intent-based skill routing** — replaced keyword trigger matching with intent descriptions across all 14 skills. Each skill now describes user state and domain, not trigger phrases. Polymath correctly activates on uncertainty signals instead of losing to keyword matches.
- **Polymath priority** — uncertainty expressions ("don't know where to start", "not sure how") now correctly route to polymath before product-manager or production-grade.

## [3.1.0] — 2026-03-05

### Added
- **Polymath co-pilot** — the 14th skill. Thinks with you before, during, and after the pipeline.
- 6 Polymath modes: onboard, research, ideate, advise, translate, synthesize.
- Pre-flight gap detection — orchestrator detects knowledge gaps and invokes Polymath before proceeding.
- Gate companion — "Chat about this" at any approval gate routes to Polymath for plain-language explanation.
- Product Manager integration — PM reads Polymath context package to shorten CEO interview.

### Changed
- README rewritten as concise marketing material with GitHub badges, Star History, and Quick Start near top.

## [3.0.0] — 2026-03-04

### Changed
- **Full rewrite** — Teams/TaskList orchestration replaces custom state management.
- 7 parallel execution points across the pipeline.
- 4 shared protocols: UX, input validation, tool efficiency, conflict resolution.
- Large skills split into router + on-demand phases for 65% token savings.
- Sole-authority conflict resolution: security-engineer owns OWASP, SRE owns SLOs.

### Added
- Phase-based skill splitting: software-engineer (5), frontend-engineer (5), security-engineer (6), SRE (5), data-scientist (6), technical-writer (4).
- Conditional task execution: frontend auto-skip, data-scientist auto-detect.
- Partial execution: "just define", "just build", "just harden", "just ship", "just document".

## [2.0.0] — 2026-03-04

### Changed
- **Bundle all 13 skills** into a single plugin install.
- Unified workspace architecture: deliverables at project root, workspace artifacts in `Claude-Production-Grade-Suite/`.
- Prescriptive UX Protocol enforced across all skills: AskUserQuestion with options only, never open-ended.

### Added
- Skill Maker as pipeline phase for generating project-specific custom skills.
- VISION.md: ten principles governing the ecosystem.

## [1.0.0] — 2026-03-03

### Added
- Initial release: production-grade orchestrator plugin.
- 12 specialized agent skills coordinated through dependency graph.
- 3 approval gates, autonomous execution between gates.
- DEFINE > BUILD > HARDEN > SHIP > SUSTAIN pipeline.
