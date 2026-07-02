# Development Protocol

*Read this before implementing anything. This is the law of this project.*

This document is the operational counterpart to [VISION.md](VISION.md). VISION defines *what we believe*. DEV_PROTOCOL defines *how we build*. Every change — by human or AI — must conform to both.

---

## 1. Identity and Positioning

### What We Are

A **compound intelligence system** — 14 specialized agents coordinated by a single orchestrator — that transforms Claude Code from producing raw code into delivering production-ready systems. One plugin install gives users architecture, tested code, security audit, CI/CD, and documentation.

### What We Are Not

- Not a collection of independent skills. Every skill is part of a system — it reads upstream artifacts, produces downstream artifacts, and obeys shared protocols.
- Not a code generator. Code generators produce files. We produce *systems* — tested, secured, documented, deployable.
- Not a chatbot wrapper. We research, decide, build, verify. We pause for human input at 3 gates, not 30.

### Our Differentiators

These are the capabilities that no adjacent plugin offers in combination. Protect them in every change:

| Differentiator | What It Means | Adjacent Landscape Context |
|---|---|---|
| **Receipt enforcement** | JSON proof of completion from every agent. No receipt = not done. Gate won't open without verified artifacts. | Most multi-agent plugins (Ruflo, wshobson/agents, Superpowers) rely on LLM self-reporting. No verifiable proof chain. |
| **Re-anchoring** | Orchestrator re-reads specs FROM DISK at every phase transition. Prevents context drift in multi-hour runs. | No adjacent plugin addresses context drift. Long runs in other systems silently degrade. |
| **Adversarial code review** | Reviewer assumes code is WRONG until proven right. Scales from critical-only to hostile break scenarios. | Other review skills (wshobson's code-reviewer, Superpowers' review mode) are neutral observers, not adversaries. |
| **Freshness protocol** | Agents detect volatile data and WebSearch to verify BEFORE implementing. | No adjacent plugin has temporal awareness. They ship training-data-era model IDs, deprecated APIs, stale versions. |
| **Boundary safety** | 6 structural patterns for system boundary bugs, derived from real deployment. | Novel — derived from our own PingBase deployment. Not in any other system. |
| **Constraint-driven architecture** | Architecture derived from YOUR scale, budget, team, compliance — not templates. | wshobson/agents and Shipyard use template-based architecture. We derive from first principles. |
| **Functional completeness** | Dead Element Rule — any button/link/form that renders but does nothing is a Critical bug, not a TODO. | No frontend skill in the ecosystem enforces functional verification. They produce structure, not behavior. |
| **Engagement modes** | Express/Standard/Thorough/Meticulous — propagated to all 14 agents, controlling decision surfacing depth. | Superpowers has a planning mode but no granular engagement control across agents. |
| **Worktree isolation** | Each parallel agent runs in its own git worktree — zero file race conditions. Auto-detect dirty state, auto-commit or fallback. Merge branches back after each wave. | Superpowers uses worktrees but without auto-detection/fallback or merge-back orchestration. |
| **Self-healing gates** | Gate rejection loops back to the relevant agent for rework (max 2 cycles), re-verifies, re-presents. Pipeline never dead-ends on rejection. | No adjacent plugin has rework loops. Gate rejection = pipeline stop everywhere else. |
| **Cost dashboard** | Effort tracking in every receipt (files_read, files_written, tool_calls). Pre-pipeline cost estimate. Final summary aggregates across all agents. | No adjacent plugin provides cost visibility. Users fly blind on token spend. |

| **Harmonization protocol** | Recurring discipline to detect and fix design conflicts across 14 skills, 9 protocols, and 11 principles. Conflict matrix, authority hierarchy, engagement mode consistency checks. | No adjacent plugin has a self-consistency mechanism. Multi-agent systems accumulate contradictions silently. |

**Rule: Any new feature must either strengthen an existing differentiator or introduce a new one. Features that merely match what others already do are low priority.**

---

## 2. Architecture Rules

### The Skill Is the Unit of Work

Every skill follows this structure:

```
skills/{skill-name}/
  SKILL.md          — router + dispatch table (always loaded)
  phases/           — on-demand phase files (loaded one at a time)
    01-{phase}.md
    02-{phase}.md
    ...
```

