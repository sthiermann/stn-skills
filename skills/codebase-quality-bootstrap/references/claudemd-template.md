# CLAUDE.md Template Structure

This is the canonical template for generated CLAUDE.md files. Modeled after enterprise-grade CLAUDE.md files from production projects. Each section maps to one or more codebase-audit domains. Sections marked `[CONDITIONAL]` are only included when the corresponding tech is detected.

## Design Principles

These principles govern every generated CLAUDE.md:

1. **Positive framing first.** Lead with what TO DO, append what to avoid after `--`. Formula: `**{Bold Rule}** {DO instruction} -- {never/no prohibited alternative}`. Positive framing cuts violations ~50% vs negative-only rules.
2. **Name exact tools, functions, and paths.** "Use `db.query()` from `src/utils/db.ts`" not "use the database helper". Generic advice produces audit findings.
3. **Bold-header every rule.** Each rule starts with `- **{Rule Name}**` for scannability. AI agents can grep for bold phrases.
4. **Enforcement callout.** The Development Standards section opens with: "These standards cover all code changes. Critical rules are enforced by hooks in `.claude/settings.json`."
5. **Conditional sections omitted entirely.** Do not leave empty sections. If no database, no Database section.
6. **Commands are copy-paste ready.** Backtick-quoted, exact syntax, no placeholders.
7. **Per-language conventions separated.** Polyglot projects get one H3 per language under Development Standards.

## Line Budget

- **Target:** 150-250 lines when populated (enterprise projects need more room)
- **Architecture variable budget:** Complex architectures (pipelines, microservices) may need 30-50 lines for diagrams
- **Rule budget:** ~100-150 lines for Development Standards
- **Overflow strategy:** Move detailed rules to `.claude/quality-rules.md` referenced via `@.claude/quality-rules.md`

## Standard Section Headings

These headings are recognized as STANDARD sections during brownfield analysis. Any heading not in this list is classified as CUSTOM and preserved verbatim.

```
Project
Commands
Architecture
Development Standards
  Security
  Architecture Compliance
  Code Quality
  {Language} Conventions    [per detected language]
  Testing
  Database                  [CONDITIONAL: only if database/ORM detected]
  Dependencies
  Error Handling
  Infrastructure            [CONDITIONAL: only if containers/CI detected]
  Performance
  Concurrency               [CONDITIONAL: only if concurrency detected]
  Configuration
  Documentation
Gotchas
Custom Rules                [BROWNFIELD: preserved from existing CLAUDE.md]
```

## Rule Format

Every rule in the Development Standards section follows this format:

```markdown
- **{Bold Rule Name}** {Positive instruction naming exact tool/lib/function} -- {prohibited alternative with "never"/"no"}
```

Examples of correct format:
```markdown
- **Parameterized queries only.** Use Prisma's query builder for all database access -- never concatenate user input into SQL strings.
- **Secrets from environment.** Load all secrets from environment variables via `src/config.ts` -- never hardcode credentials, tokens, or API keys.
- **Functional components.** Use function components with hooks for all React components -- no class components.
```

When prohibition is the primary message (security), pair it with the alternative:
```markdown
- **No PII in logs.** Use the structured logger from `src/lib/logger.ts` which auto-redacts sensitive fields -- never log raw user data, emails, IPs, or tokens.
```

## Template

```markdown
# {Project Name}

This file provides guidance to Claude Code when working with code in this repository.

## Project

{2-3 sentence description: what the project is, its tech stack, and its purpose. Derived from package.json/README/pyproject.toml/Cargo.toml.}

{Optional: **{Key design constraint}** -- {explanation}. Include only if the project has a defining constraint that shapes all development decisions.}

## Commands

```bash
# Setup
{setup commands with exact syntax}

# Development
{dev server, build, watch commands}

# Testing
{test all, test single file, test with coverage}

