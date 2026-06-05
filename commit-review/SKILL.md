---
name: commit-review
description: Review a single git commit for correctness, security, and quality. Use when asked to review a specific commit, audit a patch, check what a commit introduces, or verify a squashed change before push. Not for branch diffs or full PRs.
---

# Commit Review

## Scope

Target: single commit. Obtain the diff via `git show <hash>`, or `git show HEAD` if no hash given.

Depth is always targeted — inspect only files and symbols touched by the commit. Expand to callers or importers only when the change modifies a public API or shared contract.

## Report Output

Before starting:

1. Check memory for a saved report directory path for the current project (`code-review.report_dir`). Treat it as project-specific; do not reuse a path saved for a different project.
2. If not found, ask: *"Where should I save the review report? (Leave blank to print output only.)"*
   - Path provided: save to memory as the current project's `code-review.report_dir`, write report as `commit-<hash>-review-YYYY-MM-DD-HHmm.md`.
   - No path: output directly. Ask again next time.
3. If report directory is known, glob for `commit-<hash>-review-*.md` in that directory. For each match (sorted oldest-first), surgically read: `## Executive Summary`, `## Findings Summary`, and `## Context` → `### Limitations`. Use these to:
   - Avoid re-confirming findings already marked Completed in prior reviews.
   - Elevate findings previously marked Low confidence that may now have more evidence.
   - Note findings recurring across multiple reviews.

## Workflow

1. Run `git show <hash>` (or `git show HEAD`) to obtain the full diff. Record the commit hash, author, date, and message.
2. Inventory available review tools (see `fixtures/lang-checklist.md`). Run every available, relevant, and safe tool.
3. Inventory available code intelligence capabilities. Use every available, relevant, and safe capability to navigate definitions, references, symbols, call paths, type information, and dependency relationships.
4. Research supporting context: search repository documentation first; if a RAG or context-retrieval system is available, query it for project docs, architecture notes, requirements, runbooks, and prior decisions; when internet access is available, check official or primary external documentation for libraries, frameworks, APIs, protocols, advisories, and behavior that would materially improve the review.
5. For each changed file: read the diff, identify touched symbols, trace to callers and tests. Assess correctness and security of the specific change.
6. Run independent tools, checks, and research tasks concurrently.
7. Gather evidence in order: commit diff, tool output, code intelligence results, repository and external documentation, surrounding source context, git log for affected files.
8. When unsure, prove or disprove — run targeted tests, static analysis, or small repros.
9. Keep temporary validation artifacts isolated in a safe path. Remove after use. If retained, say why.
10. Separate every conclusion into `Confirmed`, `Assumption`, `Unknown`, or `Validation`.
11. Record exact commands, tools, output, research sources, and cleanup status. Do not claim tests passed unless run in this review.
12. Draft output by copying `fixtures/report-template.md` as the authoritative schema. Apply every rule in `fixtures/output-rules.md`. Replace the template tag line with `#CodeReview` first, followed by tags specific to the report findings.

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

- `fixtures/report-template.md`: audit report template with severity/confidence scales.
- `fixtures/output-rules.md`: rules governing report production (apply but do not include in output).
- `fixtures/lang-checklist.md`: language- and runtime-specific audit commands.
