---
name: experiment-summary
description: "Run or design a focused finding experiment and return a compact evidence packet"
version: 1.0.0
author: Mark Heramis
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [code-review, evidence-first, workflow]
    related_skills: [evidence-first-code-review]
---

# Experiment Summary

Run or design the smallest safe experiment that proves, weakens, or disproves one finding/hypothesis. Language- and OS-agnostic.

## Purpose

- Validate findings with concrete runtime evidence
- Provide definitive proof for suspected issues
- Compare baseline vs candidate implementations
- Generate regression tests for confirmed issues

## Inputs

- Finding/hypothesis ID and the hypothesis to test
- Expected behavior
- Allowed experiment type and commands, if specified
- Temporary-file policy
- Mode: `single` (default) or `comparative` (deep confirmation)

## Modes

### Single Mode (Default)

Prove, weaken, or disprove one claim with a focused experiment.

### Comparative Mode (Deep Confirmation)

Used by `deep-confirm` workflow for exhaustive validation:

1. **Enumerate claims** - Split finding into testable empirical claims (C1, C2, ...)
2. **Baseline** - Demonstrate the problem with current code
3. **Candidate** - Apply suggested fix and measure same claim
4. **Compare** - Report whether suggestion improves outcome
5. **Aggregate** - `Yes` requires ALL claims reproduced AND resolved

## Allowed Work

- Run focused commands approved by main agent
- Use project's own toolchain
- Prefer existing tests over temporary files
- Create temporary files when necessary (clearly named)
- Delete temporary files before returning unless asked to promote

### Temporary File Naming

Use clear naming patterns:
- `tmp_review_repro_<slug>.<ext>`
- `tmp_review_test_<slug>.<ext>`

## Forbidden Work

- No broad full-suite validation unless requested
- No committing temporary files
- No editing production code as the fix
- No overstating results

## Output Schema

```yaml
subtask: code-review-experiment-summary
status: pass|fail|blocked|needs_main_review
finding_id: "F-001"
mode: single|comparative

experiment_type: existing_test|temporary_test|temporary_program|build_command|compiler_or_analyzer_diagnostic|minimal_repro|micro_benchmark|comparative_baseline_vs_candidate|other

command: "python -c \"import subprocess; subprocess.run(['evil_input'])\""
expected_result: "Should fail with security error"
actual_result: "Command succeeded, confirming vulnerability"

conclusion: supports|weakens|disproves|inconclusive|suggestion_ineffective

# Comparative mode only (leave blank in single mode):
baseline_command: "python bench_baseline.py"
baseline_result: "Mean: 1250ms, p95: 1800ms"
candidate_command: "python bench_candidate.py"
candidate_result: "Mean: 320ms, p95: 450ms"
comparison: "3.9x faster (1250ms → 320ms)"

output_excerpt: |
  ERROR: Untrusted input detected
  Traceback (most recent call last):
    File "<stdin>", line 1, in <module>

temporary_files:
  created:
    - "tmp_review_repro_sql_injection.py"
  deleted:
    - "tmp_review_repro_sql_injection.py"
  promoted: []

suggested_regression_test: |
  def test_sql_injection_blocked():
      with pytest.raises(SecurityError):
          execute_query("'; DROP TABLE users; --")

open_questions:
  - "Are there other code paths with similar vulnerability?"

recommended_next_action: "Mark finding as High confidence and include regression test"
```

## Experiment Types

| Type | When to Use |
|------|-------------|
| `existing_test` | Existing test validates the finding |
| `temporary_test` | New test written to validate finding |
| `temporary_program` | Standalone program demonstrates issue |
| `build_command` | Build errors reveal the problem |
| `compiler_or_analyzer_diagnostic` | Static analysis confirms issue |
| `minimal_repro` | Smallest possible reproduction |
| `micro_benchmark` | Performance measurement |
| `comparative_baseline_vs_candidate` | Deep confirmation comparison |
| `other` | Experiment not fitting other categories |

## Conclusions

| Conclusion | When to Use |
|------------|-------------|
| `supports` | Experiment proves the finding |
| `weakens` | Evidence suggests finding is less severe |
| `disproves` | Experiment shows finding is incorrect |
| `inconclusive` | Results unclear or ambiguous |
| `suggestion_ineffective` | Fix doesn't improve baseline (comparative mode) |

## Workflow

### Single Mode

1. **Design experiment**
   - Identify smallest testable claim
   - Design minimal reproduction
   - Choose appropriate experiment type

2. **Run experiment**
   - Execute using project toolchain
   - Capture actual output
   - Compare with expected result

3. **Analyze results**
   - Determine conclusion based on results
   - Assess confidence in conclusion
   - Identify any open questions

4. **Clean up**
   - Delete temporary files
   - Promote useful artifacts to tests
   - Document findings

### Comparative Mode

1. **Enumerate claims**
   - Split finding into testable claims
   - Design experiment for each claim

2. **Baseline measurement**
   - Run experiment on current code
   - Record baseline results

3. **Candidate measurement**
   - Apply suggested fix (throwaway)
   - Run same experiment
   - Record candidate results

4. **Comparison**
   - Compare baseline vs candidate
   - Determine improvement (or lack thereof)

5. **Aggregate**
   - Assess all claims together
   - Final aggregate conclusion

## Integration

This skill follows `finding-verification`:
```
finding-verification → experiment-summary
```

In deep confirmation workflow:
```
deep-confirm → experiment-summary (comparative mode)
```

## Dependencies

- Requires finding/hypothesis from `finding-verification`
- Requires project toolchain access
- May require temporary file creation permissions

## See Also

- `finding-verification` - Provides hypotheses for experiments
- `deep-confirm` - Orchestrate comparative experiments
- `remediate-validate` - Validate fix with similar experiments