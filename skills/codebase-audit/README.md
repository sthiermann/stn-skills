<div align="center">

<img src="banner.svg" alt="Codebase Audit — 13-domain evidence-based audits" width="100%">

# Codebase Audit

**Evidence-based repository audits**

13 domains. Parallel agents. Independently verified findings. Optional auto-fix.

<p>
  <img src="https://img.shields.io/badge/audit_domains-13-orange?style=flat-square" alt="13 Audit Domains">
  <img src="https://img.shields.io/badge/phases-5_with_3_gates-purple?style=flat-square" alt="5 Phases with 3 Gates">
  <img src="https://img.shields.io/badge/invoke-stn--skills:codebase--audit-blue?style=flat-square" alt="Invoke: stn-skills:codebase-audit">
</p>

</div>

Part of the [stn-skills](https://github.com/sthiermann/stn-skills) pipeline. Audit findings can be escalated to brainstorming and plan-writing for structured remediation. Use `/stn-skills:build-feature` for the full pipeline.

A skill for comprehensive, technology-agnostic code auditing. Dispatches up to 13 specialized auditor agents in parallel, independently verifies every finding, and delivers a structured report with file:line evidence. Simple findings are fixed directly with surgical precision. Complex findings — architectural violations, large-scale refactoring, design decisions — are escalated to the brainstorming → plan-writing → plan-execution pipeline via a structured remediation brief.

**Typical duration:** 15–30 min for a medium repository (50–500 files)

---

## Why This Exists

Code reviews catch issues in individual changes. But codebases accumulate problems across changes — security gaps nobody noticed, deprecated APIs that still work, dead code everyone steps around, documentation that drifted from reality, PII leaking into log files, N+1 queries hiding behind an ORM.

These systemic issues need a systematic audit, not a file-by-file review. This skill runs that audit. It works with any programming language and framework, adapts to your project's conventions, and enforces your team's quality mandates.

---

## Quick Start

Open your AI coding tool in any repository and run:

```
/stn-skills:codebase-audit
```

Or use natural language: `Audit this repository` | `Review the codebase for production readiness` | `Run a code health check` | `Check this repo for security issues` | `Find dead code and deprecated patterns`

The skill detects your tech stack, confirms scope with you, dispatches auditors, verifies findings, and generates the report.

---

## How It Works

```mermaid
graph LR
    P1["Phase 1\nReconnaissance"] --> G1{"GATE 1\nScope"}
    G1 -->|confirmed| P2["Phase 2\nParallel Audits\n(13 agents)"]
    P2 --> P3["Phase 3\nVerification"]
    P3 --> G2{"GATE 2\nFindings"}
    G2 -->|confirmed| P4["Phase 4\nReport"]
    P4 --> G3{"GATE 3\nRemediation"}
    G3 -->|fix selected| P5["Phase 5\nFix & Verify"]
    G3 -->|skip| Done(("Done"))
    P5 --> Done

    classDef phase fill:#2563eb,stroke:#1d4ed8,color:#fff,font-weight:bold
    classDef gate fill:#d97706,stroke:#b45309,color:#fff,font-weight:bold
    classDef done fill:#16a34a,stroke:#15803d,color:#fff,font-weight:bold

    class P1,P2,P3,P4,P5 phase
    class G1,G2,G3 gate
    class Done done
```

| Phase | What happens | Key detail |
|-------|-------------|------------|
| **Phase 1** | Detect tech stack, read project rules, map modules | Classifies repo size for optimal audit strategy |
| **Gate 1** | You confirm the scope | Adjust domains or modules before spending compute |
| **Phase 2** | 13 specialized auditors run in parallel | SEC, DOC, DEAD, DEPR, MAND, QUAL, ARCH, DEP, TEST, INFRA, PERF, CONC, PRIV |
| **Phase 3** | Independent verifier checks 30%+ of findings | False positives are removed; domains with >25% FP rate get re-audited |
| **Gate 2** | You review the verified findings | Challenge or investigate any finding before the report |
| **Phase 4** | Structured report with remediation roadmap | Every finding has a stable ID (F1, F2, ...) for selection |
| **Gate 3** | You choose what to fix — or skip entirely | Select by ID, severity, domain, or module. No code changes without your say. |
| **Phase 5** | Quick fixes applied surgically; complex findings generate pipeline brief | Bottom-up edits + test suite OR remediation brief for brainstorming/plan-writing |

---

## Pipeline Escalation

Not all findings can be fixed with surgical edits. Architectural violations, large-scale deprecated pattern replacements, and findings requiring design decisions benefit from the full brainstorming → plan-writing → plan-execution pipeline.

At Gate 3, findings are classified into two remediation tiers:

| Tier | Criteria | Action |
|------|----------|--------|
| **Quick Fix** | Effort ∈ {Trivial, Small}, Risk ∈ {Safe, Moderate} | Direct remediation — applied and verified in Phase 5 |
| **Pipeline** `[PIPELINE]` | Effort ∈ {Medium, Large}, Risk = High, or domain = ARCH | Generates a remediation brief for `/stn-skills:brainstorming` or `/stn-skills:plan-writing` |

The remediation brief contains the problem statement, constraints, scope boundaries, success criteria, and finding references — designed as direct input for the brainstorming or plan-writing skill's Phase 1.

---

## Audit Domains

| Domain | Code | What It Examines |
|--------|------|-----------------|
| **Security** | `SEC` | OWASP Top 10, hardcoded secrets, injection, auth, CORS, security headers, cryptographic weaknesses |
| **Documentation** | `DOC` | README accuracy, API docs vs. actual endpoints, architecture docs vs. structure, stale references |
| **Dead Code** | `DEAD` | Unused imports, functions, variables, files, unreachable branches, commented-out code, dead tests |
| **Deprecated Patterns** | `DEPR` | Outdated language features, deprecated framework APIs, legacy patterns — verified against actual versions |
| **Enterprise Mandates** | `MAND` | Non-negotiable project rules from CLAUDE.md (configurable per project) |
| **Code Quality** | `QUAL` | SOLID principles, DRY, naming, complexity, error handling, nesting depth, consistent idioms |
| **Architecture** | `ARCH` | Layer violations, circular dependencies, coupling, cohesion, testability, module boundaries |
| **Dependencies** | `DEP` | Outdated versions, CVEs, unused deps, duplicates, unpinned versions, license conflicts |
| **Test Coverage** | `TEST` | Untested interfaces, mock abuse, shallow assertions, missing edge cases, flaky indicators |
| **Infrastructure** | `INFRA` | Container best practices, CI/CD completeness, env var hygiene, secret management, IaC quality |
| **Performance** | `PERF` | N+1 queries, blocking I/O, unbounded data structures, resource leaks, missing caching, inefficient algorithms |
| **Concurrency** | `CONC` | Race conditions, deadlocks, TOCTOU, shared mutable state, async pitfalls (dispatched only when concurrency is detected) |
| **Data Privacy** | `PRIV` | PII in logs and error responses, data retention gaps, missing consent tracking, uncontrolled third-party data transmission |

---

## Language Support

The skill is fully technology-agnostic. All audit checks are expressed as universal principles — Claude adapts them to whatever tech stack it detects.

| Ecosystem | Languages and Frameworks |
|-----------|------------------------|
| **JVM** | Java, Kotlin, Scala, Groovy — Spring Boot, Quarkus, Micronaut, Gradle, Maven |
| **JavaScript / TypeScript** | Node.js, Deno, Bun — React, Angular, Vue, Next.js, NestJS, Express, Fastify |
| **Python** | Django, Flask, FastAPI, SQLAlchemy, Poetry, pip |
| **Go** | Standard library, Gin, Echo, Fiber, Chi |
| **Rust** | Actix, Axum, Rocket, Cargo |
| **C# / .NET** | ASP.NET Core, Blazor, Entity Framework, NuGet |
| **PHP** | Laravel, Symfony, Composer |
| **Ruby** | Rails, Sinatra, Bundler |
| **Swift** | iOS, macOS, Swift Package Manager |
| **C / C++** | CMake, Make, Bazel, Conan, vcpkg |
| **Others** | Elixir/Phoenix, Haskell/Stack, Clojure/Leiningen, Dart/Flutter, Zig, Nim |

---

## Example Output

Every finding includes severity, confidence, file:line evidence, impact, remediation, effort estimate, and risk level. Each carries a stable ID (F1, F2, ...) for remediation selection at Gate 3.

Severity levels: **Critical** (fix immediately) > **High** (fix this sprint) > **Medium** (fix this cycle) > **Low** (track)

**F1 [Critical] SEC: SQL injection in user search endpoint**
- **File:** `src/api/users.py:47`
- **Confidence:** Confirmed
- **Evidence:** `cursor.execute(f"SELECT * FROM users WHERE name = '{query}'")`
- **Impact:** User-supplied input is interpolated directly into SQL, enabling full database extraction via UNION-based injection
- **Remediation:** Use parameterized query: `cursor.execute("SELECT * FROM users WHERE name = %s", (query,))`
- **Effort:** Trivial (< 30min) | **Risk:** Safe

**F4 [High] PERF: N+1 query in order listing endpoint**
- **File:** `src/api/orders.js:82`
- **Confidence:** Confirmed
- **Evidence:** `orders.forEach(async (o) => { o.items = await db.query("SELECT * FROM items WHERE order_id = ?", o.id) })`
- **Impact:** For N orders, executes N+1 database queries. At 500 orders per page, this produces 501 queries per request.
- **Remediation:** Use a single JOIN or IN-clause: `SELECT * FROM items WHERE order_id IN (?)` with all order IDs batched
- **Effort:** Small (< 2h) | **Risk:** Moderate

**F9 [Medium] DEAD: Unused exported function**
- **File:** `src/utils/format.ts:124`
- **Confidence:** High
- **Evidence:** `export function formatLegacyDate(d: Date): string` — zero references found across 847 files searched
- **Impact:** Dead code increases bundle size and confuses maintainers scanning the utils module
- **Remediation:** Remove `formatLegacyDate` and its associated tests in `tests/utils/format.test.ts:89`
- **Effort:** Trivial (< 30min) | **Risk:** Safe

**F15 [Low] DOC: README setup instructions reference removed env variable**
- **File:** `README.md:34`
- **Confidence:** Confirmed
- **Evidence:** `Set LEGACY_DB_URL in your .env` — but `LEGACY_DB_URL` is not referenced anywhere in source code
- **Impact:** Users following setup instructions will configure an unused variable, wasting time and causing confusion
- **Remediation:** Remove the outdated setup step or replace with the current `DATABASE_URL` variable
- **Effort:** Trivial (< 30min) | **Risk:** Safe

---

## Enterprise Mandates

When your project defines quality mandates in `CLAUDE.md`, the audit enforces them. The default mandates:

| # | Mandate | Target State |
|---|---------|-------------|
| 1 | **Current APIs exclusively** | All code uses current, officially recommended APIs and language idioms |
| 2 | **Clean-slate architecture** | No migration scripts, compatibility layers, or transition logic |
| 3 | **State-of-the-art practices** | Current best practices applied consistently to every component |
| 4 | **Forward-only development** | No backward compatibility shims, version checks, or legacy adapters |
| 5 | **Unified codebase** | No "old/new/legacy" labeling — everything is the current state |
| 6 | **Complete implementations** | No partial patches preserving outdated structures |
| 7 | **Zero legacy assumptions** | No assumptions about pre-existing users, data, or state |

The audit produces a PASS/FAIL compliance matrix for each mandate with cited evidence.

---

## Report Structure

The final audit report contains:

- **Executive Summary** — finding counts, top 3 priorities, deploy recommendation, verification statistics
- **Enterprise Mandate Compliance Matrix** — PASS/FAIL per mandate with evidence
- **Findings by Severity** — Critical, High, Medium, Low — each with file:line evidence, confidence, effort, risk
- **Remediation Roadmap** — prioritized by severity and estimated effort with total effort range
- **Evidence Index** — all file:line references organized by domain

---

## Suppressing Findings

Teams can suppress known false positives or intentional patterns by adding comments directly in source code:

```python
# audit-suppress: DEAD: intentionally unused — reserved for plugin API
def on_plugin_load(ctx):
    pass
```

```java
// audit-suppress: SEC: CSRF not applicable — internal microservice, no browser clients
@PostMapping("/internal/sync")
public void syncData(@RequestBody SyncRequest req) { ... }
```

Suppression syntax: `audit-suppress: DOMAIN` or `audit-suppress: DOMAIN: reason`. Applies to the next line only. Critical findings with Confirmed confidence are never suppressed.

---

## CI/CD Integration

The audit runs interactively by default (3 user gates for scope, findings, and remediation). For CI/CD pipelines, use headless mode with pre-confirmed scope (example uses Claude Code CLI):

```yaml
# GitHub Actions example
- name: Run codebase audit
  run: |
    claude --print "Run a codebase audit on this repository. \
      Scope: all 13 domains. \
      At Gate 1: confirm full scope. \
      At Gate 2: proceed to report. \
      At Gate 3: skip remediation. \
      Output the full report."
```

**Using the deploy recommendation:**
The audit report includes a deploy recommendation at Gate 2 based on findings:
- **Block deploy**: Critical findings with Confirmed or High confidence detected
- **Deploy with caution**: High findings in non-critical paths
- **Ship it**: No Critical or High findings

Teams can parse the deploy recommendation from the report output and use it as a gate in their pipeline.

---

## Acknowledgments

- Security audit categories reference the [OWASP Top 10 2021](https://owasp.org/Top10/), published by the OWASP Foundation under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/). OWASP is a registered trademark of the OWASP Foundation, Inc. This project is not affiliated with or endorsed by the OWASP Foundation.
