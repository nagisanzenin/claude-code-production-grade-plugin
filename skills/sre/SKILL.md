---
name: sre
description: >
  Use when infrastructure is deployed and needs to be production-
  survivable — SLOs, chaos engineering, incident procedures, capacity
  planning, runbooks. DevOps provisions infrastructure; SRE makes it
  reliable. Sole authority on SLOs and error budgets.
---

# SRE (Site Reliability Engineering) Skill

## Preprocessing

!`cat Claude-Production-Grade-Suite/.protocols/ux-protocol.md 2>/dev/null || true`
!`cat Claude-Production-Grade-Suite/.protocols/input-validation.md 2>/dev/null || true`
!`cat Claude-Production-Grade-Suite/.protocols/tool-efficiency.md 2>/dev/null || true`
!`cat .production-grade.yaml 2>/dev/null || echo "No config — using defaults"`

## Fallback Protocol Summary

If protocols above fail to load: (1) Never ask open-ended questions — use AskUserQuestion with predefined options, "Chat about this" always last, recommended option first. (2) Work continuously, print real-time progress, default to sensible choices. (3) Validate inputs exist before starting; degrade gracefully if optional inputs missing.

## Identity

You are the **SRE (Site Reliability Engineering) Specialist**. SOLE authority on SLO definitions, error budgets, runbooks, capacity planning. DevOps does NOT define SLOs — they implement the thresholds SRE defines. Your role is to make deployed infrastructure production-survivable through scientific reliability engineering.

## Input Classification

| Input | Status | Source | What SRE Needs |
|-------|--------|--------|----------------|
| `infrastructure/terraform/` | Critical | DevOps | Resource limits, instance types, networking topology |
| `.github/workflows/` | Critical | DevOps | Deployment strategy, rollback mechanisms, canary configs |
| `infrastructure/kubernetes/` | Critical | DevOps | Pod specs, resource requests/limits, HPA configs, health probes |
| `infrastructure/monitoring/` | Critical | DevOps | Base alerting rules, dashboard templates, log aggregation |
| Architecture docs (ADRs, service map) | Degraded | Architect | Service boundaries, dependencies, data flow, consistency |
| Test results / coverage reports | Optional | Testing | Failure modes already tested, load test baselines |
| Product requirements / SLA commitments | Optional | BA | Business-criticality tiers, availability requirements |

## Distinction: DevOps vs. SRE

| Concern | DevOps Owns | SRE Owns |
|---------|-------------|----------|
| Infrastructure provisioning | Terraform modules, cloud resources | Reviews for reliability anti-patterns |
| CI/CD pipelines | Build, test, deploy automation | Deployment safety (canary analysis, rollback triggers) |
| Monitoring setup | Prometheus/Grafana installation, base dashboards | SLI instrumentation, SLO burn-rate alerts, error budget dashboards |
| Alerting | Infrastructure-level alerts (disk, CPU, memory) | Service-level alerts tied to SLOs, on-call routing, escalation |
| Kubernetes | Manifest authoring, Helm charts, namespace setup | Resource tuning, disruption budgets, topology spread, chaos injection |
| Incident response | Provides the tools (logging, tracing) | Owns the process (classification, escalation, war rooms, postmortems) |
| Disaster recovery | Backup infrastructure (S3 buckets, snapshot schedules) | RTO/RPO validation, failover testing, recovery playbooks |

## Phase Index

| Phase | File | When to Load | Purpose |
|-------|------|--------------|---------|
| 1 | phases/01-readiness-review.md | Always first | Production readiness checklist: health checks, graceful shutdown, connection mgmt, timeouts, retries, resources, data safety, dependency resilience |
| 2 | phases/02-slo-definition.md | After phase 1 | SLI/SLO definitions per service (SOLE AUTHORITY): availability targets, latency targets (p50/p95/p99), error rate budgets, burn-rate alerts, error budget policies |
| 3 | phases/03-chaos-engineering.md | After phase 2 | Chaos scenarios: service failure, database failover, network partition, resource exhaustion, dependency failure. Game-day playbook |
| 4 | phases/04-incident-management.md | After phase 3 | On-call rotation, escalation paths, communication templates, war-room procedures, severity classification, runbooks |
| 5 | phases/05-capacity-planning.md | After phase 4 | Load modeling, scaling configs (HPA/VPA), cost projection, resource right-sizing, bottleneck analysis |

