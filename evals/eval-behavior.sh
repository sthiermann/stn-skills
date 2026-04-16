#!/usr/bin/env bash
# eval-behavior.sh — Behavioral tests for stn-skills hooks
# Tests hook scripts with fixture data. No LLM calls needed.
# Part of the stn-skills eval suite.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
HOOKS_DIR="${REPO_ROOT}/hooks"
PASS_COUNT=0
FAIL_COUNT=0

pass() { echo "PASS: $1"; PASS_COUNT=$((PASS_COUNT + 1)); }
fail() { echo "FAIL: $1"; FAIL_COUNT=$((FAIL_COUNT + 1)); }

check() {
  local desc="$1" expected="$2" actual="$3"
  if echo "$actual" | grep -qF "$expected"; then
    pass "$desc"
  else
    fail "$desc (expected '$expected', got '$actual')"
  fi
}

# --- Setup temp dir for state fixtures ---
TMPDIR_FIX="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_FIX"' EXIT
mkdir -p "${TMPDIR_FIX}/.claude"

# ========================================
# T01: stn-init
# ========================================

# B-01: Kill-switch bypasses stn-init
result=$(echo '{}' | STN_SKILLS_HOOKS_DISABLE=1 bash "${HOOKS_DIR}/stn-init" 2>&1 || true)
[[ -z "$result" ]] && pass "B-01: stn-init kill-switch" || fail "B-01: stn-init kill-switch (output: $result)"

# B-02: stn-init handles missing state gracefully
result=$(bash "${HOOKS_DIR}/stn-init" < /dev/null 2>&1; echo "exit:$?")
check "B-02: stn-init missing state" "exit:0" "$result"

# ========================================
# T02: stn-skill-gate
# ========================================

# B-03: skill-gate allows when no state file
result=$(echo '{"tool_name":"Skill","tool_input":{"skill":"stn-skills:plan-writing"}}' | bash "${HOOKS_DIR}/stn-skill-gate" 2>&1)
check "B-03: skill-gate no state = allow" '"permissionDecision":"allow"' "$result"

# B-04: skill-gate allows non-stn-skills
result=$(echo '{"tool_name":"Skill","tool_input":{"skill":"other-skill:something"}}' | bash "${HOOKS_DIR}/stn-skill-gate" 2>&1)
check "B-04: skill-gate non-stn = allow" '"permissionDecision":"allow"' "$result"

# B-05: skill-gate blocks when handoff not validated
cat > "${TMPDIR_FIX}/.claude/stn-skills-pipeline-state.json" <<'FIXTURE'
{"pipeline_id":"test","active_skill":"brainstorming","current_phase":6,"total_phases":6,"gates_passed":[1,2,3,4],"artifact_path":"test.md","handoff_validated":false,"updated_at":"2026-01-01T00:00:00Z"}
FIXTURE
result=$(cd "$TMPDIR_FIX" && echo '{"tool_name":"Skill","tool_input":{"skill":"stn-skills:plan-writing"}}' | bash "${HOOKS_DIR}/stn-skill-gate" 2>&1)
check "B-05: skill-gate blocks unvalidated handoff" '"permissionDecision":"deny"' "$result"

# B-06: skill-gate allows when handoff validated
cat > "${TMPDIR_FIX}/.claude/stn-skills-pipeline-state.json" <<'FIXTURE'
{"pipeline_id":"test","active_skill":"brainstorming","current_phase":6,"total_phases":6,"gates_passed":[1,2,3,4],"artifact_path":"test.md","handoff_validated":true,"updated_at":"2026-01-01T00:00:00Z"}
FIXTURE
result=$(cd "$TMPDIR_FIX" && echo '{"tool_name":"Skill","tool_input":{"skill":"stn-skills:plan-writing"}}' | bash "${HOOKS_DIR}/stn-skill-gate" 2>&1)
check "B-06: skill-gate allows validated handoff" '"permissionDecision":"allow"' "$result"

# B-07: skill-gate kill-switch
result=$(echo '{"tool_name":"Skill","tool_input":{"skill":"stn-skills:plan-writing"}}' | STN_SKILLS_HOOKS_DISABLE=1 bash "${HOOKS_DIR}/stn-skill-gate" 2>&1)
check "B-07: skill-gate kill-switch" '"permissionDecision":"allow"' "$result"

