# QA Engineer Skill

## Skill Definition

```yaml
name: qa-engineer
description: >
  Use when you need to create comprehensive test suites for implemented code.
  Takes implemented services from Claude-Production-Grade-Suite/software-engineer/, frontend components from
  Claude-Production-Grade-Suite/frontend-engineer/, API contracts, and BRD acceptance criteria as inputs, then
  generates production-grade test coverage including unit tests, integration tests,
  contract tests, E2E tests, performance tests, and CI test infrastructure. All
  output is written to Claude-Production-Grade-Suite/qa-engineer/ in the project root.
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

This skill runs AFTER the Software Engineer (Claude-Production-Grade-Suite/software-engineer/) and Frontend Engineer (Claude-Production-Grade-Suite/frontend-engineer/) skills have completed. It expects:

- **Claude-Production-Grade-Suite/software-engineer/** — Backend services, handlers, repositories, domain models, API route definitions
- **Claude-Production-Grade-Suite/frontend-engineer/** — UI components, pages, hooks, state management, API client calls
- **Claude-Production-Grade-Suite/solution-architect/** — API contracts (OpenAPI/AsyncAPI specs), data models, sequence diagrams
- **BRD or PRD** — Acceptance criteria, user stories, business rules, edge cases

The QA Engineer does NOT modify source code. It generates test files, test infrastructure, and test documentation that validate the implemented system against its specification.

---

## Output Structure

All artifacts are written to `Claude-Production-Grade-Suite/qa-engineer/` in the project root. Never write test files into Claude-Production-Grade-Suite/software-engineer/ or Claude-Production-Grade-Suite/frontend-engineer/ directly.

```
Claude-Production-Grade-Suite/qa-engineer/
├── test-plan.md                        # Master test plan with traceability matrix
├── unit/
│   └── <service>/                      # One folder per backend service
│       ├── handlers/
│       │   └── <handler>.test.ts       # HTTP handler / controller tests
│       ├── services/
│       │   └── <service>.test.ts       # Business logic / domain service tests
│       ├── repositories/
│       │   └── <repo>.test.ts          # Data access layer tests (mocked DB)
│       ├── validators/
│       │   └── <validator>.test.ts     # Input validation tests
│       └── mappers/
│           └── <mapper>.test.ts        # DTO / domain mapper tests
├── integration/
│   ├── docker-compose.test.yml         # Test dependency containers (Postgres, Redis, Kafka, etc.)
│   ├── setup.ts                        # Global integration test setup / teardown
│   └── <service>/
│       ├── db/
│       │   └── <repo>.integration.ts   # Real DB queries via testcontainers
│       ├── cache/
│       │   └── <cache>.integration.ts  # Real Redis / cache operations
│       ├── messaging/
│       │   └── <queue>.integration.ts  # Real message broker publish / consume
│       └── api/
│           └── <endpoint>.integration.ts  # HTTP-level integration (supertest / httptest)
├── contract/
│   ├── pacts/
│   │   ├── consumer/
│   │   │   └── <consumer>-<provider>.pact.ts  # Consumer-driven contract tests
│   │   └── provider/
│   │       └── <provider>.verify.ts           # Provider verification tests
│   ├── schema/
│   │   └── <api>.schema.test.ts               # OpenAPI schema validation tests
│   └── pact-broker.config.ts                  # Pact Broker connection config
├── e2e/
│   ├── api/
│   │   ├── flows/
│   │   │   └── <user-flow>.e2e.ts     # Multi-step API workflow tests
│   │   ├── smoke.e2e.ts               # Critical-path smoke tests
│   │   └── setup.ts                   # API E2E auth helpers, base URLs
│   └── ui/
│       ├── pages/                     # Page Object Models
│       │   └── <page>.page.ts
│       ├── flows/
│       │   └── <user-flow>.spec.ts    # Playwright / Cypress user flow specs
│       ├── visual/
│       │   └── <component>.visual.ts  # Visual regression snapshot tests
│       └── playwright.config.ts       # Or cypress.config.ts
├── performance/
│   ├── load-tests/
│   │   └── <scenario>.k6.js           # k6 load test scripts (sustained load)
│   ├── stress-tests/
│   │   └── <scenario>.k6.js           # k6 stress test scripts (breaking point)
│   ├── spike-tests/
│   │   └── <scenario>.k6.js           # k6 spike test scripts (sudden burst)
│   ├── baselines/
│   │   └── <scenario>.baseline.json   # Expected p50/p95/p99 latency, throughput
│   └── thresholds.js                  # Shared k6 threshold definitions
├── fixtures/
│   ├── factories/
│   │   └── <entity>.factory.ts        # Test data factories (fishery / factory-girl pattern)
│   ├── seed-data/
│   │   ├── <entity>.seed.json         # Static seed data for integration / E2E
│   │   └── seed-runner.ts             # Script to load seed data into test DBs
│   └── mocks/
│       ├── <external-api>.mock.ts     # External API mock servers (MSW / nock)
│       └── <service>.stub.ts          # Internal service stubs
├── coverage/
│   └── thresholds.json                # Per-service and global coverage gates
└── ci-test-config.yml                 # CI pipeline test stage configuration
```

---

## Phases

Execute each phase sequentially. Do NOT skip phases. Each phase builds on the outputs of the previous one.

---

### Phase 1 — Test Planning

**Goal:** Produce a traceability matrix linking every BRD acceptance criterion to concrete test cases, categorized by test type.

**Inputs to read:**
- BRD / PRD acceptance criteria (every GIVEN/WHEN/THEN or equivalent)
- Claude-Production-Grade-Suite/solution-architect/ API contracts (OpenAPI specs, AsyncAPI specs)
- Claude-Production-Grade-Suite/solution-architect/ data models and sequence diagrams
- Claude-Production-Grade-Suite/software-engineer/ service structure (list all services, handlers, repos)
- Claude-Production-Grade-Suite/frontend-engineer/ component and page structure

**Actions:**
1. Extract every acceptance criterion and assign a unique ID (AC-001, AC-002, ...).
2. For each criterion, determine which test types are required (unit, integration, contract, e2e, performance).
3. Identify all services, modules, and components that need test coverage.
4. Identify all external dependencies that require mocking or test containers.
5. Identify critical user flows for E2E coverage.
6. Identify performance-sensitive endpoints for load testing.
7. Define coverage thresholds per service (lines, branches, functions).

**Output:** Write `Claude-Production-Grade-Suite/qa-engineer/test-plan.md` with the following sections:
- **Scope** — What is being tested, what is explicitly out of scope
- **Test Strategy** — Test pyramid approach, which test types cover which risk areas
- **Traceability Matrix** — Table mapping AC-ID to test case IDs, test type, and priority
- **Environment Requirements** — Containers, external services, env vars needed
- **Coverage Targets** — Per-service and global coverage gates
- **Risk Register** — Areas with high complexity or insufficient testability

---

### Phase 2 — Unit Tests

**Goal:** Test each service's business logic, handlers, and repositories in isolation with full mocking of external dependencies.

**Inputs to read:**
- Claude-Production-Grade-Suite/software-engineer/ source code for each service
- The test plan from Phase 1

**Rules:**
1. One test file per source file. Mirror the source directory structure under `Claude-Production-Grade-Suite/qa-engineer/unit/<service>/`.
2. Mock ALL external dependencies: databases, caches, message brokers, HTTP clients, other services.
3. Use dependency injection or module mocking — never patch globals.
4. Test the happy path, error paths, edge cases, and boundary values for every public function.
5. For handlers/controllers: test request parsing, validation error responses, correct status codes, response body shape.
6. For services/domain logic: test business rule enforcement, state transitions, calculation correctness.
7. For repositories: test query construction, parameter binding, result mapping (with mocked DB driver).
8. For validators: test every validation rule, including null, empty, boundary, and malformed inputs.
9. Every test must have a descriptive name that reads as a specification: `it("should return 404 when order does not exist for the given user")`.
10. Use factories from `Claude-Production-Grade-Suite/qa-engineer/fixtures/factories/` for test data — never inline large object literals.
11. Assert on specific values, not just truthiness. Prefer `toEqual` over `toBeTruthy`.
12. Test error types and messages, not just that an error was thrown.

**Output:** Write test files to `Claude-Production-Grade-Suite/qa-engineer/unit/<service>/`.

Also write factories to `Claude-Production-Grade-Suite/qa-engineer/fixtures/factories/` as you discover entity shapes.

---

### Phase 3 — Integration Tests

**Goal:** Test service interactions with real dependencies using testcontainers or docker-compose.

**Inputs to read:**
- Claude-Production-Grade-Suite/software-engineer/ database migrations, schemas, connection configs
- Claude-Production-Grade-Suite/solution-architect/ infrastructure requirements (which DBs, caches, brokers)
- The test plan from Phase 1

**Rules:**
1. Write `Claude-Production-Grade-Suite/qa-engineer/integration/docker-compose.test.yml` with containers for every real dependency (PostgreSQL, Redis, Kafka, Elasticsearch, etc.). Pin exact image versions.
2. Write `Claude-Production-Grade-Suite/qa-engineer/integration/setup.ts` with global before/after hooks: start containers, run migrations, seed base data, tear down after suite.
3. Each integration test file connects to real containers — no mocks for the dependency under test.
4. Test actual SQL queries against a real database with realistic data volumes (not just 1 row).
5. Test cache read/write/eviction with a real Redis instance.
6. Test message publishing and consumption with a real broker.
7. Test API endpoints with real HTTP calls (supertest / httptest) against a running server.
8. Each test must clean up its own data. Use transactions with rollback, or truncate tables in afterEach.
9. Tests must be parallelizable — use unique identifiers to avoid cross-test data collisions.
10. Test failure modes: connection timeouts, constraint violations, concurrent writes, deadlocks.

**Output:** Write test files to `Claude-Production-Grade-Suite/qa-engineer/integration/<service>/`.

Write `docker-compose.test.yml` and `setup.ts` to `Claude-Production-Grade-Suite/qa-engineer/integration/`.

---

### Phase 4 — Contract Tests

**Goal:** Verify API consumers and providers agree on request/response schemas and that implementations conform to OpenAPI specifications.

**Inputs to read:**
- Claude-Production-Grade-Suite/solution-architect/ OpenAPI specs and AsyncAPI specs
- Claude-Production-Grade-Suite/software-engineer/ API route definitions, request/response DTOs
- Claude-Production-Grade-Suite/frontend-engineer/ API client calls and expected response shapes

**Rules:**
1. For each API consumer (frontend, other services), write a Pact consumer test that defines the expected interactions.
2. For each API provider, write a Pact provider verification test that replays consumer expectations against the real provider.
3. Write schema validation tests that load the OpenAPI spec and validate every endpoint's actual response against the schema.
4. Test backward compatibility: if there are versioned APIs, verify old consumers still work with new providers.
5. For async APIs (events, messages), write contract tests for message schemas using AsyncAPI specs.
6. Configure Pact Broker connection in `pact-broker.config.ts` (even if the broker URL is a placeholder).
7. Contract tests must fail if a required field is removed, a type changes, or a new required field is added without consumer agreement.

**Output:** Write contract tests to `Claude-Production-Grade-Suite/qa-engineer/contract/`.

---

### Phase 5 — E2E Tests

**Goal:** Test critical user flows end-to-end through the full stack.

**Inputs to read:**
- BRD / PRD user stories and acceptance criteria (especially the critical path)
- Claude-Production-Grade-Suite/frontend-engineer/ pages and navigation flow
- Claude-Production-Grade-Suite/software-engineer/ API endpoints
- The test plan from Phase 1 (critical user flows identified)

**Rules:**
1. Identify the 5-10 most critical user flows (signup, login, core CRUD, payment, etc.).
2. For API E2E: chain multiple API calls that represent a complete user journey. Use real auth tokens. Validate side effects (DB state, emails sent, events published).
3. For UI E2E: use Page Object Model pattern. Each page gets a class in `Claude-Production-Grade-Suite/qa-engineer/e2e/ui/pages/`.
4. UI tests must use resilient selectors: `data-testid` attributes, ARIA roles — never CSS classes or DOM structure.
5. Write a smoke test suite (`smoke.e2e.ts`) that covers the absolute minimum "is the app alive" checks. This runs on every deploy.
6. E2E tests must be idempotent — running them twice produces the same result.
7. Include setup/teardown that creates test users, seeds required data, and cleans up after.
8. Add explicit waits for async operations — never use arbitrary `sleep()` calls.
9. For visual regression: capture screenshots of key pages and compare against baselines.
10. Configure test timeouts generously (30s+ per test) — E2E is slow by nature.

**Output:** Write E2E tests and page objects to `Claude-Production-Grade-Suite/qa-engineer/e2e/`. Write Playwright or Cypress config.

---

### Phase 6 — Performance Tests

**Goal:** Establish performance baselines and create load/stress test scripts for performance-sensitive endpoints.

**Inputs to read:**
- Claude-Production-Grade-Suite/solution-architect/ NFRs (latency targets, throughput requirements, SLOs)
- Claude-Production-Grade-Suite/software-engineer/ API endpoints (especially high-traffic ones)
- The test plan from Phase 1 (performance-sensitive areas)

**Rules:**
1. Write k6 scripts (JavaScript). Each script targets a specific scenario (e.g., "user browsing products", "checkout flow under load").
2. Load tests: simulate sustained normal traffic. Define realistic ramp-up patterns (e.g., 0 -> 100 VUs over 2 min, hold 10 min, ramp down).
3. Stress tests: find the breaking point. Ramp VUs aggressively until error rate exceeds 5% or p99 exceeds SLO.
4. Spike tests: simulate sudden traffic bursts (0 -> 500 VUs in 10 seconds).
5. Define thresholds in each script: `http_req_duration['p(95)'] < 500`, `http_req_failed < 0.01`.
6. Write baseline JSON files that record expected performance under normal load. CI compares against these.
7. Use realistic test data — not the same request repeated. Parameterize with CSV data files or k6 SharedArray.
8. Include authentication in test scripts (token generation, session management).
9. Test both read-heavy and write-heavy endpoints separately.
10. Add custom metrics for business-critical operations (e.g., `order_processing_time`).

**Output:** Write k6 scripts to `Claude-Production-Grade-Suite/qa-engineer/performance/`. Write baseline files to `Claude-Production-Grade-Suite/qa-engineer/performance/baselines/`.

---

### Phase 7 — Test Infrastructure

**Goal:** Configure CI test execution, coverage enforcement, and test reliability tooling.

**Inputs to read:**
- All test files generated in Phases 2-6
- Coverage thresholds from the test plan
- Project CI/CD system (GitHub Actions, GitLab CI, etc.)

**Actions:**
1. Write `Claude-Production-Grade-Suite/qa-engineer/coverage/thresholds.json` with per-service and global coverage gates:
   ```json
   {
     "global": { "lines": 80, "branches": 75, "functions": 80, "statements": 80 },
     "services": {
       "<service-name>": { "lines": 85, "branches": 80, "functions": 85, "statements": 85 }
     }
   }
   ```
2. Write `Claude-Production-Grade-Suite/qa-engineer/ci-test-config.yml` with:
   - **Unit test stage** — runs first, fast, no containers. Fails fast on coverage threshold breach.
   - **Integration test stage** — starts docker-compose dependencies, runs integration suite, tears down.
   - **Contract test stage** — runs Pact tests, publishes results to broker.
   - **E2E test stage** — deploys to test environment, runs smoke + full E2E suite.
   - **Performance test stage** — runs load tests against staging, compares to baselines.
   - Parallel execution: split unit and integration tests across multiple CI runners by service.
   - Test result artifacts: JUnit XML reports, coverage HTML reports, k6 JSON results.
   - Flaky test detection: track test pass/fail history, quarantine tests with >5% flake rate.
   - Retry policy: retry failed E2E tests up to 2 times before marking as failed.
3. Write seed data runner to `Claude-Production-Grade-Suite/qa-engineer/fixtures/seed-data/seed-runner.ts`.
4. Write external API mock configurations to `Claude-Production-Grade-Suite/qa-engineer/fixtures/mocks/`.

**Output:** Write CI config and coverage thresholds to `Claude-Production-Grade-Suite/qa-engineer/`.

---

## Common Mistakes

| # | Mistake | Why It Fails | What to Do Instead |
|---|---------|-------------|-------------------|
| 1 | Writing tests inside Claude-Production-Grade-Suite/software-engineer/ or Claude-Production-Grade-Suite/frontend-engineer/ | Pollutes source directories; violates pipeline separation | Always write to `Claude-Production-Grade-Suite/qa-engineer/` exclusively |
| 2 | Testing implementation details instead of behavior | Tests break on every refactor, providing no safety net | Test public interfaces, inputs, and outputs — not private methods or internal state |
| 3 | Using `any` type or skipping type assertions in test mocks | Mocks drift from real interfaces silently; tests pass but code is broken | Type mocks against the real interface; use `jest.Mocked<typeof RealService>` or equivalent |
| 4 | Sharing mutable state between tests | Tests pass in isolation but fail when run together; order-dependent results | Reset state in beforeEach; use factory functions that return fresh instances |
| 5 | Hardcoding connection strings, ports, or URLs in test files | Tests break in CI, on other machines, or when container ports change | Use environment variables with sensible defaults; read from docker-compose labels |
| 6 | Writing integration tests that mock the dependency under test | You are just writing unit tests with extra steps; real bugs slip through | If testing DB queries, use a real database. If testing cache, use real Redis. Mock only the things NOT under test |
| 7 | E2E tests that depend on specific database IDs or auto-increment values | Tests break when seed data changes or when run against a non-empty database | Create test data as part of test setup; reference by unique business identifiers, not DB IDs |
| 8 | Performance test scripts with a single hardcoded request | Does not simulate real traffic patterns; results are misleading | Parameterize requests with varied data; simulate realistic user think-time with `sleep(Math.random() * 3)` |
| 9 | Coverage thresholds set to 100% | Encourages meaningless tests written just to hit the number; blocks legitimate PRs | Set realistic thresholds (80-85% lines, 75-80% branches); focus on critical path coverage |
| 10 | Ignoring test execution time | Slow test suites get skipped by developers; CI feedback loops become painful | Parallelize tests by service; keep unit suite under 60 seconds; keep integration suite under 5 minutes |
| 11 | Not testing error paths and failure modes | Happy-path-only tests miss the bugs that actually cause production incidents | For every success test, write at least one failure test: invalid input, timeout, auth failure, conflict |
| 12 | Writing E2E tests with `sleep()` for async waits | Flaky on slow CI runners; wastes time on fast ones | Use explicit wait-for conditions: poll for element visibility, API response, or DB state change |
| 13 | Contract tests that only check status codes | Schema changes, missing fields, and type mismatches go undetected | Validate full response body shape, field types, required fields, and enum values against the contract |
| 14 | No seed data strategy — each test creates its own world from scratch | Integration and E2E suites become extremely slow; redundant setup logic everywhere | Build a shared seed-data layer with factories and a seed runner; tests add only their unique data on top |
| 15 | Generating test files without reading the actual implementation first | Tests reference nonexistent functions, wrong parameter names, or incorrect module paths | Always read the source file before writing its test file; match imports, function signatures, and error types exactly |

---

## Execution Checklist

Before marking the skill as complete, verify:

- [ ] `test-plan.md` has a traceability matrix covering every BRD acceptance criterion
- [ ] Every service in Claude-Production-Grade-Suite/software-engineer/ has corresponding unit tests in `Claude-Production-Grade-Suite/qa-engineer/unit/`
- [ ] Every repository/data-access module has integration tests with real database containers
- [ ] Every API endpoint has at least one contract test validating its schema
- [ ] The top 5-10 critical user flows have E2E tests
- [ ] At least 3 performance-sensitive endpoints have k6 load test scripts with baselines
- [ ] `docker-compose.test.yml` defines all required test containers with pinned versions
- [ ] `coverage/thresholds.json` defines realistic per-service coverage gates
- [ ] `ci-test-config.yml` orchestrates all test stages with parallelization and artifact collection
- [ ] All test factories are in `Claude-Production-Grade-Suite/qa-engineer/fixtures/factories/` and reused across test types
- [ ] No test file has hardcoded secrets, credentials, or environment-specific values
- [ ] All tests can run independently and in any order
