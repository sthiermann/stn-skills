#!/usr/bin/env bash
# eval-behavior.sh — Behavioral tests for stn-skills v5.0.0 hooks
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
  if echo "$actual" | grep -q "$expected"; then
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
check "B-03: skill-gate no state = allow" '"decision":"allow"' "$result"

# B-04: skill-gate allows non-stn-skills
result=$(echo '{"tool_name":"Skill","tool_input":{"skill":"other-skill:something"}}' | bash "${HOOKS_DIR}/stn-skill-gate" 2>&1)
check "B-04: skill-gate non-stn = allow" '"decision":"allow"' "$result"

# B-05: skill-gate blocks when handoff not validated
cat > "${TMPDIR_FIX}/.claude/stn-skills-pipeline-state.json" <<'FIXTURE'
{"pipeline_id":"test","active_skill":"brainstorming","current_phase":6,"total_phases":6,"gates_passed":[1,2,3,4],"artifact_path":"test.md","handoff_validated":false,"updated_at":"2026-01-01T00:00:00Z"}
FIXTURE
result=$(cd "$TMPDIR_FIX" && echo '{"tool_name":"Skill","tool_input":{"skill":"stn-skills:plan-writing"}}' | bash "${HOOKS_DIR}/stn-skill-gate" 2>&1)
check "B-05: skill-gate blocks unvalidated handoff" '"decision":"block"' "$result"

# B-06: skill-gate allows when handoff validated
cat > "${TMPDIR_FIX}/.claude/stn-skills-pipeline-state.json" <<'FIXTURE'
{"pipeline_id":"test","active_skill":"brainstorming","current_phase":6,"total_phases":6,"gates_passed":[1,2,3,4],"artifact_path":"test.md","handoff_validated":true,"updated_at":"2026-01-01T00:00:00Z"}
FIXTURE
result=$(cd "$TMPDIR_FIX" && echo '{"tool_name":"Skill","tool_input":{"skill":"stn-skills:plan-writing"}}' | bash "${HOOKS_DIR}/stn-skill-gate" 2>&1)
check "B-06: skill-gate allows validated handoff" '"decision":"allow"' "$result"

# B-07: skill-gate kill-switch
result=$(echo '{"tool_name":"Skill","tool_input":{"skill":"stn-skills:plan-writing"}}' | STN_SKILLS_HOOKS_DISABLE=1 bash "${HOOKS_DIR}/stn-skill-gate" 2>&1)
check "B-07: skill-gate kill-switch" '"decision":"allow"' "$result"

# ========================================
# T03: stn-state-validator
# ========================================

# B-08: state-validator allows non-state writes
result=$(echo '{"tool_name":"Write","tool_input":{"file_path":"src/index.ts","content":"hello"}}' | bash "${HOOKS_DIR}/stn-state-validator" 2>&1)
check "B-08: state-validator non-state = allow" '"decision":"allow"' "$result"

# B-09: state-validator blocks malformed JSON
result=$(echo '{"tool_name":"Write","tool_input":{"file_path":".claude/stn-skills-pipeline-state.json","content":"not json"}}' | bash "${HOOKS_DIR}/stn-state-validator" 2>&1)
check "B-09: state-validator blocks bad JSON" '"decision":"block"' "$result"

# B-10: state-validator allows valid JSON
result=$(echo '{"tool_name":"Write","tool_input":{"file_path":".claude/stn-skills-pipeline-state.json","content":"{\"pipeline_id\":\"t\",\"active_skill\":\"brainstorming\",\"current_phase\":1,\"total_phases\":6,\"gates_passed\":[],\"updated_at\":\"2026-01-01T00:00:00Z\"}"}}' | bash "${HOOKS_DIR}/stn-state-validator" 2>&1)
check "B-10: state-validator allows valid state" '"decision":"allow"' "$result"

# B-11: state-validator blocks missing required fields
result=$(echo '{"tool_name":"Write","tool_input":{"file_path":".claude/stn-skills-pipeline-state.json","content":"{\"pipeline_id\":\"t\"}"}}' | bash "${HOOKS_DIR}/stn-state-validator" 2>&1)
check "B-11: state-validator blocks missing fields" '"decision":"block"' "$result"

# B-12: state-validator kill-switch
result=$(echo '{"tool_name":"Write","tool_input":{"file_path":".claude/stn-skills-pipeline-state.json","content":"bad"}}' | STN_SKILLS_HOOKS_DISABLE=1 bash "${HOOKS_DIR}/stn-state-validator" 2>&1)
check "B-12: state-validator kill-switch" '"decision":"allow"' "$result"

