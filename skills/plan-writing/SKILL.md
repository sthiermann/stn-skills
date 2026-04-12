---
name: plan-writing
description: >-
  Create comprehensive, zero-ambiguity implementation plans structured as
  Directed Acyclic Graphs of atomic tasks. Each task is 2-5 minutes with
  complete code and commands (no placeholders), verification per step,
  risk assessment, and rollback strategy. Plans are so detailed that
  execution is mechanical. Works with any programming language and framework.
  Use when translating design specs or requirements into executable plans.
  Triggers on "write a plan", "create implementation plan", "plan this",
  "break this down", "how should I implement", or any request for actionable
  work breakdown.
---

# Plan Writing

## Overview

Transform requirements, design specs, or brainstorm outputs into zero-ambiguity implementation plans. Dispatches specialized agents to decompose work into a DAG of atomic tasks, author complete steps with full code, and adversarially verify the result. Output is a single plan document so detailed that execution is mechanical.

**Core principle:** Every step contains complete code or complete commands. If a human must think during execution, the plan failed.

**Announce:** "I'm using the plan-writing skill to create a comprehensive implementation plan."

## The Iron Laws

```
IRON LAW 1: ZERO PLACEHOLDERS
EVERY STEP CONTAINS COMPLETE CODE OR COMPLETE COMMANDS.
"TBD", "TODO", "SIMILAR TO ABOVE" ARE PLAN FAILURES.

IRON LAW 2: DAG, NOT LIST
TASKS FORM A DIRECTED ACYCLIC GRAPH.
EVERY TASK DECLARES ITS EXACT DEPENDENCIES AND OUTPUTS.
```

Iron Law 1: Every `write_code` step contains the full file content (CREATE) or a complete diff with context lines (MODIFY). Every `run_command` step contains the exact shell command and expected output. Ellipsis, abbreviations, and "similar to above" are rejected by the placeholder detector. See `references/placeholder-detector-rules.md` for the exhaustive pattern catalog.

Iron Law 2: Tasks declare `depends_on` and `blocks` fields. Independent tasks run in parallel waves. Same-file modifications enforce sequential ordering. The DAG is verified by topological sort. See `references/task-anatomy.md` for dependency rules.

## Modernization Mandate

```
ALL CODE IN EVERY STEP MUST USE CURRENT APIs AND BEST PRACTICES.
NO DEPRECATED PATTERNS. NO LEGACY COMPATIBILITY SHIMS. NO BACKWARD-COMPAT CODE.
IF EXISTING CODE USES DEPRECATED PATTERNS, THE PLAN MUST MODERNIZE THEM.
```

