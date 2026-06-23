---
name: deep-confirm-record
description: "Write the Deep Confirmation value and record block to the report finding; update status fixtures"
version: 1.0.0
author: Mark Heramis
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [code-review, evidence-first, verification, workflow]
    related_skills: [evidence-first-code-review]
---

# Deep Confirm Record

Write the resolved `Deep Confirmed` value into the report finding's metadata, append a `#### Deep Confirmation` evidence block, and update the deep confirmation status fixture. Perform read-back verification before returning.

## Purpose

- Record deep confirmation results in finding
- Update status fixtures
- Provide audit trail
- Verify all writes are applied correctly

## Inputs

- Report directory — defaults to `.ai/reports/`
- `finding_id` - Finding identifier
- `deep_confirmed` value and evidence from classify/experiment stages
- Deep-confirm status lifecycle — `fixtures/status-deep-confirmation.json` (bundled)

## Output Schema

```json
{
  "finding_id": "F-007",
  "deep_confirmed": "Yes",
  "finding_file_updated": true,
  "fixture_updated": true,
  "readback_verified": true,
  "block_written": "#### Deep Confirmation\n\n**Value**: Yes\n**Method**: Comparative experiment..."
}
```

## Workflow

### 1. Resolve Finding File

Find file by `finding_id` (filename pattern `F-NNN-<slug>.md`).

### 2. Update Frontmatter

- Update `deep_confirmed` field to resolved value (`Yes`, `No`, `N/A`, or `Blocked`)
- **Invalid values:** `Partially`, `Ineffective`, `Inconclusive` are not valid
- Reject and re-route to experiment stage if they arrive
- Frontmatter is single source of truth for finding metadata
- Never duplicate as `**Deep Confirmed**:` line in body

### 3. Append Deep Confirmation Block

Append to finding file body:
- Immediately after existing `## Deep Confirmation` section placeholder, or at end if none
- Include:

**For experiment ran:**
- `**Value**:` Resolved confirmation value (`Yes`/`No`/`Blocked`)
- `**Classification**:` `needs_confirmation` or `auto_skip` with rationale
- `**Experiment Ran**:` `true` or `false`
- `**Claims Enumerated**:` Count and list of claim IDs (`C1`, `C2`, …) from classify stage
- Per-claim `**Claim Cn**:` blocks with:
  - `Baseline:` summary
  - `Candidate:` summary
  - `Verdict:` (`confirmed`/`disproved`/`ineffective`/`blocked`)
- Aggregate `**Verdict**:` (`Yes`/`No`/`Blocked`)
- `**Timestamp**:` ISO 8601

**For auto-skip:**
- Shorter block with just `**Value**: N/A` and `**Auto-Skip Reason**:`

### 4. Handle Existing Blocks

If `#### Deep Confirmation` block already exists:
- Append `#### Deep Confirmation (Update N)` block
- Never overwrite existing confirmation history
- Increment N from last update

### 5. Update Status Fixture

Update `status-deep-confirmation.json`:
- Set/update entry for this `finding_id`
- Fields:
  - `deep_confirmed` (`Yes`/`No`/`N/A`/`Blocked`)
  - `experiment_ran`
  - `claims_count`
  - `classified_at` (ISO 8601)
  - `confirmed_at` (ISO 8601)

### 6. Read-Back Verification

After all writes:
- Re-read finding file
- Verify Deep Confirmation block appears in body
- Verify frontmatter `deep_confirmed` field matches
- Return `readback_verified: false` with mismatch description if verification fails

## Deep Confirmation Block Format

### For Experiment Ran

```markdown
#### Deep Confirmation

**Value**: Yes

**Classification**: needs_confirmation - Empirical SQL injection claim with testable reproduction

**Experiment Ran**: true

**Claims Enumerated**: 2 (C1, C2)

**Claim C1**:
**Baseline**: POST /login with malicious username returned 200 with all users
**Candidate**: POST /login with parameterized query returned 400
**Verdict**: confirmed

**Claim C2**:
**Baseline**: Query with special characters bypassed validation
**Candidate**: Input validation rejected special characters
**Verdict**: confirmed

**Verdict**: Yes

**Timestamp**: 2024-06-22T21:30:00Z
```

### For Auto-Skip

```markdown
#### Deep Confirmation

**Value**: N/A

**Auto-Skip Reason**: Style: variable naming convention has no runtime behavior to reproduce or measure

**Timestamp**: 2024-06-22T21:30:00Z
```

## Rules

- **Valid values only** - `Yes`, `No`, `N/A`, or `Blocked` only
- **Frontmatter is canonical** - Status in frontmatter is source of truth
- **Never overwrite history** - Append to existing blocks
- **Read-back verification** - Verify all writes before returning
- **No mutations beyond scope** - Only finding-file edits and fixture updates

## Integration

This is the final stage in deep confirmation:
```
deep-confirm-experiment → deep-confirm-record
```

## Dependencies

- Requires deep_confirmed value from experiment
- Requires finding file in report directory
- Requires status fixture for sync

## See Also

- `deep-confirm-experiment` - Provides results to record
- `deep-confirm` - Orchestrates full confirmation workflow
- `status-deep-confirmation.json` - Canonical status lifecycle