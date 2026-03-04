---
name: devops
description: Use when setting up CI/CD pipelines, infrastructure as code, container orchestration, monitoring, or cloud deployments. Triggers on "setup CI/CD", "deploy to cloud", "infrastructure", "Terraform", "Kubernetes", "Docker", "monitoring", "DevOps", "pipeline", or when preparing a codebase for production deployment.
---

# DevOps

## Overview

Full DevOps pipeline generator: from infrastructure design to production-ready deployment with monitoring and security. Generates a `Claude-Production-Grade-Suite/devops/` folder in the project root containing Terraform modules, CI/CD pipelines, container configs, monitoring dashboards, and security policies for AWS, GCP, and Azure.

## When to Use

- Setting up CI/CD pipelines for a new or existing project
- Creating infrastructure as code for cloud deployments
- Containerizing applications with Docker/Kubernetes
- Configuring monitoring, logging, and alerting
- Implementing security scanning and secrets management
- Multi-cloud or hybrid-cloud deployment planning
- Production readiness review and hardening

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

## Process Flow

```dot
digraph devops {
    rankdir=TB;
    "Triggered" [shape=doublecircle];
    "Phase 1: Assessment" [shape=box];
    "Phase 2: IaC" [shape=box];
    "Phase 3: CI/CD" [shape=box];
    "Phase 4: Containers" [shape=box];
    "Phase 5: Monitoring" [shape=box];
    "Phase 6: Security" [shape=box];
    "User Review" [shape=diamond];
    "Suite Complete" [shape=doublecircle];

    "Triggered" -> "Phase 1: Assessment";
    "Phase 1: Assessment" -> "Phase 2: IaC";
    "Phase 2: IaC" -> "User Review";
    "User Review" -> "Phase 2: IaC" [label="revise"];
    "User Review" -> "Phase 3: CI/CD" [label="approved"];
    "Phase 3: CI/CD" -> "Phase 4: Containers";
    "Phase 4: Containers" -> "Phase 5: Monitoring";
    "Phase 5: Monitoring" -> "Phase 6: Security";
    "Phase 6: Security" -> "Suite Complete";
}
```

## Phase 1: Infrastructure Assessment

Use AskUserQuestion to gather (batch into 2-3 calls max):

1. **Current state** — Existing infra? Greenfield? Migration? What's already running?
2. **Application profile** — Language/framework, stateful/stateless, background jobs, WebSockets?
3. **Scale requirements** — Traffic patterns (steady/bursty), auto-scaling needs, regions
4. **Environments** — How many? (dev/staging/prod minimum), environment parity strategy
5. **Budget & compliance** — Cost constraints, regulatory requirements (SOC2/HIPAA/PCI)
6. **Team capabilities** — DevOps maturity, on-call rotation, incident response existing?

## Phase 2: Infrastructure as Code (Terraform)

Generate `Claude-Production-Grade-Suite/devops/terraform/`:

### Module Structure
```
terraform/
├── modules/
│   ├── networking/      # VPC, subnets, security groups, NAT
│   ├── compute/         # ECS/EKS/GKE/AKS clusters
│   ├── database/        # RDS/Cloud SQL/Azure SQL, Redis
│   ├── messaging/       # SQS/Pub-Sub/Service Bus
│   ├── storage/         # S3/GCS/Blob, CDN
│   ├── monitoring/      # CloudWatch/Cloud Monitoring/Azure Monitor
│   ├── security/        # IAM, KMS, WAF, secrets
│   └── dns/             # Route53/Cloud DNS/Azure DNS
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars
│   │   └── backend.tf
│   ├── staging/
│   └── prod/
├── global/              # Shared resources (IAM, DNS zones)
└── README.md
```

### Terraform Standards
- **Remote state** — S3/GCS/Azure Blob backend with state locking (DynamoDB/GCS/Azure Table)
- **Module versioning** — Pinned module versions, semantic versioning
- **Variable validation** — `validation` blocks on all input variables
- **Tagging strategy** — `environment`, `service`, `team`, `cost-center`, `managed-by=terraform`
- **Least privilege IAM** — Service-specific roles, no wildcard permissions
- **Encryption everywhere** — KMS-managed keys for storage, databases, secrets
- **Network isolation** — Private subnets for compute/data, public only for load balancers

### Multi-Cloud Provider Configs
Generate provider blocks and modules for each target cloud:

| Resource | AWS | GCP | Azure |
|----------|-----|-----|-------|
| Compute | ECS Fargate / EKS | Cloud Run / GKE | Container Apps / AKS |
| Database | RDS Aurora | Cloud SQL | Azure SQL |
| Cache | ElastiCache Redis | Memorystore | Azure Cache Redis |
| Queue | SQS + SNS | Pub/Sub | Service Bus |
| Storage | S3 + CloudFront | GCS + Cloud CDN | Blob + Front Door |
| Secrets | Secrets Manager | Secret Manager | Key Vault |
| DNS | Route 53 | Cloud DNS | Azure DNS |
| WAF | AWS WAF | Cloud Armor | Azure WAF |

