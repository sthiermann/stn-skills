# Reasoning Flaw Catalog

11-type taxonomy for adversarial design review. The reviewer's job is to attack — find every flaw, gap, and weakness.

## Classification

Each finding is classified:
- **Blocker** — Must resolve before proceeding to spec. Design cannot ship with this flaw.
- **Warning** — Should address during implementation. Risk increases if ignored.
- **Note** — Awareness item. No action required but worth tracking.

## Flaw Types

| # | Type | Definition | Detection Signal |
|---|---|---|---|
| 1 | Missing_Assumption | Critical assumption never surfaced or confirmed | "This works because..." without evidence |
| 2 | Invalid_Precondition | Design depends on something that may not be true | "Given that X..." where X is unverified |
| 3 | Unjustified_Inference | Conclusion drawn without sufficient evidence | Leap from observation to conclusion |
| 4 | Circular_Reasoning | Justification references itself | "Do X because X is the right approach" |
| 5 | Contradiction | Two parts of the design conflict | Requirement A implies not-B, but B required |
| 6 | Overgeneralization | Claim applied too broadly from limited evidence | "This always works" without edge case analysis |
| 7 | Scope_Creep | Design exceeds agreed scope boundaries | Changes outside NEVER DO list |
| 8 | Missing_Error_Path | No handling for failure scenarios | Happy path only, no error consideration |
| 9 | Missing_Edge_Case | Input or state not considered | Boundary values, empty states, concurrency |
| 10 | Integration_Gap | Break in adjacent system not addressed | Shared interface changes without consumer update |
| 11 | Legacy_Pattern | Design relies on deprecated or outdated patterns | Using old APIs, patterns with known modern replacements |

## Adversarial Review Depth by Complexity

| Complexity | Flaw Types Checked |
|---|---|
| Focused | 1, 2, 8 (top 3 most impactful) |
| Standard | 1-7 (core reasoning + scope) |
| Deep | All 11 (comprehensive) |

## Output Format

For each finding:
- **Type:** {flaw type from table above}
- **Classification:** Blocker / Warning / Note
- **Location:** Which section of the design is affected
- **Description:** What the flaw is (specific, not vague)
- **Recommendation:** How to fix it (actionable, not "think about it")
