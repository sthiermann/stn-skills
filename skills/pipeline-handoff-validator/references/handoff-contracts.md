# Handoff Contracts

Defines the exact contracts that artifacts must satisfy at each pipeline boundary.

## Contract A: Design Spec → Plan-Writing

The design spec is the input contract for plan-writing. Plan-writing's Phase 1 assumes these fields are present and populated.

### Required Sections

| Section | Source | Used by plan-writing |
|---------|--------|---------------------|
| Problem Statement | brainstorming Phase 1 | Requirement extraction (Phase 1, Step 2) |
| Success Criteria | brainstorming Phase 1 | Testable assertions for requirements |
| Scope Boundaries | brainstorming GATE 1 | Task constraints (Always/Ask/Never) |
| Selected Approach | brainstorming GATE 3 | Architecture guidance for codebase mapping |
| Acceptance Criteria | brainstorming Phase 5 | Per-requirement verification steps |
| Risk Register | brainstorming Phase 3 | Task risk seeds and rollback planning |
| Confirmed Assumptions | brainstorming Phases 1-4 | Constraint inputs for task decomposition |

### Quality Requirements

- **Testable assertions:** Each acceptance criterion must contain a specific, verifiable condition. Example of passing: "API returns 429 after 100 requests per 15-minute window." Example of failing: "Rate limiting works correctly."
- **Scope boundaries populated:** The Always/Ask First/Never table must have concrete entries, not generic placeholders.
- **Risks are specific:** Each risk must name a failure mode, not a category. "WebSocket connections fail under 10k concurrent users" not "scalability risk."
- **Assumptions resolved:** Any assumption marked "Unverified" that appears in the Selected Approach rationale is a gap.

---

## Contract B: Plan → Plan-Execution

The plan document is the input contract for plan-execution. Plan-execution's Phase 1 parses this document to build the task DAG and execution order.

### Required Sections

| Section | Source | Used by plan-execution |
|---------|--------|----------------------|
| Metadata | plan-writing Phase 6 | Plan Quality Score, complexity class |
| Requirements List | plan-writing Phase 1 | Traceability matrix baseline |
| File Structure Lock-In | plan-writing Phase 2 | Scope anchoring for drift detection |
| Task Definitions | plan-writing Phase 3-4 | DAG construction and task dispatch |
| Mermaid DAG | plan-writing Phase 3 | Execution order and parallel waves |
| Wave Plan | plan-writing Phase 3 | Parallel dispatch grouping |
| Traceability Matrix | plan-writing Phase 5 | End-to-end verification mapping |

### Quality Requirements

- **Plan Quality Score >= 90:** Scores below 90 indicate known defects that plan-execution will encounter.
- **Rollback blocks present:** Every task must have a rollback block because plan-execution checkpoints assume rollback capability.
- **Zero placeholder patterns:** Any placeholder in a code block causes the task-implementer to produce incomplete output or hallucinate missing details.
- **DAG is acyclic:** Cycles in the dependency graph cause plan-execution's topological sort to fail.
- **File Structure table complete:** Missing files cause drift detection false positives (unexpected extra files).
- **Requirements fully traced:** Orphan requirements cannot be verified in the completion report.

---

## Gap Remediation

When a gap is found, the validator suggests one of these remediation paths:

| Gap Location | Remediation |
|-------------|-------------|
| Missing spec section | Return to brainstorming, address in the relevant phase |
| Vague acceptance criteria | Rewrite criteria with specific, measurable assertions |
| Unverified critical assumption | Confirm with user before proceeding |
| Plan quality score < 90 | Return to plan-writing Phase 5 for rework |
| Placeholder in plan | Return to plan-writing Phase 4 step-author |
| Missing rollback block | Add rollback commands for the affected task |
| DAG cycle | Reorder task dependencies to break the cycle |
