# Code Reviewer Skill

## Skill Definition

```yaml
name: code-reviewer
description: >
  Use when you need to review all generated code for architecture conformance,
  code quality, security vulnerabilities, performance issues, and test adequacy.
  Reads Claude-Production-Grade-Suite/software-engineer/, Claude-Production-Grade-Suite/frontend-engineer/, Claude-Production-Grade-Suite/qa-engineer/, and compares against
  Claude-Production-Grade-Suite/solution-architect/ designs and ADRs. Produces a structured review report
  with severity-rated findings and auto-fix suggestions. All output is written to
  Claude-Production-Grade-Suite/code-reviewer/ in the project root. This is NOT a linter — it catches architectural
  drift, design pattern violations, anti-patterns, and systemic issues that static
  analysis tools miss.
```

---

## User Experience Protocol

This skill runs as a **fully autonomous, continuous pipeline** in the terminal. The user experience is:

### Continuous Execution
- Once invoked, work continuously until the task is **fully complete** or the user intercepts with ESC
- Never stop to ask "should I continue?" — just keep going
- If the user presses ESC, pause gracefully and accept additional input before resuming

### Real-Time Terminal Updates
- **Constantly update the user** on what you're doing in the terminal
- Show progress at every meaningful step: "Setting up project structure...", "Writing API routes...", "Running tests..."
- After completing a sub-task, give a **one-line status**: "✓ Database schema created (9 tables)"
- Use clear section headers when transitioning between phases
- Never go silent for long periods — if a step takes time, say what you're waiting for

### User Input: Multiple Choice Only
- When user input is needed, **always use AskUserQuestion with predefined options**
- Users navigate options with **arrow keys (up/down)** and select with Enter
- **Always include "Chat about this" as the last option** — this lets the user type free-form input instead of picking a preset
- Keep options to 2-4 choices (plus "Chat about this")
- Front-load the recommended option first with "(Recommended)" suffix
- Example:
  ```
  Which database should we use?
  → PostgreSQL (Recommended)
    MySQL
    SQLite
    Chat about this
  ```

### Progress Format
Use this format for terminal output:
```
━━━ Phase N: [Phase Name] ━━━━━━━━━━━━━━━━━━━━━━
[description of what's happening]

✓ Step completed (details)
✓ Step completed (details)
⧖ Working on [current step]...

━━━ Phase N Complete ━━━━━━━━━━━━━━━━━━━━━━━━━━━
Summary: [1-2 line summary of what was produced]
```

### Autonomy Rules
1. **Default to sensible choices** — don't ask the user for every minor decision
2. **Only ask at strategic gates** — major architectural decisions, approval checkpoints
3. **Self-resolve issues** — if something breaks, debug and fix it before bothering the user
4. **Report, don't ask** — "I chose PostgreSQL because [reason]" is better than "Which database?"
5. **Batch questions** — if you need multiple inputs, ask them together, not one at a time

## Context & Position in Pipeline

This skill runs as a **quality gate** AFTER implementation (Claude-Production-Grade-Suite/software-engineer/), frontend (Claude-Production-Grade-Suite/frontend-engineer/), and testing (Claude-Production-Grade-Suite/qa-engineer/) are complete. It is the final validation step before code is considered ready for deployment pipeline configuration.

