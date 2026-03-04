# SRE (Site Reliability Engineering) Skill

name: sre
description: Use when the DevOps infrastructure is deployed and you need to make it production-survivable — defining SLOs, building chaos experiments, creating incident management procedures, capacity planning, disaster recovery, and writing service-specific operational runbooks that go beyond generic monitoring.

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

| Artifact | Source | What SRE Needs From It |
|---|---|---|
| `Claude-Production-Grade-Suite/devops/terraform/` | DevOps skill | Infrastructure definitions — resource limits, instance types, networking topology |
| `Claude-Production-Grade-Suite/devops/ci-cd/` | DevOps skill | Pipeline definitions — deployment strategy, rollback mechanisms, canary configs |
| `Claude-Production-Grade-Suite/devops/kubernetes/` | DevOps skill | K8s manifests — pod specs, resource requests/limits, HPA configs, health probes |
| `Claude-Production-Grade-Suite/devops/monitoring/` | DevOps skill | Base alerting rules, dashboard templates, log aggregation setup |
| Architecture docs (ADRs, service map) | Architect skill | Service boundaries, dependencies, data flow, consistency requirements |
| Test results / coverage reports | Testing skill | Failure modes already tested, load test baselines |
| `Claude-Production-Grade-Suite/product-manager/` or requirements docs | BA skill | Business-criticality tiers, availability requirements, user-facing SLA commitments |

## Distinction: DevOps vs. SRE

This boundary must be respected. Blurring it produces duplicate work and conflicting configs.

| Concern | DevOps Owns | SRE Owns |
|---|---|---|
| Infrastructure provisioning | Terraform modules, cloud resources | Reviews for reliability anti-patterns |
| CI/CD pipelines | Build, test, deploy automation | Deployment safety (canary analysis, rollback triggers) |
| Monitoring setup | Prometheus/Grafana/Datadog installation, base dashboards | SLI instrumentation, SLO burn-rate alerts, error budget dashboards |
| Alerting | Infrastructure-level alerts (disk, CPU, memory) | Service-level alerts tied to SLOs, on-call routing, escalation |
| Kubernetes | Manifest authoring, Helm charts, namespace setup | Resource tuning, disruption budgets, topology spread, chaos injection |
| Incident response | Provides the tools (logging, tracing) | Owns the process (classification, escalation, war rooms, postmortems) |
| Disaster recovery | Backup infrastructure (S3 buckets, snapshot schedules) | RTO/RPO validation, failover testing, recovery playbooks |

## Output Structure

All outputs are written to `Claude-Production-Grade-Suite/sre/` in the project root.

```
Claude-Production-Grade-Suite/sre/
├── production-readiness/
│   ├── checklist.md
│   ├── findings.md
│   └── remediation.md
├── slo/
│   ├── sli-definitions.yaml
│   ├── slo-dashboard.json
│   ├── error-budget-policy.md
│   └── burn-rate-alerts.yaml
├── chaos/
│   ├── scenarios/
│   │   ├── pod-failure.yaml
│   │   ├── network-partition.yaml
│   │   ├── dependency-failure.yaml
│   │   └── resource-pressure.yaml
│   ├── game-day-playbook.md
│   └── steady-state-hypothesis.md
├── capacity/
│   ├── load-model.md
│   ├── scaling-configs.yaml
│   ├── cost-projection.md
│   └── bottleneck-analysis.md
├── incidents/
│   ├── on-call-rotation.yaml
│   ├── escalation-policy.md
│   ├── severity-classification.md
│   ├── communication-templates/
│   │   ├── statuspage-investigating.md
│   │   ├── statuspage-identified.md
│   │   ├── statuspage-resolved.md
│   │   ├── internal-slack-alert.md
│   │   └── customer-notification.md
│   └── war-room-checklist.md
├── disaster-recovery/
│   ├── rto-rpo-definitions.md
│   ├── failover-playbook.md
│   ├── backup-verification.md
│   └── recovery-procedures.md
└── runbooks/
    └── <service-name>/
        ├── high-error-rate.md
        ├── high-latency.md
        ├── out-of-memory.md
        └── dependency-down.md
```

---

## Phases

Execute these phases sequentially. Each phase builds on the previous. Do not skip phases. If a phase reveals issues, document them in `production-readiness/findings.md` and continue — do not block on remediation.

---

### Phase 1: Production Readiness Review

**Goal:** Systematically evaluate every service for production survivability. This is not a rubber stamp — it is an adversarial review.

**Inputs:**
- `Claude-Production-Grade-Suite/devops/kubernetes/` — pod specs, probes, resource limits
- `Claude-Production-Grade-Suite/devops/terraform/` — infrastructure sizing, redundancy
- Application source code — connection pooling, retry logic, timeout configs
- Architecture docs — dependency map, data stores, external integrations

