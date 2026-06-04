---
name: branch-review
description: Review a feature branch diff against a base branch for correctness, security, and quality. Use when asked to review a branch, check accumulated changes before merge, audit a feature branch, or assess regression risk from a set of commits. Not for single commits or full PRs with metadata.
---

# Branch Review

## Scope and Depth Detection

Target: diff between feature branch and base branch. Obtain via `git diff <base>..<branch>` or `git diff main..HEAD` if no base specified.

Calibrate depth based on change size:

| Size | Lines changed | Files changed | Depth |
|------|--------------|--------------|-------|
| Small | ≤200 | ≤10 | Changes + directly called/imported symbols |
| Medium | ≤1000 | ≤30 | Changes + adjacent modules + affected tests |
| Large | >1000 or >30 | — | Full workflow: architecture, security, coverage, dependencies |

Start from the diff only. Expand to additional files only for symbols directly touched by the changes or to assess downstream impact. Stop expanding once all changed symbols are traced and adjacency impact is assessed.

## Report Output

Before starting:

1. Check memory for a saved report directory path (`code-review.report_dir`).
2. If found, use it only as the output destination. Do not read or list existing reports unless explicitly asked.
3. If not found, ask: *"Where should I save the review report? (Leave blank to print output only.)"*
   - Path provided: save to memory as `code-review.report_dir`, write report as `YYYY-MM-DD-branch-<name>-review.md`.
   - No path: output directly. Ask again next time.

## Workflow

1. Run `git diff <base>..<branch>` to read the full diff. Record branch names and commit range. Run `git log <base>..<branch> --oneline` to understand commit history.
2. Calibrate depth using the size table above.
3. Inventory available review tools (see `fixtures/lang-checklist.md`). Run every available, relevant, and safe tool.
4. Inspect changed files surgically: project structure, symbol definitions, references/usages, dependencies, targeted search, small excerpts, control/data flow, then git history. Use full-file reads only when exact surrounding context is required.
5. Run independent audit tools concurrently: type check, linter, tests for affected modules, dependency audit if lock files changed.
6. Gather evidence in order: branch diff, commit log, tool output, surrounding source context, git blame for ambiguous changes.
7. When unsure, prove or disprove — run targeted tests, static analysis, or small repros.
8. Keep temporary validation artifacts isolated in a safe path. Remove after use. If retained, say why.
9. Separate every conclusion into `Confirmed`, `Assumption`, `Unknown`, or `Validation`.
10. Record exact commands, tools, output, and cleanup status. Do not claim tests passed unless run in this review.
11. Draft output from `fixtures/report-template.md`. Replace the template tag line with `#CodeReview` first, followed by tags specific to the report findings.

## Finding Rules

- Lead with findings ordered by severity.
- Assign severity: `Critical`, `High`, `Medium`, `Low`, or `Informational`.
- Assign confidence: `High` for direct code/test/log/repro evidence; `Medium` for strong but incomplete evidence; `Low` for plausible concerns needing more data.
- Assign category: `Security`, `Correctness`, `Reliability`, `Performance`, `Maintainability`, `Architecture`, `Testing`, `Observability`, `Documentation`, or `Compliance`.
- Include exact paths, symbols, and line references when possible.
- For each major finding: summary, evidence, impact, reproduction or validation, root cause, recommendation, suggested tests.
- For security findings: exploitability, affected trust boundary, sensitive assets, realistic risk.
- Prefer precise, minimal recommendations. Do not recommend large rewrites unless evidence supports them.
- Note positive findings only when they materially improve confidence.
- Treat untested uncertainty as incomplete review state. Convert uncertainty into validation work whenever feasible.

## Resources

- `fixtures/report-template.md`: audit report template with severity/confidence scales and output rules.
- `fixtures/lang-checklist.md`: language- and runtime-specific audit commands.
