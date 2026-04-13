#!/usr/bin/env bash
# stn-skills Quality Metrics Eval
# Produces a quality dashboard with line counts, token efficiency, and reuse analysis.
# Runs without the claude CLI — pure file system checks.

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

echo "Quality Metrics Eval"
echo "===================="
echo ""

# ── Q-01: SKILL.md line counts ──

echo "--- Q-01: SKILL.md line counts (limit: 500, warn: 400) ---"
echo ""
printf "  %-35s %6s %s\n" "Skill" "Lines" "Status"
printf "  %-35s %6s %s\n" "-----" "-----" "------"

for skill_file in "$SKILLS_DIR"/*/SKILL.md; do
  skill=$(basename "$(dirname "$skill_file")")
  lines=$(wc -l < "$skill_file" | tr -d ' ')
  if [[ "$lines" -gt 500 ]]; then
    printf "  %-35s %6s %s\n" "$skill" "$lines" "EXCEED (>500)"
    fail_check "Q-01 SKILL.md over 500 lines: ${skill} (${lines})"
  elif [[ "$lines" -gt 400 ]]; then
    printf "  %-35s %6s %s\n" "$skill" "$lines" "WARN (>400)"
    pass_check "Q-01 SKILL.md under 500 but over 400: ${skill} (${lines})"
  else
    printf "  %-35s %6s %s\n" "$skill" "$lines" "OK"
    pass_check "Q-01 SKILL.md within limits: ${skill} (${lines})"
  fi
done

echo ""

# ── Q-02: Agent line counts ──

echo "--- Q-02: Agent line counts (limit: 200) ---"
echo ""
printf "  %-50s %6s %s\n" "Agent" "Lines" "Status"
printf "  %-50s %6s %s\n" "-----" "-----" "------"

violations=0
total_agents=0
for agent_file in "$SKILLS_DIR"/*/agents/*.md; do
  [[ -f "$agent_file" ]] || continue
  total_agents=$((total_agents + 1))
  skill=$(basename "$(dirname "$(dirname "$agent_file")")")
  agent=$(basename "$agent_file")
  lines=$(wc -l < "$agent_file" | tr -d ' ')
  if [[ "$lines" -gt 200 ]]; then
    printf "  %-50s %6s %s\n" "${skill}/${agent}" "$lines" "EXCEED"
    violations=$((violations + 1))
  fi
done

if [[ "$violations" -eq 0 ]]; then
  echo "  All ${total_agents} agent files within 200-line limit"
  pass_check "Q-02 All ${total_agents} agents within 200-line limit"
else
  echo ""
  echo "  ${violations}/${total_agents} agents exceed 200-line limit"
  fail_check "Q-02 ${violations} agents exceed 200-line limit"
fi

echo ""

# ── Q-03: Reference line counts ──

echo "--- Q-03: Reference line counts (limit: 150) ---"
echo ""
printf "  %-55s %6s %s\n" "Reference" "Lines" "Status"
printf "  %-55s %6s %s\n" "---------" "-----" "------"

violations=0
total_refs=0
for ref_file in "$SKILLS_DIR"/*/references/*.md; do
  [[ -f "$ref_file" ]] || continue
  total_refs=$((total_refs + 1))
  skill=$(basename "$(dirname "$(dirname "$ref_file")")")
  ref=$(basename "$ref_file")
  lines=$(wc -l < "$ref_file" | tr -d ' ')
  if [[ "$lines" -gt 150 ]]; then
    printf "  %-55s %6s %s\n" "${skill}/${ref}" "$lines" "EXCEED"
    violations=$((violations + 1))
  fi
done

if [[ "$violations" -eq 0 ]]; then
  echo "  All ${total_refs} reference files within 150-line limit"
  pass_check "Q-03 All ${total_refs} references within 150-line limit"
else
  echo ""
  echo "  ${violations}/${total_refs} references exceed 150-line limit"
  fail_check "Q-03 ${violations} references exceed 150-line limit"
fi

echo ""

# ── Q-04: Total file counts ──

echo "--- Q-04: Total file counts ---"
echo ""

skill_count=$(find "$SKILLS_DIR" -maxdepth 1 -mindepth 1 -type d | wc -l | tr -d ' ')
skillmd_count=$(find "$SKILLS_DIR" -name 'SKILL.md' | wc -l | tr -d ' ')
agent_count=$(find "$SKILLS_DIR" -path '*/agents/*.md' | wc -l | tr -d ' ')
ref_count=$(find "$SKILLS_DIR" -path '*/references/*.md' | wc -l | tr -d ' ')
cmd_count=$(find "$REPO_DIR/commands" -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
readme_count=$(find "$SKILLS_DIR" -name 'README.md' | wc -l | tr -d ' ')
banner_count=$(find "$SKILLS_DIR" -name 'banner.svg' | wc -l | tr -d ' ')

printf "  %-25s %5s\n" "Skill directories" "$skill_count"
printf "  %-25s %5s\n" "SKILL.md files" "$skillmd_count"
printf "  %-25s %5s\n" "Agent prompts" "$agent_count"
printf "  %-25s %5s\n" "Reference files" "$ref_count"
printf "  %-25s %5s\n" "Command files" "$cmd_count"
printf "  %-25s %5s\n" "README.md files" "$readme_count"
printf "  %-25s %5s\n" "Banner SVGs" "$banner_count"
total=$((skillmd_count + agent_count + ref_count + cmd_count + readme_count + banner_count))
printf "  %-25s %5s\n" "TOTAL" "$total"
pass_check "Q-04 Total plugin files: ${total}"

echo ""

# ── Q-05: Progressive disclosure ratio ──

echo "--- Q-05: Progressive disclosure ratio (SKILL.md vs total) ---"
echo ""
printf "  %-30s %8s %8s %8s %6s\n" "Skill" "SKILL.md" "Agents" "Refs" "Ratio"
printf "  %-30s %8s %8s %8s %6s\n" "-----" "--------" "------" "----" "-----"

for skill_dir in "$SKILLS_DIR"/*/; do
  skill=$(basename "$skill_dir")
  skill_lines=$(wc -l < "${skill_dir}SKILL.md" 2>/dev/null | tr -d ' ' || echo "0")

  agent_lines=0
  if [[ -d "${skill_dir}agents" ]]; then
    for f in "${skill_dir}agents/"*.md; do
      [[ -f "$f" ]] || continue
      l=$(wc -l < "$f" | tr -d ' ')
      agent_lines=$((agent_lines + l))
    done
  fi

  ref_lines=0
  if [[ -d "${skill_dir}references" ]]; then
    for f in "${skill_dir}references/"*.md; do
      [[ -f "$f" ]] || continue
      l=$(wc -l < "$f" | tr -d ' ')
      ref_lines=$((ref_lines + l))
    done
  fi

  total=$((skill_lines + agent_lines + ref_lines))
  if [[ "$total" -gt 0 ]]; then
    ratio=$(awk "BEGIN {printf \"%.0f%%\", ($skill_lines / $total) * 100}")
  else
    ratio="N/A"
  fi

  printf "  %-30s %8s %8s %8s %6s\n" "$skill" "$skill_lines" "$agent_lines" "$ref_lines" "$ratio"
