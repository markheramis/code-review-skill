---
name: repo-review
description: Review or audit an entire repository for security, architecture, correctness, optimization opportunities, complexity reduction, test coverage gaps, feature improvements, maintainability, and overall project quality. Use when asked to audit a codebase, review overall code quality, assess security posture, produce a formal remediation report, or review a repository with no specific PR or branch target.
---

# Repository Review

## Scope

Target: full repository. No diff — assess the codebase as it stands. Use risk-surface triage to prioritize coverage.

Inspect in this priority order:

1. **Entry points** — HTTP handlers, CLI commands, public APIs, event handlers, message consumers
2. **Trust boundaries** — authentication, authorization, input validation gates
3. **Data persistence** — DB queries, file writes, cache writes, external state mutations
4. **External calls** — outbound HTTP, process execution, file system access
5. **Internal logic and error propagation** — business rules, error handling, state transitions

Stop when all identified high-risk surfaces have been assessed and a confirming pass finds no new findings at Medium severity or above. Record everything not covered in `Limitations`.

## Review Lenses

Treat the review as both defect detection and project improvement discovery. Look for evidenced opportunities in:

- Security issues and trust-boundary weaknesses.
- Correctness, reliability, data integrity, and edge-case defects.
- Optimization and performance problems in hot paths, resource use, caching, I/O, concurrency, and dependency overhead.
- Code complexity reduction: simpler control flow, clearer boundaries, less duplication, safer abstractions.
- Test coverage gaps: missing unit, integration, regression, security, error-path, and performance coverage.
- Feature, product, usability, operational, observability, documentation, and developer-experience improvements that would materially help the project.

Because this is a full-repository review, capture project-wide opportunities when evidence shows they would materially reduce risk, cost, complexity, or user/developer friction.

## Report Output

Before starting:

1. Check memory for a saved report directory path for the current project (`code-review.report_dir`). Treat it as project-specific; do not reuse a path saved for a different project.
2. If not found, ask: *"Where should I save the review report? (Leave blank to print output only.)"*
   - Path provided: save to memory as the current project's `code-review.report_dir`, write report as `repo-review-YYYY-MM-DD-HHmm.md`.
   - No path: output directly. Ask again next time.
3. If report directory is known, glob for `repo-review-*.md` in that directory. For each match (sorted oldest-first), run `python scripts/get-report-headings.py <report>` to map heading line ranges, then use `python scripts/get-heading-content.py <report> --title <heading>` to surgically read only: `## Executive Summary`, `## Scope` (all three sub-sections), `## Findings Summary`, and `## Context` → `### Limitations`. Use these to:
   - Build a map of which areas (modules, entry points, trust boundaries) have already been assessed.
   - Skip re-reviewing already-confirmed findings unless new evidence changes the picture.
   - Focus the current review on: areas listed in Excluded/Limitations, areas changed since the last review (cross-check with git log), and previously Low-confidence findings.
   - Record coverage progress — note in the new report's Scope/Excluded what prior reviews already covered.

## Workflow

1. Map the repository: project structure, entry points, key modules, external dependencies. Use git log to understand recent activity and hotspots.
2. Triage risk surface using the priority order above. Identify the highest-risk areas before inspecting any code.
3. Check the report directory (if known) for prior reviews — use them to understand what was already covered and focus effort on what is new or changed.
4. Inventory available review tools (see `fixtures/lang-checklist.md`). Run every available, relevant, and safe tool.
5. Inventory test coverage tooling separately by checking project scripts, dependency manifests, coverage config, CI config, and language-specific tools in `fixtures/lang-checklist.md`. Run available, relevant, and safe coverage commands. If no coverage tool is present or it cannot run safely, explain that in `## Test Coverage Review` and `### Coverage Tooling`.
6. Inventory available code intelligence capabilities. Use every available, relevant, and safe capability to navigate definitions, references, symbols, call paths, type information, and dependency relationships.
7. Research supporting context: search repository documentation first; if a RAG or context-retrieval system is available, query it for project docs, architecture notes, requirements, runbooks, and prior decisions; when internet access is available, check official or primary external documentation for libraries, frameworks, APIs, protocols, advisories, and behavior that would materially improve the review.
8. Where tools, checks, coverage commands, and research tasks are independent, run them concurrently.
9. Inspect surgically in priority order: project structure, symbol definitions, references/usages, dependencies, targeted search, small excerpts, control/data flow, then git history. Use full-file reads only when exact surrounding context is required.
10. When unsure, prove or disprove — run targeted tests, build checks, static analysis, coverage checks, or small repros.
11. For suspected runtime-behavior findings, try the smallest safe executable check before confirming the issue: an existing focused test, a temporary test case, a throwaway script/program, or a REPL snippet that imports the real code path and exercises the suspected edge case. Use the actual implementation under review; do not mock away the behavior being tested.
12. If a small executable repro is feasible but was not run, do not present the concern as confirmed. Assign lower confidence and state the missing validation.
13. Keep temporary validation artifacts isolated in a safe path. Remove after use unless promoting them into real regression tests. If retained, say why.
14. Separate every conclusion into `Confirmed`, `Assumption`, `Unknown`, or `Validation`. Use `Unknown` only after reasonable evidence-gathering has failed or is blocked.
15. Record exact commands, tools, coverage tooling checked, observed output, temporary artifacts created, research sources, and cleanup status. Do not claim tests or coverage checks passed unless they ran in the current review.
16. Draft output by copying `fixtures/report-template.md` as the authoritative schema. Apply every rule in `## Report Output Rules`. Replace the template tag line with `#CodeReview` first, followed by tags specific to the report findings. Before writing the report, perform a template compliance pass: compare the draft against `fixtures/report-template.md`, restore any missing section, heading, table, or appendix item, and fill not-applicable areas with `None found`, `Not reviewed`, or `Unknown` plus a brief reason.

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
16. Every finding should have a validation path. Behavior-facing findings should include an executable reproduction when feasible, or explain why it was not safe or practical.
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
- For suspected runtime bugs, prefer direct code/test/log/repro evidence. Do not elevate a code-reading hypothesis to a confirmed bug when a small safe repro was feasible but skipped.
- For security findings: exploitability, affected trust boundary, sensitive assets, realistic risk.
- For optimization findings: affected hot path, cost driver, expected improvement, and validation or measurement path.
- For complexity-reduction, testing, and feature-improvement findings: current pain, proposed improvement, evidence it matters, and concrete project benefit.
- Prefer precise, minimal recommendations. Do not recommend large rewrites unless evidence supports them.
- Treat material improvement opportunities as findings when evidence shows impact and a credible remediation path. Do not bury them as generic notes.
- Note positive findings only when they materially improve confidence.
- Treat untested uncertainty as incomplete review state. Convert uncertainty into validation work whenever feasible.

## Resources

- `scripts/get-report-headings.py`: returns all Markdown heading line ranges for surgical inspection.
- `scripts/get-heading-content.py`: extracts the content of a specific heading by title.
- `scripts/get-reports.py`: lists reports and their finding status counts as JSON.
- `scripts/get-findings-by-status.py`: extracts individual findings filtered by status, with file path and line number.
- `fixtures/report-template.md`: audit report template with severity/confidence scales.
- `fixtures/lang-checklist.md`: language- and runtime-specific audit commands.
