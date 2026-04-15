# Changelog

All notable changes to this project will be documented in this file.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [5.1.2] - 2026-04-15

### Fixed
- **Routing guard `set -u` crash** — `stn-routing-guard` line 45 crashed with `execution: unbound variable` on macOS bash 3.2 when a pipeline had `active_skill: "plan-execution"`. The `-gt` operator inside `[[ ]]` evaluates operands in arithmetic context where `plan-execution` is parsed as `plan - execution`, triggering `set -u`. Fixed by splitting into separate `[[ ]]` blocks and adding `${:-}` defaults to all integer comparisons.

## [5.1.1] - 2026-04-15

### Fixed
- **Hook JSON output format** — all 6 PreToolUse hooks (`stn-skill-gate`, `stn-state-validator`, `stn-routing-guard`, `stn-scope-guard`, `stn-circuit-breaker`) and `stn-session-lock` now output the Claude Code `hookSpecificOutput` format with `permissionDecision`/`permissionDecisionReason` instead of the deprecated `{"decision":"allow/block"}` format. This eliminates `Hook JSON output validation failed — (root): Invalid input` errors and ensures `permissionDecisionReason` (including corrective actions like "Invoke stn-skills:build-feature") is properly delivered to Claude as structured context.
- **Routing guard corrective action delivery** — with the corrected output format, the routing guard's deny reason ("Invoke stn-skills:build-feature or stn-skills:brainstorming") is now parsed as structured `permissionDecisionReason` instead of appearing as an unstructured error message. Claude should now follow the corrective action automatically.

### Changed
- **Hook output helpers** — all PreToolUse hooks use shared `_allow()` / `_deny()` helper functions for consistent, DRY output formatting.
- **Documentation** — `docs/recommended-hooks.md` updated with correct `hookSpecificOutput` format examples.

## [5.1.0] - 2026-04-14

### Added
- **Routing guard hook** — `stn-routing-guard` blocks multi-file edits (3+ unique files) outside active pipelines. Closes the gap where Claude could bypass session-init routing and implement directly without skill invocation. Self-healing tracker with 12h staleness window. Dedicated kill-switch (`STN_ROUTING_GUARD_SKIP=1`). Configurable threshold (`STN_ROUTING_GUARD_THRESHOLD`).
- **Path traversal protection** — `stn-routing-guard` and `stn-scope-guard` reject file paths containing `../` sequences.
- **session-init README** — full documentation for the auto-discovery skill with routing table, enforcement details, and pipeline links.
- **Troubleshooting section** — root README now includes FAQ for common hook and pipeline questions.

### Changed
- **Hook hardening** — python3 fallbacks added to `stn-skill-gate` (skill name parsing), `stn-state-validator` (JSON validation + field checks), and `stn-circuit-breaker` (state + failure count). All hooks now work without jq installed.
- **stn-init injection fix** — python3 fallback in `json_get` now uses `sys.argv` instead of string interpolation, preventing potential code injection.
- **stn-session-lock hardened** — atomic `mkdir` (no `-p`) for lock acquisition, numeric PID validation, safe stale lock cleanup without `rm -rf`.
- **session-init Skip criteria tightened** — "one-line fix" → "single-file fix". Added "mechanical/routine changes" to Red Flags table.
- **Behavioral eval suite** — expanded from 22 to 48 tests. Session-lock (3 tests), skill-gate chain validation (4 tests), state-validator edge cases (3 tests), circuit-breaker tool gating (3 tests), scope-guard path traversal (1 test), routing-guard extras (3 tests).
- **Coverage matrix** — expanded from R1-R20 to R1-R26.
- **Marketplace description** — rewritten with value proposition, research backing, and metrics.
- **.gitignore** — removed `docs/` exclusion to allow versioned documentation.
- **Skill table links** — root README skill table now links to individual skill READMEs.

### Security
- **Path traversal rejection** — `stn-scope-guard` and `stn-routing-guard` block `../` paths.
- **Injection-safe python3 fallbacks** — all hooks use `sys.argv` or `sys.stdin` for value passing, never string interpolation.
- **Session-lock race condition fixed** — concurrent sessions can no longer both acquire the lock via `mkdir -p`.

## [5.0.0] - 2026-04-14

