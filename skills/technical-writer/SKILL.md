# Technical Writer Skill

name: technical-writer
description: Use when all implementation, testing, DevOps, and SRE phases are complete and you need to produce comprehensive documentation — API references, developer guides, architecture overviews, operational docs, onboarding materials, and a documentation site scaffold — so that a new developer can onboard in hours and an API consumer can integrate in minutes.

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

## Prerequisites

Before invoking this skill, ensure the following exist:

| Artifact | Source | What Technical Writer Needs From It |
|---|---|---|
| `Claude-Production-Grade-Suite/product-manager/` | BA skill | Business context, user personas, feature scope, glossary of domain terms |
| Architecture docs / ADRs | Architect skill | Service boundaries, technology choices, data flow diagrams, decision rationale |
| OpenAPI / AsyncAPI specs | Implementation | API contracts, request/response schemas, authentication methods |
| Source code | Implementation | Code comments, module structure, configuration files, environment variables |
| `Claude-Production-Grade-Suite/qa-engineer/` | Testing skill | Test coverage reports, integration test descriptions, testing strategy |
| `Claude-Production-Grade-Suite/devops/` | DevOps skill | Deployment procedures, environment configurations, CI/CD pipeline docs |
| `Claude-Production-Grade-Suite/sre/` | SRE skill | Runbooks, incident procedures, SLO definitions, DR playbooks |

**Critical rule:** The Technical Writer skill does NOT invent information. Every statement in the documentation must trace to an artifact from a previous phase. If information is missing, the skill creates a placeholder with a `<!-- TODO: Source not found — verify with <team> -->` comment rather than fabricating content.

## Output Structure

All outputs are written to `Claude-Production-Grade-Suite/technical-writer/` in the project root.

```
Claude-Production-Grade-Suite/technical-writer/
├── docusaurus/                  # or mkdocs/ — documentation site scaffold
│   ├── docusaurus.config.js
│   ├── sidebars.js
│   ├── package.json
│   ├── babel.config.js
│   └── src/
│       ├── css/
│       │   └── custom.css
│       └── pages/
│           └── index.js
├── docs/
│   ├── getting-started/
│   │   ├── quickstart.md
│   │   ├── installation.md
│   │   └── local-development.md
│   ├── architecture/
│   │   ├── overview.md
│   │   ├── service-map.md
│   │   └── decisions/           # Readable ADR summaries
│   │       └── <NNN-decision-title>.md
│   ├── api-reference/
│   │   ├── authentication.md
│   │   ├── endpoints/
│   │   │   └── <resource-name>.md
│   │   ├── error-codes.md
│   │   ├── rate-limiting.md
│   │   └── webhooks.md
│   ├── guides/
│   │   ├── coding-conventions.md
│   │   ├── testing-guide.md
│   │   └── contributing.md
│   ├── operations/
│   │   ├── deployment.md
│   │   ├── monitoring.md
│   │   ├── incident-response.md
│   │   └── runbook-index.md
│   └── integrations/
│       ├── sdk-quickstart.md
│       └── webhook-guide.md
├── api-reference/
│   └── generated/               # Auto-generated from OpenAPI
│       ├── openapi.html
│       └── openapi.json
├── CHANGELOG.md
└── ci/
    └── docs-build.yml
```

---

## Phases

Execute these phases sequentially. Each phase builds on the documentation architecture established in Phase 1.

---

### Phase 1: Documentation Architecture

**Goal:** Survey all existing artifacts, determine what documentation is needed, create a sitemap, and establish documentation standards.

**Inputs:**
- ALL suite outputs (`Claude-Production-Grade-Suite/product-manager/`, architecture docs, `Claude-Production-Grade-Suite/qa-engineer/`, `Claude-Production-Grade-Suite/devops/`, `Claude-Production-Grade-Suite/sre/`)
- Source code structure
- OpenAPI/AsyncAPI specifications (if present)

**Process:**

1. **Inventory all artifacts.** Read every suite directory. For each file, record:
   - File path
   - Content type (config, narrative, spec, diagram)
   - Documentation relevance (high / medium / low)
   - Target audience (developer, operator, API consumer, business stakeholder)

2. **Identify documentation gaps.** Cross-reference against this required documentation matrix:

