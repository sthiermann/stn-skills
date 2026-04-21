#!/usr/bin/env bash
# eval-copilot-skills-count.sh — Verify documented AskUserQuestion counts match SKILL.md reality
# docs/copilot-cli.md enumerates 6 skills + AskUserQuestion counts as a "degraded mode"
# disclosure on Copilot. This eval ensures the documented counts never drift from code.
# Covers R14. Uses parallel arrays for bash 3.x compatibility (macOS system bash).

set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SKILLS_DIR="${REPO_ROOT}/skills"

PASS=0
FAIL=0

# Parallel arrays: skill name -> expected count (per docs/copilot-cli.md)
SKILL_NAMES=("build-feature" "brainstorming" "codebase-audit" "plan-execution" "plan-writing" "codebase-quality-bootstrap")
EXPECTED_COUNTS=(3 9 5 7 9 2)

i=0
for skill in "${SKILL_NAMES[@]}"; do
  expected="${EXPECTED_COUNTS[$i]}"
  skill_file="${SKILLS_DIR}/${skill}/SKILL.md"
  if [[ ! -f "$skill_file" ]]; then
    FAIL=$((FAIL + 1))
    echo "FAIL: $skill_file not found"
    i=$((i + 1))
    continue
  fi
  actual=$(grep -c 'AskUserQuestion' "$skill_file")
  if [[ "$actual" == "$expected" ]]; then
    PASS=$((PASS + 1))
    echo "PASS: $skill has $actual AskUserQuestion references (expected $expected)"
  else
    FAIL=$((FAIL + 1))
    echo "FAIL: $skill has $actual AskUserQuestion refs, expected $expected (docs drift — update docs/copilot-cli.md)"
  fi
  i=$((i + 1))
done

echo ""
echo "================================"
echo "Copilot Skills Count: $PASS passed, $FAIL failed"
echo "================================"
[[ "$FAIL" -eq 0 ]] && exit 0 || exit 1
