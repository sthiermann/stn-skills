# Task Anatomy

Rules governing valid tasks and steps in implementation plans. Plan verifier rejects plans violating these constraints.

## Task Validity Rules

| Rule | Constraint | Violation Action |
|------|-----------|-----------------|
| Estimated time | 2-5 minutes | Under 2 min: merge with adjacent task. Over 5 min: split. |
| Files modified | 1-3 files max | More than 3: split into smaller tasks. |
| Step count | 3-15 steps | Under 3: task too granular, merge. Over 15: too complex, split. |
| Verify step | At least one `verify_output` step per task | Reject task. |
| Test pairing | Every task producing new behavior has TDD cycle steps | Reject task. |
| Title format | Imperative verb phrase | Rewrite. E.g., "Add user validation to signup endpoint". |

## Step Validity Rules

| Rule | Constraint | Example |
|------|-----------|---------|
| Single action | Exactly ONE action type per step: `write_code`, `run_command`, `verify_output`, `read_file` | Never combine "write file and run tests" in one step. |
| `write_code` completeness | CREATE: full file content. MODIFY: complete diff with context lines. No abbreviations, no `...` | Placeholder scan catches violations. |
| `run_command` precision | Exact shell command + exact expected output pattern | `npm test -- --grep "auth"` expects `3 passing` |
| `verify_output` precision | Command AND expected output, both explicit | `curl localhost:3000/health` expects `{"status":"ok"}` |
| `if_unexpected` specificity | Specific diagnostic steps with exact commands | Never "investigate" or "debug". Always: "Run X, check Y, if Z then W." |

## TDD Cycle Within a Task

Standard six-step sequence for tasks introducing new behavior:

| Step | Action | Purpose |
|------|--------|---------|
| 1 | `read_file` | Read existing file (brownfield). Skip for greenfield. |
| 2 | `write_code` | Write failing test asserting desired behavior. |
| 3 | `verify_output` | Run test. Confirm failure with expected assertion message. |
| 4 | `write_code` | Write minimal implementation to pass test. |
| 5 | `verify_output` | Run test. Confirm pass. |
| 6 | `verify_output` | Run full test suite. Confirm zero regressions. |

Deviation allowed only when task is pure refactoring (no new behavior). Refactoring tasks: run existing tests before and after, confirm identical results.

## Task Dependency Rules

| Condition | Dependency Type | Example |
|-----------|----------------|---------|
| Two tasks modify same file | Sequential (hard edge) | T3 writes `auth.ts`, T5 modifies `auth.ts` -> T5 depends on T3 |
| Two tasks modify unrelated files | Parallel (no edge) | T2 writes `utils.ts`, T4 writes `config.ts` -> independent |
| Test task validates implementation task | Sequential (hard edge) | T6 tests T5 output -> T6 depends on T5 |
| Shared import dependency | Sequential if import target not yet created | T3 imports module T2 creates -> T3 depends on T2 |
| Type definition dependency | Sequential if consumer uses type producer defines | T4 uses `UserDTO` from T2 -> T4 depends on T2 |
| Schema/migration dependency | Sequential: migration before code using new schema | T3 creates table, T5 queries it -> T5 depends on T3 |
| Config dependency | Sequential if reader depends on setter | T2 sets env var, T4 reads it -> T4 depends on T2 |

**Max parallel width per wave:** 4 tasks. Beyond 4 increases context-switch overhead and merge conflict risk.

## Wave Construction

1. Topological sort of task DAG.
2. Group tasks with satisfied dependencies into waves.
3. Enforce max width of 4 per wave.
4. Each wave ends with recovery point: `git add {files} && git commit -m "plan checkpoint: wave {N}"`.

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
|-------------|---------|-----|
| Mega-task (>5 min) | Unrecoverable on failure | Split at file boundaries. |
| Micro-task (<2 min) | Overhead exceeds work | Merge with related task. |
| Orphan task (no verify step) | Silent failure | Add `verify_output` step. |
| Implicit dependency | Race condition in parallel execution | Add explicit DAG edge. |
| Vague `if_unexpected` | Blocks execution on failure | Replace with exact diagnostic commands. |
| Test-after (not TDD) | Late failure detection, wasted implementation effort | Reorder: test first, implement second. |
