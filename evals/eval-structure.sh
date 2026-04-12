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
for skill in brainstorming plan-writing plan-execution build-feature codebase-audit codebase-quality-bootstrap pipeline-handoff-validator; do
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
  if [[ "$line_count" -le 500 ]]; then
    pass_check "Under 500 lines: $skill_name ($line_count)"
  else
    fail_check "Under 500 lines: $skill_name ($line_count)"
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
for cmd in brainstorming plan-writing plan-execution build-feature codebase-audit codebase-quality-bootstrap pipeline-handoff-validator; do
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

# 7. Description format check: should contain "Invoke" (stn-skills format)
for skill_file in "$SKILLS_DIR"/*/SKILL.md; do
  skill_name=$(basename "$(dirname "$skill_file")")
  if head -10 "$skill_file" | grep -q 'Invoke'; then
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

echo ""
echo "Structure: ${pass} passed, ${fail} failed"
