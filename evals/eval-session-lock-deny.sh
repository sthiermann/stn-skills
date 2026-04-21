#!/usr/bin/env bash
# eval-session-lock-deny.sh — Verify stn-session-lock emits correct hookEventName
# Under Claude/Cursor: hookEventName MUST be "SessionStart" (not PreToolUse)
# Under Copilot: top-level permissionDecision=deny (no wrapper)
# Covers R11.

set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
HOOKS_DIR="${REPO_ROOT}/hooks"

PASS=0
FAIL=0

# Setup fresh lock with live PID (our own $$)
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/.claude/stn-skills.lock"
echo "$$" > "$TMP/.claude/stn-skills.lock/pid"

# Claude: hookEventName must be SessionStart
out=$(cd "$TMP" && env -i PATH="$PATH" HOME="$HOME" CLAUDE_PLUGIN_ROOT="$REPO_ROOT" bash "$HOOKS_DIR/stn-session-lock" 2>&1)
if echo "$out" | grep -q '"hookEventName":"SessionStart"'; then
  PASS=$((PASS + 1))
  echo "PASS: claude emits hookEventName=SessionStart on lock deny"
else
  FAIL=$((FAIL + 1))
  echo "FAIL: claude missing SessionStart event name: $out"
fi
# Must NOT be PreToolUse (regression check — would happen if _deny 3rd arg isn't threaded)
if echo "$out" | grep -q '"hookEventName":"PreToolUse"'; then
  FAIL=$((FAIL + 1))
  echo "FAIL: claude leaked PreToolUse as hookEventName: $out"
else
  PASS=$((PASS + 1))
  echo "PASS: claude does NOT emit PreToolUse on SessionStart deny"
fi

# Copilot: top-level permissionDecision (no hookSpecificOutput wrapper)
out=$(cd "$TMP" && env -i PATH="$PATH" HOME="$HOME" STN_PLATFORM=copilot bash "$HOOKS_DIR/stn-session-lock" 2>&1)
if echo "$out" | grep -q '"permissionDecision":"deny"'; then
  PASS=$((PASS + 1))
  echo "PASS: copilot emits top-level permissionDecision=deny"
else
  FAIL=$((FAIL + 1))
  echo "FAIL: copilot missing permissionDecision=deny: $out"
fi
if echo "$out" | grep -q 'hookSpecificOutput'; then
  FAIL=$((FAIL + 1))
  echo "FAIL: copilot leaked hookSpecificOutput wrapper: $out"
else
  PASS=$((PASS + 1))
  echo "PASS: copilot does NOT use hookSpecificOutput wrapper"
fi

echo ""
echo "================================"
echo "Session Lock Deny: $PASS passed, $FAIL failed"
echo "================================"
[[ "$FAIL" -eq 0 ]] && exit 0 || exit 1
