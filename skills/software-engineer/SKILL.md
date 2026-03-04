---
name: software-engineer
description: Use when implementing business logic, service handlers, data access layers, or turning architecture scaffolds into working code. Triggers on "implement the services", "write the business logic", "build the handlers", "implement the API", "code the backend", "implement from architecture", "write the services", or when a Claude-Production-Grade-Suite/solution-architect/ exists and the next step is actual code implementation.
---

# Software Engineer

## Overview

Production-grade service implementation engine: reads the Solution Architect's output (`Claude-Production-Grade-Suite/solution-architect/`) and generates fully working service code with business logic, API handlers, data access layers, middleware, and integration patterns. Generates an `Claude-Production-Grade-Suite/software-engineer/` folder in the project root containing production-ready service implementations following clean architecture, dependency injection, repository pattern, and cloud-native best practices.

## When to Use

- Implementing services after a Solution Architect has produced `Claude-Production-Grade-Suite/solution-architect/`
- Writing API handlers, business logic, and data access layers from API contracts
- Building middleware (auth, logging, rate limiting, caching)
- Creating service-to-service communication and integration layers
- Setting up local development environments with Docker Compose and seed data
- Implementing cross-cutting concerns (retry, circuit breaker, feature flags, multi-tenancy)
- Turning OpenAPI/gRPC/AsyncAPI specs into working service code

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

## Pipeline Position

```
Product Manager          Solution Architect          Software Engineer          QA Engineer
    (BRD/PRD)     -->    (Claude-Production-Grade-Suite/solution-architect/)  -->  (Claude-Production-Grade-Suite/software-engineer/)  -->  (Tests/QA)
                         API contracts, schemas,          Working services,             Test suites,
                         ADRs, scaffold                   business logic,               coverage,
                                                          data access                   validation
```

This skill reads from `Claude-Production-Grade-Suite/solution-architect/` and produces `Claude-Production-Grade-Suite/software-engineer/`. It does NOT redesign the architecture or change API contracts — it implements them faithfully.

## Process Flow

```dot
digraph se {
    rankdir=TB;
    "Triggered" [shape=doublecircle];
    "Phase 1: Context Analysis" [shape=box];
    "Implementation Plan" [shape=diamond];
    "Phase 2: Service Implementation" [shape=box];
    "Code Review Gate" [shape=diamond];
    "Phase 3: Cross-Cutting Concerns" [shape=box];
    "Phase 4: Integration Layer" [shape=box];
    "Integration Review" [shape=diamond];
    "Phase 5: Local Dev Environment" [shape=box];
    "Suite Complete" [shape=doublecircle];

    "Triggered" -> "Phase 1: Context Analysis";
    "Phase 1: Context Analysis" -> "Implementation Plan";
    "Implementation Plan" -> "Phase 1: Context Analysis" [label="revise"];
    "Implementation Plan" -> "Phase 2: Service Implementation" [label="approved"];
    "Phase 2: Service Implementation" -> "Code Review Gate";
    "Code Review Gate" -> "Phase 2: Service Implementation" [label="revise"];
    "Code Review Gate" -> "Phase 3: Cross-Cutting Concerns" [label="approved"];
    "Phase 3: Cross-Cutting Concerns" -> "Phase 4: Integration Layer";
    "Phase 4: Integration Layer" -> "Integration Review";
    "Integration Review" -> "Phase 4: Integration Layer" [label="revise"];
    "Integration Review" -> "Phase 5: Local Dev Environment" [label="approved"];
    "Phase 5: Local Dev Environment" -> "Suite Complete";
}
```

## Phase 1: Context Analysis

Read ALL of these from `Claude-Production-Grade-Suite/solution-architect/` before writing any code:

### 1.1 — Mandatory Inputs (Fail if Missing)

| Input | Path | What to Extract |
|-------|------|-----------------|
| Tech stack | `docs/tech-stack.md` | Language, framework, database, cache, message broker |
| API contracts | `api/openapi/*.yaml` | Endpoints, request/response schemas, auth requirements |
| gRPC contracts | `api/grpc/*.proto` | Service definitions, message types |
| Async contracts | `api/asyncapi/*.yaml` | Event schemas, channels, message formats |
| Data models | `schemas/erd.md` | Entity relationships, field types, constraints |
| Migrations | `schemas/migrations/*.sql` | Table structures, indexes, constraints |
| ADRs | `docs/architecture-decision-records/` | Architecture pattern, communication patterns, data strategy, auth, multi-tenancy |
| Scaffold structure | `scaffold/services/` | Service names, directory layout, existing boilerplate |

