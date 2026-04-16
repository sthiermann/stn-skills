#!/usr/bin/env bash
# stn-skills Consistency Eval
# Deep cross-reference validation across all skills.
# Catches contradictions between SKILL.md, agents, references, and README.
# Runs without the claude CLI — pure file system checks.
# Compatible with bash 3.2+ (no associative arrays).

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_DIR="${REPO_DIR}/skills"
README="${REPO_DIR}/README.md"
PLUGIN_JSON="${REPO_DIR}/.claude-plugin/plugin.json"

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

# Lookup functions replacing associative arrays (bash 3.2 compat)
get_expected_phases() {
  case "$1" in
    brainstorming) echo 6 ;; plan-writing) echo 6 ;; plan-execution) echo 7 ;;
    codebase-audit) echo 5 ;; codebase-quality-bootstrap) echo 4 ;; *) echo 0 ;;
  esac
}

get_expected_gates() {
  case "$1" in
    brainstorming) echo 4 ;; plan-writing) echo 4 ;; plan-execution) echo 3 ;;
    codebase-audit) echo 3 ;; codebase-quality-bootstrap) echo 3 ;; *) echo 0 ;;
  esac
}

get_expected_agents() {
  case "$1" in
    brainstorming) echo 5 ;; plan-writing) echo 4 ;; plan-execution) echo 5 ;;
    codebase-audit) echo 17 ;; codebase-quality-bootstrap) echo 6 ;; *) echo 0 ;;
  esac
}

get_expected_refs() {
  case "$1" in
    brainstorming) echo 5 ;; plan-writing) echo 4 ;; pipeline-handoff-validator) echo 1 ;;
    plan-execution) echo 8 ;; codebase-audit) echo 4 ;; codebase-quality-bootstrap) echo 3 ;; *) echo 0 ;;
  esac
}

echo "Consistency Eval"
echo "================"
echo ""

# ── C-01/C-02: Cross-reference — agents and references in SKILL.md exist on disk ──

