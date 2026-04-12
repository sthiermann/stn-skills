# Placeholder Detector Rules

Exhaustive pattern catalog for plan verifier. Every code block in a plan is scanned against these rules. Any match = plan rejection.

## Literal String Patterns

Case-insensitive scan of all code blocks and inline code.

| Pattern | Category | Example Match |
|---------|----------|---------------|
| `TBD` | Deferred work | `const timeout = TBD;` |
| `TODO` | Deferred work | `// TODO: add validation` |
| `FIXME` | Known defect | `# FIXME: race condition` |
| `HACK` | Acknowledged shortcut | `// HACK: workaround for API bug` |
| `XXX` | Attention marker | `/* XXX needs review */` |
| `IMPLEMENT` | Missing logic | `// IMPLEMENT: auth check` |
| `PLACEHOLDER` | Stub content | `data = "PLACEHOLDER"` |
| `STUB` | Incomplete function | `return stub_response()` |
| `MOCK_DATA` | Fake data | `users = MOCK_DATA` |
| `SAMPLE_DATA` | Fake data | `load(SAMPLE_DATA)` |
| `YOUR_` | User-fill token | `api_key = "YOUR_KEY_HERE"` |
| `CHANGEME` | User-fill token | `password = "CHANGEME"` |
| `REPLACE_THIS` | User-fill token | `url = "REPLACE_THIS"` |

## Code Patterns

Structural patterns indicating incomplete implementation.

| Pattern | Category | Example Match |
|---------|----------|---------------|
| `...` (ellipsis in code block) | Omitted code | `function init() { ... }` |
| `pass` as sole function body | Empty Python function | `def process(data):\n    pass` |
| `raise NotImplementedError` as sole body | Unimplemented Python | `def save(self): raise NotImplementedError` |
| `throw new Error("not implemented")` | Unimplemented JS/TS | `save() { throw new Error("not implemented") }` |
| `panic!("not implemented")` | Unimplemented Rust | `fn save(&self) { panic!("not implemented") }` |
| `unimplemented!()` | Unimplemented Rust | `fn process() { unimplemented!() }` |
| `todo!()` | Deferred Rust | `fn validate() { todo!() }` |
| Empty function body `{}` or `{ }` | No-op function | `function validate() {}` |
| `// implement`, `# implement`, `/* implement */` | Deferred comment | `// implement error handling` |
| `return null;` / `return None` as sole body | Stub return (non-void) | `function getUser() { return null; }` |
| `return undefined;` as sole body | Stub return | `getConfig() { return undefined; }` |
| `return 0;` / `return ""` as sole body | Stub return | `int count() { return 0; }` |

## Natural Language Patterns in Code Comments

Comments inside code blocks that signal omitted logic.

| Pattern | Category | Example Match |
|---------|----------|---------------|
| "similar to above" | Reference to elided code | `// similar to above but for updates` |
| "as shown earlier" | Reference to elided code | `# as shown earlier` |
| "add appropriate" | Vague instruction | `// add appropriate error handling` |
| "handle errors" | Vague instruction | `# handle errors here` |
| "add validation" | Deferred work | `// add validation logic` |
| "write tests" | Deferred work | `# write tests for this` |
| "see documentation" | External reference | `// see documentation for options` |
| "fill in" | Incomplete | `/* fill in the details */` |
| "complete this" | Incomplete | `// complete this function` |
| "add logic" | Deferred work | `# add logic for edge cases` |
| "implement here" | Deferred work | `// implement here` |
| "add remaining" | Incomplete | `// add remaining fields` |
| Sentence ending with "etc." | Enumeration shortcut | `// handle POST, PUT, DELETE, etc.` |

## Structural Patterns

Cross-step validation failures detected by plan structure analysis.

| Pattern | Category | Detection Method |
|---------|----------|-----------------|
| Declared function, no implementation steps | Ghost function | Function appears in file structure but no `write_code` step creates it |
| Test file referenced, no test-writing steps | Ghost test | `files_modified` lists test file but no step writes test code |
| Import of uncreated module | Dangling import | `import X from './Y'` where no step creates `Y` |
| `files_modified` entry with no write step | Phantom file | File listed in task metadata but zero `write_code` steps target it |
| Config value referenced but never set | Missing setup | Code reads `process.env.X` but no step creates `.env` entry |
| Route/endpoint declared but handler missing | Incomplete wiring | Router maps path but no step implements handler function |

## Scan Precedence

1. Literal string patterns (fastest, regex match)
2. Code patterns (AST-lite heuristic match)
3. Natural language patterns (comment extraction + match)
4. Structural patterns (cross-step graph analysis)

Any single match at any level = plan rejection with exact location and pattern ID reported.
