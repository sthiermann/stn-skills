#!/usr/bin/env bash
# stn-skills Activation Eval
# Tests whether each skill activates when given relevant prompts.
#
# Requires: claude CLI in PATH
# Uses --max-turns 3 to allow routing (session-init -> routing -> skill invocation).
# Uses --output-format json to capture tool calls, falling back to text grep.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROMPTS_DIR="${SCRIPT_DIR}/prompts"
TIMEOUT="${EVAL_TIMEOUT:-120}"
MAX_TURNS="${EVAL_MAX_TURNS:-3}"

check_activation() {
  local skill_name="$1"
  local prompt="$2"

  local output
  output=$(timeout "$TIMEOUT" claude -p "$prompt" --max-turns "$MAX_TURNS" --output-format json 2>/dev/null) || true

  # Strategy 1: Check JSON output for Skill tool invocation
  if echo "$output" | grep -qi "stn-skills:${skill_name}"; then
    echo "PASS: [$skill_name] activated for: \"$prompt\""
    return 0
  fi

  # Strategy 2: Check for skill name mention in text output (weaker signal)
  if echo "$output" | grep -qi "\"$skill_name\""; then
    echo "PASS: [$skill_name] mentioned for: \"$prompt\" (weak match)"
    return 0
  fi

  # Strategy 3: Fallback to plain text mode if JSON mode fails
  local text_output
  text_output=$(timeout "$TIMEOUT" claude -p "$prompt" --max-turns "$MAX_TURNS" 2>&1) || true
  if echo "$text_output" | grep -qi "$skill_name"; then
    echo "PASS: [$skill_name] activated (text mode) for: \"$prompt\""
    return 0
  fi

  echo "FAIL: [$skill_name] NOT activated for: \"$prompt\""
  return 1
}

echo "Activation Eval"
echo "==============="
echo ""
echo "NOTE: This eval requires the Claude CLI and makes LLM calls."
echo "      Set EVAL_TIMEOUT (default: 120s) and EVAL_MAX_TURNS (default: 3)."
echo ""

pass=0
fail=0

for prompt_file in "$PROMPTS_DIR"/*.txt; do
  [[ -f "$prompt_file" ]] || continue
  skill_name=$(basename "$prompt_file" .txt)

  while IFS= read -r prompt || [[ -n "$prompt" ]]; do
    [[ -z "$prompt" || "$prompt" == \#* ]] && continue
    if check_activation "$skill_name" "$prompt"; then
      ((pass++)) || true
    else
      ((fail++)) || true
    fi
  done < "$prompt_file"
done

echo ""
echo "Activation: ${pass} passed, ${fail} failed"