This mandate is enforced at every stage:
- **Phase 2 (Codebase Mapping):** Cartographer flags deprecated patterns found in existing code. These become modernization tasks in Phase 3.
- **Phase 4 (Step Authoring):** Step-author writes only current-generation code. All agents carry the Modernization Mandate in their prompts.
- **Phase 5 (Verification):** Plan-verifier checks convention compliance (check #5) — deprecated API usage in any code block is a defect.
- **Plan Output:** If existing code touched by the plan uses deprecated patterns, the plan includes modernization steps that replace them with current equivalents. No plan may leave deprecated code in files it touches.

## When to Use

```mermaid
graph TD
    A{"Have requirements\nor design spec?"} -->|yes| B{"Multi-step\nimplementation?"}
    A -->|no| C["Not in scope —\nclarify requirements first"]
    B -->|yes| D{"Complexity\nestimate?"}
    B -->|no| E["Not in scope —\njust implement directly"]
    D -->|"1-3 tasks"| F["Small plan\n(streamlined)"]
    D -->|"4-8 tasks"| G["Medium plan\n(standard)"]
    D -->|"9+ tasks"| H["Large plan\n(maximum parallelism)"]
```

**Use this skill when:**
- Translating a design spec into executable implementation steps
- Breaking down a feature request into atomic tasks
- Planning a refactoring that touches multiple files
- Creating work breakdown for a team sprint
- Turning brainstorm output into actionable work

**Not designed for:**
- Debugging a single bug in a known file — investigate directly
- Exploring requirements that are not yet defined — use brainstorming first
- Executing a plan that already exists — use plan-execution skill

---

## The Six Phases

Complete each phase before proceeding to the next. Four gates ensure alignment and quality.

```mermaid
graph TD
    P1["Phase 1: Input Analysis\n& Codebase Reconnaissance"] --> G1{"GATE 1:\nScope Confirmation"}
    G1 -->|user confirms| P2["Phase 2: Parallel\nCodebase Mapping"]
    P2 --> P3["Phase 3: Task Decomposition\n(dispatch task-decomposer)"]
    P3 --> G2{"GATE 2:\nDAG Review"}
    G2 -->|user confirms| P4["Phase 4: Parallel\nStep Authoring"]
    P4 --> P5["Phase 5: Adversarial\nVerification\n(dispatch plan-verifier)"]
    P5 --> G3{"GATE 3:\nVerification Results"}
    G3 -->|score >= 90| P6["Phase 6: Plan Assembly\n& Delivery"]
    G3 -->|score < 90| P4
    P6 --> G4{"GATE 4:\nFinal Plan Approval"}
    G4 -->|approved| Done(("Plan delivered"))

    classDef phase fill:#2563eb,stroke:#1d4ed8,color:#fff
    classDef gate fill:#d97706,stroke:#b45309,color:#fff
    classDef done fill:#16a34a,stroke:#15803d,color:#fff

    class P1,P2,P3,P4,P5,P6 phase
    class G1,G2,G3,G4 gate
    class Done done
```

---

### Phase 1: Input Analysis & Codebase Reconnaissance

Accept one of: design spec, brainstorm output, or direct requirements from the user.

**1. Validate input** — if input is a design spec file, verify it contains: Problem Statement, Success Criteria, Scope Boundaries, Selected Approach, and Acceptance Criteria. Flag missing sections. Map design spec fields: Success Criteria + Acceptance Criteria → Requirements list. Selected Approach → architecture guidance. Scope Boundaries → task constraints. Risk Register → task risk seeds.

**2. Extract requirements** — enumerate as R1, R2, ... R(N). Each requirement gets a testable assertion that proves it is met.

**3. Classify project context:**

| Dimension | Options | Detection |
|-----------|---------|-----------|
| **Mode** | Greenfield / Brownfield / Mixed | Existing source files for the target modules? |
| **Complexity** | Small (1-3 tasks) / Medium (4-8) / Large (9+) | Requirement count, file surface area, integration points |

**4. Detect tech stack** by scanning for build and config files:

| Category | Files to scan |
|----------|--------------|
| **Build systems** | `package.json`, `Cargo.toml`, `go.mod`, `pyproject.toml`, `build.gradle.kts`, `pom.xml`, `*.csproj`, `Makefile`, `CMakeLists.txt`, `pubspec.yaml`, `composer.json` |
| **Frameworks** | Inspect imports, configs, directory conventions |
| **Test frameworks** | Jest, Vitest, pytest, Go testing, JUnit, RSpec, etc. |
| **CI/CD** | `.github/workflows/`, `.gitlab-ci.yml`, `Jenkinsfile` |
| **Project rules** | `CLAUDE.md`, `AGENTS.md`, `.editorconfig`, `CONTRIBUTING.md` |

**5. Read project rules** from CLAUDE.md, AGENTS.md, or similar files. Extract naming conventions, import ordering, error handling patterns, test structure mandates. These feed into convention compliance verification in Phase 5.

**6. Estimate complexity** — count requirements, estimate file surface area, identify integration points. Assign Small / Medium / Large.

---

### GATE 1: Scope Confirmation

Present to the user:
- Numbered requirements list (R1 ... R(N)) with testable assertions
- Project mode: Greenfield / Brownfield / Mixed
- Detected tech stack
- Complexity classification
- Estimated task count and total duration range

Ask: **"Confirm these requirements and scope, or adjust before I proceed."**

Proceed only after user confirmation. Misunderstood requirements produce wasted plans.

---

### Phase 2: Parallel Codebase Mapping

Build the file structure that the plan will operate on.

**Brownfield mode:** Dispatch `codebase-cartographer` subagents per module to map existing files, exports, types, and integration points. Each cartographer receives:
```
- Repository path: [REPO_PATH]
- Module scope: [MODULE_PATH]
- Task: Map all exports, types, function signatures, and file dependencies
```

**Greenfield mode:** Define the complete target file structure based on requirements and detected conventions.

**Both modes produce a File Structure Lock-In table:**

| File | Action | Responsibility | Modified By |
|------|--------|---------------|-------------|
| `src/auth.ts` | CREATE | Authentication middleware | T1, T3 |
| `src/routes.ts` | MODIFY | Route registration | T2 |

This table is authoritative. Every task in the plan must reference files from this table. No phantom files.

**Complexity-adaptive behavior:**
- **Small:** Skip parallel dispatch. Single-pass mapping inline.
- **Medium:** Standard parallel dispatch per module.
- **Large:** Maximum parallelism — dispatch one cartographer per module boundary.

---

### Phase 3: Task Decomposition

Dispatch the `agents/task-decomposer.md` subagent.

**Context package:**
```
- Repository path: [REPO_PATH]
- Detected tech stack: [STACK]
- Project rules: [RULES]
- Requirements: [R1..RN with testable assertions]
- Codebase map: [CARTOGRAPHER_OUTPUT or "greenfield"]
- File structure: [FILE_STRUCTURE_TABLE]
- Complexity class: [Small/Medium/Large]
```

The task-decomposer produces:
1. **Task list** — each task with all properties per `references/task-anatomy.md`: ID, title, requirements addressed, depends_on, blocks, files_read, files_modified, estimated_minutes, risk, verification, rollback, parallel_group
2. **Mermaid DAG** — visual dependency graph
3. **Wave plan** — parallel execution groups (max 4 tasks per wave)
4. **Requirements coverage matrix** — every R(N) mapped to task(s)
5. **TDD enforcement** — every task introducing new behavior includes test-first steps

**DAG rules (enforced):**
- Same-file modification = sequential dependency
- Unrelated-file modification = parallel allowed
- Test task depends on implementation task
- Max 4 tasks per wave
- Every R(N) covered by at least one T(M)
- Topological sort must succeed (no cycles)

---

### GATE 2: DAG Review

Present to the user:
- Complete task list with dependencies
- Mermaid DAG visualization
- Wave execution plan with estimated durations
- Requirements coverage matrix (every R(N) -> T(M) mapping)
- Any gaps or risks flagged by the decomposer

Ask: **"Review the task breakdown and dependencies. Confirm, or adjust tasks before I author steps."**

---

### Phase 4: Parallel Step Authoring

Author complete steps for every task. Dispatch `step-author` subagents in parallel, clustered by dependency proximity (2-4 tasks per cluster).

**Context package per step-author:**
```
- Repository path: [REPO_PATH]
- Detected tech stack: [STACK]
- Project rules: [RULES]
- Assigned tasks: [T(A), T(B), T(C)] with full properties
- File structure: [FILE_STRUCTURE_TABLE]
- Codebase map: [relevant module maps]
- Placeholder rules: references/placeholder-detector-rules.md
- Task anatomy rules: references/task-anatomy.md
```

**Step authoring rules:**
- One action per step: `read_file`, `write_code`, `run_command`, or `verify_output`
- `write_code`: CREATE = full file content. MODIFY = complete diff with context lines.
- `run_command`: exact shell command + exact expected output pattern
- `verify_output`: exact command + expected output + specific `if_unexpected` diagnostic steps
- TDD cycle per task: read -> write failing test -> verify fail -> write implementation -> verify pass -> verify full suite
- Every task ends with at least one `verify_output` step
- Every task has a rollback block with exact git commands

**Complexity-adaptive behavior:**
- **Small:** Author all tasks inline, no parallel dispatch.
- **Medium:** Dispatch 2-3 step-author agents in parallel.
- **Large:** Dispatch one step-author per cluster of 2-4 related tasks.

---

### Phase 5: Adversarial Verification

Dispatch the `agents/plan-verifier.md` subagent with the complete plan.

**Context package:**
```
- Complete plan: [ALL_TASKS_WITH_STEPS]
- Requirements: [R1..RN with testable assertions]
- Project rules: [RULES]
- Placeholder rules: references/placeholder-detector-rules.md
```

**The 7 verification checks:**

| # | Check | What It Verifies |
|---|-------|-----------------|
| 1 | **Requirements coverage** | Every R(N) traces to task(s) -> step(s) -> verification step |
| 2 | **Placeholder scan** | Zero placeholder patterns per `references/placeholder-detector-rules.md` |
| 3 | **Signature consistency** | Same function/type name has identical signature everywhere |
| 4 | **DAG integrity** | No cycles, no parallel file conflicts, file lists match actual steps |
| 5 | **Convention compliance** | All code follows project rules from CLAUDE.md |
| 6 | **Rollback feasibility** | Rollback commands are actionable, target correct files, reverse-ordered |
| 7 | **Traceability** | Full chain R(N) -> T(M) -> S(K) -> verify. No orphan tasks or steps |

**Plan Quality Score** (must be >= 90 to pass):

| Dimension | Weight |
|-----------|--------|
| Requirements coverage | 30% |
| Placeholder contamination | 25% |
| Signature consistency | 20% |
| DAG completeness | 15% |
| Convention compliance | 10% |

If score < 90: return to Phase 4 with specific defect list. Step authors fix cited defects. Re-verify. Maximum 2 rework cycles before escalating to user.

---

### GATE 3: Verification Results

Present to the user:
- Plan Quality Score (composite and per-dimension)
- Verification check results (PASS/FAIL per check)
- Defect count and details (if any remain after rework)
- Traceability matrix

If score >= 90: **"Verification passed with score {N}/100. Proceed to plan assembly?"**

If score < 90 after 2 rework cycles: **"Score is {N}/100 after 2 rework attempts. Here are the remaining defects. Proceed anyway, or adjust scope?"**

---

### Phase 6: Plan Assembly & Delivery

Assemble the final plan document following `references/plan-document-template.md`.

**Output file:** `.plan/plan-{YYYYMMDD}-{slug}.md`

Where `{slug}` is a kebab-case summary of the plan title (max 40 characters).

**Plan document sections:**
1. Header (title, date, repo, stack, complexity, quality score)
2. Requirements table with testable assertions and task mappings
3. File Structure Lock-In table
4. Task DAG (Mermaid) + Execution Waves table
5. Complete task details with all steps, risk, rollback
6. Traceability matrix
7. Plan Quality Score breakdown
8. Verification summary (7 checks)
9. Recovery points (git commit per wave boundary)

---

### GATE 4: Final Plan Approval

Present the plan summary:
- Total tasks, waves, estimated duration
- Plan Quality Score
- Output file path

Ask: **"Plan written to {path}. Review and approve, or request changes."**

---

## Red Flags -- STOP and Restructure

If you catch yourself or an agent:
- Writing a task estimated over 5 minutes
- Writing a step with ellipsis, "similar to above", or any placeholder pattern
- Skipping Phase 5 adversarial verification
- Producing a plan without a Mermaid DAG
- Omitting risk assessment or rollback from any task
- Claiming a requirement is addressed without pointing to specific steps
- Allowing two parallel tasks to modify the same file
- Writing an `if_unexpected` that says just "investigate" or "debug"
- Producing a task that modifies more than 3 files
- Emitting a plan with Quality Score below 90 without user acknowledgment

**ALL of these mean: STOP. Fix the defect before continuing.**

---

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "The implementation is obvious, I'll abbreviate" | Obvious to you now, not to the executor later. Write the complete code. |
| "These steps are similar, I'll say 'repeat for X'" | Each step is unique context. Duplicate with correct values, never reference. |
| "The user will know what I mean by 'configure appropriately'" | If you cannot write the exact config, you do not understand the requirement. |
| "Adding rollback to every task is overkill" | The task that does not need rollback is the task that will need it most. |
| "This small plan doesn't need verification" | Small plans with defects waste more time than large plans caught early. |
| "I'll finalize the details during execution" | Plans that defer decisions to execution are lists, not plans. |
| "The DAG is simple enough to keep in my head" | Draw it. If you cannot draw it, the dependencies are not clear. |
| "Risk assessment is speculative anyway" | Speculative risk identification prevents concrete failures. Name the failure mode. |