### Added
- **5 PreToolUse hook scripts** — `stn-skill-gate` (blocks invalid skill chain invocations), `stn-state-validator` (validates JSON on state file writes), `stn-scope-guard` (blocks writes outside task scope), `stn-circuit-breaker` (blocks at RED threshold), `stn-session-lock` (prevents concurrent sessions via mkdir lock). All hooks use jq with python3 fallback, include kill-switch (`STN_SKILLS_HOOKS_DISABLE=1`), and are security-hardened (no shell expansion of state values).
- **Behavioral eval suite** — `evals/eval-behavior.sh` with 22 deterministic hook tests (no LLM calls). Tests kill-switch, blocking, allowing, and security for all 6 hooks.
- **Coverage matrix** — `evals/coverage-matrix.json` maps all 20 requirements to implementing files, tasks, and eval checks.
- **Scope enforcement file** — `current-task-scope.json` written by plan-execution before each task, read by `stn-scope-guard` hook. Enables hardware-level file scope enforcement during execution.
- **Schema versioning** — `schema_version` field in pipeline-state-protocol.md. Optional, defaults to 1 if absent. Enables future state migrations.
- **Protocol sync eval** — `eval-consistency.sh` checks C-31 (3 protocol copies identical) and C-32 (schema_version present).

### Changed
- **stn-init migrated to jq** — replaced grep/sed JSON parsing with jq (python3 fallback). Added kill-switch, artifact_path existence check, `json_get` helper function.
- **XML delimiters in 6 agent prompts** — `<codebase-context>` tags prevent prompt injection via codebase content in codebase-cartographer, step-author, task-implementer, problem-decomposer, code-quality-reviewer, completion-verifier.
- **MAX_FILES truncation** — codebase-cartographer (MAX_FILES=200) and task-implementer (MAX_FILES=20) prevent context window exhaustion on large codebases.
- **Hook registration** — hooks.json and hooks-cursor.json now include all 6 hooks (SessionStart + PreToolUse).
- **recommended-hooks.md** — rewritten to document v5.0.0 built-in hooks instead of manual setup instructions.
- **codebase-audit pipeline handoff** — auto-invokes brainstorming/plan-writing after generating remediation brief (was passive text only).

### Security
- **Kill-switch** — `STN_SKILLS_HOOKS_DISABLE=1` env var bypasses all hooks (emergency override).
- **No shell expansion** — all hooks use jq for JSON parsing with double-quoted variables. No `eval` or unquoted `$()` patterns.
- **Scope guard** — hardware-level enforcement preventing writes outside declared task scope during plan-execution.
- **Session lock** — mkdir-based lock with PID validation prevents concurrent session state corruption.
- **State validation** — malformed JSON writes to pipeline state files are blocked before they reach disk.

## [4.2.0] - 2026-04-14

### Changed
- **Intent-based routing** — session-init routing table now matches by semantic intent instead of literal English keywords. Works in any language — German, Japanese, or any other language triggers the correct skill.
- **Subagent guard** — subagents dispatched for specific tasks now skip session-init routing, preventing recursive skill invocation.
- **Instruction priority** — explicit hierarchy: user project rules (CLAUDE.md) > stn-skills > system defaults.
- **Pre-plan-mode gate** — entering plan mode now checks whether brainstorming was done first for non-trivial tasks.
- **Stronger no-match fallback** — tasks touching 3+ files or requiring design decisions are re-evaluated instead of proceeding without a skill.
- **Expanded rationalizations** — 11 anti-bypass entries (was 6), covering "I need more context first", "let me just explore quickly", and other common skip patterns.
- **Version** bumped to 4.2.0.

## [4.1.0] - 2026-04-14

### Changed
- **Multi-platform branding** — all user-facing text updated from Claude Code-only to multi-platform. stn-skills now officially lists Claude Code, Cursor, and Copilot CLI as supported platforms across README, plugin manifests, skill READMEs, templates, and documentation.
- **Version** bumped to 4.1.0.

## [4.0.0] - 2026-04-13

### Added
- **Auto-discovery SessionStart hook** — stn-skills now auto-loads at every session start via `hooks/hooks.json` and `hooks/stn-init`. Injects the `session-init` discovery skill with pipeline-state awareness into the session context. Pure bash, <50ms, zero external dependencies.
- **session-init discovery skill** — New skill (`skills/session-init/SKILL.md`) with pipeline-state-first routing. When an active pipeline exists, directs Claude to resume it. For fresh sessions, provides a compact skill catalog with routing rules.
- **Pipeline state protocol** — JSON state file (`.claude/stn-skills-pipeline-state.json`) tracks active skill, phase, gates across sessions. Session Resumption Protocol in all core skills reads state at every turn.
- **Artifact Gates** — Every phase in brainstorming, plan-writing, and plan-execution checks that the previous phase produced its required artifact before proceeding.
- **Mandatory handoff validation** — Transition sections in brainstorming and plan-writing now run the pipeline-handoff-validator before offering skill advancement.
- **Anti-fast-tracking rationalizations** — Research-backed entries in all core skill rationalization tables (e.g., "at 85% per-step accuracy, skipping verification drops success to 20%").
- **Cursor support** — `.cursor-plugin/` directory with `plugin.json` and `hooks-cursor.json` for Cursor IDE.
- **Copilot CLI support** — `hooks/stn-init` detects Copilot CLI via `COPILOT_CLI` env var and outputs the correct JSON format.
- **Recommended hooks template** — `docs/recommended-hooks.md` (local, gitignored) provides a PreToolUse hook that blocks code edits outside plan-execution phase.
- **Explicit state updates at gates** — Every gate section now includes "On confirmation: update state file" instructions.