**Rules:**
- SKILL.md is the entry point. It loads protocols, classifies inputs, and dispatches to phases. It must NOT contain phase implementation detail.
- Phase files are loaded on demand — never all at once. Each phase file is self-contained with its own objective, prerequisites, implementation, output contract, and validation loop.
- Large skills (Software Engineer, Frontend Engineer, Security Engineer, SRE, Data Scientist, Technical Writer) MUST be split into phases. Small skills (Code Reviewer, Polymath) may be single-file.
- Phase count per skill should be 4-6. Fewer means phases are too big. More means unnecessary granularity.

### Protocol Stack Is Law

All 14 agents load these 9 shared protocols at startup:

```
1. UX Protocol          — structured interactions, no open-ended questions
2. Input Validation     — classify external inputs (Critical/Degraded/Optional)
3. Tool Efficiency      — dedicated tools over shell commands
4. Visual Identity      — formatting, containers, icons, timing, progress
5. Conflict Resolution  — sole-authority domains, no agent contradicts another's domain
6. Freshness Protocol   — verify volatile data before implementing
7. Receipt Protocol     — JSON proof of completion, verified at gates
8. Boundary Safety      — 6 patterns for system boundary bugs
9. Loop Protocol        — oracle-driven iteration: no oracle no loop, convergence guards, oracle immutability
```

