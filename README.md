# Codebase Audit

A Claude Code plugin that performs comprehensive, evidence-based code audits. It dispatches up to 13 specialized auditor agents in parallel — each focused on a single domain — then independently verifies every finding before delivering a structured report.

Every reported issue includes the exact file and line where the problem exists, what the code does wrong, and how to fix it. No vague warnings. No false positives that waste your time.

---

## Why This Exists

Code reviews catch issues in individual changes. But codebases accumulate problems across changes — security gaps nobody noticed, deprecated APIs that still work, dead code everyone steps around, documentation that drifted from reality, PII leaking into log files, N+1 queries hiding behind an ORM.

These systemic issues need a systematic audit, not a file-by-file review. This skill runs that audit. It works with any programming language and framework, adapts to your project's conventions, and enforces your team's quality mandates.

---

## Install

```bash
claude plugin add https://github.com/sthiermann/codebase-audit
```

## Quick Start

Open Claude Code in any repository and say:

```
Audit this repository
```

That's it. The skill detects your tech stack, confirms scope with you, dispatches auditors, verifies findings, and generates the report.

Other phrases that work: `Review the codebase for production readiness` | `Run a code health check` | `Check this repo for security issues` | `Find dead code and deprecated patterns`

---

## How It Works

```
                           GATE 1                                 GATE 2
                        User confirms                          User confirms
                            scope                               findings
                              |                                    |
  Phase 1               Phase 2                    Phase 3         |    Phase 4
  Reconnaissance  --->  Parallel Domain Audits --> Verification ---|-->  Report
                                                                        Synthesis
  - Detect stack        SEC   DOC   DEAD  DEPR     Independent         - Executive summary
  - Read project rules  MAND  QUAL  ARCH  DEP      verifier reads     - Findings by severity
  - Map modules         TEST  INFRA PERF            cited file:line    - Compliance matrix
  - Classify size       CONC  PRIV                  for 30%+ of       - Remediation roadmap
                                                    all findings
                        All dispatched
                        in parallel
```

**Gate 1** lets you adjust scope before spending compute.
**Gate 2** lets you challenge findings before the report is finalized.

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

## Finding Format

Every finding follows a consistent structure:

```markdown
**[Critical] SEC: SQL injection in user search endpoint**
- **File:** `src/api/users.py:47`
- **Evidence:** `cursor.execute(f"SELECT * FROM users WHERE name = '{query}'")`
- **Impact:** User-supplied input is interpolated directly into SQL, enabling data extraction
- **Remediation:** Use parameterized query: `cursor.execute("SELECT * FROM users WHERE name = %s", (query,))`
```

Severity levels: **Critical** (fix immediately) > **High** (fix this sprint) > **Medium** (fix this cycle) > **Low** (track)

---

## Enterprise Mandates

When your project defines quality mandates in `CLAUDE.md`, the audit enforces them. The default mandates:

| # | Mandate | Target State |
|---|---------|-------------|
| 1 | **Current APIs** | All code uses current, officially recommended APIs and language idioms |
| 2 | **Clean-slate system** | No migration scripts, compatibility layers, or transition logic |
| 3 | **State-of-the-art** | Current best practices applied consistently to every component |
| 4 | **Forward-only** | No backward compatibility shims, version checks, or legacy adapters |
| 5 | **Unified codebase** | No "old/new/legacy" labeling — everything is the current state |
| 6 | **Full rewrite** | No partial patches preserving outdated structures |
| 7 | **Zero legacy assumptions** | No assumptions about pre-existing users, data, or state |

The audit produces a PASS/FAIL compliance matrix for each mandate with cited evidence.

---

## Report Structure

The final audit report contains:

- **Executive Summary** — finding counts, top 3 priorities, verification statistics
- **Enterprise Mandate Compliance Matrix** — PASS/FAIL per mandate with evidence
- **Findings by Severity** — Critical, High, Medium, Low — each with file:line evidence
- **Remediation Roadmap** — prioritized by severity and estimated effort
- **Evidence Index** — all file:line references organized by domain

---

## Plugin Structure

```
codebase-audit/
|
|-- .claude-plugin/
|   +-- plugin.json                          # Plugin metadata
|
|-- skills/
|   +-- codebase-audit/
|       |-- SKILL.md                         # Orchestration (4 phases, 2 gates)
|       |
|       |-- agents/
|       |   |-- security-auditor.md          # OWASP Top 10, secrets, injection
|       |   |-- documentation-auditor.md     # Doc accuracy, completeness
|       |   |-- dead-code-auditor.md         # Unused code, unreachable branches
|       |   |-- deprecated-patterns-auditor.md
|       |   |-- enterprise-mandates-auditor.md
|       |   |-- code-quality-auditor.md      # SOLID, DRY, naming, complexity
|       |   |-- architecture-auditor.md      # Coupling, cohesion, layering
|       |   |-- dependency-auditor.md        # CVEs, outdated, licenses
|       |   |-- test-coverage-auditor.md     # Gaps, mock abuse, edge cases
|       |   |-- infrastructure-auditor.md    # Containers, CI/CD, secrets
|       |   |-- performance-auditor.md       # N+1, blocking I/O, leaks
|       |   |-- concurrency-auditor.md       # Race conditions, deadlocks
|       |   |-- data-privacy-auditor.md      # PII handling, retention
|       |   |-- findings-verifier.md         # Independent evidence check
|       |   +-- report-synthesizer.md        # Dedup, report generation
|       |
|       +-- references/
|           |-- severity-classification.md   # Severity levels and evidence rules
|           +-- report-template.md           # Output report structure
|
|-- README.md
+-- LICENSE
```

---

## Contributing

Contributions are welcome. If you want to improve an auditor's checklist, add support for a new domain, or fix an issue:

1. Fork the repository
2. Make your changes
3. Ensure all auditor prompts follow the canonical format (see `SKILL.md` for the finding format specification)
4. Submit a pull request with a clear description of what changed and why

**Guidelines:**
- Audit checks use universal principles, not language-specific rules
- Every checklist item uses positive formulations ("verify that X works correctly" not "check for X failure")
- All agents use the same context variable format and output field names
- New domains need a corresponding entry in the dispatch table in `SKILL.md`

---

## Acknowledgments

- Security audit categories reference the [OWASP Top 10 2021](https://owasp.org/Top10/), published by the OWASP Foundation under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/). OWASP is a registered trademark of the OWASP Foundation, Inc. This project is not affiliated with or endorsed by the OWASP Foundation.

---

## License

MIT
