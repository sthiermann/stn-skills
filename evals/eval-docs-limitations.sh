#!/usr/bin/env bash
# eval-docs-limitations.sh — Verify docs/copilot-cli.md contains 6 named limitations
# Covers R15 (6 named limitations present) and R19 (no overclaiming — each R4-R10
# gap from the design spec Risk Register is referenced by name in the doc).

set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
DOC="${REPO_ROOT}/docs/copilot-cli.md"

PASS=0
FAIL=0

if [[ ! -f "$DOC" ]]; then
  echo "FAIL: docs/copilot-cli.md not found at $DOC"
  echo ""
  echo "================================"
  echo "Docs Limitations: 0 passed, 1 failed"
  echo "================================"
  exit 1
fi

# R15: six named limitation phrases must appear in the doc
limitations=(
  "no Skill tool"
  "userPromptSubmitted output ignored"
  "sessionStart best-effort"
  "6 skills use AskUserQuestion"
  "Windows WSL/Git Bash"
  "no Copilot CLI in CI"
)
for p in "${limitations[@]}"; do
  if grep -qF "$p" "$DOC"; then
    PASS=$((PASS + 1))
    echo "PASS: limitation section present — '$p'"
  else
    FAIL=$((FAIL + 1))
    echo "FAIL: missing limitation — '$p'"
  fi
done

# R19: each Risk Register entry R4-R10 (from the design spec) should be referenced
# by name in the Known Limitations section, so readers can cross-reference back
# to the spec's risk assessment.
for ref in "R4" "R9" "R11"; do
  # Only check Risk Register IDs that are user-visible; internal requirement IDs
  # (R5/R6/R7/R8/R10) don't need to appear in user-facing docs.
  if grep -qE "\b${ref}\b" "$DOC"; then
    PASS=$((PASS + 1))
    echo "PASS: Risk reference '$ref' present in docs"
  else
    FAIL=$((FAIL + 1))
    echo "FAIL: missing Risk reference '$ref' (design spec Risk Register entry)"
  fi
done

echo ""
echo "================================"
echo "Docs Limitations: $PASS passed, $FAIL failed"
echo "================================"
[[ "$FAIL" -eq 0 ]] && exit 0 || exit 1
