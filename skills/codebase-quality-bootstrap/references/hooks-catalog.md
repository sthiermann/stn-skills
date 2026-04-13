# Hooks Catalog

Tech-stack-specific hook patterns for `.claude/settings.json`.

## Hook Structure
```json
{ "hooks": { "{EventType}": [{ "matcher": "{ToolNameRegex}", "hooks": [{ "type": "command", "command": "{cmd}", "timeout": {s} }] }] } }
```
**Event types:** `PostToolUse` (auto-format, auto-test), `PreToolUse` (block protected files)
**Matcher:** Regex against tool name. `Edit|Write|MultiEdit` catches all file modifications.
**Env vars:** `$CLAUDE_FILE_PATH` (file path), `$CLAUDE_TOOL_NAME` (tool name)

## File Extension Guards
Every auto-format hook MUST filter by extension: `case "$CLAUDE_FILE_PATH" in *.py) cmd ;; esac 2>/dev/null || true`

## Hook 1: Auto-Format on Edit/Write
**Event:** PostToolUse | **Matcher:** `Edit|Write|MultiEdit`
**Prevents:** QUAL (formatting), DEAD (unused imports via linter), DEPR (deprecated APIs via linter)

### JavaScript/TypeScript
**Prettier** (`.prettierrc*`, `prettier.config.*`, `prettier` in package.json):
```json
{ "type": "command", "command": "case \"$CLAUDE_FILE_PATH\" in *.ts|*.tsx|*.js|*.jsx|*.json|*.css|*.md) npx prettier --write \"$CLAUDE_FILE_PATH\" ;; esac 2>/dev/null || true", "timeout": 30 }
```
**ESLint** (`eslint.config.*`, `.eslintrc*`, `eslint` in package.json):
```json
{ "type": "command", "command": "case \"$CLAUDE_FILE_PATH\" in *.ts|*.tsx|*.js|*.jsx) npx eslint --fix \"$CLAUDE_FILE_PATH\" ;; esac 2>/dev/null || true", "timeout": 30 }
```
**Biome** (`biome.json`, `@biomejs/biome` in package.json):
```json
{ "type": "command", "command": "case \"$CLAUDE_FILE_PATH\" in *.ts|*.tsx|*.js|*.jsx|*.json|*.css) npx @biomejs/biome check --fix \"$CLAUDE_FILE_PATH\" ;; esac 2>/dev/null || true", "timeout": 30 }
```
**Combined Prettier + ESLint:**
```json
{ "type": "command", "command": "case \"$CLAUDE_FILE_PATH\" in *.ts|*.tsx|*.js|*.jsx) npx prettier --write \"$CLAUDE_FILE_PATH\"; npx eslint --fix \"$CLAUDE_FILE_PATH\" ;; *.json|*.css|*.md) npx prettier --write \"$CLAUDE_FILE_PATH\" ;; esac 2>/dev/null || true", "timeout": 30 }
```

### Python
**Ruff** (`ruff.toml`, `[tool.ruff]` in pyproject.toml, `ruff` in requirements):
```json
{ "type": "command", "command": "case \"$CLAUDE_FILE_PATH\" in *.py) ruff check --fix \"$CLAUDE_FILE_PATH\"; ruff format \"$CLAUDE_FILE_PATH\" ;; esac 2>/dev/null || true", "timeout": 30 }
```
**Black + isort** (`[tool.black]`/`[tool.isort]` in pyproject.toml):
```json
{ "type": "command", "command": "case \"$CLAUDE_FILE_PATH\" in *.py) black \"$CLAUDE_FILE_PATH\"; isort \"$CLAUDE_FILE_PATH\" ;; esac 2>/dev/null || true", "timeout": 30 }
```

### Other Languages
All follow pattern: `{ "type": "command", "command": "case \"$CLAUDE_FILE_PATH\" in {exts}) {cmd} ;; esac 2>/dev/null || true", "timeout": {t} }`

