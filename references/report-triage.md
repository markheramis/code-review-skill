---
name: report-triage
description: "Scan code-review report findings, classify stale vs interrupted In-Progress work for triage"
version: 1.0.0
author: Mark Heramis
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [code-review, evidence-first, reporting]
    related_skills: [evidence-first-code-review]
---

# Report Triage

Classify every In-Progress finding: determine whether work is stale (no recent activity, abandoned) or interrupted (recoverable with existing branch/change request). Output a triage summary with recommended disposition per finding.

## Purpose

- Identify stale In-Progress findings that need reopening
- Find interrupted work that can be resumed
- Clean up abandoned work
- Prioritize remediation efforts

## Inputs

- Report directory of finding files
- In-Progress findings from the report queue

## Output Schema

```json
{
  "stale": [
    {
      "id": "F-001",
      "reason": "no activity >7 days",
      "action": "reopen"
    }
  ],
  "interrupted": [
    {
      "id": "F-003",
      "reason": "branch exists, unmerged",
      "action": "resume",
      "branch": "fix/sql-injection",
      "change_request": "PR #456"
    }
  ],
  "unchanged": [
    {
      "id": "F-007",
      "reason": "recent activity, in progress"
    }
  ],
  "total_in_progress": 5,
  "actions_summary": "2 stale (reopen), 1 interrupted (resume), 2 unchanged"
}
```

## Classification Rules

| Classification | When to Use | Action |
|----------------|-------------|--------|
| `stale` | No linked branch, or change request inactive >7 days with no recent commits | `reopen` |
| `interrupted` | Linked branch exists, change request open, commits present but unmerged | `resume` |
| `unchanged` | Recent activity, actively being worked on | None |

## Workflow

1. **Identify In-Progress findings**
   - List all findings with `status: In-Progress`
   - Extract finding IDs and affected paths

2. **Check git branches**
   - Look for branches related to each finding
   - Check branch age and commit recency
   - Determine if branch is active or abandoned

3. **Check linked change requests**
   - Find PRs or MRs linked to findings
   - Check change request status and age
   - Look for recent comments or activity

4. **Classify each finding**
   - Apply classification rules
   - Determine appropriate disposition
   - Identify recoverable work

5. **Generate recommendations**
   - Suggest action for each finding
   - Preserve existing work when possible
   - Note any special handling needed

## Rules

- **Never discard local work** - Preserve branches and commits unless user confirms
- **Check activity thresholds** - Use 7 days as staleness threshold
- **Preserve context** - Keep branches, PRs, and related artifacts
- **Clear disposition** - Each finding gets one clear action

## Disposition Actions

| Action | When to Use | What It Does |
|--------|-------------|--------------|
| `reopen` | Stale findings | Mark status as `Open` for fresh remediation |
| `resume` | Interrupted findings | Continue from existing branch/PR |
| `unchanged` | Active findings | Leave as-is, continue current work |

## Integration

This skill follows `report-queue`:
```
report-queue → report-triage → report-resolution
```

## Dependencies

- Requires report directory with finding files
- Requires git repository access for branch checking
- Requires access to change request system (GitHub, GitLab, etc.)

## See Also

- `report-queue` - Provides In-Progress findings
- `report-resolution` - Processes triaged findings
- `remediate-review` - Handles individual finding remediation