**Present IaC design to user for approval before proceeding.**

## Phase 3: CI/CD Pipelines

Generate `Claude-Production-Grade-Suite/devops/ci-cd/`:

### Pipeline Templates
```
ci-cd/
├── github-actions/
│   ├── ci.yml              # Build, test, lint, security scan
│   ├── cd-staging.yml      # Deploy to staging on merge to main
│   ├── cd-production.yml   # Deploy to prod on release tag
│   ├── pr-checks.yml       # PR validation (tests, lint, preview)
│   └── scheduled.yml       # Nightly builds, dependency updates
├── gitlab-ci/              # (if requested)
│   └── .gitlab-ci.yml
└── scripts/
    ├── build.sh
    ├── deploy.sh
    ├── rollback.sh
    └── smoke-test.sh
```

### CI Pipeline Stages
1. **Checkout & cache** — Restore dependency caches
2. **Install** — Dependencies with lockfile verification
3. **Lint** — Code style, formatting (fail-fast)
4. **Type check** — Static analysis (if applicable)
5. **Unit tests** — Parallel execution, coverage reporting
6. **Integration tests** — Against test containers (testcontainers)
7. **Security scan** — SAST (Semgrep/CodeQL), dependency audit (Snyk/Trivy)
8. **Build** — Docker image with content-hash tagging
9. **Push** — To ECR/GCR/ACR with immutable tags

### CD Pipeline Stages
1. **Deploy to staging** — Automatic on main branch merge
2. **Smoke tests** — Health checks + critical path verification
3. **Performance tests** — Load testing gate (k6/Artillery)
4. **Manual approval** — Required for production (GitHub Environments)
5. **Deploy to production** — Blue-green or canary strategy
6. **Post-deploy verification** — Automated smoke + synthetic monitoring
7. **Rollback trigger** — Automatic on error rate spike

### Deployment Strategies
Generate configs for the selected strategy:
- **Blue-Green** — Zero-downtime with instant rollback (default for stateless)
- **Canary** — Gradual traffic shift (10% → 25% → 50% → 100%) with automated rollback
- **Rolling** — For stateful services with ordered updates

## Phase 4: Container Orchestration

Generate `Claude-Production-Grade-Suite/devops/containers/`:

### Docker
```
containers/
├── dockerfiles/
│   └── <service>.Dockerfile    # Per-service, multi-stage
├── docker-compose.yml          # Local development
├── docker-compose.test.yml     # Integration test environment
└── .dockerignore
```

Dockerfile standards:
- Multi-stage builds (builder → runtime)
- Non-root user (`USER appuser`)
- Minimal base images (distroless/alpine)
- Layer caching optimization (dependencies before source)
- Health check instruction (`HEALTHCHECK`)
- No secrets in image layers
- `.dockerignore` excluding `.git`, `node_modules`, `__pycache__`, etc.

### Kubernetes
```
containers/
├── k8s/
│   ├── base/
│   │   ├── namespace.yaml
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   ├── ingress.yaml
│   │   ├── hpa.yaml
│   │   ├── pdb.yaml
│   │   └── networkpolicy.yaml
│   ├── overlays/
│   │   ├── dev/
│   │   ├── staging/
│   │   └── prod/
│   └── kustomization.yaml
└── helm/                       # (if requested)
    └── <service>/
        ├── Chart.yaml
        ├── values.yaml
        ├── values-prod.yaml
        └── templates/
```

K8s standards:
- **Resource limits** on all containers (CPU/memory requests and limits)
- **Pod Disruption Budgets** — `minAvailable: 1` minimum
- **Horizontal Pod Autoscaler** — CPU/memory/custom metrics
- **Network Policies** — Default deny, explicit allow
- **Service accounts** — Per-service, bound to cloud IAM
- **Readiness/liveness probes** — Distinct endpoints, tuned thresholds
- **Anti-affinity rules** — Spread pods across nodes/zones
- **Kustomize overlays** — Environment-specific overrides without duplication

## Phase 5: Monitoring & Observability

Generate `Claude-Production-Grade-Suite/devops/monitoring/`:

```
monitoring/
├── prometheus/
│   ├── prometheus.yml
│   ├── alerts/
│   │   ├── availability.yml
│   │   ├── latency.yml
│   │   ├── saturation.yml
│   │   └── errors.yml
│   └── recording-rules.yml
├── grafana/
│   ├── dashboards/
│   │   ├── overview.json
│   │   ├── per-service.json
│   │   ├── infrastructure.json
│   │   └── business-metrics.json
│   └── datasources.yml
├── logging/
│   ├── fluentbit.conf          # Log collection and forwarding
│   └── log-format.md           # Structured logging standard
├── tracing/
│   └── otel-collector.yaml     # OpenTelemetry Collector config
├── alerting/
│   ├── pagerduty.yml
│   ├── slack.yml
│   └── escalation-policy.md
├── slo/
│   └── slo-definitions.yaml    # SLI/SLO/SLA definitions
└── runbooks/
    ├── high-error-rate.md
    ├── high-latency.md
    ├── disk-full.md
    └── pod-crashloop.md
```

