---
name: remediate-implement
description: "Apply the smallest correct fix in production code with focused regression tests"
version: 1.0.0
author: Mark Heramis
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [code-review, evidence-first, remediation]
    related_skills: [evidence-first-code-review]
---

# Remediate Implement

Apply the smallest correct fix to production source files. Add focused regression tests that fail before the fix and pass after. Never broaden the scope beyond what the finding demands.

## Purpose

- Implement minimal fix for the finding
- Add targeted regression tests
- Ensure fix doesn't introduce new issues
- Verify affected test suite passes

## Inputs

- `finding_id` - Finding identifier
- `title` - Finding title
- `category` - Finding category
- `severity` - Severity level
- `affected_paths` - Affected files with line ranges
- `suggested_fix` - From finding or experiment result
- `experiment_result` - Result from verify+experiment stages

## Output Schema

```json
{
  "finding_id": "F-007",
  "implement_status": "applied",
  "files_changed": [
    {
      "path": "src/auth/login.ts",
      "change_type": "modified",
      "lines_touched": 3
    },
    {
      "path": "src/auth/__tests__/login.test.ts",
      "change_type": "added",
      "lines_added": 18
    }
  ],
  "fix_description": "Replaced string interpolation with parameterized query in authenticate()",
  "regression_tests_added": 2,
  "regression_tests_passing": 2,
  "build_passes": true
}
```

## Workflow

1. **Apply minimal fix**
   - Apply smallest change that resolves finding
   - No refactoring, no style-only changes
   - No unrelated improvements
   - Focus on exact issue described

2. **Add regression tests**
   - Add tests targeting specific vulnerability/defect
   - Tests must fail against unfixed code
   - Use project's existing test framework and conventions
   - Place tests alongside existing tests for affected module

3. **Verify test behavior**
   - Run newly added tests - should pass
   - Verify they would fail without fix (if practical)
   - Or trust experiment result if reverting is impractical

4. **Run affected test suite**
   - Run only affected module's tests (not full suite)
   - All new and existing tests in module must pass
   - Full suite validation is done in validate stage

5. **Build verification**
   - Run project's build command
   - If build fails, revert and report `implement_status: "build_failed"`
   - Include error message in result

6. **Fix lint/formatting issues**
   - If fix introduces violations, fix them before reporting
   - Ensure code passes linting and formatting checks
   - Never proceed with violations in place

7. **Atomic changes**
   - If fix touches multiple files, apply as single logical change
   - Report all files in `files_changed`
   - Ensure all changes are related to finding

## Rules

- **Minimal changes only** - Smallest fix that resolves finding
- **Targeted tests** - Regression tests specific to the finding
- **Build must pass** - Revert if build fails
- **Affected tests pass** - All tests in affected module pass
- **No unrelated changes** - Fix scope limited to finding
- **No violations** - Fix lint/formatting issues before completing
- **No commits** - Never commit, branch, or push from this stage

## Integration

This stage follows experiment:
```
remediate-experiment → remediate-implement → remediate-validate
```

## Dependencies

- Requires finding details and suggested fix
- Requires experiment_result confirmation
- Requires project build/test toolchain

## See Also

- `remediate-experiment` - Validates fix approach
- `remediate-validate` - Full validation of implementation
- `experiment-summary` - Provides experiment results