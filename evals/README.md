# stn-skills Eval Suite

Lightweight evaluation framework for measuring skill reliability.

## Evals

| Script | Requires Claude CLI | What it checks |
|--------|-------------------|----------------|
| `eval-structure.sh` | No | File structure, line counts, frontmatter, consistency |
| `eval-activation.sh` | Yes | Skill activation rate for relevant prompts |

## Usage

```bash
# Run all evals
./evals/eval-runner.sh

# Run specific eval
./evals/eval-runner.sh --test structure

# Verbose output
./evals/eval-runner.sh --verbose

# Run structure eval standalone (no claude CLI needed)
./evals/eval-structure.sh
```

## Adding Prompts

Add trigger prompts to `prompts/<skill-name>.txt`, one per line. Lines starting with `#` are comments.

## Results

Reports are saved to `evals/results/` with timestamps.
