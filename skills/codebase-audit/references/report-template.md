# Audit Report Template

Use this exact structure for the final audit report. Replace all placeholders with actual data.

---

```markdown
# Codebase Audit Report — {{REPO_NAME}}

**Date:** {{DATE}}
**Tech Stack:** {{DETECTED_STACK}}
**Scope:** {{AUDITED_MODULES}}
**Audit Domains:** {{DOMAINS_AUDITED}}

---

## Executive Summary

- **Total findings:** {{TOTAL}} ({{CRITICAL}} Critical, {{HIGH}} High, {{MEDIUM}} Medium, {{LOW}} Low)
- **Verification:** {{VERIFIED_COUNT}} findings verified, {{FP_COUNT}} false positives removed
- **Top priorities:**
  1. {{TOP_PRIORITY_1}}
  2. {{TOP_PRIORITY_2}}
  3. {{TOP_PRIORITY_3}}

---

## Enterprise Mandate Compliance

| # | Mandate | Status | Violations | Evidence |
|---|---------|--------|------------|----------|
| 1 | Current APIs and idioms only | {{PASS/FAIL}} | {{COUNT}} | {{EVIDENCE_REF}} |
| 2 | Clean-slate system (no migration/compat logic) | {{PASS/FAIL}} | {{COUNT}} | {{EVIDENCE_REF}} |
| 3 | State-of-the-art standards | {{PASS/FAIL}} | {{COUNT}} | {{EVIDENCE_REF}} |
| 4 | Forward-only (no backward compatibility) | {{PASS/FAIL}} | {{COUNT}} | {{EVIDENCE_REF}} |
| 5 | Unified codebase (no old/new labeling) | {{PASS/FAIL}} | {{COUNT}} | {{EVIDENCE_REF}} |
| 6 | Full rewrite approach | {{PASS/FAIL}} | {{COUNT}} | {{EVIDENCE_REF}} |
| 7 | Zero legacy assumptions | {{PASS/FAIL}} | {{COUNT}} | {{EVIDENCE_REF}} |

---

## Critical Findings (fix immediately)

{{FOR_EACH_CRITICAL_FINDING}}

**[CRITICAL] {{DOMAIN_CODE}}: {{TITLE}}**
- **File:** `{{FILE_PATH}}:{{LINE_RANGE}}`
- **Evidence:** {{CODE_SNIPPET_OR_DESCRIPTION}}
- **Impact:** {{WHAT_HAPPENS_IF_NOT_FIXED}}
- **Remediation:** {{SPECIFIC_ACTION_WITH_CODE_EXAMPLE}}

{{END_FOR_EACH}}

---

## High Findings (fix this sprint)

{{FOR_EACH_HIGH_FINDING}}

**[HIGH] {{DOMAIN_CODE}}: {{TITLE}}**
- **File:** `{{FILE_PATH}}:{{LINE_RANGE}}`
- **Evidence:** {{CODE_SNIPPET_OR_DESCRIPTION}}
- **Impact:** {{WHAT_HAPPENS_IF_NOT_FIXED}}
- **Remediation:** {{SPECIFIC_ACTION_WITH_CODE_EXAMPLE}}

{{END_FOR_EACH}}

---

## Medium Findings (fix this cycle)

{{FOR_EACH_MEDIUM_FINDING}}

**[MEDIUM] {{DOMAIN_CODE}}: {{TITLE}}**
- **File:** `{{FILE_PATH}}:{{LINE_RANGE}}`
- **Evidence:** {{CODE_SNIPPET_OR_DESCRIPTION}}
- **Impact:** {{WHAT_HAPPENS_IF_NOT_FIXED}}
- **Remediation:** {{SPECIFIC_ACTION_WITH_CODE_EXAMPLE}}

{{END_FOR_EACH}}

---

## Low Findings (track)

{{FOR_EACH_LOW_FINDING}}

**[LOW] {{DOMAIN_CODE}}: {{TITLE}}**
- **File:** `{{FILE_PATH}}:{{LINE_RANGE}}`
- **Evidence:** {{CODE_SNIPPET_OR_DESCRIPTION}}
- **Remediation:** {{SUGGESTED_IMPROVEMENT}}

{{END_FOR_EACH}}

---

## Remediation Roadmap

### Immediate (this week)
{{CRITICAL_FINDINGS_SUMMARIZED_WITH_EFFORT_ESTIMATE}}

### Short-term (this sprint)
{{HIGH_FINDINGS_SUMMARIZED_WITH_EFFORT_ESTIMATE}}

### Medium-term (this cycle)
{{MEDIUM_FINDINGS_GROUPED_BY_THEME}}

### Backlog
{{LOW_FINDINGS_GROUPED_BY_THEME}}

---

## Audit Methodology

- **Domains audited:** {{DOMAIN_LIST}}
- **Files examined:** {{FILE_COUNT}} source files across {{MODULE_COUNT}} modules
- **Findings before verification:** {{PRE_VERIFICATION_COUNT}}
- **False positives removed:** {{FP_COUNT}} ({{FP_RATE}}%)
- **Domains re-audited:** {{RE_AUDIT_LIST or "none"}}

---

## Evidence Index

### By Domain
{{FOR_EACH_DOMAIN}}
#### {{DOMAIN_NAME}} ({{FINDING_COUNT}} findings)
- `{{FILE_PATH}}:{{LINE}}` — {{BRIEF_DESCRIPTION}}
{{END_FOR_EACH}}
```
