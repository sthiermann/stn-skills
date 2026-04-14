<div align="center">

<img src="banner.svg" alt="Build Feature — End-to-end pipeline" width="100%">

# Build Feature

**End-to-end design-to-delivery pipeline**

Brainstorm. Plan. Execute. One command.

<p>
  <img src="https://img.shields.io/badge/macro--phases-3-purple?style=flat-square" alt="3 Macro-Phases">
  <img src="https://img.shields.io/badge/total_gates-11-orange?style=flat-square" alt="11 Gates">
  <img src="https://img.shields.io/badge/invoke-stn--skills:build--feature-blue?style=flat-square" alt="Invoke: stn-skills:build-feature">
</p>

</div>

Part of the [stn-skills](https://github.com/sthiermann/stn-skills) pipeline. Orchestrates the full design-to-delivery workflow. Use individual skills for targeted work.

A meta-orchestrator skill that chains brainstorming, plan-writing, and plan-execution into a single pipeline. Takes a feature idea from initial exploration through DAG-based planning to verified, committed code — with user gates at every transition. One command, three research-backed techniques: multi-perspective design exploration, complete-before-execution planning, and independently verified implementation.

**Typical duration:** 30–60 min for a medium-complexity feature (3–5 tasks)

---

## What It Does

- **Design** — runs the full brainstorming workflow (6 phases, 4 gates) to produce a validated design spec
- **Plan** — feeds the spec into plan-writing (6 phases, 4 gates) to produce a zero-ambiguity implementation plan
- **Execute** — feeds the plan into plan-execution (7 phases, 3 gates) to deliver verified code with a fidelity score

---

## Quick Start

```
/stn-skills:build-feature
```

Or use natural language: `Build this feature` | `Implement end-to-end` | `Full pipeline for X` | `Design and build this`

---

## How It Works

```mermaid
graph LR
    M1["Design\n6 phases\n4 gates"] -->|"spec file"| V1{"Validate"}
    V1 --> M2["Plan\n6 phases\n4 gates"]
    M2 -->|"plan file"| V2{"Validate"}
    V2 --> M3["Execute\n7 phases\n3 gates"]
    M3 --> Done(("Done\n+ Fidelity Score"))

    classDef macro fill:#2563eb,stroke:#1d4ed8,color:#fff,font-weight:bold
    classDef validator fill:#d97706,stroke:#b45309,color:#fff,font-weight:bold
    classDef done fill:#7c3aed,stroke:#6d28d9,color:#fff,font-weight:bold

    class M1,M2,M3 macro
    class V1,V2 validator
    class Done done
```

---

## What Each Phase Produces

| Phase | Output | Location |
|---|---|---|
| Design | Validated design spec | `docs/specs/YYYY-MM-DD-<topic>-design.md` |
| Plan | DAG-based implementation plan | `.plan/plan-{YYYYMMDD}-{slug}.md` |
| Execute | Completion report + fidelity score | Printed to session |

All artifacts persist on disk. The pipeline is resumable — if a session ends after Design, start Plan in a new session by pointing to the spec file.

---

## When to Use This vs Individual Skills

| Scenario | Use |
|---|---|
| Building a complete feature from scratch | **build-feature** |
| Exploring options without committing to build | brainstorming |
| You already have a spec and need a plan | plan-writing |
| You already have a plan and need to execute | plan-execution |
| You want to exit after design or planning | **build-feature** (exit at any gate) |