**Rules:**
- Every new skill MUST load all 9 protocols via `!`cat` commands in its SKILL.md header.
- New protocols are added only when a pattern is (a) universal across all agents, and (b) derived from real failure, not theory. We currently have 9 (the Loop Protocol was motivated by documented failures: tests written but never run, oracle-gaming by weakening checks, fixed-count rework that neither converges nor escalates well). Getting to 12 would be concerning. Each protocol adds cognitive load to every agent.
- Protocol files live in `skills/_shared/protocols/`. They are never skill-specific.

### Parallelism Architecture

Parallelism follows a strict pattern: **shared foundations BEFORE parallel execution**.

| Skill | Sequential Foundation | Then Parallel |
|---|---|---|
| Software Engineer | `libs/shared/` (types, errors, middleware, auth, logging, config) | 1 agent per service |
| Frontend Engineer | UI Primitives (Button, Input, Select, Modal, etc.) | Layout + Feature components in parallel, then pages in parallel |
| QA Engineer | Test infrastructure setup | Unit / Integration / E2E / Performance in parallel |
| Security Engineer | Threat model | Code audit / Auth / Data / Supply chain in parallel |

**Why foundations first:** Without shared foundations, N parallel agents create N different implementations of the same concern (N error handlers, N auth checks, N button components). Foundations first ensures consistency.

**Rule: Never parallelize agents that share a dependency. If agent B imports from agent A's output, A runs first.**

### Orchestrator Controls Everything

The orchestrator (`skills/production-grade/SKILL.md`) is the single entry point. It:
1. Classifies the request into one of 10 execution modes
2. Presents the plan (for multi-skill modes)
3. Creates teams and tasks
4. Manages gate ceremonies
5. Verifies receipts at every phase transition
6. Re-anchors from disk at every phase transition
7. Cleans up agents on completion

**Rule: Sub-skills never invoke other sub-skills. Only the orchestrator dispatches. If skill A needs output from skill B, the orchestrator sequences them.**

---

## 3. Quality Standards

### The Production-Grade Bar

"It compiles" is not done. "It passes tests" is not done. "It works in production" is the bar.

Every output must satisfy:
- **No TODOs, stubs, or placeholders.** If it's written, it works.
- **All code compiles, all tests pass, all infrastructure validates.** Agents verify their own output.
- **Security is continuous.** Credentials never hardcoded. Inputs validated at system boundaries.
- **Functional completeness.** Every button does something. Every link resolves. Every form submits. Every nav item reaches a page that renders.

### Common Quality Failures (From Real Deployments)

These are patterns we've seen fail in production. Every change should be checked against this list:

| Failure | Root Cause | Prevention |
|---|---|---|
| Buttons that render but do nothing | No onClick handler, or handler is a no-op | Dead Element Rule in Frontend Engineer Phase 4b |
| Auth flow infinite redirects | Config override pointing to the default value | Boundary Safety Pattern 3 |
| Cross-page links that 404 | Parallel page agents don't know about each other's routes | Cross-Agent Reconciliation in Phase 4b |
| Wrong model IDs / deprecated APIs | Training data staleness | Freshness Protocol |
| Frontend looks good but doesn't function | Design-first instead of function-first | 6-phase frontend: functional foundation → then design polish |
| Agent claims work is done but files are missing | No verification mechanism | Receipt Protocol + artifact existence check |
| Context drift in long pipeline runs | Compressed memory degrades spec accuracy | Re-anchoring from disk at every phase transition |
| Framework router used for API/OAuth URLs | Abstraction doesn't cross domain boundary | Boundary Safety Pattern 1 |
| N different error handlers across N services | No shared foundation before parallelism | Sequential `libs/shared/` before parallel service agents |
| Parallel agents overwrite each other's files | No isolation between concurrent agents | Worktree isolation — each agent gets its own git worktree |
| Pipeline stops on gate rejection, user must restart | No rework mechanism | Self-healing gates — rework loop feeds concerns back to agent (max 2 cycles) |
| No visibility into pipeline cost | No effort tracking | Receipt effort fields + cost estimation table + final summary dashboard |

### Verification Hierarchy

Not all verification is equal. Use the right level:

```
Level 1 — Self-verification     Agent checks its own output (minimum)
Level 2 — Receipt verification  Orchestrator reads receipt + confirms artifacts exist
Level 3 — Cross-agent review    Another agent reviews (Code Reviewer, QA Engineer)
Level 4 — User approval         Gate ceremony with concrete metrics
```

Every task gets Level 1-2. Critical findings get Level 3. Phase transitions get Level 4.

---

## 4. Development Workflow

### Making Changes to the Plugin

```
1. Understand the change — read existing code before modifying
2. Check against differentiators — does this strengthen one? introduce one?
3. Check against architecture rules — protocols, phase structure, parallelism
4. Implement — modify existing files, don't create new ones unless necessary
5. Update version — bump plugin.json, marketplace.json, installed_plugins.json, cache dir
6. Update CHANGELOG.md — what changed, what was added, what was fixed
7. Update README.md — if user-visible behavior changed
8. Test locally — install and verify the plugin works
9. Commit and push
```

### Version Bumping Checklist

Version lives in 4 places. All must match:

```
1. .claude-plugin/plugin.json                                     → version field
2. ~/nagi_plugins/nagisanzenin-plugins/.claude-plugin/marketplace.json → plugins[0].version
3. ~/.claude/plugins/installed_plugins.json                        → production-grade@nagisanzenin entry
4. ~/.claude/plugins/cache/nagisanzenin/production-grade/{version}/ → directory name
```

**Versioning policy:**
- Patch (5.2.x) — bug fixes, wording changes, minor improvements
- Minor (5.x.0) — new protocol, new skill, new execution mode, significant capability addition
- Major (x.0.0) — breaking changes to skill structure, protocol changes that affect all agents, fundamental architecture shifts

### Adding a New Skill

1. Create `skills/{skill-name}/SKILL.md` with YAML frontmatter (`name`, `description`)
2. Add all 9 protocol `!`cat` loading lines in the header
3. Add Engagement Mode section reading from `settings.md`
4. Add Progress Output section following visual identity
5. Add Input Classification table (Critical/Degraded/Optional)
6. Split into phases if the skill has 4+ logical steps
7. Add the skill to the orchestrator's routing table in `skills/production-grade/SKILL.md`
8. Update README.md crew section and agent count
9. Update plugin.json description if the skill changes the plugin's scope

### Adding a New Protocol

Protocols are expensive — they add to every agent's context. Gate carefully:

