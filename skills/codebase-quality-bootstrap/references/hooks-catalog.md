# Hooks Catalog

Tech-stack-specific hook patterns for `.claude/settings.json`. Analyzers reference this catalog to produce correct hook configurations.

## Hook Architecture

Claude Code hooks use this structure in `.claude/settings.json`:

```json
{
  "hooks": {
    "{EventType}": [
      {
        "matcher": "{ToolNameRegex}",
        "hooks": [
          {
            "type": "command",
            "command": "{shell command}",
            "timeout": {seconds}
          }
        ]
      }
    ]
  }
}
```

**Event types used by this skill:**
- `PostToolUse` -- Runs after a tool completes (auto-format, auto-test)
- `PreToolUse` -- Runs before a tool executes, can block (protected files)

**Matcher:** Regex against tool name. `Edit|Write|MultiEdit` catches all file modifications.

**Environment variables available in hooks:**
- `$CLAUDE_FILE_PATH` -- Path of the file being edited/written (Edit, Write, MultiEdit)
- `$CLAUDE_TOOL_NAME` -- Name of the tool being invoked

---

## Hook 1: Auto-Format on Edit/Write

**Event:** PostToolUse
**Matcher:** `Edit|Write|MultiEdit`
**Purpose:** Automatically format files after every modification
**Prevents audit findings in:** QUAL (formatting consistency), DEAD (unused imports via linter), DEPR (deprecated APIs via linter)

### JavaScript/TypeScript

**Prettier (detected via `.prettierrc*`, `prettier.config.*`, or `prettier` in package.json):**
```json
{
  "type": "command",
  "command": "npx prettier --write \"$CLAUDE_FILE_PATH\" 2>/dev/null || true",
  "timeout": 30
}
```

**ESLint + fix (detected via `eslint.config.*`, `.eslintrc*`, or `eslint` in package.json):**
```json
{
  "type": "command",
  "command": "npx eslint --fix \"$CLAUDE_FILE_PATH\" 2>/dev/null || true",
  "timeout": 30
}
```

**Biome (detected via `biome.json` or `@biomejs/biome` in package.json):**
```json
{
  "type": "command",
  "command": "npx @biomejs/biome check --fix \"$CLAUDE_FILE_PATH\" 2>/dev/null || true",
  "timeout": 30
}
```

**Combined Prettier + ESLint:**
```json
{
  "type": "command",
  "command": "npx prettier --write \"$CLAUDE_FILE_PATH\" 2>/dev/null; npx eslint --fix \"$CLAUDE_FILE_PATH\" 2>/dev/null || true",
  "timeout": 30
}
```

### Python

**Ruff (detected via `ruff.toml`, `[tool.ruff]` in pyproject.toml, or `ruff` in requirements/pyproject):**
```json
{
  "type": "command",
  "command": "ruff check --fix \"$CLAUDE_FILE_PATH\" 2>/dev/null; ruff format \"$CLAUDE_FILE_PATH\" 2>/dev/null || true",
  "timeout": 30
}
```

**Black + isort (detected via `[tool.black]`/`[tool.isort]` in pyproject.toml):**
```json
{
  "type": "command",
  "command": "black \"$CLAUDE_FILE_PATH\" 2>/dev/null; isort \"$CLAUDE_FILE_PATH\" 2>/dev/null || true",
  "timeout": 30
}
```

**autopep8 (detected via `[tool.autopep8]` or `autopep8` in requirements):**
```json
{
  "type": "command",
  "command": "autopep8 --in-place \"$CLAUDE_FILE_PATH\" 2>/dev/null || true",
  "timeout": 30
}
```

### Go

**gofmt (always available with Go):**
```json
{
  "type": "command",
  "command": "gofmt -w \"$CLAUDE_FILE_PATH\" 2>/dev/null || true",
  "timeout": 15
}
```

**goimports (detected via `golang.org/x/tools/cmd/goimports`):**
```json
{
  "type": "command",
  "command": "goimports -w \"$CLAUDE_FILE_PATH\" 2>/dev/null || true",
  "timeout": 15
}
```

### Rust

**rustfmt (always available with Rust, config in `rustfmt.toml` or `.rustfmt.toml`):**
```json
{
  "type": "command",
  "command": "rustfmt \"$CLAUDE_FILE_PATH\" 2>/dev/null || true",
  "timeout": 15
}
```

### Java/Kotlin

**google-java-format (detected via build plugin or config):**
```json
{
  "type": "command",
  "command": "google-java-format --replace \"$CLAUDE_FILE_PATH\" 2>/dev/null || true",
  "timeout": 30
}
```

**ktlint (detected via `ktlint` in build plugins):**
```json
{
  "type": "command",
  "command": "ktlint --format \"$CLAUDE_FILE_PATH\" 2>/dev/null || true",
  "timeout": 30
}
```

### C/C++

**clang-format (detected via `.clang-format`):**
```json
{
  "type": "command",
  "command": "clang-format -i \"$CLAUDE_FILE_PATH\" 2>/dev/null || true",
  "timeout": 15
}
```

### Ruby

**rubocop (detected via `.rubocop.yml` or `rubocop` in Gemfile):**
```json
{
  "type": "command",
  "command": "rubocop --autocorrect \"$CLAUDE_FILE_PATH\" 2>/dev/null || true",
  "timeout": 30
}
```