echo "--- C-01/C-02: Agent and reference cross-references ---"
for skill_dir in "$SKILLS_DIR"/*/; do
  skill=$(basename "$skill_dir")
  skill_file="${skill_dir}SKILL.md"
  [[ -f "$skill_file" ]] || continue

  # C-01: agents
  if [[ -d "${skill_dir}agents" ]]; then
    agents_mentioned=$(grep -oE 'agents/[a-z0-9_-]+\.md' "$skill_file" | sort -u || true)
    if [[ -n "$agents_mentioned" ]]; then
      all_found=true
      while IFS= read -r agent; do
        if [[ ! -f "${skill_dir}${agent}" ]]; then
          fail_check "C-01 Agent exists: ${skill}/${agent}"
          all_found=false
        fi
      done <<< "$agents_mentioned"
      if $all_found; then
        count=$(echo "$agents_mentioned" | wc -l | tr -d ' ')
        pass_check "C-01 All ${count} agents referenced in ${skill}/SKILL.md exist"
      fi
    fi
  fi

  # C-02: references (check local first, then cross-skill)
  # Only match standalone references/ paths (not preceded by skills/*/)
  refs_mentioned=$(grep -oE 'references/[a-z0-9_-]+\.md' "$skill_file" | sort -u || true)
  # Filter out refs that are part of full skills/*/references/ paths
  standalone_refs=""
  if [[ -n "$refs_mentioned" ]]; then
    while IFS= read -r ref; do
      # Check if this ref appears ONLY as part of a full skills/ path
      ref_escaped=$(echo "$ref" | sed 's/\//\\\//g')
      full_path_count=$(grep -c "skills/[a-z-]*/${ref_escaped}" "$skill_file" 2>/dev/null || true)
      full_path_count=${full_path_count:-0}
      standalone_count=$(grep -c "${ref_escaped}" "$skill_file" 2>/dev/null || true)
      standalone_count=${standalone_count:-0}
      if [[ "$standalone_count" -gt "$full_path_count" ]]; then
        # There are standalone uses beyond the full-path uses
        if [[ -z "$standalone_refs" ]]; then
          standalone_refs="$ref"
        else
          standalone_refs="${standalone_refs}"$'\n'"${ref}"
        fi
      fi
    done <<< "$refs_mentioned"
  fi

  if [[ -n "$standalone_refs" ]]; then
    all_local=true
    while IFS= read -r ref; do
      if [[ ! -f "${skill_dir}${ref}" ]]; then
        found_elsewhere=false
        for other_dir in "$SKILLS_DIR"/*/; do
          if [[ -f "${other_dir}${ref}" ]]; then
            found_elsewhere=true
            fail_check "C-02 Ambiguous path: ${skill}/SKILL.md references '${ref}' but it's in $(basename "$other_dir")'s directory"
            break
          fi
        done
        if ! $found_elsewhere; then
          fail_check "C-02 Reference not found anywhere: ${skill}/${ref}"
        fi
        all_local=false
      fi
    done <<< "$standalone_refs"
    if $all_local; then
      count=$(echo "$standalone_refs" | wc -l | tr -d ' ')
      pass_check "C-02 All ${count} references in ${skill}/SKILL.md exist locally"
    fi
  elif [[ -n "$refs_mentioned" ]]; then
    # All references use full skills/ paths — that's correct
    count=$(echo "$refs_mentioned" | wc -l | tr -d ' ')
    pass_check "C-02 All ${count} references in ${skill}/SKILL.md use full paths or exist locally"
  fi
done

echo ""

# ── C-03/C-04: Phase and gate counts match README ──

echo "--- C-03/C-04: Phase and gate counts vs README ---"

for skill in brainstorming plan-writing plan-execution codebase-audit codebase-quality-bootstrap; do
  skill_file="${SKILLS_DIR}/${skill}/SKILL.md"
  [[ -f "$skill_file" ]] || continue

  actual_phases=$(grep -cE '^### Phase [0-9]' "$skill_file" || echo "0")
  expected_phases=$(get_expected_phases "$skill")
  if [[ "$actual_phases" == "$expected_phases" ]]; then
    pass_check "C-03 Phase count ${skill}: ${actual_phases} (README: ${expected_phases})"
  else
    fail_check "C-03 Phase count ${skill}: actual=${actual_phases}, README=${expected_phases}"
  fi

  actual_gates=$(grep -cE '^### GATE [0-9]' "$skill_file" || echo "0")
  expected_gates=$(get_expected_gates "$skill")
  if [[ "$actual_gates" == "$expected_gates" ]]; then
    pass_check "C-04 Gate count ${skill}: ${actual_gates} (README: ${expected_gates})"
  else
    fail_check "C-04 Gate count ${skill}: actual=${actual_gates}, README=${expected_gates}"
  fi
done

echo ""

# ── C-05/C-06: Agent and reference file counts match README ──

echo "--- C-05/C-06: Agent/reference counts vs README ---"

for skill in brainstorming plan-writing plan-execution codebase-audit codebase-quality-bootstrap; do
  agent_dir="${SKILLS_DIR}/${skill}/agents"
  if [[ -d "$agent_dir" ]]; then
    actual=$(find "$agent_dir" -name '*.md' -maxdepth 1 | wc -l | tr -d ' ')
    expected=$(get_expected_agents "$skill")
    if [[ "$actual" == "$expected" ]]; then
      pass_check "C-05 Agent count ${skill}: ${actual}"
    else
      fail_check "C-05 Agent count ${skill}: actual=${actual}, README=${expected}"
    fi
  fi
done

for skill in brainstorming plan-writing pipeline-handoff-validator plan-execution codebase-audit codebase-quality-bootstrap; do
  ref_dir="${SKILLS_DIR}/${skill}/references"
  if [[ -d "$ref_dir" ]]; then
    actual=$(find "$ref_dir" -name '*.md' -maxdepth 1 | wc -l | tr -d ' ')
    expected=$(get_expected_refs "$skill")
    if [[ "$actual" == "$expected" ]]; then
      pass_check "C-06 Reference count ${skill}: ${actual}"
    else
      fail_check "C-06 Reference count ${skill}: actual=${actual}, README=${expected}"
    fi
  fi
done

echo ""

# ── C-07/C-08/C-09: Modernization Mandate in pipeline agents ──

echo "--- C-07/C-08/C-09: Modernization Mandate in pipeline agents ---"

check_mandate() {
  local skill="$1"
  local check_id="$2"
  local agent_dir="${SKILLS_DIR}/${skill}/agents"
  [[ -d "$agent_dir" ]] || return 0
  local total=0
  local found=0
  for f in "$agent_dir"/*.md; do
    [[ -f "$f" ]] || continue
    total=$((total + 1))
    if grep -qi "modernization" "$f"; then
      found=$((found + 1))
    else
      fail_check "${check_id} Modernization Mandate missing: ${skill}/$(basename "$f")"
    fi
  done
  if [[ "$found" == "$total" && "$total" -gt 0 ]]; then
    pass_check "${check_id} Modernization Mandate present in all ${total} ${skill} agents"
  fi
}

check_mandate "brainstorming" "C-07"
check_mandate "plan-writing" "C-08"
check_mandate "plan-execution" "C-09"

echo ""

# ── C-10/C-11: Decision matrix criteria consistency ──

echo "--- C-10/C-11: Decision matrix criteria and weights ---"

skill_file="${SKILLS_DIR}/brainstorming/SKILL.md"
ref_file="${SKILLS_DIR}/brainstorming/references/decision-matrix-template.md"

if [[ -f "$skill_file" && -f "$ref_file" ]]; then
  all_match=true
  for c in Complexity Time-to-ship Risk Extensibility Alignment Maintainability Modernity; do
    in_skill=$(grep -c "$c" "$skill_file" || echo "0")
    in_ref=$(grep -c "$c" "$ref_file" || echo "0")
    if [[ "$in_skill" -eq 0 || "$in_ref" -eq 0 ]]; then
      target="SKILL.md"
      if [[ "$in_skill" -gt 0 ]]; then target="template"; fi
      fail_check "C-10 Criterion '${c}' missing in ${target}"
      all_match=false
    fi
  done
  if $all_match; then
    pass_check "C-10 All 7 decision matrix criteria consistent"
  fi

  # Extract exactly 7 weights from the FIRST criteria table (not the example)
  weights=$(awk '/\| Criterion \| Default Weight/,/^$/' "$skill_file" | grep -oE '[0-9]+%' | head -7 | grep -oE '[0-9]+' || true)
  sum=0
  for w in $weights; do
    sum=$((sum + w))
  done
  if [[ "$sum" -eq 100 ]]; then
    pass_check "C-11 Decision matrix weights sum to 100% (${sum}%)"
  else
    fail_check "C-11 Decision matrix weights sum to ${sum}% (expected 100)"
  fi
fi

echo ""

# ── C-12: Reasoning flaw catalog count ──

echo "--- C-12: Reasoning flaw catalog ---"
flaw_catalog="${SKILLS_DIR}/brainstorming/references/reasoning-flaw-catalog.md"
if [[ -f "$flaw_catalog" ]]; then
  flaw_count=$(grep -cE '^\| [0-9]+' "$flaw_catalog" || echo "0")
  if [[ "$flaw_count" -eq 11 ]]; then
    pass_check "C-12 Reasoning flaw catalog contains exactly 11 flaw types"
  else
    fail_check "C-12 Reasoning flaw catalog: found ${flaw_count} types (expected 11)"
  fi
fi

echo ""

# ── C-13/C-14: Score dimension weights ──

echo "--- C-13/C-14: Score dimension weights ---"

pw_skill="${SKILLS_DIR}/plan-writing/SKILL.md"
if [[ -f "$pw_skill" ]]; then
  # Find PQS table: grep the heading, take next 10 lines, extract weights
  pqs_line=$(grep -n "Plan Quality Score.*(must be" "$pw_skill" | head -1 | cut -d: -f1)
  if [[ -n "$pqs_line" ]]; then
    pqs_weights=$(sed -n "${pqs_line},$((pqs_line + 10))p" "$pw_skill" | grep -oE '[0-9]+%' | grep -oE '[0-9]+' || true)
    pqs_sum=0
    for w in $pqs_weights; do pqs_sum=$((pqs_sum + w)); done
    if [[ "$pqs_sum" -eq 100 ]]; then
      pass_check "C-13 Plan Quality Score dimensions sum to 100%"
    else
      fail_check "C-13 Plan Quality Score dimensions sum to ${pqs_sum}% (expected 100)"
    fi
  else
    fail_check "C-13 Plan Quality Score section not found in plan-writing SKILL.md"
  fi
fi

pe_skill="${SKILLS_DIR}/plan-execution/SKILL.md"
if [[ -f "$pe_skill" ]]; then
  # Find EFS table: grep the heading, take next 12 lines, extract weights
  efs_line=$(grep -n "Execution Fidelity Score.*calculated" "$pe_skill" | head -1 | cut -d: -f1)
  if [[ -n "$efs_line" ]]; then
    efs_weights=$(sed -n "${efs_line},$((efs_line + 12))p" "$pe_skill" | grep -oE '[0-9]+%' | grep -oE '[0-9]+' || true)
    efs_sum=0
    for w in $efs_weights; do efs_sum=$((efs_sum + w)); done
    if [[ "$efs_sum" -eq 100 ]]; then
      pass_check "C-14 Execution Fidelity Score dimensions sum to 100%"
    else
      fail_check "C-14 Execution Fidelity Score dimensions sum to ${efs_sum}% (expected 100)"
    fi
  else
    fail_check "C-14 Execution Fidelity Score section not found in plan-execution SKILL.md"
  fi
fi

echo ""

# ── C-15/C-16/C-17: 13 audit domains consistent ──

echo "--- C-15/C-16/C-17: 13 audit domain consistency ---"

audit_skill="${SKILLS_DIR}/codebase-audit/SKILL.md"
alignment_ref="${SKILLS_DIR}/codebase-quality-bootstrap/references/audit-domain-alignment.md"
bootstrap_skill="${SKILLS_DIR}/codebase-quality-bootstrap/SKILL.md"

for check_pair in "C-15:${audit_skill}:codebase-audit SKILL.md" "C-16:${alignment_ref}:audit-domain-alignment.md" "C-17:${bootstrap_skill}:bootstrap SKILL.md"; do
  IFS=: read -r check_id file_path desc <<< "$check_pair"
  if [[ -f "$file_path" ]]; then
    all_found=true
    for d in SEC DOC DEAD DEPR MAND QUAL ARCH DEP TEST INFRA PERF CONC PRIV; do
      if ! grep -q "$d" "$file_path"; then
        fail_check "${check_id} Domain ${d} missing from ${desc}"
        all_found=false
      fi
    done
    if $all_found; then
      pass_check "${check_id} All 13 audit domains present in ${desc}"
    fi
  fi
done

echo ""

# ── C-18/C-19: build-feature consistency ──

echo "--- C-18/C-19: build-feature cross-references ---"

bf_skill="${SKILLS_DIR}/build-feature/SKILL.md"
if [[ -f "$bf_skill" ]]; then
  # C-18: total gate count = 4+4+3 = 11
  bs_gates=$(grep -cE '^### GATE' "${SKILLS_DIR}/brainstorming/SKILL.md" 2>/dev/null || echo "0")
  pw_gates=$(grep -cE '^### GATE' "${SKILLS_DIR}/plan-writing/SKILL.md" 2>/dev/null || echo "0")
  pe_gates=$(grep -cE '^### GATE' "${SKILLS_DIR}/plan-execution/SKILL.md" 2>/dev/null || echo "0")
  total_gates=$((bs_gates + pw_gates + pe_gates))
  if [[ "$total_gates" -eq 11 ]]; then
    pass_check "C-18 build-feature gate sum: ${bs_gates}+${pw_gates}+${pe_gates}=11"
  else
    fail_check "C-18 build-feature gate sum: ${bs_gates}+${pw_gates}+${pe_gates}=${total_gates} (expected 11)"
  fi

  # C-19: build-feature references sub-skill agent directories
  all_ref=true
  for sub in brainstorming plan-writing plan-execution; do
    if ! grep -q "skills/${sub}/agents/" "$bf_skill"; then
      fail_check "C-19 build-feature missing reference to ${sub} agents"
      all_ref=false
    fi
  done
  if $all_ref; then
    pass_check "C-19 build-feature references all 3 sub-skill agent directories"
  fi
fi

echo ""

# ── C-22/C-23/C-24: Standard sections in all SKILL.md ──

echo "--- C-22/C-23/C-24: Standard sections ---"

for skill_file in "$SKILLS_DIR"/*/SKILL.md; do
  skill=$(basename "$(dirname "$skill_file")")

  # Skip session-init (lightweight routing skill, no pipeline phases)
  [[ "$skill" == "session-init" ]] && continue

  # C-22: Iron Law or Contract Rule
  if grep -qE 'Iron Law|Contract Rule' "$skill_file"; then
    pass_check "C-22 Iron Law/Contract Rule present: ${skill}"
  else
    fail_check "C-22 Iron Law/Contract Rule missing: ${skill}"
  fi

  # C-23: Red Flags
  if grep -q "Red Flag" "$skill_file"; then
    pass_check "C-23 Red Flags section present: ${skill}"
  else
    fail_check "C-23 Red Flags section missing: ${skill}"
  fi

  # C-24: Common Rationalizations
  if grep -q "Rationalization" "$skill_file"; then
    pass_check "C-24 Common Rationalizations present: ${skill}"
  else
    fail_check "C-24 Common Rationalizations missing: ${skill}"
  fi
