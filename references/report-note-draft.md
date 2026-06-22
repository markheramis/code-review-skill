---
name: report-note-draft
description: "Draft report remediation notes, finding evidence notes, or reviewer-facing PR text"
version: 1.0.0
author: Mark Heramis
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [code-review, evidence-first, reporting]
    related_skills: [evidence-first-code-review]
---

# Report Note Draft

Draft concise Markdown/YAML from facts supplied by the main agent. Draft only; never edit files. Language- and OS-agnostic.

## Purpose

- Create reviewer-facing documentation
- Draft commit and PR descriptions
- Generate issue bodies
- Document remediation results

## Inputs

- Draft type: `review_finding` | `remediation_notes` | `staleness_resolution` | `commit_pr_text` | `issue_body`
- Structured facts from the main agent or other subtasks
- Validation commands/results and branch/commit/PR info, if relevant

## Allowed Work

- Draft concise Markdown or YAML from provided facts
- Flag missing facts that would make the draft unsupported
- Check for forbidden references when drafting commit/PR text
- Follow template structures (commit-template.md, pull-request-template.md, issue-template.md)

### Draft Type Guidelines

#### `commit_pr_text`
Follow Conventional Commits structure:
- Subject: `<type>: <imperative subject>`
- Body: Context / Changes / Validation / Impact
- **CRITICAL:** Do not include report metadata:
  - No frontmatter `tags`
  - No topic tags
  - No severity/confidence labels
  - No report paths
  - No finding IDs (e.g., `F-027`)

#### `issue_body`
Follow issue-template.md structure:
- Summary / Status / Type / Context
- Current Behavior / Expected Behavior / Scope
- Evidence / Root Cause / Proposed Solution
- How This Helps / Acceptance Criteria / Validation Plan / Impact
- Check `[x] Pending` in Status (new issues start Pending)
- Check one Type box matching finding's category
- **Keep standalone and reviewer-facing** - no report path, finding IDs, or severity-label jargon

## Forbidden Work

- No editing finding files
- No inventing validation results, command output, commits, PR URLs, or evidence
- No mention of ignored, deleted, scratch, local-only, or uncommitted files in reviewer-facing text
- No report-only tags, finding files, finding IDs in commit/PR text

## Output Schema

```yaml
subtask: code-review-report-note-draft
status: pass|fail|blocked|needs_main_review
draft_type: "remediation_notes"

missing_required_facts: []
forbidden_references_detected:
  - local_temp_file
  - report_tag
  - finding_id

markdown_draft: |
  #### Remediation Notes

  **Status**: Resolved

  **Fix Summary**: Added input validation to prevent SQL injection

  **Validation Results**:
  - Targeted: `test_sql_injection_blocked` passes
  - Full: All tests pass

  **Files Changed**:
  - `src/database/query.go`

  **Change Request**: PR #456

commit_subject: "fix: add input validation to user query handler"

commit_body: |
  **Context**:
  User input was being concatenated directly into SQL queries, creating
  an injection vulnerability.

  **Changes**:
  - Added parameterized query support
  - Validate user input before query construction

  **Validation**:
  - Added `test_sql_injection_blocked` test
  - All existing tests pass

  **Impact**:
  Prevents SQL injection attacks. No breaking changes.

pr_title: "fix: add input validation to user query handler"

pr_body: |
  This PR adds input validation to prevent SQL injection vulnerabilities
  in the user query handler. Changes are limited to the query construction
  logic and include new test coverage.

pr_description: <same as commit_body>

issue_title: "SQL injection vulnerability in user query handler"

issue_body: |
  ## Summary
  User-supplied input is concatenated directly into SQL queries without
  validation, creating an injection vulnerability.

  ## Status
  [x] Pending

  ## Type
  [x] Security

  ## Context
  The user query handler accepts arbitrary query strings from the API
  and concatenates them into SQL commands.

  ## Current Behavior
  Malicious SQL can be injected via the query parameter.

  ## Expected Behavior
  Only properly validated and parameterized queries should execute.

  ## Scope
  `src/database/query.go`, API endpoint `/api/query`

  ## Evidence
  Code review shows direct string concatenation in `execute_query()`.

  ## Root Cause
  Missing input validation and parameterized query support.

  ## Proposed Solution
  Add input validation and switch to parameterized queries.

  ## How This Helps
  Prevents SQL injection attacks.

  ## Acceptance Criteria
  - [ ] Input validation implemented
  - [ ] Parameterized queries used
  - [ ] Test coverage added
  - [ ] All tests pass

  ## Validation Plan
  Run `npm test` to verify all tests pass.

  ## Impact
  Prevents security vulnerability. No breaking changes to API.

open_questions: []

recommended_next_action: "Review and publish draft"
```

## Forbidden Reference Detection

Check for these references in reviewer-facing text:
- `local_temp_file` - Temporary file paths
- `ignored_file` - Gitignored files
- `scratch_path` - Scratch directories
- `uncommitted_file` - Uncommitted files
- `report_tag` - Report-specific tags
- `finding_file_path` - Finding file paths (e.g., `.ai/reports/F-001.md`)
- `finding_id` - Finding IDs (e.g., `F-001`, `F-027`)

## Rules

- **Reviewer-facing only** - Text should be understandable without access to report
- **No internal jargon** - Avoid severity labels, confidence levels, finding IDs
- **Standalone** - Should make sense without additional context
- **Template compliant** - Follow provided templates exactly
- **Fact-based only** - Never invent facts or results

## Integration

This skill is used for documentation generation:
```
remediate-finding → report-note-draft → report-finalize
```

## Dependencies

- Requires facts from remediation results
- Requires template files for structure
- May require validation results

## See Also

- `remediate-finding` - Provides remediation facts
- `report-finalize` - Appends notes to finding
- `commit-template.md` - Commit message structure
- `pull-request-template.md` - PR description structure
- `issue-template.md` - Issue body structure