<div align="center">

<img src="banner.svg" alt="Plan Writing — Zero-ambiguity implementation plans" width="100%">

# Plan Writing

**Zero-ambiguity implementation plans for AI-assisted development**

Atomic tasks. Complete code. DAG execution. Adversarial verification.

<p>
  <img src="https://img.shields.io/badge/phases-6_with_4_gates-purple?style=flat-square" alt="6 Phases with 4 Gates">
  <img src="https://img.shields.io/badge/plan_quality-score_90+-green?style=flat-square" alt="Plan Quality Score 90+">
  <img src="https://img.shields.io/badge/invoke-stn--skills:plan--writing-blue?style=flat-square" alt="Invoke: stn-skills:plan-writing">
</p>

</div>

Part of the [stn-skills](https://github.com/sthiermann/stn-skills) pipeline. Accepts design specs from brainstorming and produces plans for plan-execution. Use `/stn-skills:build-feature` for the full pipeline.

A skill that transforms requirements into implementation plans so detailed that execution becomes mechanical. Every task takes 2–5 minutes, every step contains complete code, and the entire plan is adversarially verified before delivery. Zero-placeholder enforcement rejects 40+ lazy shortcut patterns — no `...`, no `similar to above`, no `TODO` — ensuring plans are genuinely complete before execution begins.

Research measures 20–27% quality degradation in multi-turn generation without per-step verification. Complete plans prevent that.

**Typical duration:** Small (1–3 tasks): 5–10 min | Medium (4–8 tasks): 10–20 min | Large (9+ tasks): 20–35 min

---

## What It Does

- **Requirement extraction** — numbers requirements with testable assertions from any input (design spec, brainstorm output, direct request)
- **DAG decomposition** — atomic tasks with explicit dependencies, parallel wave grouping, and TDD enforcement
- **Complete step authoring** — every step with complete code and commands — zero placeholders, zero ellipsis, zero "similar to above"
- **Adversarial verification** — 7 checks computing a Plan Quality Score (must be 90+ to pass)
- **Single deliverable** — plan document with Mermaid DAG, traceability matrix, risk assessment, and rollback per task

---

## Quick Start

```
/stn-skills:plan-writing
```

Or use natural language: `Write a plan for this feature` | `Create an implementation plan` | `Break this down into tasks` | `How should I implement this` | `Plan this refactoring`

---

## How It Works

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
| Traceability matrix | Requirement → Task → Step → Verification (full chain) |
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
