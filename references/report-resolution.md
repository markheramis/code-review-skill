---
name: report-resolution
description: "Orchestrate sequential burn-down of resolvable code-review report findings, one commit and change request per finding"
version: 1.0.0
author: Mark Heramis
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [code-review, evidence-first, reporting]
    related_skills: [evidence-first-code-review]
---

# Report Resolution

Sequentially burn down resolvable findings as a bounded sequential queue around the canonical one-item resolution procedure. Process findings one at a time with proper queue management and continuation rules.

## Purpose

- Systematically resolve all findings in a report
- Follow proper dependency order
- Ensure each finding gets proper validation
- Track progress and completion

## Config

- `KILO_REPORT_DIRECTORY` - `.ai/reports/`
- `KILO_CONFIG_ROOT` - `~/.config/kilo`
- `KILO_TOOLS_PATH` - `<KILO_CONFIG_ROOT>/tools/...`
- `KILO_FINDINGS_STATUS` - Status lifecycle
- `KILO_ISSUE_STATUS` - Issue lifecycle
- `KILO_COMMIT_TEMPLATE` - Commit message template
- `KILO_PR_TEMPLATE` - Pull request template

## Inputs

- Optional report directory or finding ID
- Optional batch limit and time budget
- Defaults from environment variables if not specified

## Stages (Sequential)

For each selected finding, run the canonical one-item procedure:

### 1. Build Queue
- `report-queue` - Ordered resolvable queue
- Surface blocked/not_ready with unblock commands
- Never work blocked findings

### 2. Triage In-Progress
- `report-triage` - Classify In-Progress findings
- Apply terminal dispositions or queue-as-open
- Output triage summary first

### 3. Process Each Finding
For each queued finding, run:
- `staleness-check` - Check if finding is outdated
- `finding-verification` - Validate with current code
- `experiment-summary` - Run validation experiments
- `finding-branch-plan` - Plan fix branch
- Delegated `remediate-finding` - Fix to selected specialist
- Main agent validation + commit + change request
- `report-note-draft` - Draft reviewer notes
- `report-finalize` - Sync status across systems

### 4. Refresh State
After each finding:
- Refresh the report
- Update work items
- Update branches and change requests
- Re-run checks
- Re-read queue before next item

### 5. Continue
- Continue to next eligible finding only when previous item reaches terminal state
- Terminal states: `Completed`, `Closed`, or explicitly `Blocked`

## Gates

### Common Gates (from resolution-contract.md)
- Apply standard validation and quality gates
- Ensure proper testing and review
- Maintain change-request secrecy

### Queue Rules
- Check linked work-item state before selecting
- Finding eligible only when: deep-confirmed, issue-linked, issue `Ready`
- Exclude findings already represented by active/completed work
- Select next finding by severity, dependency, report order

### Processing Rules
- Process one finding at a time
- Configurable batch limit and time budget
- Stop when limit or budget exhausted
- Continue only when previous item is terminal or blocked

### Parallelism Rules
- **Never use parallel worktrees** for default burn-down
- **Never run two specialists in parallel**
- **Never parallelize edits, branch ops, status calls, validation**

### Change-Request Secrecy
**CRITICAL:** Commit messages and PR descriptions MUST NOT mention:
- The report or its path
- Finding IDs
- Severity/confidence labels
- The review process

Only the change itself and the linked tracker issue should be referenced.

### Work Preservation
- **Never discard local work** without explicit user confirmation
- **Never force-delete a branch**
- **Never force-reset** without explicit confirmation
- Read back after every mutation

## Final Summary

Report:
- Active report directory
- Finding files processed
- Statuses changed

Work:
- Specialist agents delegated (which agent, which findings)

Artifacts:
- Branches/commits/change requests created
- Validation commands run with actual results
- Linked issues updated
- Temp files deleted or promoted

Blockers:
- Unresolved blockers listed
- Do not claim completion if any finding remains blocked, unverified, unvalidated, uncommitted, or without required change request

## Integration

This skill orchestrates the full remediation pipeline:
```
report-queue → report-triage → report-resolution → report-finalize
```

## Dependencies

- Requires completed `report-queue` and `report-triage`
- Requires access to all workflow skills
- Requires git repository with remote
- Requires issue/change request system access

## See Also

- `report-queue` - Builds ordered queue
- `report-triage` - Classifies In-Progress findings
- `report-finalize` - Syncs status across systems
- `remediate-review` - Handles individual finding fixes