### PHP

**PHP-CS-Fixer (detected via `.php-cs-fixer.php` or config):**
```json
{
  "type": "command",
  "command": "php-cs-fixer fix \"$CLAUDE_FILE_PATH\" 2>/dev/null || true",
  "timeout": 30
}
```

### Dart/Flutter

**dart format (always available with Dart):**
```json
{
  "type": "command",
  "command": "dart format \"$CLAUDE_FILE_PATH\" 2>/dev/null || true",
  "timeout": 15
}
```

### Swift

**swift-format (detected via `.swift-format` or Package.swift dependency):**
```json
{
  "type": "command",
  "command": "swift-format format --in-place \"$CLAUDE_FILE_PATH\" 2>/dev/null || true",
  "timeout": 15
}
```

### Elixir

**mix format (always available with Elixir):**
```json
{
  "type": "command",
  "command": "mix format \"$CLAUDE_FILE_PATH\" 2>/dev/null || true",
  "timeout": 15
}
```

---

## Hook 2: Block Protected File Edits

**Event:** PreToolUse
**Matcher:** `Edit|Write|MultiEdit`
**Purpose:** Prevent direct edits to sensitive or managed files
**Prevents audit findings in:** SEC (secrets exposure), INFRA (lock file corruption), PRIV (credential protection)

### Universal (all tech stacks)

```json
{
  "type": "command",
  "command": "case \"$CLAUDE_FILE_PATH\" in *.env|*.env.*|*credentials*|*secrets*|*.pem|*.key|*.p12|*.pfx|*.jks|*.keystore) echo '{\"decision\":\"block\",\"reason\":\"Protected file: direct edits to secrets, credentials, and key files are blocked. Use environment variables or secret managers.\"}' ;; *) echo '{}' ;; esac",
  "timeout": 5
}
```

### Lock File Protection (stack-specific additions)

**Node.js (package-lock.json, yarn.lock, pnpm-lock.yaml):**
Add to the case pattern: `*/package-lock.json|*/yarn.lock|*/pnpm-lock.yaml`

**Python (poetry.lock, Pipfile.lock, uv.lock):**
Add to the case pattern: `*/poetry.lock|*/Pipfile.lock|*/uv.lock`

**Rust (Cargo.lock):**
Add to the case pattern: `*/Cargo.lock`

**Go (go.sum):**
Add to the case pattern: `*/go.sum`

**Ruby (Gemfile.lock):**
Add to the case pattern: `*/Gemfile.lock`

**PHP (composer.lock):**
Add to the case pattern: `*/composer.lock`

### Combined Pattern (all detected lock files merged)

Build the case pattern dynamically based on detected tech stack:

```
BASE_PATTERNS="*.env|*.env.*|*credentials*|*secrets*|*.pem|*.key|*.p12|*.pfx|*.jks|*.keystore"
LOCK_PATTERNS="{detected lock files joined with |}"
FULL_PATTERN="$BASE_PATTERNS|$LOCK_PATTERNS"
```

---

## Hook 3: Auto-Test on Edit (Optional)

**Event:** PostToolUse
**Matcher:** `Edit|Write|MultiEdit`
**Purpose:** Run related tests when source files change
**Prevents audit findings in:** TEST (continuous test execution)

**Only generate this hook when:**
1. A test runner is detected
2. Source/test file naming conventions allow mapping (e.g., `foo.ts` -> `foo.test.ts`)

### JavaScript/TypeScript

**Jest:**
```json
{
  "type": "command",
  "command": "npx jest --findRelatedTests \"$CLAUDE_FILE_PATH\" --passWithNoTests 2>/dev/null || true",
  "timeout": 60
}
```

**Vitest:**
```json
{
  "type": "command",
  "command": "npx vitest related \"$CLAUDE_FILE_PATH\" --run 2>/dev/null || true",
  "timeout": 60
}
```

### Python

**pytest:**
```json
{
  "type": "command",
  "command": "python -m pytest \"$(echo \"$CLAUDE_FILE_PATH\" | sed 's|/\\([^/]*\\)\\.py$|/test_\\1.py|')\" --no-header -q 2>/dev/null || true",
  "timeout": 60
}
```

### Go

**go test:**
```json
{
  "type": "command",
  "command": "cd \"$(dirname \"$CLAUDE_FILE_PATH\")\" && go test ./... -count=1 -short 2>/dev/null || true",
  "timeout": 60
}
```

### Rust

**cargo test:**
```json
{
  "type": "command",
  "command": "cargo test --quiet 2>/dev/null || true",
  "timeout": 120
}
```

---

## Hook Merging Rules

When generating hooks for a project with existing `.claude/settings.json`:

1. **Read** existing hooks completely before generating
2. **Preserve** all existing hooks that do not conflict
3. **Detect conflicts:** Same event type + overlapping matcher regex
4. **Present conflicts** to user at GATE 2 for decision
5. **Never** silently overwrite existing hooks

### Conflict Resolution Strategy

If an existing hook and a generated hook share the same event + matcher:
- Present both side-by-side
- User chooses: keep existing, replace with generated, or combine both commands in sequence
- Default recommendation: combine (existing command first, then generated command)