| Document | Source Artifact | Target Audience | Priority |
|---|---|---|---|
| Quickstart guide | Implementation + DevOps | New developer | P0 |
| Local development setup | DevOps-Suite, docker-compose, env vars | New developer | P0 |
| Architecture overview | ADRs, service map | All technical | P0 |
| API authentication guide | OpenAPI spec, auth implementation | API consumer | P0 |
| API endpoint reference | OpenAPI spec | API consumer | P0 |
| Error code reference | Source code, API spec | API consumer | P0 |
| Deployment guide | DevOps-Suite CI/CD | Operator | P1 |
| Monitoring guide | DevOps-Suite monitoring, SRE-Suite SLOs | Operator | P1 |
| Incident response guide | SRE-Suite incidents | Operator | P1 |
| Coding conventions | Source code patterns, linter configs | Developer | P1 |
| Testing guide | Test-Suite | Developer | P1 |
| Contributing guide | Git workflow, PR templates | Developer | P1 |
| Webhook documentation | AsyncAPI spec, webhook implementation | API consumer (B2B) | P2 |
| SDK quickstart | SDK source code | API consumer | P2 |
| Rate limiting guide | API gateway config, middleware | API consumer | P2 |
| ADR summaries | Architecture ADRs | Developer | P2 |
| Runbook index | SRE-Suite runbooks | Operator | P2 |
| Changelog | Git history, release notes | All | P2 |

3. **Create documentation sitemap.** Define the navigation structure for the documentation site. This becomes the `sidebars.js` configuration.

4. **Establish documentation standards:**

```markdown
## Documentation Standards

### Voice and Tone
- Use second person ("you") when addressing the reader
- Use present tense ("the API returns" not "the API will return")
- Use active voice ("Send a request" not "A request should be sent")
- Be direct and concise — developers skim, they do not read novels

### Structure Rules
- Every page starts with a one-sentence summary of what it covers
- Every page ends with a "Next steps" section linking to related pages
- Code examples are complete and copy-pasteable (no pseudo-code)
- Code examples include expected output or response
- Every environment variable is documented with: name, type, default, description, example
- Every API endpoint shows: method, path, auth required, request body, response, error cases

### Formatting
- Use headers hierarchically (h2 for sections, h3 for subsections — never skip levels)
- Use admonitions for warnings, tips, and important notes
- Use tables for structured data (env vars, parameters, error codes)
- Use code blocks with language identifiers for syntax highlighting
- Maximum line length in markdown: 120 characters
```

---

### Phase 2: API Reference

**Goal:** Generate comprehensive API documentation that enables a consumer to integrate without reading source code or asking questions.

**Inputs:**
- OpenAPI / AsyncAPI specifications
- Authentication implementation (middleware, API key management)
- Rate limiting configuration
- Error handling middleware / error code definitions
- Source code for request/response examples

**Process:**

1. **Generate `docs/api-reference/authentication.md`:**

```markdown
# Authentication

## Overview
<One paragraph: what auth method is used, how to obtain credentials>

## Getting Your API Key
1. <Step-by-step instructions>
2. ...

## Using Your API Key

### Header Authentication (Recommended)
```bash
curl -X GET https://api.example.com/v1/resources \
  -H "Authorization: Bearer YOUR_API_KEY"
```

### Query Parameter Authentication
```bash
curl -X GET "https://api.example.com/v1/resources?api_key=YOUR_API_KEY"
```

> **Warning:** Query parameter authentication exposes your key in URLs and server logs.
> Use header authentication in production.

## Authentication Errors

| Status Code | Error Code | Description | Resolution |
|---|---|---|---|
| 401 | `auth_missing` | No API key provided | Include `Authorization` header |
| 401 | `auth_invalid` | API key is malformed or revoked | Check key format, generate new key if revoked |
| 403 | `auth_insufficient_scope` | Key does not have required permissions | Request additional scopes |

## Code Examples

### Python
```python
import requests

response = requests.get(
    "https://api.example.com/v1/resources",
    headers={"Authorization": "Bearer YOUR_API_KEY"}
)
print(response.json())
```

### JavaScript (Node.js)
```javascript
const response = await fetch("https://api.example.com/v1/resources", {
  headers: { "Authorization": "Bearer YOUR_API_KEY" }
});
const data = await response.json();
```

### Go
```go
req, _ := http.NewRequest("GET", "https://api.example.com/v1/resources", nil)
req.Header.Set("Authorization", "Bearer YOUR_API_KEY")
resp, err := http.DefaultClient.Do(req)
```
```

