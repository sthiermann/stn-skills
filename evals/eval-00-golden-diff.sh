#!/usr/bin/env bash
# eval-00-golden-diff.sh — Regression firewall: current hook output must match captured goldens byte-exact
# Runs first alphabetically (00- prefix). Any byte drift on Claude/Cursor fails the build.
# Covers R7 (regression firewall) and R20 (Claude/Cursor unchanged).

set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
HOOKS_DIR="${REPO_ROOT}/hooks"
GOLDEN_DIR="${SCRIPT_DIR}/golden/baseline"

if [[ ! -d "$GOLDEN_DIR" ]]; then
  echo "FAIL: golden directory missing at $GOLDEN_DIR — run evals/capture-goldens.sh first" >&2
  echo "Golden diff: N/A (no baseline)"
  exit 1
fi

TMPDIR_FIX="$(mktemp -d)"
CURRENT_DIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_FIX" "$CURRENT_DIR"' EXIT
mkdir -p "${TMPDIR_FIX}/.claude"

# --- Fixtures (match capture-goldens.sh exactly) ---
STATE_ACTIVE='{"pipeline_id":"golden-test","active_skill":"brainstorming","current_phase":3,"total_phases":6,"gates_passed":[1,2],"artifact_path":"test.md","handoff_validated":false,"updated_at":"2026-04-21T00:00:00Z"}'
STATE_COMPLETED='{"pipeline_id":"golden-test","active_skill":"plan-execution","current_phase":8,"total_phases":7,"gates_passed":[1,2,3],"artifact_path":"test.md","handoff_validated":true,"updated_at":"2026-04-21T00:00:00Z"}'
STATE_BRAINSTORMING_UNVAL='{"pipeline_id":"golden-test","active_skill":"brainstorming","current_phase":6,"total_phases":6,"gates_passed":[1,2,3,4],"artifact_path":"test.md","handoff_validated":false,"updated_at":"2026-04-21T00:00:00Z"}'
STATE_BRAINSTORMING_VAL='{"pipeline_id":"golden-test","active_skill":"brainstorming","current_phase":6,"total_phases":6,"gates_passed":[1,2,3,4],"artifact_path":"test.md","handoff_validated":true,"updated_at":"2026-04-21T00:00:00Z"}'
EDIT_TRACKER='{"files":["a.ts","b.ts","c.ts","d.ts"],"updated_at":"2026-04-21T00:00:00Z"}'
PLAN_EXEC_RED='{"plan_id":"golden","circuit_breaker":{"state":"RED","consecutive_review_failures":4}}'
PLAN_EXEC_GREEN='{"plan_id":"golden","circuit_breaker":{"state":"GREEN","consecutive_review_failures":0}}'

DRIFT=0
TOTAL=0

capture_current() {
  local platform="$1" hook="$2" scenario="$3" stdin_json="$4" setup_cmd="${5:-}"
  local env_var
  case "$platform" in
    claude) env_var="CLAUDE_PLUGIN_ROOT=${REPO_ROOT}" ;;
    cursor) env_var="CURSOR_PLUGIN_ROOT=${REPO_ROOT}" ;;
  esac
  local scenario_dir="${CURRENT_DIR}/${platform}/${hook}"
  mkdir -p "$scenario_dir"
  local out_file="${scenario_dir}/${scenario}.json"
  (
    cd "$TMPDIR_FIX"
    rm -rf .claude/stn-skills-pipeline-state.json .claude/stn-edit-tracker.json .claude/plan-execution-state.json .claude/stn-skills.lock 2>/dev/null || true
    mkdir -p .claude
    [[ -n "$setup_cmd" ]] && eval "$setup_cmd"
    printf '%s' "$stdin_json" | env -i PATH="$PATH" HOME="$HOME" $env_var bash "${HOOKS_DIR}/${hook}" 2>/dev/null > "$out_file" || true
  )
}

diff_scenario() {
  local platform="$1" hook="$2" scenario="$3"
  local golden="${GOLDEN_DIR}/${platform}/${hook}/${scenario}.json"
  local current="${CURRENT_DIR}/${platform}/${hook}/${scenario}.json"
  TOTAL=$((TOTAL + 1))
  if ! diff -q "$golden" "$current" >/dev/null 2>&1; then
    DRIFT=$((DRIFT + 1))
    echo "DRIFT: ${platform}/${hook}/${scenario}"
    diff -u "$golden" "$current" | head -20
    echo "---"
  fi
}

