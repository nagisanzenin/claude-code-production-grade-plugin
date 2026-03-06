# Visual Identity — Design Language

**Aesthetic: Sleek · Elegant · High-Tech · Informative · Dynamic**

Think mission control, not decoration. Every visual element earns its place through information, not ornament. The output should feel like watching a sophisticated system execute with precision — like observing a spacecraft launch sequence or a trading floor dashboard.

---

## Principles

### 1. Information Is the Aesthetic

Never print a line that doesn't carry information. Beauty comes from data density organized with clarity — not from borders, filler, or decoration. A well-structured metrics block is more impressive than any ASCII art.

### 2. Earned Elevation

Visual weight must match informational weight. Reserve heavy borders for genuinely important moments. If everything looks important, nothing is.

### 3. State Must Be Visible

The user should always know: where they are, what's happening now, and what's next. Anxiety comes from absence of information, not from complexity.

### 4. Concrete Over Vague

Never say "analysis complete." Say "analyzed 247 files across 3 services, 12 endpoints." Specificity is the #1 trust signal. Numbers prove the system actually did work.

### 5. Dynamic Contrast

Each section should feel visually distinct from the last. Grids for parallel status. Lists for sequential steps. Metrics blocks for summaries. Monotony kills engagement.

---

## Typography

### Case Convention

| Element | Style | Example |
|---------|-------|---------|
| Phase names | UPPERCASE | `DEFINE`, `BUILD`, `HARDEN` |
| Skill names | Title Case | `Software Engineer`, `QA Engineer` |
| Status labels | lowercase | `active`, `pending`, `complete` |
| Metrics labels | Title Case | `Services`, `Endpoints`, `Coverage` |
| Mode names | Title Case | `Wave A`, `Gate 2`, `Full Build` |

### Spacing

- **2-space indent** inside all bordered containers
- **1 blank line** between logical groups inside containers
- **No trailing decorative whitespace**
- **Consistent column alignment** — right-align numbers, left-align labels

### No Emoji

Emoji break monospace alignment, render inconsistently across terminals, and feel playful rather than technical. Use Unicode symbols exclusively — they maintain the grid and the mission-control aesthetic.

---

## Icon Vocabulary

Minimal set. Each icon has exactly one meaning.

