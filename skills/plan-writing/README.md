<div align="center">

# Plan Writing

**Zero-ambiguity implementation plans for Claude Code**

Atomic tasks. Complete code. DAG execution. Adversarial verification.

<p>
  <img src="https://img.shields.io/badge/phases-6_with_4_gates-purple?style=flat-square" alt="Phases">
  <img src="https://img.shields.io/badge/plan_quality-score_90+-green?style=flat-square" alt="Quality">
  <img src="https://img.shields.io/badge/invoke-stn--skills:plan--writing-blue?style=flat-square" alt="Invoke">
</p>

</div>

A Claude Code skill that transforms requirements into implementation plans so detailed that execution is mechanical. Every task is 2-5 minutes, every step has complete code, and the entire plan is adversarially verified before delivery.

---

## What It Does

- Extracts and numbers requirements with testable assertions from any input (design spec, brainstorm output, direct request)
- Decomposes work into a DAG of atomic tasks with explicit dependencies, parallel wave grouping, and TDD enforcement
- Authors every step with complete code and commands -- zero placeholders, zero ellipsis, zero "similar to above"
- Runs 7 adversarial verification checks and computes a Plan Quality Score (must be 90+ to pass)
- Delivers a single plan document with Mermaid DAG, traceability matrix, risk assessment, and rollback per task

---

## How to Invoke

```
/stn-skills:plan-writing
```

Or use natural language: `Write a plan for this feature` | `Create an implementation plan` | `Break this down into tasks` | `How should I implement this` | `Plan this refactoring`

---

## Workflow

```mermaid
graph LR
    P1["Phase 1\nInput Analysis"] --> G1{"GATE 1\nScope"}
    G1 -->|confirmed| P2["Phase 2\nCodebase Mapping"]
    P2 --> P3["Phase 3\nTask Decomposition"]
    P3 --> G2{"GATE 2\nDAG Review"}
    G2 -->|confirmed| P4["Phase 4\nStep Authoring"]
    P4 --> P5["Phase 5\nVerification"]
    P5 --> G3{"GATE 3\nResults"}
    G3 -->|"score >= 90"| P6["Phase 6\nDelivery"]
    G3 -->|"score < 90"| P4
    P6 --> G4{"GATE 4\nApproval"}
    G4 --> Done(("Done"))

    classDef phase fill:#2563eb,stroke:#1d4ed8,color:#fff,font-weight:bold
    classDef gate fill:#d97706,stroke:#b45309,color:#fff,font-weight:bold
    classDef done fill:#16a34a,stroke:#15803d,color:#fff,font-weight:bold

    class P1,P2,P3,P4,P5,P6 phase
    class G1,G2,G3,G4 gate
    class Done done
```

---

## Key Outputs

| Output | Location |
|--------|----------|
| Plan document | `.plan/plan-{YYYYMMDD}-{slug}.md` |
| Task DAG | Mermaid flowchart embedded in plan |
| Traceability matrix | R(N) -> T(M) -> S(K) -> verification |
| Quality score | Composite 0-100 across 5 dimensions |

---

## Plan Quality Score

| Dimension | Weight | What It Measures |
|-----------|--------|-----------------|
| Requirements coverage | 30% | Every requirement traced to tasks, steps, and verification |
| Placeholder contamination | 25% | Zero matches against 40+ placeholder patterns |
| Signature consistency | 20% | Identical signatures for same function/type across all steps |
| DAG completeness | 15% | No cycles, no parallel file conflicts, no orphan tasks |
| Convention compliance | 10% | All code follows project rules from CLAUDE.md |

**Composite score must be >= 90 to pass.** Plans scoring below 90 enter a rework cycle (max 2 attempts) before escalating to the user.
