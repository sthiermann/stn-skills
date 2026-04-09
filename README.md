<div align="center">

# stn-skills

**Professional Claude Code skill suite by Sven Thiermann**

<p>
  <img src="https://img.shields.io/badge/version-2.1.0-blue?style=flat-square" alt="Version">
  <img src="https://img.shields.io/badge/license-MIT-green?style=flat-square" alt="License">
  <img src="https://img.shields.io/badge/skills-1-brightgreen?style=flat-square" alt="Skills">
</p>

</div>

A curated collection of high-quality Claude Code skills for professional software engineering workflows. Each skill is independently usable, thoroughly documented, and built to enterprise standards.

---

## Available Skills

| Skill | Invoke | Description | Docs |
|-------|--------|-------------|------|
| **Codebase Audit** | `stn-skills:codebase-audit` | 13-domain evidence-based repository audit with confidence scoring, effort estimation, and optional auto-fix. Covers security, architecture, performance, data privacy, and 9 more domains. | [Details](skills/codebase-audit/README.md) |

---

## Install

Run these two commands inside Claude Code (not in your terminal):

```
/plugin marketplace add sthiermann/stn-skills
/plugin install stn-skills
```

All skills are available immediately after installation.

---

## Quick Start

### Codebase Audit

```
/stn-skills:codebase-audit
```

Or use natural language: `Audit this repository` | `Review the codebase for production readiness` | `Run a code health check` | `Check this repo for security issues`

---

## Plugin Structure

```
stn-skills/
|
|-- .claude-plugin/
|   |-- plugin.json                          # Plugin metadata
|   +-- marketplace.json                     # Marketplace registration
|
|-- commands/
|   +-- codebase-audit.md                    # /stn-skills:codebase-audit
|
|-- skills/
|   +-- codebase-audit/                      # Codebase Audit skill
|       |-- README.md                        # Skill documentation
|       |-- SKILL.md                         # Orchestration (5 phases, 3 gates)
|       |-- agents/                          # 17 specialized agent prompts
|       +-- references/                      # Severity rules, report template
|
|-- README.md                                # This file (suite overview)
+-- LICENSE
```

---

## Contributing

Contributions are welcome — whether improving existing skills or proposing new ones.

**Improving an existing skill:**
1. Fork the repository
2. Make your changes in the relevant `skills/` directory
3. Ensure all changes follow the skill's canonical format (see its `SKILL.md`)
4. Submit a pull request with a clear description

**Proposing a new skill:**
1. Open an issue describing the skill's purpose and scope
2. Each skill lives in its own `skills/{skill-name}/` directory
3. Every skill needs: `SKILL.md` (prompt), `README.md` (documentation)
4. Follow existing patterns for agent structure and finding formats

**Guidelines:**
- Skills use universal principles, not language-specific rules
- Every skill must be independently usable
- Documentation is as important as the prompt

---

## License

MIT
