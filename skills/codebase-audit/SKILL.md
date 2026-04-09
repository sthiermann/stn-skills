---
name: codebase-audit
description: >-
  Comprehensive, technology-agnostic repository audit for security vulnerabilities,
  dead code, deprecated patterns, documentation staleness, architecture compliance,
  and code quality. Works with any programming language and framework.
  Use when auditing a repository, preparing for production, performing periodic
  code health checks, or assessing technical debt. Triggers on "audit",
  "review the repo", "code health", "security scan", "find dead code",
  "clean up", "quality check", or any repository-wide analysis request.
  Use this skill whenever the user wants to review an entire codebase,
  even if they only mention one specific concern like security or dead code —
  the full audit covers all dimensions.
---

# Codebase Audit

## Overview

Systematic, multi-dimensional audit of an entire repository. Dispatches specialized auditor subagents in parallel across up to 13 domains, verifies every finding independently, and synthesizes a prioritized report with actionable remediation.

**Core principle:** Every finding requires file:line evidence. Assertions without evidence are false positives.

**Announce:** "I'm using the codebase-audit skill to perform a comprehensive repository audit."

## The Iron Law

```
EVERY FINDING REQUIRES FILE:LINE EVIDENCE.
SPECULATION IS NOT A FINDING. EVIDENCE IS.
```

If an auditor reports an issue without citing the exact file and line — that finding is rejected. If a finding cannot be verified by reading the cited location — that finding is rejected.

## When to Use

```dot
digraph when_to_use {
    "Repository-wide concern?" [shape=diamond];
    "Specific domain known?" [shape=diamond];
    "Run full audit (all 13 domains)" [shape=box];
    "Run targeted audit (selected domains)" [shape=box];
    "Not in scope — investigate the specific file directly" [shape=box];

    "Repository-wide concern?" -> "Specific domain known?" [label="yes"];
    "Repository-wide concern?" -> "Not in scope — investigate the specific file directly" [label="no"];
    "Specific domain known?" -> "Run targeted audit (selected domains)" [label="yes"];
    "Specific domain known?" -> "Run full audit (all 13 domains)" [label="no"];
}
```

**Use this skill when:**
- Auditing an entire codebase for production readiness
- Performing periodic code health assessments
- Onboarding to understand existing code quality
- After major refactoring to verify quality
- Assessing technical debt across a project
- Preparing for a compliance or security review

**Not designed for:**
- Debugging a single bug in a known file — investigate that file directly
- Reviewing a single pull request — use your standard review process
- Planning a new feature — this skill audits existing code, not designs

---

## The Five Phases

Complete each phase before proceeding to the next. Three user gates ensure alignment.

```dot
digraph audit_flow {
    rankdir=TB;
    node [shape=box];

    P1 [label="Phase 1: Repository Reconnaissance"];
    G1 [label="GATE 1: Scope Confirmation" shape=diamond];
    P2 [label="Phase 2: Parallel Domain Audits\n(dispatch up to 13 subagents)"];
    P3 [label="Phase 3: Verification\n(independent evidence check)"];
    G2 [label="GATE 2: Findings Review" shape=diamond];
    P4 [label="Phase 4: Report Synthesis"];
    G3 [label="GATE 3: Remediation Selection\n(opt-in)" shape=diamond];
    P5 [label="Phase 5: Remediation Execution\n(fix, verify)"];

    P1 -> G1;
    G1 -> P2 [label="user confirms"];
    P2 -> P3;
    P3 -> G2;
    G2 -> P4 [label="user confirms"];
    P4 -> G3;
    G3 -> P5 [label="user selects findings"];
    G3 -> end [label="user skips"];
    end [label="Audit complete\n(report only)" shape=oval];
}
```

---

### Phase 1: Repository Reconnaissance

Before dispatching any auditor, understand what you are auditing.

**1. Detect tech stack** by scanning for build and config files:

| Category | Files to scan |
|----------|--------------|
| **Build systems** | `build.gradle.kts`, `build.gradle`, `pom.xml`, `package.json`, `Cargo.toml`, `go.mod`, `go.sum`, `Gemfile`, `requirements.txt`, `pyproject.toml`, `setup.py`, `*.csproj`, `*.sln`, `Makefile`, `CMakeLists.txt`, `mix.exs`, `build.sbt`, `pubspec.yaml`, `Package.swift`, `composer.json`, `Rakefile`, `BUILD`, `WORKSPACE` |
| **Frameworks** | Inspect imports, configs, directory conventions (e.g., `src/main/java` = Spring, `app/` = Rails, `pages/` = Next.js) |
| **Containers** | `Dockerfile`, `docker-compose.yml`, `docker-compose.yaml`, `Containerfile`, `.dockerignore` |
| **CI/CD** | `.github/workflows/`, `.gitlab-ci.yml`, `Jenkinsfile`, `.circleci/`, `bitbucket-pipelines.yml`, `.travis.yml`, `azure-pipelines.yml` |
| **Project rules** | `CLAUDE.md`, `AGENTS.md`, `.context/`, `.editorconfig`, `CONTRIBUTING.md` |