| Icon | Meaning | Usage |
|------|---------|-------|
| `◆` | Brand mark | Pipeline header only |
| `⬥` | Gate marker | Gate ceremony headers only |
| `●` | Active / running | Agent or phase currently executing |
| `○` | Pending / queued | Agent or phase not yet started |
| `✓` | Complete / success | Step, agent, or phase finished successfully |
| `✗` | Failed / error | Step, agent, or phase failed |
| `⧖` | In progress | Active work step (inside a skill's own output) |
| `⚠` | Warning / degraded | Non-blocking issue, degraded input |
| `→` | Flow / transition | "Starting next phase", handoff indicators |
| `·` | Separator | Inline metric separation: `12 used · 22 completed` |

**Never mix icons.** `●` is always "running." `✓` is always "done." No synonyms, no alternatives.

---

## Container Hierarchy

Three tiers of visual weight. Used consistently — never mix tiers for the same importance level.

### Tier 1 — Double-Line Box `╔═╗`

**Reserved for:** Pipeline header dashboard, gate ceremonies, final summary. Maximum 3-5 uses per full pipeline run. These are the moments that matter.

```
╔══════════════════════════════════════════════════════════════╗
║  ◆ PRODUCTION GRADE v4.3                         ⏱ 12m 47s ║
║  Project: multi-vendor-marketplace                          ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║   DEFINE    ✓ complete    ⏱ 3m 12s                          ║
║   BUILD     ● active      ⏱ 1m 45s                          ║
║   HARDEN    ○ pending                                        ║
║   SHIP      ○ pending                                        ║
║   SUSTAIN   ○ pending                                        ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
```

### Tier 2 — Single-Line Box `┌─┐`

**Used for:** Wave announcements, agent status boards, intermediate status blocks. The workhorse container for structured multi-line information.

```
┌─ WAVE A ──────────────────────────────────── 7 agents ─┐
│                                                         │
│  ✓ Software Engineer    4 services, 12 endpoints        │
│  ✓ Frontend Engineer    4 page groups, 23 components    │
│  ✓ DevOps               4 Dockerfiles, 1 compose        │
│  ✓ QA Engineer          test plan: 47 test cases        │
│  ✓ Security Engineer    STRIDE: 6 threats identified    │
│  ✓ Code Reviewer        checklist: 15 checkpoints       │
│  ✓ SRE                  4 SLOs, 12 alert rules          │
│                                                         │
│  7/7 complete                                ⏱ 4m 23s   │
└─────────────────────────────────────────────────────────┘
```

### Tier 3 — Heavy Rule `━━━`

**Used for:** Phase headers, skill-level section headers, findings summaries, horizontal dividers. The lightest structural element.

```
━━━ Software Engineer ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  [1/5] Context & Architecture
    ✓ Read 4 ADRs, 3 API specs, 1 ERD
    ✓ Identified 4 services, 12 endpoints

  [2/5] Shared Foundations
    ✓ libs/shared/types — domain types, DTOs
    ✓ libs/shared/errors — error hierarchy
    ⧖ libs/shared/middleware — auth, logging, validation
    ○ libs/shared/config — env vars, secrets

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Progress Patterns

### Numbered Phases (inside each skill)

Always show position: `[current/total]`. This gives users a mental model of how far along the skill is.

```
  [3/5] Service Implementation
    ✓ auth-service — handlers, service, repository
    ✓ marketplace-service — handlers, service, repository
    ⧖ payment-service — writing handlers...
    ○ notification-service
```

### Wave Progress (orchestrator level)

Show agent count and completion status:

```
  Wave A: 5/7 agents complete                  ⏱ 2m 14s
```

### Phase Dashboard Line

Each phase gets one line in the dashboard. Three possible states:

```
  DEFINE    ✓ complete    ⏱ 3m 12s
  BUILD     ● active      ⏱ 1m 45s
  HARDEN    ○ pending
```

---

## Timing

Show elapsed time at three levels:

| Level | Position | Format |
|-------|----------|--------|
| **Total pipeline** | Dashboard header, right-aligned | `⏱ 12m 47s` |
| **Per phase** | Dashboard phase line, right-aligned | `⏱ 3m 12s` |
| **Per wave** | Wave completion box, bottom-right | `⏱ 4m 23s` |

Do NOT show timing for individual steps inside skills — that's too granular and clutters the output.

---

## Completion Summaries

When an agent finishes, it must print a structured completion line with concrete counts. This is the single most important trust signal.

### Pattern

```
  ✓ [Skill Name]    {concrete output metrics}    ⏱ Xm Ys
```

### Examples

```
  ✓ Software Engineer    4 services, 12 endpoints, 2847 lines       ⏱ 3m 41s
  ✓ Frontend Engineer    4 page groups, 23 components, 18 hooks      ⏱ 2m 58s
  ✓ Security Engineer    12 findings (2 Critical, 3 High, 7 Medium)  ⏱ 2m 05s
  ✓ QA Engineer          147 tests written, 145 passing, 2 failing   ⏱ 1m 23s
  ✓ Code Reviewer        8 findings (0 Critical, 4 High, 4 Medium)   ⏱ 1m 41s
  ✓ DevOps               4 Dockerfiles, 3 workflows, 1 compose       ⏱ 1m 12s
  ✓ SRE                  4 SLOs, 12 alerts, 3 runbooks               ⏱ 0m 54s
  ✓ Technical Writer     API ref, dev guide, ops guide (3 docs)       ⏱ 1m 33s
```

**Rule:** Every completion line must contain at least one number. No `✓ Security Engineer — complete`. That says nothing.

---

## Gate Ceremony

Gates are the most psychologically important moments — the user is being asked to make a decision. Frame them with authority.

### Structure

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ⬥ GATE 2 — Architecture Approval                  ⏱ 3m 12s
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Pattern      Modular monolith with event-driven boundaries
  Stack        TypeScript · NestJS · PostgreSQL · Redis
  Services     4 bounded contexts
  API          REST (OpenAPI 3.1) + WebSocket for real-time
  ADRs         4 architecture decision records
  Endpoints    12 defined across 3 specs

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Metrics block:** Left-aligned labels, 5+ space gap, then values. This columnar layout is easy to scan and feels like a technical spec sheet — exactly the right psychology for a decision point.

---

## Transition Announcements

When moving between phases or starting/ending waves, print a concise transition line:

```
  → Starting BUILD phase (Wave A: 7 agents)
  → Wave A complete, starting Wave B (4 agents against written code)
  → HARDEN complete, 3 Critical findings → entering remediation
  → All phases complete, presenting final summary
```

Always use `→` prefix. Always state what's next. This eliminates "what's happening?" anxiety.

---

## Findings & Metrics Blocks

For security/QA/review findings, use a severity grid:

```
  Critical   2    SQL injection in user input handler
                  Hardcoded API key in config.ts
  High       5    Missing rate limiting (3), broken auth check (2)
  Medium     8    —
  Low        3    —
  ─────────────
  Total     18    deduplicated by file:line
```

The indented detail under Critical/High and the `—` for lower severities creates visual hierarchy. Users scan the top, glance past the bottom.

---

## Before/After Patterns

For remediation and any transformation, show the delta:

```
  Security:  12 findings → 0 Critical, 0 High remaining
  QA:        147 tests, 2 failing → 147 passing (100%)
  Coverage:  0% → 94% line coverage
```

The `→` arrow between states is the most compelling visual proof that work was done. Use it everywhere a transformation occurred.

---

## Anti-Patterns — Never Do These

| Anti-Pattern | Why It Fails | Do Instead |
|-------------|-------------|-----------|
| Empty boxes with only a title | Decoration without information | Only draw a box if it contains data |
| `✓ Analysis complete` | Says nothing — what analysis? what result? | `✓ Analyzed 247 files, found 12 issues` |
| Repeated identical separators | Monotonous, user stops reading | Vary between Tier 1/2/3 containers |
| Timing on every single step | Clutters output, nobody cares about 0.3s | Time phases, waves, totals only |
| Emoji for status | Breaks monospace grid, inconsistent rendering | Unicode symbols from the icon vocabulary |
| ALL CAPS for status text | Feels like shouting | Uppercase for phase names only |
| Box inside a box | Visual noise, hard to parse | One container level per context |
| Decorative ASCII art / logos | Takes space, adds no information | The data IS the aesthetic |

---

## The Complete Visual Rhythm (Full Build)

A full pipeline run should feel like this visual journey:

```
1. ╔═══╗  Pipeline Dashboard (grand opening — sets expectations)
2.          → Phase transition announcement
3. ━━━     PM skill output with [1/N] progress
4.          Gate 1 ceremony (decision moment)
5. ━━━     Architect skill output with [1/N] progress
6.          Gate 2 ceremony (decision moment)
7. ╔═══╗  Pipeline Dashboard (updated — DEFINE complete, BUILD active)
8. ┌───┐  Wave A announcement (here's what's launching)
9.          ...agents working autonomously...
10. ┌───┐  Wave A completion (every agent's concrete results)
11.         → Transition to Wave B
12. ┌───┐  Wave B announcement
13.         ...agents working...
14. ┌───┐  Wave B completion
15. ╔═══╗  Pipeline Dashboard (updated — HARDEN complete)
16. ━━━    Findings summary (severity grid)
17.         → Transition to SHIP
18. ┌───┐  Ship agents completion
19.         Gate 3 ceremony (final decision)
20. ╔═══╗  Pipeline Dashboard (updated — all complete)
21. ┌───┐  SUSTAIN agents completion
22. ╔═══╗  Final Summary (grand finale — the payoff)
```

Notice the rhythm: **heavy → light → light → heavy → light → light → heavy**. The double-line boxes punctuate the experience at key moments. Single-line boxes carry the middle. Heavy rules handle skill-level detail. The user never sees the same visual pattern twice in a row.

---

## Streaming as Animation

Claude Code streams text output token-by-token. This is our only animation channel — and it's enough.

When Claude prints a pipeline dashboard, the user watches it build line by line. When a wave completes and Claude prints the checkmark cascade, each `✓` appears in sequence. When the final summary renders, the double-line box draws itself before the user's eyes.

Design every visual block for streaming consumption:

- Put the most important information on the first lines (the user sees these first)
- Group related items so they stream as a visual unit
- The checkmark cascade after parallel waves is the peak visual moment — don't dilute it with filler
- The pipeline dashboard re-rendering at each transition IS the progress animation — same template, different state

We don't need spinners or ANSI cursor tricks. Structured information that changes state across renders is more impressive than any animation.