**Process:**

1. **Read** all Kubernetes manifests and extract: readiness probes, liveness probes, startup probes, resource requests, resource limits, PodDisruptionBudgets, topology spread constraints, graceful shutdown configuration (preStop hooks, terminationGracePeriodSeconds).

2. **Read** application configuration for: connection pool sizes (database, HTTP clients, Redis), timeout values (connect, read, write, idle), retry policies (max retries, backoff strategy, jitter), circuit breaker thresholds.

3. **Read** Terraform/infrastructure configs for: multi-AZ deployment, load balancer health checks, auto-scaling policies, backup schedules, encryption at rest and in transit.

4. **Generate `production-readiness/checklist.md`** using this exact structure:

```markdown
# Production Readiness Checklist

## Service: <service-name>
Review Date: <date>
Reviewer: SRE Skill (automated)

### Health Checks
- [ ] Readiness probe configured with appropriate path and thresholds
- [ ] Liveness probe configured (distinct from readiness)
- [ ] Startup probe configured for slow-starting services
- [ ] Health check endpoints verify downstream dependencies
- [ ] Health checks do NOT perform expensive operations

### Graceful Shutdown
- [ ] preStop hook configured with sleep or drain logic
- [ ] terminationGracePeriodSeconds > preStop + drain time
- [ ] Application handles SIGTERM and drains in-flight requests
- [ ] Long-running connections (WebSocket, gRPC streams) are drained

### Connection Management
- [ ] Database connection pool sized correctly (not default)
- [ ] HTTP client connection pools configured with limits
- [ ] Idle connection timeout set to prevent stale connections
- [ ] Connection pool metrics exposed

### Timeout Tuning
- [ ] Upstream timeout > downstream timeout (no orphaned requests)
- [ ] Connect timeout distinct from read timeout
- [ ] Global request timeout configured at ingress/gateway
- [ ] Timeout values documented and justified

### Retry Configuration
- [ ] Retries configured with exponential backoff
- [ ] Jitter applied to prevent thundering herd
- [ ] Retry budget capped (e.g., max 10% additional load)
- [ ] Non-idempotent operations are NOT retried
- [ ] Circuit breaker wraps retry logic

### Resource Limits
- [ ] CPU request and limit set (limit >= 2x request for bursty services)
- [ ] Memory request and limit set (limit == request for predictable OOM behavior)
- [ ] Ephemeral storage limits set
- [ ] PodDisruptionBudget configured (minAvailable or maxUnavailable)

### Data Safety
- [ ] Backup schedule configured and verified
- [ ] Point-in-time recovery tested
- [ ] Data encryption at rest enabled
- [ ] Data encryption in transit enforced (mTLS or TLS)

### Dependency Resilience
- [ ] All external dependencies have circuit breakers
- [ ] Fallback behavior defined for each dependency failure
- [ ] Dependency health is NOT part of liveness probe
- [ ] Timeout on every outbound call
```

5. **Generate `production-readiness/findings.md`** documenting every checklist item that fails, with severity (Critical / High / Medium / Low) and specific evidence from the configs.

6. **Generate `production-readiness/remediation.md`** with concrete fix instructions for every finding. Include exact config changes, code snippets, and Kubernetes manifest patches. Prioritize by severity.

---

### Phase 2: SLO Refinement

**Goal:** Transform DevOps monitoring into business-aligned SLOs with actionable error budgets.

**Inputs:**
- `Claude-Production-Grade-Suite/devops/monitoring/` — existing Prometheus rules, Grafana dashboards
- `Claude-Production-Grade-Suite/product-manager/` or requirements — availability promises, user expectations
- Architecture docs — request flow, critical paths, dependency chains
- Phase 1 findings — known reliability risks

**Process:**

1. **Identify SLIs** for each service. Use these categories:

   - **Availability:** proportion of successful requests (HTTP 5xx exclusion, gRPC status codes)
   - **Latency:** proportion of requests faster than threshold (p50, p95, p99)
   - **Throughput:** requests per second within acceptable range
   - **Correctness:** proportion of responses returning correct data (for data pipelines)
   - **Freshness:** proportion of data updated within acceptable staleness window

2. **Generate `slo/sli-definitions.yaml`** with this structure:

```yaml
slis:
  - name: api-availability
    service: api-gateway
    type: availability
    description: Proportion of HTTP requests that do not return 5xx
    good_event: http_requests_total{status!~"5.."}
    valid_event: http_requests_total
    measurement_window: 28d

  - name: api-latency-p99
    service: api-gateway
    type: latency
    description: Proportion of HTTP requests served within 500ms
    good_event: http_request_duration_seconds_bucket{le="0.5"}
    valid_event: http_request_duration_seconds_count
    threshold: 500ms
    measurement_window: 28d

slos:
  - name: api-availability-slo
    sli: api-availability
    target: 99.9
    window: 28d
    consequences: |
      If error budget exhausted: freeze deployments,
      redirect engineering effort to reliability work.

  - name: api-latency-slo
    sli: api-latency-p99
    target: 99.0
    window: 28d
    consequences: |
      If error budget below 25%: require performance review
      for all new features before deployment.
```

