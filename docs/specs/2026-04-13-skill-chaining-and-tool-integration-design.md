# Design Spec: Skill Chaining, AskUserQuestion Integration & Passive Execution Fix

**Date:** 2026-04-13
**Status:** Approved
**Complexity:** Standard

---

## Problem Statement

The stn-skills pipeline is broken at three points:
1. **No skill chaining:** Brainstorming and plan-writing end without naming or invoking the follow-up skill. Users must manually invoke the next skill.
2. **Passive execution:** After plan approval, the agent asks "Soll ich starten?" instead of executing immediately.
3. **No AskUserQuestion usage:** All gates and interview questions use inline `Ask: **"..."**` text instead of the dedicated AskUserQuestion tool, reducing interaction quality.

## Success Criteria

| # | Criterion | Verification |
|---|-----------|-------------|
| SC1 | After brainstorming Phase 6 + user says "continue" → plan-writing invoked via Skill tool | Manual test: run brainstorming, say "weiter" at end, verify plan-writing activates |
| SC2 | After plan-writing GATE 4 + user says "continue" → plan-execution invoked via Skill tool | Manual test: run plan-writing, say "weiter" at end, verify plan-execution activates |
| SC3 | Plan-execution proceeds immediately after gate confirmations without passive "Soll ich starten?" | Manual test: approve GATE 1, verify Phase 2 starts immediately |
| SC4 | All gates (18 applicable) use AskUserQuestion tool | Grep for `AskUserQuestion` in all SKILL.md files, verify count matches gate count |
| SC5 | Interview questions in brainstorming Phase 1 use AskUserQuestion | Manual test: start brainstorming, verify first question uses AskUserQuestion |

## Confirmed Assumptions

| # | Assumption | Evidence |
|---|-----------|---------|
| A1 | Individual skill usage does NOT auto-forward, but names the follow-up skill and invokes on "continue" | User confirmed |
| A2 | On "continue", the Skill tool call happens automatically | User confirmed |
| A3 | build-feature may still ask "Continue or stop?" at transition gates | User confirmed |
| A4 | AskUserQuestion for ALL user-facing gates and interview questions | User confirmed |
| A5 | Plan-execution starts directly after gate confirmation without passive asking | User confirmed (Inferred) |
| A6 | Interview questions use AskUserQuestion with options + "Other" for free text | User corrected: AskUserQuestion everywhere |
| A7 | Codebase-audit GATE 3 (complex selection) uses AskUserQuestion with simplified options | Inferred — complex syntax mapped to top-level options + "Other" |
| A8 | Content (tables, matrices) displayed VIA normal text BEFORE AskUserQuestion call | Inferred — tool only carries the question, not the content |
| A9 | codebase-quality-bootstrap GATE 3 is informational, no AskUserQuestion needed | Inferred — no question asked at this gate |

## Scope Boundaries

| Category | Content |
|----------|---------|
| **Always Do** | Add transition sections to brainstorming + plan-writing, add AskUserQuestion instructions to all gates, add anti-passivity instructions to plan-execution |
| **Ask First** | Changes to gate question text, changes to build-feature orchestrator transition logic |
| **Never Do** | Change skill phase structure, modify agent prompts, change reference files, skip any gates |

## Selected Approach: Gate Protocol Pattern (Approach B)

### Overview

Four changes applied systematically across all SKILL.md files:

### Change 1: Transition Sections (brainstorming, plan-writing)

Add a `## Transition` section after the last phase in brainstorming and plan-writing:

```markdown
## Transition: [Design/Plan] Complete

**Terminal state: The next pipeline step is `/stn-skills:[next-skill]`.**

Present to the user using AskUserQuestion:
- Question: "[Artifact] saved to `{path}`. Continue to [next-skill], or stop here?"
- Options: ["Continue to [next-skill]", "Stop here"]

**On "Continue":** Immediately invoke the Skill tool: `Skill(skill: "stn-skills:[next-skill]", args: "{artifact_path}")`
**On "Stop":** End session. Inform user they can resume with `/stn-skills:[next-skill]`.
```

This works for both standalone and build-feature usage:
- **Standalone:** Agent follows the transition section directly
- **build-feature:** Build-feature's more detailed instructions (including handoff validation) supersede, but the outcome is the same — the next skill is invoked

