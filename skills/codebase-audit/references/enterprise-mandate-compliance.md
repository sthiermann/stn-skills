# Enterprise Mandate Compliance

When CLAUDE.md or project rules define non-negotiable mandates, the enterprise-mandates-auditor evaluates compliance. The standard mandates (configurable per project):

| Mandate | Target state |
|---------|-------------|
| **Current APIs exclusively** | All code uses current, officially recommended APIs and language idioms |
| **Clean-slate architecture** | The codebase operates without migration scripts, transition logic, or compatibility layers |
| **State-of-the-art practices** | Every component applies current best practices for its technology |
| **Forward-only development** | Code contains no backward compatibility shims, version checks, or legacy adapters |
| **Unified codebase** | No code is labeled "new", "old", "legacy", or "replaced" -- everything is the current state |
| **Complete implementations** | No partial patches, minimal diffs, or preservation of outdated structures |
| **Zero legacy assumptions** | No code assumes pre-existing users, data, schemas, or runtime dependencies |