3. **Generate `slo/error-budget-policy.md`** defining:
   - Error budget calculation method (1 - SLO target = budget)
   - Budget consumption thresholds and corresponding actions
   - Who has authority to freeze deployments
   - How budget resets (rolling window vs. calendar)
   - Exception process for emergency deployments during budget freeze

4. **Generate `slo/burn-rate-alerts.yaml`** using multi-window, multi-burn-rate alerting (Google SRE workbook method):

```yaml
groups:
  - name: slo-burn-rate
    rules:
      # Fast burn — 2% budget consumed in 1 hour (page)
      - alert: SLOHighBurnRate_Critical
        expr: |
          (
            sum(rate(http_requests_total{status=~"5.."}[1h]))
            / sum(rate(http_requests_total[1h]))
          ) > (14.4 * (1 - 0.999))
          AND
          (
            sum(rate(http_requests_total{status=~"5.."}[5m]))
            / sum(rate(http_requests_total[5m]))
          ) > (14.4 * (1 - 0.999))
        for: 2m
        labels:
          severity: critical
          slo: api-availability
        annotations:
          summary: "High SLO burn rate — 2% error budget consumed in 1h"
          runbook: "../runbooks/api/high-error-rate.md"

      # Slow burn — 5% budget consumed in 6 hours (ticket)
      - alert: SLOHighBurnRate_Warning
        expr: |
          (
            sum(rate(http_requests_total{status=~"5.."}[6h]))
            / sum(rate(http_requests_total[6h]))
          ) > (6 * (1 - 0.999))
          AND
          (
            sum(rate(http_requests_total{status=~"5.."}[30m]))
            / sum(rate(http_requests_total[30m]))
          ) > (6 * (1 - 0.999))
        for: 5m
        labels:
          severity: warning
          slo: api-availability
        annotations:
          summary: "Elevated SLO burn rate — 5% error budget consumed in 6h"
          runbook: "../runbooks/api/high-error-rate.md"
```

5. **Generate `slo/slo-dashboard.json`** as a Grafana dashboard JSON containing:
   - SLO status panel (current attainment vs. target)
   - Error budget remaining (percentage and time-based)
   - Burn rate over time
   - Budget consumption trend (projected exhaustion date)
   - Per-service SLI breakdown

---

### Phase 3: Chaos Engineering

**Goal:** Proactively discover failure modes before users do. Build confidence that the system degrades gracefully.

**Inputs:**
- Architecture docs — dependency map, single points of failure
- `Claude-Production-Grade-Suite/devops/kubernetes/` — deployment topology
- Phase 1 findings — known weaknesses to target
- Phase 2 SLOs — steady-state metrics to monitor during experiments

**Process:**

1. **Generate `chaos/steady-state-hypothesis.md`** defining what "healthy" looks like in measurable terms. Every chaos experiment must validate against this hypothesis:

```markdown
# Steady-State Hypothesis

## Definition
The system is in steady state when ALL of the following are true:

### Service Health
- API availability SLI > 99.9% over the last 5 minutes
- API p99 latency < 500ms over the last 5 minutes
- All readiness probes passing
- No pods in CrashLoopBackOff

### Data Integrity
- Database replication lag < 1 second
- Message queue consumer lag < 1000 messages
- Cache hit rate > 80%

### Business Metrics
- Order completion rate > 95% of baseline
- User-facing error rate < 0.1%
```