### 1.2 — Extract Implementation Decisions

From the ADRs, determine and document:

```markdown
## Implementation Plan

### Architecture Pattern
- [ ] Monolith / Modular Monolith / Microservices

### Communication
- [ ] REST (OpenAPI) / gRPC / Both
- [ ] Sync vs Async patterns
- [ ] Event bus technology (Kafka/RabbitMQ/SQS/Pub-Sub)

### Data Access
- [ ] ORM vs Query Builder vs Raw SQL
- [ ] Connection pooling strategy
- [ ] Read replicas / Write-read split

### Auth Pattern
- [ ] JWT validation / OAuth2 / Session-based
- [ ] RBAC / ABAC / Policy-based
- [ ] Multi-tenancy isolation level (row / schema / database)

### Services to Implement (ordered by dependency)
1. <service-name> — <purpose> — <endpoint count> — <estimated complexity>
2. ...
```

### 1.3 — Clarify Ambiguities

Use AskUserQuestion for anything not covered in the architect's output (batch into 1-2 calls max):

1. **Implementation preferences** — Specific ORM/library preferences? Existing codebase conventions?
2. **Priority ordering** — Which services are MVP-critical vs can-wait?
3. **External service accounts** — Any third-party API keys/SDKs needed? (Stripe, SendGrid, Twilio, etc.)
4. **Feature flag provider** — LaunchDarkly, Unleash, ConfigCat, or env-var based?

**Present the Implementation Plan to user via AskUserQuestion for approval before proceeding.**

## Phase 2: Service Implementation

Implement each service identified in Phase 1, one at a time, in dependency order (shared libs first, then core services, then dependent services).

### 2.1 — Service Structure

Each service in `Claude-Production-Grade-Suite/software-engineer/services/<service-name>/` follows clean architecture:

```
services/<service-name>/
├── src/
│   ├── handlers/           # API route handlers (thin — validate, delegate, respond)
│   │   ├── health.ts       # GET /healthz, GET /readyz
│   │   └── <resource>.ts   # CRUD + custom actions per resource
│   ├── services/           # Business logic (pure logic, no framework deps)
│   │   └── <resource>.service.ts
│   ├── repositories/       # Data access (DB queries, cache reads)
│   │   └── <resource>.repository.ts
│   ├── models/             # Domain models and DTOs
│   │   ├── entities/       # Database entity definitions
│   │   ├── dto/            # Request/Response DTOs (from OpenAPI schemas)
│   │   └── mappers/        # Entity <-> DTO transformations
│   ├── middleware/          # Auth, logging, rate limiting, tenant resolution
│   │   ├── auth.middleware.ts
│   │   ├── logging.middleware.ts
│   │   ├── rate-limit.middleware.ts
│   │   ├── tenant.middleware.ts
│   │   └── error-handler.middleware.ts
│   ├── config/             # Service configuration
│   │   ├── index.ts        # Env var loading with validation and defaults
│   │   ├── database.ts     # DB connection config
│   │   └── dependencies.ts # DI container wiring
│   ├── events/             # Event producers and consumers
│   │   ├── producers/
│   │   └── consumers/
│   └── index.ts            # Entry point — bootstrap, graceful shutdown
├── tests/
│   ├── unit/               # Pure logic tests (no I/O)
│   │   ├── services/
│   │   └── mappers/
│   ├── integration/        # Tests against real DB/cache (testcontainers)
│   │   └── repositories/
│   └── fixtures/           # Shared test data factories
├── Makefile                # build, test, lint, run, migrate
└── package.json / go.mod / requirements.txt / Cargo.toml  # (per language)
```

### 2.2 — Handler Implementation Pattern

Handlers are THIN. They validate input, delegate to services, and format output.

```
Handler receives request
  → Validate request (schema validation from OpenAPI DTOs)
  → Extract tenant context from middleware
  → Call service method with validated DTO
  → Service returns Result<DTO, DomainError>
  → Handler maps to HTTP response (200/201/400/404/500)
  → Structured logging of request/response metadata
```

Required for every handler:
- Request body validation against OpenAPI schema DTOs
- Request ID propagation (from `X-Request-ID` header or generate UUID)
- Structured logging with `trace_id`, `tenant_id`, `user_id`, `method`, `path`, `status`, `duration_ms`
- Error responses in the standard format: `{ code, message, details, trace_id }`
- Pagination support using cursor-based pagination for list endpoints

### 2.3 — Service Layer Implementation Pattern

Services contain ALL business logic. No HTTP awareness, no database awareness.

