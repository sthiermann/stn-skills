# Cognitive Lenses

Five structured frameworks for exploring a problem from fundamentally different angles. Each lens forces a specific type of insight that default thinking misses.

## Lens Selection

Select lenses based on complexity class:
- **Focused**: 1 lens (most relevant to the problem)
- **Standard**: 3 lenses
- **Deep**: all 5 lenses

## 1. Inversion Lens

**Core question:** "What guarantees this fails?"

**Process:**
1. List 5-10 conditions that would guarantee failure
2. For each failure condition, define the inverse as a design requirement
3. Prioritize: which failure modes are most likely? Those inversions are highest-priority requirements

**Output format:**
| Failure Mode | Likelihood | Inverted Requirement | Priority |
|---|---|---|---|

**Best for:** Problems that seem straightforward — surfaces hidden risks

## 2. Stakeholder Lens

**Core question:** "What does success look like for each consumer?"

**Process:**
1. Identify all stakeholders: end user, developer maintaining this, ops/deploy team, adjacent system owners, future developers
2. For each stakeholder: define success criteria, pain points, constraints
3. Identify conflicts between stakeholder needs
4. Resolve conflicts with explicit trade-off decisions

**Output format:**
| Stakeholder | Success Looks Like | Pain Points | Constraints | Conflicts |
|---|---|---|---|---|

**Best for:** Features with multiple consumers or cross-team impact

## 3. Constraint Removal Lens

**Core question:** "What would the ideal solution be without constraint X?"

**Process:**
1. List every constraint (technical, time, scope, compliance, compatibility)
2. Remove each constraint one at a time
3. Design the ideal solution without that constraint
4. Measure the gap between ideal and constrained
5. For the largest gaps: explore creative solutions that reduce the gap without violating the constraint

**Output format:**
| Constraint | Ideal Without It | Gap Size | Creative Bridge |
|---|---|---|---|

**Best for:** Over-constrained problems where no good option exists

## 4. Temporal Lens

**Core question:** "Does this decision age well?"

**Process:**
1. Project the design to three horizons: 1 week (does it work?), 3 months (does it scale?), 1 year (does it still make sense?)
2. Classify each decision as reversible or irreversible
3. For irreversible decisions: demand higher confidence before committing
4. For reversible decisions: optimize for speed, not perfection

**Output format:**
| Decision | Reversible? | 1 Week | 3 Months | 1 Year | Confidence Needed |
|---|---|---|---|---|---|

**Best for:** Architectural decisions, technology choices, API design

## 5. Simplification Lens

**Core question:** "What is the absolute simplest solution?"

**Process:**
1. Design the simplest possible solution that handles only the most common case
2. Add requirements back one at a time, in order of importance
3. Note the complexity cost of each added requirement
4. Identify requirements whose complexity cost is disproportionate to their value
5. Challenge those requirements: are they truly necessary?

**Output format:**
| Requirement | Added Complexity | Value | Keep/Challenge |
|---|---|---|---|

**Best for:** Scope creep prevention, over-engineered designs, MVP definition
