#!/usr/bin/env bash
# eval-tool-requirement.sh — Verify fail-loud behavior when jq + python3 missing
# Enforcement hooks: exit 2 with stderr diagnostic
# Informing hooks (stn-init): graceful fallback
# Covers R12.

set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
LIB="${REPO_ROOT}/hooks/stn-hook-output"

PASS=0
FAIL=0

# 1. stn_require_json_tool returns 2 with stderr when both missing
# Mask jq + python3 via a PATH containing only an empty dir (bash itself stays on absolute path)
EMPTY_PATH_DIR="$(mktemp -d)"
err_output=$(PATH="$EMPTY_PATH_DIR" /bin/bash -c "source '$LIB' 2>/dev/null; stn_require_json_tool" 2>&1 1>/dev/null)
rc=$?
rmdir "$EMPTY_PATH_DIR"
if [[ $rc -eq 2 ]]; then
  PASS=$((PASS + 1))
  echo "PASS: stn_require_json_tool returns 2 when both missing"
else
  FAIL=$((FAIL + 1))
  echo "FAIL: stn_require_json_tool returned $rc, expected 2"
fi
if echo "$err_output" | grep -q 'stn-skills: requires jq or python3'; then
  PASS=$((PASS + 1))
  echo "PASS: stderr diagnostic present"
else
  FAIL=$((FAIL + 1))
  echo "FAIL: stderr missing diagnostic: [$err_output]"
fi

# 2. stn_require_json_tool returns 0 with jq available (or python3)
if command -v jq >/dev/null 2>&1 || command -v python3 >/dev/null 2>&1; then
  rc=$(bash -c "source '$LIB' 2>/dev/null; stn_require_json_tool; echo \$?")
  if [[ "$rc" == "0" ]]; then
    PASS=$((PASS + 1))
    echo "PASS: stn_require_json_tool returns 0 when jq/python3 available"
  else
    FAIL=$((FAIL + 1))
    echo "FAIL: stn_require_json_tool returned $rc with tools available"
  fi
fi

# 3. _STN_JSON_TOOL_OK cache works (2nd call faster, same result)
out=$(bash -c "source '$LIB' 2>/dev/null; stn_require_json_tool; stn_require_json_tool; echo rc=\$?")
if [[ "$out" == *"rc=0"* ]]; then
  PASS=$((PASS + 1))
  echo "PASS: cached tool check idempotent"
else
  FAIL=$((FAIL + 1))
  echo "FAIL: cached tool check failed: $out"
fi

# 4. json_get returns empty gracefully when tools missing (non-fatal)
EMPTY_PATH_DIR2="$(mktemp -d)"
out=$(PATH="$EMPTY_PATH_DIR2" /bin/bash -c "source '$LIB' 2>/dev/null; echo '{\"foo\":\"bar\"}' | json_get foo -" 2>/dev/null)
rmdir "$EMPTY_PATH_DIR2"
if [[ -z "$out" ]]; then
  PASS=$((PASS + 1))
  echo "PASS: json_get returns empty when tools missing (non-fatal)"
else
  FAIL=$((FAIL + 1))
  echo "FAIL: json_get returned [$out] without jq/python3"
fi

echo ""
echo "================================"
echo "Tool Requirement: $PASS passed, $FAIL failed"
echo "================================"
[[ "$FAIL" -eq 0 ]] && exit 0 || exit 1
