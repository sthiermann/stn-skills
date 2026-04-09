# Codebase Quality Bootstrap

**The preventive counterpart to codebase-audit.** While the audit *finds* quality problems after they exist, this skill *prevents* them by configuring a project's CLAUDE.md and hooks before development begins.

## What It Does

Analyzes a repository's tech stack, structure, and existing configuration, then generates:

1. **Root CLAUDE.md** with tech-stack-specific quality rules aligned to all 13 codebase-audit domains
2. **`.claude/settings.json` hooks** for automated quality enforcement (formatting, protected files, testing)

The result: Claude Code enforces highest development standards from the first line of code -- producing zero findings when audited.

## Invoke

```
/stn-skills:codebase-quality-bootstrap
```

Or natural language: `Bootstrap this project` | `Set up quality standards` | `Generate CLAUDE.md` | `Configure development standards`

## Workflow

| Phase | What Happens |
|-------|-------------|
| **Phase 1: Reconnaissance** | Detect tech stack, scan existing CLAUDE.md, identify formatters/linters/test runners |
| **GATE 1** | User confirms detected stack and scope |
| **Phase 2: Standards Generation** | 6 analyzer subagents generate tech-stack-specific rules in parallel |
| **Phase 3: Synthesis & Preview** | Assemble CLAUDE.md + hooks, present for review |
| **GATE 2** | User reviews and approves generated content |
| **Phase 4: Write & Verify** | Write files, verify correctness |
| **GATE 3** | Completion summary + recommendation to run codebase-audit |

## Audit Domain Coverage

All 13 codebase-audit domains are addressed through 6 clustered analyzers:

| Analyzer | Domains |
|----------|---------|
| Security Standards | SEC (Security), PRIV (Data Privacy) |
| Code Quality | QUAL (Code Quality), DEAD (Dead Code), DEPR (Deprecated Patterns), MAND (Enterprise Mandates) |
| Architecture | ARCH (Architecture), CONC (Concurrency) |
| Testing Standards | TEST (Test Coverage) |
| Infrastructure | INFRA (Infrastructure), DEP (Dependencies), PERF (Performance) |
| Documentation | DOC (Documentation) |

## Greenfield vs Brownfield

- **Greenfield** (no CLAUDE.md): Generates complete CLAUDE.md + hooks from scratch
- **Brownfield** (existing CLAUDE.md): Updates standard sections, preserves custom content, flags stale references

Re-running the skill updates standards without losing custom rules.

## Generated Hooks

| Hook | Type | Purpose |
|------|------|---------|
| Auto-Format | PostToolUse | Runs detected formatter after every Edit/Write |
| Protected Files | PreToolUse | Blocks edits to .env, credentials, lock files |
| Auto-Test | PostToolUse | Runs related tests after source changes (optional) |

## Relationship to Codebase Audit

```
codebase-quality-bootstrap     codebase-audit
(PREVENTIVE)                   (DETECTIVE)
                              
Generate rules that    --->    Verify rules are
prevent findings               being followed
                              
Run FIRST              --->    Run AFTER to verify
```

Bootstrap a project, then audit it. The audit should produce zero findings.
