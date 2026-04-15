# stn-skills Hook Enforcement

stn-skills ships with 7 built-in hooks that provide hardware-level pipeline enforcement. Hooks execute outside the LLM's reasoning chain — Claude cannot rationalize past them.

**Evidence:** Hooks raised skill compliance from ~20% to ~84% (source: dotzlaw.com, "Claude Hooks: The Deterministic Control Layer").

## Built-in Hooks

All hooks are registered automatically via `hooks/hooks.json` (Claude Code) and `.cursor-plugin/hooks-cursor.json` (Cursor). No manual setup required.

| Hook | Event | Matcher | Purpose |
|---|---|---|---|
| `stn-init` | SessionStart | `startup\|clear\|compact` | Load session-init skill + pipeline state into context |
| `stn-session-lock` | SessionStart | `startup\|clear\|compact` | Prevent concurrent stn-skills sessions via mkdir lock |
| `stn-skill-gate` | PreToolUse | `Skill` | Block invalid skill chain invocations (handoff not validated) |
| `stn-state-validator` | PreToolUse | `Write` | Validate JSON when writing pipeline/execution state files |
| `stn-routing-guard` | PreToolUse | `Edit\|Write` | Block multi-file edits (3+ files) outside active pipelines |
| `stn-scope-guard` | PreToolUse | `Edit\|Write` | Block writes outside current task scope during plan-execution |
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

## How Hooks Block

When a hook blocks an operation, it returns the Claude Code `hookSpecificOutput` format:
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Pipeline gate: handoff_validated is false. Run pipeline-handoff-validator before invoking plan-writing."
  }
}
```

The `permissionDecisionReason` field includes a corrective action — telling the user (and Claude) exactly what to do to proceed.

## Custom Hooks

Users can add project-level hooks on top of the built-in hooks in `.claude/settings.json`. The built-in hooks handle pipeline enforcement; custom hooks can add project-specific rules (e.g., blocking writes to generated files).

## Override

To override for urgent hotfixes outside the pipeline:
- Set `STN_SKILLS_HOOKS_DISABLE=1` (disables all stn-skills hooks)
- Set `STN_ROUTING_GUARD_SKIP=1` (disables routing guard only, keeps other hooks active)
- Delete `.claude/stn-skills-pipeline-state.json` (removes pipeline state)
- Delete `.claude/stn-skills.lock` (removes session lock)
