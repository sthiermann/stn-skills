#!/usr/bin/env bash
# eval-platform-isolation.sh — Adversarial test for platform-detection spoofing
# Verifies that env-var spoofing (e.g. COPILOT_CLI=1 inside a Claude session)
# does NOT flip hooks into Copilot output format. Positive+negative assertion
# in stn_detect_platform must hold.
# Covers R6 (positive+negative assertion), R10 (kill-switch parity).

set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
LIB="${REPO_ROOT}/hooks/stn-hook-output"
HOOKS_DIR="${REPO_ROOT}/hooks"

[[ -f "$LIB" ]] || { echo "FAIL: library not found at $LIB"; exit 1; }

PASS=0
FAIL=0

assert_detect() {
  local name="$1" expected="$2"
  shift 2
  local actual
  actual=$(env -i PATH="$PATH" HOME="$HOME" "$@" bash -c "source '$LIB'; stn_detect_platform")
  if [[ "$actual" == "$expected" ]]; then
    PASS=$((PASS + 1))
    echo "PASS: $name -> $actual"
  else
    FAIL=$((FAIL + 1))
    echo "FAIL: $name expected=$expected got=$actual"
  fi
}

# 1-3: Each platform marker alone resolves correctly
assert_detect "claude-only"   claude  CLAUDE_PLUGIN_ROOT=/tmp/x
assert_detect "cursor-only"   cursor  CURSOR_PLUGIN_ROOT=/tmp/x
assert_detect "copilot-only"  copilot STN_PLATFORM=copilot

# 4: No markers = unknown
assert_detect "no-markers"    unknown

# 5: Spoof attempt — setting COPILOT_CLI=1 (our old env var guess) does NOT
#    flip platform. Only STN_PLATFORM=copilot (set by our wrapper) does.
assert_detect "spoof-copilot-cli-inside-claude" claude CLAUDE_PLUGIN_ROOT=/tmp/x COPILOT_CLI=1

# 6: Our own marker takes precedence (wrapper-originated STN_PLATFORM wins
#    over Claude env — wrapper is the authoritative signal)
assert_detect "stn-platform-overrides-claude" copilot STN_PLATFORM=copilot CLAUDE_PLUGIN_ROOT=/tmp/x

# 7: Cursor marker takes precedence over Claude (cursor checked before claude)
assert_detect "cursor-over-claude" cursor CURSOR_PLUGIN_ROOT=/tmp/x CLAUDE_PLUGIN_ROOT=/tmp/y

# 8: Kill-switch silent exit on all 3 platforms (via stn-init)
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/.claude"
for plat_env in "CLAUDE_PLUGIN_ROOT=$REPO_ROOT" "CURSOR_PLUGIN_ROOT=$REPO_ROOT" "STN_PLATFORM=copilot"; do
  out=$(cd "$TMP" && env -i PATH="$PATH" HOME="$HOME" STN_SKILLS_HOOKS_DISABLE=1 $plat_env bash "$HOOKS_DIR/stn-init" 2>&1)
  if [[ -z "$out" ]]; then
    PASS=$((PASS + 1))
    echo "PASS: kill-switch silent under [$plat_env]"
  else
    FAIL=$((FAIL + 1))
    echo "FAIL: kill-switch leaked output under [$plat_env]: $out"
  fi
done

# 9: Adversarial — STN_PLATFORM=copilot + CLAUDE_PLUGIN_ROOT + stn-circuit-breaker RED state
#    should STILL deny modifications (enforcement hooks honor RED regardless of platform)
mkdir -p "$TMP/adv/.claude"
printf '%s' '{"circuit_breaker":{"state":"RED","consecutive_review_failures":4}}' > "$TMP/adv/.claude/plan-execution-state.json"
# Test under claude
out=$(cd "$TMP/adv" && env -i PATH="$PATH" HOME="$HOME" CLAUDE_PLUGIN_ROOT="$REPO_ROOT" bash "$HOOKS_DIR/stn-circuit-breaker" <<< '{"tool_name":"Edit"}' 2>&1)
if echo "$out" | grep -q '"permissionDecision":"deny"'; then
  PASS=$((PASS + 1))
  echo "PASS: RED circuit breaker denies under claude"
else
  FAIL=$((FAIL + 1))
  echo "FAIL: RED circuit breaker did not deny under claude: $out"
fi
# Test under copilot
out=$(cd "$TMP/adv" && env -i PATH="$PATH" HOME="$HOME" STN_PLATFORM=copilot bash "$HOOKS_DIR/stn-circuit-breaker" <<< '{"tool_name":"Edit"}' 2>&1)
if echo "$out" | grep -q '"permissionDecision":"deny"'; then
  PASS=$((PASS + 1))
  echo "PASS: RED circuit breaker denies under copilot"
else
  FAIL=$((FAIL + 1))
  echo "FAIL: RED circuit breaker did not deny under copilot: $out"
fi

echo ""
echo "================================"
echo "Platform Isolation: $PASS passed, $FAIL failed"
echo "================================"
[[ "$FAIL" -eq 0 ]] && exit 0 || exit 1