### Change 2: Gate Protocol Format (all skills with gates)

Replace every `Ask: **"..."**` pattern with:

```markdown
**Present all content above to the user first.** Then use the AskUserQuestion tool:
- Question: "[gate question text]"
- Options: [contextually appropriate options]

**Do not proceed until the user responds.**
```

AskUserQuestion applicability per gate type:
- **Simple gates** (confirm/reject): 2 options
- **Selection gates** (GATE 3 brainstorming): Approaches as options (max 4)
- **Complex gates** (audit GATE 3): Simplified top-level options + "Other" for flexible input
- **Informational gates** (bootstrap GATE 3): No AskUserQuestion — just present info

### Change 3: Interview Protocol (brainstorming Phase 1)

Replace the interview instruction with:

```markdown
For each question, use the AskUserQuestion tool with category-appropriate options.
The user can always select "Other" for free-text answers.
Wait for the response before asking the next question.
```

### Change 4: Anti-Passivity Instructions (plan-execution)

Add explicit instructions after each gate in plan-execution:

```markdown
**After user confirms: proceed immediately to the next phase. Do not ask additional questions.**
```

This prevents the "Soll ich mit Phase A starten?" behavior. Also add to the existing Rules section:

```markdown
7. **No passive asking** — After a gate confirmation, execution continues immediately. 
   Do not ask "Should I start?", "Which task first?", or similar. The plan defines the order.
```

### Affected Files

| File | Changes |
|------|---------|
| `skills/brainstorming/SKILL.md` | Add Transition section, convert 4 gates + interview to AskUserQuestion |
| `skills/plan-writing/SKILL.md` | Add Transition section, convert 4 gates to AskUserQuestion |
| `skills/plan-execution/SKILL.md` | Add anti-passivity rule, convert 3 gates + inline pauses to AskUserQuestion |
| `skills/build-feature/SKILL.md` | Convert 2 transition gates to AskUserQuestion, align with sub-skill transitions |
| `skills/codebase-audit/SKILL.md` | Convert 3 gates to AskUserQuestion |
| `skills/codebase-quality-bootstrap/SKILL.md` | Convert 2 gates to AskUserQuestion (GATE 3 informational, no change) |

## Decision Rationale

Approach B (Gate Protocol Pattern) selected over:
- **Approach A (Minimal Diff):** AskUserQuestion parenthetical hints too subtle — models may ignore them
- **Approach C (Top-Level Mandates):** Mandates 200 lines from the gate create attention-distance risk

Approach B places the tool instruction directly at each gate, making it impossible to miss.

## Risk Register

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| AskUserQuestion options too constrained for complex gates | Medium | Medium | Use "Other" option for flexible input, present rich content before the tool call |
| Transition section in brainstorming conflicts with build-feature | Low | Medium | Build-feature reads sub-skill SKILL.md — its more detailed transition supersedes |
| Anti-passivity instruction causes agent to skip important context | Low | High | Instruction specifically says "proceed to next phase", not "skip content" |

## Adversarial Review Findings

| Flaw | Classification | Resolution |
|------|---------------|------------|
| AskUserQuestion doesn't exist | Resolved | Tool exists as Claude Code built-in (verified in session) |
| Pipeline pre-approval has no mechanism | Resolved | Changed to anti-passivity instructions — no gates skipped |
| Iron Law contradiction (skipped gates) | Resolved | No gates skipped — only passive re-asking eliminated |
| Competing transition control | Warning (accepted) | build-feature's detailed instructions supersede sub-skill transitions |
| Overgeneralization of gate format | Warning (mitigated) | Complex gates use simplified options + "Other"; informational gates unchanged |

## Acceptance Criteria

1. `grep -c "AskUserQuestion" skills/*/SKILL.md` returns counts matching gate counts per skill
2. `grep -c "Transition" skills/brainstorming/SKILL.md skills/plan-writing/SKILL.md` returns 1 per file
3. `grep "No passive asking" skills/plan-execution/SKILL.md` returns a match
4. Manual test: `/stn-skills:brainstorming` → complete → say "weiter" → plan-writing activates
5. Manual test: `/stn-skills:plan-execution` → approve GATE 1 → Phase 2 starts immediately
