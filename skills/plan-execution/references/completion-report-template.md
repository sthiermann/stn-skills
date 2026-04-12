# Completion Report Template

Formal report produced after all tasks execute (or execution halts).

## Structure

### 1. Executive Summary

```
Plan: {plan_name}
Tasks: {completed}/{total} ({percentage}%)
Execution span: {start_time} → {end_time}
Fidelity score: {score}/100
Overall verdict: COMPLETE | PARTIAL | FAILED
```

### 2. Task Completion Matrix

| Task | Status | Checkpoint SHA | Spec | Quality | Integration | Attempts |
|---|---|---|---|---|---|---|
| T1 - {title} | DONE | `abc1234` | PASS | PASS | PASS | 1 |
| T2 - {title} | DONE_WITH_CONCERNS | `def5678` | PASS | PASS | PASS | 2 |
| T3 - {title} | BLOCKED | — | — | — | — | 3 |

### 3. Acceptance Criteria Verification

| Task | Criterion | Verified | Evidence |
|---|---|---|---|
| T1 | {criterion text} | YES | {evidence summary} |
| T1 | {criterion text} | YES | {evidence summary} |
| T2 | {criterion text} | YES | {evidence summary} |

### 4. Traceability Matrix

| Requirement | Task | Code Change | Verification |
|---|---|---|---|
| {requirement} | T{N} | `{file}:{lines}` | {test/command that proves it} |

### 5. Test Suite Evidence

```
BEFORE: {test count} tests, {pass count} passing, {fail count} failing
AFTER:  {test count} tests, {pass count} passing, {fail count} failing
DELTA:  +{new tests} tests, {regressions} regressions
```

### 6. Build & Lint Evidence

```
Build: PASS | FAIL
Lint:  PASS | FAIL ({warning count} warnings)
Type check: PASS | FAIL
```

### 7. Drift Detection Log

| Task | Check | Classification | Resolution |
|---|---|---|---|
| T{N} | Scope | MINOR_DRIFT | Accepted |
| T{N} | Overreach | MAJOR_DRIFT | Reverted and retried |

### 8. Circuit Breaker Log

| Event | Task | Metric | Threshold | State | Resolution |
|---|---|---|---|---|---|
| Review fail #2 | T3 | consecutive_review | WARNING | YELLOW | User: continue |
| Review fail #4 | T3 | consecutive_review | HARD | RED | User: skip task |

### 9. Cleanup Summary

```
Items found: {count}
Items fixed: {count}
Categories: {debug logs, temp files, unused imports, etc.}
Post-cleanup test status: PASS | FAIL
```

### 10. Checkpoint History

| Order | Task | SHA | Verification |
|---|---|---|---|
| 1 | T1 - {title} | `abc1234` | {command}: PASS |
| 2 | T2 - {title} | `def5678` | {command}: PASS |

### 11. Files Modified

| Path | Lines Changed | Tasks |
|---|---|---|
| `src/auth/login.ts` | +45 / -12 | T1, T3 |
| `tests/auth.test.ts` | +30 / -0 | T1 |

### 12. Adaptive Replanning Log

Only present if replanning occurred.

| Trigger | Original Plan | Revised Plan | Reason |
|---|---|---|---|
| T3 MAJOR_DRIFT | T3: {original scope} | T3: {revised scope} | Overreach detected |

## Execution Fidelity Score

Canonical formula (matches SKILL.md Phase 5 and completion-verifier agent):

| Dimension | Weight | Score | Calculation |
|---|---|---|---|
| Acceptance criteria verified | 35% | {score} | % independently verified with evidence |
| First-pass review rate | 25% | {score} | % of tasks passing all 3 review stages on first attempt |
| Drift rate | 20% | {score} | 100 minus (drift events / total tasks * 100) |
| Circuit breaker events | 10% | {score} | 100 minus (CB events * 10) |
| Cleanup items | 10% | {score} | 100 minus (cleanup items found * 5) |
| **Composite** | **100%** | **{score}/100** | Weighted sum. Target: 95+ |
