---
name: baseline-map
description: "Build focus areas list and prior findings index from existing reports"
version: 1.0.0
author: Mark Heramis
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [baseline, code-review, evidence-first, workflow]
    related_skills: [evidence-first-code-review]
---

# Baseline Map

Build a focus areas list and a Prior Findings Index from existing reports in the report directory. This guides the current review to avoid repeating confirmed findings and focus on new or changed areas.

## Purpose

- Understand what has already been covered in prior reviews
- Identify gaps and areas needing renewed attention
- Guide the current review's focus and depth
- Enable finding deduplication across reviews

## Inputs

- Report directory path (from `inventory` or memory)
- Current git branch and commit
- Recent git history for changed areas

## Tools

- `scripts/get-findings-by-status.py` - Filter findings by status across the report directory
- `scripts/get-reports.py` - List all reports with finding counts
- `git log` - Changed area detection
- `git diff` - Coverage gap analysis

## Output Schema

```yaml
focus_areas:
  - area: "authentication module"
    priority: high
    reason: "recent commits in src/auth/"
    paths:
      - src/auth/
      - src/middleware/auth.go
  - area: "API rate limiting"
    priority: medium
    reason: "prior review marked Low confidence"
    paths:
      - src/ratelimit/

prior_findings_index:
  - id: "F-001"
    title: "SQL injection in user query"
    category: "Security"
    severity: "Critical"
    status: "Open"
    report: "repo-review-2024-06-15-1430.md"
  - id: "F-007"
    title: "Missing error handling in file upload"
    category: "Correctness"
    severity: "High"
    status: "In-Progress"
    report: "pr-123-review-2024-06-18-0915.md"

coverage_gaps:
  - area: "database migration scripts"
    reason: "excluded in prior review"
    last_reviewed: "never"
  - area: "websocket message handler"
    reason: "newly added since last review"
    last_reviewed: "never"

excluded_areas:
  - "third-party libraries in node_modules/"
  - "generated code in dist/"
  - "test fixtures and mocks"

coverage_note: |
  This review focuses on:
  - Areas changed since 2024-06-15 (git log)
  - Previously Low-confidence findings that need re-examination
  - Areas excluded or marked as limitations in prior reviews

  Prior reviews covered:
  - Authentication module (2024-06-10)
  - API endpoints (2024-06-12)
  - Data validation (2024-06-15)
```

## Workflow

1. **Scan prior findings**
   - List all finding files in report directory
   - Read frontmatter only (id, title, category, severity, status)
   - Build Prior Findings Index
   - Do NOT read finding bodies (token optimization)

2. **Identify covered areas**
   - Analyze finding paths and symbols
   - Map findings to code areas (modules, entry points, trust boundaries)
   - Identify which areas have confirmed findings
   - Note areas with only Low-confidence findings

3. **Detect changes**
   - Run `git log --since=<last-review-date> --name-only`
   - Identify files and directories changed since last review
   - Mark changed areas as high priority

4. **Build focus areas**
   - Combine: changed areas + Low-confidence findings + excluded areas
   - Assign priority: high (changed), medium (Low confidence), low (routine)
   - Include 5-10 line Focus Areas note

5. **Run external dependency check** (optional, ≤5 queries)
   - Check highest-risk dependencies for unacknowledged advisories
   - Focus on Critical/High severity findings with Open status
   - Use official advisory sources (GHSA, CVE database)

## Rules

- **Read frontmatter only** - Never read finding bodies for baseline mapping
- **Bounded external pass** - Maximum 5 dependency advisory queries
- **Focus on gaps** - Prioritize areas not covered or needing re-examination
- **Treat prior findings as ground truth** - Don't re-confirm Completed findings
- **Document exclusions** - Clearly state what's not being reviewed

## Integration

This skill follows `inventory` and precedes `risk-scan`:
```
inventory → baseline-map → risk-scan (parallel)
```

## Dependencies

- Requires completed `inventory` with report directory
- Requires git repository with history
- Requires Python 3.8+ to run the bundled `scripts/` utilities
- Does NOT require Node.js, Kilo, or any `KILO_*` environment variable to be set

## Kilo backend compatibility

This reference uses the bundled `scripts/` Python utilities as the canonical implementation. If the Kilo orchestrator is installed at `~/.config/kilo/`, the following `KILO_*` environment variables are honored as a compatible backend:

- `KILO_REPORT_DIRECTORY` — overrides the default `.ai/reports/` save path
- `KILO_CONFIG_ROOT` — when set, points at the Kilo fixtures and tools
- `KILO_TOOLS_PATH` — when set, the Node.js helpers under `~/.config/kilo/tools/*.mjs` may be used in place of the bundled Python scripts

When `KILO_*` variables are unset (the default), this reference works against the bundled `fixtures/` and `scripts/` directories only. Node.js and `~/.config/kilo/` are never required.

## See Also

- `inventory` - Catalogs environment and report surface
- `risk-scan` - Scans specific risk domains based on focus areas
- `finding-verification` - Validates new findings against prior index