### Changed
- **Version** bumped to 4.0.0 (major: new auto-discovery infrastructure).
- **Skills count** 7 → 8 (added session-init).
- **Plugin manifests** updated with new skill and keywords.

## [3.5.0] - 2026-04-13

### Added
- **Three-layer chaining defense** — Skill chaining instructions now appear at three context-stable locations: skill description (survives context compression), Mandatory Skill Chain section (near top of skill), and strengthened Transition section (at decision point). Prevents Claude from starting the next pipeline phase without invoking the skill.
- **Artefakt-embedded chaining** — Plan and design spec templates now include a header line pointing to the next pipeline skill, so chaining info is visible whenever the artifact is read.
- **Anti-rationalization entries** — Common Rationalizations tables in brainstorming and plan-writing now include entries for "I can just start executing/planning directly".
- **Chaining validation evals** — New checks C-20 (CHAINS TO in description) and C-21 (Mandatory Skill Chain section) in eval-consistency.sh.

### Changed
- **Skill descriptions** for brainstorming and plan-writing now include `CHAINS TO [next-skill] — MUST invoke via Skill tool` in YAML frontmatter.
- **Eval trigger format check** fixed — eval-structure.sh now checks for `Triggers:` keyword (matching current description format) instead of obsolete `Invoke` keyword.
- **Build-feature transitions** aligned with strengthened MANDATORY language from sub-skills.
- **Version** bumped to 3.5.0.

### Fixed
- **README version badge** updated from 3.3.0 to 3.5.0.
- **CHANGELOG gap** — Added missing v3.4.0 entry.

## [3.4.0] - 2026-04-13

### Changed
- **All skill descriptions** rewritten for stronger discovery and priority — clearer trigger keywords, more specific scope declarations, better alignment with how Claude Code surfaces skills in the system prompt.
- **Version** bumped to 3.4.0.

## [3.3.0] - 2026-04-13

### Added
- **Skill chaining** — brainstorming, plan-writing, and plan-execution now declare their follow-up skill in a `## Transition` section with explicit Skill tool invocation. After completion, the user is offered to continue to the next pipeline step via AskUserQuestion. On "continue", the follow-up skill is invoked automatically.
- **AskUserQuestion integration** — All 24 user-facing interaction points across 6 skills (gates, interviews, circuit breakers, transitions) now instruct the agent to use the AskUserQuestion tool instead of inline text. Provides structured options for every gate.
- **Anti-passivity rule** in plan-execution — New rule: "After a gate confirmation, execution continues immediately. Do not ask 'Should I start?', 'Which task first?', or similar." Eliminates passive re-asking after gate approvals.
- **Eval: consistency checks** (`evals/eval-consistency.sh`) — 30 new cross-reference validations: agent/reference file existence, phase/gate counts vs README, Modernization Mandate presence, decision matrix weight sums, score dimension sums, audit domain coverage, plugin.json consistency, activation prompt coverage, handoff validator path resolution.
- **Eval: quality metrics** (`evals/eval-quality-metrics.sh`) — Quality dashboard with SKILL.md/agent/reference line counts, progressive disclosure ratios, cross-skill reference sharing map, total markdown line count.
- **Eval: extended structure checks** — Agent ≤200-line and reference ≤150-line enforcement, README.md and banner.svg existence checks per skill.
- **Red Flags and Common Rationalizations** sections added to build-feature SKILL.md — Previously the only skill missing these standard sections.

### Changed
- **All gate interactions** across brainstorming (4 gates + interview), plan-writing (4 gates), plan-execution (3 gates + 2 inline pauses), build-feature (2 transitions), codebase-audit (3 gates), and codebase-quality-bootstrap (2 gates) rewritten to Gate Protocol Format with AskUserQuestion instructions.
- **5 codebase-audit agents** trimmed to ≤200 lines: architecture-auditor, code-quality-auditor, infrastructure-auditor, security-auditor, test-coverage-auditor. All functional content preserved.
- **5 reference files** trimmed to ≤150 lines: report-template, audit-domain-alignment, claudemd-template, hooks-catalog, plan-document-template. All template sections and fields preserved.
- **Version** bumped to 3.3.0.

