# Reflect-Retry-Escalate Protocol

Structured retry protocol with mandatory self-reflection between attempts.

## Protocol

### Attempt 1: Standard Dispatch

Dispatch task to implementer with original prompt and context package.

On success → proceed to review.
On failure → implementer generates structured self-reflection before retry.

### Self-Reflection Format

```
SELF-REFLECTION: T{N} Attempt {X}

WHAT WENT WRONG:
- {specific failure, not vague}

ROOT CAUSE:
- {underlying reason, not symptom}

WHAT I WOULD DO DIFFERENTLY:
- {concrete changed approach}

FAILED APPROACH:
- {what was tried} → {why it failed}
```

Must be structured — free-form narrative rejected. Each field mandatory.

### Attempt 2: Same Model + Enriched Context

Dispatch with:
- Original prompt
- Self-reflection from attempt 1 prepended
- Reviewer feedback (spec/quality/integration notes)
- Explicit instruction: "Do NOT repeat the failed approach"

On success → proceed to review.
On failure → escalate model capability.

### Attempt 3: Maximum Capability + Simplified Scope

Dispatch with:
- Most capable available model
- All prior reflections (attempts 1 and 2)
- Simplified task scope (non-essential acceptance criteria deprioritized)
- All reviewer feedback accumulated
- Explicit instruction: "Focus on core criteria only"

On success → proceed to review.
On failure → circuit breaker activates, escalate to user.

## Rules

### No Identical Retries

Each attempt MUST differ from previous. Minimum new information per retry:
- Attempt 2: self-reflection + reviewer feedback
- Attempt 3: model escalation + scope simplification + all reflections

### Best-Candidate Tracking

Track quality score of each attempt's output. If no attempt passes review threshold, promote best-scoring output. Present to user:

```
No attempt passed review. Best candidate:
  Attempt: {N}
  Spec: {score} | Quality: {score} | Integration: {score}
  Shortfall: {what didn't pass}
  
Options:
1. Accept best candidate as-is
2. Revert and replan task with narrower scope
3. Skip task, continue plan
```

### Hard Limits

- Max 3 attempts per subagent per task. No exceptions.
- Each attempt gets full context budget — no truncation of reflections.
- Timer: if single attempt exceeds 5 minutes wall-clock, terminate and count as failure.

### Loop Detection

Monitor agent actions within a single attempt. If agent produces identical action sequence 3 times with no state change:

1. Kill current attempt immediately.
2. Log loop detection event.
3. Count as failure, proceed to next attempt or circuit breaker.

**Detection mechanism:**
- Capture each tool call as `{tool_name, file_path, action_type}` tuple
- Compare last 3 action sequences (window of 3 consecutive tool calls)
- If all 3 sequences are identical: loop detected
- **State change** = different file written, different command output, or new file created
- **Stuck timeout**: if no state change for 2 minutes wall-clock, treat as loop

### Interaction with Circuit Breaker

Each failed attempt increments:
- Consecutive review failures (same task)
- Total review failures (all tasks)

Attempt 3 failure always triggers at minimum YELLOW (consecutive = 3 if prior attempts also failed). Circuit breaker may trigger RED before attempt 3 if cross-task totals are high.

## Failure Escalation Path

```
Attempt 1 fail → reflect → retry with enrichment
Attempt 2 fail → reflect → retry with escalation + simplification  
Attempt 3 fail → circuit breaker → user intervention
```
