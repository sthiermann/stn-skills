#!/usr/bin/env bash
# capture-goldens.sh — Capture byte-exact goldens from current hook state
# Generates 50 golden files (6 hooks × 25 scenarios × 2 platforms)
# Used by eval-00-golden-diff.sh as the regression firewall baseline.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
HOOKS_DIR="${REPO_ROOT}/hooks"
GOLDEN_DIR="${SCRIPT_DIR}/golden/baseline"

TMPDIR_FIX="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_FIX"' EXIT
mkdir -p "${TMPDIR_FIX}/.claude"

# --- Fixtures ---
STATE_ACTIVE='{"pipeline_id":"golden-test","active_skill":"brainstorming","current_phase":3,"total_phases":6,"gates_passed":[1,2],"artifact_path":"test.md","handoff_validated":false,"updated_at":"2026-04-21T00:00:00Z"}'
STATE_COMPLETED='{"pipeline_id":"golden-test","active_skill":"plan-execution","current_phase":8,"total_phases":7,"gates_passed":[1,2,3],"artifact_path":"test.md","handoff_validated":true,"updated_at":"2026-04-21T00:00:00Z"}'
STATE_BRAINSTORMING_UNVAL='{"pipeline_id":"golden-test","active_skill":"brainstorming","current_phase":6,"total_phases":6,"gates_passed":[1,2,3,4],"artifact_path":"test.md","handoff_validated":false,"updated_at":"2026-04-21T00:00:00Z"}'
STATE_BRAINSTORMING_VAL='{"pipeline_id":"golden-test","active_skill":"brainstorming","current_phase":6,"total_phases":6,"gates_passed":[1,2,3,4],"artifact_path":"test.md","handoff_validated":true,"updated_at":"2026-04-21T00:00:00Z"}'
EDIT_TRACKER='{"files":["a.ts","b.ts","c.ts","d.ts"],"updated_at":"2026-04-21T00:00:00Z"}'
PLAN_EXEC_RED='{"plan_id":"golden","circuit_breaker":{"state":"RED","consecutive_review_failures":4}}'
PLAN_EXEC_GREEN='{"plan_id":"golden","circuit_breaker":{"state":"GREEN","consecutive_review_failures":0}}'

mkdir -p "${GOLDEN_DIR}/claude" "${GOLDEN_DIR}/cursor"

# --- capture function: run hook under env, save stdout to golden file ---
# Usage: capture <platform> <hook> <scenario_name> <stdin_json> [setup_cmd]
capture() {
  local platform="$1" hook="$2" scenario="$3" stdin_json="$4" setup_cmd="${5:-}"
  local env_var
  case "$platform" in
    claude) env_var="CLAUDE_PLUGIN_ROOT=${REPO_ROOT}" ;;
    cursor) env_var="CURSOR_PLUGIN_ROOT=${REPO_ROOT}" ;;
    *) echo "Unknown platform: $platform" >&2; return 1 ;;
  esac

  local scenario_dir="${GOLDEN_DIR}/${platform}/${hook}"
  mkdir -p "$scenario_dir"
  local out_file="${scenario_dir}/${scenario}.json"

  # Run setup in subshell (state file prep, lock setup, etc.)
  (
    cd "$TMPDIR_FIX"
    rm -rf .claude/stn-skills-pipeline-state.json .claude/stn-edit-tracker.json .claude/plan-execution-state.json .claude/stn-skills.lock 2>/dev/null || true
    mkdir -p .claude
    [[ -n "$setup_cmd" ]] && eval "$setup_cmd"
    printf '%s' "$stdin_json" | env -i PATH="$PATH" HOME="$HOME" $env_var bash "${HOOKS_DIR}/${hook}" 2>/dev/null > "$out_file" || true
  )
}

# --- 25 scenarios × 2 platforms ---