# B-32: skill-gate blocks plan-writing→plan-execution unvalidated
cat > "${TMPDIR_FIX}/.claude/stn-skills-pipeline-state.json" <<'FIXTURE'
{"pipeline_id":"test","active_skill":"plan-writing","current_phase":6,"total_phases":6,"gates_passed":[1,2,3,4],"artifact_path":"test.md","handoff_validated":false,"updated_at":"2026-01-01T00:00:00Z"}
FIXTURE
result=$(cd "$TMPDIR_FIX" && echo '{"tool_name":"Skill","tool_input":{"skill":"stn-skills:plan-execution"}}' | bash "${HOOKS_DIR}/stn-skill-gate" 2>&1)
check "B-32: skill-gate blocks plan→exec unvalidated" '"permissionDecision":"deny"' "$result"

# B-33: skill-gate allows plan-writing→plan-execution validated
cat > "${TMPDIR_FIX}/.claude/stn-skills-pipeline-state.json" <<'FIXTURE'
{"pipeline_id":"test","active_skill":"plan-writing","current_phase":6,"total_phases":6,"gates_passed":[1,2,3,4],"artifact_path":"test.md","handoff_validated":true,"updated_at":"2026-01-01T00:00:00Z"}
FIXTURE
result=$(cd "$TMPDIR_FIX" && echo '{"tool_name":"Skill","tool_input":{"skill":"stn-skills:plan-execution"}}' | bash "${HOOKS_DIR}/stn-skill-gate" 2>&1)
check "B-33: skill-gate allows plan→exec validated" '"permissionDecision":"allow"' "$result"

# B-34: skill-gate allows non-chain skill (codebase-audit)
result=$(cd "$TMPDIR_FIX" && echo '{"tool_name":"Skill","tool_input":{"skill":"stn-skills:codebase-audit"}}' | bash "${HOOKS_DIR}/stn-skill-gate" 2>&1)
check "B-34: skill-gate allows non-chain skill" '"permissionDecision":"allow"' "$result"

# B-35: skill-gate allows non-Skill tool
result=$(echo '{"tool_name":"Edit","tool_input":{}}' | bash "${HOOKS_DIR}/stn-skill-gate" 2>&1)
check "B-35: skill-gate ignores non-Skill tool" '"permissionDecision":"allow"' "$result"
rm -f "${TMPDIR_FIX}/.claude/stn-skills-pipeline-state.json"

# ========================================
# T03: stn-state-validator
# ========================================

# B-08: state-validator allows non-state writes
result=$(echo '{"tool_name":"Write","tool_input":{"file_path":"src/index.ts","content":"hello"}}' | bash "${HOOKS_DIR}/stn-state-validator" 2>&1)
check "B-08: state-validator non-state = allow" '"permissionDecision":"allow"' "$result"

# B-09: state-validator blocks malformed JSON
result=$(echo '{"tool_name":"Write","tool_input":{"file_path":".claude/stn-skills-pipeline-state.json","content":"not json"}}' | bash "${HOOKS_DIR}/stn-state-validator" 2>&1)
check "B-09: state-validator blocks bad JSON" '"permissionDecision":"deny"' "$result"

# B-10: state-validator allows valid JSON
result=$(echo '{"tool_name":"Write","tool_input":{"file_path":".claude/stn-skills-pipeline-state.json","content":"{\"pipeline_id\":\"t\",\"active_skill\":\"brainstorming\",\"current_phase\":1,\"total_phases\":6,\"gates_passed\":[],\"updated_at\":\"2026-01-01T00:00:00Z\"}"}}' | bash "${HOOKS_DIR}/stn-state-validator" 2>&1)
check "B-10: state-validator allows valid state" '"permissionDecision":"allow"' "$result"

# B-11: state-validator blocks missing required fields
result=$(echo '{"tool_name":"Write","tool_input":{"file_path":".claude/stn-skills-pipeline-state.json","content":"{\"pipeline_id\":\"t\"}"}}' | bash "${HOOKS_DIR}/stn-state-validator" 2>&1)
check "B-11: state-validator blocks missing fields" '"permissionDecision":"deny"' "$result"

# B-12: state-validator kill-switch
result=$(echo '{"tool_name":"Write","tool_input":{"file_path":".claude/stn-skills-pipeline-state.json","content":"bad"}}' | STN_SKILLS_HOOKS_DISABLE=1 bash "${HOOKS_DIR}/stn-state-validator" 2>&1)
check "B-12: state-validator kill-switch" '"permissionDecision":"allow"' "$result"