done

echo ""

# ── C-25/C-26: plugin.json consistency ──

echo "--- C-25/C-26: plugin.json consistency ---"

if [[ -f "$PLUGIN_JSON" ]]; then
  plugin_version=$(grep -oE '"version": "[^"]+"' "$PLUGIN_JSON" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
  readme_version=$(grep -oE 'version-[0-9]+\.[0-9]+\.[0-9]+' "$README" | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
  if [[ "$plugin_version" == "$readme_version" ]]; then
    pass_check "C-25 Version match: plugin.json=${plugin_version}, README=${readme_version}"
  else
    fail_check "C-25 Version mismatch: plugin.json=${plugin_version}, README=${readme_version}"
  fi

  actual_skills=$(find "$SKILLS_DIR" -maxdepth 1 -mindepth 1 -type d | wc -l | tr -d ' ')
  readme_badge=$(grep -oE 'skills-[0-9]+' "$README" | head -1 | grep -oE '[0-9]+')
  if [[ "$actual_skills" == "$readme_badge" ]]; then
    pass_check "C-26 Skill count: ${actual_skills} directories = README badge (${readme_badge})"
  else
    fail_check "C-26 Skill count: ${actual_skills} directories != README badge (${readme_badge})"
  fi
fi

echo ""

# ── C-20/C-21: Skill chaining declarations ──

echo "--- C-20/C-21: Skill chaining declarations ---"

for chain_pair in "brainstorming:plan-writing" "plan-writing:plan-execution"; do
  source_skill="${chain_pair%%:*}"
  target_skill="${chain_pair%:*}"
  target_skill="${chain_pair##*:}"
  skill_file="${SKILLS_DIR}/${source_skill}/SKILL.md"

  if [[ -f "$skill_file" ]]; then
    if head -15 "$skill_file" | grep -q "CHAINS TO ${target_skill}"; then
      pass_check "C-20 Description chains ${source_skill} → ${target_skill}"
    else
      fail_check "C-20 Description missing CHAINS TO ${target_skill} in ${source_skill}"
    fi

    if grep -q "## Mandatory Skill Chain" "$skill_file"; then
      pass_check "C-21 Mandatory Skill Chain section present: ${source_skill}"
    else
      fail_check "C-21 Mandatory Skill Chain section missing: ${source_skill}"
    fi
  fi
done

echo ""

# ── C-29: Activation prompt file coverage ──

echo "--- C-29: Activation prompt coverage ---"

prompts_dir="${REPO_DIR}/evals/prompts"
if [[ -d "$prompts_dir" ]]; then
  for prompt_file in "$prompts_dir"/*.txt; do
    [[ -f "$prompt_file" ]] || continue
    name=$(basename "$prompt_file" .txt)
    count=$(grep -cvE '^#|^$' "$prompt_file" || echo "0")
    if [[ "$count" -ge 3 ]]; then
      pass_check "C-29 Prompt coverage ${name}: ${count} prompts (>= 3)"
    else
      fail_check "C-29 Prompt coverage ${name}: only ${count} prompts (need >= 3)"
    fi
  done
fi

echo ""

# ── C-30: Handoff validator reference path resolution ──

echo "--- C-30: Handoff validator reference paths ---"

hv_skill="${SKILLS_DIR}/pipeline-handoff-validator/SKILL.md"
if [[ -f "$hv_skill" ]]; then
  # Check all full cross-skill paths (skills/X/references/Y.md)
  full_paths=$(grep -oE 'skills/[a-z-]+/references/[a-z0-9_-]+\.md' "$hv_skill" | sort -u || true)
  if [[ -n "$full_paths" ]]; then
    all_resolve=true
    while IFS= read -r fp; do
      if [[ -f "${REPO_DIR}/${fp}" ]]; then
        pass_check "C-30 Cross-skill path resolves: ${fp}"
      else
        fail_check "C-30 Cross-skill path broken: ${fp}"
        all_resolve=false
      fi
    done <<< "$full_paths"
  fi

  # Check local references/ path (handoff-contracts.md)
  local_ref="${SKILLS_DIR}/pipeline-handoff-validator/references/handoff-contracts.md"
  if [[ -f "$local_ref" ]]; then
    pass_check "C-30 Local reference exists: handoff-contracts.md"
  else
    fail_check "C-30 Local reference missing: handoff-contracts.md"
  fi

  # Check for any standalone references/ that aren't full paths and don't exist locally
  all_refs=$(grep -oE 'references/[a-z0-9_-]+\.md' "$hv_skill" | sort -u || true)
  if [[ -n "$all_refs" ]]; then
    while IFS= read -r ref; do
      ref_name=$(basename "$ref")
      # Skip if it's part of a full skills/ path
      if grep -q "skills/[a-z-]*/${ref}" "$hv_skill" 2>/dev/null; then
        continue
      fi
      # It's a standalone reference/ path — must exist locally
      if [[ ! -f "${SKILLS_DIR}/pipeline-handoff-validator/${ref}" ]]; then
        for other in "$SKILLS_DIR"/*/; do
          if [[ -f "${other}${ref}" ]]; then
            fail_check "C-30 Standalone '${ref}' should use full path: skills/$(basename "$other")/${ref}"
            break
          fi
        done
      fi
    done <<< "$all_refs"
  fi
fi

# C-31: Pipeline state protocol — all 3 copies identical
proto_exec="${SKILLS_DIR}/plan-execution/references/pipeline-state-protocol.md"
proto_brain="${SKILLS_DIR}/brainstorming/references/pipeline-state-protocol.md"
proto_plan="${SKILLS_DIR}/plan-writing/references/pipeline-state-protocol.md"
if [[ -f "$proto_exec" ]] && [[ -f "$proto_brain" ]] && [[ -f "$proto_plan" ]]; then
  if diff -q "$proto_exec" "$proto_brain" >/dev/null 2>&1 && diff -q "$proto_exec" "$proto_plan" >/dev/null 2>&1; then
    pass_check "C-31 Pipeline state protocol: all 3 copies identical"
  else
    fail_check "C-31 Pipeline state protocol: copies differ (run: cp plan-execution/references/pipeline-state-protocol.md to brainstorming + plan-writing)"
  fi
else
  fail_check "C-31 Pipeline state protocol: one or more copies missing"
fi

# C-32: Pipeline state protocol contains schema_version
if [[ -f "$proto_exec" ]]; then
  if grep -q 'schema_version' "$proto_exec"; then
    pass_check "C-32 Pipeline state protocol contains schema_version"
  else
    fail_check "C-32 Pipeline state protocol missing schema_version field"
  fi
fi

echo ""
echo "Consistency: ${pass} passed, ${fail} failed"
