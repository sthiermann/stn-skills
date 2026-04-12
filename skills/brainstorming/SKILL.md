---
name: brainstorming
description: >-
  Invoke for feature design, approach exploration, or architectural decisions.
  Covers multi-lens analysis, weighted evaluation, adversarial review.
  Triggers: "brainstorm", "design", "explore approaches", "how should we build".
---

# Brainstorming

## Overview

Structured exploration that converts ambiguous requests into validated design specs. Surfaces assumptions, generates genuinely distinct approaches through multi-lens cognitive frameworks, scores them against weighted criteria, stress-tests the winner through adversarial review, and produces a spec document ready for plan-writing.

This skill implements tree-structured exploration — generating multiple distinct approaches in parallel (branching), evaluating each through weighted criteria (scoring), and pruning via adversarial review (selection). Research shows tree-structured search with execution feedback at each node consistently outperforms single-path linear generation for complex design problems.

**Core principle:** Every design decision requires explored alternatives. Assumptions without confirmation are landmines.

**Announce:** "I'm using the brainstorming skill to explore this problem systematically before implementation."

## The Iron Law

```
EVERY DESIGN DECISION REQUIRES EXPLORED ALTERNATIVES.
ASSUMPTIONS WITHOUT CONFIRMATION ARE LANDMINES.
```

If a design proceeds with only one approach considered — the design is underexplored. If an assumption is treated as fact without user confirmation — the design is built on sand.

## Modernization Mandate

```
USE ONLY CURRENT APIs, PATTERNS, AND BEST PRACTICES.
EVERY APPROACH MUST REFLECT THE STATE OF THE ART.
DEPRECATED PATTERNS ARE AUTOMATICALLY DISQUALIFIED.
```

