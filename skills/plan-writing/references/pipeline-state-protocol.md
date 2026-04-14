# Pipeline State Protocol

Durable JSON state file that tracks pipeline progress across sessions. Enables correct resumption regardless of what the user types — the state file IS the truth, not the conversation context.

**Why this exists:** Without durable state, pipeline progress lives only in conversation memory. When a session continues, the agent has no reliable way to know where it is — leading to skipped phases, fast-tracking, and broken pipelines. Research shows JSON state files are less likely to be corrupted by models than Markdown, and are machine-validatable (Anthropic Engineering: "Effective Harnesses for Long-Running Agents").

## State File

**Location:** `.claude/stn-skills-pipeline-state.json`

**Schema:**

```json
{
  "pipeline_id": "{YYYYMMDD}-{slug}",
  "active_skill": "brainstorming | plan-writing | plan-execution",
  "current_phase": 1,
  "total_phases": 6,
  "gates_passed": [],
  "gates_total": 4,
  "artifact_path": null,
  "handoff_validated": false,
  "updated_at": "{ISO-8601}"
}
```

| Field | Type | Description |
|-------|------|-------------|
| `pipeline_id` | string | Unique ID: date + kebab-case topic slug |
| `active_skill` | string | Which skill is currently running |
| `current_phase` | integer | Phase number currently being executed (1-indexed) |
| `total_phases` | integer | Total phases in active skill |
| `gates_passed` | integer[] | Gate numbers that have been passed |
| `gates_total` | integer | Total gates in active skill |
| `artifact_path` | string\|null | Path to the skill's output artifact (null until Phase 6/final) |
| `handoff_validated` | boolean | Whether handoff-validator has approved the artifact |
| `updated_at` | string | ISO-8601 timestamp of last update |

## When to Write State

Write the state file at every transition point:

| Event | What changes |
|-------|-------------|
| Skill starts | Initialize: `active_skill`, `current_phase: 1`, `total_phases`, `gates_total` |
| Phase completes | Increment `current_phase` |
| Gate passes | Append gate number to `gates_passed` |
| Artifact saved to disk | Set `artifact_path` |
| Handoff-validator passes | Set `handoff_validated: true` |
| Skill transition | Reset for next skill: new `active_skill`, `current_phase: 1`, clear `gates_passed`, `handoff_validated: false` |

**Write method:** Use the Write tool to overwrite the entire file. Always write the complete JSON — never partial updates.

## When to Read State

Read the state file at the start of EVERY user turn within a pipeline skill:

1. **If state file exists and `active_skill` matches the current skill:**
   Report: "Resuming {active_skill} at Phase {current_phase}/{total_phases}. Gates passed: {gates_passed}."
   Continue from `current_phase`. Do not restart completed phases.

2. **If state file exists but `active_skill` does NOT match:**
   Report: "Pipeline state shows {active_skill} at Phase {current_phase}. This skill is {this_skill}."
   Ask user: "Resume {active_skill}, or start fresh with {this_skill}?"
   Do not proceed without explicit user choice.

3. **If state file does not exist:**
   Fresh start. Initialize state file for the current skill.

## Session Resumption

When a user continues work (any phrasing — "continue", "go on", "weiter", "next", or anything else):

1. Read the state file
2. The state file determines what happens next — not the user's phrasing
3. If `current_phase < total_phases`: continue to next phase within current skill
4. If `current_phase == total_phases` AND all gates passed: offer skill transition
5. Never interpret any user message as "skip remaining phases"

## Skill Transition

When a skill completes and the user chooses to advance:

1. Verify state file shows all phases complete and all gates passed
2. Verify handoff-validator has run (`handoff_validated: true`)
3. Update state file for next skill:
   ```json
   {
     "active_skill": "{next_skill}",
     "current_phase": 1,
     "total_phases": "{next_skill_phases}",
     "gates_passed": [],
     "gates_total": "{next_skill_gates}",
     "artifact_path": null,
     "handoff_validated": false
   }
   ```
4. Invoke next skill via Skill tool

## Skill Phase Counts

| Skill | Phases | Gates |
|-------|--------|-------|
| brainstorming | 6 | 4 |
| plan-writing | 6 | 4 |
| plan-execution | 7 | 3 |
| codebase-audit | — | — | Entry point only; does not track its own phases in pipeline state |

**Pipeline entry points:** The standard pipeline starts with brainstorming. However, codebase-audit can also initiate a pipeline when `[PIPELINE]` tier findings are discovered. In this case, codebase-audit writes the initial pipeline state with `active_skill` set to `brainstorming` (default) or `plan-writing` (user choice), and `artifact_path` pointing to the remediation brief. The audit itself is not tracked as a pipeline phase — it completes independently, and the pipeline state it writes is the starting point for the subsequent skill chain.

## Relationship to plan-execution-state.json

Plan-execution maintains its own detailed state file at `.claude/plan-execution-state.json` (per-task checkpoints, circuit breaker, commit SHAs). The pipeline state file (`.claude/stn-skills-pipeline-state.json`) is a higher-level tracker that operates across ALL skills, not just execution. Both files coexist — the pipeline state tracks which skill/phase is active, while the execution state tracks per-task progress within plan-execution.

## Cleanup

Delete the state file when:
- Pipeline completes successfully (all 3 skills done)
- User explicitly abandons the pipeline
- User starts a completely new pipeline (overwrite with fresh state)

Do NOT delete mid-pipeline. The file persists across sessions to enable resumption.
