#!/usr/bin/env bash
# eval-copilot-contract.sh — Assert library emits correct Copilot-format JSON
# CONTRACT-SPEC eval: NOT authoritative for live Copilot CLI behavior. Live
# verification requires eval-copilot-smoke.sh with COPILOT_CLI=1 env.
# This eval tests only our emission — what we WOULD send Copilot.
# Covers R8.

set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
LIB="${REPO_ROOT}/hooks/stn-hook-output"

PASS=0
FAIL=0

assert_contains() {
  local name="$1" expected="$2" actual="$3"
  if echo "$actual" | grep -qF "$expected"; then
    PASS=$((PASS + 1))
    echo "PASS: $name"
  else
    FAIL=$((FAIL + 1))
    echo "FAIL: $name (expect containing '$expected', got: $actual)"
  fi
}

# Contract: _allow under copilot emits NOTHING (absence = allow)
out=$(bash -c "source '$LIB'; STN_PLATFORM=copilot _allow" 2>&1)
if [[ -z "$out" ]]; then
  PASS=$((PASS + 1))
  echo "PASS: _allow under copilot emits empty stdout"
else
  FAIL=$((FAIL + 1))
  echo "FAIL: _allow under copilot emitted: $out"
fi

# Contract: _deny under copilot emits top-level permissionDecision (no hookSpecificOutput wrapper)
out=$(bash -c "source '$LIB'; STN_PLATFORM=copilot _deny 'test-reason'" 2>&1)
assert_contains "_deny copilot has permissionDecision=deny" '"permissionDecision":"deny"' "$out"
assert_contains "_deny copilot has reason" '"permissionDecisionReason":"test-reason"' "$out"
if echo "$out" | grep -q 'hookSpecificOutput'; then
  FAIL=$((FAIL + 1))
  echo "FAIL: _deny copilot leaked hookSpecificOutput wrapper"
else
  PASS=$((PASS + 1))
  echo "PASS: _deny copilot no hookSpecificOutput wrapper"
fi

# Contract: _deny with event_name on copilot — event_name still irrelevant (top-level)
out=$(bash -c "source '$LIB'; STN_PLATFORM=copilot _deny 'sr' '' 'SessionStart'" 2>&1)
assert_contains "_deny copilot SessionStart still top-level" '"permissionDecision":"deny"' "$out"

# Contract: _inform under copilot emits top-level additionalContext
out=$(bash -c "source '$LIB'; STN_PLATFORM=copilot _inform 'hint-text'" 2>&1)
assert_contains "_inform copilot additionalContext top-level" '"additionalContext":"hint-text"' "$out"
if echo "$out" | grep -q 'hookSpecificOutput'; then
  FAIL=$((FAIL + 1))
  echo "FAIL: _inform copilot leaked hookSpecificOutput wrapper"
else
  PASS=$((PASS + 1))
  echo "PASS: _inform copilot no hookSpecificOutput wrapper"
fi

# Contract: stn_emit_context under copilot emits top-level additionalContext
out=$(bash -c "source '$LIB'; STN_PLATFORM=copilot stn_emit_context 'SessionStart' 'ctx-body'" 2>&1)
assert_contains "stn_emit_context copilot additionalContext" '"additionalContext":"ctx-body"' "$out"

# Contract: stn_should_skip_tool returns 0 (skip) for Copilot+non-matching tool
bash -c "source '$LIB'; STN_PLATFORM=copilot stn_should_skip_tool Bash 'Edit|Write'"
if [[ $? -eq 0 ]]; then
  PASS=$((PASS + 1))
  echo "PASS: stn_should_skip_tool skips non-matching tool on copilot"
else
  FAIL=$((FAIL + 1))
  echo "FAIL: stn_should_skip_tool did not skip non-matching tool"
fi

# Contract: stn_should_skip_tool returns 1 (don't skip) for Copilot+matching tool
bash -c "source '$LIB'; STN_PLATFORM=copilot stn_should_skip_tool Edit 'Edit|Write'"
if [[ $? -eq 1 ]]; then
  PASS=$((PASS + 1))
  echo "PASS: stn_should_skip_tool does NOT skip matching tool on copilot"
else
  FAIL=$((FAIL + 1))
  echo "FAIL: stn_should_skip_tool skipped matching tool"
fi

# Claude/Cursor contract: _allow/_deny/_inform still emit hookSpecificOutput wrapper
out=$(bash -c "source '$LIB'; CLAUDE_PLUGIN_ROOT=/x _allow" 2>&1)
assert_contains "_allow claude wrapper" '"hookSpecificOutput":{"hookEventName":"PreToolUse"' "$out"

out=$(bash -c "source '$LIB'; CLAUDE_PLUGIN_ROOT=/x _deny 'r'" 2>&1)
assert_contains "_deny claude wrapper" '"hookSpecificOutput":{"hookEventName":"PreToolUse"' "$out"

out=$(bash -c "source '$LIB'; CLAUDE_PLUGIN_ROOT=/x _deny 'r' '' 'SessionStart'" 2>&1)
assert_contains "_deny claude SessionStart event-name" '"hookEventName":"SessionStart"' "$out"

echo ""
echo "================================"
echo "Copilot Contract: $PASS passed, $FAIL failed"
echo "================================"
[[ "$FAIL" -eq 0 ]] && exit 0 || exit 1
