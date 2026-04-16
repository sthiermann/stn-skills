# stn-skills Hook Architecture

stn-skills ships with 6 built-in hooks that provide safety enforcement and context priming. Hooks execute outside the LLM's reasoning chain.

## Built-in Hooks

All hooks are registered automatically via `hooks/hooks.json` (Claude Code) and `.cursor-plugin/hooks-cursor.json` (Cursor). No manual setup required.

| Hook | Event | Matcher | Purpose |
|---|---|---|---|
| `stn-init` | SessionStart | `startup\|resume\|clear\|compact` | Load session-init skill + pipeline state into context |
| `stn-session-lock` | SessionStart | `startup\|resume\|clear\|compact` | Prevent concurrent stn-skills sessions via mkdir lock |
| `stn-prompt-router` | UserPromptSubmit | active pipeline or edit threshold | Remind Claude about active pipelines and multi-file edit thresholds |
| `stn-skill-gate` | PreToolUse | `Skill` | Block invalid skill chain invocations (handoff not validated) |
| `stn-state-validator` | PreToolUse | `Write` | Validate JSON when writing pipeline/execution state files |
| `stn-circuit-breaker` | PreToolUse | `Edit\|Write\|Agent` | Block code modifications when circuit breaker is RED |

## Kill-Switch

To disable all hooks (emergency override):

```bash
export STN_SKILLS_HOOKS_DISABLE=1
```

All hooks check this env var first and allow immediately if set.

## Dependencies

- **jq** (recommended): Fast JSON parsing. Available via `brew install jq` (macOS) or `apt install jq` (Linux).
- **python3** (fallback): Used automatically if jq is not found. Pre-installed on macOS and most Linux distributions.

## How Hooks Work

Hooks use two modes: **prime** (context injection) for routing guidance, and **deny** for safety-critical violations.

### Prime Mode (session-init + prompt-router)

The session-init hook loads the routing table and pipeline state at session start. The prompt-router fires when an active pipeline exists or the edit threshold is reached, reminding Claude to resume the pipeline or start one.

```json
{
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": "Active stn-skills pipeline: brainstorming (phase 3/6). Resume by invoking Skill(skill: \"stn-skills:brainstorming\") before starting other work."
  }
}
```

The prompt-router is silent when no pipeline is active and the edit threshold hasn't been reached.

### Deny Mode (safety hooks)

When a safety hook blocks an operation, it returns `permissionDecision: "deny"`:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Pipeline gate: handoff_validated is false. Run pipeline-handoff-validator before invoking plan-writing."
  }
}
```

Used by: `stn-skill-gate`, `stn-state-validator`, `stn-circuit-breaker`, `stn-session-lock`.

Deny is reserved for safety and data integrity — never for workflow routing.

## Custom Hooks

Users can add project-level hooks on top of the built-in hooks in `.claude/settings.json`. The built-in hooks handle pipeline safety; custom hooks can add project-specific rules (e.g., blocking writes to generated files).

## Override

To override for urgent hotfixes:
- Set `STN_SKILLS_HOOKS_DISABLE=1` (disables all stn-skills hooks)
- Delete `.claude/stn-skills-pipeline-state.json` (removes pipeline state)
- Delete `.claude/stn-skills.lock` (removes session lock)