### Fixed
- **Ambiguous reference paths** in pipeline-handoff-validator — `references/design-spec-template.md` and `references/plan-document-template.md` now use full cross-skill paths (`skills/brainstorming/references/...`, `skills/plan-writing/references/...`).
- **codebase-audit SKILL.md** exceeded 500-line limit after AskUserQuestion integration — compacted gate blocks to inline format, back to 491 lines.

## [3.2.0] - 2026-04-12

### Added
- **Pipeline Handoff Validator skill** — New skill that validates artifacts at pipeline boundaries before the next phase consumes them. Two modes: Mode A validates design specs before plan-writing (6 contract checks), Mode B validates plans before plan-execution (7 contract checks). Produces structured Handoff Compliance Tables. Integrated into build-feature between macro-phases.
- **Eval framework** — New `evals/` directory with structure validation (`eval-structure.sh`) and activation testing (`eval-activation.sh`) scripts. Includes prompt files for all skills and a runner that produces timestamped reports.
- **Concrete examples** in pipeline skills — Decision matrix example in brainstorming, complete task example in plan-writing, spec compliance review example in plan-execution. Anchors expected output quality.
- **Visible verification output requirements** — Structured result tables mandated for plan-writing Phase 5 (7-check table), brainstorming Phase 4 (flaw assessment table), and codebase-audit Phase 3 (sampling table). Prevents verification step skipping.
- **Agent dispatch table** in plan-writing — Formal table listing all 4 agents with phases and purposes, consistent with other skills.
- **Audit domain alignment reference** now documented in codebase-quality-bootstrap context package.

### Changed
- **All skill descriptions** rewritten to trigger-focused format (`Invoke for [trigger]. Covers [scope].`) for improved activation rates. Based on research showing directive descriptions achieve higher activation.
- **All command descriptions** updated to match trigger-focused format.
- **codebase-audit** trimmed from 541 to 495 lines — Finding Suppression and Enterprise Mandate Compliance moved to reference files. Under Anthropic's 500-line recommendation.
- **codebase-quality-bootstrap** — Softened aggressive emphasis language (`CRITICAL:`, `NEVER`, `MUST`) to normal instructions per Claude 4.6 best practices (reduces overtriggering).
- **build-feature** — Now invokes pipeline-handoff-validator between macro-phases for artifact contract validation.
- **Version** bumped to 3.2.0.

### Fixed
- Missing `audit-domain-alignment.md` reference in codebase-quality-bootstrap context package (used by all 6 analyzer agents but undocumented).
- Incomplete dispatch table in plan-writing (only showed 2 of 4 agents in table format).

## [3.1.0] - 2026-04-12

### Added
- **Pipeline escalation for complex audit findings** — codebase-audit GATE 3 now classifies findings into Quick Fix (direct remediation) and Pipeline `[PIPELINE]` (generates structured remediation brief for brainstorming or plan-writing). Complex findings — architectural violations, large-scale refactoring, design decisions — are handled through the full design-to-delivery pipeline instead of surgical fixes.
- **Context refresh mandate** in plan-execution — orchestrator re-reads all scope files before every task dispatch; task-implementer reads current file state instead of relying on plan-authored snapshots. Prevents plan staleness across multi-task execution.
- **Full context refresh in post-execution cleanup** — Phase 4 reads complete final state of every modified file before scanning, catching issues that emerge only in combination of multiple task changes.
- **TDD safeguard** in task-implementer — flags concern when plan orders implementation before tests, prioritizes test-first execution.
- **Research-backed methodology documentation** — root README now includes evidence table linking each design principle to measured outcomes (12-18% correctness improvement from planning, 20-27% degradation prevention from per-step verification, etc.).
- **Duration estimates** across all skills and READMEs.
- **Pipeline context callouts** in all individual skill READMEs linking to the full pipeline.
- **Tree-structured search documentation** in brainstorming SKILL.md connecting multi-lens exploration to research on tree-structured generation.
- **Pipeline Escalation Candidates** subsection in audit report template and report-synthesizer with `[PIPELINE]` tagging.

### Changed
- Root README "What Makes This Different" section expanded from collapsed `<details>` to visible headers for brainstorming, plan-writing, plan-execution, and codebase-audit differentiators.
- Root README pipeline diagram now shows codebase-audit → pipeline escalation flow alongside the main pipeline.
- Available Skills table now includes "Typical Duration" column.
- Codebase-audit README adds Pipeline Escalation section explaining two-tier remediation.
- Severity classification reference adds pipeline escalation criteria note.

