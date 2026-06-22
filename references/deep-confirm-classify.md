---
name: deep-confirm-classify
description: "Classify a finding as needing experimental deep confirmation or auto-skip as N/A"
version: 1.0.0
author: Mark Heramis
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [code-review, evidence-first, verification, workflow]
    related_skills: [evidence-first-code-review]
---

# Deep Confirm Classify

Decide whether a finding requires experimental deep confirmation or qualifies for auto-skip (`N/A`). Enumerate every distinct testable empirical claim the finding makes. Deep confirmation is exhaustive — the experiment stage will prove or disprove each enumerated claim individually.

## Purpose

- Identify findings needing experimental confirmation
- Auto-skip non-empirical findings
- Enumerate all testable claims for exhaustive testing
- Guide experiment stage with complete claim list

## Inputs

- `finding_id` - Finding identifier
- `title` - Finding title
- `category` - Finding category
- `severity` - Severity level
- `confidence` - Confidence level
- Full finding body including description, evidence, and suggested fix
- `affected_paths` - Affected files with line ranges

## Output Schema

```json
{
  "finding_id": "F-007",
  "decision": "needs_confirmation",
  "rationale": "Empirical SQL injection claim with testable reproduction steps and observable exploit behavior",
  "claim_type": "security",
  "auto_skip_reason": null,
  "enumerated_claims": [
    {
      "claim_id": "C1",
      "claim_text": "Unparameterized query in login() accepts ' OR '1'='1 and returns all user rows",
      "claim_type": "security",
      "testable": true
    }
  ]
}
```

## Decision Criteria

### `needs_confirmation`

Finding makes at least one testable empirical claim, including:
- Security vulnerabilities with reproducible exploit paths
- Correctness bugs with observable wrong behavior
- Performance regressions measurable via benchmarks
- Data integrity risks with verifiable corruption conditions
- Concurrency issues with reproducible race windows

### `auto_skip` (`N/A`)

Finding is non-empirical with zero testable claims, including:
- Code style or naming convention violations
- Documentation gaps or outdated comments
- Architectural opinions without correctness/security impact
- Cosmetic changes with no behavioral effect

For auto-skip, `enumerated_claims` must be `[]`.

## Claim Types

| Type | When to Use |
|------|-------------|
| `security` | Security vulnerabilities, exploit paths |
| `correctness` | Bugs with observable wrong behavior |
| `performance` | Performance regressions, scalability |
| `data_integrity` | Data corruption, integrity violations |
| `concurrency` | Race conditions, deadlocks |
| `configuration` | Config issues affecting behavior |
| `dependency` | Dependency problems with runtime impact |
| `style` | Style violations (usually auto-skip) |
| `documentation` | Documentation gaps (usually auto-skip) |
| `architecture` | Architectural opinions (usually auto-skip) |

## Confidence Influence

- Confidence influences but does not dictate decision
- `Low` confidence security claim still needs confirmation
- `High` confidence style claim still auto-skips

## Edge Cases

- When uncertain, default to `needs_confirmation`
- False positive skip is worse than unnecessary experiment
- Missed confirmation is a missed vulnerability

## Enumeration Requirements

**Exhaustive enumeration when `needs_confirmation`:**

A single finding often makes multiple claims:
- Security finding may assert: exploit path AND privilege boundary AND data-leak vector
- Performance finding may assert: hot path AND scaling cliff

Split each into its own `claim_id` (`C1`, `C2`, …) with:
- One-line `claim_text`
- `testable: true`

The experiment stage runs baseline-vs-candidate comparison per claim.
`Yes` requires every enumerated claim reproduced AND resolved.

Incomplete enumeration forces `No` or `Blocked` downstream — do the work now.

## Claim Testability

A claim is `testable: false` only when behavior is genuinely unobservable without unavailable infrastructure. Route such claims in too (experiment stage will mark them `blocked`), do not drop them.

## Auto-Skip Rationale

For `auto_skip`, rationale must cite specific claim type and explain why experimental reproduction adds no value.

Example: "Style: variable naming convention has no runtime behavior to reproduce or measure"

## Rules

- **Exhaustive enumeration** - List every testable claim
- **No partial lists** - Incomplete enumeration causes downstream failures
- **Clear rationale** - Explain why decision was made
- **Edge case safety** - Default to confirmation when uncertain
- **Pure decision** - No file I/O, git operations, or experiments

## Integration

This is the first stage in deep confirmation:
```
deep-confirm → deep-confirm-classify → finding-verification
```

## Dependencies

- Requires finding details and full body
- No external tools needed

## See Also

- `deep-confirm` - Orchestrates full confirmation workflow
- `deep-confirm-experiment` - Tests enumerated claims
- `deep-confirm-record` - Records classification results