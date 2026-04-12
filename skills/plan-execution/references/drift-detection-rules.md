# Drift Detection Rules

3-check system run after every task-implementer completion. Detects scope creep, missing work, and overreach.

## Check 1: Scope Check

Compare actual file changes against planned file list.

```bash
git diff --name-only HEAD~1  # files changed in last commit
```

Cross-reference against task's `files` field from plan.

| Condition | Classification |
|---|---|
| 0 extra files, 0 missing files | CLEAN |
| 1 extra file | MINOR_DRIFT |
| 2+ extra files OR any missing file | MAJOR_DRIFT |

Extra file = modified but not in plan. Missing file = in plan but not modified.

## Check 2: Content Check

Verify acceptance criteria evidence coverage from implementer status report.

| Condition | Classification |
|---|---|
| All criteria have evidence | CLEAN |
| 1 criterion without evidence | MINOR_DRIFT |
| 2+ criteria without evidence | MAJOR_DRIFT |

Evidence must be specific and verifiable — "done" or "implemented" without proof counts as missing.

## Check 3: Overreach Check

Compare actual change volume against expected scope.

```bash
git diff --stat HEAD~1  # lines changed
```

Calculate ratio: `actual_lines_changed / expected_lines_changed`

Expected lines derived from task complexity estimate in plan.

| Ratio | Classification |
|---|---|
| Under 3x | CLEAN |
| 3x to 5x | MINOR_DRIFT |
| Over 5x | MAJOR_DRIFT |

If no expected estimate exists, use 200 lines as default baseline.

## Overall Classification

Overall drift = worst classification across all 3 checks.

```
If any check is MAJOR_DRIFT → overall MAJOR_DRIFT
Else if any check is MINOR_DRIFT → overall MINOR_DRIFT
Else → overall CLEAN
```

## Response Actions

### CLEAN

Log result. Proceed to checkpoint protocol.

### MINOR_DRIFT

Log result with details. Proceed to checkpoint protocol. Include drift note in commit message. No user interruption.

### MAJOR_DRIFT

1. **Stop** — do not checkpoint.
2. **Present** drift report to user:

```
DRIFT DETECTED: MAJOR
Task: T{N} - {Title}

Scope Check: {CLEAN|MINOR_DRIFT|MAJOR_DRIFT}
  Extra files: {list}
  Missing files: {list}

Content Check: {CLEAN|MINOR_DRIFT|MAJOR_DRIFT}
  Criteria without evidence: {list}

Overreach Check: {CLEAN|MINOR_DRIFT|MAJOR_DRIFT}
  Expected: ~{N} lines | Actual: {N} lines | Ratio: {N}x
```

3. **Offer** 3 options:
   - **Accept**: checkpoint as-is, update plan to reflect actual scope
   - **Revert**: `git reset --hard {last_checkpoint_SHA}`, retry task
   - **Replan**: revert + regenerate remaining tasks with adjusted scope

4. Increment MAJOR_DRIFT counter in circuit breaker.

## Logging Format

Every drift check produces a log entry:

```
DRIFT LOG | T{N} | Scope:{result} Content:{result} Overreach:{result} | Overall:{result}
```

Accumulated in completion report under "Drift Detection Log" section.
