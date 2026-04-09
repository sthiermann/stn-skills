<div align="center">

# Codebase Quality Bootstrap

**Zero-finding audit compliance for Claude Code**

6 analyzers. 13 audit domains. Tech-stack-specific rules. Automated hooks.

<p>
  <img src="https://img.shields.io/badge/audit_domains-13-orange?style=flat-square" alt="Domains">
  <img src="https://img.shields.io/badge/phases-4_with_3_gates-purple?style=flat-square" alt="Phases">
  <img src="https://img.shields.io/badge/invoke-stn--skills:codebase--quality--bootstrap-blue?style=flat-square" alt="Invoke">
</p>

</div>

A Claude Code skill that analyzes a repository's tech stack, dispatches 6 specialized analyzer agents in parallel, and generates a production-grade CLAUDE.md with `.claude/settings.json` hooks — all aligned with the 13 codebase-audit domains. The preventive counterpart to codebase-audit: bootstrap first, then audit with zero findings.

---

## Why This Exists

Claude Code follows the rules you give it. Vague CLAUDE.md files produce inconsistent code. Missing hooks mean formatting, linting, and security checks run only when someone remembers to trigger them. Projects without explicit standards accumulate the exact problems a codebase audit later finds — security gaps, deprecated patterns, dead code, documentation drift.

This skill solves the problem at the source. It reads your tech stack, generates tech-stack-specific rules (not generic advice), and configures hooks that enforce deterministically. The result: Claude Code writes code that passes all 13 audit domains from the first line.

---

## Quick Start

Open Claude Code in any repository and run:

```
/stn-skills:codebase-quality-bootstrap
```

Or use natural language: `Bootstrap this project` | `Set up quality standards` | `Generate CLAUDE.md` | `Configure development standards` | `Set up hooks for this project`

The skill detects your tech stack, confirms scope with you, generates rules and hooks, previews everything for your approval, then writes the files.

---

## How It Works

```mermaid
graph LR
    P1["Phase 1\nReconnaissance"] --> G1{"GATE 1\nScope"}
    G1 -->|confirmed| P2["Phase 2\nStandards Generation\n(6 analyzers)"]
    P2 --> P3["Phase 3\nSynthesis & Preview"]
    P3 --> G2{"GATE 2\nContent Review"}
    G2 -->|approved| P4["Phase 4\nWrite & Verify"]
    G2 -->|changes| P3
    P4 --> G3{"GATE 3\nCompletion"}

    classDef phase fill:#2563eb,stroke:#1d4ed8,color:#fff,font-weight:bold
    classDef gate fill:#d97706,stroke:#b45309,color:#fff,font-weight:bold

    class P1,P2,P3,P4 phase
    class G1,G2,G3 gate
```

| Phase | What happens | Key detail |
|-------|-------------|------------|
| **Phase 1** | Detect tech stack, read existing CLAUDE.md, scan formatters/linters/test runners | Classifies greenfield (new) vs brownfield (existing CLAUDE.md) |
| **Gate 1** | You confirm the detected stack and scope | Correct misdetections before spending compute |
| **Phase 2** | 6 clustered analyzers generate rules in parallel | Each analyzer covers related audit domains with tech-stack-specific rules |
| **Phase 3** | Assemble CLAUDE.md + hooks, enforce 200-line budget | Brownfield: custom sections preserved, stale content flagged |
| **Gate 2** | You review the complete generated content | Modify specific sections before writing |
| **Phase 4** | Write files, read back to verify correctness | Both CLAUDE.md and .claude/settings.json are written atomically |
| **Gate 3** | Completion summary with audit domain coverage | Recommendation: run codebase-audit to verify zero findings |

---

## Audit Domain Coverage

All 13 codebase-audit domains are addressed through 6 clustered analyzers:

| Analyzer | Domains | What It Generates |
|----------|---------|------------------|
| **Security Standards** | `SEC`, `PRIV` | OWASP Top 10 prevention rules, data privacy rules, secrets management, protected file hooks |
| **Code Quality** | `QUAL`, `DEAD`, `DEPR`, `MAND` | SOLID/DRY rules, dead code prevention, deprecated pattern avoidance, 7 enterprise mandates, auto-format hooks |
| **Architecture** | `ARCH`, `CONC` | Dependency direction rules, circular dep prohibition, concurrency guidelines (when detected) |
| **Testing Standards** | `TEST` | Test commands, file conventions, assertion quality, mock usage guidelines, auto-test hooks |
| **Infrastructure** | `INFRA`, `DEP`, `PERF` | Dependency management, container rules, CI/CD expectations, N+1 prevention, resource lifecycle |
| **Documentation** | `DOC` | README requirements, API docs, config docs, architecture docs, freshness rules |

---

## Language Support

The skill is fully technology-agnostic. Rules are generated specific to whatever tech stack is detected — not as generic advice.

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

### Generated CLAUDE.md (excerpt for a Next.js + Prisma project)