```
Service method receives validated DTO
  → Apply business rules and validation
  → Call repository for data access
  → Apply domain transformations
  → Emit domain events (if event-driven)
  → Return Result type (not exceptions for expected errors)
```

Required for every service:
- Constructor injection of repositories and dependencies (NO `new` in business logic)
- Domain error types (not HTTP errors — `NotFound`, `Conflict`, `ValidationFailed`, `Unauthorized`)
- Idempotency keys for all write operations
- Audit trail calls for state-changing operations (`who`, `what`, `when`, `tenant`)
- Unit testable in isolation with mocked repositories

### 2.4 — Repository Implementation Pattern

Repositories handle ALL data access. They return domain entities, not raw rows.

```
Repository method receives query parameters
  → Build query with tenant isolation (WHERE tenant_id = ?)
  → Execute with connection pool
  → Map rows to domain entities
  → Handle not-found as explicit return (Option/Maybe), not exception
  → Return domain entities
```

Required for every repository:
- Tenant-scoped queries (every query includes `tenant_id` filter)
- Soft delete support (`deleted_at IS NULL` in all queries)
- Connection pooling with health checks
- Query parameterization (NEVER string concatenation for SQL)
- Optimistic locking via `version` column for concurrent writes
- Read replica routing for read-heavy queries (when configured)

### 2.5 — Dependency Injection Wiring

Every service uses constructor injection. Wire dependencies in `config/dependencies.ts` (or equivalent):

```
// Pseudocode — adapt to chosen DI framework
Container.register({
  // Infrastructure
  dbPool: () => createPool(config.database),
  cache: () => createRedisClient(config.redis),
  eventBus: () => createEventBus(config.messageBroker),

  // Repositories
  userRepository: (c) => new UserRepository(c.dbPool, c.cache),
  orderRepository: (c) => new OrderRepository(c.dbPool, c.cache),

  // Services
  userService: (c) => new UserService(c.userRepository, c.eventBus),
  orderService: (c) => new OrderService(c.orderRepository, c.userService, c.eventBus),

  // Middleware
  authMiddleware: (c) => new AuthMiddleware(c.config.auth),
  tenantMiddleware: (c) => new TenantMiddleware(c.tenantRepository),
});
```

### 2.6 — Language-Specific Standards

#### TypeScript/Node.js
- Strict TypeScript (`strict: true`, `noUncheckedIndexedAccess: true`)
- ESM modules, no CommonJS
- Zod or class-validator for runtime validation
- Drizzle, Prisma, or TypeORM for data access
- tsx or tsup for compilation
- pino for structured logging
- DI via tsyringe, inversify, or manual constructor injection

#### Go
- Standard library HTTP or Chi/Gin/Fiber router
- sqlx or pgx for database access (not GORM for performance-critical paths)
- Wire or manual DI (no reflection-based DI)
- zerolog or slog for structured logging
- Context propagation for cancellation and tracing
- Table-driven tests

#### Python
- FastAPI or Django REST Framework
- SQLAlchemy or Django ORM
- Pydantic for validation and serialization
- dependency-injector or manual DI
- structlog for structured logging
- pytest with fixtures

#### Rust
- Axum or Actix-web
- SQLx for compile-time checked queries
- Tower middleware
- tracing crate for structured logging
- Manual DI via App state

#### Java/Kotlin
- Spring Boot with constructor injection
- Spring Data JPA or jOOQ
- Spring Security for auth middleware
- SLF4J + Logback for structured logging
- JUnit 5 + Mockito for tests

### 2.7 — Config and Environment Variables

Every service loads config from environment variables with validation at startup:

```
# Required (fail to start if missing)
DATABASE_URL=postgresql://user:pass@host:5432/dbname
REDIS_URL=redis://host:6379
SERVICE_NAME=user-service
ENVIRONMENT=development|staging|production
LOG_LEVEL=debug|info|warn|error
PORT=8080

# Optional (with sensible defaults)
DB_POOL_MIN=2
DB_POOL_MAX=10
DB_QUERY_TIMEOUT_MS=5000
CACHE_TTL_SECONDS=300
RATE_LIMIT_RPM=100
GRACEFUL_SHUTDOWN_TIMEOUT_MS=30000

# Feature flags
FEATURE_FLAG_PROVIDER=env|launchdarkly|unleash
FEATURE_NEW_BILLING=false

# Auth
AUTH_JWKS_URL=https://auth.example.com/.well-known/jwks.json
AUTH_ISSUER=https://auth.example.com
AUTH_AUDIENCE=api.example.com

# Observability
OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
OTEL_SERVICE_NAME=${SERVICE_NAME}

# Multi-tenancy
TENANT_ISOLATION_LEVEL=row|schema|database
```

