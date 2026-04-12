# Severity Classification

## Severity Levels

| Severity | Criteria | Expected Response | Examples |
|----------|----------|-------------------|----------|
| **Critical** | Exploitable security vulnerability, data loss risk, authentication bypass, secrets exposed in source code, complete system failure path | Fix immediately, block deployment | SQL injection with user input reaching query, hardcoded API key in public repo, auth bypass in endpoint, unencrypted password storage |
| **High** | Significant quality issue in critical path, deprecated API in core functionality, architectural violation in central module, missing tests for business-critical logic, vulnerable dependency in active use | Fix this sprint | God class handling core business logic, circular dependency between core modules, untested payment processing, dependency with known CVE |
| **Medium** | Code quality issue affecting maintainability, documentation gap for active feature, moderate technical debt, non-critical deprecated usage, missing edge case tests | Fix this cycle | DRY violation across 3+ locations, README setup instructions outdated, unused import accumulation, missing null-check tests |
| **Low** | Style inconsistency, minor optimization opportunity, cosmetic documentation issue, unused variable in non-critical code | Track, fix opportunistically | Inconsistent naming convention, minor Dockerfile optimization, cosmetic typo in comments |

## Evidence Requirements by Severity

### Critical Findings

Critical severity demands the highest evidence bar:
- **Exploitability demonstration:** Show the exact code path from user input to vulnerable operation
- **Data flow:** Trace the data from entry point to the security-sensitive operation
- **Impact scope:** Identify what data, systems, or users are affected
- **Remediation urgency:** Explain why this cannot wait

A finding is Critical only when the evidence demonstrates real, immediate risk. "This could theoretically be exploited" is High, not Critical.

### High Findings

High severity requires clear impact on production quality:
- **Concrete impact:** Explain the specific maintenance, reliability, or quality cost
- **Scope:** Identify how much of the codebase is affected
- **Dependency chain:** Show what breaks or degrades because of this issue

### Medium Findings

Medium severity requires evidence of maintainability impact:
- **Code location:** Exact file:line reference
- **Pattern description:** What the code does vs. what it should do
- **Maintenance cost:** How this makes future work harder

### Low Findings

Low severity still requires file:line evidence:
- **Code location:** Exact file:line reference
- **Observation:** What could be improved
- **Suggestion:** The recommended change

## Severity Escalation Rules

A finding escalates to a higher severity when:
- A Medium finding appears in 10+ locations → High (systemic pattern)
- A High finding exists in a security-sensitive code path → Critical
- A Low finding violates an explicit project mandate → Medium or High (per mandate severity)
- A finding of any severity has Confirmed confidence in a core module → consider one level escalation

## Confidence Levels

Every finding carries a confidence rating independent of severity:

| Level | Criteria | Effect on Deploy Recommendation |
|-------|----------|--------------------------------|
| **Confirmed** | Statically verifiable with certainty. The evidence alone proves the finding. | Critical + Confirmed = Block deploy |
| **High** | Very likely correct based on static analysis. Minimal false positive risk. | Critical + High = Block deploy |
| **Medium** | Probably correct, but framework conventions, dynamic dispatch, or runtime behavior could invalidate. | Critical + Medium = Deploy with caution |
| **Low** | Possible issue, but requires runtime verification or deeper context to confirm. | Not counted toward deploy recommendation |

The findings verifier may adjust confidence levels during Phase 3 verification. Adjustments are documented with rationale.

## Effort and Risk Estimates

Every finding includes remediation effort and risk estimates:

| Effort | Criteria |
|--------|----------|
| **Trivial** | Single-line change, drop-in replacement, delete unused code. Under 30 minutes. |
| **Small** | Localized change in 1-2 files. Under 2 hours. |
| **Medium** | Changes spanning multiple files or requiring testing. Under 1 day. |
| **Large** | Architectural change, cross-module refactoring, or requires design decisions. Over 1 day. |

| Risk | Criteria |
|------|----------|
| **Safe** | Drop-in replacement, removing dead code, fixing typos. No behavior change for working code paths. |
| **Moderate** | Changes behavior but in predictable ways. Requires testing to verify. |
| **High** | Could break existing functionality, affects shared interfaces, or changes security-sensitive code paths. |

**Pipeline escalation candidates:** Findings with Effort ∈ {Medium, Large}, Risk = High, or domain = ARCH are tagged `[PIPELINE]` in the remediation roadmap. These findings benefit from structured design exploration (`/stn-skills:brainstorming`) or verified multi-step execution (`/stn-skills:plan-writing`) rather than direct surgical fixes. The user decides at GATE 3 whether to quick-fix or escalate.

## Domain Code Reference

| Code | Domain | Typical Severity Range |
|------|--------|----------------------|
| `SEC` | Security | Critical – High |
| `DOC` | Documentation | Medium – Low |
| `DEAD` | Dead Code | Medium – Low |
| `DEPR` | Deprecated Patterns | High – Medium |
| `MAND` | Enterprise Mandates | High – Medium |
| `QUAL` | Code Quality | High – Low |
| `ARCH` | Architecture | High – Medium |
| `DEP` | Dependencies | Critical – Low |
| `TEST` | Test Coverage | High – Medium |
| `INFRA` | Infrastructure | Critical – Low |
| `PERF` | Performance | Critical – Low |
| `CONC` | Concurrency | Critical – Low |
| `PRIV` | Data Privacy | Critical – Medium |
