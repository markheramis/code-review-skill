---
name: remediate-cleanup
description: "Remove all temporary files, verify a clean working tree, and confirm the final state before packet assembly"
version: 1.0.0
author: Mark Heramis
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [code-review, evidence-first, remediation]
    related_skills: [evidence-first-code-review]
---

# Remediate Cleanup

Sweep all temporary artifacts created during the remediation pipeline. Verify the working tree contains only the intended production and test changes. Return the final git status snapshot.

## Purpose

- Remove all temporary files and artifacts
- Verify clean working tree state
- Confirm only intended changes remain
- Identify any unexpected artifacts

## Inputs

- `finding_id` - Finding identifier
- `implement_result` - Files changed (expected modified files)
- Known temp file patterns from prior stages

## Output Schema

```json
{
  "finding_id": "F-007",
  "cleanup_status": "clean",
  "temp_files_removed": ["F-007.experiment.patch", "tmp_review_repro.py"],
  "temp_files_not_found": [],
  "git_status": {
    "staged": [],
    "unstaged_modified": ["src/auth/login.ts"],
    "unstaged_added": ["src/auth/__tests__/login.test.ts"],
    "untracked": []
  },
  "unexpected_artifacts": [],
  "tree_matches_expected": true
}
```

## Workflow

1. **Identify temp files**
   - Known patterns: `*.experiment.patch`, `/tmp/<finding_id>-*`, `*.baseline-output.log`
   - Scan for temp artifacts from all stages
   - List all temp files found

2. **Preview cleanup**
   - Run `git clean -n` (dry-run) first
   - Preview untracked files
   - Never run `git clean -f` - delete files individually

3. **Remove temp files**
   - Delete each temp file individually
   - Confirm each is a temp artifact before deletion
   - Track removed files for reporting

4. **Verify working tree**
   - Run `git status --porcelain`
   - Categorize entries:
     - `staged` - Files staged for commit
     - `unstaged_modified` - Modified but not staged
     - `unstaged_added` - New files not staged
     - `untracked` - Files not tracked by git

5. **Compare against expected**
   - Compare remaining files against `files_changed` from implement
   - Any mismatch is an `unexpected_artifact`
   - Report unexpected artifacts without deleting

6. **Determine cleanup status**
   - `clean` - Tree matches expected changes only
   - `unexpected` - Extra modified/untracked files present
   - `missing` - Expected file absent

## Rules

- **Delete individually** - Never use bulk cleanup commands
- **Confirm before delete** - Verify each file is temp artifact
- **Report unexpected** - Don't delete unexpected artifacts without user awareness
- **No destructive git ops** - Never `git stash`, `git reset`, or `git checkout` files
- **Report-only** - This skill only reports status, never makes changes

## Unexpected Artifacts

Report as `unexpected_artifacts`:
- Modified files not in `files_changed`
- Untracked files that aren't temp artifacts
- Files in unexpected locations
- Files with unexpected content

## Cleanup Status

| Status | When to Use |
|--------|-------------|
| `clean` | Tree matches expected changes exactly |
| `unexpected` | Extra modified/untracked files present |
| `missing` | Expected file is absent |

## Integration

This is the final stage before packet assembly:
```
remediate-warn → remediate-cleanup → remediate-packet
```

## Dependencies

- Requires implement_result with expected files
- Requires git repository access
- Requires knowledge of temp file patterns

## See Also

- `remediate-warn` - Precedes cleanup
- `remediate-packet` - Assembles final remediation packet
- `experiment-summary` - May create temp files needing cleanup