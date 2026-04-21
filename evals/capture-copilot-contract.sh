#!/usr/bin/env bash
# capture-copilot-contract.sh — generates contract-spec Copilot goldens
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
HOOKS_DIR="${REPO_ROOT}/hooks"
OUT_DIR="${SCRIPT_DIR}/copilot-contract"
TMPDIR_FIX="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_FIX"' EXIT
mkdir -p "${TMPDIR_FIX}/.claude"

STATE_ACTIVE='{"pipeline_id":"golden-test","active_skill":"brainstorming","current_phase":3,"total_phases":6,"gates_passed":[1,2],"artifact_path":"test.md","handoff_validated":false,"updated_at":"2026-04-21T00:00:00Z"}'
STATE_COMPLETED='{"pipeline_id":"golden-test","active_skill":"plan-execution","current_phase":8,"total_phases":7,"gates_passed":[1,2,3],"artifact_path":"test.md","handoff_validated":true,"updated_at":"2026-04-21T00:00:00Z"}'
STATE_BRAINSTORMING_UNVAL='{"pipeline_id":"golden-test","active_skill":"brainstorming","current_phase":6,"total_phases":6,"gates_passed":[1,2,3,4],"artifact_path":"test.md","handoff_validated":false,"updated_at":"2026-04-21T00:00:00Z"}'
STATE_BRAINSTORMING_VAL='{"pipeline_id":"golden-test","active_skill":"brainstorming","current_phase":6,"total_phases":6,"gates_passed":[1,2,3,4],"artifact_path":"test.md","handoff_validated":true,"updated_at":"2026-04-21T00:00:00Z"}'
EDIT_TRACKER='{"files":["a.ts","b.ts","c.ts","d.ts"],"updated_at":"2026-04-21T00:00:00Z"}'
PLAN_EXEC_RED='{"plan_id":"golden","circuit_breaker":{"state":"RED","consecutive_review_failures":4}}'
PLAN_EXEC_GREEN='{"plan_id":"golden","circuit_breaker":{"state":"GREEN","consecutive_review_failures":0}}'

mkdir -p "$OUT_DIR"

capture() {
  local hook="$1" scenario="$2" stdin_json="$3" setup_cmd="${4:-}"
  local scenario_dir="${OUT_DIR}/${hook}"
  mkdir -p "$scenario_dir"
  local out_file="${scenario_dir}/${scenario}.json"
  (
    cd "$TMPDIR_FIX"
    rm -rf .claude/stn-skills-pipeline-state.json .claude/stn-edit-tracker.json .claude/plan-execution-state.json .claude/stn-skills.lock 2>/dev/null || true
    mkdir -p .claude
    [[ -n "$setup_cmd" ]] && eval "$setup_cmd"
    printf '%s' "$stdin_json" | env -i PATH="$PATH" HOME="$HOME" STN_PLATFORM=copilot bash "${HOOKS_DIR}/${hook}" 2>/dev/null > "$out_file" || true
  )
}

# stn-init (3)
capture "stn-init" "no-state" '' ''
capture "stn-init" "active-pipeline" '' "printf '%s' '${STATE_ACTIVE}' > .claude/stn-skills-pipeline-state.json"
capture "stn-init" "stale-state" '' "printf '%s' '${STATE_ACTIVE}' > .claude/stn-skills-pipeline-state.json; touch -t 202403010000 .claude/stn-skills-pipeline-state.json"
# stn-session-lock (3)
capture "stn-session-lock" "no-lock" '' ''
capture "stn-session-lock" "stale-lock" '' 'mkdir -p .claude/stn-skills.lock; echo "999999" > .claude/stn-skills.lock/pid'
capture "stn-session-lock" "active-lock" '' 'mkdir -p .claude/stn-skills.lock; echo "1" > .claude/stn-skills.lock/pid'
# stn-prompt-router (4)
capture "stn-prompt-router" "no-state" '{"prompt":"hello"}' ''
capture "stn-prompt-router" "active-pipeline" '{"prompt":"hello"}' "printf '%s' '${STATE_ACTIVE}' > .claude/stn-skills-pipeline-state.json"
capture "stn-prompt-router" "completed-pipeline" '{"prompt":"hello"}' "printf '%s' '${STATE_COMPLETED}' > .claude/stn-skills-pipeline-state.json"
capture "stn-prompt-router" "edit-tracker" '{"prompt":"hello"}' "printf '%s' '${EDIT_TRACKER}' > .claude/stn-edit-tracker.json"
# stn-skill-gate (5)
capture "stn-skill-gate" "non-skill-tool" '{"tool_name":"Edit","tool_input":{}}' ''
capture "stn-skill-gate" "non-stn-skill" '{"tool_name":"Skill","tool_input":{"skill":"other:thing"}}' ''
capture "stn-skill-gate" "no-state" '{"tool_name":"Skill","tool_input":{"skill":"stn-skills:plan-writing"}}' ''
capture "stn-skill-gate" "unvalidated-chain" '{"tool_name":"Skill","tool_input":{"skill":"stn-skills:plan-writing"}}' "printf '%s' '${STATE_BRAINSTORMING_UNVAL}' > .claude/stn-skills-pipeline-state.json"
capture "stn-skill-gate" "validated-chain" '{"tool_name":"Skill","tool_input":{"skill":"stn-skills:plan-writing"}}' "printf '%s' '${STATE_BRAINSTORMING_VAL}' > .claude/stn-skills-pipeline-state.json"
# stn-state-validator (6)
capture "stn-state-validator" "non-state-path" '{"tool_name":"Write","tool_input":{"file_path":"/tmp/foo.txt","content":"hello"}}' ''
capture "stn-state-validator" "path-traversal" '{"tool_name":"Write","tool_input":{"file_path":"../evil/stn-skills-pipeline-state.json","content":"{}"}}' ''
capture "stn-state-validator" "empty-content" '{"tool_name":"Write","tool_input":{"file_path":".claude/stn-skills-pipeline-state.json","content":""}}' ''
capture "stn-state-validator" "malformed-json" '{"tool_name":"Write","tool_input":{"file_path":".claude/stn-skills-pipeline-state.json","content":"not json"}}' ''
capture "stn-state-validator" "missing-fields" '{"tool_name":"Write","tool_input":{"file_path":".claude/stn-skills-pipeline-state.json","content":"{\"active_skill\":\"x\"}"}}' ''
capture "stn-state-validator" "valid-state" '{"tool_name":"Write","tool_input":{"file_path":".claude/stn-skills-pipeline-state.json","content":"{\"pipeline_id\":\"x\",\"active_skill\":\"b\",\"current_phase\":1,\"total_phases\":6,\"gates_passed\":[],\"updated_at\":\"2026-04-21\"}"}}' ''
# stn-circuit-breaker (4)
capture "stn-circuit-breaker" "non-gated-tool" '{"tool_name":"Bash","tool_input":{"command":"echo hi"}}' ''
capture "stn-circuit-breaker" "no-state" '{"tool_name":"Edit","tool_input":{}}' ''
capture "stn-circuit-breaker" "green-state" '{"tool_name":"Edit","tool_input":{}}' "printf '%s' '${PLAN_EXEC_GREEN}' > .claude/plan-execution-state.json"
capture "stn-circuit-breaker" "red-state" '{"tool_name":"Edit","tool_input":{}}' "printf '%s' '${PLAN_EXEC_RED}' > .claude/plan-execution-state.json"

count=$(find "${OUT_DIR}" -type f -name '*.json' | wc -l | tr -d ' ')
echo "Contract goldens: $count files under $OUT_DIR"
