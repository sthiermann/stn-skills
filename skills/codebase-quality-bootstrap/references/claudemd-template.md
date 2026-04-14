# CLAUDE.md Template Structure

Canonical template for generated CLAUDE.md files. Each section maps to codebase-audit domains. `[CONDITIONAL]` sections only included when tech is detected.

## Design Principles
1. **Positive framing first.** Formula: `- **{Bold Rule}** {DO instruction} -- {never/no prohibited alternative}`.
2. **Name exact tools, functions, and paths.** No generic advice.
3. **Bold-header every rule.** `- **{Rule Name}**` for scannability.
4. **Enforcement callout.** Dev Standards opens with: "These standards cover all code changes. Critical rules are enforced by hooks in `.claude/settings.json`."
5. **Conditional sections omitted entirely.** No empty sections.
6. **Commands are copy-paste ready.** Backtick-quoted, exact syntax.
7. **Per-language conventions separated.** One H3 per language under Development Standards.

## Line Budget
- **Target:** 150-250 lines | **Rule budget:** ~100-150 lines for Development Standards
- **Overflow:** Move detailed rules to `.claude/quality-rules.md` referenced via `@.claude/quality-rules.md`

## Standard Section Headings

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
  Database                  [CONDITIONAL]
  Dependencies
  Error Handling
  Infrastructure            [CONDITIONAL]
  Performance
  Concurrency               [CONDITIONAL]
  Configuration
  Documentation
Gotchas
Custom Rules                [BROWNFIELD]
```

## Rule Format
```markdown
- **{Bold Rule Name}** {Positive instruction naming exact tool/lib/function} -- {prohibited alternative with "never"/"no"}
```
Example: `- **Parameterized queries only.** Use Prisma's query builder for all database access -- never concatenate user input into SQL strings.`

## Template
```markdown
# {Project Name}
This file provides guidance to AI coding tools when working with code in this repository.

## Project
{2-3 sentence description: what the project is, its tech stack, and its purpose.}
{Optional: **{Key design constraint}** -- {explanation}. Only if project has a defining constraint.}

## Commands
```bash
# Setup / Development / Testing / Code Quality
{exact commands grouped by purpose, copy-paste ready}
```

## Architecture
{ASCII diagram or directory tree. Key components, module boundaries, dependency direction.}

## Development Standards
These standards cover all code changes. Critical rules are enforced by hooks in `.claude/settings.json`.

### Security
- **Parameterized queries only.** {exact ORM/driver method} -- never string concatenation in SQL.
- **Secrets from environment.** {exact config mechanism} -- never hardcode credentials.
- **Input validation at boundary.** {exact validation library} for all external input.
- **No PII in logs.** Use {logger} with auto-redaction -- never log raw user data.
- **Auth on every request.** {exact middleware/decorator} for all non-public endpoints.

### Architecture Compliance
- **Dependency direction.** {exact layer names} -- never import {inner} from {outer}.
- **No circular dependencies.** Modules communicate through {interface mechanism}.
- **Single responsibility.** Each {module/package} in {directory} has one clear purpose.

### Code Quality
- **Current APIs only.** Use {framework}'s current recommended patterns -- no deprecated methods.
- **State-of-the-art practices.** Apply current best practices -- no outdated patterns.
- **No dead code.** Remove unused imports, functions, variables -- use git history, not comments.
- **Clean codebase.** No "old", "new", "legacy", "v2" labeling or migration scaffolding.

### Enterprise Mandates (always include all 7)
- **Current APIs exclusively.** Current, officially recommended APIs and idioms for all code.
- **Clean-slate architecture.** Current state only -- no compatibility layers. Forward-only DB migrations compliant.
- **State-of-the-art practices.** Current best practices consistently to every component.
- **Forward-only development.** Current version only -- no backward compatibility shims.
- **Unified codebase.** One canonical implementation -- no "old/new/legacy" labeling.
- **Complete implementations.** Current patterns fully -- no partial patches.
- **Zero legacy assumptions.** Current state -- no assumptions about pre-existing users, data, or state.

### {Language} Conventions
[One H3 per detected language. Naming, idioms, import ordering, type annotations.]

### Testing
- **Test commands.** `{exact full suite cmd}` for all tests, `{exact single file cmd}` for single files.
- **Test file convention.** {exact naming pattern and location}.
- **Meaningful assertions.** Verify specific return values and state -- not just truthiness.
- **Real implementations preferred.** Mocks only for external boundaries -- never mock internal modules.
- **Edge cases covered.** Test boundary values, empty inputs, error paths for every public interface.

### Database [CONDITIONAL]

### Dependencies
- **Pinned versions.** {exact pinning strategy per detected package manager}.
- **Lock file committed.** `{exact lock file name}` tracked in git -- never manually edited.
- **No unused dependencies.** Run `{exact check command}` -- remove unused packages from manifests.

### Error Handling
- **Consistent error shape.** {exact error class/type/structure} for all error responses.
- **Structured logging.** Use `{exact logger}` with context -- never bare `print()`/`console.log()`.
- **Fail fast on startup.** Validate config at startup -- missing config causes immediate exit.
- **No silent catches.** Handle every error explicitly -- never swallow exceptions.

### Infrastructure [CONDITIONAL]

### Performance
- **Batch queries.** Use {exact eager-loading method} -- no N+1 query patterns.
- **Bounded collections.** All list endpoints support pagination -- no unbounded queries.
- **Resource lifecycle.** {exact pattern: defer/with/using/try-with-resources} for all I/O resources.

### Concurrency [CONDITIONAL]

### Configuration
- **Environment-driven config.** All environment-specific values from env vars or config files.
- **Documented variables.** All required env vars listed in `.env.example` with descriptions.
- **Validated at startup.** Missing values cause startup failure with clear error message.

### Documentation
- **README reflects reality.** Update README in same PR when changes affect setup, API, or architecture.
- **Public APIs documented.** All exported functions have {exact doc format} with parameters and return types.
- **Self-documenting code.** Comments only for WHY -- never for WHAT.

## Gotchas
{Project-specific non-obvious patterns. Only genuinely surprising behaviors.}

## Custom Rules
[BROWNFIELD: Preserved verbatim from existing CLAUDE.md.]
<!-- Generated by stn-skills:codebase-quality-bootstrap | Last updated: {YYYY-MM-DD} -->
```
