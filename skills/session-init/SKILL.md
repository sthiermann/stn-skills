---
name: session-init
description: >-
  Auto-loaded at session start. Resumes active pipelines, routes tasks to
  stn-skills. Triggers: session start, /stn-skills:session-init.
---

## The Iron Law

```
ACTIVE PIPELINES ARE RESUMED FIRST.
MATCHING SKILLS ARE INVOKED BEFORE ANY WORK.
THE STATE FILE IS THE TRUTH.
```

## Active Pipeline

If an **Active Pipeline State** section appears below, a pipeline is active.

1. Report status to user.
2. Invoke the listed skill via Skill tool immediately.
3. Do NOT start other work until user acknowledges the pipeline.

No Active Pipeline State section? Use routing below.

## Routing

| Priority | Trigger | Skill |
|----------|---------|-------|
| 1 | Active pipeline state | Resume `stn-skills:{active_skill}` |
| 2 | "build X", "add Y", "implement Z" | `stn-skills:build-feature` |
| 3 | "brainstorm", "explore", "design" | `stn-skills:brainstorming` |
| 4 | "plan this", "break down" | `stn-skills:plan-writing` |
| 5 | "execute plan", "run plan" | `stn-skills:plan-execution` |
| 6 | "audit", "review repo" | `stn-skills:codebase-audit` |
| 7 | "bootstrap", "generate CLAUDE.md" | `stn-skills:codebase-quality-bootstrap` |

Multiple match? Use higher priority. No match? Proceed without skill.

## Skip

Do NOT invoke when: simple question, one-line fix, no code changes, user says "skip".

## Pipeline

`brainstorming` -> `plan-writing` -> `plan-execution`. Each outputs an artifact for the next. `build-feature` orchestrates all three. State: `.claude/stn-skills-pipeline-state.json`.

## Red Flags and Common Rationalizations

- "Too simple for a skill" -> Check routing. Simple tasks in complex codebases need structure.
- "I know what to do" -> Skill loads gates + verification. Skipping loses that.
- "I'll invoke later" -> Skills are invoked BEFORE work, not after.
- "Pipeline can wait" -> Active pipelines are priority 1. Inform user first.
- "Already started, too late" -> Stop. Invoke skill. Starting without structure produces rework.
- "This is a continuation" -> Read state file. State determines what happens next.
