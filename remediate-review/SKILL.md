---
name: remediate-review
description: Apply fixes for Open findings in a review report, including security issues, optimization opportunities, complexity reduction, test coverage gaps, feature improvements, and other project improvements. Use after any review skill to work through findings one-by-one, implement fixes, run tests, and update report statuses. Not for finding new issues — only for resolving existing ones.
---

# Remediate Review

## Purpose

Fix Open findings in a code review report. Takes one finding at a time: analyze, implement, test, commit, update status. Only works on findings already confirmed by a review skill (`commit-review`, `branch-review`, `pr-review`, `repo-review`).

## Report Discovery

1. Check memory for a saved report directory path (`code-review.report_dir`). If not found, ask: *"Where are the review reports stored?"*
2. Run `python scripts/get-reports.py <report_dir>` to list all reports with finding counts.
   - The script outputs JSON — each entry has `file` (filename) and `findings` (counts by status).
3. Pick the best candidate:
   - Prefer reports with `open > 0` or `in-progress > 0`.
   - When multiple qualify, prefer the most recent (by filename timestamp).
   - If exactly one `in-progress` exists, resume it.
4. If no reports have Open or In-Progress findings, report that and exit.

## Workflow

Work one finding at a time. Do not start the next finding until the current one is validated, committed, pushed, and the user has answered whether to create a pull request.

1. Run `python scripts/get-report-headings.py <report>` to map the report's heading line ranges, then use `python scripts/get-heading-content.py <report> --title <title> --type h3` to surgically read each finding block on demand.
2. Pick the highest-priority Open finding from the report's `## Findings Summary` table. Priority order: Critical → High → Medium → Low → Informational.
3. Update its Status to `In-Progress` in both `## Findings Summary` and the finding block. Write the modified report back to disk.
4. Analyze: read the finding's Evidence, Impact, Root Cause, Remediation Analysis, Recommendation, How This Helps, and Suggested Test Coverage. Confirm the issue still exists in the current codebase before fixing. For runtime-behavior findings, prefer the smallest safe executable check: an existing focused test, a temporary test case, a throwaway script/program, or a REPL snippet that imports the real code path and exercises the reported edge case. If an older report lacks Remediation Analysis or How This Helps, derive them from the evidence and research before changing code.
5. Research supporting context for this finding: search repository documentation first; if a RAG or context-retrieval system is available, query it for relevant project docs, architecture notes, requirements, runbooks, and prior decisions; when internet access is available, check official or primary external documentation for libraries, frameworks, APIs, protocols, advisories, and behavior needed to remediate accurately.
6. Plan the fix: identify the minimal change needed and the expected project benefit. Prefer targeted edits over rewrites. Use the research context to validate the intended behavior, API contracts, compatibility constraints, performance expectations, test strategy, and security implications.
7. Implement the fix.
8. Write or update targeted tests covering the changed behavior. Promote any useful temporary repro into a real regression test when it is stable, maintainable, and within scope. Tests must pass and achieve high coverage of the changed code paths.
9. Run the full test suite to verify no existing behavior is broken.
10. Update relevant documentation to reflect the change (inline docs, README, changelogs, API docs, architecture notes — whatever applies to the scope of the fix).
11. Commit the fix to an appropriately named branch: `{hotfix|bugfix|refactor|docs|chore}/{descriptive-branch-name}`. Write the commit message to describe what changed and why — do not reference the report file, report IDs, or internal review artifacts. The commit message must stand on its own for anyone reading the repository history.
12. Push the branch.
13. Ask the user whether to create a pull request for this remediation before moving to the next finding. If the user says yes, create the PR and record its URL. If the user says no, continue without creating one and record that choice.
14. Update the finding's Status to `Completed` in both `## Findings Summary` and the finding block. Add a brief note under `#### Remediation Notes` with the branch name, commit hash, PR URL or no-PR decision, validation performed, research sources used, and the concrete benefit delivered or still needing measurement. Write the modified report back to disk.
15. Repeat from step 1 for the next Open finding.

**When tests are unavailable:** If the project has no test infrastructure, skip steps 8–9. Document the omission in `#### Remediation Notes`.

## Finding Rules

- Only fix findings that are `Open` or `In-Progress`. Do not touch `Completed`, `Accepted Risk`, or `Needs Verification`.
- Trust the original review's Evidence, Impact, Root Cause, Remediation Analysis, Recommendation, and How This Helps. If the finding appears wrong (already fixed, not reproducible, misunderstood the code), do not silently skip — mark it `Needs Verification` with a note explaining why.
- Temporary repro files are validation artifacts. Keep them isolated, delete them after use unless promoted into committed tests, and record the cleanup status.
- Use supplementary research to remediate the current finding accurately. Do not broaden into a new audit or introduce unrelated fixes.
- Preserve the finding's intended benefit. If implementation evidence changes the expected security, performance, complexity, coverage, feature, or project-quality impact, update `#### Remediation Notes` clearly.
- After all Open findings are resolved, print a summary: total fixed, skipped, and any remaining.
- Do not introduce new findings. If you spot a new issue while fixing, note it in `#### Remediation Notes` for the current finding and suggest running a review skill again.

## Output Discipline

- Record exact commands, tools, repository documentation, RAG/context systems, external documentation, and cleanup status for each fix.
- Do not claim tests passed unless they were run in this remediation session.
- The report file is the source of truth — always write status updates back to it immediately.
- Finding IDs are globally unique within the project's report directory. When cross-referencing findings from another report in Remediation Notes, use the globally unique `F-XXX` ID — it resolves unambiguously.

## Resources

- `scripts/get-report-headings.py`: returns all Markdown heading line ranges for surgical inspection.
- `scripts/get-heading-content.py`: extracts the content of a specific heading by title.
- `scripts/get-reports.py`: lists reports and their finding counts as JSON.
- `scripts/get-findings-by-status.py`: extracts individual findings filtered by status, with file path and line number.
- `fixtures/report-template.md`: report schema (understanding finding structure and status values).
- `fixtures/lang-checklist.md`: language- and runtime-specific audit commands (useful for running tests during remediation).
