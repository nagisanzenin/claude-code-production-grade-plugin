# Changelog

All notable changes to the Production Grade Plugin.

## [5.4.1] — 2026-07-02

### Added
- **`docs/PUBLISHING.md`** — two-repo publish + release runbook (this plugin repo + the `nagisanzenin/claude-code-plugins` marketplace): version-resolution/update-gating rules, step-by-step release procedure, local validation/testing, consume flow, and known version drift. (#4)

### Fixed
- **Non-existent tool references** — replaced `smart_outline`/`smart_search`/`smart_unfold` (not in Claude Code's tool catalog) with `Glob`/`Grep`/`Read` across the tool-efficiency protocol and 8 skills, so instructed tool calls no longer fail. (#1)
- **SessionStart hook fallback** — now resolves the versioned install directory (`~/.claude/plugins/cache/nagisanzenin/production-grade/<version>/`) where `session-guard.sh` actually lives, via a pure-shell version-sorted glob. The previous unversioned fallback pointed at a path with no script, silently skipping the guard when `CLAUDE_PLUGIN_ROOT` was unset. (#3)
- **Auto-Update Check dropped `hooks/`** — the updater copied only `skills`, `.claude-plugin`, `README.md`, and `VISION.md` into the new version directory, so the SessionStart hook disappeared after an in-plugin update. It now copies the full plugin (excluding VCS metadata).

## [5.4.0] — 2026-03-07

### Added
- **Harmonization protocol** — new Section 8 in DEV_PROTOCOL.md. Conflict matrix with 9 check categories, 7-level authority hierarchy (VISION > DEV_PROTOCOL > Protocols > Orchestrator > Phase dispatchers > Sub-skill SKILL.md > Agent() prompts), recurring audit triggers, and harmonization checklist. Ensures cohesiveness as the system evolves.
- **Pipeline gates vs agent questions distinction** — formalized in VISION.md Principle IV and DEV_PROTOCOL. Pipeline gates (3 per run: BRD, Architecture, Production Readiness) are mode-independent. Agent questions (framework choice, style selection, test strategy) scale with engagement mode: zero in Express, full in Meticulous. An agent question firing in Express mode is now defined as a design bug.
- **Cross-session enforcement via SessionStart hook** — new `hooks/hooks.json` and `hooks/session-guard.sh`. Detects projects built with production-grade (via `Claude-Production-Grade-Suite/` directory) and presents a courteous 3-option choice: use production-grade, work directly, or chat about it. Silent in non-production-grade projects.
- **SUSTAIN phase CLAUDE.md directive** — production-grade native projects get a CLAUDE.md section prompting the 3-option choice at session start, ensuring cross-session consistency.

### Changed
- **Mode-aware AskUserQuestion across all skills** — 15+ mandatory user prompts across 11 files converted from "always ask" to engagement-mode-aware behavior. Express auto-resolves with sensible defaults and reports choices. Standard asks only subjective/irreversible decisions (1-2 per skill). Thorough surfaces all major decisions. Meticulous surfaces every decision point.
- **UX Protocol Rule 6** rewritten as engagement-mode-aware autonomy spectrum with explicit table (Express/Standard/Thorough/Meticulous behaviors) plus "never mode-dependent" and "always mode-dependent" lists.
- **Frontend Engineer** — style selection (Creative/Elegance/High Tech/Corporate) now mode-aware: Express auto-selects based on domain mapping, Standard+ asks user. Framework confirmation, page approval, and design review all mode-aware.
- **Software Engineer** — context analysis clarifications, plan review, service implementation review, and integration review all mode-aware.
- **DevOps** — 6-question infrastructure interview now mode-aware: Express infers from code, Standard asks unknowns, Thorough/Meticulous full interview.
- **Security Engineer** — compliance/threat context questions mode-aware: Express infers from domain, Standard asks compliance only.
- **Skill Maker** — Phase 1 interview mode-aware: Express skips entirely, Standard 1-2 questions.
- **Technical Writer** — content audit approval and deployment options mode-aware: Express defaults to GitHub Pages.
- **All Agent() prompts in phase dispatchers** — now include explicit `Use the Skill tool to invoke 'production-grade:<skill-name>'` instruction, ensuring sub-agents load their full SKILL.md methodology instead of flying blind with 5-10 line prompts.
- **VISION.md** — fixed all numeric references: "Thirteen" → "Fourteen" agents (4 occurrences), "13 skills" → "14 agents", "original 13" → "built-in 14".
- **DEV_PROTOCOL.md** — fixed "10 principles" → "11 principles". Added 3 new quality checklist items (mode-awareness, numeric consistency, Agent() prompt alignment).

## [5.3.0] — 2026-03-07

### Added
- **Worktree isolation for parallel agents** — all parallel Agent calls now use `isolation="worktree"` by default. Each concurrent agent gets its own git worktree — zero file race conditions. Dirty-state detection with auto-commit or fallback option. Merge-back orchestration after each wave completes. Worktree decision stored in pipeline settings.
- **Self-healing gates (rework loops)** — gate rejection no longer stops the pipeline. When a user rejects at Gate 2 or Gate 3, concerns are fed back to the relevant agent (Solution Architect or Remediation Engineer) for rework. Re-verification and re-presentation happen automatically. Max 2 rework cycles per gate before escalation. All rework cycles logged to `.orchestrator/rework-log.md` with concerns and changes.
- **Cost dashboard** — effort tracking in every receipt (`files_read`, `files_written`, `tool_calls`). Pre-pipeline cost estimate shown after engagement mode selection (based on mode × engagement × project complexity). Final summary includes aggregated cost metrics across all agents with estimated token usage.
- **Cost estimation table** in visual-identity protocol — lookup table for estimated tokens by mode (Full Build, Feature, Harden, etc.) × engagement level (Express through Meticulous).

### Changed
- **Receipt protocol** — new `effort` field added to receipt schema (files_read, files_written, tool_calls). All agent prompts in phase dispatchers updated to include effort tracking.
- **All 5 phase dispatchers** (define, build, harden, ship, sustain) — Agent calls include `isolation="worktree"`, worktree pre-flight check in BUILD, merge-back instructions after each parallel wave.
- **Orchestrator parallelism preference** — new "Maximum + worktree isolation" option (recommended default). Settings now include `Worktrees: enabled|disabled`.
- **Gate 2 ceremony** — "I have concerns" replaced with "Rework architecture" with explicit rework loop.
- **Gate 3 ceremony** — "Fix issues first" replaced with "Rework — fix issues first" with remediation re-run and re-verification.
- **Final summary template** — new cost line showing agents used, total tool calls, files processed, estimated tokens. Worktree and rework cycle counts included.
- **DEV_PROTOCOL.md** — 3 new differentiators (worktree isolation, self-healing gates, cost dashboard). 3 new common quality failure entries. Cost estimation marked as shipped.

## [5.2.0] — 2026-03-07

### Added
- **Frontend "make it work, then make it beautiful" overhaul** — restructured from 5 to 6 phases. Phase 2 reduced to functional defaults (system fonts, neutral palette — move fast). NEW Phase 5 (Design & Polish) added after functional verification.
- **4 visual style presets** — user selects Creative, Elegance, High Tech, or Corporate at the start of Phase 5. Each drives all design decisions: colors, typography, spacing, interaction richness, dark mode treatment.
  - **Creative** — vibrant, bold gradients, expressive fonts, animated transitions, illustrated empty states
  - **Elegance** — minimalist, Apple-inspired, restrained palette, thin font weights, whitespace-driven
  - **High Tech** — terminal aesthetics, monospace accents, dark-mode-first, data-dense, grid-aligned
  - **Corporate** — formal, conservative palette, standard layouts, no animations, enterprise-ready
- **Design research phase** — Phase 5 uses WebSearch (freshness protocol) to research domain trends, competitive visual benchmarks, and style-specific inspiration before making any design decisions.
- **Frontend functional completeness enforcement** — Phase 4b (Functional Verification Pass). Dead Element Rule: any button/link/form that renders but does nothing is a Critical bug. Navigation Graph Verification. Interaction Trace: top 5 user flows walked click-by-click. Cross-Agent Reconciliation after parallel page builds.

### Changed
- **Frontend Engineer** — 6 phases (was 5). Phase 2 is functional defaults. Phase 5 is design research + polish. Phase 6 (Testing) tests the final polished version.
- **Code Reviewer** Phase 2 — new checks for dead interactive elements and navigation completeness.

## [5.1.0] — 2026-03-07

### Added
- **Boundary safety protocol** — new shared protocol (`boundary-safety.md`) with 6 structural patterns that cause silent failures at system boundaries. Derived from real deployment bugs found during a production-grade pipeline run on PingBase.
- **6 patterns enforced**: (1) framework abstractions break at boundaries — use platform primitives when crossing domains, (2) delegate to framework control flow — don't duplicate middleware logic in UI, (3) self-referencing config creates infinite loops, (4) global interceptors must be conditional, (5) test full user journeys across system boundaries, (6) identity must be consistent across integrated systems.

### Changed
- **All 14 skills** now load `boundary-safety.md` at startup.
- **Frontend Engineer** — 7 new Common Mistakes entries for navigation misuse, auth flow duplication, callback misconfiguration, and unconditional interceptors.
- **Code Reviewer** Phase 2 — new "Boundary Safety" review dimension (5 checks): framework abstraction misuse, duplicated control flow, self-referencing config, unconditional interceptors, identity consistency.
- **QA Engineer** Phase 5 (E2E) — 2 new rules requiring cross-boundary journey testing and framework navigation correctness verification. 2 new Common Mistakes entries.
- **Orchestrator** Common Mistakes table expanded with 4 boundary safety anti-patterns.
- **Orchestrator** protocol table updated to include `boundary-safety.md`.

## [5.0.0] — 2026-03-06

### Added
- **Receipt-based gate enforcement** — new shared protocol (`receipt-protocol.md`) requiring every agent to write a JSON receipt as proof of completion. Receipts list artifacts produced, concrete metrics, and verification summary. Orchestrator verifies receipts and artifact existence at every phase transition and before every gate. No receipt = task not complete.
- **Receipt verification at all 3 gates** — Gate 1 verifies PM receipt, Gate 2 verifies Architect receipt, Gate 3 verifies ALL receipts including remediation chain (finding → fix → verification) for Critical/High issues.
- **Remediation receipt chain** — Critical/High findings require three receipts: finding agent receipt, remediation receipt, and verification receipt from the original finder confirming the fix. All three must exist before Gate 3 opens.
- **Re-anchoring protocol** — orchestrator re-reads key workspace artifacts FROM DISK at every phase transition (DEFINE→BUILD, BUILD→HARDEN, HARDEN→SHIP, SHIP→SUSTAIN). Prevents context drift in long pipeline runs where compressed memory degrades accuracy of specs, ADRs, and API contracts.
- **Adversarial code review stance** — code-reviewer skill reframed from neutral observer to adversarial challenger. Assumes code is wrong until proven right. Scaled with engagement mode: Express (Critical-only hunt), Standard (Critical+High), Thorough (all severities with edge case analysis), Meticulous (hostile with reproducible break scenarios).
- **Phase-specific adversarial framing** — each review phase (Architecture Conformance, Code Quality, Performance, Test Quality) has explicit adversarial framing directing the reviewer to assume violations exist.

### Changed
- **All 14 skills** now load `receipt-protocol.md` at startup.
- **All 5 phase dispatchers** updated with receipt verification blocks, re-anchor blocks, and receipt-writing instructions in agent prompts.
- **Orchestrator bootstrap** creates `.orchestrator/receipts/` directory.
- **Gate ceremony templates** now read verified receipt data for metrics display instead of relying on agent memory.
- **Non-Full-Build modes** write and verify receipts at mode completion.
- **Common Mistakes table** expanded with receipt, re-anchoring, and adversarial review anti-patterns.

## [4.4.0] — 2026-03-06

### Added
- **Freshness protocol** — new shared protocol (`freshness-protocol.md`) that gives all 14 agents temporal sensitivity to volatile data. Agents now recognize when they're about to use potentially outdated information (LLM model IDs, API pricing, package versions, CVEs, framework APIs, Docker tags, cloud service features) and trigger WebSearch to verify before implementing.
- **4-tier volatility classification** — Critical (days-weeks: model IDs, pricing, CVEs → MUST search), High (weeks-months: package versions, framework APIs, Docker tags → search when writing config), Medium (months-quarters: browser APIs, crypto best practices → search if uncertain), Stable (years+: language fundamentals, protocols → trust training data).
- **Search-then-implement pattern** — when volatile data is detected, agents pause, WebSearch for current state, cite what they found with `✓ Verified:` markers, then implement with verified data.
- **Skill-specific sensitivity table** — each agent knows its own high-sensitivity areas (Software Engineer: package versions/SDK APIs, DevOps: Docker tags/Terraform providers, Security: CVEs/crypto, Data Scientist: LLM model IDs/pricing, etc.).

### Changed
- **All 14 skills** now load `freshness-protocol.md` at startup alongside existing protocols.
- **Orchestrator protocol table** updated to include freshness protocol in workspace bootstrap.

### Fixed
- **Orphaned agents after pipeline completion** — orchestrator now calls `TeamDelete` after the final summary and on gate rejection. Previously, all agents remained idle indefinitely after work was done, requiring manual intervention to shut down.

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
