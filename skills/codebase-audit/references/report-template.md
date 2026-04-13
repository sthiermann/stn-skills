# Audit Report Template

Use this exact structure. Replace all placeholders with actual data. Findings receive stable IDs (F1, F2, ...) in severity order (Critical, High, Medium, Low), used for GATE 3 remediation selection.

---

```markdown
# Codebase Audit Report — {{REPO_NAME}}

**Date:** {{DATE}}  |  **Tech Stack:** {{DETECTED_STACK}}
**Scope:** {{AUDITED_MODULES}}  |  **Audit Domains:** {{DOMAINS_AUDITED}}

---

## Executive Summary

- **Total findings:** {{TOTAL}} ({{CRITICAL}} Critical, {{HIGH}} High, {{MEDIUM}} Medium, {{LOW}} Low)
- **Verification:** {{VERIFIED_COUNT}} verified, {{FP_COUNT}} false positives removed ({{FP_RATE}}%)
- **Domains re-audited:** {{RE_AUDIT_LIST or "none"}}
- **Top priorities:** 1) {{TOP_PRIORITY_1}}  2) {{TOP_PRIORITY_2}}  3) {{TOP_PRIORITY_3}}
- **Deploy recommendation:** {{BLOCK_DEPLOY | DEPLOY_WITH_CAUTION | SHIP_IT}}

---

## Enterprise Mandate Compliance Matrix

| # | Mandate | Status | Violations | Evidence |
|---|---------|--------|------------|----------|
| 1 | Current APIs exclusively | {{PASS/FAIL}} | {{COUNT}} | {{EVIDENCE_REF}} |
| 2 | Clean-slate architecture | {{PASS/FAIL}} | {{COUNT}} | {{EVIDENCE_REF}} |
| 3 | State-of-the-art practices | {{PASS/FAIL}} | {{COUNT}} | {{EVIDENCE_REF}} |
| 4 | Forward-only development | {{PASS/FAIL}} | {{COUNT}} | {{EVIDENCE_REF}} |
| 5 | Unified codebase | {{PASS/FAIL}} | {{COUNT}} | {{EVIDENCE_REF}} |
| 6 | Complete implementations | {{PASS/FAIL}} | {{COUNT}} | {{EVIDENCE_REF}} |
| 7 | Zero legacy assumptions | {{PASS/FAIL}} | {{COUNT}} | {{EVIDENCE_REF}} |

---

## Findings by Severity

### Critical (fix immediately)
{{FOR_EACH_CRITICAL_FINDING}}
**F{{ID}} [CRITICAL] {{DOMAIN_CODE}}: {{TITLE}}**
- **File:** `{{FILE_PATH}}:{{LINE_RANGE}}` | **Confidence:** {{CONFIDENCE}}
- **Evidence:** {{CODE_SNIPPET_OR_DESCRIPTION}}
- **Impact:** {{WHAT_HAPPENS_IF_NOT_FIXED}}
- **Remediation:** {{SPECIFIC_ACTION_WITH_CODE_EXAMPLE}}
- **Effort:** {{EFFORT}} | **Risk:** {{RISK}}
{{END_FOR_EACH}}

### High (fix this sprint)
{{FOR_EACH_HIGH_FINDING}}
**F{{ID}} [HIGH] {{DOMAIN_CODE}}: {{TITLE}}**
- **File:** `{{FILE_PATH}}:{{LINE_RANGE}}` | **Confidence:** {{CONFIDENCE}}
- **Evidence:** {{CODE_SNIPPET_OR_DESCRIPTION}}
- **Impact:** {{WHAT_HAPPENS_IF_NOT_FIXED}}
- **Remediation:** {{SPECIFIC_ACTION_WITH_CODE_EXAMPLE}}
- **Effort:** {{EFFORT}} | **Risk:** {{RISK}}
{{END_FOR_EACH}}

### Medium (fix this cycle)
{{FOR_EACH_MEDIUM_FINDING}}
**F{{ID}} [MEDIUM] {{DOMAIN_CODE}}: {{TITLE}}**
- **File:** `{{FILE_PATH}}:{{LINE_RANGE}}` | **Confidence:** {{CONFIDENCE}}
- **Evidence:** {{CODE_SNIPPET_OR_DESCRIPTION}}
- **Impact:** {{WHAT_HAPPENS_IF_NOT_FIXED}}
- **Remediation:** {{SPECIFIC_ACTION_WITH_CODE_EXAMPLE}}
- **Effort:** {{EFFORT}} | **Risk:** {{RISK}}
{{END_FOR_EACH}}

### Low (track)
{{FOR_EACH_LOW_FINDING}}
**F{{ID}} [LOW] {{DOMAIN_CODE}}: {{TITLE}}**
- **File:** `{{FILE_PATH}}:{{LINE_RANGE}}` | **Confidence:** {{CONFIDENCE}}
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

### Pipeline Escalation Candidates

Findings marked `[PIPELINE]` benefit from structured design exploration (`/stn-skills:brainstorming`) or verified multi-step execution (`/stn-skills:plan-writing`) rather than direct surgical fixes.

| Finding | Title | Effort | Risk | Reason for Escalation |
|---------|-------|--------|------|-----------------------|
{{FOR_EACH_PIPELINE_FINDING}}
| F{{ID}} [PIPELINE] | {{TITLE}} | {{EFFORT}} | {{RISK}} | {{ESCALATION_REASON}} |
{{END_FOR_EACH}}

---

## Evidence Index

{{FOR_EACH_DOMAIN}}
#### {{DOMAIN_NAME}} ({{FINDING_COUNT}} findings)
- `{{FILE_PATH}}:{{LINE}}` — F{{ID}} {{BRIEF_DESCRIPTION}}
{{END_FOR_EACH}}

---

## Audit Methodology & Verification Statistics

- **Domains audited:** {{DOMAIN_LIST}} | **Files examined:** {{FILE_COUNT}} across {{MODULE_COUNT}} modules
- **Pre-verification:** {{PRE_VERIFICATION_COUNT}} | **Post-verification:** {{TOTAL}} | **FP removed:** {{FP_COUNT}} ({{FP_RATE}}%)
- **Suppressed:** {{SUPPRESSED_COUNT}} ({{SUPPRESSED_PER_DOMAIN}}) | **Re-audited:** {{RE_AUDIT_LIST or "none"}}
```