# B-36: state-validator allows plan-execution-state writes (no field validation)
result=$(echo '{"tool_name":"Write","tool_input":{"file_path":".claude/plan-execution-state.json","content":"{\"plan_id\":\"t\"}"}}' | bash "${HOOKS_DIR}/stn-state-validator" 2>&1)
check "B-36: state-validator allows exec-state partial" '"permissionDecision":"allow"' "$result"

# B-37: state-validator blocks empty content
result=$(echo '{"tool_name":"Write","tool_input":{"file_path":".claude/stn-skills-pipeline-state.json","content":""}}' | bash "${HOOKS_DIR}/stn-state-validator" 2>&1)
check "B-37: state-validator blocks empty content" '"permissionDecision":"deny"' "$result"

# B-38: state-validator allows valid JSON with extra fields
result=$(echo '{"tool_name":"Write","tool_input":{"file_path":".claude/stn-skills-pipeline-state.json","content":"{\"pipeline_id\":\"t\",\"active_skill\":\"brainstorming\",\"current_phase\":1,\"total_phases\":6,\"gates_passed\":[],\"updated_at\":\"2026-01-01T00:00:00Z\",\"extra\":true}"}}' | bash "${HOOKS_DIR}/stn-state-validator" 2>&1)
check "B-38: state-validator allows extra fields" '"permissionDecision":"allow"' "$result"

# ========================================
# T04: stn-session-lock
# ========================================

# B-39: session-lock kill-switch
result=$(STN_SKILLS_HOOKS_DISABLE=1 bash "${HOOKS_DIR}/stn-session-lock" 2>&1; echo "exit:$?")
check "B-39: session-lock kill-switch" "exit:0" "$result"

# B-40: session-lock creates lock in temp dir
LOCK_TEST="$(mktemp -d)"
mkdir -p "${LOCK_TEST}/.claude"
(cd "$LOCK_TEST" && bash "${HOOKS_DIR}/stn-session-lock" 2>&1) || true
[[ -d "${LOCK_TEST}/.claude/stn-skills.lock" ]] && pass "B-40: session-lock creates lock dir" || fail "B-40: session-lock creates lock dir"
rm -rf "$LOCK_TEST"

# B-41: session-lock validates PID is numeric
LOCK_TEST="$(mktemp -d)"
mkdir -p "${LOCK_TEST}/.claude/stn-skills.lock"
echo "not-a-pid" > "${LOCK_TEST}/.claude/stn-skills.lock/pid"
(cd "$LOCK_TEST" && bash "${HOOKS_DIR}/stn-session-lock" 2>&1) || true
# Non-numeric PID should be treated as stale — lock cleaned and recreated
NEW_PID="$(cat "${LOCK_TEST}/.claude/stn-skills.lock/pid" 2>/dev/null || echo "")"
[[ "$NEW_PID" =~ ^[0-9]+$ ]] && pass "B-41: session-lock replaces non-numeric PID" || fail "B-41: session-lock replaces non-numeric PID (got: $NEW_PID)"
rm -rf "$LOCK_TEST"

# ========================================
# T05: stn-circuit-breaker
# ========================================

# B-13: circuit-breaker allows when no state
result=$(cd "$TMPDIR_FIX" && rm -f .claude/plan-execution-state.json && echo '{"tool_name":"Edit","tool_input":{}}' | bash "${HOOKS_DIR}/stn-circuit-breaker" 2>&1)
check "B-13: circuit-breaker no state = allow" '"permissionDecision":"allow"' "$result"

# B-14: circuit-breaker blocks at RED
cat > "${TMPDIR_FIX}/.claude/plan-execution-state.json" <<'FIXTURE'
{"plan_id":"test","starting_sha":"abc","current_task":3,"total_tasks":5,"checkpoints":[],"circuit_breaker":{"state":"RED","consecutive_review_failures":4,"total_review_failures":6,"consecutive_blocked":0,"major_drift_count":0}}
FIXTURE
result=$(cd "$TMPDIR_FIX" && echo '{"tool_name":"Edit","tool_input":{}}' | bash "${HOOKS_DIR}/stn-circuit-breaker" 2>&1)
check "B-14: circuit-breaker blocks at RED" '"permissionDecision":"deny"' "$result"

