---
name: verify-report
description: Verify findings marked "Needs Verification" in a review report. Checks each finding against the current codebase, conducts research, determines if the issue is real and actionable, and either resolves it or escalates to the user. Use after any review skill when findings require confirmation before remediation. Not for finding new issues — only for verifying or disproving existing ones.
---

# Verify Report

## Purpose

Verify findings marked `Needs Verification` in a code review report. For each finding: read the full evidence, assess whether the agent can autonomously confirm or disprove it, research the claim, and either close it or escalate to the user with specific questions. Only works on findings already produced by a review skill (`commit-review`, `branch-review`, `pr-review`, `repo-review`).

Verification is distinct from remediation. Verification answers *"is this finding real?"* Remediation answers *"let's fix it."* A finding must be verified before it can be remediated.

## Report Discovery

1. Check memory for a saved report directory path (`code-review.report_dir`). If not found, ask: *"Where are the review reports stored?"*
2. Run `python scripts/get-reports.py <report_dir>` to list all reports with finding counts.
3. Pick the best candidate:
   - Prefer reports with `needs-verification > 0`.
   - When multiple qualify, prefer the most recent (by filename timestamp).
   - If exactly one has `needs-verification` findings, select it.
4. If no reports have Needs Verification findings, report that and exit.

## Workflow

Work one finding at a time. Do not start the next finding until the current one is assessed and its status updated.

1. Run `python scripts/get-findings-by-status.py <report_dir> needs-verification` to list all Needs Verification findings across reports. Filter to the selected report if more than one.
2. Pick the highest-priority finding. Priority order: Critical → High → Medium → Low → Informational.
3. Read the full finding block surgically: use `python scripts/get-heading-content.py <report> --title "<finding_id>" --type h3` to extract the finding block directly. Capture: Summary, Evidence, Impact, Root Cause, Remediation Analysis, Recommendation, and any Remediation Notes.
4. **Autonomy Assessment** — Before any research, evaluate whether the agent has the access and visibility needed to verify this finding:
   - Can the agent read every file referenced in the Evidence section?
   - Are the referenced symbols, code paths, and dependencies available in the workspace?
   - Does verification require access to external systems (deployed servers, databases, CI pipelines, third-party services, private repositories) that the agent cannot reach?
   - Does verification depend on runtime behavior, network conditions, user sessions, or production data the agent cannot reproduce?
   - Is the claim about a codebase, language, framework, or platform the agent can reason about with available tooling?
   - Does the finding involve hardware, physical equipment, or closed-source firmware?
   - Is the finding about a dependency version, CVE, or advisory that requires checking an external registry or database?

   **If any access gap exists**, do NOT guess. Instead:
   - Summarize what the agent *can* confirm with available tooling.
   - Identify the specific gap: what system, credential, environment, or permission is needed.
   - Formulate clear, specific questions for the user — not open-ended "can you check X?" but targeted queries the user can answer definitively. Example: *"Does the `LEGACY_API_KEY` environment variable exist on the staging server at `10.x.x.x`? If so, is it set to a non-empty value?"*
   - Ask the user via `vscode_askQuestions`. Wait for answers before continuing.

5. **Research** — When the agent has sufficient access:
   - Read all files referenced in the Evidence section.
   - Use LSP (go-to-definition, find-references, hover) to trace symbols and understand call sites.
   - Search the repository for related code, configuration, tests, and documentation.
   - If a RAG or context-retrieval system is available, query it for relevant project docs, architecture notes, requirements, and prior decisions.
   - When internet access is available, check official documentation for libraries, frameworks, APIs, CVEs, advisories, and language specifications referenced in the finding.
   - If the finding claims a runtime behavior (crash, panic, incorrect output, performance degradation), attempt the smallest safe reproduction: an existing focused test, a temporary test case, a throwaway script, or a REPL snippet that exercises the real code path. Isolate temporary artifacts and clean them up after.

