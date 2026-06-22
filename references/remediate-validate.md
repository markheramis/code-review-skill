---
name: remediate-validate
description: "Run targeted validation then full project gate to confirm the fix introduces no regressions"
version: 1.0.0
author: Mark Heramis
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [code-review, evidence-first, remediation]
    related_skills: [evidence-first-code-review]
---

# Remediate Validate

Run a two-phase validation gate: first targeted (affected module and its direct dependents), then full (project-wide test suite, lint, type-check, build). Report any regressions or validate clean passage.

## Purpose

- Confirm fix doesn't break existing functionality
- Run appropriate validation for scope of change
- Detect regressions early
- Ensure code quality standards maintained

## Inputs

- `finding_id` - Finding identifier
- `affected_paths` - Files that were changed
- `implement_result` - Result from implement stage, including `files_changed`
- Project's test, lint, type-check, and build commands

## Output Schema

```json
{
  "finding_id": "F-007",
  "validate_status": "passed",
  "targeted_gate": {
    "ran": "npx vitest run src/auth/",
    "tests_total": 47,
    "tests_passed": 47,
    "tests_failed": 0,
    "duration_ms": 3200
  },
  "full_gate": {
    "ran": "npx vitest run && npx tsc --noEmit && npx eslint src/",
    "tests_total": 312,
    "tests_passed": 312,
    "tests_failed": 0,
    "typecheck_passed": true,
    "lint_passed": true,
    "build": "npm run build",
    "build_passed": true
  },
  "regressions": []
}
```

## Validation Gates

### Targeted Gate
- Run tests scoped to affected module(s)
- Include modules that directly import from them
- Use test runner's path filter (e.g., `vitest run <path>`, `jest --testPathPattern`)
- Focus on changed functionality

### Full Gate Sequence
1. Full test suite
2. Type-check (`tsc --noEmit` or equivalent)
3. Linter
4. Build
- Run each step sequentially
- Stop on first failure and report which step failed

## Handling Missing Tools

If full test suite is genuinely unavailable:
- Note explicitly in `full_gate.tests_skipped` with reason
- Never fabricate test results
- Document why tests are unavailable

## Regression Detection

A regression is any test, type-check, lint, or build failure that:
- Did not exist before the fix
- Was introduced by the changes
- Affects previously working functionality

Report each regression with:
- Test name (if applicable)
- Error message
- Affected file

## Monorepo Handling

For monorepos:
- Limit full gate to affected package/workspace plus shared dependencies
- Document scope in `full_gate.scope`
- Example: `scope: "packages/auth plus shared/utils"`

## File Validation

- Validate that all `files_changed` from implement are tracked by git
- Ensure no temporary or generated files in changed set
- Check `git status` for untracked files

## Output for Failures

```json
{
  "finding_id": "F-007",
  "validate_status": "failed",
  "targeted_gate": {
    "ran": "npx vitest run src/auth/",
    "tests_total": 47,
    "tests_passed": 45,
    "tests_failed": 2,
    "duration_ms": 3200
  },
  "full_gate": {
    "ran": null,
    "tests_skipped": "targeted gate failed"
  },
  "regressions": [
    {
      "test": "test_user_login_with_invalid_credentials",
      "file": "src/auth/__tests__/login.test.js",
      "message": "Expected 401, got 403",
      "affected_file": "src/auth/login.ts"
    }
  ]
}
```

## Rules

- **Sequential execution** - Run targeted first, then full
- **Stop on failure** - Don't continue after first gate failure
- **No fabrication** - Never fabricate test results
- **Document gaps** - Explicitly state when tools are unavailable
- **Track regressions** - Report all regressions with details
- **Validate files** - Ensure all changes are tracked

## Integration

This stage follows implementation:
```
remediate-implement → remediate-validate → remediate-warn
```

## Dependencies

- Requires implement_result with files_changed
- Requires project test/tool commands
- Requires git repository for file validation

## See Also

- `remediate-implement` - Provides changes to validate
- `remediate-warn` - Fix validation warnings
- `validation-summary` - General validation summary skill