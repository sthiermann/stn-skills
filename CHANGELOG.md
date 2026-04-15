# Changelog

All notable changes to this project will be documented in this file.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [7.0.0] - 2026-04-15

### Changed
- **Routing guard restores deny enforcement** — the v6.0.0 change from `_deny()` to `_inform()` was a regression. The inform pattern (allow + additionalContext) let edits through while Claude consistently ignored the guidance. The routing guard now blocks edits at 3+ files outside a pipeline with an actionable deny reason directing Claude to invoke `stn-skills:build-feature`. This matches the v5.2.0 approach that was correct but was changed before proper testing. All crash-class fixes from v5.1.2–v6.1.0 (no set -e, complete JSON escaping, tracker persistence) are preserved.
- **Version bump across all manifests** — plugin.json, README badge, and Cursor plugin aligned to 7.0.0.

### Why this is not going in circles
The original v5.1.0 deny used the **wrong JSON format** (`decision: "block"` instead of `permissionDecision: "deny"`), and v5.1.1–v5.1.3 had **crash bugs** from `set -e`/`set -u`. These failures were misattributed to the deny approach itself, leading to the v6.0.0 regression to inform. The deny mechanism was never the problem — the implementation bugs were. Those bugs are now fixed.

## [6.1.0] - 2026-04-15

### Fixed
- **Routing guard tracker persistence** — when the multi-file edit threshold was reached, the tracker file was not updated because `_deny()` exits before the write. This caused every subsequent new-file edit to re-trigger the guidance message with an incorrect file count. The tracker is now updated before the threshold check, ensuring accurate file tracking across edits.

### Removed
- **Design specs and plan artifacts** — deleted `docs/specs/` (3 completed design specs) and `.plan/` (3 completed implementation plans). These were build-process artifacts that served no purpose in the final product.

## [6.0.0] - 2026-04-15

### Changed
- **Routing guard informs instead of blocking** — when 3+ files are edited outside an active pipeline, the routing guard now allows the edit and injects guidance context telling Claude to use stn-skills pipelines. Previously, the edit was hard-blocked, requiring manual override or env var workarounds. This aligns with the Claude Code hook contract where routing decisions use `additionalContext` rather than deny. Security blocks (path traversal) remain hard denials.
- **Shared `_inform()` helper** — `stn-hook-output` now provides `_inform()` alongside `_allow()` and `_deny()`, enabling hooks to allow tool calls while injecting guidance text via `additionalContext`.
- **DRY session-init** — `stn-init` now sources `stn-hook-output` for JSON escaping instead of duplicating the `escape_for_json` function. Single source of truth for all character escaping.
- **Removed `set -e` from all 7 hooks** — replaced with explicit error handling (`|| fallback`) to prevent fail-crash behavior. The `set -e` (errexit) flag was the architectural root cause of crash-class bugs: any unhandled error converted a fail-open hook into a fatal crash.
- **DRY `stn-session-lock`** — removed duplicated `_json_escape()`, now sources `stn-hook-output` and overrides only `_deny()` with the SessionStart event name.
- **SessionStart hook timeouts** — `hooks.json` now specifies 10-second timeouts for `stn-init` and `stn-session-lock` (previously no timeout, could hang indefinitely).
- **Eval runner crash detection** — eval runner now detects crashed eval scripts (non-zero exit with no failures) and empty runs (zero tests executed), preventing silent false-green reports.
- **Shell expansion security scan** — now includes `stn-hook-output` in the security scan (previously only scanned 6 of 7 executable hook files).
- **Quality metrics threshold aligned** — SKILL.md line limit aligned to 600 lines (matching eval-structure and README documentation) with warn at 500 lines.

