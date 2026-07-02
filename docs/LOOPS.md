# RFC: The Loop Engine

*Why v5.5 turns the pipeline from feed-forward-with-exceptions into oracle-driven iteration — the theory, the architecture, and where autonomy honestly ends.*

Status: **Adopted** (v5.5.0). Operational law lives in `skills/_shared/protocols/loop-protocol.md` (protocol 9 of 9); this document is the design rationale. When the two disagree, the protocol wins (authority hierarchy, DEV_PROTOCOL §8).

---

## 1. The Problem

Through v5.4 the pipeline was a feed-forward DAG — DEFINE → BUILD → HARDEN → SHIP, waves of agents handing artifacts downstream, receipts as the hand-off currency. It did have loops (gate rework, self-debug, remediation re-scan), but all of them shared four traits:

1. **Exception-driven** — they fired on rejection or failure. Real engineering iterates routinely.
2. **Fixed-count terminated** — "max 2 cycles" is a budget, not a convergence test.
3. **Judgment-verified** — receipts prove an agent *claims* done; adversarial review is still an LLM opinion. The roadmap itself admitted: "QA Engineer writes tests but doesn't always run them."
4. **Statically placed at gates** — while the Common Quality Failures table (DEV_PROTOCOL §3) shows the expensive defects live at the *seams*: cross-page 404s, N different error handlers, auth flows that only break end-to-end.

The consequence: correctness depended on human review at gates and hand-testing after delivery. That contradicts the project's own bar — "It works in production" — and its philosophy: **anything that can be agentically done, should be.**

## 2. The Core Principle

That philosophy has a precise operational form:

> **A task can be agentically closed if and only if there exists an oracle the agent can execute.**

An *oracle* is an exit condition that is not an opinion: a compiler, a type checker, a test suite, a contract validation, an e2e driver clicking the actual button. A loop without an oracle is worse than one pass — it burns tokens, risks a regression per edit, and terminates on self-approval.

Therefore the engineering program of v5.5 is **not "add loops" — it is "manufacture oracles."** Loops are just the control flow around them. Hand-testing disappears exactly when each hand-test is converted into an executable check. Every new oracle converts a human checkpoint into a loop exit condition.

Corollaries:

- **Oracle hierarchy.** Executable (Tier 1) > adversarial-judged by an independent critic (Tier 2) > self-check (Tier 3, never terminates a loop). See loop-protocol Rule 1.
- **Separation of duties.** The producer of work may not control the check that judges it. The documented failure mode — models "removing safety checks" to make output pass — is Goodhart's law applied to agents. Hence oracle immutability: engineers pass tests, QA owns tests (Rule 4).
- **Verification is cheaper than generation.** That asymmetry is why loops are profitable at all: one producer plus a cheap executable check beats N unaided attempts.

## 3. Anatomy of a Well-Formed Loop

Every loop — premade or JIT — is the same six-part contract (loop-protocol Rule 2): goal, producer, oracle, delta, ratchet, budget/exit. And every loop carries four convergence guards (Rule 3), because unguarded loops fail in known ways:

| Failure mode | Guard |
|---|---|
| Oracle gaming (weaken the test to pass it) | Oracle immutability + test-diff review by the test owner |
| Livelock (fix X breaks Y, fix Y breaks X) | Oscillation detection — repeated failure signature → halt, escalate |
| Plateau (polishing forever) | No ratchet improvement in 2 rounds → stop |
| Regression (iteration N breaks what N−1 fixed) | Per-iteration checkpoint; ratchet regression auto-reverts |

Escalation changes **strategy, not effort** (Rule 6): same producer → fresh agent with a different approach → re-plan one altitude up → user. "Try harder" fails the same way twice.

## 4. Loop Altitudes

The macro skeleton (phases, waves, artifact hand-offs, 3 gates) survives — waterfall between phases is fine when interfaces are stable. What changes is that iteration becomes the main path *inside and between* phases:

```
macro   DEFINE → BUILD → HARDEN → SHIP          gates check INTENT
          │        │        │
meso      │   TDD pair   remediation loop        seams check CORRECTNESS
          │   review     functional drive
          │   integration loop (post-merge)
          │        │        │
micro     red-green inner loop, per edit         oracle.sh, hook-enforced
```

Loop density is highest at the seams, because that is where the expensive defects live.

## 5. The Oracle Foundation (what makes it real)

Three mechanisms turn this from prose into physics:

**5.1 Oracle Bootstrap (BUILD Phase 0.5).** Before any parallel wave, the pipeline stands up the run harness and writes two project-specific scripts into the workspace:

- `Claude-Production-Grade-Suite/.orchestrator/oracle.sh` — the *fast* oracle: typecheck + lint, target < 15 s. Run after every edit.
- `Claude-Production-Grade-Suite/.orchestrator/oracle-full.sh` — the *full* oracle: test suite + build + boot smoke. Run at loop exits and phase transitions.

The bootstrap emits an **oracle inventory** receipt listing every executable check available downstream. No harness → downstream loops have nothing to execute — which is why this is a foundation step, like `libs/shared/` before parallel services. Test infrastructure is not a QA afterthought; it is the substrate every loop stands on.

