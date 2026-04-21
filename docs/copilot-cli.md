# GitHub Copilot CLI Support

stn-skills v8.1.0 introduces first-class support for GitHub Copilot CLI with parity to the existing Cursor integration at the plugin, hooks, and skill layers.

## Status

| Platform | Plugin manifest | Hooks | Skills | Notes |
|---|---|---|---|---|
| Claude Code | `.claude-plugin/plugin.json` | 6 hooks (full enforcement) | 8 skills | Reference implementation |
| Cursor | `.cursor-plugin/plugin.json` | 6 hooks (full enforcement) | 8 skills | Parity with Claude Code |
| Copilot CLI | `.copilot-plugin/plugin.json` | 6 thin wrappers → shared hooks | 8 skills | v8.1.0 — see Known Limitations below |

All three platforms share the same `hooks/stn-*` scripts, same `skills/` directory, and same `.claude/stn-skills-pipeline-state.json` state file. Platform-specific behavior lives in a single library (`hooks/stn-hook-output`) with runtime detection via `stn_detect_platform`.

## Installation

### Copilot CLI (local path)

Clone the repository and install the Copilot plugin from the `.copilot-plugin/` subdirectory:

```sh
git clone https://github.com/sthiermann/stn-skills.git
cd stn-skills
copilot plugin install ./.copilot-plugin
```

### Verify

After install, confirm the plugin is active:

```sh
copilot plugin list | grep stn-skills
```

Run the optional smoke test to verify Copilot CLI integration works end-to-end on your machine (requires `COPILOT_CLI=1` env var):

```sh
COPILOT_CLI=1 ./evals/eval-copilot-smoke.sh
```

### Upgrading from v8.0.0

No state migration is required. v8.1.0 is purely additive for Copilot; Claude Code and Cursor hook output is byte-identical to v8.0.0 (verified by `evals/eval-00-golden-diff.sh` regression firewall). Simply reinstall:

```sh
copilot plugin uninstall stn-skills
copilot plugin install ./.copilot-plugin
```

## Pipeline State Location