**2. Read project rules** from CLAUDE.md, AGENTS.md, or similar files. Extract any project-specific quality mandates, non-negotiable rules, or architectural constraints that auditors must enforce.

**3. Map module structure** — identify module boundaries, packages, workspaces, or subprojects. Note which modules are active vs. potentially abandoned.

**4. Classify repository size:**

| Class | Source files | Strategy |
|-------|-------------|----------|
| Small | < 50 | Full audit, all files examined |
| Medium | 50 – 500 | Standard parallel dispatch |
| Monorepo | 500+ or multi-module | Scope to user-selected modules |

**5. Identify primary and secondary languages** — note all languages present and their approximate proportion.

---

### GATE 1: Scope Confirmation

Present to the user:
- Detected tech stack (languages, frameworks, build tools, infrastructure)
- Repository size classification
- Module structure (if multi-module)
- Proposed audit domains (all 13 by default)

Ask: **"Confirm this scope, or specify which domains to audit and which modules to focus on."**

Proceed only after user confirmation. Assumptions about scope lead to wasted work.

---

### Phase 2: Parallel Domain Audits

Dispatch specialized auditor subagents in parallel. Each auditor receives the same context package and its domain-specific prompt.

**Context package for every auditor:**
```
- Repository path: [REPO_PATH]
- Tech stack: [DETECTED_STACK summary]
- Project rules: [CLAUDE_MD_CONTENT or "none detected"]
- Scope: [MODULE_LIST or "all"]
- Instruction: Read your domain prompt at agents/[domain]-auditor.md
```

**Dispatch table:**

| Domain | Agent prompt file | Focus |
|--------|------------------|-------|
| Security | `agents/security-auditor.md` | OWASP Top 10, secrets, injection, auth, headers |
| Documentation | `agents/documentation-auditor.md` | Doc currency, completeness, accuracy |
| Dead Code | `agents/dead-code-auditor.md` | Unused code, unreachable branches, orphaned files |
| Deprecated Patterns | `agents/deprecated-patterns-auditor.md` | Outdated APIs, legacy patterns, superseded features |
| Enterprise Mandates | `agents/enterprise-mandates-auditor.md` | The 7 non-negotiable rules enforcement |
| Code Quality | `agents/code-quality-auditor.md` | SOLID, DRY, naming, complexity, idioms |
| Architecture | `agents/architecture-auditor.md` | Coupling, cohesion, layering, dependency direction |
| Dependencies | `agents/dependency-auditor.md` | Outdated versions, CVEs, unused deps, license conflicts |
| Test Coverage | `agents/test-coverage-auditor.md` | Gaps, anti-patterns, assertions, edge cases |
| Infrastructure | `agents/infrastructure-auditor.md` | Containers, CI/CD, env vars, build config |
| Performance | `agents/performance-auditor.md` | N+1 queries, blocking I/O, unbounded data, resource leaks |
| Concurrency | `agents/concurrency-auditor.md` | Race conditions, deadlocks, TOCTOU, async pitfalls |
| Data Privacy | `agents/data-privacy-auditor.md` | PII in logs, data retention, consent, third-party transmission |

**Conditional dispatch:**
- **Concurrency**: dispatch only when Phase 1 detects threading, goroutines, async runtimes, or multiprocessing in the codebase. Skip for single-threaded applications.

**Model selection:**
- Security + Architecture + Concurrency: use the most capable model (judgment-heavy, high stakes)
- All other domains: use standard model

**Dispatch all auditors in a single message** to maximize parallelism. Each auditor works independently — no cross-domain dependencies during Phase 2.

---

### Phase 3: Verification

After all auditors complete, dispatch the `agents/findings-verifier.md` subagent with the combined findings.

The verifier's mandate:
1. Sample at least **30% of all findings** (all Criticals are mandatory)
2. For each sampled finding: **read the actual file:line cited**
3. Confirm the issue exists exactly as described
4. Mark each finding: **Verified** / **False Positive** / **Needs Context**
5. Remove all False Positives from the findings set

**Re-dispatch threshold:** If any single domain has a false positive rate above 25%, re-dispatch that domain's auditor with a stricter prompt emphasizing evidence requirements. This happens automatically — the verifier identifies which domains need re-audit.

---

### GATE 2: Findings Review

Present to the user:

**1. Severity Overview:**
- Findings count by severity: Critical | High | Medium | Low
- Confidence distribution: how many Confirmed vs. High vs. Medium vs. Low confidence (note: confidence levels may have been adjusted by the verifier during Phase 3 based on evidence quality)

