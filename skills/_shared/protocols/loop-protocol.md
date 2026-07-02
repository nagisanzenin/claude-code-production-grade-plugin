# Loop Protocol — Oracle-Driven Iteration

**Core principle: NO ORACLE, NO LOOP. A loop is defined by its exit condition, not its participants. Never iterate without an executable check that decides "done"; never let the producer of work also control the check that judges it.**

Iteration is the main path, not the exception path. But an unguarded loop is worse than one pass — it burns tokens, risks regressions, and terminates on self-approval. Every loop follows this protocol.

---

## Rule 1: The Oracle Hierarchy

Every loop exits on an oracle. Prefer the highest tier available:

| Tier | Oracle type | Examples | May terminate a loop? |
|------|-------------|----------|----------------------|
| 1 — Executable | Machine-checkable, binary | compile, typecheck, test suite, lint, contract validation, e2e driver, screenshot diff | Yes — gold standard |
| 2 — Adversarial judgment | Independent critic told to REFUTE | code review verdict, security assessment | Yes, only with a critic that did not produce the work |
| 3 — Self-check | Producer inspects own output | re-read, self-review | Never terminates a loop on its own |

If no Tier 1-2 oracle exists for a task, your FIRST move is to build one (write the failing test, the repro script, the contract check) — or escalate. Iterating on self-judgment is forbidden.

An oracle you cannot EXECUTE (missing checker, no runtime, no Docker, offline) is not green — it is **UNVERIFIED**. Record it as unverified and escalate; never treat "could not run the check" as "the check passed."

## Rule 2: The Loop Contract

Before opening any loop, state its contract (in your working notes or the loop ledger):

```yaml
loop:
  goal:     one sentence
  producer: who does the work
  oracle:   the executable check (or 2 independent judges)
  delta:    what feeds back per iteration — failing output ONLY, never full history
  ratchet:  metric that must never regress (failing tests, type errors, open Critical findings)
  budget:   max iterations + plateau threshold (default: plateau after 2 no-progress rounds)
  exit:     converged | plateau | oscillation | budget → escalation target
```

## Rule 3: Convergence Guards

| Guard | Rule |
|-------|------|
| **Ratchet** | Track the metric against a BASELINE snapshot, not the previous iteration. A real fix can transiently *raise* the count (fixing an import error reveals 10 genuine test failures that were hidden behind it) — that is progress, not regression. Regression = worse than baseline once the change settles; on a true regression, revert the iteration (worktree/git checkpoint) and try differently. |
| **Plateau** | No ratchet improvement for 2 consecutive iterations → stop, escalate. Do not polish forever. |
| **Oscillation** | Same failure signature reappears after being fixed → you are cycling (fix X breaks Y, fix Y breaks X). Stop, escalate one altitude up. |
| **Hard cap** | Absolute iteration caps are backstops, not targets. Exit on convergence or plateau first. Defaults: inner loops 5, review loops 3, remediation 3. |

## Rule 4: Oracle Immutability — Anti-Gaming

The producer inside a loop MUST NOT modify the oracle it is looping against.

- **Ownership boundaries:** the acceptance layer — the project `tests/` tree (integration, contract, e2e, performance), coverage thresholds, API contracts — is owned by the **QA Engineer**. Producers may NEVER edit, delete, skip, or weaken it (`.skip`, loosened assertions, removed cases).
- **Unit tests co-located with a producer's own code** are written by that producer as part of red-green TDD. Once green they join the ratchet: weakening a green test to admit a later change is not a fix — it goes through the review loop like any oracle change.
- If an oracle check is genuinely wrong, the producer STOPS and reports it; only the owner may change it, and every oracle change gets a diff review answering one question: "does this weaken the oracle?"
- Same for lint configs, type configs, thresholds: making the check pass by making the check weaker is a Critical violation, not a fix.
- **Impl-side gaming (the other direction):** satisfying an oracle by faking the implementation — hardcoding a test's expected output, special-casing the asserted input, stubbing a function to return the fixture — passes the check without the behavior. It is as much a violation as weakening the test. Defend with property/metamorphic tests and held-out acceptance checks the producer does not see, and task the adversarial reviewer to hunt code that is overfit to the tests.

