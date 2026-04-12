# Checkpoint Protocol

Exact git checkpoint procedure after each task passes review and drift detection.

## 5 Steps

### Step 1: Pre-Commit Verification

Run task's verification command. Captures fresh evidence.

```bash
{task.verification_command}
```

- Pass → proceed to step 2.
- Fail → do NOT commit. Return to implementer with failure output. Increment review failure counter.

### Step 2: Selective Staging

Stage only files listed in task scope.

```bash
git add path/to/file1.ts path/to/file2.ts
```

**Never use `git add -A` or `git add .`** — prevents accidental inclusion of debug artifacts, temp files, or unrelated changes.

If drift detection approved extra files, include those in staging list.

### Step 3: Structured Commit Message

```bash
git commit -m "$(cat <<'EOF'
plan-exec: T{N} - {Title}

Task {N}/{TOTAL}: {description}
Acceptance criteria: {count} met
Review: spec PASS, quality PASS, integration PASS
EOF
)"
```

If MINOR_DRIFT was detected, append to message body:

```
Drift: MINOR — {brief description of deviation}
```

### Step 4: State File Update

Write checkpoint SHA to state tracking file.

```json
{
  "plan_id": "{plan_id}",
  "starting_sha": "{sha_before_execution}",
  "current_task": {N},
  "total_tasks": {TOTAL},
  "checkpoints": [
    {
      "task": 1,
      "sha": "{commit_sha}",
      "timestamp": "{ISO-8601}",
      "status": "DONE",
      "drift": "CLEAN"
    }
  ],
  "circuit_breaker": {
    "state": "GREEN",
    "consecutive_review_failures": 0,
    "total_review_failures": 0,
    "consecutive_blocked": 0,
    "major_drift_count": 0
  }
}
```

Location: `.claude/plan-execution-state.json`

### Step 5: Post-Commit Check

```bash
git status
```

- Clean working tree → checkpoint complete.
- Unexpected unstaged changes → warn user:

```
WARNING: Unstaged changes detected after checkpoint.
Files: {list}
These were NOT part of the committed task scope.
Action: review before proceeding to next task.
```

## Recovery Procedures

### Recover to Specific Checkpoint

```bash
git reset --hard {checkpoint_SHA}
```

Restores to state after task N completed. All subsequent task work lost.

### Recover to Pre-Execution State

```bash
git reset --hard {starting_SHA}
```

Restores to state before plan execution began. All task work lost.

### Recovery Rules

- **Never execute recovery automatically.** Always present to user first.
- Show what will be lost (list of tasks and their checkpoint SHAs).
- Require explicit confirmation.
- After recovery, update state file to reflect new position.
- Circuit breaker counters persist through recovery (not reset).
- **If uncommitted changes exist at recovery point:** present user with options: (a) stash changes with `git stash`, (b) commit as WIP with `git commit -m "WIP: in-progress work before recovery"`, (c) discard with `git checkout .`. Never silently discard uncommitted work.

### Partial Recovery

If tasks T1-T5 completed and T6 failed:
- Can recover to any checkpoint T1 through T5.
- Recommend recovering to T5 (latest good state) unless earlier task is suspected.
- After recovery, replan from recovery point forward.
