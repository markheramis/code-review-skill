---
name: remediate-verify
description: "Re-verify a finding holds at the current HEAD revision; return disproven or confirmed"
version: 1.0.0
author: Mark Heramis
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [code-review, evidence-first, remediation]
    related_skills: [evidence-first-code-review]
---

# Remediate Verify

Re-verify the finding still applies at the current working tree HEAD. If the condition no longer holds (already fixed, code restructured, or the alleged vulnerability path is gone), return `disproven` immediately. Otherwise return `confirmed` with evidence.

## Purpose

- Confirm finding still needs remediation
- Detect if finding was already fixed
- Identify code restructuring that invalidated finding
- Provide updated evidence if still applicable

## Inputs

- `finding_id` - Finding identifier
- `title` - Finding title
- `category` - Finding category
- `severity` - Severity level
- `affected_paths` - Affected files with line ranges
- `target_revision` - Commit finding was reported against
- Current HEAD (`git rev-parse HEAD`)
- `staleness_result` - Result from staleness check
- `verification_result` - Result from prior verification

## Output Schema

```json
{
  "finding_id": "F-007",
  "reverify_status": "confirmed",
  "current_head": "a1b2c3d",
  "target_revision": "d4e5f6g",
  "files_checked": ["src/auth/login.ts:42-58"],
  "evidence": "SQL concatenation still present at line 47; no parameterization added",
  "discrepancy": null
}
```

## Workflow

1. **Check revision match**
   - If `current_head` equals `target_revision`
   - Skip re-inspection
   - Return `confirmed` with `evidence: "same revision as target"`

2. **Inspect affected paths**
   - For each `affected_path`, read cited lines ±10 lines
   - Verify the alleged issue still exists
   - Look for evidence of fixes or changes

3. **Handle file changes**
   - **File removed**: Check `git log -- <path>` for deletion commit
     - If deleted: return `disproven`
     - If renamed: trace via `git log --follow`, return `confirmed` with updated path
   - **Line range mismatch**: Attempt to locate code ±50 lines
     - If found at new location: return `confirmed` with corrected range in `discrepancy`
     - If not found: return `disproven`

4. **Assess changes**
   - Check if code was removed
   - Check if restructured away from vulnerable pattern
   - Check if already matches suggested fix
   - Identify what changed if disproven

5. **Return result**
   - `confirmed` - Finding still applies, with evidence
   - `disproven` - Finding no longer applies, with explanation of what changed

## Discrepancy Handling

When code moved but issue still exists:

```json
{
  "reverify_status": "confirmed",
  "files_checked": ["src/auth/login.ts:42-58"],
  "evidence": "SQL concatenation still present",
  "discrepancy": {
    "original_location": "src/auth/login.ts:47",
    "current_location": "src/auth/login.ts:52",
    "reason": "Function refactored, lines shifted by 5"
  }
}
```

## Rules

- **Same revision** - If current_head equals target_revision, return confirmed without re-inspection
- **Surrounding context** - Read cited lines ±10 lines for context
- **Atomic verification** - One-shot check, do not start implementing fixes
- **No edits** - Never edit code from this leaf
- **Clear evidence** - Always provide concrete evidence for confirmed or disproven

## Integration

This is the first stage in remediation:
```
remediate-finding → remediate-verify → remediate-experiment
```

## Dependencies

- Requires finding details from main agent
- Requires current HEAD and target revision
- Requires git repository access
- May require staleness/verification results

## See Also

- `remediate-finding` - Orchestrates full remediation
- `remediate-experiment` - Validates fix approach
- `staleness-check` - Checks if finding is outdated