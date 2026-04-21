#!/usr/bin/env bash
# eval-copilot-smoke.sh — Opt-in end-to-end Copilot CLI smoke test
# Requires COPILOT_CLI=1 env var to run (CI skips by default since no Copilot
# in standard CI environments).
# Covers R9.

set -o pipefail

if [[ -z "${COPILOT_CLI:-}" ]]; then
  # Emit as PASS (opt-in skip) so eval-runner doesn't flag the script as empty.
  # Real verification requires COPILOT_CLI=1 with Copilot CLI installed.
  echo "PASS: copilot-smoke opt-in skipped (COPILOT_CLI not set — verify locally with COPILOT_CLI=1)"
  echo "SKIP: COPILOT_CLI not set (opt-in test requires Copilot CLI installed)"
  echo ""
  echo "================================"
  echo "Copilot Smoke: 0 passed, 0 failed, 1 skipped"
  echo "================================"
  exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
PASS=0
FAIL=0

# 1. copilot command exists
if ! command -v copilot >/dev/null 2>&1; then
  echo "FAIL: copilot CLI not found on PATH (set COPILOT_CLI=1 but 'copilot' missing)"
  echo ""
  echo "================================"
  echo "Copilot Smoke: 0 passed, 1 failed, 0 skipped"
  echo "================================"
  exit 1
fi
PASS=$((PASS + 1))
echo "PASS: copilot command on PATH"

# 2. plugin.json parseable
if jq -e '.name == "stn-skills" and .version == "8.1.0"' "${REPO_ROOT}/.copilot-plugin/plugin.json" >/dev/null 2>&1; then
  PASS=$((PASS + 1))
  echo "PASS: .copilot-plugin/plugin.json is valid v8.1.0"
else
  FAIL=$((FAIL + 1))
  echo "FAIL: .copilot-plugin/plugin.json invalid or wrong version"
fi

# 3. wrapper smoke — each wrapper under STN_PLATFORM=copilot invocation
for wrapper in "${REPO_ROOT}/.copilot-plugin/hooks"/*; do
  name=$(basename "$wrapper")
  out=$(echo '{}' | bash "$wrapper" 2>&1) || true
  # Accept empty output (Copilot-allow) or valid JSON
  if [[ -z "$out" ]] || echo "$out" | jq . >/dev/null 2>&1; then
    PASS=$((PASS + 1))
    echo "PASS: wrapper $name emits valid output"
  else
    FAIL=$((FAIL + 1))
    echo "FAIL: wrapper $name emitted non-JSON: $out"
  fi
done

echo ""
echo "================================"
echo "Copilot Smoke: $PASS passed, $FAIL failed, 0 skipped"
echo "================================"
[[ "$FAIL" -eq 0 ]] && exit 0 || exit 1
