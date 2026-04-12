#!/usr/bin/env bash
# stn-skills Activation Eval
# Tests whether each skill activates when given relevant prompts.
#
# Requires: claude CLI in PATH
# Each prompt is sent with --max-turns 1 to check if the skill is invoked.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROMPTS_DIR="${SCRIPT_DIR}/prompts"
TIMEOUT="${EVAL_TIMEOUT:-60}"

check_activation() {
  local skill_name="$1"
  local prompt="$2"
  local prompt_file
  prompt_file=$(mktemp)
  echo "$prompt" > "$prompt_file"

  local output
  output=$(timeout "$TIMEOUT" claude -p < "$prompt_file" --max-turns 1 2>&1) || true
  rm -f "$prompt_file"

  # Check if the skill name appears in the output (case-insensitive)
  if echo "$output" | grep -qi "$skill_name"; then
    echo "PASS: [$skill_name] activated for: \"$prompt\""
    return 0
  else
    echo "FAIL: [$skill_name] NOT activated for: \"$prompt\""
    return 1
  fi
}

echo "Activation Eval"
echo "==============="
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