1. **Derived from real failure.** Not theory. Show the bug, the root cause, and why it's universal.
2. **Applies to all agents.** If it only affects 2-3 skills, put it in those skills, not a shared protocol.
3. **Cannot be expressed as a Common Mistakes entry.** If a 2-line table row captures it, don't write a protocol.
4. Add the file to `skills/_shared/protocols/`
5. Add `!`cat` loading line to ALL 14 skill SKILL.md files
6. Add to the orchestrator's protocol table
7. Document in CHANGELOG

---

## 5. User Experience Principles

### Zero Open-Ended Questions

Every interaction is `AskUserQuestion` with predefined options. Arrow keys + Enter. "Chat about this" always last. Recommended option always first.

This is non-negotiable. The target user is a non-technical founder or product person. They should never need to type a technical answer.

### 3 Pipeline Gates (Distinct from Agent Questions)

Full pipeline: Gate 1 (Requirements), Gate 2 (Architecture), Gate 3 (Production Readiness). These are **pipeline-level strategic checkpoints** — they exist in all engagement modes, always.

Single-skill modes: 0 gates. The intent is clear — just execute.

Multi-skill modes: 1-2 gates depending on the mode.

**Gates are NOT agent questions.** A gate is a full-stop pipeline checkpoint where the user reviews the big picture. An agent question is a skill-level decision point (framework choice, style selection, test strategy). These are separate layers:

| Layer | What | Controlled By |
|-------|------|---------------|
| **Pipeline gates** | Strategic go/no-go (BRD, Architecture, Production Readiness) | Always 3, all modes |
| **Agent questions** | Technical/design choices within each skill | Engagement mode |

| Mode | Pipeline Gates | Agent Questions |
|------|---------------|----------------|
| Express | 3 | 0 — auto-resolve everything, report decisions |
| Standard | 3 | 1-2 per agent, only subjective/irreversible |
| Thorough | 3 | All major decisions surfaced |
| Meticulous | 3 | Every decision, user reviews before implementation |

**Rule: Adding a gate is a major decision. Adding an agent question is a skill-level decision that MUST respect engagement mode. Never add a question that fires in Express mode.**

### Engagement Mode Propagation

The user selects Express/Standard/Thorough/Meticulous once at pipeline start. This propagates to all 14 agents via `settings.md` and controls:
- How many decisions are surfaced
- How deep interviews go
- How much discovery happens
- How adversarial the code review is

Express = fully autonomous, report decisions in output.
Meticulous = surface every decision point.

**Rule: Every new skill must read `settings.md` and adapt its behavior to the engagement mode.**

### Progress Is Trust

Users trust what they can see. Concrete numbers are the #1 trust signal.

- Every `✓` line includes counts: `✓ Analyzed 247 files, found 12 issues`
- Completion summaries include metrics: `✓ Software Engineer    4 services, 12 endpoints    ⏱ 3m 41s`
- Gate ceremonies show a metrics block with key-value pairs
- Before/after deltas prove transformation: `12 findings → 0 Critical remaining`

**Rule: "Analysis complete" is never acceptable. Say what was analyzed, what was found, what was produced.**

---

## 6. Lessons from the Landscape

These observations come from deep research into adjacent plugins and the broader AI agent ecosystem. They inform what we build and what we avoid.

### What Adjacent Plugins Do Well

| Plugin / System | Strength | What We Can Learn |
|---|---|---|
| **Superpowers** (obra) | Forces planning before coding. TDD-first mindset. Clean brainstorm→plan→execute workflow. | Our PM+Architect DEFINE phase serves the same purpose but at a higher level. We could learn from their simpler single-developer planning UX for lightweight modes. |
| **wshobson/agents** | 112 agents organized into 72 focused plugins. Modular — install only what you need. Agent Teams preset for common workflows. | Modularity is powerful. Our single-install approach is simpler but less flexible. Consider: could our execution modes serve as the "modularity" equivalent? |
| **Ruflo** | Swarm intelligence, consensus mechanisms, distributed agent coordination. Enterprise positioning. | Swarm patterns are interesting for future exploration. Our current wave-based parallelism is simpler but may not scale to 20+ agents. |
| **Shipyard** | IaC validation (Terraform, Ansible, Docker, K8s, CloudFormation). Security auditing integrated with lifecycle. | Our DevOps skill handles IaC but doesn't validate it as deeply. IaC validation is a potential enhancement area. |
| **Plannotator** | Structured, annotated planning with review/share capabilities. | Our Solution Architect produces ADRs. Could we make architecture artifacts more shareable/reviewable? |
| **claude-code-plugins-plus** (jeremylongshore) | 270+ plugins, 739 skills, CCPI package manager, interactive tutorials. Massive breadth. | Breadth without depth is their weakness. Our strength is depth — 14 agents that actually coordinate. Don't chase breadth. |

### What the Ecosystem Gets Wrong

These are systemic problems across the AI agent coding landscape. Our protocols exist specifically to prevent them:

| Problem | Industry Evidence | Our Solution |
|---|---|---|
| **Hallucinated dependencies** | AI models invent non-existent packages. Attackers register those names with malicious code. (45% of developers cite "almost right but not quite" as #1 frustration.) | Freshness Protocol — WebSearch to verify packages, versions, APIs before implementing. |
| **Compounding errors** | Mistakes compound over agent runtime. By the end, errors are baked into the code irreversibly. | Receipt Protocol + Re-anchoring — verify at every phase transition, re-read specs from disk. |
| **Surface-level correctness** | Code looks syntactically perfect but contains subtle bugs — off-by-one errors, hallucinated methods, security flaws. Recently released LLMs create fake output by removing safety checks. | Adversarial Code Review — assumes code is wrong. QA Engineer runs actual tests. Dead Element Rule catches non-functional UI. |
| **No verification loop** | Most agent systems have no way to prove work was actually done vs. hallucinated. | Receipt Protocol — JSON proof with artifact existence verification. No receipt = not done. |
| **Context drift** | Multi-hour agent runs lose track of original specs as context compresses. | Re-anchoring — re-reads key artifacts FROM DISK at every phase transition. |
| **Template architecture** | Systems apply the same architecture regardless of scale, budget, or constraints. | Constraint-driven architecture — 100 users gets monolith, 10M gets microservices, derived from your specific constraints. |

### Features Worth Exploring (Future Roadmap)

Informed by landscape research and industry trends. These are not commitments — they are directions worth investigating:

| Direction | Why | Complexity |
|---|---|---|
| **IaC validation** | Shipyard validates Terraform/K8s/Docker configs structurally. Our DevOps skill writes IaC but doesn't validate deeply. | Medium — extend DevOps phases |
| **Agent observability dashboard** | Industry trend: RBAC, audit trails, compliance logging for AI agents. | High — requires external tooling |
| **Incremental re-runs** | Only re-run skills whose inputs changed. Currently the pipeline doesn't track dependency freshness. | High — requires dependency graph tracking |
| **Cost estimation** | ✓ Shipped in v5.3.0 — effort tracking in receipts, pre-pipeline estimate, final cost dashboard. | — |
| **Skill marketplace** | Allow community-contributed skills that plug into the orchestrator. | High — requires skill contract, testing, compatibility |
| **Test execution** | QA Engineer writes tests but doesn't always run them. Running tests requires runtime environment. | Medium — Docker-based test execution |
| **Visual diff for architecture** | Show before/after diagrams when architecture changes. | Low — generate Mermaid diagrams |
| **Memory across pipeline runs** | Remember decisions from previous runs on the same project. Compound learning. | Medium — persistent workspace artifacts |

---

## 7. Autonomous Resilience — Self-Healing and Self-Learning

The plugin aims to be autonomous in a sense that the system self-heals and self-learns when possible. Both require thoughtful implementation — every recovery loop and learning artifact has a token cost and a context footprint.

### Self-Healing Rules

The pipeline should recover from failures without human intervention whenever possible. But recovery is not free — every retry burns tokens, every rework cycle adds context.

As of v5.5, all recovery loops are governed by the Loop Protocol (`skills/_shared/protocols/loop-protocol.md`): every loop names an executable oracle, tracks a ratchet, and exits on **convergence, plateau (2 no-progress rounds), or oscillation** — the counts below are hard-cap BACKSTOPS, not targets. Escalation changes strategy, not effort (fresh approach → altitude up → user).

| Mechanism | Backstop | Why the Bound Exists |
|---|---|---|
| Gate rework loops | Max 2 cycles per gate | Beyond 2, the issue is likely fundamental, not incremental. Escalate to user. |
| Agent self-debug | Max 3 attempts | After 3 failures, the agent lacks the information to self-resolve. Report with diagnostics. |
| Worktree merge conflicts | 1 auto-resolve attempt | Merge conflicts require human judgment. Don't burn tokens guessing. |
| Remediation re-scan | Max 3 fix-rescan cycles | Convergence-based (ratchet = open Critical/High); if the count stops falling for 2 cycles, the root cause is misidentified — escalate with the trajectory. |
| Inner red-green / review / integration / functional-drive loops | Per loop-protocol Rules 3 & 10 | Convergence-first with plateau/oscillation guards; budgets scale with engagement mode. |

**Token discipline for self-healing:**
- Rework reuses existing context. Re-read the same artifacts — don't re-discover from scratch.
- When looping, the agent carries forward only the specific concern (the user's rejection reason, the failing test output) — not the entire phase history.
- Every self-healing loop MUST produce a log entry in `.orchestrator/rework-log.md` so the cost is visible in the final summary.
- If a rework cycle would exceed an estimated 50K tokens (e.g., re-running an entire BUILD phase), warn the user before proceeding.

### Self-Learning Rules

The pipeline should get smarter across runs. But learning artifacts must be compact — context window space is the scarcest resource.

| Learning Type | When Written | Size Bound | Storage |
|---|---|---|---|
| Compound learnings | End of pipeline (T13) | Max 50 lines | `.orchestrator/compound-learnings.md` |
| Project patterns | End of pipeline (T13) | Max 20 lines appended to CLAUDE.md | Project root `CLAUDE.md` |
| Rework log | During rework cycles | 5-10 lines per cycle | `.orchestrator/rework-log.md` |
| Cost actuals | End of pipeline | 3-5 lines in final summary | Printed, not stored |

**What is NOT self-learning:**
- Storing full agent transcripts (too large, low signal-to-noise)
- Automatically injecting prior-run context without user approval
- Caching intermediate artifacts across runs (stale data risk)
- Growing a persistent database that accumulates indefinitely

**The test for a learning artifact:** Would a new Claude Code session benefit from reading this in under 30 seconds? If yes, keep it. If it requires 2+ minutes to parse, it's too verbose.

### Context Accumulation Awareness

Every feature that adds information to the pipeline has a context cost. Be aware of it:

```
Feature costs context:
  +9 protocols × 14 agents         = protocol loading overhead (fixed, acceptable)
  +1 rework cycle                  = ~10-30K tokens (bounded by max 2 cycles)
  +1 compound learning entry       = ~500 tokens (acceptable)
  +1 new protocol                  = ~2K tokens × 14 agents = 28K per run (expensive — gate carefully)
  +1 new phase per skill           = ~5K tokens per invocation (moderate — justify it)
