# Task Implementer Status Codes

4 structured codes returned by task-implementer agent on completion.

## Code Definitions

| Code | Meaning | Required Evidence |
|---|---|---|
| `DONE` | Task completed, all acceptance criteria met | Per-criterion evidence table + verification command output |
| `DONE_WITH_CONCERNS` | Completed but implementer flagged potential issue | Evidence table + concern description + severity assessment |
| `BLOCKED` | Cannot complete as specified | What was attempted, what failed, what would unblock |
| `NEEDS_CONTEXT` | Missing information not in context package | Exactly what is needed and why |

**Critical rule**: `DONE` requires FRESH verification evidence from THIS execution. Never from memory or prior runs. Re-run verification commands and capture output at completion time.

## Output Formats

### DONE

```
STATUS: DONE
TASK: T{N} - {Title}

ACCEPTANCE CRITERIA EVIDENCE:
| # | Criterion | Verified | Evidence |
|---|-----------|----------|----------|
| 1 | {criterion text} | YES | {specific evidence: test output, command result, code reference} |
| 2 | {criterion text} | YES | {specific evidence} |

VERIFICATION COMMAND OUTPUT:
$ {command}
{actual stdout/stderr captured during this execution}
```

### DONE_WITH_CONCERNS

```
STATUS: DONE_WITH_CONCERNS
TASK: T{N} - {Title}

ACCEPTANCE CRITERIA EVIDENCE:
| # | Criterion | Verified | Evidence |
|---|-----------|----------|----------|
| 1 | {criterion text} | YES | {specific evidence} |

CONCERN:
  Description: {what the concern is}
  Severity: LOW | MEDIUM | HIGH
  Impact: {what could go wrong}
  Recommendation: {suggested action}

VERIFICATION COMMAND OUTPUT:
$ {command}
{actual stdout/stderr captured during this execution}
```

### BLOCKED

```
STATUS: BLOCKED
TASK: T{N} - {Title}

ATTEMPTED:
- {action taken and result}
- {action taken and result}

FAILURE REASON: {specific technical reason}

UNBLOCK REQUIREMENTS:
- {what is needed to proceed}
- {alternative approaches if any}
```

### NEEDS_CONTEXT

```
STATUS: NEEDS_CONTEXT
TASK: T{N} - {Title}

MISSING INFORMATION:
- {specific item needed}
  WHY: {why this is required to proceed}
  WHERE: {where this info likely lives}

PROGRESS SO FAR: {what was completed before hitting the gap}
```

## Rules

- Every `DONE` must have ALL criteria rows marked `YES` with non-empty evidence.
- Verification command output must be captured fresh — copy-paste from actual execution.
- `DONE_WITH_CONCERNS` still requires all criteria met; concern is advisory.
- `BLOCKED` must include at least one attempted action — never block without trying.
- `NEEDS_CONTEXT` must specify exactly what is missing; vague requests rejected.
