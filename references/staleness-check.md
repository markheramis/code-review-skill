---
name: staleness-check
description: "Classify report findings for staleness using git history and current code"
version: 1.0.0
author: Mark Heramis
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [analysis, code-review, evidence-first, workflow]
    related_skills: [evidence-first-code-review]
---

# Staleness Check

Run read-only git history/diff checks for one or more report findings and return a compact staleness classification. Language- and OS-agnostic.

## Purpose

- Identify findings that have been fixed since they were reported
- Detect code changes that may invalidate findings
- Classify findings by current relevance
- Recommend appropriate next actions

## Inputs

- Finding ID(s) (resolved to finding file paths)
- Target revision (when finding was created)
- Current head, if known
- Cited files and line ranges

## Allowed Work

- Read-only git commands:
  - `git rev-parse HEAD`
  - `git log --oneline <target-revision>..HEAD -- <file>`
  - `git diff <target-revision>..HEAD -- <file>`
  - `git status --short --branch`
- Inspect current cited source with read/grep/code-navigation
- Group checks by cited file to avoid redundant commands

## Forbidden Work

- No edits or destructive ops
- Do not mark reports complete yourself
- Do not infer `fully_stale_resolved` without exact fixing-commit evidence

## Classification Rules

| Classification | When to Use |
|----------------|-------------|
| `not_stale` | Cited logic unchanged and issue still present |
| `partially_stale` | Root cause persists but references/manifestation shifted |
| `fully_stale_resolved` | Exact fixing commit(s) prove the issue was fixed |
| `fully_stale_superseded` | Cited code/module/feature was removed or superseded |
| `unknown` | Evidence needs main-agent interpretation |

## Recommended Actions

Map each finding's `classification` to a `recommended_action`:

| Classification | Recommended Action |
|----------------|-------------------|
| `not_stale` | `proceed_to_verification` |
| `partially_stale` | `update_references_and_proceed_to_verification` |
| `fully_stale_resolved` | `mark_completed_with_fixing_commit_evidence` |
| `fully_stale_superseded` | `mark_closed_with_removal_evidence` |
| `unknown` | `proceed_to_verification_with_uncertainty_flag` |

**Important:** Only set `mark_completed_with_fixing_commit_evidence` when you can name the exact fixing commit(s). Otherwise downgrade to `partially_stale`.

## Output Schema

```yaml
subtask: code-review-staleness-check
status: pass|fail|blocked|needs_main_review

findings:
  - finding_id: "F-001"
    target_revision: "abc123def"
    current_head: "xyz789uvw"

    cited_files:
      - "src/handlers/auth.go"

    commits_touching_cited_files:
      - commit: "def456ghi"
        file: "src/handlers/auth.go"
        relevance: fix_candidate
      - commit: "jkl012mno"
        file: "src/handlers/auth.go"
        relevance: logic_changed

    diff_inspection_result: fully_fixed
    classification: fully_stale_resolved

    fixing_commits:
      - "def456ghi - Added input validation to auth handler"

    evidence_summary: |
      Commit def456ghi added input validation at lines 45-50
      which directly addresses the SQL injection vulnerability.

    recommended_action: "mark_completed_with_fixing_commit_evidence"

open_questions: []
```

## Commit Relevance Levels

| Relevance | When to Use |
|-----------|-------------|
| `none` | Commit doesn't affect the cited area |
| `line_shift` | Lines moved but logic unchanged |
| `logic_changed` | Logic changed but doesn't fix the issue |
| `fix_candidate` | Likely fixes the issue |
| `deletion` | Cited code was removed |

## Diff Inspection Results

| Result | When to Use |
|--------|-------------|
| `unchanged` | No changes to cited code |
| `shifted_only` | Lines moved but logic unchanged |
| `partial_fix` | Some but not all aspects fixed |
| `fully_fixed` | Issue completely addressed |
| `code_deleted` | Cited code removed |
| `unknown` | Cannot determine from diff |

## Workflow

1. **Resolve finding IDs**
   - Convert finding IDs to file paths
   - Read finding frontmatter for target revision
   - Extract cited files and line ranges

2. **Get git history**
   - For each cited file, get commits since target revision
   - Classify commit relevance
   - Identify potential fixing commits

3. **Inspect diffs**
   - For relevant commits, inspect actual changes
   - Determine diff inspection result
   - Assess whether issue is addressed

4. **Classify findings**
   - Apply classification rules
   - Determine recommended action
   - Identify fixing commits when applicable

5. **Summarize evidence**
   - Provide clear evidence summary
   - Note any open questions
   - Recommend next steps

## Integration

This skill can be used:
- Before `finding-verification` to filter stale findings
- In `verify-report` to check finding currency
- In `remediate-review` to avoid fixing already-fixed issues

## Dependencies

- Requires finding IDs and target revisions
- Requires git repository with history
- Requires ability to run read-only git commands

## See Also

- `finding-verification` - Verify non-stale findings
- `verify-report` - Verify report currency
- `remediate-review` - Fix only non-stale findings