for platform in claude cursor; do
  echo "Capturing goldens for platform: $platform"

  # stn-init (3 scenarios)
  capture "$platform" "stn-init" "no-state"       '' ''
  capture "$platform" "stn-init" "active-pipeline" '' "printf '%s' '${STATE_ACTIVE}' > .claude/stn-skills-pipeline-state.json"
  capture "$platform" "stn-init" "stale-state" '' "printf '%s' '${STATE_ACTIVE}' > .claude/stn-skills-pipeline-state.json; touch -t 202403010000 .claude/stn-skills-pipeline-state.json"

  # stn-session-lock (3 scenarios)
  capture "$platform" "stn-session-lock" "no-lock"     '' ''
  capture "$platform" "stn-session-lock" "stale-lock"  '' 'mkdir -p .claude/stn-skills.lock; echo "999999" > .claude/stn-skills.lock/pid'
  capture "$platform" "stn-session-lock" "active-lock" '' 'mkdir -p .claude/stn-skills.lock; echo "1" > .claude/stn-skills.lock/pid'

  # stn-prompt-router (4 scenarios)
  capture "$platform" "stn-prompt-router" "no-state" '{"prompt":"hello"}' ''
  capture "$platform" "stn-prompt-router" "active-pipeline" '{"prompt":"hello"}' "printf '%s' '${STATE_ACTIVE}' > .claude/stn-skills-pipeline-state.json"
  capture "$platform" "stn-prompt-router" "completed-pipeline" '{"prompt":"hello"}' "printf '%s' '${STATE_COMPLETED}' > .claude/stn-skills-pipeline-state.json"
  capture "$platform" "stn-prompt-router" "edit-tracker" '{"prompt":"hello"}' "printf '%s' '${EDIT_TRACKER}' > .claude/stn-edit-tracker.json"

  # stn-skill-gate (5 scenarios)
  capture "$platform" "stn-skill-gate" "non-skill-tool"  '{"tool_name":"Edit","tool_input":{}}' ''
  capture "$platform" "stn-skill-gate" "non-stn-skill"   '{"tool_name":"Skill","tool_input":{"skill":"other:thing"}}' ''
  capture "$platform" "stn-skill-gate" "no-state"        '{"tool_name":"Skill","tool_input":{"skill":"stn-skills:plan-writing"}}' ''
  capture "$platform" "stn-skill-gate" "unvalidated-chain" '{"tool_name":"Skill","tool_input":{"skill":"stn-skills:plan-writing"}}' "printf '%s' '${STATE_BRAINSTORMING_UNVAL}' > .claude/stn-skills-pipeline-state.json"
  capture "$platform" "stn-skill-gate" "validated-chain" '{"tool_name":"Skill","tool_input":{"skill":"stn-skills:plan-writing"}}' "printf '%s' '${STATE_BRAINSTORMING_VAL}' > .claude/stn-skills-pipeline-state.json"

  # stn-state-validator (6 scenarios)
  capture "$platform" "stn-state-validator" "non-state-path"  '{"tool_name":"Write","tool_input":{"file_path":"/tmp/foo.txt","content":"hello"}}' ''
  capture "$platform" "stn-state-validator" "path-traversal"  '{"tool_name":"Write","tool_input":{"file_path":"../evil/stn-skills-pipeline-state.json","content":"{}"}}' ''
  capture "$platform" "stn-state-validator" "empty-content"   '{"tool_name":"Write","tool_input":{"file_path":".claude/stn-skills-pipeline-state.json","content":""}}' ''
  capture "$platform" "stn-state-validator" "malformed-json"  '{"tool_name":"Write","tool_input":{"file_path":".claude/stn-skills-pipeline-state.json","content":"not json"}}' ''
  capture "$platform" "stn-state-validator" "missing-fields"  '{"tool_name":"Write","tool_input":{"file_path":".claude/stn-skills-pipeline-state.json","content":"{\"active_skill\":\"x\"}"}}' ''
  capture "$platform" "stn-state-validator" "valid-state"     '{"tool_name":"Write","tool_input":{"file_path":".claude/stn-skills-pipeline-state.json","content":"{\"pipeline_id\":\"x\",\"active_skill\":\"b\",\"current_phase\":1,\"total_phases\":6,\"gates_passed\":[],\"updated_at\":\"2026-04-21\"}"}}' ''

  # stn-circuit-breaker (4 scenarios)
  capture "$platform" "stn-circuit-breaker" "non-gated-tool" '{"tool_name":"Bash","tool_input":{"command":"echo hi"}}' ''
  capture "$platform" "stn-circuit-breaker" "no-state"       '{"tool_name":"Edit","tool_input":{}}' ''
  capture "$platform" "stn-circuit-breaker" "green-state"    '{"tool_name":"Edit","tool_input":{}}' "printf '%s' '${PLAN_EXEC_GREEN}' > .claude/plan-execution-state.json"
  capture "$platform" "stn-circuit-breaker" "red-state"      '{"tool_name":"Edit","tool_input":{}}' "printf '%s' '${PLAN_EXEC_RED}' > .claude/plan-execution-state.json"
done

count=$(find "${GOLDEN_DIR}" -type f -name '*.json' | wc -l | tr -d ' ')
echo "Captured ${count} golden files under ${GOLDEN_DIR}"
if [[ "$count" -lt 50 ]]; then
  echo "ERROR: expected 50 goldens (6 hooks × 25 scenarios × 2 platforms), got ${count}" >&2
  exit 1
fi
exit 0
