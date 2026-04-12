# Circuit Breaker Thresholds

Dual-threshold circuit breaker protecting against runaway execution loops.

## Tracked Metrics

| Metric | Warning (YELLOW) | Hard (RED) |
|---|---|---|
| Consecutive review failures (same task) | 2 | 4 |
| Total review failures (all tasks) | 5 | 10 |
| Consecutive BLOCKED (same task) | 1 | 2 |
| MAJOR_DRIFT count | 2 | 3 |

## States

### GREEN — Normal Operation

All counters below warning thresholds. Execution proceeds without interruption.

### YELLOW — Warning

Any single metric hits warning threshold. Response:
1. **Pause** execution immediately.
2. **Present** situation to user with current metric values.
3. **Offer** options: continue, adjust scope, abort.
4. **Resume** only on explicit user approval.

### RED — Hard Stop

Any single metric hits hard threshold. Response:
1. **Stop** all execution immediately.
2. **Commit** checkpoint for current progress if any work is salvageable.
3. **Present** full circuit breaker report to user.
4. **Require** user intervention before any further execution.

## State Transition Rules

```
GREEN → YELLOW : any metric reaches warning threshold
GREEN → RED    : any metric reaches hard threshold (can skip YELLOW)
YELLOW → GREEN : user approves continue AND metric drops below warning
YELLOW → RED   : any metric reaches hard threshold
RED → GREEN    : user explicitly resets after addressing root cause
```

## Counter Reset Rules

| Event | Reset Action |
|---|---|
| Task passes review | Reset consecutive review failures for that task to 0 |
| Task completes DONE | Reset consecutive BLOCKED for that task to 0 |
| User approves YELLOW continue | No reset — counters keep accumulating |
| User explicitly resets breaker | Reset ALL counters to 0 |
| New plan execution starts | Reset ALL counters to 0 |

Total review failures (cross-task) never reset except on explicit user reset or new plan.

## Escalation Protocol

### On YELLOW Trigger

```
CIRCUIT BREAKER: WARNING
Metric: {which metric}
Current: {value} / Warning: {threshold} / Hard: {hard threshold}
Task: T{N} - {Title}

Recent failure pattern:
- Attempt {X}: {failure reason}
- Attempt {X-1}: {failure reason}

Options:
1. Continue execution (counter keeps accumulating)
2. Skip this task, proceed to next
3. Adjust task scope and retry
4. Abort plan execution
```

### On RED Trigger

```
CIRCUIT BREAKER: HARD STOP
Metric: {which metric}
Current: {value} / Hard: {threshold}
Task: T{N} - {Title}

Failure history:
{complete list of failures that led here}

Progress checkpoint: {SHA or "none"}
Tasks completed: {N} / {TOTAL}

Recovery options:
1. Reset to last checkpoint and replan remaining tasks
2. Reset to pre-execution state
3. Accept current progress and stop
```

## Integration with Retry Protocol

Circuit breaker checks run AFTER each:
- Review failure (spec, quality, or integration)
- BLOCKED status return
- Drift detection MAJOR_DRIFT classification

Retry protocol (reflect-retry-escalate) operates WITHIN circuit breaker limits. If retry attempt 3 fails and breaker is still GREEN, breaker escalates to YELLOW.