**2. Hotspot Analysis:**
- Top 5 most affected modules/directories (ranked by finding count weighted by severity)
- Finding clusters: group identical patterns (e.g., "47 unused imports across 12 files" instead of 47 individual findings)

**3. Blast Radius Assessment:**
- Findings in security-sensitive paths (auth, payments, user data) flagged separately
- Findings affecting shared/core modules vs. isolated leaf modules

**4. Top 5 Most Impactful Findings:**
- Brief summary with file references, confidence, and estimated effort

**5. Verification Statistics:**
- How many findings checked, how many false positives removed, which domains (if any) were re-audited

**6. Deploy Recommendation:**
- **Block deploy**: Any Critical finding with Confirmed or High confidence
- **Deploy with caution**: High findings in non-critical paths, or Critical with Medium confidence
- **Ship it**: No Critical or High findings, or all are Low confidence

Ask: **"These are the verified findings. Proceed to full report, or investigate any area deeper?"**

---

### Phase 4: Report Synthesis

Dispatch `agents/report-synthesizer.md` with all verified findings. The synthesizer:

1. **Deduplicates** findings that overlap across domains (same file:line from different auditors)
2. **Organizes** by severity, then by domain within each severity level
3. **Generates** the structured report following `references/report-template.md`
4. **Builds** the enterprise mandate compliance matrix
5. **Creates** a prioritized remediation roadmap (severity x effort)

Present the complete report to the user.

---

## Severity Classification

| Severity | Criteria | Expected response |
|----------|----------|-------------------|
| **Critical** | Exploitable security vulnerability, data loss risk, authentication bypass, secrets exposed in code | Fix immediately, block deployment |
| **High** | Significant quality issue, deprecated API in critical path, architectural violation in core module, missing tests for critical logic | Fix this sprint |
| **Medium** | Code quality issue, documentation gap, moderate technical debt, non-critical deprecated usage | Fix this cycle |
| **Low** | Style inconsistency, minor optimization opportunity, cosmetic documentation issue | Track, fix opportunistically |

Full classification details in `references/severity-classification.md`.

---

## Finding Format

Every finding follows this exact structure:

```markdown
**[SEVERITY] DOMAIN: Descriptive title**
- **File:** `path/to/file.ext:line-range`
- **Confidence:** Confirmed / High / Medium / Low
- **Evidence:** [exact code snippet or description of what was found at that location]
- **Impact:** [what happens if this is not addressed]
- **Remediation:** [specific action to take, with idiomatic code example for the detected language]
- **Effort:** Trivial (< 30min) / Small (< 2h) / Medium (< 1 day) / Large (> 1 day)
- **Risk:** Safe (drop-in) / Moderate (requires testing) / High (could break functionality)
```

Domain codes: `SEC`, `DOC`, `DEAD`, `DEPR`, `MAND`, `QUAL`, `ARCH`, `DEP`, `TEST`, `INFRA`, `PERF`, `CONC`, `PRIV`

**Confidence levels:**
- **Confirmed**: Statically verifiable with certainty. The evidence alone proves the finding.
- **High**: Very likely correct. Minimal false positive risk.
- **Medium**: Probably correct, but framework conventions or runtime behavior could invalidate.
- **Low**: Possible issue, but requires runtime verification to confirm.

---

## Red Flags — STOP and Return to Phase 1

If you catch yourself or an auditor:
- Generating findings without reading actual source files
- Reporting issues based on assumptions about what code "probably" does
- Citing Critical severity without demonstrating exploitability or data loss
- Reporting deprecated patterns without verifying the actual version in use
- Claiming "no issues found" without examining specific files as evidence
- Skipping the verification phase
- Proceeding past a gate without user confirmation
- Reporting findings for files outside the agreed scope

**ALL of these mean: STOP. Gather real evidence before continuing.**

---

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "This pattern is commonly deprecated" | Check the actual version in the project. Generic assumptions produce false positives. |
| "This is a well-known security issue" | Show the exact vulnerable code path. Generic warnings waste the user's time. |
| "Too many files to check thoroughly" | Scope to modules, but examine those modules deeply. A shallow scan across everything produces noise. |
| "Verification is redundant if I'm careful" | Without verification, 25%+ false positive rate is normal. Always verify. |
| "The user wants results fast" | An audit with false positives erodes trust. Accurate findings beat fast noise. |
| "This finding is obvious enough to skip evidence" | Evidence distinguishes signal from noise. Every finding, every time. |
| "I can infer the issue from the file name" | File names lie. Read the actual code. |
| "I checked a similar file, this one is probably the same" | Each file gets its own assessment. Probably is not evidence. |

---

## Enterprise Mandate Compliance

When CLAUDE.md or project rules define non-negotiable mandates, the enterprise-mandates-auditor evaluates compliance. The standard mandates (configurable per project):

