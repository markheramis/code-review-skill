---
name: deep-confirm
description: "Orchestrate deep confirmation of report findings — experimentally re-prove each empirical claim or auto-skip non-empirical ones"
version: 1.0.0
author: Mark Heramis
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [code-review, evidence-first, verification, workflow]
    related_skills: [evidence-first-code-review]
---

# Deep Confirmation

Resolve every not-yet-confirmed finding to a terminal `Deep Confirmed` value (`Yes`, `No`, or `Blocked`) — or `N/A` via auto-skip. Deep confirmation is exhaustive, not holistic: it enumerates every distinct empirical claim the finding makes, designs and runs a baseline-vs-candidate experiment per claim, and demands every claim be reproduced AND resolved before `Yes`.

## Purpose

- Experimentally re-prove empirical findings
- Auto-skip non-empirical findings
- Provide rigorous confirmation evidence
- Gate issue creation on confirmed findings

## Pipeline Position

```
code-review → deep-confirm → create-issues → issue-discussion → issue-resolution (one) or report-resolution (whole)
```

This is the gate before issues: only findings with `Deep Confirmed: Yes` or `N/A` get issues filed.

## Config

- Report directory — defaults to `.ai/reports/`
- Deep-confirm status lifecycle — `fixtures/status-deep-confirmation.json` (bundled)
- Findings status lifecycle — `fixtures/status-findings.json` (bundled)

## Inputs

- Optional report directory or finding ID
- Otherwise process active report directory

## Stages (Sequential, One Finding at a Time)

### 1. Build Queue
- Record current revision (`git rev-parse HEAD`)
- Run `scripts/get-findings-by-status.py --status Open <report-dir>` to list candidate findings
- Find findings with `deep_confirmed: No`/missing
- Treat missing field as unconfirmed, add field when recording

### 2. Classify
- `deep-confirm-classify` - Decide need vs auto-skip (`N/A`)

### 3. Verify
- `finding-verification` - Confirm finding still applies at current head
- If gone/already-fixed → set Status + `Deep Confirmed: N/A`, skip to record

### 4. Experiment
- `deep-confirm-experiment` - Enumerate claims, run comparative baseline-vs-candidate
- Map aggregate to `Deep Confirmed` value
- Exhaustive: `Yes` requires every claim reproduced AND resolved
- `No` covers Partial/Ineffective/Inconclusive outcomes
- `Blocked` when claim genuinely cannot be tested

### 5. Record
- `deep-confirm-record` - Write value, status change, and evidence block
- Read back verification

## Gates

### Auto-Skip
- Auto-skipped (`N/A`) findings skip stages 3-4, go straight to record

### Confirmation Requirements
- `Deep Confirmed: Yes` only when experiment actually ran this session
- Must enumerate every claim
- Must reproduce AND resolve EVERY claim
- Never claim deep confirmation otherwise

### No Partial Credit
- `Partial` is not a valid outcome
- Any single un-reproduced or un-resolved claim → `No`

### Sequential Processing
- One finding at a time
- Never parallelize skip/confirm decision, report edits, destructive git, or heavy experiments
- Prefer documented low-resource variants on constrained hosts

### Artifact Cleanup
- Delete or promote every temp artifact before finishing
- Never leave tree dirty

## Deep Confirmation Values

| Value | When to Use |
|--------|-------------|
| `Yes` | Every claim reproduced AND resolved by experiment |
| `No` | Any claim not reproduced OR not resolved (absorbs Partial/Ineffective) |
| `Blocked` | Cannot test any claim AND no claim disproved (retry later) |
| `N/A` | Auto-skipped (non-empirical finding) |

## Final Summary

Report:
- Report directory
- Findings processed
- Counts: confirmed (`Yes`), disproven/incomplete (`No`), auto-skipped (`N/A`), blocked (`Blocked`)

Per finding:
- Enumerated claims and per-claim verdict
- Experiments run with real before/after results
- Status changes
- Artifacts deleted or promoted

If queue empty, say so and stop.

## Rules

- **Exhaustive enumeration** - Every claim must be enumerated
- **No partial credit** - All claims must be reproduced and resolved for `Yes`
- **Real experiments** - Must actually run experiments, never reasoning-only
- **Clean artifacts** - All temp files must be deleted or promoted
- **Read-back verification** - Verify all writes before completing

## Integration

This skill follows initial review:
```
code-review → deep-confirm → create-issues
```

## Dependencies

- Requires unconfirmed findings from report directory
- Requires access to all deep confirmation sub-skills
- Requires git repository access
- Requires Python 3.8+ and `scripts/get-findings-by-status.py` to list candidates
- Does NOT require Node.js, Kilo, or any `KILO_*` environment variable to be set

## Kilo backend compatibility

This reference uses the bundled `scripts/` Python utilities and `fixtures/` JSON schemas as the canonical implementation. If the Kilo orchestrator is installed at `~/.config/kilo/`, the following `KILO_*` environment variables are honored as a compatible backend:

- `KILO_REPORT_DIRECTORY` — overrides the default `.ai/reports/` save path
- `KILO_CONFIG_ROOT` — when set, points at the Kilo fixtures and tools
- `KILO_TOOLS_PATH` — when set, the Node.js helpers under `~/.config/kilo/tools/*.mjs` may be used in place of the bundled Python scripts
- `KILO_DEEP_CONFIRMATION_STATUS` — when set, the deep-confirm status lifecycle fixture is taken from the Kilo config

When `KILO_*` variables are unset (the default), this reference works against the bundled `fixtures/` and `scripts/` directories only. Node.js and `~/.config/kilo/` are never required.

## See Also

- `deep-confirm-classify` - Classifies findings for confirmation
- `deep-confirm-experiment` - Runs per-claim experiments
- `deep-confirm-record` - Records results
- `create-issues` - Files issues for confirmed findings