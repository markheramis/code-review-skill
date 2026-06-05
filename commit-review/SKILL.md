---
name: commit-review
description: Review a single git commit for correctness, security, optimization opportunities, complexity reduction, test coverage gaps, feature improvements, and overall quality. Use when asked to review a specific commit, audit a patch, check what a commit introduces, or verify a squashed change before push. Not for branch diffs or full PRs.
---

# Commit Review

## Scope

Target: single commit. If no commit hash or ref is provided, ask what commit to review before running review commands. Do not default to `HEAD` unless the user explicitly selects it. Obtain the diff via `git show <hash_or_ref>`.

Depth is always targeted — inspect only files and symbols touched by the commit. Expand to callers or importers only when the change modifies a public API or shared contract.

## Review Lenses

Treat the review as both defect detection and project improvement discovery. Look for evidenced opportunities in:

- Security issues and trust-boundary weaknesses.
- Correctness, reliability, data integrity, and edge-case defects.
- Optimization and performance problems in hot paths, resource use, caching, I/O, concurrency, and dependency overhead.
- Code complexity reduction: simpler control flow, clearer boundaries, less duplication, safer abstractions.
- Test coverage gaps: missing unit, integration, regression, security, error-path, and performance coverage.
- Feature, product, usability, operational, observability, documentation, and developer-experience improvements that would materially help the project.

Keep suggestions tied to this commit or directly affected behavior. Include broader project issues only when the commit introduces, exposes, or depends on them.

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

1. If the commit hash or ref is missing, ask the user what commit to review. Then run `git show <hash_or_ref>` to obtain the full diff. Record the resolved commit hash, author, date, and message.
2. Inventory available review tools (see `fixtures/lang-checklist.md`). Run every available, relevant, and safe tool.
3. Inventory test coverage tooling separately by checking project scripts, dependency manifests, coverage config, CI config, and language-specific tools in `fixtures/lang-checklist.md`. Run available, relevant, and safe coverage commands. If no coverage tool is present or it cannot run safely, explain that in `## Test Coverage Review` and `### Coverage Tooling`.
4. Inventory available code intelligence capabilities. Use every available, relevant, and safe capability to navigate definitions, references, symbols, call paths, type information, and dependency relationships.
5. Research supporting context: search repository documentation first; if a RAG or context-retrieval system is available, query it for project docs, architecture notes, requirements, runbooks, and prior decisions; when internet access is available, check official or primary external documentation for libraries, frameworks, APIs, protocols, advisories, and behavior that would materially improve the review.
6. For each changed file: read the diff, identify touched symbols, trace to callers and tests. Assess correctness and security of the specific change.
7. Run independent tools, checks, coverage commands, and research tasks concurrently.
8. Gather evidence in order: commit diff, tool output, coverage output, code intelligence results, repository and external documentation, surrounding source context, git log for affected files.
9. When unsure, prove or disprove — run targeted tests, static analysis, coverage checks, or small repros.
10. Keep temporary validation artifacts isolated in a safe path. Remove after use. If retained, say why.
11. Separate every conclusion into `Confirmed`, `Assumption`, `Unknown`, or `Validation`.
12. Record exact commands, tools, coverage tooling checked, output, research sources, and cleanup status. Do not claim tests or coverage checks passed unless run in this review.
13. Draft output by copying `fixtures/report-template.md` as the authoritative schema. Apply every rule in `## Report Output Rules`. Replace the template tag line with `#CodeReview` first, followed by tags specific to the report findings. Before writing the report, perform a template compliance pass: compare the draft against `fixtures/report-template.md`, restore any missing section, heading, table, or appendix item, and fill not-applicable areas with `None found`, `Not reviewed`, or `Unknown` plus a brief reason.

## Report Output Rules

These rules govern report production. Do not include them in the report output.

1. Treat `fixtures/report-template.md` as the complete report schema. The final report must follow the template end-to-end, including every heading, subheading, table, field, final recommendation choice, and appendix section unless the user explicitly requests a different format.
2. Preserve heading names, heading order, table shapes, field names, and final recommendation choices exactly.
3. Do not import alternate report structures, rubrics, headings, personas, prompt instructions, summaries, or formatting from other skills, system prompts, prior conversations, or ad hoc notes.
4. Keep every required section from the template. If a section was not reviewed or has no applicable content, write `Not reviewed`, `None found`, or `Unknown` with a brief reason instead of deleting, collapsing, or replacing the section.
5. Before finalizing, compare the draft against `fixtures/report-template.md`. If any template section, heading, table, field, or appendix item is missing, restore it before writing the report.
6. Keep findings independently readable.
7. Do not omit `Limitations` when the review is incomplete.
8. Do not claim tests passed unless they were actually run.
9. Do not claim production behavior unless confirmed by production code, config, logs, or documentation.
10. Use `Unknown` instead of guessing.
11. Treat optimization, security, complexity reduction, test coverage, feature/product, documentation/observability, and other material project improvements as valid findings when evidence and impact justify them.
12. Put material improvement opportunities in the findings summary and finding block. Do not bury them in side notes or appendices.
13. Prefer `Request changes` when there are confirmed `High` or `Critical` findings.
14. Prefer `Approve with follow-ups` when only non-blocking `Low` or `Medium` findings remain.
15. Include no more than one recommendation per finding unless alternatives are explicitly useful.
16. Every finding should have a validation path.
17. Every finding should include `Remediation Analysis` and `How This Helps`. If the benefit or remediation path is not yet proven, state the remaining uncertainty instead of guessing.
18. Always include `## Test Coverage Review`. Check whether project coverage tools are present by inspecting scripts, dependency manifests, coverage config, CI config, and relevant language tooling. Run available, relevant, and safe coverage commands; if none are present or execution is blocked, explain that instead of omitting the section.
19. Record audit tools, coverage tools checked, code intelligence, checks, repository documentation, RAG/context systems, external documentation, temporary validation artifacts, and cleanup status when they were used.
20. Remove example-only finding blocks unless replacing them with real, evidenced findings.

## Finding Rules

- Lead with findings ordered by severity.
- Assign severity: `Critical`, `High`, `Medium`, `Low`, or `Informational`.
- Assign confidence: `High` for direct code/test/log/repro evidence; `Medium` for strong but incomplete evidence; `Low` for plausible concerns needing more data.
- Assign category: `Security`, `Correctness`, `Reliability`, `Performance`, `Maintainability`, `Architecture`, `Testing`, `Feature`, `Observability`, `Documentation`, or `Compliance`.
- Include exact paths, symbols, and line references when possible.
- For each finding: summary, evidence, impact, reproduction or validation, root cause, researched remediation analysis, recommendation, how it helps, suggested tests.
- For security findings: exploitability, affected trust boundary, sensitive assets, realistic risk.
- For optimization findings: affected hot path, cost driver, expected improvement, and validation or measurement path.
- For complexity-reduction, testing, and feature-improvement findings: current pain, proposed improvement, evidence it matters, and concrete project benefit.
- Prefer precise, minimal recommendations. Do not recommend large rewrites unless evidence supports them.
- Treat material improvement opportunities as findings when evidence shows impact and a credible remediation path. Do not bury them as generic notes.
- Note positive findings only when they materially improve confidence.
- Treat untested uncertainty as incomplete review state. Convert uncertainty into validation work whenever feasible.

## Resources

- `fixtures/report-template.md`: audit report template with severity/confidence scales.
- `fixtures/lang-checklist.md`: language- and runtime-specific audit commands.