2. **Generate chaos scenario files** in `chaos/scenarios/`. Use Chaos Mesh CRD format (with Litmus and Gremlin equivalents in comments):

   **`pod-failure.yaml`** — Kill random pods to validate self-healing:
   ```yaml
   apiVersion: chaos-mesh.org/v1alpha1
   kind: PodChaos
   metadata:
     name: pod-kill-api
     namespace: chaos-testing
   spec:
     action: pod-kill
     mode: one
     selector:
       namespaces: [production]
       labelSelectors:
         app: api-gateway
     duration: "60s"
     scheduler:
       cron: "@every 5m"  # Only during game days
   ---
   # Expected behavior:
   # - Kubernetes reschedules the pod within 30s
   # - Readiness probe prevents traffic to new pod until ready
   # - No user-visible errors (other pods absorb traffic)
   # - SLO burn rate does not spike
   #
   # Litmus equivalent: pod-delete experiment
   # Gremlin equivalent: State > Shutdown
   ```

   **`network-partition.yaml`** — Simulate network failures between services:
   ```yaml
   apiVersion: chaos-mesh.org/v1alpha1
   kind: NetworkChaos
   metadata:
     name: network-partition-db
     namespace: chaos-testing
   spec:
     action: partition
     mode: all
     selector:
       namespaces: [production]
       labelSelectors:
         app: api-gateway
     direction: to
     target:
       selector:
         namespaces: [production]
         labelSelectors:
           app: database
     duration: "120s"
   ---
   # Expected behavior:
   # - Circuit breaker trips within 10s
   # - Fallback responses served (cached data or graceful degradation)
   # - Alerts fire within 2 minutes
   # - System recovers automatically when partition heals
   ```

   **`dependency-failure.yaml`** — Simulate external dependency outages:
   ```yaml
   apiVersion: chaos-mesh.org/v1alpha1
   kind: NetworkChaos
   metadata:
     name: external-dependency-failure
     namespace: chaos-testing
   spec:
     action: loss
     mode: all
     selector:
       namespaces: [production]
       labelSelectors:
         app: payment-service
     loss:
       loss: "100"
     direction: to
     externalTargets:
       - "payment-provider.example.com"
     duration: "300s"
   ---
   # Expected behavior:
   # - Payment requests fail fast (circuit breaker)
   # - Orders queue for retry (not lost)
   # - User sees "payment processing delayed" (not a 500)
   # - Alerting escalates to on-call within 5 minutes
   ```

   **`resource-pressure.yaml`** — Simulate CPU/memory/disk pressure:
   ```yaml
   apiVersion: chaos-mesh.org/v1alpha1
   kind: StressChaos
   metadata:
     name: cpu-stress-api
     namespace: chaos-testing
   spec:
     mode: one
     selector:
       namespaces: [production]
       labelSelectors:
         app: api-gateway
     stressors:
       cpu:
         workers: 4
         load: 80
       memory:
         workers: 2
         size: "512MB"
     duration: "180s"
   ---
   # Expected behavior:
   # - HPA triggers scale-out within 2 minutes
   # - Latency degrades but stays within SLO
   # - No OOMKills (memory limits correctly set)
   # - CPU throttling visible in metrics
   ```

3. **Generate `chaos/game-day-playbook.md`** with this structure:

```markdown
# Game Day Playbook

## Pre-Game Day (1 week before)
- [ ] Schedule game day window (2-4 hours, business hours)
- [ ] Notify all on-call engineers and stakeholders
- [ ] Verify steady-state hypothesis metrics are accessible
- [ ] Confirm rollback procedures for each experiment
- [ ] Set up dedicated Slack channel for game day comms
- [ ] Verify chaos tooling is installed and authorized in target namespace
- [ ] Brief participants on experiment sequence and abort criteria

## Abort Criteria
Immediately halt ALL experiments if:
- User-facing error rate exceeds 1% for more than 2 minutes
- Data corruption is detected
- Payment processing completely stops
- On-call receives customer reports of outages

## Experiment Sequence

### Round 1: Pod Resilience (Low Risk)
1. Record steady-state metrics baseline
2. Execute pod-failure.yaml against non-critical service
3. Observe for 5 minutes, record behavior
4. Execute pod-failure.yaml against critical service (api-gateway)
5. Observe for 5 minutes, record behavior
6. Document findings

### Round 2: Network Chaos (Medium Risk)
1. Verify steady state restored from Round 1
2. Execute network-partition.yaml (service-to-database)
3. Observe circuit breaker behavior for 3 minutes
4. Remove partition, observe recovery
5. Document time-to-detect, time-to-recover

### Round 3: Dependency Failure (Medium Risk)
1. Verify steady state restored from Round 2
2. Execute dependency-failure.yaml
3. Observe fallback behavior
4. Verify queued operations retry after recovery
5. Document data integrity check results

### Round 4: Resource Pressure (Higher Risk)
1. Verify steady state restored from Round 3
2. Execute resource-pressure.yaml
3. Observe HPA behavior and scaling timeline
4. Verify SLOs maintained during scale-out
5. Document scaling decisions and latency impact

## Post-Game Day
- [ ] Compile findings into incident-style report
- [ ] File tickets for every unexpected behavior
- [ ] Update runbooks with discoveries
- [ ] Schedule follow-up game day in 30 days
- [ ] Present findings to engineering team
```

---

### Phase 4: Capacity Planning

**Goal:** Model current and future load, validate auto-scaling, project costs, and identify bottlenecks before they hit production.

