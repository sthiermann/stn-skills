# Finding Suppression

Teams can suppress known false positives or intentional patterns by adding suppression comments directly in source code. The findings verifier respects these annotations and excludes matching findings from the report.

## Suppression Syntax

Language-agnostic -- use the comment style of the file's language:

```
// audit-suppress: DOMAIN           -- suppress all findings of this domain for the next line
// audit-suppress: DOMAIN: reason   -- suppress with documented justification (recommended)
// audit-suppress: SEC,PERF         -- suppress multiple domains
// audit-suppress: *                -- suppress all audit findings for the next line
```

### Examples

```python
# audit-suppress: DEAD: intentionally unused -- reserved for plugin API
def on_plugin_load(ctx):
    pass
```

```java
// audit-suppress: SEC: CSRF not applicable -- internal microservice, no browser clients
@PostMapping("/internal/sync")
public void syncData(@RequestBody SyncRequest req) { ... }
```

### Block Suppression

For multi-line constructs:
```
// audit-suppress-start: DOMAIN: reason
... suppressed code block ...
// audit-suppress-end
```

Block suppression applies to all lines between the start and end markers. The same restrictions as single-line suppression apply: Critical findings with Confirmed confidence can never be suppressed. The domain code and reason are required on the start marker.

## Rules

- Suppression applies only to the **next line** after the comment (not the whole file)
- Suppression comments must include the domain code -- bare `audit-suppress` without a domain is ignored
- The `reason` field is optional but strongly recommended -- suppressions without reasons are flagged as Low findings by the enterprise-mandates auditor
- Suppressions are reported in the audit methodology section: count of suppressed findings per domain
- Suppressions do **not** hide Critical security findings with Confirmed confidence -- these are always reported regardless of suppression

## Verifier Integration

During **Phase 3 (Verification)**, the findings verifier:
1. For each finding, checks whether a suppression comment exists at the cited file:line
2. If a matching suppression is found, marks the finding as **Suppressed** (not False Positive -- suppression is intentional, not an error)
3. Records all suppressions in the verification output for transparency
