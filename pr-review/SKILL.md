---
name: pr-review
description: Review a pull request including diff, description, CI status, and linked issues. Use when asked to review a PR, audit a pull request before merge, check PR quality, post inline review comments, or verify a PR resolves its linked issue. Not for bare branch diffs without PR metadata.
---

# PR Review

## Scope and Depth Detection

Target: pull request. Obtain diff and metadata via `gh pr view <number>`, `gh pr diff <number>`, and `gh pr checks <number>`. Read the PR description, linked issues, and reviewer comments before inspecting code.

Calibrate depth based on change size:

| Size | Lines changed | Files changed | Depth |
|------|--------------|--------------|-------|
| Small | ≤200 | ≤10 | Changes + directly called/imported symbols |
| Medium | ≤1000 | ≤30 | Changes + adjacent modules + affected tests |
| Large | >1000 or >30 | — | Full workflow: architecture, security, coverage, dependencies |

Start from the diff only. Expand to additional files only for symbols directly touched by the changes or to assess downstream impact.

## Report Output

Before starting:

1. Check memory for a saved report directory path for the current project (`code-review.report_dir`). Treat it as project-specific; do not reuse a path saved for a different project.
2. If found, use it only as the output destination. Do not read or list existing reports unless explicitly asked.
3. If not found, ask: *"Where should I save the review report? (Leave blank to print output only.)"*
   - Path provided: save to memory as the current project's `code-review.report_dir`, write report as `YYYY-MM-DD-pr-<number>-review.md`.
   - No path: output directly. Ask again next time.

## Workflow

1. Fetch PR metadata: `gh pr view <number>` (title, description, author, linked issues, reviewers, labels). Then `gh pr diff <number>` for the full diff. Then `gh pr checks <number>` for CI status.
2. Read PR description and linked issues first. Verify the diff actually addresses the stated goal. Note any mismatch between description and implementation.
3. Calibrate depth using the size table above.
4. Inventory available review tools (see `fixtures/lang-checklist.md`). Run every available, relevant, and safe tool.
5. Inspect changed files surgically: symbol definitions, references/usages, dependencies, targeted search, small excerpts, control/data flow, then git history. Use full-file reads only when exact surrounding context is required.
6. Run independent audit tools concurrently: type check, linter, tests for affected modules, dependency audit if lock files changed.
7. Check existing reviewer comments — do not duplicate concerns already raised and acknowledged.
8. Gather evidence in order: PR diff, CI output, tool results, surrounding source context, linked issue requirements.
9. When unsure, prove or disprove — run targeted tests, static analysis, or small repros.
10. Keep temporary validation artifacts isolated in a safe path. Remove after use. If retained, say why.
11. Separate every conclusion into `Confirmed`, `Assumption`, `Unknown`, or `Validation`.
12. Record exact commands, tools, output, and cleanup status. Do not claim tests passed unless run in this review.
13. Draft output from `fixtures/report-template.md`. Replace the template tag line with `#CodeReview` first, followed by tags specific to the report findings. End with a clear recommendation: Approve, Approve with follow-ups, or Request changes.

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