This mandate applies to every phase:
- **Phase 2:** Approaches using deprecated APIs or legacy patterns are flagged by the multi-lens-explorer and assumptions-surfacer
- **Phase 3:** The "Modernity" criterion (12% weight) scores how future-proof each approach is. Approaches relying on deprecated patterns score 1/5.
- **Phase 4:** The adversarial reviewer checks for `Legacy_Pattern` flaws (flaw type #11). Any design decision relying on deprecated or outdated patterns is a Blocker.
- **Phase 6:** The design spec marks any approach that uses legacy code as rejected in the "Alternatives Considered" section with explicit reasoning.

## When to Use

```mermaid
graph TD
    A{"Creative work\nrequested?"} -->|yes| B{"Problem\nunderstood?"}
    A -->|no| C["Not in scope —\nuse a different skill"]
    B -->|yes| D{"Multiple approaches\npossible?"}
    B -->|no| E["Run brainstorming\n(start at Phase 1)"]
    D -->|yes| F["Run brainstorming\n(full workflow)"]
    D -->|no| G["Problem too constrained —\nproceed directly"]
```

**Use this skill when:**
- Designing a new feature, component, or system
- Exploring how to modify existing behavior
- Evaluating multiple technical approaches
- Making architectural decisions with trade-offs
- User asks to think through, brainstorm, or explore options

**Not designed for:**
- Fixing a known bug with an obvious solution — fix it directly
- Applying a prescribed pattern with no design choice — execute it
- Refactoring where the target state is already defined — plan and execute

---

## Adaptive Depth

Complexity classification determines how much exploration each phase performs. Classify during Phase 1 based on scope, ambiguity, and impact.

| Dimension | Focused | Standard | Deep |
|-----------|---------|----------|------|
| Interview questions | 2-3 | 4-5 | 6 |
| Cognitive lenses | 1 | 3 | 5 |
| Approaches generated | 2 | 3 | 5+ |
| Sub-problem depth | Shallow (max 5) | Standard | Second-order + cross-cutting |
| Flaw types checked | 3 (highest-risk) | 7 (core + scope) | All 11 |
| Agent dispatches | 2 | 4 | 5 |
| Typical scope | Single function/component | Feature spanning modules | System-level or architectural |

---

## The Six Phases

Complete each phase before proceeding. Four user gates ensure alignment.

```mermaid
graph TD
    P1["Phase 1: Problem Understanding\n(recon, interview, classify)"] --> G1{"GATE 1:\nProblem Confirmation"}
    G1 -->|user confirms| P2["Phase 2: Multi-Lens Exploration\n(dispatch parallel subagents)"]
    P2 --> G2{"GATE 2:\nExploration Review"}
    G2 -->|user confirms| P3["Phase 3: Approach Evaluation\n(decision matrix + risk)"]
    P3 --> G3{"GATE 3:\nApproach Selection"}
    G3 -->|user selects| P4["Phase 4: Adversarial Review\n(stress-test selected approach)"]
    P4 -->|blockers found| P4R["Resolve blockers\n(loop back)"]
    P4R --> P4
    P4 -->|no blockers| P5["Phase 5: Spec Assembly"]
    P5 --> G4{"GATE 4:\nFinal Spec Approval"}
    G4 -->|user approves| P6["Phase 6: Write Spec Document\n(save to docs/specs/)"]

    classDef phase fill:#2563eb,stroke:#1d4ed8,color:#fff
    classDef gate fill:#d97706,stroke:#b45309,color:#fff
    classDef done fill:#16a34a,stroke:#15803d,color:#fff

    class P1,P2,P3,P4,P4R,P5,P6 phase
    class G1,G2,G3,G4 gate
```

---

### Phase 1: Problem Understanding

Before generating any approach, understand the problem completely.

**1. Codebase reconnaissance.** Scan for relevant code, patterns, dependencies, and constraints. Identify tech stack, architectural patterns, and existing conventions that any solution must respect.

**2. Structured interview.** Ask questions ONE AT A TIME. Maximum 6 questions total. Each question targets a specific gap in understanding. Do not batch questions — wait for the answer before asking the next.

Question categories:
- **Intent** — What outcome does the user want?
- **Constraints** — What cannot change?
- **Context** — Who/what is affected?
- **Scale** — How much data, how many users, how often?
- **Priority** — What matters most when trade-offs arise?
- **Integration** — What adjacent systems are involved?

**3. Classify complexity:**

| Signal | Focused | Standard | Deep |
|--------|---------|----------|------|
| Scope | Single component | Feature across modules | System/architectural |
| Ambiguity | Low — clear goal | Medium — some unknowns | High — multiple valid framings |
| Impact | Local | Cross-module | Cross-system or irreversible |
| Stakeholders | 1 | 2-3 | 4+ |

**4. Surface assumptions.** List every assumption about the problem, codebase, or solution space. Mark each: Confirmed (user stated), Inferred (derived from code), or Unverified (needs confirmation).

**5. Define scope boundaries:**

| Category | Content |
|----------|---------|
| **Always Do** | Actions within agreed scope, no approval needed |
| **Ask First** | Actions that could affect adjacent systems, require approval |
| **Never Do** | Hard constraints, explicitly excluded actions |

---

### GATE 1: Problem Confirmation

Present to the user:
- Problem statement (1-2 sentences)
- Complexity classification with justification
- All assumptions with their status (Confirmed / Inferred / Unverified)
- Scope boundaries (Always Do / Ask First / Never Do)
- Success criteria (testable outcomes)

Ask: **"Confirm this problem statement, assumptions, and scope — or correct anything before I explore approaches."**

The user must explicitly confirm or deny each unverified assumption. Proceeding with unaddressed assumptions violates the Iron Law.

---

### Phase 2: Multi-Lens Exploration

Dispatch parallel subagents to explore the problem from multiple angles simultaneously.

**Context package for every agent:**
```
PROBLEM_STATEMENT:      {{PROBLEM_STATEMENT}}
SUCCESS_CRITERIA:       {{SUCCESS_CRITERIA}}
CONFIRMED_ASSUMPTIONS:  {{CONFIRMED_ASSUMPTIONS}}
SCOPE_BOUNDARIES:       {{SCOPE_BOUNDARIES}}
COMPLEXITY_CLASS:       {{COMPLEXITY_CLASS}}
CODEBASE_CONTEXT:       {{CODEBASE_CONTEXT}}
```

**Dispatch table:**

| Agent | Prompt file | Focus | Dispatch |
|-------|------------|-------|----------|
| Problem Decomposer | `agents/problem-decomposer.md` | Break into sub-problems, map dependencies, generate distinct approaches | Always |
| Multi-Lens Explorer | `agents/multi-lens-explorer.md` | Apply cognitive lenses from `references/cognitive-lenses.md` | Always |
| Assumptions Surfacer | `agents/assumptions-surfacer.md` | Deep assumption mining beyond Phase 1 surface pass | Standard + Deep |

**Dispatch count by complexity:**
- **Focused:** 2 agents (Problem Decomposer + Multi-Lens Explorer)
- **Standard:** 3 agents (all three)
- **Deep:** 3 agents (all three, with expanded lens count and deeper decomposition)

Dispatch all agents in a single message to maximize parallelism. Each agent works independently.

**Synthesis.** After all agents complete, the orchestrator merges results:
1. Deduplicate approaches that are variations of the same strategy
2. Merge sub-problem maps with lens insights
3. Consolidate newly surfaced assumptions
4. Produce a unified list of genuinely distinct approaches

---

### GATE 2: Exploration Review

Present to the user:
- Sub-problem decomposition with dependency map
- All distinct approaches with summaries and differentiators
- Newly surfaced assumptions (if any) requiring confirmation
- Lens insights that challenged initial framing

Ask: **"Review these approaches. Confirm new assumptions, eliminate any non-starters, or request deeper exploration of a specific direction."**

The user may eliminate approaches, surface new constraints, or request additional exploration. Non-starters are removed before evaluation.

---

### Phase 3: Approach Evaluation

Dispatch the approach-evaluator subagent.

**Context package:**
```
PROBLEM_STATEMENT:      {{PROBLEM_STATEMENT}}
SUCCESS_CRITERIA:       {{SUCCESS_CRITERIA}}
CONFIRMED_ASSUMPTIONS:  {{CONFIRMED_ASSUMPTIONS}}
SCOPE_BOUNDARIES:       {{SCOPE_BOUNDARIES}}
COMPLEXITY_CLASS:       {{COMPLEXITY_CLASS}}
CODEBASE_CONTEXT:       {{CODEBASE_CONTEXT}}
SURVIVING_APPROACHES:   {{APPROACHES_AFTER_GATE_2}}
SUB_PROBLEMS:           {{SUB_PROBLEM_MAP}}
```

**Agent:** `agents/approach-evaluator.md`

The evaluator scores each surviving approach against 7 weighted criteria using the decision matrix from `references/decision-matrix-template.md`:

| Criterion | Default Weight | Definition |
|-----------|---------------|------------|
| Complexity | 18% | Implementation effort and cognitive load |
| Time-to-ship | 13% | Calendar time to production |
| Risk | 18% | What can go wrong and how badly |
| Extensibility | 13% | Adapts to future requirements |
| Alignment | 13% | Matches existing patterns and conventions |
| Maintainability | 13% | Long-term ownership cost |
| Modernity | 12% | Uses current best practices |

Every score requires a one-sentence justification. Scores without justification are invalid.

<details>
<summary>Example: Decision matrix for "Add user notification system"</summary>

| Criterion (Weight) | A: WebSocket Push | B: Polling + SSE | C: Third-party Service |
|---|---|---|---|
| Complexity (18%) | 7 — Requires connection lifecycle mgmt | 5 — Two simple mechanisms combined | 3 — External dependency but less code |
| Time-to-ship (13%) | 5 — Socket infra setup takes time | 7 — Both patterns well-known in team | 8 — SDK integration only |
| Risk (18%) | 6 — Scaling WebSockets at load is proven | 7 — Graceful degradation built in | 4 — Vendor lock-in, outage dependency |
| Extensibility (13%) | 8 — Bidirectional, supports future features | 5 — One-directional only | 6 — Limited to vendor capabilities |
| Alignment (13%) | 4 — No existing WebSocket usage in project | 8 — Matches current REST-based patterns | 3 — New vendor dependency pattern |
| Maintainability (13%) | 5 — Connection state adds complexity | 7 — Stateless, easy to debug | 6 — Vendor docs required |
| Modernity (12%) | 8 — Current best practice for real-time | 6 — Adequate but not optimal for RT | 7 — Managed service, auto-updated |

**Weighted totals:** A: 6.22 | B: 6.43 | C: 5.10
**Recommendation:** Approach B (Polling + SSE) — best alignment with existing patterns and lowest risk.

</details>

**Risk pre-assessment.** For each approach, identify top 3 risks: specific risk, likelihood (H/M/L), impact (H/M/L), and mitigation strategy. Answer: "What happens if this approach fails halfway through?"

**Tie-breaking:** If two approaches score within 5% weighted total, risk breaks the tie (lower risk wins). If risk is also tied, complexity breaks the tie (lower complexity wins).

---

### GATE 3: Approach Selection

Present to the user:
- Complete decision matrix with scores and justifications
- Risk pre-assessment per approach
- Recommended approach with reasoning
- Runner-up with specific trade-off comparison

Ask: **"Select an approach, or adjust the criteria weights and I'll re-score."**

The user may adjust weights (must still sum to 100%, minimum 5% per criterion), override the recommendation, or request a hybrid of approaches.

---

### Phase 4: Adversarial Review

Dispatch the adversarial-reviewer subagent to stress-test the selected approach.

**Context package:**
```
SELECTED_APPROACH:      {{SELECTED_APPROACH}}
PROBLEM_STATEMENT:      {{PROBLEM_STATEMENT}}
CONFIRMED_ASSUMPTIONS:  {{CONFIRMED_ASSUMPTIONS}}
SCOPE_BOUNDARIES:       {{SCOPE_BOUNDARIES}}
RISK_ASSESSMENT:        {{RISK_ASSESSMENT_FOR_SELECTED}}
CODEBASE_CONTEXT:       {{CODEBASE_CONTEXT}}
```

**Agent:** `agents/adversarial-reviewer.md`

The reviewer checks against the 11-type flaw taxonomy from `references/reasoning-flaw-catalog.md`. Depth scales with complexity:
- **Focused:** 3 flaw types (highest-risk)
- **Standard:** 7 flaw types (core reasoning + scope)
- **Deep:** All 11 flaw types

Each finding is classified:
- **Blocker** — must resolve before spec. Loop back, address the flaw, re-submit.
- **Warning** — must address during implementation.
- **Note** — awareness item.

**Visible output requirement:** The adversarial-reviewer presents a structured flaw assessment table:

| Flaw Type | Verdict | Classification | Detail |
|-----------|---------|---------------|--------|
| Legacy_Pattern | Clean/Finding | — / Blocker/Warning/Note | [evidence or "no legacy patterns detected"] |
| Assumptions_Unchecked | Clean/Finding | ... | ... |
| ... (all checked types per complexity class) |

This table is displayed to the user before proceeding. Findings without this table are incomplete.

**Blocker resolution loop:** If blockers are found, present them to the user, resolve each one (modify the approach, add constraints, or change scope), then re-dispatch the adversarial reviewer on the updated approach. Repeat until zero blockers remain.

---

### Phase 5: Spec Assembly

The orchestrator assembles the design spec from all prior phases. No new analysis — pure assembly from validated outputs.

Spec structure follows `references/design-spec-template.md`:
- Problem statement and success criteria
- Confirmed assumptions with evidence
- Scope boundaries
- Selected approach with rationale
- Decision matrix and alternative comparison
- Risk register
- Adversarial review findings (warnings + notes)
- Acceptance criteria with verification methods

Every acceptance criterion must include an exact verification method (command, test, or check). "Verify it works" is not a verification method.

---

### GATE 4: Final Spec Approval

Present the complete design spec to the user.

Ask: **"Review this design spec. Approve to save, or request changes."**

Changes loop back to the relevant phase. The spec is not saved until the user explicitly approves.

---

### Phase 6: Write Spec Document

Save the approved spec to `docs/specs/YYYY-MM-DD-<topic>-design.md` using the format from `references/design-spec-template.md`.

The file name uses the current date and a kebab-case topic derived from the problem statement. If `docs/specs/` does not exist, create it.

---

## Red Flags — STOP and Correct

If you catch yourself:
- Asking multiple questions in a single message during the interview
- Generating approaches without completing the structured interview
- Scoring the decision matrix without one-sentence justifications per score
- Proceeding past any gate without explicit user confirmation
- Proceeding with unverified assumptions that the user has not confirmed or denied
- Writing the spec before completing adversarial review
- Adversarial reviewer praising the design instead of attacking it
- Producing acceptance criteria without specific verification methods

**ALL of these mean: STOP. Return to the correct phase and do it properly.**

---

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "This is too simple for brainstorming" | Classify as Focused and use the lightweight path. Simple problems still benefit from assumption surfacing. |
| "The user already knows what they want" | They know the outcome, not the approach. Explore alternatives — the first idea is rarely the best. |
| "There's only one way to do this" | Apply the Inversion Lens. If you truly cannot find alternatives, the problem is over-constrained — surface that. |
| "The interview is slowing things down" | Rework from missed requirements costs 10x more than 3 questions up front. |
| "I can skip adversarial review for simple changes" | Simple changes in complex codebases cause cascading failures. The Focused path already scales review down. |
| "The user approved it, so assumptions are fine" | User approval of the problem statement does not confirm individual assumptions. Each must be addressed explicitly. |
| "I'll note the risks in the spec and move on" | Unmitigated risks in the spec become unmitigated risks in production. Every risk needs a mitigation action. |
| "Weights don't matter for obvious choices" | Default weights encode specific trade-off preferences. Making them visible prevents hidden bias. |
