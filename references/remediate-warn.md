---
name: remediate-warn
description: "Classify all warnings from validation; fix introduced ones; report any remaining blockers"
version: 1.0.0
author: Mark Heramis
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [code-review, evidence-first, remediation]
    related_skills: [evidence-first-code-review]
---

# Remediate Warn

Classify every warning surfaced during validation (lint, type-check, test console, build). Fix any warning introduced by the remediation change. Report pre-existing warnings as documented noise. Any introduced warning left unfixed is a blocker.

## Purpose

- Identify which warnings were introduced by the fix
- Fix all introduced warnings
- Preserve pre-existing warnings (out of scope)
- Report any unfixed blockers

## Inputs

- `finding_id` - Finding identifier
- `implement_result` - Files changed
- `validate_result` - Results from validate stage, including warnings
- Lint and type-check output from full gate

## Tools

- `~/.config/kilo/tools/classify-warnings.mjs` - Deterministic classification of warnings

## Output Schema

```json
{
  "finding_id": "F-007",
  "warn_status": "clean",
  "total_warnings": 5,
  "pre_existing": [
    {
      "source": "eslint",
      "rule": "no-console",
      "file": "src/utils/logger.ts",
      "message": "Unexpected console statement",
      "count": 3
    }
  ],
  "introduced": [],
  "fixed": [],
  "unfixed_blockers": [],
  "warnings_remaining": 3
}
```

## Workflow

1. **Collect warnings**
   - Gather from full gate output:
     - Linter warnings
     - Type-check diagnostics with severity `warning`
     - Build warnings
     - Deprecation notices
     - Test console output

2. **Classify warnings**
   - Check if warning's file/line/rule affected by remediation
   - Warnings on touched lines are `introduced`
   - All other warnings are `pre_existing`
   - Use `classify-warnings.mjs` for mechanical classification

3. **Fix introduced warnings**
   - Apply minimal change to silence warning
   - Move from `introduced` to `fixed` after fixing
   - Re-run linter/type-check to confirm warning is gone

4. **Handle unfixed warnings**
   - Any introduced warning that cannot be fixed is a blocker
   - Document rationale for legitimate reasons
   - Report as `unfixed_blockers`

5. **Determine status**
   - `clean` - No introduced warnings remain
   - `fixed` - All introduced warnings fixed
   - `blocked` - Unfixed blockers remain

## Fix Guidelines

- **Minimal changes** - Apply smallest fix possible
- **Local fixes only** - Never suppress globally or disable rules project-wide
- **Preserve behavior** - Fixes must not alter program behavior
- **Document suppressions** - Comment explains why suppression is needed
- **Preferred approaches**:
  - Inline directive (e.g., `// eslint-disable-next-line`)
  - Type annotation
  - Code change

## Rules

- **Fix all introduced** - Every introduced warning must be addressed
- **Document pre-existing** - Report but don't fix pre-existing warnings
- **Block on unfixed** - Pipeline stops if unfixed blockers remain
- **No global suppression** - Never disable rules project-wide
- **Verify fixes** - Re-run tools to confirm warnings are gone

## Integration

This stage follows validation:
```
remediate-validate → remediate-warn → remediate-cleanup
```

## Dependencies

- Requires implement_result with changed files
- Requires validate_result with warnings
- Requires classify-warnings.mjs tool

## See Also

- `remediate-validate` - Provides warnings to classify
- `remediate-cleanup` - Follows warning fixes
- `warning-analysis` - General warning classification skill