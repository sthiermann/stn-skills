---
name: no-co-authored-by
enabled: true
event: bash
pattern: (?i)co-authored-by\s*:|noreply@anthropic\.com
action: block
---

BLOCKED: Commit contains AI co-author attribution.

The user does not want Co-Authored-By lines or any AI attribution in git commits. Only Sven Thiermann should appear as author.

**Fix:** Remove the Co-Authored-By line from the commit message and retry the commit.
