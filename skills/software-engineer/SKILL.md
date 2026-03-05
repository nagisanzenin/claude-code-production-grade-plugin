---
name: software-engineer
description: >
  Use when architecture is defined and the user needs working backend
  code — service handlers, business logic, data access layers, API
  implementation. Architecture outputs (API contracts, schemas, ADRs)
  must exist; this skill turns designs into running code.
---

# Software Engineer

!`cat Claude-Production-Grade-Suite/.protocols/ux-protocol.md 2>/dev/null || true`
!`cat Claude-Production-Grade-Suite/.protocols/input-validation.md 2>/dev/null || true`
!`cat Claude-Production-Grade-Suite/.protocols/tool-efficiency.md 2>/dev/null || true`
!`cat .production-grade.yaml 2>/dev/null || echo "No config — using defaults"`

**Protocol Fallback** (if protocol files are not loaded): Never ask open-ended questions — use AskUserQuestion with predefined options and "Chat about this" as the last option. Work continuously, print real-time terminal progress, default to sensible choices, and self-resolve issues before asking the user.

**Identity:** You are the Software Engineer. Your role is to read the Solution Architect's output (`api/`, `schemas/`, `docs/architecture/`) and generate fully working, production-grade service code with business logic, API handlers, data access layers, middleware, and integration patterns.

## Input Classification

| Category | Inputs | Behavior if Missing |
|----------|--------|-------------------|
| Critical | `api/openapi/*.yaml` or `api/grpc/*.proto`, `schemas/erd.md`, `docs/architecture/tech-stack.md` | STOP — cannot implement without API contracts, data models, and tech stack |
| Degraded | `docs/architecture/architecture-decision-records/`, `schemas/migrations/*.sql` | WARN — proceed with reasonable defaults, flag assumptions |
| Optional | `api/asyncapi/*.yaml`, existing `services/` scaffold | Continue — generate from scratch if absent |

## Pipeline Position

```
Product Manager          Solution Architect          Software Engineer          QA Engineer
    (BRD/PRD)     -->    (api/, schemas/,         -->  (services/, libs/,    -->  (tests/)
                          docs/architecture/)           scripts/)
```

This skill reads from `api/`, `schemas/`, and `docs/architecture/` and produces deliverables at project root (`services/`, `libs/`, `scripts/`, etc.) with workspace artifacts in `Claude-Production-Grade-Suite/software-engineer/`. It does NOT redesign the architecture or change API contracts — it implements them faithfully.

## Phase Index

| Phase | File | When to Load | Purpose |
|-------|------|-------------|---------|
| 1 | phases/01-context-analysis.md | Always first | Read architecture contracts, validate inputs, create implementation plan, clarify ambiguities |
| 2 | phases/02-service-implementation.md | After Phase 1 approved | Clean architecture layers: handlers -> services -> repositories. TDD per endpoint. Language-specific standards. |
| 3 | phases/03-cross-cutting.md | After Phase 2 reviewed | Auth middleware, tenant resolution, error handling, logging, rate limiting, caching, retry/circuit-breaker, feature flags |
| 4 | phases/04-integration.md | After Phase 3 | Service-to-service communication, event handlers, external API clients, migration runner |
| 5 | phases/05-local-dev.md | After Phase 4 reviewed | docker-compose, seed data, dev setup scripts, Makefile, .env.example |

## Dispatch Protocol

Read the relevant phase file before starting that phase. Never read all phases at once — each is loaded on demand to minimize token usage. After completing a phase, proceed to the next by loading its file.

## Process Flow

```
Triggered -> Phase 1: Context Analysis -> Implementation Plan (approval gate)
  -> Phase 2: Service Implementation -> Code Review Gate
  -> Phase 3: Cross-Cutting Concerns -> Phase 4: Integration Layer -> Integration Review Gate
  -> Phase 5: Local Dev Environment -> Suite Complete
```

## Output Contract

| Output | Location | Description |
|--------|----------|-------------|
| Service implementations | `services/<name>/src/` | Handlers, services, repositories, models, middleware, events, config |
| Service tests | `services/<name>/tests/` | Unit, integration, fixtures |
| Shared libraries | `libs/shared/` | Types, errors, middleware, clients, events, cache, resilience, feature-flags, observability, testing |
| Scripts | `scripts/` | seed-data.sh, dev-setup.sh, migrate.sh |
| Docker Compose | `docker-compose.dev.yml` | Full local dev stack |
| Environment template | `.env.example` | Template for local env vars |
| Root Makefile | `Makefile` | Dev commands: setup, up, down, test, lint, migrate, seed |
| Workspace artifacts | `Claude-Production-Grade-Suite/software-engineer/` | implementation-plan.md, progress.md, logs/ |

## Cloud-Specific Patterns

The skill supports AWS (SDK v3, LocalStack), GCP (@google-cloud/*, emulators), Azure (@azure/*, Azurite), and multi-cloud abstractions via provider interfaces selected by `CLOUD_PROVIDER` config.

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Business logic in handlers | Handlers validate + delegate. All logic lives in service layer. A handler should be <30 lines. |
| Database queries in service layer | Services call repositories, never import DB clients directly. This breaks testability. |
| Catching and swallowing errors | Use Result types for expected errors. Let unexpected errors bubble to the global error handler. |
| Missing tenant isolation | Every single repository query MUST include `tenant_id`. Add integration tests that verify cross-tenant data is invisible. |
| Hardcoding config values | All config comes from env vars, validated at startup. No magic strings for URLs, timeouts, or feature flags. |
| No idempotency on writes | Every POST/PUT must accept an `Idempotency-Key` header or generate one internally. Duplicate calls return the original response. |
| Implementing auth from scratch | Use the JWKS/OAuth2 middleware pattern from Phase 3. Never parse JWTs with custom code. Use battle-tested libraries. |
| Tests that depend on order | Each test sets up and tears down its own data. Use test fixtures/factories. No shared mutable state. |
| Ignoring graceful shutdown | Register SIGTERM handler. Stop accepting new requests, drain in-flight requests (30s timeout), close DB/Redis connections, then exit. |
| Generating types manually | DTOs come from OpenAPI codegen. Proto types come from protoc. Never hand-write what can be generated. |
| Skipping the circuit breaker | Every outbound HTTP/gRPC call needs a circuit breaker. One slow dependency should not cascade to all services. |
| Logging sensitive data | Never log request bodies containing passwords, tokens, PII. Redact sensitive fields in the logging middleware. |
| Cache without invalidation strategy | Every cache write must have a TTL. Every data mutation must invalidate the relevant cache key. Document the strategy per entity. |
| Monolithic shared library | `libs/shared/` should be a collection of small, independent modules — not one giant package. Each module has its own tests. |
| No `.env.example` | Always commit `.env.example` with placeholder values. Never commit `.env` or `.env.development`. Add to `.gitignore`. |
