# Design Spec: GitHub Copilot CLI Support

**Date:** 2026-04-21
**Complexity:** Standard
**Status:** Approved

> **Next step:** Use `/stn-skills:plan-writing` to decompose this spec into an executable implementation plan.

---

## Problem Statement

Make the stn-skills README claim ("a professional skill suite for Claude Code, Cursor, and Copilot CLI") substantively true by adding real Copilot CLI support with parity to the existing Cursor integration. The v4.0 CHANGELOG claim of "Copilot CLI support" is currently backed by a single fallback branch in `hooks/stn-init:112` — no plugin manifest, no hook config, no install docs, no eval coverage.

## Success Criteria

- **SC-1**: `.copilot-plugin/plugin.json` conforms to Copilot CLI schema — `jq -e '.name and .version and .skills' .copilot-plugin/plugin.json` exits 0.
- **SC-2**: `.copilot-plugin/hooks-copilot.json` uses Copilot schema (camelCase events, `bash` field, `timeoutSec`) — jq assertions + `! grep -E '"command":|"timeout":' .copilot-plugin/hooks-copilot.json`.
- **SC-3**: All 6 hook scripts produce valid Copilot JSON output via the `stn-hook-output` library when platform detection returns `copilot` — `evals/eval-copilot-contract.sh` feeds each script representative stdin + env and asserts output schema.
- **SC-4**: Kill-switch `STN_SKILLS_HOOKS_DISABLE=1` works across all 3 platforms — existing kill-switch eval extended with Copilot env combination.
- **SC-5**: Claude Code and Cursor hook output is byte-identical to v8.0.0 baseline — `evals/eval-00-golden-diff.sh` diffs against pre-refactor goldens captured from the v8.0.0 git tag.
- **SC-6**: README, CHANGELOG, CONTRIBUTING reflect actual working capability with no overclaiming — doc audit + grep-based assertion.
- **SC-7**: `docs/copilot-cli.md` honestly lists 6 known limitations (no Skill tool, userPromptSubmitted ignored, sessionStart context best-effort, 6 skills affected by AskUserQuestion, Windows requires WSL/Git Bash, CI cannot verify Copilot) — doc contains a "Known Limitations" section with all six.
- **SC-8**: Full eval suite `./evals/eval-runner.sh` passes with zero failures.
- **SC-9**: Adversarial platform-isolation eval — `COPILOT_CLI=1 CLAUDE_PLUGIN_ROOT=/tmp/x` does NOT flip Claude-path hooks to Copilot output — `evals/eval-platform-isolation.sh`.
- **SC-10**: Shell compatibility — `.copilot-plugin/hooks/<wrapper>` executes under `/bin/sh -c` (not just bash) — `evals/eval-shell-compat.sh`.

## Confirmed Assumptions

| # | Assumption | Status | Evidence |
|---|---|---|---|
| A1 | Plugin goes in `.copilot-plugin/` subdirectory | Confirmed | User chose at GATE 1 (parity over Copilot root convention) |
| A2 | Existing `skills/*/SKILL.md` format-compatible with Copilot | Confirmed | Copilot docs state SKILL.md format identical to Claude Code |
| A3 | `sessionStart` `additionalContext` behavior on Copilot | Inferred (unverified) | Tutorial says yes; reference ambiguous; known bug #2585 for preToolUse additionalContext. Design degrades gracefully if dropped |
| A4 | Copilot `preToolUse` output supports only `permissionDecision: deny` | Confirmed | Copilot docs reference |
| A5 | `userPromptSubmitted`, `postToolUse`, `sessionEnd`, `errorOccurred` output IGNORED | Confirmed | Copilot docs reference |
| A6 | No `COPILOT_PLUGIN_ROOT` env var | Confirmed | Copilot docs do not document one; grep of repo confirms no existing use |
| A7 | No Copilot hook matcher | Confirmed | Copilot hook schema has no matcher field |
| A8 | No Copilot Skill tool | Confirmed | Copilot auto-activates skills by description |
| A9 | Hook scripts remain single-file portable (runtime platform detection) | Confirmed | User's GATE 1 direction; extends existing `stn-init:110-116` pattern |
| A10 | User accepts parity gaps — document honestly, don't hack | Confirmed | User statement at GATE 1 |
| A11 | Version bump: MINOR (v8.0.0 → v8.1.0) | Confirmed | User chose at GATE 1 |
| H1 | Pipeline chain enforcement on Copilot = advisory-only | Confirmed | User chose at GATE 2 (`stn-skill-gate` dormant on Copilot; docs explicit) |
| H6 | Windows: bash-only, WSL/Git Bash required | Confirmed | User chose at GATE 2 |
| H10 | SKILL.md tool references → doc-only note in docs/copilot-cli.md | Confirmed | User chose at GATE 2; adversarial pass 2 expanded scope to 6 skills (not 2) |

