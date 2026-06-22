---
name: warning-analysis
description: "Classify compiler, linter, and test warnings with compact root-cause summaries"
version: 1.0.0
author: Mark Heramis
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [analysis, code-review, evidence-first, workflow]
    related_skills: [evidence-first-code-review]
---

# Warning Analysis

Classify warnings from validation output or a specific command and return compact, actionable root-cause summaries. Language- and OS-agnostic.

## Purpose

- Understand warning root causes
- Distinguish new vs pre-existing warnings
- Identify blockers vs non-critical issues
- Provide actionable fix suggestions

## Inputs

- Warning output, or the exact command that produced warnings
- Current diff/touched files, if known
- Finding/remediation branch context, if relevant

## Allowed Work

- Inspect warning output and related source
- Re-run the exact warning-producing command only if main agent asks and it is safe
- Use `git diff --name-only` or other read-only git commands to tell whether warnings are in touched files

## Forbidden Work

- No edits, suppression, weakening of validation flags, or destructive ops

## Warning Categories

| Category | Examples |
|----------|----------|
| `compiler` | Type errors, unreachable code, deprecated APIs |
| `linter` | Style issues, unused variables, complexity |
| `deprecation` | Use of deprecated features |
| `unused` | Unused imports, variables, or functions |
| `dead_code` | Unreachable or never-executed code |
| `unsafe` | Unsafe operations, missing null checks |
| `documentation` | Missing docs, docstring issues |
| `dependency_api` | Breaking changes in dependencies |
| `project_lint` | Project-specific lint rules |
| `unknown` | Warnings not fitting other categories |

## Output Schema

```yaml
subtask: code-review-warning-analysis
status: pass|fail|blocked|needs_main_review

warning_analysis:
  - command: "cargo clippy"
    category: compiler
    path: "src/handlers/request.rs"
    line: 45
    warning_code_or_lint: "unused_variables"
    message: "variable `user_id` is never used"
    touched_by_current_branch: yes
    likely_pre_existing: no
    root_cause: "Variable declared but never used after error check"
    suggested_fix: "Remove unused variable or use it in error handling"
    suppression_justified: no

  - command: "eslint"
    category: linter
    path: "src/utils/format.js"
    line: 120
    warning_code_or_lint: "no-console"
    message: "Unexpected console statement"
    touched_by_current_branch: no
    likely_pre_existing: yes
    root_cause: "Debug console.log left in production code"
    suggested_fix: "Remove or replace with proper logging"
    suppression_justified: yes

summary:
  introduced_warning_count: 3
  pre_existing_warning_count: 12
  blockers:
    - "src/handlers/request.rs:45 - unused variable prevents optimization"
    - "src/auth/token.rs:78 - unsafe unwrap may cause panic"

open_questions:
  - "Should we enable stricter linter rules?"

recommended_next_action: "Fix 3 introduced warnings, address 2 blockers"
```

## Workflow

1. **Parse warning output**
   - Extract individual warnings
   - Identify warning type and category
   - Extract file paths and line numbers

2. **Determine context**
   - Check if warnings are in files touched by current changes
   - Use `git diff --name-only` to identify changed files
   - Mark warnings as introduced vs pre-existing

3. **Analyze root cause**
   - Read the cited code sections
   - Understand why warning occurs
   - Identify if warning is legitimate or false positive

4. **Assess impact**
   - Determine if warning is a blocker
   - Check if suppression is justified
   - Prioritize warnings by severity

5. **Suggest fixes**
   - Provide actionable fix suggestions
   - Consider trade-offs (suppression vs fix)
   - Note any risks associated with fixes

6. **Summarize**
   - Count introduced vs pre-existing warnings
   - Identify blockers requiring attention
   - Recommend next actions

## Blocker Criteria

Warnings are blockers when they:
- Indicate potential runtime errors or panics
- Prevent compilation or successful tests
- Represent security vulnerabilities
- Break critical functionality

## Suppression Justification

Suppression is justified when:
- Warning is a false positive
- Code intentionally violates the rule with good reason
- Fix would introduce worse problems
- Warning is in third-party code you control

## Integration

This skill is used in:
- `remediate-validate` - Check for new warnings after fixes
- `finding-verification` - Understand code quality issues
- `report-finalize` - Ensure report doesn't introduce warnings

## Dependencies

- Requires warning output or command to run
- Requires git repository for diff checking
- Requires access to source code

## See Also

- `remediate-validate` - Validate fixes without new warnings
- `finding-verification` - Verify findings including warnings
- `remediate-warn` - Address warnings specifically