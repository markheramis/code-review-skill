---
name: deep-confirm-experiment
description: "Run a per-claim comparative baseline-vs-candidate experiment and map the result to a Deep Confirmed value"
version: 1.0.0
author: Mark Heramis
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [code-review, evidence-first, verification, workflow]
    related_skills: [evidence-first-code-review]
---

# Deep Confirm Experiment

Execute a throwaway comparative experiment to reproduce the finding's claim(s). Deep confirmation is exhaustive, not holistic: enumerate every distinct empirical claim the finding makes, then prove or disprove each one with its own baseline-vs-candidate comparison. Map the aggregate outcome to a `Deep Confirmed` value. Never alter production files.

## Purpose

- Reproduce finding claims with baseline experiments
- Test suggested fixes with candidate experiments
- Provide empirical evidence for confirmation
- Map aggregate results to confirmation status

## Inputs

- `finding_id` - Finding identifier
- `category` - Finding category
- `claim_type` - From classify stage
- Finding description with reproduction steps and expected behavior
- `suggested_fix` - From the finding
- `affected_paths` - Affected files with line ranges
- `verification_result` - From prior verification stage

## Output Schema

```json
{
  "finding_id": "F-007",
  "experiment_ran": true,
  "deep_confirmed": "Yes",
  "claims_enumerated": [
    {
      "claim_id": "C1",
      "claim_text": "Unparameterized SQL query accepts ' OR '1'='1 as username and returns all user rows",
      "category": "security",
      "baseline": {
        "command": "POST /login {\"username\": \"' OR '1'='1\", \"password\": \"any\"}",
        "result": "200 OK; response body contained full user list",
        "reproduced": true
      },
      "candidate": {
        "command": "POST /login against parameterized query build",
        "result": "400 Bad Request; no rows returned",
        "resolved": true
      },
      "verdict": "confirmed"
    }
  ],
  "aggregate_verdict": "Yes",
  "notes": null
}
```

## Workflow

### 1. Enumerate Claims

Read finding body and split into every distinct testable empirical claim:
- Security finding may assert: exploit path AND privilege boundary AND data-leak vector
- Performance finding may assert: hot path AND scaling cliff

Each claim gets:
- `claim_id` (`C1`, `C2`, …)
- One-line `claim_text`

If zero testable empirical claims, return `deep_confirmed: "N/A"` with `experiment_ran: false` and `claims_enumerated: []`.

### 2. Per-Claim Baseline + Candidate

For every enumerated claim:
- **Baseline**: Reproduce specific claimed behavior against current code
- **Candidate**: Apply suggested fix to temporary copy (patch file, temp directory, or in-memory diff - never working tree)
- Re-run same reproduction
- Capture concrete output per claim (not single holistic observation)

### 3. Deep Confirmed Mapping

Aggregate over all claims:

| Value | When to Use |
|--------|-------------|
| `Yes` | Baseline reproduces EVERY claim AND candidate resolves EVERY claim |
| `No` | ANY claim not reproduced OR reproduced but not resolved (absorbs Partial/Ineffective) |
| `Blocked` | Cannot test any claim AND no claim disproved (distinct from No) |
| `N/A` | Reserved for zero-claims case; never produced here |

**Important:** `No` absorbs former `Partial` and `Ineffective` outcomes. Any single unresolved claim collapses finding to `No`. Record which claim(s) failed in per-claim breakdown.

**Important:** `Blocked` means "could not test, retry later", while `No` means "tested and claim/fix failed". If ANY claim is actually disproved (baseline did not reproduce), aggregate is `No`, never `Blocked`.

### 4. Experiment Status

- `experiment_ran: true` only if at least one claim's baseline actually executed
- Never set `true` for reasoning-only analysis
- If enumeration happened but no experiment could execute, return `experiment_ran: false` with `deep_confirmed: "Blocked"` and document blockers

### 5. Test Harness

Document what was used per claim:
- Temp test file
- curl command
- node script

All temp artifacts must be deleted before returning.

### 6. Special Cases

**Concurrency claims:** Run per-claim experiment under load (multiple iterations or concurrent invocations). Document iteration count.

**Performance claims:** Compare timing data (baseline vs candidate) with ≥3 runs each. Report mean and variance per claim.

### 7. Aggregate Verdict

Derived strictly:
- `Yes` only if every `verdict` is `confirmed`
- `No` if any `verdict` is `disproved` or `ineffective`
- `Blocked` if no claim disproved and at least one claim is `blocked`

## Rules

- **Enumerate first** - Must list all claims before experimenting
- **No guessing** - If cannot enumerate expected behavior, mark claim `blocked` with notes citing ambiguity
- **Never alter production** - Use throwaway copies only
- **Clean artifacts** - All temp files must be deleted before returning
- **Concrete evidence** - Must provide actual experiment results, not reasoning

## Integration

This stage follows classification and verification:
```
deep-confirm-classify → finding-verification → deep-confirm-experiment → deep-confirm-record
```

## Dependencies

- Requires enumerated claims from classification
- Requires verification result confirming finding still applies
- Requires ability to create temporary artifacts

## See Also

- `deep-confirm-classify` - Provides claim enumeration
- `deep-confirm-record` - Records experiment results
- `experiment-summary` - General experiment skill