## [3.0.0] - 2026-04-12

### Added
- **Brainstorming skill** — 6-phase structured design exploration with 5 cognitive lenses (Inversion, Stakeholder, Constraint Removal, Temporal, Simplification), weighted 7-criteria decision matrix, 11-type adversarial reasoning flaw taxonomy, and adaptive depth (Focused/Standard/Deep). Produces validated design specifications.
- **Plan-Writing skill** — 6-phase DAG-based task decomposition with zero-placeholder enforcement (40+ prohibited patterns), complete code in every step, 7-check adversarial verification, Plan Quality Score (0-100, threshold 90+), and end-to-end traceability matrices.
- **Plan-Execution skill** — 7-phase checkpoint-verified execution with 3-stage sequential review (spec compliance → code quality → integration), 3-check drift detection, dual-threshold circuit breakers, Reflect-Retry-Escalate protocol, structured task handoff, post-execution cleanup, and Execution Fidelity Score.
- **Build-Feature meta-skill** — end-to-end pipeline chaining brainstorming → plan-writing → plan-execution with all gates preserved.
- Cross-cutting Modernization Guard in every agent prompt
- Token-efficient progressive disclosure architecture (SKILL.md max 400 lines, agent prompts max 200 lines, reference files max 150 lines)
- KV-cache optimized agent prompt structure (stable prefixes, deterministic ordering)

## [2.5.0] - 2026-04-10

### Added
- Brownfield structural transformation: converts flat H2 sections to H3 under Development Standards
- Mandatory pre-preview check ensuring Enterprise Mandates are always present in output
- Block suppression syntax (`audit-suppress-start` / `audit-suppress-end`) for multi-line constructs
- Mass assignment / over-posting check in security auditor
- 14 international PII patterns (aadhaar, cpf, nric, iban, biometric, etc.)
- 6 framework false-positive patterns in dead-code auditor (Next.js, Pytest, FastAPI, NestJS, Vue, Svelte)
- File extension guards in all hook commands (hooks-catalog.md)
- Monorepo handling guidance in both SKILL.md files
- Deploy recommendation in report template executive summary
- Sampling caps for findings verifier (max 25 Medium, 15 Low per domain)
- CLAUDE.md, CHANGELOG.md, CONTRIBUTING.md, GitHub issue/PR templates

### Changed
- Domain-specific confidence and effort examples in all 13 auditor agents (replaced copy-paste boilerplate)
- Synchronized Enterprise Mandate names across all files (canonical: code-quality-analyzer.md)
- Migration files nuance: standard forward-only migrations are Mandate 2 compliant
- Expanded Mandate 5 whitelist (constructor keywords, navigation terms, timestamps, annotations)
- Pragmatic test-first framing in testing analyzer (replaces prescriptive TDD rule)
- Brownfield merge now explicitly inserts missing standard sections (not just replaces existing)
- Line budget consistently stated as 150-250 lines across all files
- Build systems table synced between audit and bootstrap (added Rakefile, Bazel)

## [2.4.0] - 2026-04-10

### Changed
- Enforce mandatory compliance checks in brownfield mode
- Upgrade codebase-quality-bootstrap to enterprise-grade Golden Lens quality

## [2.3.0] - 2026-04-10

### Changed
- Version bump consolidating bootstrap quality improvements

## [2.1.0] - 2026-04-09

### Added
- codebase-quality-bootstrap skill (preventive counterpart to codebase-audit)
- `/stn-skills:codebase-quality-bootstrap` slash command

### Changed
- Restructured docs for multi-skill suite architecture
- Rewrite codebase-quality-bootstrap README to match codebase-audit quality
- Add hookify rule to block AI attribution in commits
- Add .gitignore to exclude .claude/ directory

## [2.0.0] - 2026-04-09

### Added
- Standalone plugin with remediation execution
- Marketplace registration (`marketplace.json`)
- `/stn-skills:codebase-audit` slash command
- Enterprise upgrade: confidence scores, effort estimates, enriched auditors
- Suppression syntax, Mermaid diagrams, conflict detection, CI/CD docs

### Changed
- Renamed plugin to stn-skills (Sven Thiermann skill suite)
- Restructured as multi-skill suite
- Fixed header consistency, coverage tables, docs
- Added missing domains to plugin.json description and keywords

## [1.0.0] - 2026-04-09

### Added
- Initial release: comprehensive, technology-agnostic codebase audit skill for Claude Code
- 13-domain evidence-based repository audit
- 17 specialized agent prompts
- Severity rules and report template