Copilot reads the same `.claude/stn-skills-pipeline-state.json` as Claude Code and Cursor — the `.claude/` path is kept for cross-platform state continuity (not because the directory is Claude-specific; it's treated as a tool-agnostic state location). This means a pipeline started in Claude Code can be resumed from Cursor or Copilot CLI and vice versa.

## Known Limitations

These are honest, deliberate gaps — NOT bugs to work around. Every limitation below corresponds to a documented Copilot CLI product constraint or a deliberate scope boundary (see `docs/specs/2026-04-21-copilot-cli-support-design.md` Risk Register R4–R10).

### no Skill tool (R11 advisory)

Copilot CLI has no `Skill` tool — skills auto-activate by description. The `stn-skill-gate` hook (which enforces pipeline chain ordering `brainstorming → plan-writing → plan-execution` on Claude Code by matching the `Skill` tool in `preToolUse`) is therefore **dormant on Copilot**. Pipeline chain enforcement becomes **advisory-only**: skill descriptions still guide the model toward the correct chain order, but there is no mechanical gate like there is on Claude Code.

Downstream impact: it is possible on Copilot to invoke `stn-skills:plan-writing` directly without first running `stn-skills:brainstorming` + `pipeline-handoff-validator`. The skill text itself will refuse to proceed (all three pipeline skills check `handoff_validated` in their state-resumption protocol), but the hook-level safety net is inactive.

### userPromptSubmitted output ignored (A5)

Copilot CLI's `userPromptSubmitted` hook event exists, but any output written to stdout is **ignored by the agent runtime**. The `stn-prompt-router` hook (which injects "you have an active pipeline — resume it" reminders on Claude Code) therefore has no effect on Copilot. Users on Copilot will not see the unconditional pipeline-state reminder when their first prompt doesn't match any skill description.

Mitigation: Copilot's native skill auto-activation by description is the primary discovery mechanism — if the user's prompt semantically matches any stn-skills description, the relevant skill activates and reads state from the `.claude/stn-skills-pipeline-state.json` file.

### sessionStart best-effort (R4)

Copilot CLI's `sessionStart` hook **may** support `additionalContext` injection, but documentation is inconsistent (the official reference suggests output is ignored, while the tutorial example uses `additionalContext` explicitly). A known bug (Copilot issue #2585) documents that `preToolUse` `additionalContext` is dropped; the sessionStart equivalent may behave similarly.

stn-init emits the session-init skill content and active-pipeline reminder via `additionalContext` on sessionStart — this is best-effort. If Copilot drops it, primary discovery falls back to auto-activation by skill description. Users will not silently lose skill access; they will lose only the unconditional session-start reminder.

### 6 skills use AskUserQuestion (R9)

Six of the eight skills include `AskUserQuestion` tool calls to present user-facing decision points:

| Skill | AskUserQuestion call count | Purpose |
|---|---|---|
| build-feature | 3 | Macro-phase boundaries (Design → Plan → Execute) |
| brainstorming | 9 | Gates 1–4 + blocker resolution + transition |
| codebase-audit | 5 | Scope confirmation, fix-mode, escalation |
| plan-execution | 7 | Gates 1–3 + circuit-breaker YELLOW + replan |
| plan-writing | 9 | Gates 1–4 + defect-resolution + transition |
| codebase-quality-bootstrap | 2 | Bootstrap confirmation, hook selection |

On Claude Code and Cursor these render as native option-picker UI. **Copilot CLI has no AskUserQuestion tool equivalent**, so the model emits the question text and a numbered list of options as prose and waits for the user to reply with a digit or a quoted option label. This is a graceful degradation — all skills still function — but the user experience on Copilot is prose-based instead of UI-based.

Consistency of the documented counts is checked by `evals/eval-copilot-skills-count.sh` on every test run.

### Windows WSL/Git Bash required (H6)

stn-skills hooks are bash-only (`#!/usr/bin/env bash`). The Copilot wrappers in `.copilot-plugin/hooks/` use `#!/bin/sh` with a defensive `[ -n "$BASH_VERSION" ] || exec bash "$0" "$@"` re-exec pattern, so they function under POSIX `sh`, `dash`, and bash.

**Native PowerShell is not supported in v8.1.0**. Windows users must run Copilot CLI inside Git Bash or WSL2 to get a bash interpreter on PATH. PowerShell-native wrappers would require duplicating every hook in `.ps1` and maintaining bash↔PowerShell parity — out of scope for this release.

### no Copilot CLI in CI (R7)

The stn-skills test harness runs `./evals/eval-runner.sh` in a standard CI environment without GitHub Copilot CLI installed. This means:

- `evals/eval-00-golden-diff.sh` verifies Claude and Cursor output byte-for-byte (50 goldens captured from v8.0.0 baseline).
- `evals/copilot-contract/` contains 25 **contract-spec** goldens that describe what stn-skills *intends* to emit to Copilot. These are NOT captured from a live Copilot session — they are generated from the `stn-hook-output` library running under `STN_PLATFORM=copilot`.
- `evals/eval-copilot-contract.sh` asserts library emission matches the contract spec.
- `evals/eval-copilot-smoke.sh` is opt-in via `COPILOT_CLI=1` — runs a real Copilot invocation when the env var is set and Copilot CLI is on PATH. In standard CI it emits `SKIP` and exits 0.

**Consequence:** a Copilot-specific regression (e.g., Copilot renames `permissionDecision` to `decision`) could ship without being caught by the default eval run. Users who install stn-skills via Copilot CLI should run `COPILOT_CLI=1 ./evals/eval-copilot-smoke.sh` locally as part of their own verification.

## Platform Parity Gaps Summary

| Feature | Claude Code | Cursor | Copilot CLI | Gap document section |
|---|---|---|---|---|
| Chain enforcement via skill-gate | Enforced | Enforced | Advisory only | no Skill tool |
| Context reminder on every prompt | Injected | Injected | Dropped | userPromptSubmitted output ignored |
| Session-start skill-init + state | Injected | Injected | Best-effort (may be dropped) | sessionStart best-effort |
| `AskUserQuestion` tool | Native UI | Native UI | Prose fallback | 6 skills use AskUserQuestion |
| Windows native | WSL/Git Bash ok, PowerShell ok | WSL/Git Bash ok | WSL/Git Bash only (no native PowerShell) | Windows WSL/Git Bash required |
| Circuit breaker (RED blocks writes) | Enforced | Enforced | **Enforced** | — (Copilot honors `permissionDecision: deny`) |
| State file validation | Enforced | Enforced | **Enforced** | — (Copilot honors `permissionDecision: deny`) |
| Session lock | Enforced | Enforced | **Enforced** | — (Copilot honors `permissionDecision: deny` on sessionStart) |

The three enforcement hooks (`stn-circuit-breaker`, `stn-state-validator`, `stn-session-lock`) work fully on Copilot because Copilot honors top-level `permissionDecision: deny` in preToolUse/sessionStart. The two informing hooks (`stn-init`, `stn-prompt-router`) have the documented best-effort / dropped limitations above.
