#!/usr/bin/env bash
# eval-shell-compat.sh — Verify Copilot wrappers execute under POSIX sh
# Wrappers use #!/bin/sh + defensive [ -n "$BASH_VERSION" ] || exec bash re-exec.
# Covers R4.

set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
WRAPPER_DIR="${REPO_ROOT}/.copilot-plugin/hooks"

[[ -d "$WRAPPER_DIR" ]] || { echo "FAIL: wrapper dir not found at $WRAPPER_DIR"; exit 1; }

PASS=0
FAIL=0

# Minimal stdin payloads per wrapper (the hooks that require specific tool_name)
get_stdin() {
  case "$1" in
    stn-init|stn-session-lock) echo '{}' ;;
    stn-prompt-router)         echo '{"prompt":"hi"}' ;;
    stn-skill-gate)            echo '{"tool_name":"Edit","tool_input":{}}' ;;
    stn-state-validator)       echo '{"tool_name":"Bash","tool_input":{"command":"echo"}}' ;;
    stn-circuit-breaker)       echo '{"tool_name":"Bash","tool_input":{"command":"echo"}}' ;;
  esac
}

for wrapper in "$WRAPPER_DIR"/*; do
  name=$(basename "$wrapper")
  stdin_data=$(get_stdin "$name")

  # Check executable
  if [[ ! -x "$wrapper" ]]; then
    FAIL=$((FAIL + 1))
    echo "FAIL: $name not executable"
    continue
  fi
  # Check sh shebang
  if ! head -1 "$wrapper" | grep -qE '^#!/bin/sh$'; then
    FAIL=$((FAIL + 1))
    echo "FAIL: $name missing #!/bin/sh shebang"
    continue
  fi
  # Check kill-switch presence
  if ! grep -q 'STN_SKILLS_HOOKS_DISABLE' "$wrapper"; then
    FAIL=$((FAIL + 1))
    echo "FAIL: $name missing kill-switch check"
    continue
  fi
  # Check STN_PLATFORM=copilot marker
  if ! grep -q 'STN_PLATFORM="copilot"' "$wrapper"; then
    FAIL=$((FAIL + 1))
    echo "FAIL: $name missing STN_PLATFORM=copilot export"
    continue
  fi

  # Execute under sh (POSIX). Exit 0 or valid JSON required.
  out=$(echo "$stdin_data" | sh "$wrapper" 2>/dev/null)
  exit_code=$?
  if [[ $exit_code -ne 0 ]]; then
    FAIL=$((FAIL + 1))
    echo "FAIL: $name sh exec returned $exit_code"
    continue
  fi
  # Empty stdout = Copilot-allow semantics (accepted)
  if [[ -z "$out" ]]; then
    PASS=$((PASS + 1))
    echo "PASS: $name under sh (empty stdout = allow)"
    continue
  fi
  # Non-empty stdout must be valid JSON
  if echo "$out" | jq . >/dev/null 2>&1 || python3 -c "import json,sys; json.loads(sys.argv[1])" "$out" >/dev/null 2>&1; then
    PASS=$((PASS + 1))
    echo "PASS: $name under sh (valid JSON stdout)"
  else
    FAIL=$((FAIL + 1))
    echo "FAIL: $name under sh produced non-JSON: $out"
  fi

  # Kill-switch test
  out=$(echo "$stdin_data" | STN_SKILLS_HOOKS_DISABLE=1 sh "$wrapper" 2>/dev/null)
  if [[ -z "$out" ]]; then
    PASS=$((PASS + 1))
    echo "PASS: $name kill-switch under sh (empty stdout)"
  else
    FAIL=$((FAIL + 1))
    echo "FAIL: $name kill-switch leaked output under sh: $out"
  fi
done

echo ""
echo "================================"
echo "Shell Compat: $PASS passed, $FAIL failed"
echo "================================"
[[ "$FAIL" -eq 0 ]] && exit 0 || exit 1
