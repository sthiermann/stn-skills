# Audit Report Template

Use this exact structure for the final audit report. Replace all placeholders with actual data. Every finding receives a stable ID (F1, F2, ...) assigned in order of appearance (Critical first, then High, Medium, Low). These IDs are used for GATE 3 remediation selection.

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
- **Verification:** {{VERIFIED_COUNT}} findings verified, {{FP_COUNT}} false positives removed ({{FP_RATE}}%)
- **Domains re-audited:** {{RE_AUDIT_LIST or "none"}}
- **Top priorities:**
  1. {{TOP_PRIORITY_1}}
  2. {{TOP_PRIORITY_2}}
  3. {{TOP_PRIORITY_3}}

---

## Enterprise Mandate Compliance Matrix

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

## Findings by Severity

### Critical (fix immediately)

{{FOR_EACH_CRITICAL_FINDING}}

**F{{ID}} [CRITICAL] {{DOMAIN_CODE}}: {{TITLE}}**
- **File:** `{{FILE_PATH}}:{{LINE_RANGE}}`
- **Confidence:** {{CONFIDENCE}}
- **Evidence:** {{CODE_SNIPPET_OR_DESCRIPTION}}
- **Impact:** {{WHAT_HAPPENS_IF_NOT_FIXED}}
- **Remediation:** {{SPECIFIC_ACTION_WITH_CODE_EXAMPLE}}
- **Effort:** {{EFFORT}} | **Risk:** {{RISK}}

{{END_FOR_EACH}}

### High (fix this sprint)

{{FOR_EACH_HIGH_FINDING}}

**F{{ID}} [HIGH] {{DOMAIN_CODE}}: {{TITLE}}**
- **File:** `{{FILE_PATH}}:{{LINE_RANGE}}`
- **Confidence:** {{CONFIDENCE}}
- **Evidence:** {{CODE_SNIPPET_OR_DESCRIPTION}}
- **Impact:** {{WHAT_HAPPENS_IF_NOT_FIXED}}
- **Remediation:** {{SPECIFIC_ACTION_WITH_CODE_EXAMPLE}}
- **Effort:** {{EFFORT}} | **Risk:** {{RISK}}

{{END_FOR_EACH}}

### Medium (fix this cycle)

{{FOR_EACH_MEDIUM_FINDING}}

**F{{ID}} [MEDIUM] {{DOMAIN_CODE}}: {{TITLE}}**
- **File:** `{{FILE_PATH}}:{{LINE_RANGE}}`
- **Confidence:** {{CONFIDENCE}}
- **Evidence:** {{CODE_SNIPPET_OR_DESCRIPTION}}
- **Impact:** {{WHAT_HAPPENS_IF_NOT_FIXED}}
- **Remediation:** {{SPECIFIC_ACTION_WITH_CODE_EXAMPLE}}
- **Effort:** {{EFFORT}} | **Risk:** {{RISK}}

{{END_FOR_EACH}}

### Low (track)

{{FOR_EACH_LOW_FINDING}}

**F{{ID}} [LOW] {{DOMAIN_CODE}}: {{TITLE}}**
- **File:** `{{FILE_PATH}}:{{LINE_RANGE}}`
- **Confidence:** {{CONFIDENCE}}
- **Evidence:** {{CODE_SNIPPET_OR_DESCRIPTION}}
- **Impact:** {{IMPACT}}
- **Remediation:** {{SUGGESTED_IMPROVEMENT}}
- **Effort:** {{EFFORT}} | **Risk:** {{RISK}}

{{END_FOR_EACH}}

---

## Remediation Roadmap

**Total estimated effort:** {{TOTAL_EFFORT_RANGE}}
**Deploy recommendation:** {{BLOCK_DEPLOY / DEPLOY_WITH_CAUTION / SHIP_IT}}

### Immediate (this week)

| Finding | Title | Effort | Risk | Confidence |
|---------|-------|--------|------|------------|
{{FOR_EACH_CRITICAL_FINDING}}
| F{{ID}} | {{TITLE}} | {{EFFORT}} | {{RISK}} | {{CONFIDENCE}} |
{{END_FOR_EACH}}

### Short-term (this sprint)

| Finding | Title | Effort | Risk | Confidence |
|---------|-------|--------|------|------------|
{{FOR_EACH_HIGH_FINDING}}
| F{{ID}} | {{TITLE}} | {{EFFORT}} | {{RISK}} | {{CONFIDENCE}} |
{{END_FOR_EACH}}

### Medium-term (this cycle)

| Module | Findings | Combined Effort | Batch Description |
|--------|----------|----------------|-------------------|
{{FOR_EACH_MODULE_GROUP}}
| {{MODULE}} | F{{IDs}} | {{COMBINED_EFFORT}} | {{BATCH_DESCRIPTION}} |
{{END_FOR_EACH}}

### Backlog

| Category | Count | Quick Wins (Trivial effort) |
|----------|-------|-----------------------------|
{{FOR_EACH_LOW_CATEGORY}}
| {{CATEGORY}} | {{COUNT}} | {{TRIVIAL_ITEMS_OR_DASH}} |
{{END_FOR_EACH}}

---

## Evidence Index

### By Domain
{{FOR_EACH_DOMAIN}}
#### {{DOMAIN_NAME}} ({{FINDING_COUNT}} findings)
- `{{FILE_PATH}}:{{LINE}}` — F{{ID}} {{BRIEF_DESCRIPTION}}
{{END_FOR_EACH}}

---

## Audit Methodology & Verification Statistics

- **Domains audited:** {{DOMAIN_LIST}}
- **Files examined:** {{FILE_COUNT}} source files across {{MODULE_COUNT}} modules
- **Findings before verification:** {{PRE_VERIFICATION_COUNT}}
- **Findings after verification:** {{TOTAL}}
- **False positives removed:** {{FP_COUNT}} ({{FP_RATE}}%)
- **Findings suppressed:** {{SUPPRESSED_COUNT}} ({{SUPPRESSED_PER_DOMAIN}})
- **Domains re-audited:** {{RE_AUDIT_LIST or "none"}}
```