## Scope Boundaries

### Always Do (no approval needed)

- Create `.copilot-plugin/plugin.json` (Copilot manifest).
- Create `.copilot-plugin/hooks-copilot.json` (Copilot hook schema).
- Create 6 thin wrapper scripts in `.copilot-plugin/hooks/` that exec main hooks with `STN_PLATFORM=copilot`.
- Refactor `hooks/stn-hook-output` into a proper library (`stn_detect_platform`, `stn_emit_context`, `stn_emit_permission_decision`, `stn_should_skip_tool`, `stn_require_json_tool`, `json_get`, platform-aware `_allow`/`_deny`/`_inform` with optional event-name param).
- Adapt all 6 hook scripts (`stn-init`, `stn-session-lock`, `stn-prompt-router`, `stn-skill-gate`, `stn-state-validator`, `stn-circuit-breaker`) to use the library.
- Consolidate 17 `jq || python3 || echo` triple-fallbacks into a single `json_get` library function.
- Add evals: `eval-00-golden-diff.sh`, `eval-copilot-contract.sh`, `eval-copilot-smoke.sh`, `eval-platform-isolation.sh`, `eval-session-lock-deny.sh`, `eval-shell-compat.sh`, `eval-copilot-skills-count.sh`, `eval-tool-requirement.sh`, `eval-lazy-source-timing.sh`.
- Write `docs/copilot-cli.md` with install + 6 known limitations.
- Update README, CHANGELOG, CONTRIBUTING, bug-report template.
- Bump version v8.0.0 → v8.1.0 in `.claude-plugin/plugin.json`, `.cursor-plugin/plugin.json`, `.copilot-plugin/plugin.json` (new), and README badge.

### Ask First (requires approval)

- Any change to Claude Code or Cursor codepaths beyond what the library extraction requires for byte-identical output.
- New external dependencies beyond jq, python3, bash.
- Live Copilot CLI installation in CI (currently out of scope — contract-spec goldens only).
- Scope expansion (PowerShell variants, additional skills, etc.).

### Never Do (hard constraints)

- Hack Copilot's documented limitations (e.g., fake `additionalContext` on `preToolUse` to work around #2585).
- Modify Claude Code or Cursor JSON output format in any way.
- Break the kill-switch `STN_SKILLS_HOOKS_DISABLE=1` on any platform.
- Commit the `.claude/` directory.
- Add Co-Authored-By lines.
- Reference "superpowers" or copied patterns.
- Overclaim in README or CHANGELOG (every documented capability must be verifiable).
- Change `SKILL.md` files (H10: doc-only note, no per-skill edits).

## Selected Approach: Shared Core Library

### Overview