```markdown
# my-app

Next.js 14 App Router application with Prisma ORM and PostgreSQL.

## Commands

| Command | Description |
|---------|-------------|
| `npm install` | Install dependencies |
| `npm run dev` | Start development server |
| `npm run build` | Production build |
| `npm test` | Run all tests (Vitest) |
| `npx eslint .` | Lint code |
| `npx prettier --write .` | Format code |

## Code Standards

- Functions under 40 lines, nesting under 3 levels
- `camelCase` for functions/variables, `PascalCase` for components/types, `UPPER_SNAKE_CASE` for constants
- No unused imports (enforced by ESLint `no-unused-vars`)
- No commented-out code blocks — use git history for recovery
- Use App Router patterns: server components by default, `"use client"` only when interactivity needed
- No `getServerSideProps` / `getStaticProps` — use server components and `fetch` with caching

### Enterprise Mandates

- All code uses current, officially recommended APIs
- No backward compatibility shims, version checks, or legacy adapters
- ...

## Security

- All Prisma queries use parameterized inputs — no raw SQL with string interpolation
- Secrets loaded from environment variables via `process.env`, never hardcoded
- CORS restricted to specific origins in `next.config.js`, not wildcard `*`
- No PII (names, emails, IPs) in `console.log()` or error responses
- Authentication via NextAuth.js with secure session configuration
- ...

## Testing

- `npm test` — run full suite (Vitest)
- `npx vitest path/to/test.ts` — run single file
- Test files co-located: `foo.ts` → `foo.test.ts`
- Assertions verify specific values: `expect(result).toEqual(expected)`, not `toBeTruthy()`
- Mocks only for external boundaries (API calls, database) — never mock internal modules
- ...
```

### Generated Hooks (`.claude/settings.json`)

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": "npx prettier --write \"$CLAUDE_FILE_PATH\" 2>/dev/null; npx eslint --fix \"$CLAUDE_FILE_PATH\" 2>/dev/null || true",
            "timeout": 30
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Edit|Write|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": "case \"$CLAUDE_FILE_PATH\" in *.env|*.env.*|*credentials*|*secrets*|*.pem|*.key|*/package-lock.json|*/yarn.lock|*/pnpm-lock.yaml) echo '{\"decision\":\"block\",\"reason\":\"Protected file: direct edits blocked.\"}' ;; *) echo '{}' ;; esac",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

---

## Greenfield vs Brownfield

| Mode | Detection | Behavior |
|------|-----------|----------|
| **Greenfield** | No CLAUDE.md exists | Generates complete CLAUDE.md + hooks from scratch |
| **Brownfield** | CLAUDE.md exists | Classifies sections as STANDARD (update), CUSTOM (preserve), or STALE (flag for removal) |

**Re-running the skill** updates standard sections with current analyzer output while preserving all custom content. A sentinel comment at the bottom of the CLAUDE.md tracks when it was last bootstrapped.

---

## Generated Hooks

The skill generates three types of hooks in `.claude/settings.json`, each preventing specific audit findings:

| Hook | Event | Purpose | Audit Domains |
|------|-------|---------|---------------|
| **Auto-Format** | PostToolUse | Runs detected formatter after every Edit/Write | QUAL, DEAD, DEPR |
| **Protected Files** | PreToolUse | Blocks edits to .env, credentials, keys, lock files | SEC, INFRA, PRIV |
| **Auto-Test** | PostToolUse | Runs related tests after source changes (optional) | TEST |

Hooks are only generated for tools that are already configured in the project. Supported formatters: Prettier, ESLint, Biome, Ruff, Black, gofmt, rustfmt, clang-format, rubocop, PHP-CS-Fixer, dart format, swift-format, mix format.

---

## Enterprise Mandates

The generated CLAUDE.md always includes these 7 non-negotiable mandates — the same mandates enforced by the codebase-audit:

| # | Mandate | Target State |
|---|---------|-------------|
| 1 | **Current APIs** | All code uses current, officially recommended APIs and language idioms |
| 2 | **Clean-slate system** | No migration scripts, compatibility layers, or transition logic |
| 3 | **State-of-the-art** | Current best practices applied consistently to every component |
| 4 | **Forward-only** | No backward compatibility shims, version checks, or legacy adapters |
| 5 | **Unified codebase** | No "old/new/legacy" labeling — everything is the current state |
| 6 | **Full rewrite** | No partial patches preserving outdated structures |
| 7 | **Zero legacy assumptions** | No assumptions about pre-existing users, data, or state |

---

## Relationship to Codebase Audit

The two skills form a complementary pair:

```
┌─────────────────────────────┐     ┌─────────────────────────────┐
│  codebase-quality-bootstrap │     │       codebase-audit        │
│        (PREVENTIVE)         │     │        (DETECTIVE)          │
│                             │     │                             │
│  Generates rules + hooks    │────>│  Verifies rules are         │
│  that prevent findings      │     │  being followed             │
│                             │     │                             │
│  Run FIRST on any project   │     │  Run AFTER to verify        │
│  to establish standards     │     │  zero findings              │
└─────────────────────────────┘     └─────────────────────────────┘
```

**Recommended workflow:** Bootstrap a project, develop with the generated standards, then audit. The audit should produce zero findings.

---

## CI/CD Integration

The skill runs interactively by default (3 user gates). For CI/CD pipelines, use Claude Code's headless mode with pre-confirmed scope:

```yaml
# GitHub Actions example — regenerate standards on dependency updates
- name: Update quality standards
  run: |
    claude --print "Run codebase-quality-bootstrap on this repository. \
      At Gate 1: confirm full scope. \
      At Gate 2: approve all generated content. \
      Output the CLAUDE.md and hooks."
```

---

## Acknowledgments

- Security rules reference the [OWASP Top 10](https://owasp.org/Top10/), published by the OWASP Foundation under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/). OWASP is a registered trademark of the OWASP Foundation, Inc. This project is not affiliated with or endorsed by the OWASP Foundation.
