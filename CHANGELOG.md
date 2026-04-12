# Changelog

All notable changes to this project will be documented in this file.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [3.1.0] - 2026-04-12

### Added
- **Pipeline escalation for complex audit findings** — codebase-audit GATE 3 now classifies findings into Quick Fix (direct remediation) and Pipeline `[PIPELINE]` (generates structured remediation brief for brainstorming or plan-writing). Complex findings — architectural violations, large-scale refactoring, design decisions — are handled through the full design-to-delivery pipeline instead of surgical fixes.
- **Context refresh mandate** in plan-execution — orchestrator re-reads all scope files before every task dispatch; task-implementer reads current file state instead of relying on plan-authored snapshots. Prevents plan staleness across multi-task execution.
- **Full context refresh in post-execution cleanup** — Phase 4 reads complete final state of every modified file before scanning, catching issues that emerge only in combination of multiple task changes.
- **TDD safeguard** in task-implementer — flags concern when plan orders implementation before tests, prioritizes test-first execution.
- **Research-backed methodology documentation** — root README now includes evidence table linking each design principle to measured outcomes (12-18% correctness improvement from planning, 20-27% degradation prevention from per-step verification, etc.).
- **Duration estimates** across all skills and READMEs.
- **Pipeline context callouts** in all individual skill READMEs linking to the full pipeline.
- **Tree-structured search documentation** in brainstorming SKILL.md connecting multi-lens exploration to research on tree-structured generation.
- **Pipeline Escalation Candidates** subsection in audit report template and report-synthesizer with `[PIPELINE]` tagging.

### Changed
- Root README "What Makes This Different" section expanded from collapsed `<details>` to visible headers for brainstorming, plan-writing, plan-execution, and codebase-audit differentiators.
- Root README pipeline diagram now shows codebase-audit → pipeline escalation flow alongside the main pipeline.
- Available Skills table now includes "Typical Duration" column.
- Codebase-audit README adds Pipeline Escalation section explaining two-tier remediation.
- Severity classification reference adds pipeline escalation criteria note.

## [3.0.0] - 2026-04-12

### Added
- **Brainstorming skill** — 6-phase structured design exploration with 5 cognitive lenses (Inversion, Stakeholder, Constraint Removal, Temporal, Simplification), weighted 7-criteria decision matrix, 11-type adversarial reasoning flaw taxonomy, and adaptive depth (Focused/Standard/Deep). Produces validated design specifications.
- **Plan-Writing skill** — 6-phase DAG-based task decomposition with zero-placeholder enforcement (40+ prohibited patterns), complete code in every step, 7-check adversarial verification, Plan Quality Score (0-100, threshold 90+), and end-to-end traceability matrices.
- **Plan-Execution skill** — 7-phase checkpoint-verified execution with 3-stage sequential review (spec compliance → code quality → integration), 3-check drift detection, dual-threshold circuit breakers, Reflect-Retry-Escalate protocol, structured task handoff, post-execution cleanup, and Execution Fidelity Score.
- **Build-Feature meta-skill** — end-to-end pipeline chaining brainstorming → plan-writing → plan-execution with all gates preserved.
- Cross-cutting Modernization Guard in every agent prompt
- Token-efficient progressive disclosure architecture (SKILL.md max 400 lines, agent prompts max 200 lines, reference files max 150 lines)
- KV-cache optimized agent prompt structure (stable prefixes, deterministic ordering)

## [2.5.0] - 2026-04-10

### Added
- Brownfield structural transformation: converts flat H2 sections to H3 under Development Standards
- Mandatory pre-preview check ensuring Enterprise Mandates are always present in output
- Block suppression syntax (`audit-suppress-start` / `audit-suppress-end`) for multi-line constructs
- Mass assignment / over-posting check in security auditor
- 14 international PII patterns (aadhaar, cpf, nric, iban, biometric, etc.)
- 6 framework false-positive patterns in dead-code auditor (Next.js, Pytest, FastAPI, NestJS, Vue, Svelte)
- File extension guards in all hook commands (hooks-catalog.md)
- Monorepo handling guidance in both SKILL.md files
- Deploy recommendation in report template executive summary
- Sampling caps for findings verifier (max 25 Medium, 15 Low per domain)
- CLAUDE.md, CHANGELOG.md, CONTRIBUTING.md, GitHub issue/PR templates

### Changed
- Domain-specific confidence and effort examples in all 13 auditor agents (replaced copy-paste boilerplate)
- Synchronized Enterprise Mandate names across all files (canonical: code-quality-analyzer.md)
- Migration files nuance: standard forward-only migrations are Mandate 2 compliant
- Expanded Mandate 5 whitelist (constructor keywords, navigation terms, timestamps, annotations)
- Pragmatic test-first framing in testing analyzer (replaces prescriptive TDD rule)
- Brownfield merge now explicitly inserts missing standard sections (not just replaces existing)
- Line budget consistently stated as 150-250 lines across all files
- Build systems table synced between audit and bootstrap (added Rakefile, Bazel)

## [2.4.0] - 2026-04-10

### Changed
- Enforce mandatory compliance checks in brownfield mode
- Upgrade codebase-quality-bootstrap to enterprise-grade Golden Lens quality

## [2.3.0] - 2026-04-10

### Changed
- Version bump consolidating bootstrap quality improvements

## [2.1.0] - 2026-04-09

### Added
- codebase-quality-bootstrap skill (preventive counterpart to codebase-audit)
- `/stn-skills:codebase-quality-bootstrap` slash command

### Changed
- Restructured docs for multi-skill suite architecture
- Rewrite codebase-quality-bootstrap README to match codebase-audit quality
- Add hookify rule to block AI attribution in commits
- Add .gitignore to exclude .claude/ directory

## [2.0.0] - 2026-04-09

### Added
- Standalone plugin with remediation execution
- Marketplace registration (`marketplace.json`)
- `/stn-skills:codebase-audit` slash command
- Enterprise upgrade: confidence scores, effort estimates, enriched auditors
- Suppression syntax, Mermaid diagrams, conflict detection, CI/CD docs

### Changed
- Renamed plugin to stn-skills (Sven Thiermann skill suite)
- Restructured as multi-skill suite
- Fixed header consistency, coverage tables, docs
- Added missing domains to plugin.json description and keywords

## [1.0.0] - 2026-04-09

### Added
- Initial release: comprehensive, technology-agnostic codebase audit skill for Claude Code
- 13-domain evidence-based repository audit
- 17 specialized agent prompts
- Severity rules and report template
