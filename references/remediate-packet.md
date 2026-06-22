---
name: remediate-packet
description: "Assemble the final structured remediation packet from all prior stage results and return it to the main agent"
version: 1.0.0
author: Mark Heramis
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [code-review, evidence-first, remediation]
    related_skills: [evidence-first-code-review]
---

# Remediate Packet

Aggregate outputs from every stage of the remediation pipeline into a single structured packet. This is the sole artifact returned to the main agent. The main agent maps this packet into the report's `#### Remediation Notes` block.

## Purpose

- Aggregate all remediation stage results
- Provide structured output for main agent
- Enable report documentation
- Support audit trail

## Inputs

- Results from all prior stages: verify, experiment, implement, validate, warn, cleanup
- `finding_id`, `title`, `severity`, `category`

## Output Schema

```json
{
  "finding_id": "F-007",
  "title": "SQL Injection in Login Handler",
  "severity": "Critical",
  "category": "Security",
  "remediation_status": "completed",
  "fix_summary": "Replaced string interpolation in authenticate() with parameterized query using pg-prepared. Added input validation for username format.",
  "validation_results": {
    "targeted": "47/47 tests passed (src/auth/)",
    "full": "312/312 tests passed, tsc noEmit clean, eslint clean, build passed",
    "regressions": 0
  },
  "warnings": {
    "total": 5,
    "pre_existing": 3,
    "fixed": 2,
    "unfixed_blockers": 0
  },
  "files_changed": [
    {
      "path": "src/auth/login.ts",
      "change_summary": "Lines 45-47: replaced template literal query with $1 parameterized call",
      "lines_added": 2,
      "lines_removed": 1
    },
    {
      "path": "src/auth/__tests__/login.test.ts",
      "change_summary": "Added 2 regression tests: SQL injection via username field, SQL injection via password field",
      "lines_added": 18,
      "lines_removed": 0
    }
  ],
  "experiment_confirmed": true,
  "reverify_passed": true,
  "cleanup_status": "clean",
  "stage_results": {
    "verify": "confirmed",
    "experiment": "confirmed",
    "implement": "applied",
    "validate": "passed",
    "warn": "clean",
    "cleanup": "clean"
  },
  "notes": []
}
```

## Remediation Status

| Status | When to Use |
|--------|-------------|
| `completed` | All stages passed successfully |
| `disproven` | Verify stage returned disproven |
| `blocked` | Any stage blocked or has unfixed blockers |
| `incomplete` | Pipeline interrupted before completion |

## Field Requirements

### `fix_summary`
- One concise paragraph (≤200 chars)
- Suitable for commit message body and PR description
- Reference changed behavior, not finding or process
- Focus on what changed and why

### `files_changed`
- Only production source and test files
- Exclude config unless directly required by fix
- Exclude temp files, finding files, lockfiles (unless security-critical)
- Include change summary, lines added/removed

### `validation_results`
- Summarize both gates with pass/fail counts
- Include key commands run
- Document skipped gates with reason

### `stage_results`
- Flat map of stage → outcome for quick pipeline audit
- Each stage: name → outcome string

### `notes`
- Dependency hints
- Follow-up recommendations
- Non-blocking observations for main agent

## Rules

- **Assemble from actual results** - Never synthesize or summarize from memory
- **Include all stages** - Never omit stages that ran
- **No secrets** - Never include secrets, tokens, or internal paths
- **Report-only** - This skill only returns packet, never writes reports
- **No mutations** - Never commit, branch, push, or open change requests

## Integration

This is the final stage of remediation:
```
remediate-cleanup → remediate-packet → (return to main agent)
```

## Dependencies

- Requires results from all prior stages
- Requires finding metadata
- No external tools needed

## See Also

- `remediate-finding` - Orchestrates all stages
- `report-finalize` - Maps packet to Remediation Notes
- All remediation sub-skills - Provide stage results