### Four Golden Signals (Required Dashboards)
1. **Latency** — p50, p90, p99 by endpoint, alerting on p99 breach
2. **Traffic** — RPS by service/endpoint, trend analysis
3. **Errors** — Error rate %, error budget burn rate
4. **Saturation** — CPU, memory, disk, connection pool utilization

### Observability Standards
- **Structured logging** — JSON format, mandatory fields: `timestamp`, `level`, `service`, `trace_id`, `message`
- **Distributed tracing** — OpenTelemetry SDK, W3C Trace Context propagation
- **Metrics** — RED method (Rate, Errors, Duration) for services, USE method (Utilization, Saturation, Errors) for infrastructure
- **SLO-based alerting** — Alert on error budget burn rate, not raw thresholds
- **Runbooks** — Every alert links to a runbook with diagnosis steps

## Phase 6: Security

Generate `Claude-Production-Grade-Suite/devops/security/`:

```
security/
├── scanning/
│   ├── sast-config.yml         # Semgrep/CodeQL rules
│   ├── dependency-scan.yml     # Snyk/Trivy config
│   ├── container-scan.yml      # Image vulnerability scanning
│   └── iac-scan.yml            # tfsec/checkov config
├── secrets/
│   ├── secrets-policy.md       # Secrets management standard
│   └── external-secrets.yaml   # External Secrets Operator config
├── network/
│   ├── waf-rules.tf            # WAF rule sets
│   ├── security-groups.tf      # Network access control
│   └── tls-config.md           # TLS 1.3 minimum, cert management
├── iam/
│   ├── service-roles.tf        # Per-service IAM roles
│   ├── ci-cd-roles.tf          # Pipeline execution roles
│   └── break-glass.md          # Emergency access procedures
├── compliance/
│   ├── checklist.md            # SOC2/HIPAA/GDPR checklist
│   └── data-classification.md  # PII/PHI data handling
└── incident-response/
    ├── playbook.md             # Incident response process
    └── post-mortem-template.md # Blameless post-mortem format
```

### Security Standards
- **Zero trust** — Verify every request, assume breach
- **Least privilege** — Minimal permissions, time-bounded access
- **Encryption** — At rest (KMS) and in transit (TLS 1.3)
- **Secret rotation** — Automated rotation via Secrets Manager
- **Container security** — No root, read-only filesystem, no capabilities
- **Supply chain** — Pin dependency versions, verify checksums, SBOM generation
- **Audit logging** — All admin actions logged, immutable audit trail

### CI Security Gates (Fail Pipeline on)
- Critical/High CVEs in dependencies
- Secrets detected in code (gitleaks/trufflehog)
- Terraform misconfigurations (tfsec severity: HIGH)
- Container image CVEs (Trivy severity: CRITICAL)
- SAST findings (Semgrep severity: ERROR)

## Suite Output Structure

```
Claude-Production-Grade-Suite/devops/
├── terraform/
│   ├── modules/
│   │   ├── networking/
│   │   ├── compute/
│   │   ├── database/
│   │   ├── messaging/
│   │   ├── storage/
│   │   ├── monitoring/
│   │   ├── security/
│   │   └── dns/
│   ├── environments/
│   │   ├── dev/
│   │   ├── staging/
│   │   └── prod/
│   └── global/
├── ci-cd/
│   ├── github-actions/
│   ├── scripts/
│   └── gitlab-ci/          # (optional)
├── containers/
│   ├── dockerfiles/
│   ├── k8s/
│   │   ├── base/
│   │   └── overlays/
│   ├── helm/               # (optional)
│   ├── docker-compose.yml
│   └── docker-compose.test.yml
├── monitoring/
│   ├── prometheus/
│   ├── grafana/
│   ├── logging/
│   ├── tracing/
│   ├── alerting/
│   ├── slo/
│   └── runbooks/
└── security/
    ├── scanning/
    ├── secrets/
    ├── network/
    ├── iam/
    ├── compliance/
    └── incident-response/
```

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Same Terraform state for all envs | Separate state per environment, shared modules |
| Secrets in environment variables | Use cloud Secrets Manager + External Secrets Operator |
| No rollback strategy | Blue-green or canary with automated rollback triggers |
| Monitoring without alerting | Every dashboard metric needs an alert threshold and runbook |
| Over-permissive IAM | Start with zero permissions, add as needed, review quarterly |
| Skipping staging | Staging must mirror prod topology, use same IaC modules |
| Docker images as root | Always `USER nonroot`, read-only filesystem where possible |
| Alert fatigue | SLO-based alerting, aggregate similar alerts, escalation tiers |