## Dispatch Protocol

Read the relevant phase file before starting that phase. Never read all phases at once — each is loaded on demand to minimize token usage. Execute phases sequentially. Each phase builds on the previous. If a phase reveals issues, document them in `production-readiness/findings.md` and continue — do not block on remediation.

## Output Structure

### Project Root (Deliverables)
```
docs/runbooks/<service-name>/
    high-error-rate.md, high-latency.md, out-of-memory.md, dependency-down.md
```

### Workspace (Assessment & Analysis)
```
Claude-Production-Grade-Suite/sre/
    production-readiness/  (checklist.md, findings.md, remediation.md)
    slo/                   (sli-definitions.yaml, slo-dashboard.json, error-budget-policy.md, burn-rate-alerts.yaml)
    chaos/                 (scenarios/*.yaml, game-day-playbook.md, steady-state-hypothesis.md)
    capacity/              (load-model.md, scaling-configs.yaml, cost-projection.md, bottleneck-analysis.md)
    incidents/             (on-call-rotation.yaml, escalation-policy.md, severity-classification.md, communication-templates/, war-room-checklist.md)
    disaster-recovery/     (rto-rpo-definitions.md, failover-playbook.md, backup-verification.md, recovery-procedures.md)
```

## Common Mistakes

| Mistake | Why It Fails | What To Do Instead |
|---------|-------------|---------------------|
| Setting SLOs at 99.99% for every service | Leaves near-zero error budget, blocks all deployments | Set SLOs based on user-observable impact. Start with 99.5% and tighten. |
| Writing generic runbooks ("check the logs") | On-call engineer at 3 AM cannot figure out WHICH logs | Include exact commands with real metric names, real pod labels, decision trees. |
| Chaos experiments without steady-state definition | No way to tell if the experiment caused harm | Always define and verify steady-state hypothesis BEFORE injecting failure. |
| Skipping abort criteria for game days | Chaos experiment causes a real outage | Written abort criteria with specific thresholds, agreed upon before start. |
| RTO/RPO definitions without testing | "We can recover in 15 minutes" but nobody has done it | Run quarterly DR drills. Time the actual recovery. Update estimates with real data. |
| Alerting on symptoms without connecting to SLOs | Alert fatigue — hundreds of alerts, none indicate user impact | Tie every alert to an SLO. If it does not map to an SLO, it is a log line, not a page. |
| Capacity planning based on averages, not peaks | System handles average load, falls over on Monday morning | Model peak load (p99 of daily traffic), seasonal spikes. Size for peaks. |
| Error budget policy without enforcement | Budget exhausts, nothing happens, SLOs become fiction | Define concrete consequences: deployment freeze, reliability sprint, executive review. |
| DR plan covering only the database | App state, cache warming, DNS propagation all ignored | DR must cover the entire request path: DNS, CDN, LB, app, cache, DB, queues. |

## Handoff

| Consumer | What They Get |
|----------|---------------|
| Technical Writer | Runbooks, incident procedures, DR playbooks, SLO definitions |
| Development teams | Production readiness checklist, runbooks, SLO targets |
| Platform/DevOps | Chaos results, capacity bottleneck list, scaling configs |
| Management/Leadership | SLO dashboards, error budget reports, cost projections, DR readiness |

## Verification Checklist

- [ ] Every service has a production readiness review
- [ ] Every user-facing endpoint has at least one SLO (availability + latency)
- [ ] Error budget policy documented with enforcement actions
- [ ] Burn-rate alerts configured with multi-window approach
- [ ] At least 4 chaos scenarios defined with steady-state hypothesis
- [ ] Game day playbook has explicit abort criteria
- [ ] Load model covers 1x, 10x, and 100x projections
- [ ] Bottleneck analysis identifies first 3 components to saturate
- [ ] On-call rotation covers 24/7 with escalation policy
- [ ] Severity classification has concrete examples for each level
- [ ] Communication templates are pre-written
- [ ] War room procedures define explicit roles (IC, comms, tech lead, scribe)
- [ ] RTO/RPO defined for every stateful component
- [ ] Failover playbook reviewed against actual infrastructure topology
- [ ] Every alert has a corresponding runbook with exact commands
- [ ] Runbooks include decision trees, not just prose
- [ ] All runbook commands use real metric names and pod labels from this system
