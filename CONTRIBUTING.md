# Contributing

Contributions are welcome — whether improving existing skills or proposing new ones.

## Prerequisites

- [Claude Code](https://claude.ai/code), [Cursor](https://cursor.com), or [Copilot CLI](https://docs.github.com/en/copilot) installed
- Familiarity with skill-based AI coding tools and slash commands

## Local Testing

1. Fork and clone the repository
2. Install as a local plugin:
   ```
   /plugin install file:///path/to/your/stn-skills
   ```
3. Test your changes by invoking the skill in a real repository

## Skill Architecture

Each skill lives in `skills/{skill-name}/` and follows this structure:

| File | Purpose |
|------|---------|
| `SKILL.md` | Orchestration prompt (phases, gates, agent dispatch) |
| `README.md` | User-facing documentation |
| `agents/*.md` | Specialized agent prompts |
| `references/*.md` | Templates, rules, catalogs |

A matching entry in `commands/` provides the slash command.

## Agent Prompt Conventions

- Every agent receives context variables: `{{REPO_PATH}}`, `{{DETECTED_STACK}}`, `{{PROJECT_RULES}}`, `{{SCOPE}}`
- Every finding requires exact `file:line` evidence
- Use positive formulation: state what code SHOULD do, then show where it falls short
- Confidence levels: Confirmed > High > Medium > Low
- Effort estimates: Trivial / Small / Medium / Large

## Commit Conventions

- Imperative mood (`Add feature`, not `Added feature`)
- No Co-Authored-By lines
- Never commit the `.claude/` directory
- Keep commits focused on a single concern

## Evaluation Suite

Before submitting changes, run the full eval suite:

```bash
./evals/eval-runner.sh          # All evals
./evals/eval-behavior.sh        # 57 behavioral hook tests (no LLM calls)
./evals/eval-consistency.sh     # 88 cross-file consistency checks
./evals/eval-structure.sh       # File structure validation
```

All tests must pass. Zero failures is the quality bar.

## Pull Request Process

1. Open an issue first for new skills or major changes
2. Branch from `main`
3. Run `./evals/eval-runner.sh` — all tests must pass
4. Ensure SKILL.md, README.md, and plugin.json stay consistent
5. Test locally against a real repository
6. Submit PR with a clear description of what changed and why

## Quality Bar

- **Tech-stack-agnostic**: skills must work with any language and framework
- **Independently usable**: each skill stands alone
- **Evidence-based**: no vague claims, always cite file and line
- **Documentation parity**: match the quality level of existing skill docs
- **Version sync**: version must match across `plugin.json`, README.md badge, and CHANGELOG.md