| Mandate | Target state |
|---------|-------------|
| **Current APIs** | All code uses current, officially recommended APIs and language idioms |
| **Clean-slate system** | The codebase operates without migration scripts, transition logic, or compatibility layers |
| **State-of-the-art** | Every component applies current best practices for its technology |
| **Forward-only** | Code contains no backward compatibility shims, version checks, or legacy adapters |
| **Unified codebase** | No code is labeled "new", "old", "legacy", or "replaced" — everything is the current state |
| **Full rewrite approach** | No partial patches, minimal diffs, or preservation of outdated structures |
| **Zero legacy assumptions** | No code assumes pre-existing users, data, schemas, or runtime dependencies |

---

### GATE 3: Remediation Selection

**Phase 5 is entirely optional.** The audit is complete after Phase 4. No code is modified unless the user explicitly requests it.

Present to the user:
- All findings numbered as F1..FN (IDs from the Phase 4 report)
- Findings grouped by file path, showing which files have multiple findings
- Detected conflicts (overlapping line ranges, contradictory remediations)
- Quick-select options: `all` | `critical+high` | `domain:SEC` | `module:auth` | `F1,F3,F7`

Ask: **"The audit is complete. Would you like me to fix any of these findings? Specify by ID, severity, domain, or module — or 'skip' to keep the report only."**

- **`skip` or any declination = audit ends here.** No files are modified. The report stands as the deliverable.
- Only an explicit selection of findings proceeds to Phase 5.
- If the user selects findings with detected conflicts, explain the conflict and ask which approach to prefer before proceeding.
- **No files are modified without explicit user approval.**

Proceed only after the user confirms the final selection.

---

### Phase 5: Remediation Execution

After the user selects findings at GATE 3, execute the fixes in three steps: plan batches, dispatch remediation agents, and verify results.

**Step 1: Plan Remediation Batches**

Group the selected findings into execution batches. The goal: maximize parallelism while preventing file conflicts.

1. **Group by file.** All findings targeting the same file go into the same batch. A file must never be modified by two agents simultaneously.
2. **Order within each batch.** Within a single-file batch, order fixes from bottom-of-file to top-of-file. This prevents line-number shifts from invalidating subsequent fixes.
3. **Handle cross-file findings.** Some findings span multiple files (e.g., an architecture violation requiring changes in both caller and callee). For these, merge the batches for all involved files into a single batch that runs sequentially.
4. **Assign batch execution order.** Batches with no cross-batch dependencies run in parallel. Batches that share a cross-file finding run sequentially in dependency order. Critical-severity batches execute first within each parallel group.

Report the batch plan to the orchestrator: how many batches exist, how many can run in parallel, how many must be sequential.

**Step 2: Dispatch Remediation Agents**

For each batch, dispatch a remediation executor subagent using the Agent tool. Dispatch all independent batches in a single message to maximize parallelism.

**Context package for each remediation agent:**
```
REPO_PATH:       {{REPO_PATH}}
DETECTED_STACK:  {{DETECTED_STACK}}
PROJECT_RULES:   {{PROJECT_RULES}}
BATCH_ID:        {{BATCH_ID}}
FINDINGS:        {{FINDINGS_IN_THIS_BATCH}}
```

Each agent reads `agents/remediation-executor.md` for its operating instructions.

**Model selection:** Use the most capable model for batches containing Critical or High security findings. Use standard model for all other batches.

**Step 3: Verify Remediation**

After all remediation agents complete, dispatch the remediation verifier with the full set of changes.

The verifier (`agents/remediation-verifier.md`):
1. Re-reads every modified file to confirm the fix was applied correctly.
2. Checks that the original finding's evidence is no longer present at the cited location.
3. Checks for regressions: does the fix introduce new issues visible in the immediate context (syntax errors, broken imports, inconsistencies)?
4. Runs the project's test suite if one was detected during Phase 1 reconnaissance.
5. Reports results per finding: **Fixed** / **Partially Fixed** / **Fix Failed** / **Regression Detected**.

**Handling failures:**
- **Fix Failed:** The finding was not resolved. Report the finding ID, what was attempted, and what went wrong. Do not retry automatically — present to the user for manual resolution.
- **Regression Detected:** A fix introduced a new problem. Report both the original finding and the regression. Present to the user with a recommendation: revert the change, or address the regression.
- **Test Failures:** If the test suite was passing before remediation and now has failures, report which tests broke and which remediation batch likely caused each failure.

**Final output — Remediation Summary:**

Present to the user:
- Findings fixed successfully (count and list)
- Findings partially fixed (count, list, what remains)
- Findings that failed (count, list, reason)
- Regressions introduced (count, list, details)
- Test suite status (before vs. after, which tests changed state)
- Files modified (full list with line counts changed)