```

**Rule: When adding any feature that persists data or adds loop iterations, estimate its token cost per pipeline run. If it exceeds 10K tokens, it needs explicit justification in the CHANGELOG.**

---

## 8. Harmonization Protocol

A system with 14 skills, 9 protocols, 5 phase dispatchers, and 11 governing principles will accumulate design conflicts through normal iteration. New features get bolted on. Principles evolve. Agent prompts drift from their SKILL.md definitions. What was coherent at v5.0 develops contradictions by v5.4.

**Harmonization is not a one-time fix — it is a recurring discipline.**

### When to Harmonize

| Trigger | Scope |
|---------|-------|
| Every 3-5 patches (e.g., after v5.5, v5.8, etc.) | Full audit |
| After any VISION.md principle change | All skills + protocols against the changed principle |
| After adding/modifying a protocol | All 14 skills that load it |
| After modifying engagement mode definitions | All skills that reference engagement modes |
| After modifying gate policy | All phase dispatchers + orchestrator |
| Before any major version release | Full audit |

### The Conflict Matrix

Run these checks during every harmonization pass. Each row is a potential conflict surface:

| Check | What Conflicts | How to Detect |
|-------|---------------|---------------|
| **Gates vs Modes** | 3-gate limit (Principle IV) vs Meticulous mode wanting max involvement | Search for "gate" in all phase files. Verify: gates are pipeline-level (always 3), agent questions are mode-dependent (0 in Express, many in Meticulous). These are different layers. |
| **MUST-ask vs Express** | Hardcoded AskUserQuestion calls vs Express mode's "fully autonomous" | Search for "AskUserQuestion", "MUST ask", "STOP" in all skill/phase files. Every mandatory prompt must have a mode-aware escape: in Express, auto-resolve with a sensible default and report. |
| **Authority overlaps** | Two skills claiming the same domain (e.g., both Security and Code Reviewer doing OWASP) | Read conflict-resolution.md authority table. Grep all SKILL.md files for domain claims. No two skills should own the same concern. |
| **Protocol vs Skill** | Protocol says "always X" but a skill says "never X" or ignores X | For each protocol rule, grep all skills for contradicting instructions. |
| **Orchestrator prompt vs SKILL.md** | Agent() prompt in phase dispatcher says one thing, the skill's SKILL.md says another | Compare every Agent() prompt in build/harden/ship/sustain.md against the corresponding SKILL.md. The SKILL.md is the authority — the prompt should align, not contradict. |
| **VISION vs DEV_PROTOCOL** | A VISION principle's hard rules vs DEV_PROTOCOL's operational rules | Re-read both documents. Every DEV_PROTOCOL rule should trace to a VISION principle. Orphaned rules in DEV_PROTOCOL need justification or removal. |
| **Engagement mode tables** | Different skills defining Express/Standard/Thorough/Meticulous differently | Grep all skills for engagement mode tables. All must use the same behavioral spectrum. Express is always fully autonomous. Meticulous always surfaces every decision. |
| **Phase dependencies** | Phase N assumes output from Phase N-1 that might not exist in certain modes | Trace the data flow: what does Phase 3 read that Phase 2 writes? What if Express mode skipped a Phase 2 question? |
| **Cross-reference counts** | DEV_PROTOCOL says "10 principles" but VISION has 11. README says "13 agents" but there are 14. | Grep for all numeric claims about the system and verify against actual counts. |

### Authority Hierarchy

When conflicts are found, resolve using this hierarchy (highest authority first):

```
1. VISION.md principles     — constitutional law, rarely changes
2. DEV_PROTOCOL.md rules    — operational law, derives from VISION
3. Protocol files            — universal agent behavior, derives from DEV_PROTOCOL
4. Orchestrator SKILL.md     — pipeline control, implements protocols
5. Phase dispatchers         — phase-level execution, implements orchestrator
6. Sub-skill SKILL.md files  — agent methodology, constrained by protocols
7. Agent() prompts           — must align with the SKILL.md they invoke
```

Lower layers NEVER override higher layers. If a sub-skill SKILL.md contradicts a protocol, the protocol wins. If a protocol contradicts a VISION principle, the principle wins.

### Harmonization Checklist

Run this after every harmonization pass:

- [ ] Every VISION principle's hard rules are reflected in at least one protocol or DEV_PROTOCOL rule
- [ ] Every protocol rule is consistent with every other protocol
- [ ] Every skill's engagement mode table uses the same behavioral spectrum
- [ ] Every "MUST ask" instruction has a mode-aware clause (Express gets auto-resolve)
- [ ] Every Agent() prompt in phase dispatchers aligns with the invoked SKILL.md
- [ ] All numeric claims (principle count, agent count, protocol count, gate count) match reality
- [ ] The 3 gates are clearly distinguished from agent-level questions in all documentation
- [ ] Authority boundaries in conflict-resolution.md match what skills actually claim
- [ ] No two skills perform the same type of review/analysis
- [ ] DEV_PROTOCOL section references are numbered correctly after any insertion

---

## 9. Non-Negotiable Constraints

These cannot be relaxed, regardless of feature pressure:

### Claude Code Platform Constraints

- **Bash output is buffered.** No live progress from shell commands. Design for token streaming instead.
- **ANSI colors are buggy.** Don't rely on color. Use Unicode symbols and structural formatting.
- **Subagent output is invisible until done.** Users see nothing from parallel agents until they complete. Design for wave-level progress, not step-level.
- **Context window is finite.** Phase splitting and on-demand loading are not optimizations — they are requirements.
- **Tool calls have latency.** Minimize round trips. Parallel tool calls when independent.

### Design Constraints (Self-Imposed)

- **No emoji.** Unicode symbols only. Monospace alignment, terminal aesthetic, cross-platform consistency.
- **No open-ended questions.** Every user interaction is structured with predefined options.
- **No config files.** Users don't touch configs. Preferences are asked at runtime via AskUserQuestion.
- **No templates.** Architecture is derived from constraints, not selected from a menu.
- **Protocols over guidelines.** If something is important enough to say, it's important enough to enforce.
- **Real over claimed.** Numbers, not adjectives. Verified artifacts, not agent assertions. Receipts, not promises.

---

## 10. Decision Framework

When implementing a change, run through these questions in order:

```
1. Does this strengthen a differentiator or introduce a new one?
   NO → Is it necessary for correctness?
     NO → Deprioritize. Don't build features that merely match the ecosystem.
     YES → Proceed, but keep scope minimal.