6. **Determination** — Based on the evidence gathered, classify the finding as one of:
   - **Confirmed**: the issue is real and matches the reported severity and impact. Update status to `Open` (ready for remediation).
   - **Disproved**: the issue does not exist, was already fixed, or was based on a misunderstanding. Update status to `Completed` with an explanation in Remediation Notes.
   - **Accepted Risk**: the issue is real but the project has intentionally accepted it (e.g., documented trade-off, wont-fix decision, architectural constraint). Update status to `Accepted Risk` with the rationale in Remediation Notes.
   - **Insufficient Access**: the agent cannot verify without user help. Leave status as `Needs Verification` and record the specific question asked and answer received (or that the question is pending).

7. **Update the report** — Write the modified report back to disk:
   - Update the finding's Status in both the `## Findings Summary` table and the `**Status:**` line in the finding block.
   - Add or update `#### Remediation Notes` with: the determination, evidence gathered, tools and sources used, reproduction results (or reason not attempted), user answers received, and the concrete reason for the status change.
   - Record exact commands, tools, repository documentation, RAG/context systems, external documentation, temporary artifacts and their cleanup status.

8. Repeat from step 2 for the next Needs Verification finding.

## Finding Rules

- Only verify findings that are `Needs Verification`. Do not touch `Open`, `In-Progress`, `Completed`, or `Accepted Risk`.
- The report file is the source of truth — always write status updates back to it immediately.
- Do not fix anything. Verification is read-only assessment. If a finding is confirmed, change status to `Open` and let `remediate-review` handle the fix.
- Do not broaden into a new audit. If you discover an unrelated issue while verifying, note it in `#### Remediation Notes` and suggest running a review skill again.
- Temporary repro files are validation artifacts. Keep them isolated, delete them after use unless promoted into committed tests, and record cleanup status.
- When the agent lacks access: ask don't guess. A wrong determination is worse than an unresolved finding.
- Trust the original review's Evidence but verify it against the current codebase. Code changes between review and verification.
- After all Needs Verification findings are processed, print a summary: total verified (confirmed + disproved + accepted-risk), escalated to user, and remaining.

## Autonomy Boundaries

The agent MUST escalate to the user when verification requires any of:

- Access to deployed environments (production, staging, QA, dev servers)
- Credentials, API keys, tokens, or secrets
- Database access beyond what's in the workspace
- External services (payment processors, email providers, cloud consoles)
- Private/internal repositories not in the workspace
- Hardware, firmware, or physical devices
- Network access to internal-only endpoints
- User sessions, browser state, or client-side-only behavior
- Production data, logs, or metrics not available locally
- Third-party account access (CI/CD, monitoring, feature flags, package registries)

The agent CAN autonomously verify findings that only require:

- Reading source code, configuration files, and tests in the workspace
- Running local builds, tests, linters, type checkers, and static analysis
- Searching public documentation, registries, and advisories
- Using LSP for code navigation and symbol analysis
- Executing safe local scripts or REPL sessions
- Checking dependency manifests, lock files, and version constraints

## Output Discipline

- Record exact commands, tools, repository documentation, RAG/context systems, external documentation, and cleanup status for each finding.
- Do not claim a reproduction was successful unless the command was actually run in this session.
- When escalating to the user, be specific: what exactly to check, where, and what to look for.
- The report file is the source of truth — always write status updates back to it immediately.

## Resources

- `scripts/get-report-headings.py`: returns all Markdown heading line ranges for surgical inspection.
- `scripts/get-heading-content.py`: extracts the content of a specific heading by title.
- `scripts/get-reports.py`: lists reports and their finding counts as JSON.
- `scripts/get-findings-by-status.py`: extracts individual findings filtered by status, with file path and line number for surgical inspection.
- `fixtures/report-template.md`: report schema (understanding finding structure, metadata fields, and status values).
- `fixtures/lang-checklist.md`: language- and runtime-specific audit commands (useful for running tests and static analysis during verification).
