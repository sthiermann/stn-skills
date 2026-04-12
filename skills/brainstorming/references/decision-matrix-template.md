# Decision Matrix Template

Structured evaluation framework for comparing approaches. Every score requires written justification — no numbers without reasoning.

## Default Criteria

| Criterion | Default Weight | Definition |
|---|---|---|
| Complexity | 18% | Implementation effort and cognitive load. 1=trivial, 5=requires deep expertise |
| Time-to-ship | 13% | Calendar time to production. 1=weeks, 5=hours |
| Risk | 18% | What can go wrong and how badly. 1=catastrophic potential, 5=nearly risk-free |
| Extensibility | 13% | Adapts to future requirements. 1=rigid, 5=naturally extensible |
| Alignment | 13% | Matches existing patterns and conventions. 1=foreign to codebase, 5=natural fit |
| Maintainability | 13% | Long-term ownership cost. 1=constant attention needed, 5=set and forget |
| Modernity | 12% | Uses current best practices. 1=legacy patterns, 5=state-of-the-art |

Weights must sum to 100%. Minimum weight per criterion: 5%. User can adjust at GATE 3.

## Scoring Rubric

| Score | Meaning |
|---|---|
| 1 | Significantly negative — major concern |
| 2 | Below average — notable weakness |
| 3 | Acceptable — meets minimum bar |
| 4 | Good — clear strength |
| 5 | Excellent — significant advantage |

## Evaluation Rules

1. Every score MUST include a one-sentence justification
2. Scores without justification are invalid
3. If two approaches score within 5% weighted total, risk breaks the tie (lower risk wins)
4. If risk is also tied, simplicity breaks the tie (lower complexity wins)

## Output Format

| Criterion | Weight | Approach A | Approach B | Approach C |
|---|---|---|---|---|
| Complexity | 18% | 4 — Single module change | 2 — Requires 3 services | 3 — New abstraction layer |
| ... | ... | ... | ... | ... |
| **Weighted Total** | 100% | **3.82** | **3.15** | **3.47** |

## Risk Pre-Assessment (per approach)

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| {specific risk} | H/M/L | H/M/L | {specific action} |

Include top 3 risks per approach. Answer: "What happens if this approach fails halfway through?"