for platform in claude cursor; do
  # stn-init
  capture_current "$platform" "stn-init" "no-state"       '' ''
  capture_current "$platform" "stn-init" "active-pipeline" '' "printf '%s' '${STATE_ACTIVE}' > .claude/stn-skills-pipeline-state.json"
  capture_current "$platform" "stn-init" "stale-state" '' "printf '%s' '${STATE_ACTIVE}' > .claude/stn-skills-pipeline-state.json; touch -t 202403010000 .claude/stn-skills-pipeline-state.json"
  # stn-session-lock
  capture_current "$platform" "stn-session-lock" "no-lock"     '' ''
  capture_current "$platform" "stn-session-lock" "stale-lock"  '' 'mkdir -p .claude/stn-skills.lock; echo "999999" > .claude/stn-skills.lock/pid'
  capture_current "$platform" "stn-session-lock" "active-lock" '' 'mkdir -p .claude/stn-skills.lock; echo "1" > .claude/stn-skills.lock/pid'
  # stn-prompt-router
  capture_current "$platform" "stn-prompt-router" "no-state" '{"prompt":"hello"}' ''
  capture_current "$platform" "stn-prompt-router" "active-pipeline" '{"prompt":"hello"}' "printf '%s' '${STATE_ACTIVE}' > .claude/stn-skills-pipeline-state.json"
  capture_current "$platform" "stn-prompt-router" "completed-pipeline" '{"prompt":"hello"}' "printf '%s' '${STATE_COMPLETED}' > .claude/stn-skills-pipeline-state.json"
  capture_current "$platform" "stn-prompt-router" "edit-tracker" '{"prompt":"hello"}' "printf '%s' '${EDIT_TRACKER}' > .claude/stn-edit-tracker.json"
  # stn-skill-gate
  capture_current "$platform" "stn-skill-gate" "non-skill-tool"  '{"tool_name":"Edit","tool_input":{}}' ''
  capture_current "$platform" "stn-skill-gate" "non-stn-skill"   '{"tool_name":"Skill","tool_input":{"skill":"other:thing"}}' ''
  capture_current "$platform" "stn-skill-gate" "no-state"        '{"tool_name":"Skill","tool_input":{"skill":"stn-skills:plan-writing"}}' ''
  capture_current "$platform" "stn-skill-gate" "unvalidated-chain" '{"tool_name":"Skill","tool_input":{"skill":"stn-skills:plan-writing"}}' "printf '%s' '${STATE_BRAINSTORMING_UNVAL}' > .claude/stn-skills-pipeline-state.json"
  capture_current "$platform" "stn-skill-gate" "validated-chain" '{"tool_name":"Skill","tool_input":{"skill":"stn-skills:plan-writing"}}' "printf '%s' '${STATE_BRAINSTORMING_VAL}' > .claude/stn-skills-pipeline-state.json"
  # stn-state-validator
  capture_current "$platform" "stn-state-validator" "non-state-path"  '{"tool_name":"Write","tool_input":{"file_path":"/tmp/foo.txt","content":"hello"}}' ''
  capture_current "$platform" "stn-state-validator" "path-traversal"  '{"tool_name":"Write","tool_input":{"file_path":"../evil/stn-skills-pipeline-state.json","content":"{}"}}' ''
  capture_current "$platform" "stn-state-validator" "empty-content"   '{"tool_name":"Write","tool_input":{"file_path":".claude/stn-skills-pipeline-state.json","content":""}}' ''
  capture_current "$platform" "stn-state-validator" "malformed-json"  '{"tool_name":"Write","tool_input":{"file_path":".claude/stn-skills-pipeline-state.json","content":"not json"}}' ''
  capture_current "$platform" "stn-state-validator" "missing-fields"  '{"tool_name":"Write","tool_input":{"file_path":".claude/stn-skills-pipeline-state.json","content":"{\"active_skill\":\"x\"}"}}' ''
  capture_current "$platform" "stn-state-validator" "valid-state"     '{"tool_name":"Write","tool_input":{"file_path":".claude/stn-skills-pipeline-state.json","content":"{\"pipeline_id\":\"x\",\"active_skill\":\"b\",\"current_phase\":1,\"total_phases\":6,\"gates_passed\":[],\"updated_at\":\"2026-04-21\"}"}}' ''
  # stn-circuit-breaker
  capture_current "$platform" "stn-circuit-breaker" "non-gated-tool" '{"tool_name":"Bash","tool_input":{"command":"echo hi"}}' ''
  capture_current "$platform" "stn-circuit-breaker" "no-state"       '{"tool_name":"Edit","tool_input":{}}' ''
  capture_current "$platform" "stn-circuit-breaker" "green-state"    '{"tool_name":"Edit","tool_input":{}}' "printf '%s' '${PLAN_EXEC_GREEN}' > .claude/plan-execution-state.json"
  capture_current "$platform" "stn-circuit-breaker" "red-state"      '{"tool_name":"Edit","tool_input":{}}' "printf '%s' '${PLAN_EXEC_RED}' > .claude/plan-execution-state.json"

  # Diff all captured scenarios for this platform
  for hook_dir in "${GOLDEN_DIR}/${platform}"/*/; do
    hook=$(basename "$hook_dir")
    for golden_file in "${hook_dir}"*.json; do
      scenario=$(basename "$golden_file" .json)
      diff_scenario "$platform" "$hook" "$scenario"
    done
  done
done

if [[ "$DRIFT" -eq 0 ]]; then
  echo "PASS: golden diff — 0 drift across ${TOTAL} files"
  echo "Golden diff: 0 drift across ${TOTAL} files"
  exit 0
fi
echo "FAIL: golden diff — ${DRIFT} drift across ${TOTAL} files"
echo "Golden diff: ${DRIFT} drift across ${TOTAL} files"
exit 1
