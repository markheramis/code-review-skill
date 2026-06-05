# Code Review / Audit Report: {Title}

#report #tags #audit #review

## Severity Scale

| Severity | Meaning |
| --- | --- |
| Critical | Likely exploitable or production-breaking issue with severe business, security, data integrity, or availability impact. Requires immediate remediation. |
| High | Significant bug, vulnerability, data loss risk, broken contract, or serious maintainability problem likely to affect production. |
| Medium | Real issue with limited scope, moderate risk, missing validation, fragile behavior, or likely future defect. |
| Low | Minor correctness, maintainability, readability, observability, or test coverage issue. |
| Informational | Observation, improvement opportunity, or context that does not require immediate action. |

## Confidence Scale

| Confidence | Meaning |
| --- | --- |
| High | Directly confirmed from code, tests, logs, or reproducible behavior. |
| Medium | Strongly indicated by available evidence but not fully reproduced. |
| Low | Plausible concern that needs more data before treating as confirmed. |

## Output Rules

1. Treat this template as the complete report schema. Preserve heading names, heading order, table shapes, field names, and final recommendation choices exactly unless the user explicitly requests a different format.
2. Do not import alternate report structures, rubrics, headings, personas, prompt instructions, summaries, or formatting from other skills, system prompts, prior conversations, or ad hoc notes.
3. Keep every required section from this template. If a section was not reviewed or has no applicable content, write `Not reviewed`, `None found`, or `Unknown` with a brief reason instead of deleting or replacing the section.
4. Keep findings independently readable.
5. Do not omit `Limitations` when the review is incomplete.
6. Do not claim tests passed unless they were actually run.
7. Do not claim production behavior unless confirmed by production code, config, logs, or documentation.
8. Use `Unknown` instead of guessing.
9. Prefer `Request changes` when there are confirmed `High` or `Critical` findings.
10. Prefer `Approve with follow-ups` when only non-blocking `Low` or `Medium` findings remain.
11. Include no more than one recommendation per finding unless alternatives are explicitly useful.
12. Every finding should have a validation path.
13. Record audit tools, checks, temporary validation artifacts, and cleanup status when they were used.
14. Remove example-only finding blocks unless replacing them with real, evidenced findings.

## Executive Summary

{Brief summary of what was reviewed, overall risk level, and the most important conclusions.}

**Overall Risk:** {Critical | High | Medium | Low | Informational}\
**Review Type:** {Code Review | Security Audit | Architecture Audit | PR Review | Regression Review | Test Coverage Review}\
**Review Status:** {Complete | Partial | Blocked}


## Scope

### Included

- `{path_or_component}`
- `{path_or_component}`

### Excluded

- `{path_or_component_or_area}`
- `{path_or_component_or_area}`

### Target Revision

```text
Repository: {repository}
Branch/PR: {branch_or_pr}
Commit: {commit_hash_if_known}
Reviewed at: {date_time_if_known}
```

## Context

### Objective

{Describe the goal of the reviewed change or system.}

### Expected Behavior

{Describe the intended behavior based on requirements, docs, or user-provided context.}

### Assumptions

- {Assumption and why it was necessary}
- {Assumption and why it was necessary}

### Limitations

- {Missing information, unavailable test environment, unverified runtime behavior, etc.}
- {Limitation}

## Methodology

The review inspected:

- Code paths relevant to `{feature_or_scope}`
- Public interfaces and contracts
- Error handling and edge cases
- Security boundaries
- Data validation and persistence behavior
- Test coverage and reproducibility
- Performance-sensitive paths
- Configuration and deployment assumptions, where applicable

Validation methods used:

```text
Static inspection: {Yes/No}
Tests executed: {Yes/No}
Audit tools used:
- {tool_or_check}
Commands run:
- {command}
Temporary artifacts:
- {path_or_none} ({removed | retained_with_reason | not_applicable})
External documentation checked:
- {doc_or_spec}
```

## Findings Summary

| ID | Severity | Confidence | Category | Title | Status |
| --- | --- | --- | --- | --- | --- |
| F-001 | High | High | Security | {Finding title} | Open |
| F-002 | Medium | Medium | Correctness | {Finding title} | Open |
| F-003 | Low | High | Testing | {Finding title} | Open |
| F-004 | Medium | High | Performance | {Finding title} | Open |

Valid Status values: `Open` · `In-Progress` · `Completed` · `Accepted Risk` · `Needs Verification`

## Findings

### F-001: {Finding Title}

**Severity:** {Critical | High | Medium | Low | Informational}
**Confidence:** {High | Medium | Low}
**Category:** {Security | Correctness | Reliability | Performance | Maintainability | Architecture | Testing | Observability | Documentation | Compliance}
**Status:** {Open | In-Progress | Completed | Accepted Risk | Needs Verification}

#### Summary

{One-paragraph explanation of the issue.}

#### Evidence

```text
File: {relative/path.ext}
Symbol: {function/class/module}
Lines: {line_range_if_available}
```

{Explain the specific evidence. Quote only the minimum code necessary.}

```text
{small_code_excerpt}
```

#### Impact

{Explain what can go wrong and who or what is affected.}

#### Reproduction / Validation