# B-15: circuit-breaker allows at GREEN
cat > "${TMPDIR_FIX}/.claude/plan-execution-state.json" <<'FIXTURE'
{"plan_id":"test","starting_sha":"abc","current_task":1,"total_tasks":5,"checkpoints":[],"circuit_breaker":{"state":"GREEN","consecutive_review_failures":0,"total_review_failures":0,"consecutive_blocked":0,"major_drift_count":0}}
FIXTURE
result=$(cd "$TMPDIR_FIX" && echo '{"tool_name":"Edit","tool_input":{}}' | bash "${HOOKS_DIR}/stn-circuit-breaker" 2>&1)
check "B-15: circuit-breaker allows at GREEN" '"permissionDecision":"allow"' "$result"

# B-16: circuit-breaker kill-switch
result=$(echo '{"tool_name":"Edit","tool_input":{}}' | STN_SKILLS_HOOKS_DISABLE=1 bash "${HOOKS_DIR}/stn-circuit-breaker" 2>&1)
check "B-16: circuit-breaker kill-switch" '"permissionDecision":"allow"' "$result"

# B-42: circuit-breaker gates Agent tool
cat > "${TMPDIR_FIX}/.claude/plan-execution-state.json" <<'FIXTURE'
{"plan_id":"test","starting_sha":"abc","current_task":3,"total_tasks":5,"checkpoints":[],"circuit_breaker":{"state":"RED","consecutive_review_failures":4,"total_review_failures":6,"consecutive_blocked":0,"major_drift_count":0}}
FIXTURE
result=$(cd "$TMPDIR_FIX" && echo '{"tool_name":"Agent","tool_input":{}}' | bash "${HOOKS_DIR}/stn-circuit-breaker" 2>&1)
check "B-42: circuit-breaker blocks Agent at RED" '"permissionDecision":"deny"' "$result"

# B-43: circuit-breaker allows YELLOW
cat > "${TMPDIR_FIX}/.claude/plan-execution-state.json" <<'FIXTURE'
{"plan_id":"test","starting_sha":"abc","current_task":2,"total_tasks":5,"checkpoints":[],"circuit_breaker":{"state":"YELLOW","consecutive_review_failures":2,"total_review_failures":3,"consecutive_blocked":0,"major_drift_count":0}}
FIXTURE
result=$(cd "$TMPDIR_FIX" && echo '{"tool_name":"Edit","tool_input":{}}' | bash "${HOOKS_DIR}/stn-circuit-breaker" 2>&1)
check "B-43: circuit-breaker allows YELLOW" '"permissionDecision":"allow"' "$result"

# B-44: circuit-breaker ignores non-gated tools
result=$(cd "$TMPDIR_FIX" && echo '{"tool_name":"Read","tool_input":{}}' | bash "${HOOKS_DIR}/stn-circuit-breaker" 2>&1)
check "B-44: circuit-breaker ignores Read tool" '"permissionDecision":"allow"' "$result"
rm -f "${TMPDIR_FIX}/.claude/plan-execution-state.json"

# ========================================
# T06: stn-state-validator — path traversal
# ========================================

# B-17: state-validator blocks path traversal
result=$(echo '{"tool_name":"Write","tool_input":{"file_path":"src/../../etc/passwd","content":"x"}}' | bash "${HOOKS_DIR}/stn-state-validator" 2>&1)
check "B-17: state-validator blocks path traversal" '"permissionDecision":"deny"' "$result"

# ========================================
# T09: stn-prompt-router
# ========================================

# B-59: prompt-router silent when no pipeline and no tracker
result=$(cd "$TMPDIR_FIX" && rm -f .claude/stn-skills-pipeline-state.json .claude/stn-edit-tracker.json && echo '{"prompt":"hello"}' | bash "${HOOKS_DIR}/stn-prompt-router" 2>&1; echo "exit:$?")
check "B-59: prompt-router silent when clean" "exit:0" "$result"

# B-60: prompt-router primes when edit tracker at threshold
cat > "${TMPDIR_FIX}/.claude/stn-edit-tracker.json" <<'FIXTURE'
{"files":["a.ts","b.ts","c.ts"]}
FIXTURE
result=$(cd "$TMPDIR_FIX" && echo '{"prompt":"fix the bug"}' | bash "${HOOKS_DIR}/stn-prompt-router" 2>&1)
check "B-60: prompt-router primes at threshold" '"additionalContext"' "$result"
check "B-60b: prompt-router mentions build-feature" 'build-feature' "$result"

