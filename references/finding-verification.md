---
name: finding-verification
description: "Verify one suspected or reported finding against current code and local evidence"
version: 1.0.0
author: Mark Heramis
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [code-review, evidence-first, verification, workflow]
    related_skills: [evidence-first-code-review]
---

# Finding Verification

Verify one suspected or reported finding against the current codebase and return a compact evidence packet. Language- and OS-agnostic.

## Purpose

- Validate hypotheses with concrete evidence
- Check whether findings still apply to current code
- Gather supporting evidence from code, tests, and documentation
- Identify alternative explanations or disproving evidence

## Inputs

- Finding/hypothesis ID and summary
- Reported confidence, if any
- Affected paths, symbols, and cited line ranges
- Finding file path (resolved from the finding ID)
- Target revision and current head, if known

## Allowed Work

- Use read, glob, grep, shell, and code-navigation tools
- Inspect the affected implementation plus at least one related call site or usage path
- Inspect project docs, comments, tests, examples, and config
- Use library-doc or web tools only when external behavior is essential
- **Never send secrets or private source externally**

## Forbidden Work

- No edits, destructive ops, fix implementation, report updates, or heavy full-suite validation

## Output Schema

```yaml
subtask: code-review-finding-verification
status: pass|fail|blocked|needs_main_review
finding_id: "F-001"
reported_confidence: high|medium|low|unknown

current_code_evidence:
  - path: "src/handlers/auth.go"
    lines: "45-67"
    note: "Exact code pattern matches the reported vulnerability"

related_call_sites:
  - path: "src/api/routes.go"
    lines: "120-135"
    note: "Call site passes user input without validation"

research_summary:
  concept: "SQL injection via user-controlled query parameter"
  local_sources:
    - "src/database/query.go - shows vulnerable pattern"
    - "tests/api/auth_test.go - missing injection test coverage"
  external_sources:
    - "OWASP SQL Injection Cheat Sheet"

alternative_explanations_checked:
  - "Parameterized queries considered - not used in current implementation"
  - "Input validation middleware - bypassed in this endpoint"

experiment_recommendation: |
  Create a test case that sends malicious SQL in the 'query' parameter
  and verify database error or unauthorized data exposure.

verification_result: valid|invalid|partially_valid|needs_verification
confidence_after_verification: high|medium|low|unknown

open_questions:
  - "Is this endpoint reachable from unauthenticated users?"
  - "Are there WAF rules that might block this attack?"

recommended_next_action: "Proceed to experiment-summary for runtime validation"
```

## Workflow

1. **Locate the finding**
   - Resolve finding ID to file path
   - Read finding frontmatter and summary
   - Extract affected paths, symbols, and line ranges

2. **Inspect current code**
   - Read the cited code sections
   - Verify the issue still exists
   - Check for recent changes that may have fixed it
   - Inspect related call sites and usage patterns

3. **Gather supporting evidence**
   - Check for existing tests covering the issue
   - Review project documentation and comments
   - Search for similar patterns elsewhere in codebase
   - Consult external documentation when needed

4. **Consider alternatives**
   - Look for mitigating controls (validation, sanitization)
   - Check if the pattern is intentional with justification
   - Identify false positive indicators

5. **Assess confidence**
   - **High** - Direct code evidence confirms the issue
   - **Medium** - Strong evidence but needs more context
   - **Low** - Plausible concern needing more investigation
   - **Unknown** - Evidence insufficient to conclude

6. **Recommend next action**
   - If valid: proceed to experiment for runtime validation
   - if invalid: mark as disproven with evidence
   - if needs verification: request additional investigation

## Verification Results

| Result | When to Use |
|--------|-------------|
| `valid` | Evidence clearly confirms the finding |
| `invalid` | Evidence disproves the finding |
| `partially_valid` | Finding is real but scope/different than reported |
| `needs_verification` | Evidence inconclusive, requires experiment |

## Integration

This skill follows `risk-scan` and precedes `experiment-summary`:
```
risk-scan → finding-verification → experiment-summary
```

## Dependencies

- Requires finding ID and affected paths from `risk-scan`
- Requires access to current codebase
- May require external documentation access

## See Also

- `risk-scan` - Generates hypotheses for verification
- `experiment-summary` - Runtime validation experiments
- `staleness-check` - Checks if findings are outdated