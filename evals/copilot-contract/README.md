# Copilot Contract-Spec Goldens

**Status:** CONTRACT-SPEC (not authoritative)

These files describe the Copilot CLI output format that stn-skills *intends* to emit. They are NOT captured from a live Copilot CLI session (the CI environment does not have Copilot CLI installed).

Live verification requires `COPILOT_CLI=1 ./evals/eval-copilot-smoke.sh` with GitHub Copilot CLI installed. See `docs/copilot-cli.md` for details.

## Generation

These fixtures are generated from the stn-hook-output library under `STN_PLATFORM=copilot`. Each file is the stdout byte-exact emission for a specific (hook, scenario) combination. Re-generate by running `./evals/capture-copilot-contract.sh` (created by this task).

## Coverage

25 scenarios across 6 hooks, mirroring the baseline goldens under `evals/golden/baseline/`:
- stn-init: 3 (no-state, active-pipeline, stale-state)
- stn-session-lock: 3 (no-lock, stale-lock, active-lock)
- stn-prompt-router: 4 (no-state, active-pipeline, completed-pipeline, edit-tracker)
- stn-skill-gate: 5 (non-skill-tool, non-stn-skill, no-state, unvalidated-chain, validated-chain)
- stn-state-validator: 6 (non-state-path, path-traversal, empty-content, malformed-json, missing-fields, valid-state)
- stn-circuit-breaker: 4 (non-gated-tool, no-state, green-state, red-state)