Config must validate at startup and fail fast with clear error messages if required vars are missing.

**After implementing all services, present code to user via AskUserQuestion for review before proceeding.**

## Phase 3: Cross-Cutting Concerns

Implement shared middleware and infrastructure code in `Claude-Production-Grade-Suite/software-engineer/libs/shared/` and wire into each service.

### 3.1 — Authentication Middleware

Based on the auth ADR from the architect:

```
Request arrives
  → Extract token (Bearer header / cookie)
  → Validate token (JWT signature, expiry, issuer, audience)
  → Extract claims (user_id, tenant_id, roles, permissions)
  → Attach to request context
  → Pass to next middleware
  → On failure: 401 with standard error format
```

Implementation requirements:
- JWKS key caching with background refresh (not per-request fetch)
- Token introspection fallback for opaque tokens
- Role-based access control (RBAC) decorator/annotation for handlers
- Permission-based fine-grained access where needed
- Service-to-service auth (mTLS or service account tokens)

### 3.2 — Tenant Resolution Middleware

```
Request arrives (after auth)
  → Extract tenant identifier (from JWT claim / subdomain / header / path)
  → Validate tenant exists and is active
  → Load tenant configuration (feature flags, limits, plan tier)
  → Attach tenant context to request
  → All downstream queries automatically scoped to tenant
  → On failure: 403 with "invalid tenant" error
```

### 3.3 — Error Handling

Global error handler that catches all unhandled errors:

```json
{
  "error": {
    "code": "RESOURCE_NOT_FOUND",
    "message": "User with ID '123' not found",
    "details": [],
    "trace_id": "abc-123-def-456"
  }
}
```

Error mapping:
| Domain Error | HTTP Status | Error Code |
|-------------|-------------|------------|
| ValidationFailed | 400 | `VALIDATION_ERROR` |
| Unauthorized | 401 | `UNAUTHORIZED` |
| Forbidden | 403 | `FORBIDDEN` |
| NotFound | 404 | `RESOURCE_NOT_FOUND` |
| Conflict | 409 | `CONFLICT` |
| RateLimited | 429 | `RATE_LIMITED` |
| InternalError | 500 | `INTERNAL_ERROR` |
| ServiceUnavailable | 503 | `SERVICE_UNAVAILABLE` |

- Never expose stack traces in production (only in development)
- Always include `trace_id` for support correlation
- Log full error details server-side at ERROR level
- Return user-friendly messages client-side

### 3.4 — Structured Logging

Every log line is JSON with mandatory fields:

```json
{
  "timestamp": "2024-01-15T10:30:00.000Z",
  "level": "info",
  "service": "user-service",
  "trace_id": "abc-123",
  "span_id": "def-456",
  "tenant_id": "tenant-789",
  "user_id": "user-012",
  "method": "POST",
  "path": "/api/v1/users",
  "status": 201,
  "duration_ms": 45,
  "message": "User created successfully"
}
```

Log levels:
- `error` — Unexpected failures requiring investigation
- `warn` — Expected failures (validation errors, rate limits, not-found)
- `info` — Request/response lifecycle, business events
- `debug` — Detailed execution flow (disabled in production)

### 3.5 — Rate Limiting

Implement at two levels:

1. **Global rate limiting** (per IP) — Sliding window, configurable RPM per endpoint
2. **Tenant rate limiting** (per tenant) — Based on plan tier from tenant config

```
Request arrives
  → Check global rate limit (Redis INCR + EXPIRE)
  → Check tenant rate limit (Redis INCR + EXPIRE, keyed by tenant_id)
  → If exceeded: 429 with Retry-After header
  → Set response headers: X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Reset
  → Pass to next middleware
```

### 3.6 — Caching Layer

Implement cache-aside pattern in repositories:

```
Read path:
  → Check cache (Redis) by key
  → Cache HIT: return cached entity, log cache hit
  → Cache MISS: query database, store in cache with TTL, return entity

Write path:
  → Write to database
  → Invalidate cache (delete key, not update — avoids race conditions)
  → Emit cache invalidation event (for multi-instance consistency)
```

Cache key convention: `{service}:{entity}:{tenant_id}:{entity_id}` (e.g., `user-service:user:tenant-123:user-456`)

### 3.7 — Retry and Circuit Breaker

For all external calls (HTTP, database, cache, message broker):

