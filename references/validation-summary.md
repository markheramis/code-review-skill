---
name: validation-summary
description: "Run validation commands sequentially and return only compact failures, warnings, and blockers"
version: 1.0.0
author: Mark Heramis
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [code-review, evidence-first, reporting]
    related_skills: [evidence-first-code-review]
---

# Validation Summary

Execute the project's validation commands and return a compact pass/fail summary that hides successful build/test noise. Language- and OS-agnostic.

## Purpose

- Validate fixes with proper testing
- Identify failures, warnings, and blockers
- Hide successful build/test noise
- Provide actionable feedback

## Inputs

- Validation type: `targeted` or `full`
- Exact commands to run, or affected test/module names
- Any resource constraints to respect

## Validation Types

| Type | When to Use |
|------|-------------|
| `targeted` | Test only affected functionality (e.g., specific test file) |
| `full` | Run full test suite, build, and validation |

## Allowed Work

- Run validation with project's own build, test, lint, and format commands
- Discover commands from manifests and CI config
- Run sequentially unless main agent confirms parallel is safe
- Prefer targeted tests before full validation
- On constrained hosts, prefer documented low-resource variants
- Avoid running multiple heavy commands at once

## Forbidden Work

- No parallel heavy commands unless explicitly approved
- No editing files or destructive ops
- No pasting full successful logs
- No claiming a command passed unless it ran in this subtask

## Failure Summarization Rules

- Include only failed command names, exit codes, failed tests
- Include assertion/panic excerpts, warning locations, resource failures
- **Omit** successful test lists and dependency/compile noise
- If output is huge, include first actionable error + note about omitted content
- Distinguish test, compile, lint, format, timeout, and resource failures

## Output Schema

```yaml
subtask: code-review-validation-summary
status: fail
validation_type: targeted

commands:
  - command: "npm test -- test_sql_injection_blocked"
    exit_code: 0
    result: pass
    duration: "2.3s"
  - command: "npm run build"
    exit_code: 0
    result: pass
    duration: "5.1s"
  - command: "eslint src/database/query.go"
    exit_code: 1
    result: fail
    duration: "1.2s"

passed: false

failed_commands:
  - command: "eslint src/database/query.go"
    exit_code: 1
    failure_kind: lint

failed_tests:
  - test: "test_sql_injection_blocked"
    file: "tests/api/query_test.js"
    message: "Expected SecurityError, but no error was thrown"
    assertion_diff: |
      Expected: SecurityError
      Received: undefined
    relevant_output_excerpt: |
      FAIL test_sql_injection_blocked (2.1s)
      Error: Expected SecurityError, but no error was thrown
        at Object.<anonymous> (tests/api/query_test.js:45:12)

warnings:
  - path: "src/database/query.go"
    line: 67
    warning: "unused variable 'userId'"
    command: "eslint"

resource_failures:
  - kind: timeout
    evidence_excerpt: "npm test timed out after 60s"

pre_existing_failure_candidates: []

main_agent_action_required: "Fix linting error and test failure"
```

## Failure Kinds

| Kind | When to Use |
|------|-------------|
| `compile` | Compilation errors |
| `test` | Test failures |
| `lint` | Linting warnings/errors |
| `format` | Formatting violations |
| `timeout` | Command exceeded time limit |
| `resource` | Out of memory, disk space, etc. |
| `unknown` | Failure type not identified |

## Workflow

1. **Determine commands**
   - Use exact commands provided
   - Or discover from manifests (package.json, Makefile, etc.)
   - Prefer targeted commands over full suite

2. **Run validation**
   - Execute commands sequentially
   - Capture exit codes and output
   - Measure duration for each command

3. **Analyze results**
   - Identify failures and their types
   - Extract relevant error excerpts
   - Distinguish new vs pre-existing failures
   - Collect warnings

4. **Summarize**
   - Hide successful output noise
   - Include actionable failures
   - Note resource constraints
   - Recommend next actions

5. **Report**
   - Provide compact summary
   - Flag blockers requiring attention
   - Suggest fixes for failures

## Resource Constraints

On constrained hosts:
- Prefer documented low-resource variants
- Avoid running multiple heavy commands at once
- Use targeted validation instead of full suite
- Monitor memory and timeout limits

## Integration

This skill validates fixes:
```
remediate-finding → validation-summary → report-finalize
```

## Dependencies

- Requires commands to run or test names to target
- Requires project toolchain access
- May require CI config for command discovery

## See Also

- `remediate-validate` - Validation-specific skill for fixes
- `warning-analysis` - Classifies warnings from validation
- `remediate-finding` - Generates fixes requiring validation