**Inputs:**
- `Claude-Production-Grade-Suite/devops/monitoring/` — current traffic metrics, resource utilization
- `Claude-Production-Grade-Suite/devops/kubernetes/` — HPA configs, resource limits
- `Claude-Production-Grade-Suite/devops/terraform/` — infrastructure sizing, instance types
- Architecture docs — request fan-out ratios, data growth patterns
- Business requirements — growth projections, seasonal patterns

**Process:**

1. **Generate `capacity/load-model.md`** containing:

```markdown
# Load Model

## Current Baseline
| Metric | Value | Source |
|---|---|---|
| Peak RPS (requests/sec) | <measured> | Prometheus: rate(http_requests_total[5m]) |
| Average RPS | <measured> | Prometheus: rate(http_requests_total[1h]) |
| P99 latency at peak | <measured> | Prometheus: histogram_quantile(0.99, ...) |
| Daily active users | <measured> | Analytics |
| Database QPS | <measured> | Database metrics |
| Message queue throughput | <measured> | Queue metrics |

## Request Fan-Out
For each user-facing request, the internal amplification:
| User Action | Internal Requests | Database Queries | Cache Operations | Queue Messages |
|---|---|---|---|---|
| Page load | 5 API calls | 12 queries | 8 reads | 0 |
| Submit order | 3 API calls | 8 queries, 3 writes | 2 reads, 4 invalidations | 3 messages |
| Search | 2 API calls | 1 query (Elasticsearch) | 1 read | 0 |

## Growth Projections
| Scale | RPS | DB QPS | Storage Growth/mo | Est. Monthly Cost |
|---|---|---|---|---|
| Current (1x) | <val> | <val> | <val> | <val> |
| 10x | <val> | <val> | <val> | <val> |
| 100x | <val> | <val> | <val> | <val> |

## Seasonal Patterns
- <Document known traffic patterns: day-of-week, time-of-day, holidays, marketing events>
```

2. **Generate `capacity/scaling-configs.yaml`** with validated HPA/VPA/KEDA configurations:

```yaml
# Horizontal Pod Autoscaler — validated against load model
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: api-gateway-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: api-gateway
  minReplicas: 3          # Never go below 3 for redundancy
  maxReplicas: 50         # Ceiling based on cost projection
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 60    # Respond quickly to load spikes
      policies:
        - type: Percent
          value: 100      # Double pods if needed
          periodSeconds: 60
    scaleDown:
      stabilizationWindowSeconds: 300   # Cool down slowly to avoid flapping
      policies:
        - type: Percent
          value: 25       # Scale down 25% at a time
          periodSeconds: 120
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 65  # Scale before saturation
    - type: Pods
      pods:
        metric:
          name: http_requests_per_second
        target:
          type: AverageValue
          averageValue: "1000"    # Based on load test: 1200 RPS causes p99 degradation
```

3. **Generate `capacity/cost-projection.md`** with compute, storage, network, and managed-service costs at 1x, 10x, and 100x scale. Include recommendations for cost optimization (reserved instances, spot instances, right-sizing).

4. **Generate `capacity/bottleneck-analysis.md`** identifying the first component that will fail at each scale tier. Use this structure:

```markdown
# Bottleneck Analysis

## Methodology
Bottlenecks identified through: load testing results, resource utilization trends,
theoretical throughput limits, and architectural analysis.

## Bottleneck Ranking (First to Saturate)

### 1. Database Connection Pool
- **Current utilization:** 60% of max connections
- **Saturates at:** ~1.7x current load
- **Symptom:** Connection timeout errors, request queuing
- **Mitigation:** Connection pooler (PgBouncer), read replicas, query optimization
- **Cost to fix:** Low (configuration change)

### 2. Single Redis Instance
- **Current utilization:** 40% CPU, 70% memory
- **Saturates at:** ~3x current load
- **Symptom:** Cache latency increase, evictions spike
- **Mitigation:** Redis Cluster, key-space partitioning
- **Cost to fix:** Medium (architecture change)

### 3. Message Queue Consumer Throughput
- **Current utilization:** 200 msg/s of 500 msg/s capacity
- **Saturates at:** ~2.5x current load
- **Symptom:** Consumer lag grows, processing delays
- **Mitigation:** Add consumer instances, partition optimization
- **Cost to fix:** Low (scaling change)
```

---

### Phase 5: Incident Management

**Goal:** Build the organizational machinery to detect, respond to, and learn from incidents. The tools exist (from DevOps) — this phase wires them into a human process.

**Inputs:**
- Phase 2 SLOs and alerting rules — what triggers incidents
- Phase 3 chaos results — known failure modes
- Organization structure — team composition, time zones
- Existing tooling — PagerDuty/OpsGenie, Slack, Statuspage

**Process:**

1. **Generate `incidents/severity-classification.md`:**