```text
{command_to_reproduce_or_validate}
```

Expected result:

```text
{expected_result}
```

Observed result:

```text
{observed_result_if_known}
```

#### Root Cause

{Explain the underlying implementation or design cause.}

#### Recommendation

{Concrete fix recommendation. Prefer precise, minimal changes.}

#### Suggested Test Coverage

Add or update tests for:

- {test_case_1}
- {test_case_2}
- {test_case_3}

#### Remediation Notes

{Optional implementation notes, migration concerns, compatibility concerns, or rollout considerations.}

---

more findings...


## Positive Findings

List confirmed strengths that materially improve confidence.

- {Positive finding with evidence}
- {Positive finding with evidence}

## Test Coverage Review

### Existing Coverage

| Area | Coverage Status | Notes |
| --- | --- | --- |
| Unit tests | {Good/Partial/Missing/Unknown} | {notes} |
| Integration tests | {Good/Partial/Missing/Unknown} | {notes} |
| Regression tests | {Good/Partial/Missing/Unknown} | {notes} |
| Security tests | {Good/Partial/Missing/Unknown} | {notes} |
| Error-path tests | {Good/Partial/Missing/Unknown} | {notes} |

### Recommended Tests

| Priority | Test | Purpose |
| --- | --- | --- |
| High | `{test_name}` | {what it verifies} |
| Medium | `{test_name}` | {what it verifies} |
| Low | `{test_name}` | {what it verifies} |

## Security Review

### Trust Boundaries

- {Boundary, e.g. external API input to application service}
- {Boundary}

### Sensitive Assets

- {tokens, credentials, PHI/PII, files, database records, etc.}
- {asset}

### Security Observations

| Area | Status | Notes |
| --- | --- | --- |
| Authentication | {Pass/Concern/Unknown/Not Applicable} | {notes} |
| Authorization | {Pass/Concern/Unknown/Not Applicable} | {notes} |
| Input validation | {Pass/Concern/Unknown/Not Applicable} | {notes} |
| Output encoding | {Pass/Concern/Unknown/Not Applicable} | {notes} |
| Secrets handling | {Pass/Concern/Unknown/Not Applicable} | {notes} |
| Logging safety | {Pass/Concern/Unknown/Not Applicable} | {notes} |
| Dependency risk | {Pass/Concern/Unknown/Not Applicable} | {notes} |
| Data persistence | {Pass/Concern/Unknown/Not Applicable} | {notes} |

## Architecture / Maintainability Review

### Observations

- {Observation}
- {Observation}

### Coupling / Cohesion

{Assess whether the implementation is appropriately modular.}

### Error Handling

{Assess error propagation, logging, recovery, and failure behavior.}

### Performance Considerations

{Assess obvious performance risks or confirm no material concern found.}

## Remediation Plan

| Priority | Finding | Recommended Action | Owner | Verification |
| --- | --- | --- | --- | --- |
| P0 | F-001 | {action} | {owner_or_TBD} | {test_or_check} |
| P1 | F-002 | {action} | {owner_or_TBD} | {test_or_check} |
| P2 | F-003 | {action} | {owner_or_TBD} | {test_or_check} |
| P2 | F-004 | {action} | {owner_or_TBD} | {test_or_check} |

## Remediation Workflow

Use this workflow to resolve findings. Work one finding at a time. Do not start the next finding until the current one is committed.

1. Pick the highest-priority Open finding from the Remediation Plan. Update its Status to `In-Progress` in both `## Findings Summary` and the finding block.
2. Analyze the finding: read the Evidence, Root Cause, and Recommendation sections. Confirm the issue still exists in the current codebase.
3. Plan the fix: identify the minimal change needed. Prefer targeted edits over rewrites.
4. Implement the fix.
5. Write or update targeted tests covering the changed behavior. Tests must pass and must achieve high coverage of the changed code paths.
6. Run the full test suite to verify no existing behavior is broken.
7. Commit the fix to an appropriately named branch: `{hotfix|bugfix|refactor|docs|chore}/{descriptive-branch-name}`. Write the commit message to describe what changed and why — do not reference this report file, report IDs, or internal review artifacts. The commit message must stand on its own for anyone reading the repository history.
8. Push the branch.
9. Update the finding's Status to `Completed` in both `## Findings Summary` and the finding block. Add a brief note under `#### Remediation Notes` with the branch name and commit hash.
10. Repeat from step 1 for the next Open finding.

## Final Recommendation

Choose one:

- **Approve**: no blocking issues found.
- **Approve with follow-ups**: issues exist but can be handled after merge.
- **Request changes**: issues should be fixed before merge.
- **Block release**: risk is too high for production release.

**Recommendation:** {Approve | Approve with follow-ups | Request changes | Block release}

### Rationale

{Explain the decision briefly and tie it to the findings.}

## Appendix

### Commands Run

```text
{command}
```

### Audit Tools Used

```text
{tool_or_check}
```

### Temporary Validation Artifacts

```text
{path_or_none} - {removed | retained_with_reason | not_applicable}
```

### Files Reviewed

```text
{relative/path.ext}
{relative/path.ext}
```

### References

- {Official documentation, internal doc, spec, issue, PR, or test file}
- {Reference}