done

pass_check "Q-05 Progressive disclosure ratios computed"

echo ""

# ── Q-06: Cross-skill reference sharing ──

echo "--- Q-06: Cross-skill reference sharing ---"
echo ""

# Find reference filenames that appear in multiple skills' SKILL.md (bash 3.2 compat)
ref_map_file=$(mktemp)
for skill_file in "$SKILLS_DIR"/*/SKILL.md; do
  skill=$(basename "$(dirname "$skill_file")")
  refs=$(grep -oE 'references/[a-z0-9_-]+\.md' "$skill_file" | sort -u || true)
  [[ -z "$refs" ]] && continue
  while IFS= read -r ref; do
    ref_name=$(basename "$ref")
    echo "${ref_name}:${skill}" >> "$ref_map_file"
  done <<< "$refs"
done

shared_found=false
if [[ -s "$ref_map_file" ]]; then
  # Find ref names that appear with multiple skills
  for ref_name in $(cut -d: -f1 "$ref_map_file" | sort -u); do
    skills_using=$(grep "^${ref_name}:" "$ref_map_file" | cut -d: -f2 | sort -u | tr '\n' ', ' | sed 's/, $//')
    skill_count=$(grep "^${ref_name}:" "$ref_map_file" | cut -d: -f2 | sort -u | wc -l | tr -d ' ')
    if [[ "$skill_count" -gt 1 ]]; then
      echo "  ${ref_name} -> ${skills_using}"
      shared_found=true
    fi
  done
fi
rm -f "$ref_map_file"

if ! $shared_found; then
  echo "  No cross-skill reference sharing detected"
fi
pass_check "Q-06 Cross-skill reference sharing map computed"

echo ""

# ── Q-07: Total markdown lines ──

echo "--- Q-07: Total markdown line count ---"
echo ""

total_md_lines=0
for f in $(find "$SKILLS_DIR" -name '*.md' -type f); do
  l=$(wc -l < "$f" | tr -d ' ')
  total_md_lines=$((total_md_lines + l))
done

# Add command files
for f in "$REPO_DIR"/commands/*.md; do
  [[ -f "$f" ]] || continue
  l=$(wc -l < "$f" | tr -d ' ')
  total_md_lines=$((total_md_lines + l))
done

echo "  Total markdown lines across plugin: ${total_md_lines}"
pass_check "Q-07 Total markdown lines: ${total_md_lines}"

echo ""
echo "Quality Metrics: ${pass} passed, ${fail} failed"
