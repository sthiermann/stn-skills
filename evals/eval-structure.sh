#!/usr/bin/env bash
# stn-skills Structure Eval
# Validates skill file structure, line counts, and consistency.
# This eval runs without the claude CLI -- pure file system checks.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_DIR="${REPO_DIR}/skills"

pass=0
fail=0

pass_check() {
  echo "PASS: $1"
  pass=$((pass + 1))
}

fail_check() {
  echo "FAIL: $1"
  fail=$((fail + 1))
}

echo "Structure Eval"
echo "=============="
echo ""

# 1. All SKILL.md files exist
for skill in brainstorming plan-writing plan-execution build-feature codebase-audit codebase-quality-bootstrap pipeline-handoff-validator session-init; do
  if [[ -f "${SKILLS_DIR}/${skill}/SKILL.md" ]]; then
    pass_check "SKILL.md exists: $skill"
  else
    fail_check "SKILL.md exists: $skill"
  fi
done

# 2. All SKILL.md files under 500 lines
for skill_file in "$SKILLS_DIR"/*/SKILL.md; do
  skill_name=$(basename "$(dirname "$skill_file")")
  line_count=$(wc -l < "$skill_file" | tr -d ' ')
  if [[ "$line_count" -le 600 ]]; then
    pass_check "Under 600 lines: $skill_name ($line_count)"
  else
    fail_check "Under 600 lines: $skill_name ($line_count)"
  fi
done

# 3. All SKILL.md have YAML frontmatter with name and description
for skill_file in "$SKILLS_DIR"/*/SKILL.md; do
  skill_name=$(basename "$(dirname "$skill_file")")
  if head -15 "$skill_file" | grep -q '^name:'; then
    pass_check "Has frontmatter 'name': $skill_name"
  else
    fail_check "Has frontmatter 'name': $skill_name"
  fi
  if head -15 "$skill_file" | grep -q '^description:'; then
    pass_check "Has frontmatter 'description': $skill_name"
  else
    fail_check "Has frontmatter 'description': $skill_name"
  fi
done

# 4. All command files exist and have descriptions
for cmd in brainstorming plan-writing plan-execution build-feature codebase-audit codebase-quality-bootstrap pipeline-handoff-validator session-init; do
  cmd_file="${REPO_DIR}/commands/${cmd}.md"
  if [[ -f "$cmd_file" ]]; then
    pass_check "Command exists: $cmd"
  else
    fail_check "Command exists: $cmd"
  fi
  if [[ -f "$cmd_file" ]] && head -5 "$cmd_file" | grep -q 'description:'; then
    pass_check "Command has description: $cmd"
  else
    fail_check "Command has description: $cmd"
  fi
done

# 5. All agent files in skill directories exist (non-empty)
for skill_dir in "$SKILLS_DIR"/*/; do
  skill_name=$(basename "$skill_dir")
  [[ -d "${skill_dir}agents" ]] || continue
  for agent_file in "${skill_dir}agents/"*.md; do
    [[ -f "$agent_file" ]] || continue
    agent_name=$(basename "$agent_file")
    if [[ -s "$agent_file" ]]; then
      pass_check "Agent non-empty: ${skill_name}/${agent_name}"
    else
      fail_check "Agent non-empty: ${skill_name}/${agent_name}"
    fi
  done
done

# 6. All reference files in skill directories exist (non-empty)
for skill_dir in "$SKILLS_DIR"/*/; do
  skill_name=$(basename "$skill_dir")
  [[ -d "${skill_dir}references" ]] || continue
  for ref_file in "${skill_dir}references/"*.md; do
    [[ -f "$ref_file" ]] || continue
    ref_name=$(basename "$ref_file")
    if [[ -s "$ref_file" ]]; then
      pass_check "Reference non-empty: ${skill_name}/${ref_name}"
    else
      fail_check "Reference non-empty: ${skill_name}/${ref_name}"
    fi
  done
done