**5.2 The oracle gate hook (enforcement layer).** `hooks/hooks.json` registers a `PostToolUse` hook on `Edit|Write|MultiEdit|NotebookEdit` that executes `oracle.sh` when — and only when — it exists (i.e., a production-grade pipeline is active in this project). On failure, the oracle's output is fed straight back to Claude as context. This is the plugin's own constraint "protocols over guidelines" taken to its end: the inner loop is enforced by the harness, deterministically, whether or not any prompt remembered to ask. Non-pipeline projects hit a single `[ -f ]` test and an instant no-op.

**5.3 Disk-based loop state.** Subagents are ephemeral; loops are implemented as orchestrator-driven re-invocation with delta context — each iteration is a fresh agent reading the failing oracle output plus artifacts from disk (`.orchestrator/loops/{id}.md`). This is the re-anchoring differentiator applied per-iteration: no context drift, minimal context per attempt, loop state survives session death.

## 6. Premade Loops and the JIT Composer

The premade library (loop-protocol Rule 7) covers the known 80%: inner red-green, TDD pair, review, integration, remediation, functional drive. Two deserve emphasis:

- **TDD pair** manufactures the oracle for everything downstream. QA writes failing tests first and owns them exclusively; engineers loop red-green; QA reviews the final test diff for weakening. This upgrades the existing "TDD enforced" instruction from self-discipline to separated duties.
- **Functional drive** is the literal replacement for hand-testing. An agent drives the *running* application — every button clicked, every form submitted, every link followed (Playwright/browser MCP when available; HTTP/CLI probing as fallback). The Dead Element Rule stops being reviewed and starts being executed.

For the long tail, any agent may compose a **JIT loop** — but only by instantiating the standard contract (Rule 8). The composer rule is the discipline that keeps JIT from becoming token-burning wander: *no oracle, no loop.* If no oracle exists, the first move is to build one (a failing repro IS an oracle) or escalate. JIT loops get no new physics — same guards, same ledger.

## 7. Ledger, Receipts, and Gates

Receipts prove work was *done*; loop receipts prove work *converged*. Every loop registers a contract and per-iteration trajectory in `.orchestrator/loops/`, and completed receipts carry a `loops` array (Rule 9) that feeds the cost dashboard. A loop that exited on `plateau|oscillation|budget` is surfaced at the next gate — non-convergence is information, never silently swallowed.

Gates change meaning, not shape. There are still exactly 3, but loops now own correctness, so gates stop doing QA and do what humans are actually for: **intent** (is this what I meant?) and **irreversibles** (ship it?). Gate metrics gain a line: loops run, convergence rate, non-converged items.

Engagement modes extend naturally: they already control question depth; now they also scale loop budgets (Rule 10). Loops ask nothing — deeper autonomy requires more internal verification, not more interruptions, so this strengthens the zero-open-ended-questions stance.

## 8. Where Autonomy Honestly Ends

Two carve-outs keep the philosophy from overclaiming:

1. **No-oracle judgments** — aesthetics, product intent, "is this what I meant." Tier 2 judge loops narrow these; they cannot close them.
2. **Irreversible externalities** — production deploys, spending, live-data migration.

Everything else — correctness, integration, security, functional completeness — is oracle-closable, therefore agentically closable. Refined philosophy: **agents own everything with an oracle; humans own intent and irreversibles.** The 3 gates already sit at exactly those points, which is why this RFC changes no gate.

## 9. Design Decisions (mini-ADRs)

| Decision | Choice | Because |
|---|---|---|
| Oracle scripts generated per-project by the pipeline, not shipped in the plugin | `oracle.sh` written at BUILD Phase 0.5 | A shell script cannot know every stack; the LLM writes it once with full project context. The hook stays a dumb executor. |
| Hook fires only when `oracle.sh` exists | single file test | Plugin is installed globally; must be a no-op outside active pipelines. |
| Fixed caps kept as backstops | convergence-first, caps second | Convergence detection can be wrong once; caps bound the damage. |
| QA owns tests exclusively | separation of duties | Anti-Goodhart. The producer must not control its own oracle. |
| Loops never prompt the user | budgets via engagement mode | Preserves the 3-gate UX contract; autonomy is the product. |
| JIT loops constrained to the standard contract | composer rule | Creativity in *where* to loop, never in *whether* guards apply. |

## 10. Grounding

The shape of this design is not novel — it is the industrial consensus imported into agent space: closed-loop control needs a sensor, a setpoint, and stability guards (control theory); CI exists because "the dev said it works" is not evidence; actor-critic separation exists because generators are poor judges of their own output; Goodhart's law is why the metric owner and the metric optimizer must be different parties. v5.5's contribution is wiring these into a prompt-ware pipeline: oracles as generated artifacts, enforcement as hooks, loop state as disk, convergence as protocol.

---

*Companion documents: `loop-protocol.md` (operational law, loaded by every agent), DEV_PROTOCOL.md §7 (self-healing bounds, now convergence-based), `docs/PUBLISHING.md` (how this ships).*