Refactor `hooks/stn-hook-output` from a 41-line helper into a proper library exposing platform-aware JSON emission, centralized platform detection, in-script tool-name filtering (replacing Copilot's missing matcher), and consolidated JSON parsing (replacing 17 duplicate `jq || python3 || echo` fallbacks). All 6 hook scripts call library functions — no platform logic in hook bodies.

Copilot activation happens via 6 thin wrapper scripts in `.copilot-plugin/hooks/` that set `STN_PLATFORM=copilot`, self-locate via `$0`, and `exec` the main hook. `hooks-copilot.json` references the wrappers; wrappers re-enter the real hooks with the correct environment marker.

Claude Code and Cursor continue to invoke the 6 hooks directly via their existing `plugin.json` and `hooks.json` configurations — zero changes at the wire level. The library's platform detection returns `claude` or `cursor` (based on existing env vars + negative assertion against `STN_PLATFORM=copilot`) and emits byte-identical JSON to v8.0.0. Golden-output snapshots captured from the v8.0.0 git tag serve as the regression firewall.

### Sub-Problems and Solutions

- **SP-1 — Platform detection without `COPILOT_PLUGIN_ROOT`**: Library function `stn_detect_platform()` returns `claude | cursor | copilot | unknown` using positive + negative assertion. Cursor wins when `CURSOR_PLUGIN_ROOT` is set. Claude wins when `CLAUDE_PLUGIN_ROOT` is set AND `STN_PLATFORM` is not `copilot`. Copilot wins when `STN_PLATFORM=copilot` (set by our thin wrapper, not by Copilot CLI). Otherwise `unknown`, which triggers fail-closed on enforcement hooks (`stn-skill-gate`, `stn-circuit-breaker`, `stn-state-validator`) and fail-safe on informing hooks (`stn-init`, `stn-prompt-router`).
- **SP-2 — Copilot manifest + hooks config**: `.copilot-plugin/plugin.json` with Copilot schema fields (name, version, description, author, license, keywords, `skills` pointing at `./skills/`, `hooks` pointing at `./hooks-copilot.json`). `.copilot-plugin/hooks-copilot.json` with 3 hook events registered (camelCase `sessionStart`, `userPromptSubmitted`, `preToolUse`), `bash` field, `timeoutSec`, wrapper paths referenced relative to the plugin root.
- **SP-3 — Hook scripts adapted**: `_allow`, `_deny`, `_inform` become platform-aware. `_deny` accepts an optional 3rd argument for event name (defaults to `PreToolUse`; threaded through BOTH output branches via `%s` interpolation, not a literal). `stn-session-lock` deletes its local `_deny` override and calls `_deny "reason" "" "SessionStart"`. The other 5 hooks keep their call sites unchanged. `stn_should_skip_tool(name)` replaces Copilot's missing matcher: `stn-skill-gate`, `stn-state-validator`, `stn-circuit-breaker` call it to filter by `toolName` from stdin when platform is `copilot`.
- **SP-4 — Capability gap handling**: On Copilot, `stn-skill-gate` detects A8 (no Skill tool) and exits silently — chain enforcement becomes advisory per H1. `stn-prompt-router` on Copilot detects A5 (output ignored) and exits silently. Both gaps are explicitly documented in `docs/copilot-cli.md`.
- **SP-5 — Kill-switch parity**: The `STN_SKILLS_HOOKS_DISABLE=1` check stays at the top of every hook BEFORE library sourcing. Zero change to the existing pattern. Existing kill-switch eval extended with a `STN_PLATFORM=copilot` case.
- **SP-6 — Eval coverage**: Nine new evals (enumerated below). `eval-00-golden-diff.sh` runs first alphabetically as the regression firewall. Copilot goldens are marked contract-spec (intent, not authoritative). `eval-copilot-smoke.sh` requires `COPILOT_CLI` env var for end-to-end verification, skipped otherwise with an explicit notice.
- **SP-7 — Docs + version bump**: `docs/copilot-cli.md` + README + CHANGELOG + CONTRIBUTING + bug-report template updates, plus v8.1.0 across 3 `plugin.json` files and the README badge.

### Key Design Decisions

1. **`.copilot-plugin/` subdirectory** (not root `plugin.json`) — because the user prioritizes visual parity with `.claude-plugin/` and `.cursor-plugin/`; accept local-path install or marketplace entry in return.
2. **Shared Core Library over inline branches** — because drift risk across 6 copy-pasted branches compounds in 6–12 months; the library centralizes platform logic in one diffable file (weighted winner 78.8/100).
3. **Thin wrappers in `.copilot-plugin/hooks/`** — because Copilot's path resolution for `hooks-copilot.json` is undocumented and CWD may be the user's project root, not the plugin root; wrappers deterministically self-locate via `$0` and exec the real hooks.
4. **`STN_PLATFORM=copilot` set by wrappers** — because no `COPILOT_PLUGIN_ROOT` env var exists, and env-var-based detection is spoofable; our own marker set by our own wrapper is the authoritative signal, combined with negative assertion against Claude/Cursor markers.
5. **`_deny` optional event-name** — because `stn-session-lock` needs `SessionStart`, not `PreToolUse`; eliminates the local override while preserving byte-identical `PreToolUse` output at all existing call sites via the default argument. Implementation rewires BOTH output branches to use `%s` for `hookEventName` (not a literal `"PreToolUse"`).
6. **Library uses `return 2`, not `exit 2`** — because sourced library functions must not terminate the hook unilaterally; enforcement hooks handle with `|| { _json_error "..."; exit 2; }`, informing hooks emit graceful fallback `additionalContext`.
7. **Pre-refactor golden capture from v8.0.0 git tag** — because capturing goldens from post-refactor output would create a vacuous regression firewall; baselines must precede the change.
8. **Golden matrix split** (real Claude/Cursor vs. contract-spec Copilot) — because no Copilot CLI in CI means Copilot goldens are hypothetical; honest separation prevents regression-firewall theatre for the Copilot path.
9. **v8.1.0 bundles Copilot enablement + library hardening** (json_get consolidation) — because the B2 fail-loud fix requires consolidated error handling upstream; CHANGELOG documents combined scope; MINOR bump stands because `json_get` preserves backward-compatible default-empty-on-missing semantics when `stn_require_json_tool` is satisfied.

## Decision Rationale

### Decision Matrix

| Criterion | Weight | A1: Inline Branches | A2: Shared Library | A3: Translation Shim |
|---|---|---|---|---|
| Complexity | 18% | 3/5 — up to 24 branch points across 6 hooks × 4 helpers | 3/5 — single library refactor + 6 callers; handles both PreToolUse and SessionStart shapes | 4/5 — one shim file, zero edits to existing hooks |
| Time-to-ship | 13% | 3/5 — mechanical but repetitive edits | 3/5 — library design + call-site migration + golden scaffold is front-loaded | 4/5 — one shim, fastest first demo |
| Risk | 18% | 2/5 — drift across copy-pasted branches is near-certain | 4/5 — bounded by goldens + adversarial spoof + atomic commits | 2/5 — creates second source of truth; silent divergence when hook JSON shape changes |
| Extensibility | 13% | 2/5 — platform #4 means re-editing all 6 hooks | 5/5 — platform #4 is one branch in one file | 3/5 — each new platform = another shim, matrix grows |
| Alignment | 13% | 4/5 — extends `stn-init:110-116` pattern | 4/5 — extends existing `source stn-hook-output` convention | 2/5 — new architectural layer, asymmetric to `.claude-plugin/`/`.cursor-plugin/` |
| Maintainability | 13% | 2/5 — drift near-certain in 6–12 months | 4/5 — one place to fix bugs, higher bus factor | 3/5 — shim becomes second file to cross-reference for Copilot debugging |
| Modernity | 12% | 3/5 — entrenches legacy copy-paste | 5/5 — library extraction + adversarial evals is current best practice | 3/5 — shim pattern, but avoids modernizing the hook layer itself |
| **Weighted Total** | **100%** | **53.8/100** | **78.8/100** | **60.0/100** |

### Why Shared Library Over Alternatives

Approach 2 wins every forward-looking criterion (Extensibility 5/5, Modernity 5/5, Maintainability 4/5) by 18.8 points over Approach 3 and 25 over Approach 1. Risk is tamed from a 5/5 default to 4/5 by the explicit protection mechanisms: golden snapshots captured before the refactor, an adversarial env-var spoofing eval, 6 atomic commits with `eval-behavior.sh` green gate after each, and a zero-delta output guarantee on Claude/Cursor. Approach 3's "zero architectural risk" framing is misleading — it buys same-platform safety at the cost of a second source of truth for hook semantics, a worse long-term position than a well-tested library refactor. Approach 1's appeal is familiarity bias; honest scoring shows drift risk is near-certain.

## Alternatives Considered

### Approach 1: Inline Platform Branches

- **Summary:** Extend the existing `stn-init:110-116` pattern into all 6 hooks with `case "$(stn_detect_platform)" in` blocks at each output emission site.
- **Rejected because:** 4 output helpers × 6 hooks = up to 24 branch points; multi-platform logic inline makes drift near-certain in 6–12 months; fixing a bug in one branch forgets the others; adding a future platform requires re-editing all 6 hooks. Wins only on alignment with the current (limited) pattern.

### Approach 3: Translation Shim at the Boundary

- **Summary:** A single `.copilot-plugin/stn-copilot-shim` translates Copilot↔Claude JSON; the 6 existing hooks stay literally untouched.
- **Rejected because:** creates a second source of truth — the shim's rewrite rules must stay in lockstep with hook output, and when a hook author changes JSON shape the shim silently diverges until a Copilot user reports a bug. Also conflicts with A10 (honest gap documentation): the shim abstracts away exactly the parity gaps we must document. Per-hook exec overhead adds latency. Wins on isolation of Copilot-specific logic but not worth the contract-surface cost.

### Modernization-Disqualified Patterns

- `exit 2` from a sourced library function — legacy bash antipattern; use `return 2` and let callers decide.
- Keeping 17 duplicate `jq || python3 || echo` fallbacks — legacy pattern carrier; consolidate into `json_get`.
- Env-var-only platform detection without negative assertion — spoofable bypass (malicious `COPILOT_CLI=1` inside a Claude session could flip enforcement hooks).

## Risk Register

| # | Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|---|
| R1 | Refactor silently changes Claude/Cursor output (whitespace, key order, trailing newline) | M | H | Capture goldens from the v8.0.0 tag BEFORE refactor (`git checkout v8.0.0 && evals/capture-goldens.sh && git checkout -`); `evals/eval-00-golden-diff.sh` runs first in alphabetical order; diff fails the build on any byte mismatch |
| R2 | Platform detection spoofable (`COPILOT_CLI=1 CLAUDE_PLUGIN_ROOT=/tmp/x` simultaneously) | L | H | `stn_detect_platform` uses positive + negative assertion: Claude requires `CLAUDE_PLUGIN_ROOT` set AND `STN_PLATFORM != copilot`; `evals/eval-platform-isolation.sh` exports spoofed env combinations and asserts hooks emit Claude/Cursor output; `unknown` platform triggers fail-closed on enforcement hooks |
| R3 | `_deny` signature change breaks `stn-session-lock` SessionStart deny path | M | M | `_deny` threads event-name through BOTH emission branches (`hookEventName` uses `%s`, not literal `"PreToolUse"`); `evals/eval-session-lock-deny.sh` asserts `"hookEventName":"SessionStart"` in session-lock stdout when lock held; golden-diff covers it too |
| R4 | Copilot sessionStart `additionalContext` silently dropped (A3 unverified, analogous to #2585) | M | M | Design degrades gracefully: primary discovery via skill auto-activation by description (A2 confirmed). Docs explicitly state "Copilot sessionStart context injection is best-effort". `eval-copilot-smoke.sh` verifies if `COPILOT_CLI` env present |
| R5 | Missing jq AND python3 on bare Git Bash — silent empty returns | L | H | `stn_require_json_tool()` at library init uses `command -v`; returns 2 when both absent. Enforcement hooks: `|| { _json_error "requires jq or python3"; exit 2; }`. Informing hooks emit graceful fallback additionalContext with install hint. Eval: `PATH=/nonexistent bash hooks/stn-init` |
| R6 | Wrapper pattern breaks under POSIX sh (`BASH_SOURCE` undefined) | L | M | Wrappers use `$0` (POSIX-compatible) + defensive `[ -n "$BASH_VERSION" ] \|\| exec bash "$0" "$@"` shebang check; `evals/eval-shell-compat.sh`: `sh .copilot-plugin/hooks/<wrapper>` exits 0 |
| R7 | Copilot goldens hypothetical (no Copilot CLI in CI) — regression firewall is theatre | H | M | Split golden matrix: claude/cursor → `evals/golden/{claude,cursor}/` (real, enforced). Copilot → `evals/copilot-contract/` (intent-spec, not authoritative). `eval-copilot-smoke.sh` requires `COPILOT_CLI` env var (explicit opt-in); docs state "Copilot regressions can ship if `COPILOT_CLI` not in test env" |
| R8 | Scope creep — library `json_get` consolidation bundled with Copilot enablement | M | L | CHANGELOG explicitly frames v8.1.0 as "Copilot enablement + library hardening" (single coherent delivery); `json_get` preserves backward-compat (default empty-on-miss when tool check passes); MINOR bump stands. Refactor is in scope because B2 fail-loud resolution requires it |
| R9 | 6 skills use AskUserQuestion (not 2) — docs undercount user-visible impact | L | M | `docs/copilot-cli.md` enumerates all 6 (build-feature:3, brainstorming:9, codebase-audit:5, plan-execution:7, plan-writing:9, codebase-quality-bootstrap:2) with line counts and fallback contract; `evals/eval-copilot-skills-count.sh` asserts documented count == grep count |
| R10 | Mid-pipeline session resume on Copilot loses state reminder | M | L | Documented as known limitation in `docs/copilot-cli.md`. Skills' existing "Session Resumption Protocol" still reads state file when activated. Non-stn first prompt = no reminder (documented). Not a silent failure — explicit limitation |

## Adversarial Review Findings

### Warnings (address during implementation)

- **W1**: `stn_emit_context(event_name, context)` — event_name required, not optional.
- **W2**: Golden coverage = 25 scenarios × 2 platforms (real) + 25 × 1 (Copilot contract-spec) = 75 total outputs. Per-hook scenarios enumerated: prompt-router 4, state-validator 6, skill-gate 5, circuit-breaker 4, init 3, session-lock 3.
- **W3**: Library safe to source lazily; `stn_require_json_tool` caches result in `_STN_JSON_TOOL_OK` global; eval `time bash hooks/stn-prompt-router < /dev/null ≤ 5ms` median across 10 runs.
- **W4**: Consolidate 17 `jq || python3 || echo` fallbacks into a single `json_get` library function — same commit set as library extension.
- **W5**: Thin wrappers in `.copilot-plugin/hooks/` deterministically self-locate via `$0`; 6 wrappers total (one per hook); defensive shebang check `[ -n "$BASH_VERSION" ] || exec bash "$0" "$@"`.
- **W6**: Wrapper uses `$0` not `BASH_SOURCE[0]` for POSIX sh compatibility.
- **W7**: `stn_require_json_tool` caches result after first check (one `command -v` fork per session, not per invocation).
- **W8**: v8.1.0 bundled scope documented in CHANGELOG as "Copilot enablement + library hardening"; MINOR bump justified because backward-compat semantics preserved.
- **W9**: `stn_require_json_tool` uses `return 2`, not `exit 2` — callers decide; informing hooks emit graceful fallback additionalContext with install hint.
- **W10**: Copilot goldens marked contract-spec; `eval-copilot-smoke.sh` requires `COPILOT_CLI` env var for end-to-end verification.

### Notes (awareness items)

- **N1**: `eval-00-golden-diff.sh` runs first alphabetically — prefix ensures ordering in the `evals/eval-*.sh` glob.
- **N2**: 6 skills affected by AskUserQuestion — documented with line counts per skill.
- **N3**: `_deny` signature is backward-compatible via optional third param — existing call sites (5 hooks) unchanged.
- **N4**: Positional empty-arg pattern `_deny "reason" "" "SessionStart"` — OK for now; future `getopts` refactor logged.
- **N5**: Library mixes `stn_*` prefix (new public API) and `_X` prefix (legacy helpers) — documented in the library header as intentional.
- **N6**: v8.1.0 adds a third `plugin.json` (`.copilot-plugin/plugin.json`) in addition to existing `.claude-plugin/plugin.json` and `.cursor-plugin/plugin.json`.

## Acceptance Criteria

| # | Criterion | Verification Method |
|---|---|---|
| AC-1 | `.copilot-plugin/plugin.json` exists and conforms to Copilot schema | `jq -e '.name and .version and .description and .skills' .copilot-plugin/plugin.json` exits 0; version equals `8.1.0` |
| AC-2 | `.copilot-plugin/hooks-copilot.json` uses Copilot schema | `jq -e '.hooks.sessionStart and .hooks.preToolUse' .copilot-plugin/hooks-copilot.json` exits 0; `! grep -E '"command":\|"timeout":' .copilot-plugin/hooks-copilot.json` exits 0 |
| AC-3 | 6 thin wrapper scripts in `.copilot-plugin/hooks/` | `[ -x .copilot-plugin/hooks/{stn-init,stn-session-lock,stn-prompt-router,stn-skill-gate,stn-state-validator,stn-circuit-breaker} ]` all pass; each contains `STN_PLATFORM=copilot` export |
| AC-4 | Wrappers work under POSIX sh | `evals/eval-shell-compat.sh`: `sh .copilot-plugin/hooks/stn-init < /dev/null` exits 0 with valid JSON on stdout |
| AC-5 | Library extended with 8+ new functions | `grep -E '^(stn_detect_platform\|stn_emit_context\|stn_emit_permission_decision\|stn_should_skip_tool\|stn_require_json_tool\|json_get)' hooks/stn-hook-output \| wc -l` ≥ 6 |
| AC-6 | Platform detection uses positive + negative assertion | `evals/eval-platform-isolation.sh`: `COPILOT_CLI=1 CLAUDE_PLUGIN_ROOT=/tmp/x bash hooks/stn-init` emits Claude-wrapped JSON (not Copilot format) |
| AC-7 | Golden-output regression firewall | `evals/eval-00-golden-diff.sh` diffs current output vs. `evals/golden/v8.0.0/` baseline for all 6 hooks × 25 scenarios × 2 platforms (Claude + Cursor); zero byte delta required |
| AC-8 | Copilot contract-spec goldens | `evals/golden/copilot-contract/` contains 25 expected Copilot outputs; `evals/eval-copilot-contract.sh` asserts library emits these under `STN_PLATFORM=copilot` |
| AC-9 | Copilot smoke test (opt-in) | `evals/eval-copilot-smoke.sh` — if `COPILOT_CLI` env present, runs end-to-end Copilot hook invocation; skipped otherwise with explicit notice |
| AC-10 | Kill-switch parity | `STN_SKILLS_HOOKS_DISABLE=1 bash hooks/stn-init` exits 0 silently on all 3 platforms (existing eval extended with Copilot env) |
| AC-11 | `stn-session-lock` SessionStart deny path | `evals/eval-session-lock-deny.sh` — with active lock, stdout contains `"hookEventName":"SessionStart"` exactly |
| AC-12 | Missing json tools = fail-loud | `evals/eval-tool-requirement.sh`: `PATH=/nonexistent bash hooks/stn-skill-gate` (enforcement) exits 2 with stderr "stn-skills: requires jq or python3"; `PATH=/nonexistent bash hooks/stn-init` (informing) emits graceful additionalContext with install hint |
| AC-13 | Lazy source performance | `evals/eval-lazy-source-timing.sh`: `time bash hooks/stn-prompt-router < /dev/null` ≤ 5ms median across 10 runs |
| AC-14 | 6 skills AskUserQuestion count documented | `evals/eval-copilot-skills-count.sh`: `grep -c AskUserQuestion` per skill matches counts in `docs/copilot-cli.md` Known Limitations section |
| AC-15 | `docs/copilot-cli.md` contains 6 named limitations | `docs/copilot-cli.md` has sections for: no Skill tool, `userPromptSubmitted` output ignored, `sessionStart` best-effort, 6 skills AskUserQuestion, Windows WSL/Git Bash, no Copilot CLI in CI |
| AC-16 | Full eval suite green | `./evals/eval-runner.sh` exits 0 |
| AC-17 | Version sync across all manifests | `.claude-plugin/plugin.json`, `.cursor-plugin/plugin.json`, `.copilot-plugin/plugin.json`, README badge all contain `8.1.0`; CHANGELOG has `[8.1.0] - 2026-04-21` entry |
| AC-18 | README claim verifiable | README's "Claude Code, Cursor, and Copilot CLI" claim resolves to: Claude=`.claude-plugin/`, Cursor=`.cursor-plugin/`, Copilot=`.copilot-plugin/` — all three directories exist with `plugin.json` |
| AC-19 | No overclaiming | `docs/copilot-cli.md` "Known Limitations" section covers every capability gap mentioned in R4–R10; grep assertion against enumerated limitations |
| AC-20 | Claude/Cursor behavior unchanged | Existing `evals/eval-behavior.sh` (67 tests) passes without modification to the test file |

## Open Questions

None — all questions resolved during brainstorming.

---
<!-- Generated by stn-skills:brainstorming | 2026-04-21 -->