### Fixed
- **Complete JSON escaping** — `_json_escape()` in `stn-hook-output` now escapes all 6 JSON control characters (`\n`, `\r`, `\t`, `\b`, `\f`, plus `\` and `"`). Previous version only escaped 3, producing invalid JSON when error messages or file paths contained tab, carriage return, backspace, or form feed characters.
- **Routing guard JSON injection** — jq fallback used raw string concatenation, allowing file paths with `"` or control chars to produce invalid JSON. Now uses `_json_escape()` for safe escaping.
- **`local` outside function crash** — routing guard jq fallback used `local` at top level, crashing on bash 3.2 (macOS default). Inlined to single expression.
- **Session lock wrote hook PID** — `echo "$$"` wrote the short-lived hook process PID instead of Claude Code's PID (`$PPID`), making the lock always appear stale. Lock now persists correctly.
- **Stale state false positive** — `stn-init` stat fallback used epoch 0, making files appear 56 years old when stat variants fail. Now falls back to current time (age = 0, no stale warning).
- **Skill gate missing python3 fallback** — `ACTIVE_SKILL` and `HANDOFF_VALIDATED` reads had no python3 fallback (unlike input parsing), silently bypassing chain enforcement when jq was absent.

### Added
- **57 behavioral tests** — comprehensive hook test suite covering JSON escaping with all control characters, scope-guard deny with special characters in paths, session-lock deny JSON validity, and inform-mode routing guard assertions.

## [5.2.0] - 2026-04-15

### Changed
- **Shared hook output helpers** — extracted `_allow()`, `_deny()`, and `_json_escape()` into `hooks/stn-hook-output`. All 5 PreToolUse hooks source this single file instead of duplicating helpers. Format changes now require editing one file, not five.
- **Routing guard `additionalContext`** — deny output now includes a directive as `additionalContext`, making Claude more likely to follow the corrective action instead of asking for env var overrides.
- **Routing guard condition cleanup** — merged split condition blocks back to single condition. Numeric validation already ensures safe integer comparison.
- **Session-lock `_deny` refactored** — multi-line with shared `_json_escape()` pattern instead of unreadable one-liner.
- **Consistent hook headers** — removed outdated version references. All hooks now say "Part of stn-skills Layered Defense Enforcement."

## [5.1.5] - 2026-04-15

### Changed
- **Removed `set -u` (nounset) from all 7 hooks** — the `nounset` flag was the root cause of all three crash reports in v5.1.1–v5.1.3 (`unbound variable` on non-numeric state values). Hooks process external data where strict nounset creates fragility. All variable fallbacks remain in place as defense-in-depth. Verified with 51 behavioral tests covering every hook with every edge case.

## [5.1.4] - 2026-04-15

### Fixed
- **`_deny()` JSON escaping** — all hooks now escape `\`, `"`, and newlines in deny reason strings before embedding in JSON output. Prevents invalid JSON when file paths or error messages contain special characters.
- **Routing guard tracker fallback** — jq call had no error fallback, causing silent script exit under `set -e` if jq failed on corrupted tracker data. Now falls back to single-file array.
- **Test grep literal matching** — test helper now uses fixed string matching instead of regex to prevent false positive substring matches.

## [5.1.3] - 2026-04-15

### Fixed
- **Routing guard crash on non-numeric state values** — crashed with `unbound variable` when pipeline state had non-numeric `current_phase`/`total_phases` (strings, booleans). Added numeric validation with fallback to 0.
- **All eval assertions updated** — test suite still checked for deprecated output format after v5.1.1 migrated hooks to `hookSpecificOutput`/`permissionDecision`. All assertions now match the correct format.

## [5.1.2] - 2026-04-15

### Fixed
- **Routing guard `set -u` crash** — crashed with `unbound variable` on macOS bash 3.2 when a pipeline had `active_skill: "plan-execution"`. The `-gt` operator inside `[[ ]]` evaluates operands in arithmetic context where `plan-execution` is parsed as `plan - execution`, triggering `set -u`.

## [5.1.1] - 2026-04-15

### Fixed
- **Hook JSON output format** — all hooks now output the Claude Code `hookSpecificOutput` format with `permissionDecision`/`permissionDecisionReason` instead of the deprecated `{"decision":"allow/block"}` format. Eliminates JSON validation errors and ensures corrective actions are properly delivered to Claude as structured context.
- **Routing guard corrective action delivery** — with the corrected output format, the routing guard's deny reason is now parsed as structured `permissionDecisionReason`. Claude receives the corrective action automatically.

### Changed
- **Hook output helpers** — all PreToolUse hooks use shared `_allow()` / `_deny()` helper functions for consistent output formatting.
- **Documentation** — `docs/recommended-hooks.md` updated with correct `hookSpecificOutput` format examples.

## [5.1.0] - 2026-04-14

### Added
- **Routing guard hook** — `stn-routing-guard` detects multi-file edits (3+ unique files) outside active pipelines. Self-healing tracker with 12h staleness window. Dedicated kill-switch (`STN_ROUTING_GUARD_SKIP=1`). Configurable threshold (`STN_ROUTING_GUARD_THRESHOLD`).
- **Path traversal protection** — `stn-routing-guard` and `stn-scope-guard` reject file paths containing `../` sequences.
- **session-init README** — full documentation for the auto-discovery skill with routing table, enforcement details, and pipeline links.
- **Troubleshooting section** — root README now includes FAQ for common hook and pipeline questions.

### Changed
- **Hook hardening** — python3 fallbacks added to `stn-skill-gate`, `stn-state-validator`, and `stn-circuit-breaker`. All hooks now work without jq installed.
- **stn-init injection fix** — python3 fallback now uses `sys.argv` instead of string interpolation, preventing potential code injection.
- **stn-session-lock hardened** — atomic `mkdir` (no `-p`) for lock acquisition, numeric PID validation, safe stale lock cleanup without `rm -rf`.
- **session-init skip criteria tightened** — "one-line fix" → "single-file fix". Added "mechanical/routine changes" to Red Flags table.
- **Behavioral eval suite** — expanded to 48 tests covering session-lock, skill-gate chain validation, state-validator edge cases, circuit-breaker tool gating, scope-guard path traversal, and routing-guard extras.

### Security
- **Path traversal rejection** — `stn-scope-guard` and `stn-routing-guard` block `../` paths.
- **Injection-safe python3 fallbacks** — all hooks use `sys.argv` or `sys.stdin` for value passing, never string interpolation.
- **Session-lock race condition fixed** — concurrent sessions can no longer both acquire the lock via `mkdir -p`.

## [5.0.0] - 2026-04-14

### Added
- **5 PreToolUse hook scripts** — `stn-skill-gate` (blocks invalid skill chain invocations), `stn-state-validator` (validates JSON on state file writes), `stn-scope-guard` (blocks writes outside task scope), `stn-circuit-breaker` (blocks at RED threshold), `stn-session-lock` (prevents concurrent sessions via mkdir lock). All hooks use jq with python3 fallback, include kill-switch (`STN_SKILLS_HOOKS_DISABLE=1`), and are security-hardened (no shell expansion of state values).
- **Behavioral eval suite** — 22 deterministic hook tests (no LLM calls). Tests kill-switch, blocking, allowing, and security for all hooks.
- **Coverage matrix** — maps all requirements to implementing files, tasks, and eval checks.
- **Scope enforcement file** — `current-task-scope.json` written by plan-execution before each task, read by `stn-scope-guard` hook. Enables hardware-level file scope enforcement during execution.
- **Schema versioning** — `schema_version` field in pipeline-state-protocol.md. Optional, defaults to 1 if absent. Enables future state migrations.

### Changed
- **stn-init migrated to jq** — replaced grep/sed JSON parsing with jq (python3 fallback). Added kill-switch, artifact_path existence check, `json_get` helper function.
- **XML delimiters in agent prompts** — `<codebase-context>` tags prevent prompt injection via codebase content.
- **MAX_FILES truncation** — codebase-cartographer (200) and task-implementer (20) prevent context window exhaustion on large codebases.
- **Hook registration** — hooks.json and hooks-cursor.json now include all hooks (SessionStart + PreToolUse).
- **recommended-hooks.md** — rewritten to document built-in hooks instead of manual setup instructions.
- **codebase-audit pipeline handoff** — auto-invokes brainstorming/plan-writing after generating remediation brief.

### Security
- **Kill-switch** — `STN_SKILLS_HOOKS_DISABLE=1` env var bypasses all hooks (emergency override).
- **No shell expansion** — all hooks use jq for JSON parsing with double-quoted variables. No `eval` or unquoted `$()` patterns.
- **Scope guard** — hardware-level enforcement preventing writes outside declared task scope during plan-execution.
- **Session lock** — mkdir-based lock with PID validation prevents concurrent session state corruption.
- **State validation** — malformed JSON writes to pipeline state files are blocked before they reach disk.

## [4.2.0] - 2026-04-14

### Changed
- **Intent-based routing** — session-init routing table now matches by semantic intent instead of literal English keywords. Works in any language.
- **Subagent guard** — subagents dispatched for specific tasks now skip session-init routing, preventing recursive skill invocation.
- **Instruction priority** — explicit hierarchy: user project rules (CLAUDE.md) > stn-skills > system defaults.
- **Pre-plan-mode gate** — entering plan mode now checks whether brainstorming was done first for non-trivial tasks.
- **Stronger no-match fallback** — tasks touching 3+ files or requiring design decisions are re-evaluated instead of proceeding without a skill.
- **Expanded rationalizations** — 11 anti-bypass entries covering common skip patterns.

## [4.1.0] - 2026-04-14

### Changed
- **Multi-platform branding** — all user-facing text updated from Claude Code-only to multi-platform. stn-skills now officially lists Claude Code, Cursor, and Copilot CLI as supported platforms.

## [4.0.0] - 2026-04-13

### Added
- **Auto-discovery SessionStart hook** — stn-skills now auto-loads at every session start via `hooks/hooks.json` and `hooks/stn-init`. Injects the `session-init` discovery skill with pipeline-state awareness into the session context. Pure bash, <50ms, zero external dependencies.
- **session-init discovery skill** — new skill with pipeline-state-first routing. When an active pipeline exists, directs Claude to resume it. For fresh sessions, provides a compact skill catalog with routing rules.
- **Pipeline state protocol** — JSON state file (`.claude/stn-skills-pipeline-state.json`) tracks active skill, phase, gates across sessions.
- **Artifact gates** — every phase checks that the previous phase produced its required artifact before proceeding.
- **Mandatory handoff validation** — transition sections now run the pipeline-handoff-validator before offering skill advancement.
- **Anti-fast-tracking rationalizations** — research-backed entries in all core skill rationalization tables.
- **Cursor support** — `.cursor-plugin/` directory with `plugin.json` and `hooks-cursor.json`.
- **Copilot CLI support** — `hooks/stn-init` detects Copilot CLI via `COPILOT_CLI` env var and outputs the correct JSON format.
- **Recommended hooks template** — `docs/recommended-hooks.md` provides hook reference and override documentation.
- **Explicit state updates at gates** — every gate section now includes "On confirmation: update state file" instructions.

### Changed
- **Version** bumped to 4.0.0 (major: new auto-discovery infrastructure).
- **Skills count** 7 → 8 (added session-init).
- **Plugin manifests** updated with new skill and keywords.

## [3.5.0] - 2026-04-13

### Added
- **Three-layer chaining defense** — skill chaining instructions now appear at three context-stable locations: skill description, Mandatory Skill Chain section, and strengthened Transition section.
- **Artifact-embedded chaining** — plan and design spec templates now include a header line pointing to the next pipeline skill.
- **Anti-rationalization entries** — for "I can just start executing/planning directly".
- **Chaining validation evals** — checks for CHAINS TO in description and Mandatory Skill Chain section.

### Changed
- **Skill descriptions** for brainstorming and plan-writing now include `CHAINS TO [next-skill]` in YAML frontmatter.
- **Build-feature transitions** aligned with strengthened chaining language from sub-skills.

## [3.4.0] - 2026-04-13

### Changed
- **All skill descriptions** rewritten for stronger discovery and priority — clearer trigger keywords, more specific scope declarations, better alignment with how Claude Code surfaces skills.

## [3.3.0] - 2026-04-13

### Added
- **Skill chaining** — brainstorming, plan-writing, and plan-execution now declare their follow-up skill in a `## Transition` section with explicit Skill tool invocation.
- **AskUserQuestion integration** — all 24 user-facing interaction points across 6 skills now instruct the agent to use the AskUserQuestion tool instead of inline text.
- **Anti-passivity rule** in plan-execution — after a gate confirmation, execution continues immediately without re-asking.
- **Consistency eval** — 30 cross-reference validations: agent/reference file existence, phase/gate counts, decision matrix weights, audit domain coverage, plugin.json consistency.
- **Quality metrics eval** — quality dashboard with line counts, token efficiency, progressive disclosure ratios, and cross-skill reference sharing.
- **Extended structure checks** — agent 200-line and reference 150-line enforcement, README.md and banner.svg existence per skill.
- **Red Flags and Common Rationalizations** sections added to build-feature SKILL.md.

### Changed
- **All gate interactions** rewritten to Gate Protocol Format with AskUserQuestion instructions.
- **5 codebase-audit agents** trimmed to 200 lines. All functional content preserved.
- **5 reference files** trimmed to 150 lines. All template sections and fields preserved.

### Fixed
- **Ambiguous reference paths** in pipeline-handoff-validator — now use full cross-skill paths.
- **codebase-audit SKILL.md** compacted to fit within line limit after AskUserQuestion integration.

## [3.2.0] - 2026-04-12

### Added
- **Pipeline Handoff Validator skill** — validates artifacts at pipeline boundaries before the next phase consumes them. Two modes: design spec validation (6 checks) and plan validation (7 checks).
- **Eval framework** — `evals/` directory with structure validation and activation testing scripts.
- **Concrete examples** in pipeline skills — decision matrix, complete task, and spec compliance review examples.
- **Visible verification output requirements** — structured result tables mandated for verification phases.
- **Agent dispatch table** in plan-writing.
- **Audit domain alignment reference** in codebase-quality-bootstrap.

### Changed
- **All skill descriptions** rewritten to trigger-focused format for improved activation rates.
- **All command descriptions** updated to match trigger-focused format.
- **codebase-audit** trimmed from 541 to 495 lines — Finding Suppression and Enterprise Mandate Compliance moved to reference files.
- **codebase-quality-bootstrap** — softened aggressive emphasis language per Claude 4.6 best practices.
- **build-feature** — now invokes pipeline-handoff-validator between macro-phases.

### Fixed
- Missing `audit-domain-alignment.md` reference in codebase-quality-bootstrap context package.
- Incomplete dispatch table in plan-writing.

## [3.1.0] - 2026-04-12

### Added
- **Pipeline escalation for complex audit findings** — codebase-audit classifies findings into Quick Fix and Pipeline categories. Complex findings generate structured remediation briefs for the full pipeline.
- **Context refresh mandate** in plan-execution — orchestrator re-reads scope files before every task dispatch; task-implementer reads current file state.
- **Full context refresh in post-execution cleanup** — reads complete final state of every modified file before scanning.
- **TDD safeguard** in task-implementer — flags concern when plan orders implementation before tests.
- **Research-backed methodology documentation** — root README includes evidence table linking design principles to measured outcomes.
- **Duration estimates** across all skills and READMEs.
- **Tree-structured search documentation** in brainstorming connecting multi-lens exploration to research findings.

### Changed
- Root README expanded with visible differentiator sections for brainstorming, plan-writing, plan-execution, and codebase-audit.
- Pipeline diagram now shows codebase-audit → pipeline escalation flow.
- Available Skills table includes "Typical Duration" column.

## [3.0.0] - 2026-04-12

### Added
- **Brainstorming skill** — 6-phase structured design exploration with 5 cognitive lenses, weighted 7-criteria decision matrix, 11-type adversarial reasoning flaw taxonomy, and adaptive depth.
- **Plan-Writing skill** — 6-phase DAG-based task decomposition with zero-placeholder enforcement, complete code in every step, 7-check adversarial verification, and Plan Quality Score.
- **Plan-Execution skill** — 7-phase checkpoint-verified execution with 3-stage sequential review, drift detection, dual-threshold circuit breakers, and Execution Fidelity Score.
- **Build-Feature meta-skill** — end-to-end pipeline chaining brainstorming → plan-writing → plan-execution.
- Cross-cutting Modernization Guard in every agent prompt.
- Token-efficient progressive disclosure architecture.
- KV-cache optimized agent prompt structure.

## [2.5.0] - 2026-04-10

### Added
- Brownfield structural transformation for CLAUDE.md generation.
- Mandatory pre-preview check ensuring Enterprise Mandates are always present in output.
- Block suppression syntax for multi-line constructs.
- Mass assignment / over-posting check in security auditor.
- 14 international PII patterns (aadhaar, cpf, nric, iban, biometric, etc.).
- 6 framework false-positive patterns in dead-code auditor.
- File extension guards in all hook commands.
- Monorepo handling guidance.
- Deploy recommendation in report template.
- Sampling caps for findings verifier.
- CLAUDE.md, CHANGELOG.md, CONTRIBUTING.md, GitHub issue/PR templates.

### Changed
- Domain-specific confidence and effort examples in all 13 auditor agents.
- Synchronized Enterprise Mandate names across all files.
- Migration files nuance: standard forward-only migrations are compliant.
- Expanded whitelist for naming mandates.
- Pragmatic test-first framing in testing analyzer.
- Brownfield merge now inserts missing standard sections.
- Build systems table synced between audit and bootstrap.

## [2.4.0] - 2026-04-10

### Changed
- Enforce mandatory compliance checks in brownfield mode.
- Upgrade codebase-quality-bootstrap to enterprise-grade quality.

## [2.3.0] - 2026-04-10

### Changed
- Version bump consolidating bootstrap quality improvements.

## [2.1.0] - 2026-04-09

### Added
- codebase-quality-bootstrap skill (preventive counterpart to codebase-audit).
- `/stn-skills:codebase-quality-bootstrap` slash command.

### Changed
- Restructured docs for multi-skill suite architecture.
- Rewrite codebase-quality-bootstrap README to match codebase-audit quality.
- Add .gitignore to exclude .claude/ directory.

## [2.0.0] - 2026-04-09

### Added
- Standalone plugin with remediation execution.
- Marketplace registration.
- `/stn-skills:codebase-audit` slash command.
- Enterprise upgrade: confidence scores, effort estimates, enriched auditors.
- Suppression syntax, Mermaid diagrams, conflict detection, CI/CD docs.

### Changed
- Renamed plugin to stn-skills (Sven Thiermann skill suite).
- Restructured as multi-skill suite.
- Fixed header consistency, coverage tables, docs.

## [1.0.0] - 2026-04-09

### Added
- Initial release: comprehensive, technology-agnostic codebase audit skill for Claude Code.
- 13-domain evidence-based repository audit.
- 17 specialized agent prompts.
- Severity rules and report template.