**Retry policy:**
- Max retries: 3
- Backoff: Exponential with jitter (100ms, 200ms, 400ms + random 0-100ms)
- Retry on: Network errors, 502, 503, 504, connection timeouts
- Do NOT retry on: 400, 401, 403, 404, 409 (client errors are not transient)

**Circuit breaker:**
- Closed (normal) → Open (failing) after 5 consecutive failures or >50% error rate in 60s window
- Open → Half-Open after 30s cooldown
- Half-Open → Closed after 3 consecutive successes
- Open state returns 503 immediately (fail fast, don't pile up timeouts)

Use existing libraries: resilience4j (Java), polly (.NET), cockatiel (Node.js), go-resilience (Go), tenacity (Python).

### 3.8 — Feature Flags

Implement a feature flag abstraction that supports multiple backends:

```
interface FeatureFlagService {
  isEnabled(flagName: string, context: { tenantId, userId, environment }): boolean
  getVariant(flagName: string, context): string | null
}
```

Backends:
- **Environment variables** — Simple `FEATURE_X=true/false` (default, zero dependencies)
- **LaunchDarkly / Unleash / ConfigCat** — When dynamic toggling is needed
- **Database-backed** — When tenant-specific flags are needed

Feature flags must be used for:
- New feature rollouts (percentage-based)
- Tenant-specific features (plan tier gating)
- Kill switches for degraded mode
- A/B testing integration points

### 3.9 — Graceful Degradation

Every external dependency must have a fallback:

| Dependency | Degraded Behavior |
|-----------|-------------------|
| Cache (Redis) down | Bypass cache, serve from database (higher latency, still functional) |
| Message broker down | Queue events locally (in-memory or disk), replay when reconnected |
| External API down | Return cached/default response, log degradation, alert |
| Read replica down | Route reads to primary (higher load, still functional) |
| Feature flag service down | Fall back to cached flags or env-var defaults |
| Auth service down | Accept cached JWT validation (short window), reject new tokens |

Log all degradation events at WARN level with `degraded_dependency` field.

## Phase 4: Integration Layer

Implement service-to-service communication, event handling, and external API clients.

### 4.1 — Service-to-Service Communication

#### Synchronous (REST/gRPC)

Generate typed HTTP clients for each service-to-service call:

```
// Auto-generated from OpenAPI specs
class UserServiceClient {
  constructor(baseUrl: string, httpClient: HttpClient, circuitBreaker: CircuitBreaker)

  async getUser(userId: string, tenantId: string): Promise<Result<UserDTO, ServiceError>>
  async createUser(dto: CreateUserDTO, tenantId: string): Promise<Result<UserDTO, ServiceError>>
}
```

Requirements:
- Generated from OpenAPI/gRPC specs (not hand-written)
- Circuit breaker wrapping all calls
- Request ID propagation (forward `X-Request-ID` from incoming request)
- Tenant context propagation (forward `X-Tenant-ID` header)
- Timeout per call (configurable, default 5s)
- Structured logging of outbound calls

#### Asynchronous (Events)

Generate event producers and consumers from AsyncAPI specs:

**Producer pattern:**
```
Business operation completes
  → Create event envelope: { event_id, event_type, tenant_id, timestamp, payload, correlation_id }
  → Serialize (JSON/Avro/Protobuf per AsyncAPI spec)
  → Publish to topic/queue with retry
  → Log event published at INFO level
```

**Consumer pattern:**
```
Event received from topic/queue
  → Deserialize and validate schema
  → Check idempotency (event_id already processed?)
  → Extract tenant context from event envelope
  → Delegate to event handler service
  → Acknowledge message on success
  → On failure: retry with backoff, then dead-letter queue
  → Log event processed at INFO level
```

Event envelope standard:
```json
{
  "event_id": "uuid-v4",
  "event_type": "user.created",
  "event_version": "1.0",
  "source": "user-service",
  "tenant_id": "tenant-123",
  "correlation_id": "trace-abc",
  "timestamp": "2024-01-15T10:30:00.000Z",
  "payload": { ... }
}
```

### 4.2 — External API Clients

For each third-party integration identified in the architecture:

```
Claude-Production-Grade-Suite/software-engineer/libs/shared/clients/
├── stripe/
│   ├── client.ts           # Stripe SDK wrapper with retry/circuit breaker
│   ├── types.ts            # Mapped types (internal domain <-> Stripe types)
│   └── webhooks.ts         # Webhook signature verification + event handlers
├── sendgrid/
│   ├── client.ts
│   └── templates.ts        # Email template mappings
└── <provider>/
    ├── client.ts
    └── types.ts
```

Every external client must:
- Wrap the provider SDK (never use SDK directly in business logic)
- Map provider types to internal domain types
- Include circuit breaker and retry
- Handle webhook verification (if applicable)
- Log all outbound calls with duration and status
- Support mock/stub for testing

### 4.3 — Database Migration Runner

Implement a migration runner that executes the SQL migrations from `Claude-Production-Grade-Suite/solution-architect/schemas/migrations/`:

```
migrate up    — Run all pending migrations in order
migrate down  — Rollback last migration
migrate status — Show applied vs pending migrations
```

Requirements:
- Migrations run in a transaction (rollback on failure)
- Migration lock (only one instance runs migrations at a time)
- Idempotent (safe to run multiple times)
- Logs each migration applied with duration

**After implementing all integration patterns, present to user via AskUserQuestion for review before proceeding.**

## Phase 5: Local Dev Environment

Generate everything needed to run the full stack locally.

### 5.1 — Docker Compose

Generate `Claude-Production-Grade-Suite/software-engineer/docker-compose.dev.yml`:

```yaml
# Includes:
# - All application services (with hot-reload/watch mode)
# - PostgreSQL / MySQL (matching production DB)
# - Redis (matching production cache)
# - Message broker (Kafka/RabbitMQ matching production)
# - Mailhog / Mailpit (email testing)
# - LocalStack (if AWS services used) / GCP emulators
# - OpenTelemetry Collector + Jaeger (local tracing)
```

Requirements:
- Health checks on all services (depends_on with condition: service_healthy)
- Named volumes for data persistence across restarts
- Environment variable files (`.env.development`) — NOT committed, `.env.example` committed
- Port mapping that avoids conflicts (document in README)
- Hot-reload enabled for all application services

### 5.2 — Seed Data

Generate `Claude-Production-Grade-Suite/software-engineer/scripts/seed-data.sh`:

```bash
#!/bin/bash
# Seeds the local database with realistic test data
# Usage: make seed   (or ./scripts/seed-data.sh)
#
# Creates:
# - 3 tenant organizations (free, pro, enterprise tiers)
# - 10 users per tenant (with various roles)
# - Realistic sample data for each domain entity
# - Admin super-user for testing
```

Requirements:
- Idempotent (safe to run multiple times — upserts, not inserts)
- Uses the same migration runner (runs migrations first if needed)
- Creates data that exercises all tenant tiers and role types
- Includes edge cases (long names, unicode, empty optional fields)
- Outputs created credentials and IDs for developer reference

### 5.3 — Dev Setup Script

Generate `Claude-Production-Grade-Suite/software-engineer/scripts/dev-setup.sh`:

```bash
#!/bin/bash
# One-command local development setup
# Usage: ./scripts/dev-setup.sh
#
# Steps:
# 1. Check prerequisites (Docker, language runtime, tools)
# 2. Copy .env.example to .env.development (if not exists)
# 3. Start infrastructure (docker-compose up -d postgres redis kafka)
# 4. Wait for services to be healthy
# 5. Run database migrations
# 6. Seed development data
# 7. Install dependencies for all services
# 8. Print "Ready to develop" with service URLs
```

### 5.4 — Makefile

Generate `Claude-Production-Grade-Suite/software-engineer/Makefile` (root-level):

```makefile
# Available commands:
# make setup          — First-time dev environment setup
# make up             — Start all services (docker-compose)
# make down           — Stop all services
# make logs           — Tail logs for all services
# make logs-<service> — Tail logs for one service
# make test           — Run all tests
# make test-unit      — Run unit tests only
# make test-int       — Run integration tests only
# make lint           — Lint all services
# make migrate-up     — Run pending migrations
# make migrate-down   — Rollback last migration
# make seed           — Seed development data
# make clean          — Remove containers, volumes, caches
# make build          — Build all service images
```

Per-service Makefiles at `services/<name>/Makefile`:
```makefile
# make run     — Run this service locally (hot-reload)
# make test    — Run this service's tests
# make lint    — Lint this service
# make build   — Build this service
# make migrate — Run this service's migrations
```

## Suite Output Structure

```
Claude-Production-Grade-Suite/software-engineer/
├── services/
│   └── <service-name>/
│       ├── src/
│       │   ├── handlers/           # API route handlers
│       │   │   ├── health.ts
│       │   │   └── <resource>.ts
│       │   ├── services/           # Business logic
│       │   │   └── <resource>.service.ts
│       │   ├── repositories/       # Data access
│       │   │   └── <resource>.repository.ts
│       │   ├── models/             # Domain models
│       │   │   ├── entities/
│       │   │   ├── dto/
│       │   │   └── mappers/
│       │   ├── middleware/          # Auth, logging, rate limiting
│       │   │   ├── auth.middleware.ts
│       │   │   ├── logging.middleware.ts
│       │   │   ├── rate-limit.middleware.ts
│       │   │   ├── tenant.middleware.ts
│       │   │   └── error-handler.middleware.ts
│       │   ├── events/             # Event producers/consumers
│       │   │   ├── producers/
│       │   │   └── consumers/
│       │   ├── config/             # Service configuration
│       │   │   ├── index.ts
│       │   │   ├── database.ts
│       │   │   └── dependencies.ts
│       │   └── index.ts            # Entry point
│       ├── tests/
│       │   ├── unit/
│       │   │   ├── services/
│       │   │   └── mappers/
│       │   ├── integration/
│       │   │   └── repositories/
│       │   └── fixtures/
│       └── Makefile
├── libs/
│   └── shared/
│       ├── types/                  # Shared TypeScript types / proto-generated types
│       ├── errors/                 # Domain error definitions
│       ├── middleware/             # Reusable middleware (auth, tenant, logging)
│       ├── clients/               # Service-to-service + external API clients
│       │   ├── <service>-client.ts
│       │   └── <external>/
│       ├── events/                 # Event envelope, serialization, base consumer
│       ├── cache/                  # Cache-aside implementation
│       ├── resilience/             # Retry, circuit breaker, timeout wrappers
│       ├── feature-flags/          # Feature flag abstraction + backends
│       ├── observability/          # Tracing, metrics, logging setup
│       └── testing/                # Test helpers, factories, mocks
├── scripts/
│   ├── seed-data.sh               # Idempotent seed data loader
│   ├── dev-setup.sh               # One-command dev environment setup
│   └── migrate.sh                 # Migration runner wrapper
├── docker-compose.dev.yml         # Full local dev stack
├── .env.example                   # Template for local env vars
└── Makefile                       # Root-level dev commands
```

## Cloud-Specific Implementation Patterns

### AWS

| Concern | Implementation |
|---------|---------------|
| Database | Use AWS SDK v3 for DynamoDB, pg/mysql2 for RDS Aurora |
| Cache | ioredis for ElastiCache, DAX client for DynamoDB caching |
| Messaging | @aws-sdk/client-sqs + @aws-sdk/client-sns |
| Secrets | @aws-sdk/client-secrets-manager with caching (5-min TTL) |
| Storage | @aws-sdk/client-s3 with presigned URLs for uploads |
| Auth | Cognito JWT validation with `aws-jwt-verify` |
| Local dev | LocalStack for S3, SQS, SNS, Secrets Manager, DynamoDB |

### GCP

| Concern | Implementation |
|---------|---------------|
| Database | @google-cloud/spanner or pg for Cloud SQL |
| Cache | ioredis for Memorystore |
| Messaging | @google-cloud/pubsub |
| Secrets | @google-cloud/secret-manager with caching |
| Storage | @google-cloud/storage with signed URLs |
| Auth | Firebase Admin SDK or Google Auth Library |
| Local dev | GCP emulators (Pub/Sub, Firestore, Spanner) |

### Azure

| Concern | Implementation |
|---------|---------------|
| Database | @azure/cosmos or mssql for Azure SQL |
| Cache | ioredis for Azure Cache for Redis |
| Messaging | @azure/service-bus |
| Secrets | @azure/keyvault-secrets with caching |
| Storage | @azure/storage-blob with SAS tokens |
| Auth | @azure/identity + MSAL for Azure AD |
| Local dev | Azurite for Blob/Queue/Table storage |

### Multi-Cloud Abstraction

When multi-cloud support is needed, implement provider interfaces:

```
libs/shared/providers/
├── storage.provider.ts         # interface: upload, download, presign
│   ├── s3.storage.ts
│   ├── gcs.storage.ts
│   └── azure-blob.storage.ts
├── messaging.provider.ts       # interface: publish, subscribe, ack
│   ├── sqs.messaging.ts
│   ├── pubsub.messaging.ts
│   └── service-bus.messaging.ts
└── secrets.provider.ts         # interface: get, set, rotate
    ├── aws-sm.secrets.ts
    ├── gcp-sm.secrets.ts
    └── keyvault.secrets.ts
```

Select provider via config: `CLOUD_PROVIDER=aws|gcp|azure`. Wire in DI container.

## Implementation Quality Gates

Before marking a service as complete, verify:

| Gate | Check |
|------|-------|
| Compiles | `make build` passes with zero errors and zero warnings |
| Lint clean | `make lint` passes (ESLint/golangci-lint/ruff/clippy) |
| Unit tests pass | `make test-unit` — all service layer and mapper tests green |
| Integration tests pass | `make test-int` — repository tests against test DB green |
| Health check works | `GET /healthz` returns 200, `GET /readyz` returns 200 when DB connected |
| API contract match | All OpenAPI endpoints implemented, request/response schemas match |
| Tenant isolation | Every query includes `tenant_id` filter — manual review |
| No hardcoded secrets | No API keys, passwords, or tokens in source code |
| Config validation | Service fails fast on startup if required env vars missing |
| Graceful shutdown | SIGTERM triggers connection draining, in-flight request completion |

## Context Bridging from SolutionArchitect-Suite

| Architect Output | Software Engineer Reads | Software Engineer Produces |
|-----------------|------------------------|---------------------------|
| `api/openapi/*.yaml` | Endpoint definitions, schemas | Handlers, DTOs, route registration |
| `api/grpc/*.proto` | Service definitions, messages | gRPC server implementations, generated types |
| `api/asyncapi/*.yaml` | Event schemas, channels | Event producers, consumers, handlers |
| `schemas/migrations/*.sql` | Table structures | Entity models, repository queries |
| `schemas/erd.md` | Relationships, constraints | Mapper logic, validation rules |
| `docs/tech-stack.md` | Language, framework, libraries | Correct imports, idiomatic code |
| `docs/architecture-decision-records/` | Patterns, trade-offs | Pattern-compliant implementation |
| `scaffold/services/` | Service names, structure | Flesh out each service directory |

**Do NOT modify files in `Claude-Production-Grade-Suite/solution-architect/`.** If an API contract needs changes, flag it to the user — do not unilaterally alter the architect's decisions.

## Payment System Integration

For SaaS products, implement payment infrastructure as a core service module (not an afterthought).

### Payment Service Structure
```
services/<payment-service>/
├── src/
│   ├── handlers/
│   │   ├── webhooks.ts          # Stripe/payment webhook handler
│   │   ├── subscriptions.ts     # Subscription CRUD
│   │   └── billing.ts           # Invoice, usage, billing portal
│   ├── services/
│   │   ├── payment-provider.ts  # Abstract payment provider interface
│   │   ├── stripe-provider.ts   # Stripe implementation
│   │   ├── subscription.ts      # Subscription lifecycle management
│   │   ├── billing.ts           # Metered billing, usage tracking
│   │   └── entitlements.ts      # Feature gating by plan
│   ├── repositories/
│   │   ├── subscription.ts      # Subscription persistence
│   │   ├── invoice.ts           # Invoice records
│   │   └── usage.ts             # Usage metering records
│   └── models/
│       ├── plan.ts              # Plan definitions (free, pro, enterprise)
│       ├── subscription.ts      # Subscription entity
│       └── invoice.ts           # Invoice entity
└── tests/
```

### Payment Standards
- **Provider abstraction** — Interface over Stripe/Paddle/LemonSqueezy so provider is swappable
- **Webhook idempotency** — Deduplicate by event ID, process exactly once
- **Webhook signature verification** — Always verify Stripe-Signature header
- **Subscription lifecycle** — Handle: created, updated, cancelled, past_due, unpaid, trial_ending
- **Entitlement system** — Feature access tied to plan, not hardcoded. Check `entitlements.canAccess(feature)` in middleware
- **Usage-based billing** — Track metered usage, report to billing provider, aggregate hourly
- **Invoice management** — Store invoice copies locally for compliance
- **Dunning flow** — Grace period → email reminders → downgrade → suspension
- **Tax handling** — Use Stripe Tax or TaxJar for automatic tax calculation
- **Multi-currency** — Support if serving international users
- **PCI compliance** — Never store card details. Use Stripe Elements / Checkout Sessions.
- **Billing portal** — Integrate Stripe Customer Portal or build custom

### Plan & Entitlement Configuration
```yaml
plans:
  free:
    price: 0
    features: [basic_feature]
    limits:
      api_calls: 100/day
      storage: 1GB
  pro:
    price: 29/month
    features: [basic_feature, advanced_feature, priority_support]
    limits:
      api_calls: 10000/day
      storage: 100GB
  enterprise:
    price: custom
    features: [all]
    limits:
      api_calls: unlimited
      storage: unlimited
```

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