| Language | Tool | Detection | Extensions | Command | Timeout |
|----------|------|-----------|------------|---------|---------|
| Go | gofmt | always | `*.go` | `gofmt -w "$CLAUDE_FILE_PATH"` | 15 |
| Rust | rustfmt | always | `*.rs` | `rustfmt "$CLAUDE_FILE_PATH"` | 15 |
| Java | google-java-format | build plugin | `*.java` | `google-java-format --replace "$CLAUDE_FILE_PATH"` | 30 |
| Kotlin | ktlint | build plugin | `*.kt\|*.kts` | `ktlint --format "$CLAUDE_FILE_PATH"` | 30 |
| C/C++ | clang-format | `.clang-format` | `*.c\|*.h\|*.cpp\|*.hpp\|*.cc\|*.cxx` | `clang-format -i "$CLAUDE_FILE_PATH"` | 15 |
| Ruby | rubocop | `.rubocop.yml` | `*.rb\|*.rake\|Gemfile\|Rakefile` | `rubocop --autocorrect "$CLAUDE_FILE_PATH"` | 30 |
| PHP | PHP-CS-Fixer | `.php-cs-fixer.php` | `*.php` | `php-cs-fixer fix "$CLAUDE_FILE_PATH"` | 30 |
| Dart | dart format | always | `*.dart` | `dart format "$CLAUDE_FILE_PATH"` | 15 |
| Swift | swift-format | `.swift-format` | `*.swift` | `swift-format format --in-place "$CLAUDE_FILE_PATH"` | 15 |
| Elixir | mix format | always | `*.ex\|*.exs` | `mix format "$CLAUDE_FILE_PATH"` | 15 |

## Hook 2: Block Protected File Edits
**Event:** PreToolUse | **Matcher:** `Edit|Write|MultiEdit`
**Prevents:** SEC (secrets exposure), INFRA (lock file corruption), PRIV (credential protection)

```json
{ "type": "command", "command": "case \"$CLAUDE_FILE_PATH\" in *.env|*.env.*|*credentials*|*secrets*|*.pem|*.key|*.p12|*.pfx|*.jks|*.keystore) echo '{\"decision\":\"block\",\"reason\":\"Protected file: direct edits to secrets, credentials, and key files are blocked.\"}' ;; *) echo '{}' ;; esac", "timeout": 5 }
```

**Lock file patterns** (add to case statement per detected stack):
- **Node.js:** `*/package-lock.json|*/yarn.lock|*/pnpm-lock.yaml`
- **Python:** `*/poetry.lock|*/Pipfile.lock|*/uv.lock`
- **Rust:** `*/Cargo.lock` | **Go:** `*/go.sum` | **Ruby:** `*/Gemfile.lock` | **PHP:** `*/composer.lock`

## Hook 3: Auto-Test on Edit (Optional)
**Event:** PostToolUse | **Matcher:** `Edit|Write|MultiEdit`
**Prevents:** TEST (continuous test execution)
**Condition:** Only generate when test runner detected and source/test naming conventions allow mapping.

### JavaScript/TypeScript (Jest)
```json
{ "type": "command", "command": "case \"$CLAUDE_FILE_PATH\" in *.ts|*.tsx|*.js|*.jsx) npx jest --findRelatedTests \"$CLAUDE_FILE_PATH\" --passWithNoTests ;; esac 2>/dev/null || true", "timeout": 60 }
```
### Python (pytest)
```json
{ "type": "command", "command": "case \"$CLAUDE_FILE_PATH\" in *.py) python -m pytest \"$(echo \"$CLAUDE_FILE_PATH\" | sed 's|/\\([^/]*\\)\\.py$|/test_\\1.py|')\" --no-header -q ;; esac 2>/dev/null || true", "timeout": 60 }
```
### Go
```json
{ "type": "command", "command": "case \"$CLAUDE_FILE_PATH\" in *.go) cd \"$(dirname \"$CLAUDE_FILE_PATH\")\" && go test ./... -count=1 -short ;; esac 2>/dev/null || true", "timeout": 60 }
```
### Rust
```json
{ "type": "command", "command": "case \"$CLAUDE_FILE_PATH\" in *.rs) cargo test --quiet ;; esac 2>/dev/null || true", "timeout": 120 }
```

## Hook Merging Rules
1. **Read** existing hooks completely before generating
2. **Preserve** all existing hooks that do not conflict
3. **Detect conflicts:** Same event type + overlapping matcher regex
4. **Present conflicts** to user at GATE 2 for decision
5. **Never** silently overwrite existing hooks
