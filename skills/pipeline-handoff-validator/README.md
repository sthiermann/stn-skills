<div align="center">

# Pipeline Handoff Validator

**Validate artifacts at pipeline boundaries before the next phase consumes them.**

Part of the [stn-skills](../../README.md) suite.

</div>

---

## What it Does

Catches incomplete design specs and defective plans before they propagate through the pipeline. Two validation modes cover both pipeline boundaries:

- **Mode A:** Design Spec → Plan-Writing (6 contract checks)
- **Mode B:** Plan → Plan-Execution (7 contract checks)

## Quick Start

```
/stn-skills:pipeline-handoff-validator
```

Or automatically between build-feature macro-phases.

## Contract Checks

### Mode A: Design Spec Validation

| Check | What it validates |
|-------|------------------|
| Structure | All required sections present |
| Testable criteria | Acceptance criteria have verifiable assertions |
| Scope boundaries | Always/Ask/Never table defined |
| Risk coverage | Risks documented with likelihood and mitigation |
| Assumptions resolved | No unverified critical assumptions |
| Approach clarity | Specific technology choices, not abstract patterns |

### Mode B: Plan Validation

| Check | What it validates |
|-------|------------------|
| Structure | All required plan sections present |
| Quality score | Plan Quality Score >= 90 |
| Rollback blocks | Every task has rollback commands |
| DAG integrity | No circular dependencies |
| File structure | Lock-In table with CREATE/MODIFY actions |
| Zero placeholders | No placeholder patterns in code blocks |
| Requirements traced | Every requirement maps to tasks |

## Output

Produces a **Handoff Compliance Table** with PASS/GAP per check and specific remediation suggestions for any gaps found.

## Typical Duration

1-3 minutes per validation.
