---
name: risk-scan
description: "Subtask that scans one risk domain and returns compact hypotheses, not findings"
version: 1.0.0
author: Mark Heramis
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [code-review, evidence-first, verification, workflow]
    related_skills: [evidence-first-code-review]
---

# Risk Scan

Running as a subtask. Scan one bounded review domain and return hypotheses for the main agent to verify. Language- and OS-agnostic.

## Purpose

- Perform focused, domain-specific code scanning
- Generate hypotheses for verification (not final findings)
- Enable parallel scanning across multiple domains
- Keep output compact for efficient processing

## Inputs

- Risk domain (one of the domains below)
- Relevant paths/modules (from `baseline-map`)
- Target revision and project toolchain
- Focus areas note (from `baseline-map`)

## Risk Domains

Choose exactly one domain per scan:

| Domain | Focus |
|--------|-------|
| `error-handling` | Crash/panic/abort paths, swallowed errors, unchecked assumptions |
| `concurrency` | Blocking in async, task/thread leaks, races, shared-state misuse |
| `security-boundary` | Input validation, path/command handling, deserialization, unsafe code |
| `performance` | Avoidable allocation, copying, buffering, repeated work, contention |
| `dependency` | Stale, duplicated, risky, or excessive dependencies |
| `test-coverage-gap` | Risky behavior without edge/error/security/concurrency coverage |

## Allowed Work

- Read source code, tests, docs, and config
- Use glob, grep, and code-navigation tools
- Run read-only shell commands
- Access LSP for symbol definitions and references

## Forbidden Work

- **No edits or destructive ops** - Read-only only
- **No final confidence assignment** - Return hypotheses, not findings
- **No broad search dumps** - Targeted, surgical queries only
- **No network calls beyond documentation** - Primary sources only

## Output Schema

```yaml
subtask: code-review-risk-scan
status: pass | fail | blocked | needs_main_review
scanner:
  name: "error-handling"
  version: "1.0"

scope:
  files:
    - "src/handlers/request.go"
    - "src/database/query.go"
  symbols:
    - "handle_request"
    - "execute_query"

suspicions:
  - id: "ERR-001"
    confidence_seed: high
    area: "error-handling"
    path: "src/handlers/request.go"
    symbol: "handle_request"
    line_range: "45-67"
    evidence_excerpt: "err := json.Unmarshal(data, &req)\nif err != nil {\n  log.Printf(\"parse error: %v\", err)\n  return\n}"
    why_it_matters: "JSON parse errors are logged but not propagated to caller"
    suggested_verification: "Check if caller expects error return for invalid JSON"
    suggested_experiment: "Send malformed JSON and verify response"

  - id: "ERR-002"
    confidence_seed: medium
    area: "error-handling"
    path: "src/database/query.go"
    symbol: "execute_query"
    line_range: "120-135"
    evidence_excerpt: "rows, err := db.Query(query, args...)\nif err != nil {\n  return nil\n}"
    why_it_matters: "Database errors are silently dropped, caller can't detect failures"
    suggested_verification: "Trace error propagation to caller"
    suggested_experiment: "Simulate database connection failure"

disproven_or_ignored:
  - path: "src/utils/validation.go"
    reason: "All error paths properly return error objects"

open_questions:
  - "Are JSON parse errors expected or exceptional in this handler?"
  - "Is silent database failure intentional for idempotent operations?"

recommended_next_action: "Run finding-verification on ERR-001 and ERR-002"
```

## Workflow

1. **Understand the domain**
   - Review the domain's focus areas
   - Identify relevant code paths and symbols
   - Note domain-specific patterns and anti-patterns

2. **Surgical inspection**
   - Use grep to find domain-relevant code patterns
   - Use LSP to navigate symbol definitions and references
   - Read only necessary code sections
   - Focus on high-risk areas from `baseline-map`

3. **Generate hypotheses**
   - For each potential issue, create a suspicion entry
   - Assign initial confidence (high/medium/low)
   - Provide specific evidence and line ranges
   - Suggest verification approach

4. **Filter and prioritize**
   - Mark clearly disproven or irrelevant findings
   - Note open questions needing clarification
   - Recommend next action for main agent

## Rules

- **One domain per scan** - Do not mix domains
- **Hypotheses only** - Return suspicions, not confirmed findings
- **Surgical reading** - Never dump entire files
- **Evidence-based** - Every suspicion needs code evidence
- **Clear verification path** - Suggest how to confirm or disprove

## Confidence Seeds

| Seed | When to Use |
|------|-------------|
| `high` | Direct code evidence shows clear issue pattern |
| `medium` | Strong evidence but needs more context or verification |
| `low` | Plausible concern but needs significant investigation |

## Integration

Run in parallel after `baseline-map`:
```
baseline-map → risk-scan (error-handling)
            → risk-scan (concurrency)
            → risk-scan (security-boundary)
```

## Dependencies

- Requires completed `baseline-map` with focus areas
- Requires access to source code and git history
- Requires LSP or equivalent code navigation tools

## See Also

- `baseline-map` - Provides focus areas and scope
- `finding-verification` - Validates hypotheses into findings
- `experiment-summary` - Tracks validation experiments