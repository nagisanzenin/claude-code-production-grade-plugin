# SUSTAIN Phase — Dispatcher

This phase manages tasks T11 (Technical Writer), T12 (Skill Maker), and T13 (Compound Learning + Final Assembly). Features PARALLEL #7.

## Visual Output

Print pipeline dashboard with SUSTAIN ● active on phase start, then:

```
  → Starting SUSTAIN phase (documentation + skills)
```

On PARALLEL #7 completion:
```
┌─ SUSTAIN COMPLETE ────────────────────────── ⏱ {time} ─┐
│                                                          │
│  ✓ Technical Writer    {N} docs (API ref, dev guide...)  │
│  ✓ Skill Maker         {N} project-specific skills       │
│                                                          │
│  → Final assembly and compound learning                  │
└──────────────────────────────────────────────────────────┘
```

After T13 completes, print the final summary template from the orchestrator.

## PARALLEL #7: T11 + T12

```python
# T11: Technical Writer
TaskUpdate(taskId=t11_id, status="in_progress")
Agent(
  prompt="""You are the Technical Writer.
Read ALL workspace folders at Claude-Production-Grade-Suite/ for full project context.
Read all project deliverables: api/, services/, frontend/, infrastructure/, tests/, docs/.
Read protocols from: Claude-Production-Grade-Suite/.protocols/
Read .production-grade.yaml for paths and preferences.
Generate: API reference (from OpenAPI specs), developer guides, operational guide, architecture guide, contributing guide.
If features.documentation_site is true: scaffold Docusaurus site.
Write docs to project root: docs/
Write workspace artifacts to: Claude-Production-Grade-Suite/technical-writer/
When complete, mark your task as completed.""",
  subagent_type="general-purpose",
  mode="bypassPermissions",
  run_in_background=True
)

# T12: Skill Maker
TaskUpdate(taskId=t12_id, status="in_progress")
Agent(
  prompt="""You are the Skill Maker.
Analyze the completed project for recurring patterns: API routes, DB queries, auth checks, deployment procedures, testing patterns, domain-specific workflows.
Read protocols from: Claude-Production-Grade-Suite/.protocols/
Generate 3-5 project-specific skills as SKILL.md files.
Install skills to: .claude/skills/
Write workspace artifacts to: Claude-Production-Grade-Suite/skill-maker/
When complete, mark your task as completed.""",
  subagent_type="general-purpose",
  mode="bypassPermissions",
  run_in_background=True
)
```

## T13: Compound Learning + Final Assembly

After T11 and T12 complete:

```python
TaskUpdate(taskId=t13_id, status="in_progress")
```

### Compound Learning

Write to `Claude-Production-Grade-Suite/.orchestrator/compound-learnings.md`:

```markdown
## Learning: [date] — [project name]

### What Worked
- [patterns, decisions, tools that worked well]

### What Failed
- [errors encountered, root causes, how they were fixed]

### Architecture Insights
- [patterns that emerged, tech stack fit/misfit]

### Time Sinks
- [phases that took longest, what slowed them down]

### Skip Next Time
- [unnecessary steps for this project type]

### Add Next Time
- [missing steps that should have been included]
```

Optionally append key patterns to project `CLAUDE.md` for cross-session persistence.

### Final Assembly

1. **Integration decision** — ask user via AskUserQuestion:
```python
AskUserQuestion(questions=[{
  "question": "Code is ready. Integrate into your project root?",
  "header": "Assembly",
  "options": [
    {"label": "Integrate all code (Recommended)", "description": "Copy services, frontend, infra to project root"},
    {"label": "Keep in workspace only", "description": "Leave everything in Claude-Production-Grade-Suite/"},
    {"label": "Let me choose what to copy", "description": "Select which components to integrate"},
    {"label": "Chat about this", "description": "Discuss integration strategy"}
  ],
  "multiSelect": false
}])
```

2. **Run final validation:** `docker-compose up`, `make test`, `terraform validate`, health checks.

3. **Present final summary** using the orchestrator's template.

4. **Clean up team:**
```python
TaskUpdate(taskId=t13_id, status="completed")
TeamDelete()
```

## Pipeline Complete

Print the final summary template from the orchestrator. All tasks should show as completed in TaskList.
