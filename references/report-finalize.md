---
name: report-finalize
description: "Append the canonical Remediation Notes block to a report finding and sync status across report, work item, and change request"
version: 1.0.0
author: Mark Heramis
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [code-review, evidence-first, reporting]
    related_skills: [evidence-first-code-review]
---

# Report Finalize

Read the remediation packet returned from the specialist agent. Append a `#### Remediation Notes` evidence block to the finding in the report. Update the finding's status line. Synchronize status across the report, any linked work item, and any linked change request. Perform a read-back verification of all writes before returning.

## Purpose

- Document remediation results in the report
- Sync finding status across all systems
- Maintain audit trail of fixes
- Verify all updates are applied correctly

## Inputs

- Report directory under `KILO_REPORT_DIRECTORY`
- Finding ID
- Remediation packet (from `remediate-packet`):
  - `remediation_status`
  - `fix_summary`
  - `validation_results`
  - `warnings`
  - `files_changed`
  - `stage_results`
- `KILO_FINDINGS_STATUS` - Status lifecycle fixture

## Output Schema

```json
{
  "finding_id": "F-007",
  "status": "Resolved",
  "finding_file_updated": true,
  "work_item_updated": true,
  "change_request_linked": true,
  "readback_verified": true,
  "remediation_notes_block": "#### Remediation Notes\n\n**Status**: Resolved\n**Fix Summary**: ...\n**Validation Results**: ...\n**Warnings**: ...\n**Files Changed**: ...",
  "warnings": []
}
```

## Workflow

1. **Resolve finding file**
   - Find file by ID (`F-NNN-<slug>.md`)
   - Error if file missing
   - Check for existing Remediation Notes block

2. **Compose Remediation Notes block**
   - Map packet fields to block format
   - **Status**: from `remediation_status`
   - **Fix Summary**: from `fix_summary`
   - **Validation Results**: summarize targeted and full gates
   - **Warnings**: each warning on `-` bullet with source and count
   - **Files Changed**: each committed file on `-` bullet
   - Include only production source and test files
   - Exclude temp files, finding-file paths, lockfiles (unless security-critical)

3. **Handle existing notes**
   - If Remediation Notes exists, append `#### Remediation Notes (Update N)`
   - Increment N from last update
   - Never overwrite existing remediation history

4. **Update finding file**
   - Append Remediation Notes block to finding body
   - Update frontmatter `status` field
   - Map status values: `completed`→`Resolved`, `disproven`→`Resolved`, `blocked`→`Blocked`, `in_progress`→`In Progress`
   - Frontmatter is single source of truth for status

5. **Sync to status-findings.json**
   - Set/update entry for this finding_id
   - Fields: `status` (mapped), `resolved_at` (ISO 8601), `resolution_branch`, `resolution_commit`, `fix_summary` (truncated to 200 chars)

6. **Update work item**
   - Look up finding_id in linked issue tracker
   - Update work item status to match finding status
   - If no work item exists and finding is Resolved, note `work_item_updated: false` with explanation
   - Do not create work items from this leaf

7. **Link change request**
   - If packet references change request URL/identifier
   - Link in Remediation Notes as `**Change Request**: <url_or_ref>`

8. **Read-back verification**
   - After all writes, re-read finding file
   - Verify Remediation Notes block appears verbatim
   - Verify frontmatter `status` matches
   - Return `readback_verified: false` with mismatch description if verification fails

## Remediation Notes Block Format

```markdown
#### Remediation Notes

**Status**: Resolved

**Fix Summary**: Added input validation to prevent SQL injection

**Validation Results**:
- Targeted: `test_sql_injection_blocked` passes
- Full: `npm test` passes, 0 new failures

**Warnings**:
- `cargo clippy`: 0 new warnings
- `eslint`: 1 pre-existing warning (unrelated)

**Files Changed**:
- `src/database/query.go` - Added parameterized queries
- `tests/api/query_test.go` - Added injection test coverage

**Change Request**: PR #456

**Remediated At**: 2024-06-22T20:15:30Z
```

## Rules

- **Never overwrite history** - Append to existing Remediation Notes
- **Frontmatter is canonical** - Status in frontmatter is source of truth
- **Read-back verification** - Verify all writes before returning
- **No mutations beyond scope** - Only finding-file edits and fixture updates
- **Never commit/branch/push** - This skill only updates documentation and fixtures

## Status Mapping

| Packet Status | Finding Status | Work Item Status |
|---------------|----------------|------------------|
| `completed` | `Resolved` | `Completed` |
| `disproven` | `Resolved` | `Completed` |
| `blocked` | `Blocked` | `Blocked` |
| `in_progress` | `In Progress` | `In Progress` |

## Integration

This skill is the final step for each finding:
```
remediate-finding → report-note-draft → report-finalize
```

## Dependencies

- Requires remediation packet from `remediate-packet`
- Requires finding file in report directory
- Requires `status-findings.json` for sync
- May require access to work item/change request systems

## See Also

- `remediate-packet` - Provides remediation results
- `report-note-draft` - Drafts reviewer notes
- `status-findings.json` - Canonical status lifecycle