```markdown
# Incident Severity Classification

## SEV1 — Critical
- **Definition:** Complete service outage OR data loss/corruption OR security breach
- **User impact:** All users affected, core functionality unavailable
- **Response time:** Immediate (within 5 minutes)
- **Communication:** Statuspage updated within 10 minutes, executive notification
- **War room:** Mandatory, video call opened immediately
- **Examples:** Database down, authentication service unreachable, payment processing halted

## SEV2 — High
- **Definition:** Significant degradation OR partial outage of critical feature
- **User impact:** Large subset of users affected, workaround may exist
- **Response time:** Within 15 minutes
- **Communication:** Statuspage updated within 30 minutes
- **War room:** Opened if not resolved within 30 minutes
- **Examples:** Elevated error rate (>1%), latency 5x normal, one region degraded

## SEV3 — Medium
- **Definition:** Minor feature degradation OR non-critical service issue
- **User impact:** Small subset of users, non-critical functionality
- **Response time:** Within 1 hour (business hours)
- **Communication:** Internal Slack notification
- **War room:** Not required
- **Examples:** Admin panel slow, email notifications delayed, search results stale

## SEV4 — Low
- **Definition:** Cosmetic issue OR minor inconvenience OR proactive risk
- **User impact:** Minimal to none
- **Response time:** Next business day
- **Communication:** Ticket created
- **War room:** Not required
- **Examples:** Error budget warning, non-critical dependency degraded, log volume anomaly
```

2. **Generate `incidents/on-call-rotation.yaml`:**

```yaml
# PagerDuty / OpsGenie rotation configuration
rotations:
  - name: primary-on-call
    type: weekly
    participants:
      - team: platform-engineering
    handoff:
      day: Monday
      time: "10:00"
      timezone: "America/New_York"
    restrictions:
      - type: business_hours
        start: "09:00"
        end: "18:00"

  - name: secondary-on-call
    type: weekly
    participants:
      - team: platform-engineering
    handoff:
      day: Monday
      time: "10:00"
      timezone: "America/New_York"
    description: >
      Secondary is the previous week's primary.
      Provides continuity and mentorship for new on-call.

overrides:
  holiday_coverage:
    description: "Volunteer-based with 2x comp time"
    advance_notice_days: 14

on_call_expectations:
  acknowledge_within: 5m
  response_within: 15m
  laptop_required: true
  escalation_if_no_ack: 10m
  compensation: "Per company on-call policy"
```

3. **Generate `incidents/escalation-policy.md`** defining the escalation chain for each severity level, including timeout-based auto-escalation.

4. **Generate `incidents/communication-templates/`** with pre-written templates for statuspage updates (Investigating, Identified, Monitoring, Resolved), internal Slack alerts, and customer-facing email notifications. Each template includes placeholders and instructions for what information to fill in.

5. **Generate `incidents/war-room-checklist.md`:**

```markdown
# War Room Procedures

## Opening a War Room
1. Create dedicated Slack channel: #incident-YYYY-MM-DD-<short-description>
2. Start video call (link in channel topic)
3. Assign roles:
   - **Incident Commander (IC):** Coordinates response, makes decisions
   - **Communications Lead:** Updates statuspage, stakeholders
   - **Technical Lead:** Drives debugging, delegates investigation
   - **Scribe:** Documents timeline, actions, decisions in real-time
4. Pin the incident channel with: severity, start time, user impact, assigned roles

## During the War Room
- IC runs the call. Others speak when addressed or when they have critical info.
- Every 15 minutes: IC summarizes current status and next steps
- Communications Lead updates statuspage every 30 minutes minimum
- Scribe maintains running timeline in pinned thread
- NO changes to production without IC approval
- If current IC needs to hand off, explicit verbal handoff required

## Closing a War Room
1. Confirm service restored and metrics stable for 15 minutes
2. Update statuspage to Resolved
3. Send internal all-clear notification
4. Schedule postmortem within 48 hours
5. Create follow-up tickets for all identified action items
6. Archive incident channel (do not delete)
```

---

### Phase 6: Disaster Recovery

**Goal:** Define, document, and validate the ability to recover from catastrophic failures. Not theoretical — every procedure must be tested.

**Inputs:**
- `Claude-Production-Grade-Suite/devops/terraform/` — infrastructure topology, regions, backup configs
- Architecture docs — data stores, replication topology, state management
- Business requirements — acceptable downtime, data loss tolerance
- Phase 1 findings — backup verification status

**Process:**

1. **Generate `disaster-recovery/rto-rpo-definitions.md`:**