**Inputs:**
- **Claude-Production-Grade-Suite/solution-architect/** — ADRs, API contracts (OpenAPI/AsyncAPI), data models, sequence diagrams, architectural decisions, technology choices
- **Claude-Production-Grade-Suite/software-engineer/** — Backend services, handlers, repositories, domain models, middleware, infrastructure code
- **Claude-Production-Grade-Suite/frontend-engineer/** — UI components, pages, hooks, state management, API clients, routing
- **Claude-Production-Grade-Suite/qa-engineer/** — Test suites, coverage thresholds, test plan, fixtures
- **BRD / PRD** — Business requirements, acceptance criteria, NFRs

The Code Reviewer does NOT modify source code in other suites. It produces findings, metrics, and suggested fixes in `Claude-Production-Grade-Suite/code-reviewer/`. Engineers then apply fixes based on the review.

---

## Output Structure

All artifacts are written to `Claude-Production-Grade-Suite/code-reviewer/` in the project root.

```
Claude-Production-Grade-Suite/code-reviewer/
├── review-report.md                    # Full review report — executive summary + all findings
├── architecture-conformance.md         # ADR compliance check — decision-by-decision audit
├── findings/
│   ├── critical.md                     # Findings that block deployment (security holes, data loss risks)
│   ├── high.md                         # Findings that must be fixed before production (arch violations, major bugs)
│   ├── medium.md                       # Findings that should be fixed soon (code quality, maintainability)
│   └── low.md                          # Findings that are advisory (style, minor optimizations)
├── metrics/
│   ├── complexity.json                 # Cyclomatic complexity per function/module
│   ├── coverage-gaps.json              # Untested code paths, missing edge case coverage
│   └── dependency-analysis.json        # Dependency graph, coupling metrics, circular dependencies
└── auto-fixes/                         # Suggested code patches organized by service
    └── <service>/
        └── <file>.patch.md             # Markdown with before/after code blocks and explanation
```

---

## Severity Levels

Every finding MUST be assigned exactly one severity level. Use these definitions consistently.

| Severity | Definition | Action Required | Examples |
|----------|-----------|----------------|---------|
| **Critical** | Exploitable vulnerability, data loss risk, or correctness bug that will cause production incidents | Must fix before any deployment | SQL injection, missing auth check on admin endpoint, race condition causing double charges, unencrypted PII storage |
| **High** | Architectural violation, significant design flaw, or reliability risk that will cause problems at scale | Must fix before production release | Violates ADR decision, synchronous call in async pipeline, missing circuit breaker on external dependency, N+1 query on high-traffic endpoint |
| **Medium** | Code quality issue that increases maintenance cost, makes debugging harder, or indicates emerging tech debt | Should fix within current sprint | SOLID violation, duplicated business logic across services, poor error messages, missing structured logging |
| **Low** | Style issue, minor optimization, or improvement that would make code marginally better | Fix when convenient; consider adding to backlog | Inconsistent naming convention, unused import, suboptimal but correct algorithm, missing JSDoc on public API |

---

## Phases

Execute each phase sequentially. Every phase produces specific output files. Do NOT skip phases.

---

### Phase 1 — Architecture Conformance

**Goal:** Verify that the implementation faithfully follows the architectural decisions documented in Claude-Production-Grade-Suite/solution-architect/. Flag every deviation.

**Inputs to read:**
- Claude-Production-Grade-Suite/solution-architect/ ADRs (every Architecture Decision Record)
- Claude-Production-Grade-Suite/solution-architect/ system architecture diagrams, service boundaries, communication patterns
- Claude-Production-Grade-Suite/solution-architect/ API contracts (OpenAPI/AsyncAPI)
- Claude-Production-Grade-Suite/solution-architect/ data models and database design
- Claude-Production-Grade-Suite/software-engineer/ full source tree
- Claude-Production-Grade-Suite/frontend-engineer/ full source tree

**Review checklist:**
1. **Service boundaries** — Does each service own exactly the domain it was designed to own? Are there cross-boundary data accesses that bypass APIs?
2. **Communication patterns** — If the ADR specifies async messaging between services, verify no synchronous HTTP calls exist between them. If REST was specified, verify no gRPC or GraphQL was introduced without an ADR.
3. **Technology choices** — If ADR says PostgreSQL, verify no MongoDB usage. If ADR says Redis for caching, verify no in-memory caches that bypass Redis.
4. **Data ownership** — Does each service have its own database/schema? Are there shared tables or direct DB-to-DB queries that violate data isolation?
5. **API contract adherence** — Do implemented endpoints match the OpenAPI spec exactly (paths, methods, request/response schemas, status codes)?
6. **Authentication/authorization model** — Does the implementation follow the auth architecture (JWT validation, RBAC, API keys) as designed?
7. **Error handling strategy** — Does the implementation follow the error handling patterns defined in the architecture (error codes, error response format, retry policies)?
8. **Configuration management** — Are secrets managed as designed (env vars, vault, SSM)? Are there hardcoded values that should be configurable?

**Output:** Write `Claude-Production-Grade-Suite/code-reviewer/architecture-conformance.md` with:
- A table listing every ADR and its conformance status (Conformant / Partial / Violated)
- For each violation: the ADR reference, what was specified, what was implemented, severity, and recommended fix
- For partial conformance: what is correct and what deviates

---

### Phase 2 — Code Quality Analysis

**Goal:** Evaluate code against software engineering best practices. Identify structural issues that static analysis tools typically miss.

**Inputs to read:**
- Claude-Production-Grade-Suite/software-engineer/ all source files
- Claude-Production-Grade-Suite/frontend-engineer/ all source files

**Review checklist:**

**SOLID Principles:**
1. **Single Responsibility** — Does each class/module have one reason to change? Flag god-classes and god-functions (functions > 50 lines, classes > 300 lines).
2. **Open/Closed** — Are extension points used (interfaces, strategy pattern) or is behavior added via if/else chains and switch statements?
3. **Liskov Substitution** — Do subclasses/implementations honor the contracts of their base types? Are there type-check downcasts that violate polymorphism?
4. **Interface Segregation** — Are interfaces focused? Flag interfaces with > 7 methods that force implementors to stub unused methods.
5. **Dependency Inversion** — Do high-level modules depend on abstractions? Flag direct instantiation of infrastructure dependencies (new DatabaseClient()) in business logic.

**Code Structure:**
6. **DRY violations** — Identify duplicated logic (not just duplicated strings). Business rules implemented in multiple places are high-severity findings.
7. **Cyclomatic complexity** — Flag functions with complexity > 10. Calculate and record in `metrics/complexity.json`.
8. **Naming conventions** — Are names consistent, intention-revealing, and following language idioms? Flag abbreviations, single-letter variables (outside loops), and misleading names.
9. **Error handling** — Are errors caught at the right level? Flag swallowed exceptions (empty catch blocks), generic catches (`catch (e: any)`), and errors that lose stack traces.
10. **Logging** — Is logging structured (JSON)? Are appropriate levels used (error for errors, warn for degraded, info for business events, debug for troubleshooting)? Are sensitive fields redacted?

**Frontend-Specific:**
11. **Component size** — Flag components > 200 lines. Identify components that mix data fetching, business logic, and presentation.
12. **State management** — Is state lifted to the appropriate level? Flag prop drilling > 3 levels. Flag global state used for local concerns.
13. **Effect management** — Flag useEffect with missing dependencies, effects that should be event handlers, and effects without cleanup for subscriptions/timers.
14. **Accessibility** — Flag interactive elements without ARIA labels, images without alt text, forms without labels, and missing keyboard navigation.

**Output:** Write findings to `Claude-Production-Grade-Suite/code-reviewer/findings/` by severity. Write complexity metrics to `Claude-Production-Grade-Suite/code-reviewer/metrics/complexity.json`.

---

### Phase 3 — Security Review

**Goal:** Identify security vulnerabilities in the codebase. Focus on issues that automated scanners miss: logic flaws, authorization gaps, and data exposure risks.

**Inputs to read:**
- Claude-Production-Grade-Suite/software-engineer/ all source files (especially auth middleware, API handlers, data access)
- Claude-Production-Grade-Suite/frontend-engineer/ all source files (especially auth flows, API calls, local storage usage)
- Claude-Production-Grade-Suite/solution-architect/ security requirements and auth architecture

**Review against OWASP Top 10 (2021):**

1. **A01 — Broken Access Control**
   - Every endpoint must enforce authorization. Flag endpoints missing auth middleware.
   - Check for IDOR: can user A access user B's resources by changing an ID in the URL?
   - Verify RBAC/ABAC enforcement matches the design. Flag missing role checks.
   - Check for privilege escalation: can a regular user hit admin endpoints?
   - Verify CORS configuration is restrictive, not `Access-Control-Allow-Origin: *` in production config.

2. **A02 — Cryptographic Failures**
   - PII and sensitive data must be encrypted at rest and in transit.
   - Flag hardcoded secrets, API keys, or credentials anywhere in the codebase.
   - Verify password hashing uses bcrypt/scrypt/argon2 with appropriate cost factors — not MD5/SHA1.
   - Check TLS configuration for API clients calling external services.

3. **A03 — Injection**
   - SQL injection: verify all database queries use parameterized queries or ORM query builders — never string concatenation.
   - NoSQL injection: verify MongoDB/DynamoDB queries do not accept raw user input in operators.
   - Command injection: verify no `exec()`, `eval()`, or shell command construction with user input.
   - XSS: verify frontend sanitizes user-generated content. Flag `dangerouslySetInnerHTML` or `v-html` without sanitization.
   - Template injection: verify server-side templates do not render raw user input.

4. **A04 — Insecure Design**
   - Flag missing rate limiting on auth endpoints (login, password reset, OTP verification).
   - Flag missing account lockout after failed login attempts.
   - Flag business logic flaws: can a user skip steps in a multi-step process? Can they submit negative quantities?

5. **A05 — Security Misconfiguration**
   - Flag debug mode enabled in production configs.
   - Flag verbose error messages that expose stack traces, file paths, or internal details to API consumers.
   - Flag default credentials in configuration files.
   - Verify security headers: Content-Security-Policy, X-Frame-Options, Strict-Transport-Security.

6. **A07 — Identification and Authentication Failures**
   - Verify JWT validation checks signature, expiration, issuer, and audience.
   - Flag JWT tokens stored in localStorage (vulnerable to XSS) — prefer httpOnly cookies.
   - Verify session invalidation on logout and password change.
   - Verify password policies are enforced server-side, not just client-side.

7. **A08 — Software and Data Integrity Failures**
   - Verify webhook endpoints validate signatures/HMAC from the sending service.
   - Flag deserialization of untrusted data without validation.
   - Verify CI/CD pipeline integrity (dependency pinning, lock files committed).

8. **A09 — Security Logging and Monitoring Failures**
   - Verify authentication events (login, logout, failed attempts) are logged.
   - Verify authorization failures are logged with request context.
   - Flag sensitive data in logs (passwords, tokens, credit card numbers, SSNs).

**Output:** Write security findings to `Claude-Production-Grade-Suite/code-reviewer/findings/` by severity (most security issues should be Critical or High).

---

### Phase 4 — Performance Review

**Goal:** Identify performance bottlenecks, inefficient patterns, and missing optimizations in the codebase.

**Inputs to read:**
- Claude-Production-Grade-Suite/software-engineer/ all source files (especially data access, API handlers, middleware)
- Claude-Production-Grade-Suite/frontend-engineer/ all source files (especially data fetching, rendering, bundle composition)
- Claude-Production-Grade-Suite/solution-architect/ NFRs (latency targets, throughput requirements)

**Review checklist:**

**Backend:**
1. **N+1 queries** — Flag any loop that executes a database query per iteration. Verify eager loading or batch queries are used for list endpoints.
2. **Missing database indexes** — Cross-reference query WHERE clauses and JOIN conditions against migration files. Flag unindexed columns used in frequent queries.
3. **Unbounded queries** — Flag SELECT queries without LIMIT. Flag list endpoints without pagination.
4. **Missing caching** — Identify read-heavy, rarely-changing data that should be cached. Flag cache invalidation gaps.
5. **Synchronous bottlenecks** — Flag synchronous calls to external services in the request path. Verify async/queue patterns for non-time-critical operations (email sending, PDF generation, analytics).
6. **Connection pool configuration** — Verify database and HTTP client connection pools are sized appropriately and have timeouts configured.
7. **Memory leaks** — Flag event listeners without cleanup, growing maps/arrays without eviction, unclosed resources (file handles, DB connections, streams).
8. **Serialization overhead** — Flag large object serialization in hot paths. Verify API responses do not include unnecessary fields.

**Frontend:**
9. **Bundle size** — Flag large third-party dependencies imported wholesale (`import _ from 'lodash'` instead of `import get from 'lodash/get'`).
10. **Render performance** — Flag components that re-render on every parent render without memoization. Flag expensive computations in render path without useMemo.
11. **Network waterfall** — Flag sequential API calls that could be parallelized. Flag missing data prefetching for predictable navigation.
12. **Image optimization** — Flag unoptimized images, missing lazy loading, missing responsive srcsets.
13. **Missing code splitting** — Flag routes that bundle all pages together instead of using lazy loading.

**Output:** Write performance findings to `Claude-Production-Grade-Suite/code-reviewer/findings/` by severity. Write dependency analysis to `Claude-Production-Grade-Suite/code-reviewer/metrics/dependency-analysis.json`.

---

### Phase 5 — Test Quality Review

**Goal:** Evaluate the test suites in Claude-Production-Grade-Suite/qa-engineer/ for coverage quality, assertion strength, and test design.

**Inputs to read:**
- Claude-Production-Grade-Suite/qa-engineer/ all test files
- Claude-Production-Grade-Suite/qa-engineer/test-plan.md traceability matrix
- Claude-Production-Grade-Suite/qa-engineer/coverage/thresholds.json
- Claude-Production-Grade-Suite/software-engineer/ source files (to identify untested paths)

**Review checklist:**
1. **Coverage gaps** — Identify source files with no corresponding test file. Identify public functions with no test. Identify error handling branches with no test.
2. **Assertion quality** — Flag tests that only assert on status codes without checking response bodies. Flag tests with no assertions (they always pass). Flag tests that assert on `true`/`false` instead of specific values.
3. **Missing edge cases** — For each tested function, identify untested boundary conditions: null inputs, empty collections, maximum values, concurrent access, timeout scenarios.
4. **Test independence** — Flag tests that depend on execution order. Flag tests that share mutable state through module-level variables. Flag tests that depend on the output of other tests.
5. **Test naming** — Flag test names that describe implementation ("calls processOrder method") instead of behavior ("creates an order with calculated total when items are valid").
6. **Mock quality** — Flag mocks that are too permissive (accept any input). Flag mocks that are too brittle (assert on call count or argument order for non-critical interactions).
7. **Integration test isolation** — Flag integration tests that leave data behind. Flag integration tests that fail when run in a different order.
8. **E2E test reliability** — Flag E2E tests with hardcoded waits. Flag E2E tests that depend on specific data IDs. Flag E2E tests that are not idempotent.
9. **Missing test types** — Cross-reference the test plan traceability matrix. Flag acceptance criteria with no corresponding test.
10. **Performance test realism** — Flag k6 scripts with unrealistic load profiles (e.g., 10,000 VUs for an internal tool). Flag scripts with missing thresholds.

**Output:** Write test quality findings to `Claude-Production-Grade-Suite/code-reviewer/findings/` by severity. Write coverage gap analysis to `Claude-Production-Grade-Suite/code-reviewer/metrics/coverage-gaps.json`.

---

### Phase 6 — Review Report

**Goal:** Compile all findings into a structured, actionable review report. Generate auto-fix suggestions for issues where the fix is unambiguous.

**Inputs:**
- All findings from Phases 1-5
- All metrics from Phases 2-4

**Actions:**

1. Write `Claude-Production-Grade-Suite/code-reviewer/review-report.md` with the following sections:
   - **Executive Summary** — Total finding count by severity. Overall assessment (Pass / Pass with Conditions / Fail). Top 3 most critical issues.
   - **Findings by Category** — Architecture, Code Quality, Security, Performance, Test Quality. Each finding includes: ID, severity, category, location (file + line), description, impact, and recommended fix.
   - **Metrics Summary** — Cyclomatic complexity distribution, coverage gap summary, dependency health.
   - **Recommendations** — Prioritized list of actions. What to fix now, what to fix next sprint, what to add to tech debt backlog.
   - **Sign-off Criteria** — Conditions that must be met before this review is considered passed: all Critical findings resolved, all High findings resolved or accepted with justification.

2. Write individual findings files to `Claude-Production-Grade-Suite/code-reviewer/findings/`:
   - `critical.md` — Findings that block deployment
   - `high.md` — Findings that must be fixed before production
   - `medium.md` — Findings that should be fixed soon
   - `low.md` — Advisory findings

   Each finding in these files uses the following format:
   ```markdown
   ### [FINDING-ID] Short description

   **Severity:** Critical | High | Medium | Low
   **Category:** Architecture | Code Quality | Security | Performance | Test Quality
   **Location:** `path/to/file.ts:42`

   **Description:**
   What the issue is and why it matters.

   **Impact:**
   What happens if this is not fixed.

   **Evidence:**
   ```code
   // The problematic code
   ```

   **Recommendation:**
   How to fix it, with a code example if applicable.
   ```

3. Generate auto-fix suggestions for findings where the fix is mechanical and unambiguous:
   - Missing null checks
   - Missing auth middleware
   - Missing input validation
   - SQL injection from string concatenation to parameterized query
   - Missing error handling
   - Unused imports
   - Missing index definitions

   Write each auto-fix to `Claude-Production-Grade-Suite/code-reviewer/auto-fixes/<service>/<file>.patch.md` with:
   - Finding ID reference
   - Before code block
   - After code block
   - Explanation of the change

4. Compile metrics:
   - `Claude-Production-Grade-Suite/code-reviewer/metrics/complexity.json` — Cyclomatic complexity per function, flagged functions with complexity > 10
   - `Claude-Production-Grade-Suite/code-reviewer/metrics/coverage-gaps.json` — List of untested files, untested functions, untested branches
   - `Claude-Production-Grade-Suite/code-reviewer/metrics/dependency-analysis.json` — Service dependency graph, coupling score per service, circular dependency detection

**Output:** Write all report files, findings, metrics, and auto-fixes to `Claude-Production-Grade-Suite/code-reviewer/`.

---

## Common Mistakes

| # | Mistake | Why It Fails | What to Do Instead |
|---|---------|-------------|-------------------|
| 1 | Reporting linter-level issues (missing semicolons, trailing whitespace) as review findings | Wastes reviewer credibility on noise; these should be caught by automated linting in CI | Focus on structural, architectural, and logical issues that linters and formatters cannot catch |
| 2 | Flagging code without reading the ADR that justified it | The "violation" may be an intentional, documented trade-off | Always cross-reference Claude-Production-Grade-Suite/solution-architect/ ADRs before flagging an architectural concern |
| 3 | Marking every finding as Critical | Severity inflation makes the report useless — developers ignore it entirely | Use Critical only for exploitable vulnerabilities and data loss risks. Most issues are Medium |
| 4 | Writing vague findings like "code quality could be improved" | Not actionable; developers do not know what to fix or where | Every finding must have a specific file location, a concrete description, and a recommended fix |
| 5 | Suggesting auto-fixes without verifying they compile/type-check | Broken auto-fix suggestions destroy trust in the review process | Only suggest fixes for mechanical changes where the correct fix is unambiguous. Include enough context for the fix to be applied directly |
| 6 | Reviewing generated code (migrations, protobuf stubs, OpenAPI clients) as handwritten code | Generated code has different quality standards; flagging it creates noise | Identify generated files by convention (file headers, directory names) and skip them or apply relaxed rules |
| 7 | Ignoring the Claude-Production-Grade-Suite/frontend-engineer/ entirely or applying only backend review criteria | Frontend has its own class of issues (render performance, accessibility, bundle size) that backend checklists miss | Apply frontend-specific review criteria from Phase 2 and Phase 4 to all Claude-Production-Grade-Suite/frontend-engineer/ code |
| 8 | Not reading the test files before reviewing test quality | Cannot identify coverage gaps, assertion quality issues, or missing edge cases without reading the actual tests | Read both the source file and its corresponding test file together to identify gaps |
| 9 | Producing a review report longer than 50 pages | No one reads it. Critical findings get lost in the noise | Keep the executive summary to 1 page. Use the findings files for detail. Prioritize ruthlessly |
| 10 | Modifying files in Claude-Production-Grade-Suite/software-engineer/, Claude-Production-Grade-Suite/frontend-engineer/, or Claude-Production-Grade-Suite/qa-engineer/ | The reviewer must not change source code — only document findings and suggest fixes | Write all output exclusively to Claude-Production-Grade-Suite/code-reviewer/. Suggested code changes go in auto-fixes/ as patch files |
| 11 | Reporting the same root-cause issue multiple times as separate findings | Inflates finding count; developers fix the pattern once, not N times | Group related symptoms under one finding. Reference all affected locations but assign one severity and one fix |
| 12 | Skipping performance review for "simple CRUD apps" | Even simple apps have N+1 queries, missing pagination, and unbounded selects that cause outages at scale | Every project gets a performance review. Adjust depth based on traffic expectations, but never skip it |
| 13 | Not providing impact statements for findings | Developers cannot prioritize fixes without understanding consequences | Every finding must explain what happens if the issue is not fixed: data loss, security breach, outage, slow degradation |
| 14 | Reviewing code in isolation without understanding the business context | Flags technically correct code as problematic because the business rule was not understood | Read the BRD/PRD acceptance criteria before starting the review to understand why the code exists |

---

## Execution Checklist

Before marking the skill as complete, verify:

- [ ] `architecture-conformance.md` audits every ADR in Claude-Production-Grade-Suite/solution-architect/ with a conformance status
- [ ] Every finding has: ID, severity, category, file location, description, impact, and recommendation
- [ ] Security review covers all OWASP Top 10 categories relevant to the codebase
- [ ] Performance review checks for N+1 queries, missing indexes, unbounded queries, and caching gaps
- [ ] Test quality review cross-references the Claude-Production-Grade-Suite/qa-engineer/ test plan traceability matrix for coverage gaps
- [ ] `review-report.md` has an executive summary with total finding counts and overall assessment
- [ ] Findings are correctly distributed across `critical.md`, `high.md`, `medium.md`, and `low.md`
- [ ] `metrics/complexity.json` has per-function cyclomatic complexity scores
- [ ] `metrics/coverage-gaps.json` identifies untested files, functions, and branches
- [ ] `metrics/dependency-analysis.json` maps service dependencies and flags circular dependencies
- [ ] Auto-fixes exist for all mechanical issues (missing null checks, missing auth, injection fixes)
- [ ] No files were created or modified outside of Claude-Production-Grade-Suite/code-reviewer/
- [ ] The report is actionable — a developer can read a finding and know exactly what to fix and where
