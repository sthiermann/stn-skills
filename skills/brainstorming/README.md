<div align="center">

# Brainstorming

**Structured design exploration for Claude Code**

Multi-lens analysis. Adversarial review. Validated design specs.

<p>
  <img src="https://img.shields.io/badge/phases-6_with_4_gates-purple?style=flat-square" alt="Phases">
  <img src="https://img.shields.io/badge/cognitive_lenses-5-orange?style=flat-square" alt="Lenses">
  <img src="https://img.shields.io/badge/invoke-stn--skills:brainstorming-blue?style=flat-square" alt="Invoke">
</p>

</div>

A Claude Code skill that transforms vague requests into validated design specifications. Surfaces assumptions, explores genuinely distinct approaches through cognitive frameworks, scores them against weighted criteria, stress-tests the winner, and produces a spec ready for plan-writing.

---

## What It Does

- **Structured problem discovery** — one-at-a-time interview, assumption surfacing, scope boundaries
- **Multi-lens exploration** — parallel subagents apply inversion, stakeholder, constraint, temporal, and simplification lenses
- **Weighted evaluation** — 7-criteria decision matrix with mandatory justifications and risk pre-assessment
- **Adversarial review** — 11-type flaw taxonomy stress-tests the selected approach; blockers loop back
- **Spec output** — saves a complete design spec to `docs/specs/` ready for plan-writing

---

## Quick Start

```
/stn-skills:brainstorming
```

Or use natural language: `Brainstorm how to build this` | `Design this feature` | `Explore approaches for X` | `Think through the options` | `How should we build this?`

---

## How It Works

```mermaid
graph LR
    P1["Phase 1\nUnderstand"] --> G1{"GATE 1\nConfirm"}
    G1 -->|confirmed| P2["Phase 2\nExplore\n(parallel agents)"]
    P2 --> G2{"GATE 2\nReview"}
    G2 -->|confirmed| P3["Phase 3\nEvaluate"]
    P3 --> G3{"GATE 3\nSelect"}
    G3 -->|selected| P4["Phase 4\nAttack"]
    P4 --> P5["Phase 5\nAssemble"]
    P5 --> G4{"GATE 4\nApprove"}
    G4 -->|approved| P6["Phase 6\nSave Spec"]

    classDef phase fill:#2563eb,stroke:#1d4ed8,color:#fff,font-weight:bold
    classDef gate fill:#d97706,stroke:#b45309,color:#fff,font-weight:bold

    class P1,P2,P3,P4,P5,P6 phase
    class G1,G2,G3,G4 gate
```

| Phase | What happens |
|-------|-------------|
| **Phase 1** | Codebase recon, structured interview (max 6 questions), classify complexity, surface assumptions |
| **Gate 1** | User confirms problem statement, assumptions, and scope |
| **Phase 2** | Parallel subagents: problem decomposer + multi-lens explorer + assumptions surfacer |
| **Gate 2** | User reviews approaches, confirms new assumptions, eliminates non-starters |
| **Phase 3** | Decision matrix (7 criteria) with risk pre-assessment per approach |
| **Gate 3** | User selects approach, may adjust weights |
| **Phase 4** | Adversarial reviewer attacks selected approach; blockers must resolve before proceeding |
| **Phase 5** | Orchestrator assembles design spec from validated outputs |
| **Gate 4** | User approves final spec |
| **Phase 6** | Spec saved to `docs/specs/YYYY-MM-DD-<topic>-design.md` |

---

## Key Outputs

- **Design spec document** — problem, approach, rationale, risks, acceptance criteria
- **Decision matrix** — weighted scores with justifications for every approach considered
- **Risk register** — likelihood, impact, and mitigation per identified risk
- **Adversarial findings** — blockers resolved, warnings and notes carried into spec

---

## Adaptive Depth

| Dimension | Focused | Standard | Deep |
|-----------|---------|----------|------|
| Interview | 2-3 questions | 4-5 questions | 6 questions |
| Lenses | 1 | 3 | 5 |
| Approaches | 2 | 3 | 5+ |
| Flaw types | 3 | 7 | 11 |
| Typical scope | Single component | Multi-module feature | System / architectural |
