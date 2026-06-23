---
name: remediate-finding
description: "Remediate a single code-review finding by composing verify/experiment/implement/validate/warn/cleanup stages"
version: 1.0.0
author: Mark Heramis
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [code-review, evidence-first, remediation]
    related_skills: [evidence-first-code-review]
---

# Finding Remediation

Remediate one finding end-to-end as the specialist agent. Apply specialist rules for the language/framework; use the project's own build, test, lint, and format commands. Never commit, branch, push, open PRs, or edit reports - those stay with the main agent.

## Purpose

- Fix a single finding with proper validation
- Follow specialist rules for the language/framework
- Ensure no regressions are introduced
- Generate complete remediation packet

## Config

- Status lifecycle — `fixtures/status-findings.json` (bundled)

## Inputs

Provided by main agent:
- `finding_id` - Finding identifier
- `title` - Finding title
- `severity` - Severity level
- `confidence` - Confidence level
- `category` - Finding category
- `affected_paths` - Affected files with line ranges
- `target_revision` - Commit finding was reported against
- `staleness_result` - Result from staleness check
- `verification_result` - Result from verification
- `experiment_result` - Result from experiment
- `additional_context` - Fix direction, constraints, dependencies

## Stages (Sequential)

### 1. Verify
- `remediate-verify` - Confirm finding holds at current head
- If `disproven` → stop, return packet with `remediation_status: disproven`

### 2. Experiment
- `remediate-experiment` - Confirm fix in throwaway
- Skip if prior experiment was `comparative` mode
- Otherwise, run experiment to validate fix approach

### 3. Implement
- `remediate-implement` - Smallest correct fix in production code
- Include focused regression tests
- Apply specialist rules for language/framework

### 4. Validate
- `remediate-validate` - Targeted then full validation gate
- Confirm no regressions introduced

### 5. Warn
- `remediate-warn` - Classify warnings
- Fix any introduced warnings

### 6. Cleanup
- `remediate-cleanup` - Delete temp files
- Confirm clean tree

### 7. Packet
- `remediate-packet` - Assemble and return remediation packet

## Gates

### Stop Conditions
- Stop if any stage returns `disproven`, `blocked`, or has blockers
- Set `remediation_status` accordingly
- Do not advance to implement after `disproven` reverify

### Validation Requirements
- Do not report `completed` unless both targeted and full gates passed
- If full gate unavailable, state explicitly
- Never claim command passed unless ran this session

### Warning Requirements
- Any introduced warning left unfixed is a blocker
- Results in `blocked`, not `completed`
- All introduced warnings must be addressed

### Cleanup Requirements
- Read back `git status` before returning
- Report any temp files or unexpected changes
- Ensure clean working tree

## Final Summary

Return only the packet from stage 7. Do not:
- Edit finding files
- Commit changes
- Create branches
- Push to remote
- Open PRs

The main agent maps the packet into `#### Remediation Notes` and uses `fix_summary` for commit/PR text, referencing only:
- Committed files
- Observable behavior
- Validation commands
- Reviewer-openable docs

Never reference:
- Finding file path
- Finding IDs
- Severity labels
- Temp files
- Remediation process

## Integration

This skill is delegated by `report-resolution`:
```
report-resolution → remediate-finding (specialist agent)
```

## Dependencies

- Requires finding details from main agent
- Requires access to all remediation sub-skills
- Requires project toolchain for validation
- Requires git repository access

## See Also

- `remediate-verify` - Re-verify finding applies
- `remediate-experiment` - Validate fix approach
- `remediate-implement` - Implement the fix
- `remediate-validate` - Validate no regressions
- `remediate-warn` - Fix introduced warnings
- `remediate-cleanup` - Clean up artifacts
- `remediate-packet` - Assemble results