---
name: create-issues
description: "File one tracker work item per deep-confirmed report finding that lacks one, then record the link back into the report"
version: 1.0.0
author: Mark Heramis
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [code-review, evidence-first, reporting]
    related_skills: [evidence-first-code-review]
---

# Create Issues

File one tracker work item per deep-confirmed report finding that lacks one, following the work-item template, then write the link back into the report. Prefer an MCP tracker capability; fall back to native CLI. Never send secrets or private source to external trackers.

## Purpose

- Create tracker work items for deep-confirmed findings
- Ensure findings have external issue tracking
- Maintain link between report and tracker
- Enable external review and triage

## Pipeline Position

```
code-review → deep-confirm → create-issues → issue-discussion → issue-resolution (one) or report-resolution (whole report)
```

## Gate

A finding gets a work item only after deep confirmation:
- `Deep Confirmed` must be `Yes` or `N/A`
- Never `No`/`Blocked`/blank
- `No` (disproved/incomplete) findings routed back to `deep-confirm` if new evidence warrants
- `Blocked` findings stay in unconfirmed queue for retry

## Config

- `REPORT_PATH` - Path to the review report (required)
- `KILO_CONFIG_ROOT` - `~/.config/kilo`
- `KILO_REPORT_DIRECTORY` - `.ai/reports/`
- `KILO_TOOLS_PATH` - `<KILO_CONFIG_ROOT>/tools`
- `KILO_WORK_ITEM_TEMPLATE` - `<KILO_CONFIG_ROOT>/fixtures/issue-template.md`
- `KILO_FINDINGS_STATUS` - Status lifecycle
- `KILO_WORKFLOW_MANIFEST` - Workflow manifest

## Inputs

- Report path
- Deep-confirmed findings from report
- Tracker capability detection
- Issue template

## Output Schema

```json
{
  "tracker": "GitHub",
  "project": "myorg/myproject",
  "findings_processed": 5,
  "work_items_created": [
    {
      "id": "456",
      "url": "https://github.com/myorg/myproject/issues/456"
    }
  ],
  "skipped": [
    {
      "finding_id": "F-003",
      "reason": "Deep Confirmed: No"
    }
  ],
  "failures": [
    {
      "finding_id": "F-007",
      "error": "GitHub API rate limit exceeded"
    }
  ],
  "finding_files_updated": [
    "F-001-sql-injection.md",
    "F-005-xss-vulnerability.md"
  ]
}
```

## Workflow

1. **Get findings without issues**
   - Run `get-findings-without-issue.mjs <report-dir>`
   - Read each finding file's frontmatter `issue` field
   - Identify findings needing work items

2. **Filter findings**
   - Skip findings with `Deep Confirmed: No`/`Blocked`/blank
   - Skip `Completed`, `Closed`, and disproven findings
   - Skip findings that already have work item link in `issue` field

3. **Detect tracker capability**
   - Check workflow manifest's `capabilities.workItem` keys
   - Check active MCP tool list
   - Prefer MCP tools over native CLI
   - If no tracker capability, ask user which tracker to use

4. **Draft issue bodies**
   - Delegate to `report-note-draft` with `draft_type: issue_body`
   - Follow issue template structure
   - Map finding sections to issue fields

5. **Create work items**
   - New work items enter as **Pending**
   - Apply `pending` label plus type/category labels
   - Do not apply `Ready for Development` - triage is for `issue-discussion`
   - Create one at a time via detected capability
   - On failure, record error and move on (don't retry blindly)

6. **Update finding files**
   - Set frontmatter `issue` field to `#[{id}]({url})`
   - Finding file is single source of truth
   - No table, no column to add
   - Write back to finding file

7. **Report results**
   - Tracker + project
   - Findings processed
   - Work items created (id + URL)
   - Skipped findings and reasons
   - Failures with errors
   - Finding files updated
   - Never claim work item created unless tool returned id this session

## Body Secrecy Gate

Work item body is sole reviewer-facing artifact. External reviewers have no access to report directory or finding files. Verify none of these appear:

**Forbidden in body:**
- Finding IDs: `F-001`, `F-002`, or any `F-NNN` pattern
- Report paths: `.ai/reports/`, finding file slugs
- Internal references: "finding report", "the report file", "see finding at", "(internal)"
- Severity/confidence labels from finding frontmatter
- Any path or filename resolving to file under `.ai/`

**If any leak:** Remove them and update work item before proceeding.

**Allowed in ## Related Work:**
- Link related tracker work items
- Link related change requests
- Link public documentation, specs, upstream references

### Examples

| ❌ DO NOT include | ✅ Acceptable alternative |
|---|---|
| See finding report at F-019 (internal) | Related to ##162 (worker pool restart) |
| Severity: High, Confidence: High | (omit - this is finding metadata) |
| Fixed in .ai/reports/F-003-worker-shutdown.md | Depends on earlier fix in ##143 |
| Associated with finding F-012 | Builds on ##155 (API dispatch unification) |

## Body Format Gate

When assembling work item bodies from finding file sections:
- Strip trailing whitespace from every extracted section
- Normalize blank-line runs to at most one blank line (`\n\n`)
- After creating work item, read back and verify:
  - No runs of 3+ consecutive blank lines
  - No trailing whitespace on any line
  - No blank lines between `##` heading and content beyond single `\n\n`

## Body Encoding Gate

When writing body to temp file for `gh issue edit --body-file`, CLI may read using system code page instead of UTF-8. Non-ASCII bytes will be corrupted:

| Character | UTF-8 bytes | CP-1252 mojibake |
|---|---|---|
| `—` (em dash) | `E2 80 94` | `â€\"` |
| `'` (right single quote) | `E2 80 99` | `â€™` |
| `"` (right double quote) | `E2 80 9D` | `â€` |
| `•` (bullet) | `E2 80 A2` | `â€¢` |

**Prevention:** Always write temp files with UTF-8 BOM (`encoding='utf-8-sig'` in Python, `-Encoding UTF8` with BOM in PowerShell). After writing, read back and verify no mojibake sequences appear.

## Rules

- **Deep confirmation required** - Only create issues for deep-confirmed findings
- **One at a time** - Create work items individually
- **Update finding files** - Record issue link in frontmatter
- **Verify secrecy** - Check for forbidden references
- **Verify format** - Ensure proper formatting
- **Verify encoding** - Prevent mojibake corruption
- **Report accurately** - Never claim creation without tool confirmation

## Integration

This skill follows deep confirmation:
```
deep-confirm → create-issues → issue-discussion
```

## Dependencies

- Requires deep-confirmed findings
- Requires tracker capability (MCP or CLI)
- Requires issue template
- Requires `get-findings-without-issue.mjs` tool

## See Also

- `deep-confirm` - Deep confirms findings before issue creation
- `report-note-draft` - Drafts issue bodies
- `issue-discussion` - Triages created issues