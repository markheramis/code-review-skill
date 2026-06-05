---
name: remediate-review
description: Apply fixes for Open findings in a review report. Use after any review skill to work through findings one-by-one, implement fixes, run tests, and update report statuses. Not for finding new issues — only for resolving existing ones.
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

Work one finding at a time. Do not start the next finding until the current one is committed.

1. Pick the highest-priority Open finding from the report's `## Findings Summary` table. Priority order: Critical → High → Medium → Low → Informational.
2. Update its Status to `In-Progress` in both `## Findings Summary` and the finding block. Write the modified report back to disk.
3. Analyze: read the finding's Evidence, Root Cause, and Recommendation. Confirm the issue still exists in the current codebase before fixing.
4. Research supporting context for this finding: search repository documentation first; if a RAG or context-retrieval system is available, query it for relevant project docs, architecture notes, requirements, runbooks, and prior decisions; when internet access is available, check official or primary external documentation for libraries, frameworks, APIs, protocols, advisories, and behavior needed to remediate accurately.
5. Plan the fix: identify the minimal change needed. Prefer targeted edits over rewrites. Use the research context to validate the intended behavior, API contracts, compatibility constraints, and security implications.
6. Implement the fix.
7. Write or update targeted tests covering the changed behavior. Tests must pass and achieve high coverage of the changed code paths.
8. Run the full test suite to verify no existing behavior is broken.
9. Update relevant documentation to reflect the change (inline docs, README, changelogs, API docs, architecture notes — whatever applies to the scope of the fix).
10. Commit the fix to an appropriately named branch: `{hotfix|bugfix|refactor|docs|chore}/{descriptive-branch-name}`. Write the commit message to describe what changed and why — do not reference the report file, report IDs, or internal review artifacts. The commit message must stand on its own for anyone reading the repository history.
11. Push the branch.
12. Update the finding's Status to `Completed` in both `## Findings Summary` and the finding block. Add a brief note under `#### Remediation Notes` with the branch name, commit hash, validation performed, and research sources used. Write the modified report back to disk.
13. Repeat from step 1 for the next Open finding.

**When tests are unavailable:** If the project has no test infrastructure, skip steps 7–8. Document the omission in `#### Remediation Notes`.

## Finding Rules

- Only fix findings that are `Open` or `In-Progress`. Do not touch `Completed`, `Accepted Risk`, or `Needs Verification`.
- Trust the original review's Evidence, Root Cause, and Recommendation. If the finding appears wrong (already fixed, not reproducible, misunderstood the code), do not silently skip — mark it `Needs Verification` with a note explaining why.
- Use supplementary research to remediate the current finding accurately. Do not broaden into a new audit or introduce unrelated fixes.
- After all Open findings are resolved, print a summary: total fixed, skipped, and any remaining.
- Do not introduce new findings. If you spot a new issue while fixing, note it in `#### Remediation Notes` for the current finding and suggest running a review skill again.

## Output Discipline

- Record exact commands, tools, repository documentation, RAG/context systems, external documentation, and cleanup status for each fix.
- Do not claim tests passed unless they were run in this remediation session.
- The report file is the source of truth — always write status updates back to it immediately.

## Resources

- `scripts/get-reports.py`: lists reports and their finding counts as JSON.
- `fixtures/report-template.md`: report schema (understanding finding structure and status values).
- `fixtures/lang-checklist.md`: language- and runtime-specific audit commands (useful for running tests during remediation).
