---
name: remediate-experiment
description: "Run a throwaway candidate-vs-baseline experiment confirming the fix before touching production code"
version: 1.0.0
author: Mark Heramis
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [code-review, evidence-first, remediation]
    related_skills: [evidence-first-code-review]
---

# Remediate Experiment

Run a throwaway comparative experiment to confirm the suggested fix produces the expected behavioral change. Use a temporary working copy or in-memory diff - never alter production files. Return the experiment result to gate the implement stage.

## Purpose

- Validate fix approach before implementation
- Confirm behavioral change matches expectations
- Detect regressions early
- Gate implementation with evidence

## Inputs

- `finding_id` - Finding identifier
- `category` - Finding category
- `suggested_fix` - From finding or experiment summary
- Baseline behavior description
- Candidate change (inline or as diff)

## Output Schema

```json
{
  "finding_id": "F-007",
  "experiment_status": "confirmed",
  "mode": "comparative",
  "baseline_result": "Unparameterized query accepted injection payload",
  "candidate_result": "Parameterized query rejected injection payload",
  "test_command": "npx vitest run src/auth/__tests__/login.injection.test.ts",
  "evidence": "Test passed: injection attempt returned 400 instead of 200"
}
```

## Experiment Modes

| Mode | When to Use |
|------|-------------|
| `prior` | Prior experiment was already `comparative` |
| `single` | Need to run new throwaway experiment |
| `comparative` | New comparative experiment |

## Workflow

1. **Check prior experiment**
   - If prior experiment was `comparative`, skip this stage
   - Return prior result with `mode: "prior"`

2. **For single mode experiments**
   - Create temporary file: `<finding_id>.experiment.patch`
   - Apply to throwaway copy of affected files
   - Run relevant test suite
   - Discard patch
   - **Never modify working tree**

3. **For testless experiments**
   - If no test harness covers affected area
   - Run candidate change in isolation via temporary script
   - Document:
     - Input provided
     - Expected output
     - Actual output
   - Delete temporary script

4. **Assess results**
   - `confirmed` - Candidate fixes the issue
   - `ineffective` - Candidate does not fix the issue
   - `regression` - Candidate breaks other behavior
   - `inconclusive` - Cannot determine without production integration

5. **Clean up**
   - Delete all temporary files and patches
   - Verify working tree is clean
   - Never leave artifacts

## Experiment Status

| Status | When to Use | Pipeline Action |
|--------|-------------|-----------------|
| `confirmed` | Candidate fixes the issue | Proceed to implement |
| `ineffective` | Candidate doesn't fix | Stop pipeline |
| `regression` | Candidate breaks behavior | Stop pipeline |
| `inconclusive` | Can't determine without production | Stop pipeline |

## Rules

- **Never alter production** - Use throwaway copies only
- **Clean up always** - Delete all temp files before returning
- **Evidence required** - Document actual results, not assumptions
- **Stop on failure** - Don't proceed to implement if experiment fails
- **Working tree clean** - Must be clean before returning

## Integration

This stage follows verification:
```
remediate-verify → remediate-experiment → remediate-implement
```

## Dependencies

- Requires finding details and suggested fix
- Requires test harness or ability to create temporary scripts
- Requires git repository access

## See Also

- `remediate-verify` - Confirms finding still applies
- `remediate-implement` - Implements fix if experiment confirmed
- `experiment-summary` - General experiment skill