# Code Quality
{lint, format, type check commands}
```

Commands must be copy-paste ready. Group by purpose. Include comments for clarity. Only include commands that actually exist in the project.

## Architecture

{Visual representation: ASCII diagram for pipelines/flows, directory tree for module structure}

{Brief annotation of key components, module boundaries, and dependency direction. Reference exact directory names.}

### Key Components

{Only include if project has distinct subsystems worth explaining: API layer, workers, CLI tools, etc. Describe each in 1-2 sentences with the directory path.}

## Development Standards

These standards cover all code changes. Critical rules are enforced by hooks in `.claude/settings.json`.

### Security

{SEC rules: OWASP-aligned, framework-specific}
{PRIV rules: data privacy, PII handling}

Minimum required rules (adapt to detected stack):
- **Parameterized queries only.** {exact ORM/driver method} -- never string concatenation in SQL.
- **Secrets from environment.** {exact config mechanism} -- never hardcode credentials.
- **Input validation at boundary.** {exact validation library} for all external input.
- **No PII in logs.** Use {logger} with auto-redaction -- never log raw user data.
- **Auth on every request.** {exact middleware/decorator} for all non-public endpoints.

### Architecture Compliance

{ARCH rules: dependency direction, patterns, domain constraints}

Minimum required rules:
- **Dependency direction.** {exact layer names from directory structure} -- never import {inner} from {outer}.
- **No circular dependencies.** Modules communicate through {interface mechanism}.
- **Single responsibility.** Each {module/package} in {directory} has one clear purpose.

### Code Quality

{QUAL rules: naming, complexity, patterns}
{DEAD rules: dead code prevention}
{DEPR rules: deprecated pattern avoidance}

Minimum required rules:
- **Current APIs only.** Use {framework}'s current recommended patterns -- no deprecated methods or legacy APIs.
- **State-of-the-art practices.** Apply current best practices to every component -- no outdated patterns.
- **No dead code.** Remove unused imports, functions, and variables -- use git history for recovery, not comments.
- **Clean codebase.** All code is the current state -- no "old", "new", "legacy", "v2" labeling or migration scaffolding.

### Enterprise Mandates

- **Current APIs exclusively.** Use current, officially recommended APIs and language idioms for all code.
- **Clean-slate architecture.** Build every component as current state -- no migration scripts, compatibility layers, or transition logic.
- **State-of-the-art practices.** Apply current best practices consistently to every component in the codebase.
- **Forward-only development.** Write code for the current version only -- no backward compatibility shims, version checks, or legacy adapters.
- **Unified codebase.** Maintain one canonical implementation -- no "old/new/legacy" labeling or parallel code paths.
- **Complete implementations.** Implement features fully using current patterns -- no partial patches preserving outdated structures.
- **Zero legacy assumptions.** Design for the current state -- no assumptions about pre-existing users, data formats, or system state.

These 7 mandates are always included. They are positively framed as what TO DO.

### {Language} Conventions

[One H3 per detected language. For polyglot projects, create separate sections: "### Python Conventions", "### TypeScript Conventions", etc.]

{Language-specific naming conventions, idioms, import ordering, type annotation style, formatting preferences. Reference the exact convention (PEP 8, Google style guide, etc.)}

### Testing

{TEST rules: framework-specific requirements}

Minimum required rules:
- **Test commands.** `{exact full suite cmd}` for all tests, `{exact single file cmd}` for single files.
- **Test file convention.** {exact naming pattern and location}.
- **Meaningful assertions.** Verify specific return values and state -- not just truthiness.
- **Real implementations preferred.** Use mocks only for external boundaries (HTTP, database, third-party APIs) -- never mock internal modules.
- **Edge cases covered.** Test boundary values, empty inputs, and error paths for every public interface.

### Database

[CONDITIONAL: Only include if database, ORM, or query builder detected]

{DB-specific rules: query safety, naming conventions, migration patterns, transaction handling}

### Dependencies

{DEP rules: pinning strategy, lock files, unused deps}

Minimum required rules:
- **Pinned versions.** {exact pinning strategy per detected package manager}.
- **Lock file committed.** `{exact lock file name}` tracked in git -- never manually edited.
- **No unused dependencies.** Run `{exact check command}` to verify -- remove unused packages from manifests.

### Error Handling

{QUAL rules elevated: per-layer error handling patterns}

Minimum required rules:
- **Consistent error shape.** {exact error class/type/structure} for all error responses.
- **Structured logging.** Use `{exact logger}` with context -- never bare `print()` or `console.log()`.
- **Fail fast on startup.** Validate all required configuration at startup -- missing config causes immediate exit with clear error.
- **No silent catches.** Handle every error explicitly with logging and appropriate response -- never swallow exceptions.

### Infrastructure

[CONDITIONAL: Only include if Dockerfile, docker-compose, CI/CD configs, or IaC detected]

{INFRA rules: container best practices, CI/CD requirements}

### Performance

{PERF rules: query patterns, bounded collections, resource management}

Minimum required rules:
- **Batch queries.** Use {exact eager-loading method} for related data -- no N+1 query patterns.
- **Bounded collections.** All list endpoints support pagination -- no unbounded queries.
- **Resource lifecycle.** {exact resource management pattern: defer/with/using/try-with-resources} for all I/O resources.

### Concurrency

[CONDITIONAL: Only include if Phase 1 detects threading, goroutines, async runtimes, multiprocessing, or actor systems]

{CONC rules: shared state, synchronization, async patterns}

### Configuration

{INFRA+SEC rules: env var management, config patterns}

Minimum required rules:
- **Environment-driven config.** All environment-specific values from env vars or config files -- no hardcoded URLs, hostnames, or ports.
- **Documented variables.** All required env vars listed in `.env.example` with descriptions and types.
- **Validated at startup.** Application validates required config on boot -- missing values cause startup failure with clear error message.

### Documentation

{DOC rules: what must be documented and when}

Minimum required rules:
- **README reflects reality.** Update README in the same PR when changes affect setup, API, or architecture.
- **Public APIs documented.** All exported functions have {exact doc format: JSDoc/docstring/godoc} with parameters and return types.
- **Self-documenting code.** Add comments only for WHY (business logic, workarounds) -- never for WHAT (the code itself).

## Gotchas

{Project-specific non-obvious patterns detected during Phase 1 reconnaissance. Only include genuinely surprising behaviors. Do not fabricate.}

## Custom Rules

[BROWNFIELD: Preserved verbatim from existing CLAUDE.md. Custom rules are user-added content that does not match any STANDARD heading.]

<!-- Generated by stn-skills:codebase-quality-bootstrap | Last updated: {YYYY-MM-DD} -->
```