## Rule 5: Delta-Only Feedback

Each iteration carries forward ONLY: the failing oracle output, the specific concern, and pointers to artifacts on disk. Re-read artifacts from disk (re-anchoring), do not accumulate conversation history. Fresh context per iteration beats anchored context.

## Rule 6: Escalation Ladder

On non-convergence, escalate STRATEGY, not effort — "try harder" fails the same way twice:

```
1. Same producer, next iteration (delta feedback)
2. Fresh agent, different approach (state the failed approach so it is not repeated)
3. Re-plan one altitude up (architect / orchestrator re-scopes)
4. Escalate to user with: what was tried, oracle output, ratchet trajectory
```

## Rule 7: Premade Loops

| Loop | Producer → Oracle | Exit | Where |
|------|-------------------|------|-------|
| **Inner (red-green)** | engineer → fast oracle (`oracle.sh`: typecheck+lint) after EVERY edit; tests for the unit being built | fast oracle green + unit tests green | inside every build agent |
| **TDD pair** | QA writes failing acceptance tests FIRST (oracle of record) → engineers implement against them → QA verifies tests unweakened | acceptance tests green + test-diff review clean | BUILD→HARDEN, per criterion |
| **Review** | producer → adversarial reviewer + static analysis | 0 Critical findings ∧ ratchet holds | after each work unit |
| **Integration** | merged wave output → contract tests + e2e smoke | contracts green | after every worktree merge-back |
| **Remediation** | fixer → original finding agent re-scans | 0 Critical/High, by convergence not fixed count | HARDEN/SHIP |
| **Functional drive** | driver agent exercises the RUNNING app (every button, form, link) | Dead Element Rule passes at runtime | HARDEN, before Gate 3 |
| **Debug (JIT)** | build repro oracle first → hypothesize → instrument → run → observe | repro no longer reproduces | anywhere, composed on demand |

## Rule 8: JIT Loops — The Composer Rule

For situations no premade loop covers, any agent may compose a loop by instantiating the Rule 2 contract. Constraints: the contract MUST be stated before iterating; the oracle MUST be Tier 1-2 (if none exists, build it first); the loop MUST be registered in the ledger. JIT loops follow all guards in Rules 3-6 — no new physics.

## Rule 9: Loop Ledger

Every loop writes to `Claude-Production-Grade-Suite/.orchestrator/loops/{loop-id}.md`: the contract, then one line per iteration (`iter N: {oracle result} — {ratchet value}`), then the exit reason. Receipts for looped work MUST include:

```json
"loops": [{ "id": "t3a-user-svc-redgreen", "iterations": 4, "ratchet": "9→4→1→0 failing", "exit": "converged" }]
```

Loop spend feeds the cost dashboard. An exit of `plateau|oscillation|budget` in any receipt must be surfaced at the next gate.

## Rule 10: Loop Budgets by Engagement Mode

Loops never ask the user questions — they are autonomous. Engagement mode scales their depth:

| Mode | Inner | Review rounds | Remediation cycles | Functional drive |
|------|-------|---------------|--------------------|------------------|
| Express | on | 1 | 2 | smoke (critical flows) |
| Standard | on | 2 | 3 | full |
| Thorough | on | 3 | 3 | full + edge states |
| Meticulous | on | 3 | 4 | full + edge states + visual pass |

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Looping until "it looks good" | Tier 3 never terminates a loop. Name the executable oracle first. |
| Weakening a test to make it pass | Critical violation. Report the test to its owner instead. |
| Retrying the identical approach after 2 failures | Escalate strategy (Rule 6), not effort. |
| Carrying full history into iteration N | Delta only: failing output + disk artifacts. |
| Fixed "N cycles" treated as the goal | Exit on convergence/plateau; caps are backstops. |
| Loop with no ledger entry | Unregistered loops are invisible cost. Contract + ledger, always. |
| One agent both writing and judging its own tests | Separation of duties: QA owns tests, engineers pass them. |
