#!/usr/bin/env bash
# stn-skills Eval Runner
# Runs all eval scripts and produces a summary report.
#
# Usage:
#   ./evals/eval-runner.sh                  # Run all evals
#   ./evals/eval-runner.sh --test activation # Run specific eval
#   ./evals/eval-runner.sh --verbose         # Show detailed output

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="${SCRIPT_DIR}/results"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
REPORT_FILE="${RESULTS_DIR}/report-${TIMESTAMP}.txt"

VERBOSE=false
TARGET_TEST=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --verbose) VERBOSE=true; shift ;;
    --test) TARGET_TEST="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

mkdir -p "$RESULTS_DIR"

total_pass=0
total_fail=0
total_skip=0

run_single_eval() {
  local script="$1"
  local name
  name=$(basename "$script" .sh | sed 's/^eval-//')

  if [[ -n "$TARGET_TEST" && "$name" != "$TARGET_TEST" ]]; then
    total_skip=$((total_skip + 1))
    return
  fi

  echo "--- Running: $name ---"

  local output
  local exit_code=0
  output=$("$script" 2>&1) || exit_code=$?

  if $VERBOSE; then
    echo "$output"
  fi

  local pass_count fail_count
  pass_count=$(echo "$output" | grep -c "^PASS:" || true)
  fail_count=$(echo "$output" | grep -c "^FAIL:" || true)

  total_pass=$((total_pass + pass_count))
  total_fail=$((total_fail + fail_count))

  echo "  Results: ${pass_count} passed, ${fail_count} failed"
  echo ""

  {
    echo "=== $name ==="
    echo "$output"
    echo ""
  } >> "$REPORT_FILE"
}

echo "stn-skills Eval Suite"
echo "====================="
echo "Timestamp: $TIMESTAMP"
echo ""

{
  echo "stn-skills Eval Report - $TIMESTAMP"
  echo "======================================"
  echo ""
} > "$REPORT_FILE"

for script in "$SCRIPT_DIR"/eval-*.sh; do
  [[ "$(basename "$script")" == "eval-runner.sh" ]] && continue
  [[ -x "$script" ]] || continue
  run_single_eval "$script"
done

total=$((total_pass + total_fail))
echo "====================="
echo "Summary: ${total_pass}/${total} passed, ${total_fail} failed, ${total_skip} skipped"
echo "Report: ${REPORT_FILE}"

{
  echo ""
  echo "Summary: ${total_pass}/${total} passed, ${total_fail} failed, ${total_skip} skipped"
} >> "$REPORT_FILE"

[[ $total_fail -eq 0 ]] && exit 0 || exit 1
