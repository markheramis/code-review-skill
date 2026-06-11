# Code Review / Audit Report: {Title}

#report #tags #audit #review

## Severity Scale

| Severity | Meaning |
| --- | --- |
| Critical | Likely exploitable or production-breaking issue with severe business, security, data integrity, or availability impact. Requires immediate remediation. |
| High | Significant bug, vulnerability, data loss risk, broken contract, or serious maintainability problem likely to affect production. |
| Medium | Real issue with limited scope, moderate risk, missing validation, fragile behavior, or likely future defect. |
| Low | Minor correctness, maintainability, readability, observability, feature, or test coverage issue. |
| Informational | Observation, improvement opportunity, or context that does not require immediate action. |

## Confidence Scale

| Confidence | Meaning |
| --- | --- |
| High | Directly confirmed from code, tests, logs, or reproducible behavior. |
| Medium | Strongly indicated by available evidence but not fully reproduced. |
| Low | Plausible concern that needs more data before treating as confirmed. |

## Executive Summary

{Brief summary of what was reviewed, overall risk level, and the most important conclusions.}

**Overall Risk:** {Critical | High | Medium | Low | Informational}\
**Review Type:** {Code Review | Security Audit | Architecture Audit | PR Review | Regression Review | Test Coverage Review | Improvement Review}\
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
- Optimization and performance-sensitive paths
- Code complexity, coupling, duplication, and maintainability
- Feature, product, usability, operational, observability, documentation, and developer-experience improvement opportunities
- Configuration and deployment assumptions, where applicable

Validation methods used:

```text
Static inspection: {Yes/No}
Tests executed: {Yes/No}
Runtime repros attempted: {Yes/No/Not applicable}
- {repro_command_or_reason}
Code intelligence used:
- {tool_or_capability}
Audit tools used:
- {tool_or_check}
Coverage tools checked:
- {tool_or_none} ({available | not_found | blocked_with_reason})
Coverage commands run:
- {command_or_none}
Commands run:
- {command}
Temporary artifacts:
- {path_or_none} ({removed | retained_with_reason | not_applicable})
Repository documentation checked:
- {doc_or_none}
RAG/context systems used:
- {system_or_none}
External documentation checked:
- {doc_or_spec}
```

## Findings Summary

> **Finding IDs must be globally unique within the project's report directory.** Run `python scripts/get-next-finding-id.py <report_dir>` before drafting findings and use the returned starting ID. Increment sequentially within the report.

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
**Category:** {Security | Correctness | Reliability | Performance | Maintainability | Architecture | Testing | Feature | Observability | Documentation | Compliance}
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

#### Remediation Analysis

{Explain the researched remediation approach. Include the repository docs, code constraints, external docs/specs/advisories, compatibility concerns, security implications, performance expectations, and alternatives considered when they materially affect the fix.}

#### Recommendation

{Concrete fix recommendation. Prefer precise, minimal changes.}

#### How This Helps

{Explain the concrete benefit: risk reduction, exploit prevention, correctness improvement, performance gain, complexity reduction, better test coverage, feature/user value, operational safety, maintainability, or developer productivity.}

#### Suggested Test Coverage

Add or update tests for:

- {test_case_1}
- {test_case_2}
- {test_case_3}

#### Remediation Notes

{Optional implementation notes, migration concerns, compatibility concerns, or rollout considerations. When remediated: include the branch name and commit hash of the fix (e.g., `bugfix/foo-bar` — `abc1234`).}

---

more findings...


## Positive Findings

List confirmed strengths that materially improve confidence.

- {Positive finding with evidence}
- {Positive finding with evidence}

## Test Coverage Review

### Coverage Tooling

| Tool / Command | Available | Executed | Result / Reason |
| --- | --- | --- | --- |
| `{coverage_tool_or_command}` | {Yes/No/Unknown} | {Yes/No} | {coverage_result_or_reason_not_run} |

If no coverage tooling is present, state what was checked (scripts, dependency manifests, coverage config, CI config, or language-specific tools) and explain that coverage could not be measured from available project tooling.

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

### Code Intelligence Used

```text
{tool_or_capability}
```

### Research Sources

```text
Repository documentation:
- {doc_or_none}
RAG/context systems:
- {system_or_none}
External documentation:
- {doc_or_spec}
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