```markdown
# RTO/RPO Definitions

| Service | RPO (max data loss) | RTO (max downtime) | Justification |
|---|---|---|---|
| Primary database | 1 minute | 15 minutes | Financial transactions, point-in-time recovery |
| User sessions | 0 (replicated) | 5 minutes | Active user impact, Redis replication |
| File storage | 24 hours | 1 hour | S3 cross-region replication lag acceptable |
| Search index | 4 hours | 30 minutes | Can rebuild from primary database |
| Message queue | 0 (replicated) | 10 minutes | In-flight messages must not be lost |
| Analytics data | 24 hours | 4 hours | Non-critical, can backfill |

## Definitions
- **RPO (Recovery Point Objective):** Maximum acceptable data loss measured in time.
  If RPO = 1 hour, you can lose at most 1 hour of data.
- **RTO (Recovery Time Objective):** Maximum acceptable downtime.
  If RTO = 15 minutes, the service must be operational within 15 minutes of a disaster.
```

2. **Generate `disaster-recovery/failover-playbook.md`** with step-by-step procedures for:
   - Database failover (primary to replica promotion)
   - Region failover (Route53/CloudFront failover, DNS TTL considerations)
   - Complete cluster rebuild from infrastructure-as-code
   - Partial service recovery (bring up critical path first)
   - Include verification steps after each failover action
   - Include estimated time for each step

3. **Generate `disaster-recovery/backup-verification.md`** with:
   - Automated backup verification procedures (scheduled restores to test environment)
   - Backup integrity checksums
   - Backup restoration time benchmarks
   - Quarterly full-restoration drill procedure
   - Backup monitoring alerts (failed backups, backup age)

4. **Generate `disaster-recovery/recovery-procedures.md`** with service-specific recovery instructions including:
   - Data recovery from backups
   - State reconstruction procedures
   - Cache warming procedures after recovery
   - Post-recovery validation checklist
   - Communication procedures during recovery

---

### Phase 7: Operational Runbooks

**Goal:** Write runbooks that an on-call engineer woken at 3 AM can follow without thinking. These are not generic — they are specific to THIS system, with real commands, real thresholds, and decision trees.

**Inputs:**
- ALL previous phases — alerts, SLOs, chaos findings, architecture
- `Claude-Production-Grade-Suite/devops/monitoring/` — alert definitions, metric names
- Application source code — for service-specific debugging commands

**Process:**

For each service identified in the architecture, generate a directory under `runbooks/<service-name>/` with runbooks for every alert. Each runbook MUST follow this template:

```markdown
# Runbook: <Alert Name>

## Alert Details
- **Severity:** <SEV level>
- **Alert rule:** <Prometheus/Datadog alert name>
- **Fires when:** <human-readable condition>
- **SLO impact:** <which SLO this affects and burn rate implication>

## Triage (First 5 Minutes)

### 1. Assess Scope
<Exact commands to determine impact scope>

```bash
# Check error rate across all instances
kubectl exec -n monitoring prometheus-0 -- promtool query instant \
  'sum(rate(http_requests_total{status=~"5..",service="<service>"}[5m])) / sum(rate(http_requests_total{service="<service>"}[5m]))'

# Check affected pods
kubectl get pods -n production -l app=<service> -o wide

# Check recent deployments (was this caused by a deploy?)
kubectl rollout history deployment/<service> -n production
```

### 2. Decision Tree

```
Is error rate > 10%?
├── YES → Go to "Emergency Mitigation"
└── NO
    ├── Is it correlated with a recent deployment?
    │   ├── YES → Go to "Rollback Procedure"
    │   └── NO
    │       ├── Is a downstream dependency unhealthy?
    │       │   ├── YES → Go to "Dependency Failure"
    │       │   └── NO → Go to "Deep Investigation"
```

## Emergency Mitigation
<Steps to stop the bleeding immediately, before root cause is known>

## Rollback Procedure
```bash
# Identify the previous revision
kubectl rollout history deployment/<service> -n production

# Rollback to previous revision
kubectl rollout undo deployment/<service> -n production

# Verify rollback
kubectl rollout status deployment/<service> -n production --timeout=120s

# Confirm error rate recovering
watch -n5 'kubectl exec -n monitoring prometheus-0 -- promtool query instant \
  "sum(rate(http_requests_total{status=~\"5..\",service=\"<service>\"}[1m])) / sum(rate(http_requests_total{service=\"<service>\"}[1m]))"'
```

## Dependency Failure
<Steps to isolate and work around failed dependency>

## Deep Investigation
<Systematic debugging: logs, traces, recent changes, resource utilization>

## Resolution Verification
- [ ] Error rate returned to baseline
- [ ] SLO burn rate normalized
- [ ] No error log anomalies
- [ ] Downstream services healthy
- [ ] Update incident channel with resolution

## Post-Incident
- [ ] Create postmortem document
- [ ] File follow-up tickets
- [ ] Update this runbook if new information discovered
```

Generate at minimum these runbooks per service:
- `high-error-rate.md` — elevated 5xx responses
- `high-latency.md` — p99 latency exceeding SLO threshold
- `out-of-memory.md` — OOMKilled pods, memory pressure
- `dependency-down.md` — downstream service or external API unreachable

