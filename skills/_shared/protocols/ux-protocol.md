# UX Protocol — Single Source of Truth

**Every skill in this plugin MUST follow these 6 rules for ALL user interactions.**

## RULE 1: NEVER Ask Open-Ended Questions

**NEVER output text expecting the user to type.** Every user interaction MUST use `AskUserQuestion` with predefined options. Users navigate with arrow keys (up/down) and press Enter.

**WRONG:** "What do you think?" / "Do you approve?" / "Any feedback?"
**RIGHT:** Use AskUserQuestion with 2-4 options + "Chat about this" as last option.

## RULE 2: "Chat about this" Always Last

Every `AskUserQuestion` MUST have `"Chat about this"` as the last option — the user's escape hatch for free-form typing.

## RULE 3: Recommended Option First

First option = recommended default with `(Recommended)` suffix.

## RULE 4: Continuous Execution

Work continuously until task complete or user presses ESC. Never ask "should I continue?" — just keep going.

## RULE 5: Real-Time Terminal Updates

Constantly print progress. Never go silent. Follow the visual identity protocol at `Claude-Production-Grade-Suite/.protocols/visual-identity.md` for all formatting.

Key rules from visual identity:
- Use `━━━ [Skill Name] ━━━` headers for skill-level sections
- Show numbered phase progress: `[1/5] Phase Name`
- Print `⧖` for in-progress, `✓` for complete, `○` for pending steps
- Every `✓` line must include concrete counts (numbers prove work was done)
- Completion summaries: `✓ [Skill Name]    {metrics with numbers}    ⏱ Xm Ys`

```
━━━ [Skill Name] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  [1/N] Phase Name
    ✓ Step completed (247 files scanned, 3 services found)
    ⧖ Step in progress...
    ○ Step pending

  [2/N] Next Phase
    ○ ...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## RULE 6: Autonomy

1. Default to sensible choices — minimize questions
2. Self-resolve issues — debug and fix before asking user
3. Report decisions made, don't ask for permission on minor choices
4. Only use AskUserQuestion for major decisions or approval gates
