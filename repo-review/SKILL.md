---
name: repo-review
description: Review or audit an entire repository for security, architecture, correctness, and maintainability. Use when asked to audit a codebase, review overall code quality, assess security posture, produce a formal remediation report, or review a repository with no specific PR or branch target.
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

## Report Output

Before starting:

1. Check memory for a saved report directory path for the current project (`code-review.report_dir`). Treat it as project-specific; do not reuse a path saved for a different project.
2. If not found, ask: *"Where should I save the review report? (Leave blank to print output only.)"*
   - Path provided: save to memory as the current project's `code-review.report_dir`, write report as `repo-review-YYYY-MM-DD-HHmm.md`.
   - No path: output directly. Ask again next time.
3. If report directory is known, glob for `repo-review-*.md` in that directory. For each match (sorted oldest-first), surgically read: `## Executive Summary`, `## Scope` (all three sub-sections), `## Findings Summary`, and `## Context` → `### Limitations`. Use these to:
   - Build a map of which areas (modules, entry points, trust boundaries) have already been assessed.
   - Skip re-reviewing already-confirmed findings unless new evidence changes the picture.
   - Focus the current review on: areas listed in Excluded/Limitations, areas changed since the last review (cross-check with git log), and previously Low-confidence findings.
   - Record coverage progress — note in the new report's Scope/Excluded what prior reviews already covered.

## Workflow

1. Map the repository: project structure, entry points, key modules, external dependencies. Use git log to understand recent activity and hotspots.
2. Triage risk surface using the priority order above. Identify the highest-risk areas before inspecting any code.
3. Check the report directory (if known) for prior reviews — use them to understand what was already covered and focus effort on what is new or changed.
4. Inventory available review tools (see `fixtures/lang-checklist.md`). Run every available, relevant, and safe tool.
5. Where tools are independent — security scan, dependency audit, type check, build, and test run are typically independent — run them concurrently.
6. Inspect surgically in priority order: project structure, symbol definitions, references/usages, dependencies, targeted search, small excerpts, control/data flow, then git history. Use full-file reads only when exact surrounding context is required.
7. When unsure, prove or disprove — run targeted tests, build checks, static analysis, or small repros.
8. Keep temporary validation artifacts isolated in a safe path. Remove after use. If retained, say why.
9. Separate every conclusion into `Confirmed`, `Assumption`, `Unknown`, or `Validation`. Use `Unknown` only after reasonable evidence-gathering has failed or is blocked.
10. Record exact commands, tools, observed output, temporary artifacts created, and cleanup status. Do not claim tests passed unless they ran in the current review.
11. Draft output by copying `fixtures/report-template.md` as the authoritative schema. Preserve its heading names, heading order, table shapes, field names, and final recommendation choices exactly. Do not add alternate report structures or prompt-specific sections from other instructions. Replace the template tag line with `#CodeReview` first, followed by tags specific to the report findings.

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