# B-61: prompt-router primes when active pipeline
cat > "${TMPDIR_FIX}/.claude/stn-skills-pipeline-state.json" <<'FIXTURE'
{"pipeline_id":"test","active_skill":"brainstorming","current_phase":3,"total_phases":6,"gates_passed":[1],"artifact_path":"test.md","handoff_validated":false,"updated_at":"2026-01-01T00:00:00Z"}
FIXTURE
result=$(cd "$TMPDIR_FIX" && echo '{"prompt":"continue"}' | bash "${HOOKS_DIR}/stn-prompt-router" 2>&1)
check "B-61: prompt-router primes for active pipeline" '"additionalContext"' "$result"
check "B-61b: prompt-router mentions active skill" 'brainstorming' "$result"
rm -f "${TMPDIR_FIX}/.claude/stn-skills-pipeline-state.json"
rm -f "${TMPDIR_FIX}/.claude/stn-edit-tracker.json"

# B-62: prompt-router kill-switch
cat > "${TMPDIR_FIX}/.claude/stn-edit-tracker.json" <<'FIXTURE'
{"files":["a.ts","b.ts","c.ts","d.ts"]}
FIXTURE
result=$(cd "$TMPDIR_FIX" && echo '{"prompt":"test"}' | STN_SKILLS_HOOKS_DISABLE=1 bash "${HOOKS_DIR}/stn-prompt-router" 2>&1; echo "exit:$?")
check "B-62: prompt-router kill-switch" "exit:0" "$result"
rm -f "${TMPDIR_FIX}/.claude/stn-edit-tracker.json"

# ========================================
# T10: JSON escape — control characters
# ========================================

# B-53: _json_escape handles all JSON control characters
result=$(bash -c '
source "'"${HOOKS_DIR}"'/stn-hook-output"
input=$(printf "tab\there cr\rnewline\nbs\x08ff\x0c quote\" slash\\\\")
escaped=$(_json_escape "$input")
printf "{\"test\":\"%s\"}" "$escaped"
' 2>&1)
if echo "$result" | python3 -c "import json,sys; json.load(sys.stdin)" 2>/dev/null; then
  pass "B-53: _json_escape produces valid JSON with all control chars"
else
  fail "B-53: _json_escape produces invalid JSON (output: $result)"
fi

# B-54: state-validator deny with tab in path produces valid JSON
result=$(printf '{"tool_name":"Write","tool_input":{"file_path":"src/../bad\tfile.ts","content":"x"}}' | bash "${HOOKS_DIR}/stn-state-validator" 2>&1)
if echo "$result" | python3 -c "import json,sys; json.load(sys.stdin)" 2>/dev/null; then
  pass "B-54: state-validator deny with tab = valid JSON"
else
  fail "B-54: state-validator deny with tab = invalid JSON (output: $result)"
fi

# B-55: session-lock deny with active PID produces valid JSON
LOCK_TEST="$(mktemp -d)"
mkdir -p "${LOCK_TEST}/.claude/stn-skills.lock"
echo "$$" > "${LOCK_TEST}/.claude/stn-skills.lock/pid"
result=$(cd "$LOCK_TEST" && bash "${HOOKS_DIR}/stn-session-lock" 2>&1)
if echo "$result" | python3 -c "import json,sys; json.load(sys.stdin)" 2>/dev/null; then
  pass "B-55: session-lock deny = valid JSON"
else
  fail "B-55: session-lock deny = invalid JSON (output: $result)"
fi
rm -rf "$LOCK_TEST"

# ========================================
# R8: Security — no shell expansion
# ========================================

# B-22: No eval or unquoted $() in hook scripts
EXPANSION_COUNT=0
for hook in stn-hook-output stn-skill-gate stn-state-validator stn-session-lock stn-circuit-breaker stn-prompt-router; do
  count=$(grep -cE '^\s*eval\s|[^"]\$\(' "${HOOKS_DIR}/${hook}" 2>/dev/null; true)
  count="${count##*:}"  # strip filename prefix from grep -c output
  count="${count:-0}"
  EXPANSION_COUNT=$((EXPANSION_COUNT + count))
done
[[ "$EXPANSION_COUNT" -eq 0 ]] && pass "B-22: No shell expansion in hooks" || fail "B-22: Found $EXPANSION_COUNT shell expansion patterns"

# ========================================
# Summary
# ========================================

echo ""
echo "================================"
echo "Behavioral Eval: ${PASS_COUNT} passed, ${FAIL_COUNT} failed"
echo "================================"

[[ "$FAIL_COUNT" -eq 0 ]] && exit 0 || exit 1