# 7. Description format check: should contain "Triggers:" (stn-skills format)
for skill_file in "$SKILLS_DIR"/*/SKILL.md; do
  skill_name=$(basename "$(dirname "$skill_file")")
  if head -15 "$skill_file" | grep -q 'Triggers:'; then
    pass_check "Description uses trigger format: $skill_name"
  else
    fail_check "Description uses trigger format: $skill_name"
  fi
done

# 8. plugin.json exists
if [[ -f "${REPO_DIR}/.claude-plugin/plugin.json" ]]; then
  pass_check "plugin.json exists"
else
  fail_check "plugin.json exists"
fi

# 9. All agent files under 200 lines
for skill_dir in "$SKILLS_DIR"/*/; do
  skill_name=$(basename "$skill_dir")
  [[ -d "${skill_dir}agents" ]] || continue
  for agent_file in "${skill_dir}agents/"*.md; do
    [[ -f "$agent_file" ]] || continue
    agent_name=$(basename "$agent_file")
    line_count=$(wc -l < "$agent_file" | tr -d ' ')
    if [[ "$line_count" -le 200 ]]; then
      pass_check "Agent under 200 lines: ${skill_name}/${agent_name} ($line_count)"
    else
      fail_check "Agent under 200 lines: ${skill_name}/${agent_name} ($line_count)"
    fi
  done
done

# 10. All reference files under 150 lines
for skill_dir in "$SKILLS_DIR"/*/; do
  skill_name=$(basename "$skill_dir")
  [[ -d "${skill_dir}references" ]] || continue
  for ref_file in "${skill_dir}references/"*.md; do
    [[ -f "$ref_file" ]] || continue
    ref_name=$(basename "$ref_file")
    line_count=$(wc -l < "$ref_file" | tr -d ' ')
    if [[ "$line_count" -le 150 ]]; then
      pass_check "Reference under 150 lines: ${skill_name}/${ref_name} ($line_count)"
    else
      fail_check "Reference under 150 lines: ${skill_name}/${ref_name} ($line_count)"
    fi
  done
done

# 11. Each skill directory has README.md
for skill in brainstorming plan-writing plan-execution build-feature codebase-audit codebase-quality-bootstrap pipeline-handoff-validator; do
  if [[ -f "${SKILLS_DIR}/${skill}/README.md" ]]; then
    pass_check "README.md exists: $skill"
  else
    fail_check "README.md exists: $skill"
  fi
done

# 12. Each skill directory has banner.svg
for skill in brainstorming plan-writing plan-execution build-feature codebase-audit codebase-quality-bootstrap pipeline-handoff-validator; do
  if [[ -f "${SKILLS_DIR}/${skill}/banner.svg" ]]; then
    pass_check "banner.svg exists: $skill"
  else
    fail_check "banner.svg exists: $skill"
  fi
done

# 13. Hooks directory structure
if [[ -f "${REPO_DIR}/hooks/hooks.json" ]]; then
  pass_check "hooks/hooks.json exists"
else
  fail_check "hooks/hooks.json exists"
fi
for hook in stn-init stn-session-lock stn-skill-gate stn-state-validator stn-routing-guard stn-scope-guard stn-circuit-breaker; do
  if [[ -f "${REPO_DIR}/hooks/${hook}" ]] && [[ -x "${REPO_DIR}/hooks/${hook}" ]]; then
    pass_check "hooks/${hook} exists and is executable"
  else
    fail_check "hooks/${hook} exists and is executable"
  fi
done

# 14. Cursor plugin structure
if [[ -f "${REPO_DIR}/.cursor-plugin/plugin.json" ]]; then
  pass_check ".cursor-plugin/plugin.json exists"
else
  fail_check ".cursor-plugin/plugin.json exists"
fi
if [[ -f "${REPO_DIR}/.cursor-plugin/hooks-cursor.json" ]]; then
  pass_check ".cursor-plugin/hooks-cursor.json exists"
else
  fail_check ".cursor-plugin/hooks-cursor.json exists"
fi

# 15. hooks.json is valid JSON
if python3 -c "import json; json.load(open('${REPO_DIR}/hooks/hooks.json'))" 2>/dev/null; then
  pass_check "hooks/hooks.json is valid JSON"
else
  fail_check "hooks/hooks.json is valid JSON"
fi

# 16. marketplace.json lists all skills
skill_count=$(python3 -c "import json; d=json.load(open('${REPO_DIR}/.claude-plugin/marketplace.json')); print(len(d['plugins'][0]['skills']))" 2>/dev/null || echo "0")
if [[ "$skill_count" -ge 8 ]]; then
  pass_check "marketplace.json lists $skill_count skills (>= 8)"
else
  fail_check "marketplace.json lists $skill_count skills (expected >= 8)"
fi

echo ""
echo "Structure: ${pass} passed, ${fail} failed"
