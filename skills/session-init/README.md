<div align="center">

# Session Init

**Automatic pipeline detection and skill routing at session start**

Zero-config. Intent-based. Pipeline-aware.

<p>
  <img src="https://img.shields.io/badge/type-auto--loaded-green?style=flat-square" alt="Auto-loaded">
  <img src="https://img.shields.io/badge/routing-intent--based-purple?style=flat-square" alt="Intent-based Routing">
  <img src="https://img.shields.io/badge/invoke-stn--skills:session--init-blue?style=flat-square" alt="Invoke: stn-skills:session-init">
</p>

</div>

Part of the [stn-skills](https://github.com/sthiermann/stn-skills) pipeline. Auto-injected at every session start via the `stn-init` hook. No manual invocation needed.

---

## What It Does

1. **Pipeline state detection** -- reads `.claude/stn-skills-pipeline-state.json` on session start. If an active pipeline exists, reports status and resumes it immediately.

2. **Intent-based routing** -- classifies the user's request by intent (not keywords) and routes to the correct skill:

| Priority | Intent | Skill |
|----------|--------|-------|
| 1 | Active pipeline exists | Resume active skill |
| 2 | Build, create, implement a feature | `build-feature` |
| 3 | Explore options, compare approaches | `brainstorming` |
| 4 | Decompose requirements into tasks | `plan-writing` |
| 5 | Execute an existing plan | `plan-execution` |
| 6 | Audit repository health | `codebase-audit` |
| 7 | Set up quality standards | `codebase-quality-bootstrap` |

3. **Rationalization defense** -- includes a Red Flags table that catches common bypass patterns ("too simple for a skill", "these are mechanical changes", "I can handle this without structure").

## When It Skips

Single-file fixes, simple questions, no code changes, or when the user explicitly says "skip".

## How It Loads

The `stn-init` SessionStart hook reads the session-init SKILL.md and injects it into Claude's context at session start. This happens automatically -- no `/stn-skills:session-init` invocation required.

## Routing Guidance

The `stn-prompt-router` hook reinforces routing: when an active pipeline exists or the edit threshold is reached, Claude is reminded to resume or start a pipeline.

---

**Upstream:** Any session start  
**Downstream:** Routes to [Brainstorming](../brainstorming/README.md), [Plan Writing](../plan-writing/README.md), [Plan Execution](../plan-execution/README.md), [Codebase Audit](../codebase-audit/README.md), or [Quality Bootstrap](../codebase-quality-bootstrap/README.md)  
**Full pipeline:** [Build Feature](../build-feature/README.md)
