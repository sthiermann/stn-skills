# stn-skills Eval Suite

Lightweight evaluation framework for measuring skill reliability and hook enforcement.

## Evals

| Script | Requires Claude CLI | What it checks |
|--------|-------------------|----------------|
| `eval-behavior.sh` | No | 48 deterministic hook tests — kill-switches, blocking, allowing, path traversal, security, all 7 hooks |
| `eval-consistency.sh` | No | 88 cross-file consistency checks — agent refs, phase counts, protocol sync, domain alignment |
| `eval-structure.sh` | No | File structure, line counts, frontmatter, naming conventions |
| `eval-activation.sh` | Yes (Claude Code CLI) | Skill activation rate for relevant prompts |

## Usage

```bash
# Run all evals
./evals/eval-runner.sh

# Run specific eval
./evals/eval-runner.sh --test structure

# Verbose output
./evals/eval-runner.sh --verbose

# Run behavioral eval standalone (no Claude CLI needed)
./evals/eval-behavior.sh

# Run consistency eval standalone
./evals/eval-consistency.sh
```

## Coverage Matrix

`coverage-matrix.json` maps all 26 requirements (R1-R26) to implementing files, tasks, and eval checks. Every hook has at least one behavioral test.

## Adding Prompts

Add trigger prompts to `prompts/<skill-name>.txt`, one per line. Lines starting with `#` are comments.

## Results

Reports are saved to `evals/results/` with timestamps.