2. **Generate `docs/api-reference/endpoints/`** with one file per resource. Each endpoint page follows this template:

```markdown
# <Resource Name>

## List <Resources>

`GET /v1/<resources>`

Returns a paginated list of <resources>.

### Authentication
Required. Scope: `<resource>:read`

### Query Parameters

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `page` | integer | No | 1 | Page number |
| `per_page` | integer | No | 20 | Items per page (max 100) |
| `sort` | string | No | `created_at` | Sort field |
| `order` | string | No | `desc` | Sort order: `asc` or `desc` |
| `status` | string | No | — | Filter by status: `active`, `inactive` |

### Response

```json
{
  "data": [
    {
      "id": "res_abc123",
      "name": "Example Resource",
      "status": "active",
      "created_at": "2025-01-15T09:30:00Z",
      "updated_at": "2025-01-15T09:30:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total": 42,
    "total_pages": 3
  }
}
```

### Error Responses

| Status | Code | Description |
|---|---|---|
| 400 | `invalid_parameter` | Query parameter value is invalid |
| 401 | `auth_missing` | No authentication provided |

### Example

```bash
curl -X GET "https://api.example.com/v1/resources?page=1&per_page=10" \
  -H "Authorization: Bearer YOUR_API_KEY"
```
```

3. **Generate `docs/api-reference/error-codes.md`** with a complete table of all error codes, HTTP status codes, descriptions, and resolution steps. Extract these from error handling middleware in the source code.

4. **Generate `docs/api-reference/rate-limiting.md`:**
   - Rate limit tiers (by plan/API key type)
   - Rate limit headers returned (`X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`)
   - Handling 429 responses (backoff strategy with code examples)
   - Requesting rate limit increases

5. **Generate `docs/api-reference/webhooks.md`** (if applicable):
   - Available webhook events
   - Payload format for each event (with JSON examples)
   - Webhook signature verification (with code examples in multiple languages)
   - Retry policy for failed deliveries
   - Testing webhooks locally (ngrok/localtunnel instructions)

6. **Generate auto-generated reference** in `api-reference/generated/`:
   - Use the OpenAPI spec to produce an HTML reference (Redoc or Swagger UI)
   - Copy the OpenAPI spec as `openapi.json` for consumers to download

---

### Phase 3: Developer Guides

**Goal:** Enable a new developer to go from zero to productive. These guides answer "how do I..." questions.

**Inputs:**
- Source code structure, build files, configuration
- `Claude-Production-Grade-Suite/devops/` — Docker configs, environment setup
- `Claude-Production-Grade-Suite/qa-engineer/` — testing strategy, coverage requirements
- Architecture ADRs — design decisions and their rationale
- Git workflow — branching strategy, PR process

**Process:**

1. **Generate `docs/getting-started/quickstart.md`:**

```markdown
# Quickstart

Get the application running locally in under 10 minutes.

## Prerequisites
- <Language runtime> v<version> ([install](<link>))
- Docker Desktop v<version>+ ([install](<link>))
- <Other tools>

## Steps

### 1. Clone the repository
```bash
git clone <repo-url>
cd <project-name>
```

### 2. Install dependencies
```bash
<package-manager> install
```

### 3. Configure environment
```bash
cp .env.example .env
# Edit .env — see Environment Variables below for required values
```

### 4. Start infrastructure dependencies
```bash
docker compose up -d
```

### 5. Run database migrations
```bash
<migration command>
```

### 6. Seed development data
```bash
<seed command>
```

### 7. Start the application
```bash
<start command>
```

The application is now running at `http://localhost:<port>`.

## Verify It Works

```bash
curl http://localhost:<port>/health
# Expected: {"status": "ok"}
```

## Environment Variables

| Variable | Required | Default | Description |
|---|---|---|---|
| `DATABASE_URL` | Yes | — | PostgreSQL connection string |
| `REDIS_URL` | No | `redis://localhost:6379` | Redis connection string |
| `API_KEY_SECRET` | Yes | — | Secret for signing API keys (generate: `openssl rand -hex 32`) |

## Next Steps
- [Local Development Guide](./local-development.md) — hot reloading, debugging, tooling
- [Architecture Overview](../architecture/overview.md) — understand the system design
- [Contributing Guide](../guides/contributing.md) — how to submit changes
```

2. **Generate `docs/getting-started/installation.md`** with detailed installation instructions for all supported platforms (macOS, Linux, Windows/WSL), including specific version requirements and common installation issues with solutions.

3. **Generate `docs/getting-started/local-development.md`** covering:
   - IDE setup and recommended extensions
   - Hot reloading configuration
   - Debugging setup (launch.json / debugger configuration)
   - Running tests locally
   - Working with Docker in development
   - Common development tasks (creating migrations, adding endpoints, etc.)
   - Troubleshooting common local dev issues

4. **Generate `docs/architecture/overview.md`** synthesized from ADRs and architecture docs:
   - High-level system diagram (described in text/Mermaid — not an image)
   - Service responsibilities (one paragraph per service)
   - Data flow for the 3-5 most common operations
   - Technology stack with version numbers and rationale for each choice
   - Key architectural constraints and trade-offs

5. **Generate `docs/architecture/service-map.md`** with:
   - Mermaid diagram showing all services and their communication patterns
   - For each service: port, protocol, dependencies, data stores, key configuration
   - Network topology (which services are internal-only vs. public-facing)

6. **Generate `docs/architecture/decisions/`** with human-readable summaries of each ADR:
   - Each file: `NNN-short-title.md`
   - Format: Context (problem being solved), Decision (what was chosen), Consequences (trade-offs accepted), Status (accepted/superseded/deprecated)
   - Written for a new developer who has no context on the original discussion

7. **Generate `docs/guides/coding-conventions.md`** extracted from:
   - Linter configuration files (ESLint, Prettier, Flake8, etc.)
   - Existing code patterns (naming conventions, file organization)
   - Error handling patterns used in the codebase
   - Logging conventions (log levels, structured logging format)
   - Examples of "good" code from the existing codebase

8. **Generate `docs/guides/testing-guide.md`** from `Claude-Production-Grade-Suite/qa-engineer/`:
   - Testing philosophy and strategy
   - How to run each test type (unit, integration, e2e)
   - How to write a new test (template/example)
   - Coverage requirements and how to check coverage
   - Test data management (fixtures, factories, seeding)
   - CI test pipeline explanation

9. **Generate `docs/guides/contributing.md`:**
   - Git branching strategy
   - Commit message format
   - PR process (template, required reviewers, CI checks that must pass)
   - Code review expectations
   - How to get help (Slack channels, office hours, documentation)

---

### Phase 4: Operational Documentation

**Goal:** Give operators everything they need to deploy, monitor, and respond to incidents without digging through DevOps or SRE suites.

**Inputs:**
- `Claude-Production-Grade-Suite/devops/` — CI/CD pipelines, Kubernetes manifests, monitoring configs
- `Claude-Production-Grade-Suite/sre/` — runbooks, incident procedures, SLO definitions, DR playbooks

**Process:**

1. **Generate `docs/operations/deployment.md`:**

```markdown
# Deployment Guide

## Deployment Pipeline Overview
<Describe the CI/CD pipeline stages from commit to production>

## Environments

| Environment | URL | Branch | Auto-Deploy | Approval Required |
|---|---|---|---|---|
| Development | dev.example.com | `develop` | Yes | No |
| Staging | staging.example.com | `release/*` | Yes | No |
| Production | api.example.com | `main` | No | Yes (2 reviewers) |

## Deploying to Production

### Standard Deployment
1. Merge PR to `main`
2. CI pipeline runs: lint, test, build, security scan
3. Canary deployment: 10% traffic for 10 minutes
4. Automated SLO check against canary
5. If SLO check passes: progressive rollout (25% -> 50% -> 100%)
6. If SLO check fails: automatic rollback

### Manual Deployment (Emergency)
```bash
# Only use when CI pipeline is unavailable
<manual deployment commands>
```

### Rollback
```bash
# Rollback to previous version
<rollback command>

# Rollback to specific version
<rollback to version command>

# Verify rollback
<verification command>
```

## Feature Flags
<How to enable/disable features without deployment>

## Database Migrations
<How migrations run during deployment, rollback procedures for migrations>
```

2. **Generate `docs/operations/monitoring.md`:**
   - Dashboard locations and what each dashboard shows
   - Key metrics to watch and their healthy ranges
   - SLO summary (targets, current attainment, error budget status)
   - Log access instructions (how to query logs, common log searches)
   - Tracing instructions (how to find a trace for a specific request)

3. **Generate `docs/operations/incident-response.md`** as a distilled, quick-reference version of `Claude-Production-Grade-Suite/sre/incidents/`:
   - Severity classification (one-page summary)
   - On-call contact information and escalation chain
   - War room opening procedure (condensed to steps, not explanation)
   - Statuspage update procedures
   - Postmortem template and timeline

4. **Generate `docs/operations/runbook-index.md`** — a table of all runbooks from `Claude-Production-Grade-Suite/sre/runbooks/` with:
   - Alert name
   - Severity
   - Service affected
   - Link to full runbook
   - One-line summary of what to do

---

### Phase 5: User and Integration Guides

**Goal:** For B2B SaaS or platform products, provide integration documentation that external developers can follow independently.

**Inputs:**
- OpenAPI/AsyncAPI specs — webhook events, SDK endpoints
- SDK source code (if applicable)
- Authentication and rate limiting configs
- Example integrations or sample applications

**Process:**

1. **Generate `docs/integrations/sdk-quickstart.md`** (if SDKs exist):

```markdown
# SDK Quickstart

## Installation

### Python
```bash
pip install <package-name>
```

### JavaScript / TypeScript
```bash
npm install <package-name>
```

### Go
```bash
go get <module-path>
```

## Initialize the Client

### Python
```python
from <package> import Client

client = Client(api_key="YOUR_API_KEY")

# List resources
resources = client.resources.list(page=1, per_page=10)
for resource in resources:
    print(resource.name)

# Create a resource
new_resource = client.resources.create(
    name="My Resource",
    config={"key": "value"}
)
print(f"Created: {new_resource.id}")
```

### JavaScript
```javascript
import { Client } from '<package-name>';

const client = new Client({ apiKey: 'YOUR_API_KEY' });

// List resources
const resources = await client.resources.list({ page: 1, perPage: 10 });
resources.forEach(r => console.log(r.name));

// Create a resource
const newResource = await client.resources.create({
  name: 'My Resource',
  config: { key: 'value' }
});
console.log(`Created: ${newResource.id}`);
```

## Error Handling

### Python
```python
from <package>.exceptions import ApiError, RateLimitError

try:
    resource = client.resources.get("invalid_id")
except RateLimitError as e:
    print(f"Rate limited. Retry after {e.retry_after} seconds")
except ApiError as e:
    print(f"API error {e.status_code}: {e.message}")
```

## Next Steps
- [API Reference](../api-reference/authentication.md) — full API documentation
- [Webhook Guide](./webhook-guide.md) — receive real-time events
```

2. **Generate `docs/integrations/webhook-guide.md`** (if webhooks exist):
   - How to register a webhook endpoint
   - Available events with payload examples
   - Signature verification implementation (code in Python, JavaScript, Go)
   - Retry behavior and failure handling
   - Testing webhooks in development (step-by-step with tools like ngrok)
   - Best practices (respond with 200 quickly, process asynchronously, handle duplicates)

---

### Phase 6: Documentation Infrastructure

**Goal:** Scaffold a documentation site that builds, deploys, and is searchable. Not just files in a repo — a real documentation experience.

**Inputs:**
- All documentation written in Phases 1-5
- Project branding (name, colors — infer from existing assets or use sensible defaults)

**Process:**

1. **Generate Docusaurus scaffold** in `Claude-Production-Grade-Suite/technical-writer/docusaurus/`:

   **`docusaurus.config.js`:**
   ```javascript
   // @ts-check

   /** @type {import('@docusaurus/types').Config} */
   const config = {
     title: '<Project Name> Documentation',
     tagline: '<One-line project description>',
     favicon: 'img/favicon.ico',
     url: 'https://docs.example.com',
     baseUrl: '/',
     organizationName: '<org>',
     projectName: '<project>',
     onBrokenLinks: 'throw',
     onBrokenMarkdownLinks: 'warn',

     presets: [
       [
         'classic',
         /** @type {import('@docusaurus/preset-classic').Options} */
         ({
           docs: {
             sidebarPath: './sidebars.js',
             editUrl: '<repo-url>/edit/main/Claude-Production-Grade-Suite/technical-writer/docs/',
             showLastUpdateTime: true,
             showLastUpdateAuthor: true,
             versions: {
               current: {
                 label: 'Next',
                 path: 'next',
               },
             },
           },
           blog: false,
           theme: {
             customCss: './src/css/custom.css',
           },
         }),
       ],
     ],

     themes: ['@docusaurus/theme-search-algolia'],

     themeConfig:
       /** @type {import('@docusaurus/preset-classic').ThemeConfig} */
       ({
         navbar: {
           title: '<Project Name>',
           items: [
             {
               type: 'docSidebar',
               sidebarId: 'docs',
               position: 'left',
               label: 'Docs',
             },
             {
               href: '/api-reference',
               label: 'API Reference',
               position: 'left',
             },
             {
               href: '<repo-url>',
               label: 'GitHub',
               position: 'right',
             },
           ],
         },
         footer: {
           style: 'dark',
           links: [
             {
               title: 'Docs',
               items: [
                 { label: 'Quickstart', to: '/docs/getting-started/quickstart' },
                 { label: 'API Reference', to: '/docs/api-reference/authentication' },
               ],
             },
             {
               title: 'Community',
               items: [
                 { label: 'GitHub', href: '<repo-url>' },
                 { label: 'Discord', href: '<discord-url>' },
               ],
             },
           ],
         },
         algolia: {
           appId: '<ALGOLIA_APP_ID>',
           apiKey: '<ALGOLIA_SEARCH_API_KEY>',
           indexName: '<project-docs>',
           contextualSearch: true,
         },
       }),
   };

   module.exports = config;
   ```

   **`sidebars.js`:**
   ```javascript
   /** @type {import('@docusaurus/plugin-content-docs').SidebarsConfig} */
   const sidebars = {
     docs: [
       {
         type: 'category',
         label: 'Getting Started',
         collapsed: false,
         items: [
           'getting-started/quickstart',
           'getting-started/installation',
           'getting-started/local-development',
         ],
       },
       {
         type: 'category',
         label: 'Architecture',
         items: [
           'architecture/overview',
           'architecture/service-map',
           {
             type: 'category',
             label: 'Design Decisions',
             items: [
               // Auto-populated from docs/architecture/decisions/
             ],
           },
         ],
       },
       {
         type: 'category',
         label: 'API Reference',
         items: [
           'api-reference/authentication',
           {
             type: 'category',
             label: 'Endpoints',
             items: [
               // Auto-populated from docs/api-reference/endpoints/
             ],
           },
           'api-reference/error-codes',
           'api-reference/rate-limiting',
           'api-reference/webhooks',
         ],
       },
       {
         type: 'category',
         label: 'Guides',
         items: [
           'guides/coding-conventions',
           'guides/testing-guide',
           'guides/contributing',
         ],
       },
       {
         type: 'category',
         label: 'Operations',
         items: [
           'operations/deployment',
           'operations/monitoring',
           'operations/incident-response',
           'operations/runbook-index',
         ],
       },
       {
         type: 'category',
         label: 'Integrations',
         items: [
           'integrations/sdk-quickstart',
           'integrations/webhook-guide',
         ],
       },
     ],
   };

   module.exports = sidebars;
   ```

   **`package.json`:**
   ```json
   {
     "name": "<project>-docs",
     "version": "1.0.0",
     "private": true,
     "scripts": {
       "docusaurus": "docusaurus",
       "start": "docusaurus start",
       "build": "docusaurus build",
       "serve": "docusaurus serve",
       "clear": "docusaurus clear",
       "write-translations": "docusaurus write-translations",
       "write-heading-ids": "docusaurus write-heading-ids"
     },
     "dependencies": {
       "@docusaurus/core": "^3.0.0",
       "@docusaurus/preset-classic": "^3.0.0",
       "@docusaurus/theme-search-algolia": "^3.0.0",
       "clsx": "^2.0.0",
       "prism-react-renderer": "^2.1.0",
       "react": "^18.2.0",
       "react-dom": "^18.2.0"
     },
     "devDependencies": {
       "@docusaurus/module-type-aliases": "^3.0.0",
       "@docusaurus/types": "^3.0.0"
     },
     "browserslist": {
       "production": [">0.5%", "not dead", "not op_mini all"],
       "development": ["last 3 chrome version", "last 3 firefox version", "last 5 safari version"]
     },
     "engines": {
       "node": ">=18.0"
     }
   }
   ```

2. **Generate `Claude-Production-Grade-Suite/technical-writer/ci/docs-build.yml`** — CI pipeline for documentation:

```yaml
name: Documentation Build and Deploy

on:
  push:
    branches: [main]
    paths:
      - 'Claude-Production-Grade-Suite/technical-writer/**'
  pull_request:
    branches: [main]
    paths:
      - 'Claude-Production-Grade-Suite/technical-writer/**'

jobs:
  build:
    name: Build Documentation
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: Claude-Production-Grade-Suite/technical-writer/docusaurus
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: npm
          cache-dependency-path: Claude-Production-Grade-Suite/technical-writer/docusaurus/package-lock.json

      - name: Install dependencies
        run: npm ci

      - name: Build documentation site
        run: npm run build
        env:
          NODE_OPTIONS: "--max-old-space-size=4096"

      - name: Check for broken links
        run: |
          npm run build 2>&1 | tee build-output.log
          if grep -q "BrokenLinks" build-output.log; then
            echo "Broken links detected in documentation"
            exit 1
          fi

      - name: Upload build artifact
        if: github.ref == 'refs/heads/main'
        uses: actions/upload-pages-artifact@v3
        with:
          path: Claude-Production-Grade-Suite/technical-writer/docusaurus/build

  # OpenAPI spec validation
  validate-api-docs:
    name: Validate OpenAPI Spec
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Validate OpenAPI specification
        uses: char0n/swagger-editor-validate@v1
        with:
          definition-file: Claude-Production-Grade-Suite/technical-writer/api-reference/generated/openapi.json

  deploy:
    name: Deploy Documentation
    needs: [build, validate-api-docs]
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    permissions:
      pages: write
      id-token: write
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```

3. **Generate `Claude-Production-Grade-Suite/technical-writer/CHANGELOG.md`** with a template and instructions:

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- <New features>

### Changed
- <Changes in existing functionality>

### Deprecated
- <Soon-to-be removed features>

### Removed
- <Removed features>

### Fixed
- <Bug fixes>

### Security
- <Vulnerability fixes>

<!-- ## [1.0.0] - YYYY-MM-DD -->
<!-- ### Added -->
<!-- - Initial release -->
```

4. **Generate auto-generated API reference** in `api-reference/generated/`:
   - Copy the OpenAPI spec as `openapi.json`
   - Generate `openapi.html` using Redoc standalone HTML (embed the spec in a single-file HTML page)
   - This serves as a fallback API reference that works without the Docusaurus site

---

## Common Mistakes

| Mistake | Why It Fails | What To Do Instead |
|---|---|---|
| Auto-generating API docs and calling it done | Auto-generated docs describe endpoints mechanically but lack context: why use this endpoint, what workflow does it belong to, what are the gotchas | Auto-generated reference is the baseline. Layer on hand-written guides: authentication walkthrough, common workflows, "how to do X" tutorials. |
| Writing a quickstart that takes 45 minutes | Developers give up and ask a colleague instead. The doc is abandoned. | A quickstart must get a working system in under 10 minutes. Move deep configuration to separate pages. Prerequisites must be 3 items or fewer. |
| Documenting how the code works instead of how to USE it | Internal implementation details change constantly and create maintenance burden. Developers need task-oriented docs, not code narration. | Focus on tasks: "How to add a new endpoint", "How to write a migration", "How to debug a failed deployment". Link to source for implementation details. |
| Putting all environment variables in a giant table without grouping | Developer scanning for the database URL has to read 50 variables | Group env vars by category (database, cache, auth, external services). Mark required vs. optional. Show working example values. |
| Code examples that do not actually work | Errors in copy-pasted examples destroy trust in all documentation | Every code example must be tested. Use a CI step that extracts and runs doc examples if possible. At minimum, manually verify before publishing. |
| No versioning strategy for docs | API v1 docs get overwritten by v2 docs. Users on v1 cannot find their documentation. | Use Docusaurus versioning. Cut a doc version for each major API version. Default to latest, but keep previous versions accessible. |
| Operational docs that duplicate SRE runbooks verbatim | Two copies of the same content that drift apart over time | Operations docs in Docs-Suite are summaries and indexes. They link to the canonical runbooks in SRE-Suite. Single source of truth. |
| Architecture docs that describe the aspirational design, not the actual system | New developer reads the docs, looks at the code, and they do not match. Trust in docs destroyed. | Document what IS, not what SHOULD BE. If the architecture has tech debt or divergences from the ideal, document those too with links to relevant tickets. |
| Missing "Last updated" dates on pages | Reader has no way to know if the page is current or stale from 2 years ago | Enable `showLastUpdateTime` in Docusaurus. For non-Docusaurus docs, add a "Last verified: YYYY-MM-DD" line at the top of each page. |
| Writing documentation in a vacuum without talking to users | Docs answer questions nobody is asking, and miss the questions everyone has | Before writing, audit: support tickets, Slack questions, onboarding feedback, Stack Overflow questions about the product. These reveal what docs are actually needed. |
| No search functionality | Documentation exists but nobody can find the page they need | Configure Algolia DocSearch or local search plugin. Verify search returns relevant results for common queries. |
| Changelog that lists git commits | Unreadable for anyone who is not on the development team | Changelog entries should be user-facing: what changed from the consumer's perspective, not "refactored internal handler". Group by Added/Changed/Fixed/Removed. |

---

## Handoff and Maintenance

### Who Maintains These Docs

| Doc Section | Primary Owner | Review Cadence |
|---|---|---|
| Getting Started | Engineering (onboarding buddy) | Every new hire (validate and update) |
| Architecture | Tech Lead / Architect | Quarterly, or when ADRs are created |
| API Reference | Backend team | Every API change (enforced by CI) |
| Operations | SRE / Platform team | Monthly, or after every incident |
| Integrations | Developer Relations / Backend | Every SDK release |
| Changelog | Release manager | Every release |

### Keeping Docs Current

- **CI enforcement:** The `docs-build.yml` pipeline fails on broken links. This catches stale references.
- **PR template:** Add a checkbox: "Does this change require documentation updates? If yes, Docs-Suite updated."
- **Quarterly audit:** Schedule a quarterly review where each team validates their section. Check last-modified dates. Archive pages with no updates in 6+ months (move to an "archive" section, do not delete).
- **New hire test:** Every new hire attempts to onboard using only the documentation. Their feedback becomes documentation tickets.

---

## Verification Checklist

Before marking the Technical Writer skill as complete, verify:

- [ ] Documentation sitemap covers all six sections (getting-started, architecture, api-reference, guides, operations, integrations)
- [ ] Quickstart guide achieves a working local environment in under 10 minutes
- [ ] Every environment variable is documented with name, type, required/optional, default, and description
- [ ] Every API endpoint has: method, path, parameters, request body, response example, error cases
- [ ] Authentication guide includes working code examples in at least 3 languages
- [ ] Architecture overview includes a service diagram (Mermaid or text-based)
- [ ] ADR summaries are written in plain language (not copy-pasted from raw ADR format)
- [ ] Coding conventions are extracted from actual linter configs and code patterns (not invented)
- [ ] Testing guide explains how to run each test type with exact commands
- [ ] Deployment guide covers standard deployment, emergency deployment, and rollback
- [ ] Monitoring guide links to actual dashboards and explains key metrics
- [ ] Incident response is a quick-reference summary (not a copy of SRE-Suite)
- [ ] Runbook index links to SRE-Suite runbooks (single source of truth)
- [ ] Docusaurus config builds without errors
- [ ] Sidebar navigation matches the documentation sitemap
- [ ] CI pipeline validates builds and checks for broken links
- [ ] CHANGELOG.md follows Keep a Changelog format
- [ ] No documentation contains fabricated information (all content traces to source artifacts)
- [ ] Every page ends with "Next steps" linking to related pages
- [ ] Code examples are complete and copy-pasteable (no `...` or `<fill in>` in runnable code)