Add additional runbooks for service-specific failure modes discovered during chaos engineering (Phase 3) or identified in the architecture (e.g., `queue-consumer-lag.md`, `database-replication-lag.md`, `certificate-expiry.md`).

---

## Common Mistakes

| Mistake | Why It Fails | What To Do Instead |
|---|---|---|
| Setting SLOs at 99.99% for every service | Leaves near-zero error budget, blocks all deployments, nobody takes it seriously | Set SLOs based on user-observable impact. Internal services get lower targets. Start with 99.5% and tighten. |
| Writing generic runbooks ("check the logs") | On-call engineer at 3 AM cannot figure out WHICH logs, WHERE, or what to look for | Include exact commands with real metric names, real pod labels, real log queries. Decision trees, not paragraphs. |
| Chaos experiments in production without steady-state definition | No way to tell if the experiment caused harm or if the system was already degraded | Always define and verify steady-state hypothesis BEFORE injecting failure. Automate the check. |
| Skipping the abort criteria for game days | Chaos experiment causes a real outage because nobody defined when to stop | Written abort criteria with specific thresholds, agreed upon before the game day starts. |
| RTO/RPO definitions without testing | "We can recover in 15 minutes" but nobody has ever actually done it | Run quarterly DR drills. Time the actual recovery. Update RTO estimates with real data. |
| Alerting on symptoms without connecting to SLOs | Alert fatigue — hundreds of alerts fire, none indicate actual user impact | Tie every alert to an SLO. If an alert does not map to an SLO, it is a log line, not a page. |
| Copy-pasting PagerDuty rotation without escalation policy | Primary on-call does not respond, nobody else gets notified, outage continues | Define escalation timeouts: 5 min to primary, 10 min to secondary, 15 min to engineering manager. |
| Capacity planning based on averages, not peaks | System handles average load fine, falls over on Monday morning or after a marketing push | Model peak load (p99 of daily traffic), seasonal spikes, and known events. Size for peaks, not averages. |
| Error budget policy without enforcement mechanism | Budget exhausts, nothing happens, SLOs become aspirational fiction | Define concrete consequences: deployment freeze, reliability sprint, executive review. Get management buy-in BEFORE the budget exhausts. |
| Disaster recovery plan that only covers the database | Application state, cache warming, DNS propagation, certificate validity all ignored | DR must cover the entire request path: DNS, CDN, load balancer, application, cache, database, queues, external dependencies. |
| Runbooks that do not specify who to escalate to | Engineer fixes the symptom but the underlying issue reoccurs because the right team was never involved | Every runbook ends with escalation contacts: owning team, database team, infrastructure team, with Slack handles. |
| Putting SLO dashboards only in Grafana | Engineers see them, but product and leadership (who decide priorities) do not | Create a weekly SLO report sent to engineering and product leadership. Make error budget a planning input. |

---

## Handoff to Next Phase

After SRE-Suite is complete, the following artifacts are ready for downstream consumption:

| Consumer | What They Get |
|---|---|
| Technical Writer skill | Operational documentation source material: runbooks, incident procedures, DR playbooks, SLO definitions |
| Development teams | Production readiness checklist (integrate into PR review), runbooks (on-call reference), SLO targets (feature planning input) |
| Platform/DevOps team | Chaos experiment results (infrastructure improvements), capacity bottleneck list (scaling priorities), scaling configs (HPA/VPA tuning) |
| Management/Leadership | SLO dashboards, error budget reports, cost projections, DR readiness status |

---

## Verification Checklist

Before marking the SRE skill as complete, verify:

- [ ] Every service in the architecture has a production readiness review
- [ ] Every user-facing endpoint has at least one SLO (availability + latency)
- [ ] Error budget policy is documented with specific enforcement actions
- [ ] Burn-rate alerts are configured with multi-window approach (not just threshold-based)
- [ ] At least 4 chaos scenarios are defined with steady-state hypothesis
- [ ] Game day playbook has explicit abort criteria
- [ ] Load model covers 1x, 10x, and 100x projections
- [ ] Bottleneck analysis identifies the first 3 components to saturate
- [ ] On-call rotation covers 24/7 with escalation policy
- [ ] Severity classification has concrete examples for each level
- [ ] Communication templates are pre-written (not "write a statuspage update")
- [ ] War room procedures define explicit roles (IC, comms, tech lead, scribe)
- [ ] RTO/RPO defined for every stateful component
- [ ] Failover playbook has been reviewed against actual infrastructure topology
- [ ] Every alert has a corresponding runbook with exact commands
- [ ] Runbooks include decision trees, not just prose
- [ ] All runbook commands use real metric names and pod labels from this system