# ========================================
# T05: stn-circuit-breaker
# ========================================

# B-13: circuit-breaker allows when no state
result=$(cd "$TMPDIR_FIX" && rm -f .claude/plan-execution-state.json && echo '{"tool_name":"Edit","tool_input":{}}' | bash "${HOOKS_DIR}/stn-circuit-breaker" 2>&1)
check "B-13: circuit-breaker no state = allow" '"decision":"allow"' "$result"

# B-14: circuit-breaker blocks at RED
cat > "${TMPDIR_FIX}/.claude/plan-execution-state.json" <<'FIXTURE'
{"plan_id":"test","starting_sha":"abc","current_task":3,"total_tasks":5,"checkpoints":[],"circuit_breaker":{"state":"RED","consecutive_review_failures":4,"total_review_failures":6,"consecutive_blocked":0,"major_drift_count":0}}
FIXTURE
result=$(cd "$TMPDIR_FIX" && echo '{"tool_name":"Edit","tool_input":{}}' | bash "${HOOKS_DIR}/stn-circuit-breaker" 2>&1)
check "B-14: circuit-breaker blocks at RED" '"decision":"block"' "$result"

# B-15: circuit-breaker allows at GREEN
cat > "${TMPDIR_FIX}/.claude/plan-execution-state.json" <<'FIXTURE'
{"plan_id":"test","starting_sha":"abc","current_task":1,"total_tasks":5,"checkpoints":[],"circuit_breaker":{"state":"GREEN","consecutive_review_failures":0,"total_review_failures":0,"consecutive_blocked":0,"major_drift_count":0}}
FIXTURE
result=$(cd "$TMPDIR_FIX" && echo '{"tool_name":"Edit","tool_input":{}}' | bash "${HOOKS_DIR}/stn-circuit-breaker" 2>&1)
check "B-15: circuit-breaker allows at GREEN" '"decision":"allow"' "$result"

# B-16: circuit-breaker kill-switch
result=$(echo '{"tool_name":"Edit","tool_input":{}}' | STN_SKILLS_HOOKS_DISABLE=1 bash "${HOOKS_DIR}/stn-circuit-breaker" 2>&1)
check "B-16: circuit-breaker kill-switch" '"decision":"allow"' "$result"

# ========================================
# T06: stn-scope-guard
# ========================================

# B-17: scope-guard allows when no scope file
result=$(cd "$TMPDIR_FIX" && rm -f .claude/current-task-scope.json && echo '{"tool_name":"Write","tool_input":{"file_path":"any/file.ts"}}' | bash "${HOOKS_DIR}/stn-scope-guard" 2>&1)
check "B-17: scope-guard no scope = allow" '"decision":"allow"' "$result"

# B-18: scope-guard blocks out-of-scope
cat > "${TMPDIR_FIX}/.claude/current-task-scope.json" <<'FIXTURE'
{"task_id":"T1","allowed_files":["src/auth.ts","src/router.ts"]}
FIXTURE
result=$(cd "$TMPDIR_FIX" && echo '{"tool_name":"Write","tool_input":{"file_path":"src/database.ts"}}' | bash "${HOOKS_DIR}/stn-scope-guard" 2>&1)
check "B-18: scope-guard blocks out-of-scope" '"decision":"block"' "$result"

# B-19: scope-guard allows in-scope
result=$(cd "$TMPDIR_FIX" && echo '{"tool_name":"Write","tool_input":{"file_path":"src/auth.ts"}}' | bash "${HOOKS_DIR}/stn-scope-guard" 2>&1)
check "B-19: scope-guard allows in-scope" '"decision":"allow"' "$result"

# B-20: scope-guard always allows .claude/ writes
result=$(cd "$TMPDIR_FIX" && echo '{"tool_name":"Write","tool_input":{"file_path":".claude/state.json"}}' | bash "${HOOKS_DIR}/stn-scope-guard" 2>&1)
check "B-20: scope-guard allows .claude/" '"decision":"allow"' "$result"

# B-21: scope-guard kill-switch
result=$(echo '{"tool_name":"Write","tool_input":{"file_path":"blocked.ts"}}' | STN_SKILLS_HOOKS_DISABLE=1 bash "${HOOKS_DIR}/stn-scope-guard" 2>&1)
check "B-21: scope-guard kill-switch" '"decision":"allow"' "$result"

# ========================================
# R8: Security — no shell expansion
# ========================================

# B-22: No eval or unquoted $() in hook scripts
EXPANSION_COUNT=0
for hook in stn-skill-gate stn-state-validator stn-session-lock stn-circuit-breaker stn-scope-guard; do
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
