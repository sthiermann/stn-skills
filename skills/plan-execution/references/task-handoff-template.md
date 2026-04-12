# Task Handoff Template

Structured context transfer between sequential tasks. Target: ~500 tokens.

## Template

```markdown
## Handoff: T{N-1} → T{N}

### Completed
- [x] {what was accomplished, one line per item}
- [x] {what was accomplished, one line per item}

### Files Modified
- `{path}` — {one-line change summary}
- `{path}` — {one-line change summary}

### Key Decisions
- {decision made during implementation} — because {rationale}

### Rejected Approaches
- Tried {approach} — failed because {reason}

### Public API Additions
- `{function/type/export}` in `{file}` — {purpose}

### Blockers Resolved
- {blocker that was resolved and how, if any}
```

## Rules

### Token Budget

Target ~500 tokens. Hard cap at 600. Exceed = trim lowest-value sections first:
1. Blockers Resolved (cut if none)
2. Public API Additions (cut if none)
3. Key Decisions (summarize to one line)

### Must Include

- **Completed**: what succeeded. Downstream tasks depend on knowing what exists.
- **Files Modified**: where changes landed. Prevents duplicate work and merge conflicts.
- **Rejected Approaches**: highest-value context. Prevents repeating failed strategies.

### Must Exclude

- Debug output or stack traces
- Exploration history (tool calls, search results)
- Raw command output
- Verbose reasoning or deliberation
- Anything the next task can derive from reading the code

### Section Guidelines

**Completed**: One checkbox line per deliverable. Verb + noun. No explanation.
```
- [x] Added auth middleware to Express router
- [x] Created user session schema in Prisma
```

**Files Modified**: Path + single clause. No line counts.
```
- `src/middleware/auth.ts` — new JWT validation middleware
- `prisma/schema.prisma` — added Session model
```

**Key Decisions**: Decision + rationale in one line.
```
- Used HS256 over RS256 — simpler key management, internal-only service
```

**Rejected Approaches**: What + why in one line. Most valuable section.
```
- Tried cookie-based sessions — failed because API clients lack browser context
- Tried passport.js — unnecessary abstraction for single auth strategy
```

**Public API Additions**: Exported symbols other tasks may need.
```
- `validateToken()` in `src/middleware/auth.ts` — validates JWT, returns decoded payload
- `Session` type in `prisma/schema.prisma` — stores active user sessions
```

**Blockers Resolved**: Only if a blocker was encountered and solved.
```
- bcrypt native module failed on ARM — switched to bcryptjs pure JS implementation
```

## Special Cases

### First Task (T1)

No prior handoff exists. Handoff section is empty:
```markdown
## Handoff: Start → T1

No prior task context. This is the first task in the plan.
```

### DONE_WITH_CONCERNS

Append concern to handoff:
```markdown
### Active Concerns
- {concern from previous task} — severity: {LOW|MEDIUM|HIGH}
```

### BLOCKED Task (Skipped)

If previous task was skipped:
```markdown
### Skipped Task Warning
- T{N-1} was BLOCKED: {reason}
- Impact on T{N}: {what might be missing or different}
```