2. Does this add cognitive load to agents (new protocol, new phase, new gate)?
   YES → Is it derived from a real failure, not theory?
     NO → Don't add it. Theoretical protections cost context tokens without proven value.
     YES → Add it, but document the failure that motivated it.

3. Does this affect the user experience?
   YES → Does it add a question, a gate, or a decision point?
     YES → Strongly justify. Every interruption has a cost.
     NO → Proceed. Improvements that don't interrupt are always welcome.

4. Does this change affect all 14 agents?
   YES → Is it truly universal?
     NO → Put it in the specific skills, not a shared protocol.
     YES → Protocol it. Update all 14 skills.

5. Can this be expressed as a Common Mistakes table entry instead of a protocol/phase?
   YES → Use the table. 2 lines beats 50 lines.
```

---

## 11. Quality Checklist (Pre-Commit)

Before every commit, verify:

- [ ] All modified skill files still load all 9 protocols
- [ ] Phase numbering is consecutive and consistent (`[1/N]` through `[N/N]`)
- [ ] Version is bumped in all 4 locations (if version-worthy change)
- [ ] CHANGELOG.md is updated
- [ ] README.md reflects any user-visible changes
- [ ] No new open-ended questions introduced (all interactions use AskUserQuestion)
- [ ] All AskUserQuestion calls are engagement-mode-aware (Express gets auto-resolve, not a prompt)
- [ ] Completion summaries include concrete numbers
- [ ] Common Mistakes tables are not duplicated across skills (put shared patterns in protocols)
- [ ] New features are documented in the skill's SKILL.md, not just implemented
- [ ] Numeric claims (agent count, principle count, protocol count) match reality
- [ ] Agent() prompts in phase dispatchers align with the SKILL.md they invoke (Skill tool invocation line present)

---

## 12. For AI Agents Reading This

You are likely a Claude Code session implementing a change to this plugin. Here is what you need to know:

1. **Read VISION.md first.** It contains the 11 principles that govern everything. This document operationalizes them.
2. **Read the orchestrator** (`skills/production-grade/SKILL.md`) to understand routing, modes, and gate flow.
3. **Read the skill you're modifying** — its SKILL.md and all its phase files — before changing anything.
4. **Read the protocols** (`skills/_shared/protocols/`) that the skill loads. Your changes must not violate them.
5. **Changes propagate.** If you modify a protocol, it affects all 14 skills. If you modify the orchestrator's routing table, it affects what skills run for which requests. Think through the blast radius.
6. **Version management is manual.** When bumping versions, update all 4 locations listed in Section 4. Miss one and the install breaks.
7. **Test by installing.** After changes, copy files to `~/.claude/plugins/cache/nagisanzenin/production-grade/{version}/` and update `~/.claude/plugins/installed_plugins.json`. Then invoke the skill to verify.
8. **The user (Quan) is non-technical.** He is a product/business person. His partner is a senior engineer. Design for both: simple interactions for the user, rigorous output for the engineer.
9. **Ask before destroying.** If you're about to delete files, remove protocols, change version numbers, or modify the orchestrator — confirm with the user first.

---

*This document is the operating manual. VISION.md is the constitution. Together they govern every line of code in this project.*
