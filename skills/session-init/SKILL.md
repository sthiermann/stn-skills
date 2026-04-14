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

**Match by INTENT, not literal keywords.** The user may write in any language. Classify what the user wants to accomplish, then match to the closest skill.

| Priority | Intent | Skill |
|----------|--------|-------|
| 1 | Active pipeline state | Resume `stn-skills:{active_skill}` |
| 2 | Build, create, implement, or deliver a feature or significant change — any task touching multiple files that benefits from design-before-code | `stn-skills:build-feature` |
| 3 | Explore options, compare approaches, make an architectural or design decision | `stn-skills:brainstorming` |
| 4 | Decompose requirements into tasks, create an implementation plan | `stn-skills:plan-writing` |
| 5 | Execute an existing plan step by step | `stn-skills:plan-execution` |
| 6 | Audit, review, or assess repository health, security, or quality | `stn-skills:codebase-audit` |
| 7 | Set up or update project quality standards, generate CLAUDE.md | `stn-skills:codebase-quality-bootstrap` |

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
