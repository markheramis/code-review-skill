---
name: evidence-first-code-review
description: "Evidence-first code review for repos, PRs, commits, branches, and reports. Use when the user asks to audit a codebase, review a pull request, deep-confirm a finding, or remediate findings from a prior review. Triggers on 'code review', 'security audit', 'review PR', 'audit repo', 'review commit', 'review branch', 'verify findings', 'remediate findings'. Produces single-finding markdown reports with hypothesis-grade evidence. Not for trivial style-only edits, pre-commit hooks, or non-evidence-driven quick lint passes."
version: 1.0.0
author: Mark Heramis
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [code-review, security, audit, remediation, evidence-first, nested-references]
    related_skills: [requesting-code-review, plan, test-driven-development, systematic-debugging, github-code-review]
    nested_structure: true
    reference_categories:
      - orchestration
      - workflow
      - reporting
      - remediation
---

# Evidence-First Code Review

A single skill that orchestrates an end-to-end evidence-first review: catalog the environment, baseline prior findings, scan risk domains, verify hypotheses, write a single-finding report, deep-confirm contested findings, create issues, and remediate Open findings — one bounded task at a time.

**Core principle.** Every suspected issue is a hypothesis until confirmed by current-code evidence, primary-source documentation, tool output, or a focused experiment. "Looks suspicious" is a `Low` confidence `Needs Verification` note, never a finding. Prefer fewer stronger findings over many weak ones.

**Why one skill, not six.** Harnesses (Hermes, Claude Code, Codex, Cursor, VS Code Copilot, Windsurf, Cline, Junie, Trae, Continue, generic Agents) load a skill by reading exactly one `SKILL.md`. The 32 deep-dive docs live in `references/` and are loaded only when this SKILL.md points at them. That keeps navigation in one place while the detail stays out of the always-visible context.

## When to Use

- "Audit this repository for security issues"
- "Review pull request #123 before merge"
- "Review commit abc123 for correctness"
- "Review branch feature-x against main"
- "Verify the Open findings in the latest report"
- "Remediate the Open findings from `reports/`"
- "Deep-confirm F-007 in the active report"
- "Create tracker issues for unresolved findings"

**Skip for:** pure style-only changes, single-file typo fixes, or when the user explicitly says "skip verification". For pre-commit hooks, use `requesting-code-review` instead — it is the lighter gate.

## Pipeline Overview

```
                     ┌─ repo-review ──┐
                     │                │
[trigger] ──────────► 1. inventory   ─┤
                     2. baseline-map  │
                     3. risk-scan     │ (one finding per
                     4. verification  │  file, evidence-first)
                     5. report        ─┘
                              │
              ┌───────────────┼───────────────┐
              ▼               ▼               ▼
        6. deep-confirm  7. create-issues  8. remediate
              │               │               │
              └──► update ────┴──► update ────┴──► commit
```

| Stage | What it does | Reference |
|-------|--------------|-----------|
| 1. inventory | Catalog provenance, toolchain, MCP tools, report surface | `references/inventory.md` |
| 2. baseline-map | Focus list + Prior Findings Index + external dep pass | `references/baseline-map.md` |
| 3. risk-scan (parallel) | One bounded domain per invocation, returns hypotheses | `references/risk-scan.md` |
| 4. finding-verification | Per-hypothesis evidence validation, disproof attempts | `references/finding-verification.md` |
| 5. experiment-summary | Runtime/correctness/security/perf experiments | `references/experiment-summary.md` |
| 6. deep-confirm | Disprove or strengthen Medium+ contested findings | `references/deep-confirm.md` |
| 7. create-issues | Tracker issues for unresolved findings | `references/create-issues.md` |
| 8. remediate | Sequential burn-down of Open findings | `references/remediate-review.md` |

Branch / commit / PR review share the same five-stage spine; only the diff source changes. Load `references/repo-review.md`, `references/branch-review.md`, `references/commit-review.md`, or `references/pr-review.md` for the entry-point rules of each variant.

## Quick Start

```bash
# Repository audit
"Audit this repo for security and correctness, write findings to .ai/reports/"

# Pull request review
"Review PR #123 for security and architecture issues"

# Commit review
"Review commit abc123 for regressions"

# Branch review
"Review branch feature-x against main for correctness"

# Deep-confirm a finding
"Deep-confirm F-007 in the active report"

# Remediate Open findings
"Fix Open findings in the latest report"
```

On every invocation, do this first:

1. Check memory for a saved report directory path for the current project (`code-review.report_dir`). Treat it as project-specific; do not reuse a path saved for another project.
2. If not found, ask: *"Where should I save the review report? (Leave blank to print output only.)"*
3. Resolve `KILO_REPORT_DIRECTORY` from env or default (`.ai/reports/`).
4. Read `references/<entry-point>.md` for the chosen review type before doing any work.

## Evidence-First Rules

These rules apply to every stage. They are non-negotiable.

1. **No proof, no finding.** Every confirmed finding needs a recorded experiment, a passing/failing test run, a primary-source citation, or a tool/compiler diagnostic. "Looks suspicious" → `Low`/`Needs Verification`; exclude disproven hypotheses.
2. **Surgical reading.** Never load an entire report. Use the scripts in `scripts/` (`get-report-headings.py`, `get-heading-content.py`, `get-findings-by-status.py`) to read only what is needed. Read each finding file's frontmatter (`id`/`title`/`category`/`status`) — never the body — for indexing.
3. **Single finding per file.** Every finding gets its own markdown file: `F-NNN-<slug>.md` (zero-padded `NNN`, lower-kebab-case `<slug>` from the title, ≤40 chars). The frontmatter is the single source of truth for metadata — never duplicate metadata in the body as `**Severity:**` lines.
4. **Frontmatter is canonical.** `id`, `severity`, `confidence`, `category`, `status`, `deep_confirmed`, `issue`, `depends_on`, `affected_paths`, `tags` all live in YAML frontmatter only. Tags belong to reports, never to commit messages or change-request titles.
5. **Never invent.** Never fabricate code behavior, tool output, config values, dependency versions, or test results. Never send secrets, credentials, private source, or PII to external tools.
6. **Never delegate the dangerous edges.** Do not delegate final inclusion decisions, branch/destructive git, or parallel heavy validations to subagents. Read-back after every mutation.

## Review Lenses

Every review — regardless of scope — looks for evidenced opportunities in:

- **Security** — trust boundaries, input validation, authn/authz, deserialization, secrets, dependency risk.
- **Correctness** — edge cases, error propagation, race conditions, off-by-one, contract violations.
- **Performance** — avoidable allocation, contention, repeated work, hot-path I/O.
- **Maintainability** — complexity reduction, clearer boundaries, duplication, abstraction safety.
- **Test coverage** — unit, integration, regression, security, error-path, performance coverage gaps.
- **Project improvement** — features, observability, developer experience, operational concerns that would materially help.

For full-repo reviews, surface project-wide opportunities when evidence shows they would materially reduce risk, cost, complexity, or friction. For PR/commit/branch reviews, keep the lens on the diff.

## Severity Scale

| Level | Meaning |
|-------|---------|
| **Critical** | Exploitable or production-breaking; requires immediate remediation |
| **High** | Significant bug/vulnerability likely to affect production |
| **Medium** | Real issue with limited scope or moderate risk |
| **Low** | Minor correctness, maintainability, feature, or test coverage issue |
| **Informational** | Observation or improvement opportunity not requiring immediate action |

Full definitions and thresholds: `fixtures/scale-severity.json`.

## Confidence Scale

| Level | Meaning |
|-------|---------|
| **High** | Direct code/test/log/repro evidence |
| **Medium** | Strong but incomplete evidence |
| **Low** | Plausible concern needing more data |

Full definitions: `fixtures/scale-confidence.json`.

## Finding Status Lifecycle

```
Open → In-Progress → Completed → Closed
         ↓                    ↓
      Needs Verification → Accepted Risk
```

New findings start `status: Open`, `deep_confirmed: No`, `issue: "—"` — exactly. Later stages gate on these exact values. Full state machine and transition rules: `fixtures/status-findings.json`.

## Dedup Discipline

Before adding a finding, scan the whole report directory (frontmatter only, never bodies):

- **Open / In-Progress / Needs Verification:** extend the existing finding rather than duplicate.
- **Completed / Closed:** re-raise only with regression evidence.
- **Accepted Risk:** re-raise only when the finding has materially changed.

Use `scripts/get-reports.py` to list reports, then `scripts/get-findings-by-status.py --status Open` to inspect the active queue.

## Report Output

When writing a finding:

1. Copy `fixtures/report-template.md` to `<report-dir>/F-NNN-<slug>.md`.
2. Fill every `{placeholder}`; keep headers in order.
3. Set `tags` to the project/package name first, `CodeReview` second, plus 3–6 topic tags.
4. Finding IDs are zero-padded `F-NNN`, identical in frontmatter `id` and `# {Title}` header, globally unique in the directory. `scripts/get-next-finding-id.py` is a seed only — full directory scan is canonical.
5. Report the path, finding count, highest severity, and limitations. Delete or promote every `tmp_review_repro_<slug>.<ext>` file you created.

## Configuration

| Variable | Default | Purpose |
|----------|---------|---------|
| `KILO_REPORT_DIRECTORY` | `.ai/reports/` | Where findings are saved |
| `KILO_CONFIG_ROOT` | `~/.config/kilo` | Original Kilo config root (kept for compatibility) |
| `KILO_REPORT_TEMPLATE` | `<KILO_CONFIG_ROOT>/fixtures/report-template.md` | Single-finding template |
| `KILO_TOOLS_PATH` | `<KILO_CONFIG_ROOT>/tools/` | Node-based Kilo tooling |
| `KILO_FINDINGS_STATUS` | `<KILO_CONFIG_ROOT>/fixtures/status-findings.json` | Status lifecycle |
| `KILO_DEEP_CONFIRMATION_STATUS` | `<KILO_CONFIG_ROOT>/fixtures/status-deep-confirmation.json` | Deep-confirm state |

`KILO_*` variables are honored for users who have Kilo installed. When absent, the skill falls back to the bundled `fixtures/` and `scripts/` directories and saves reports under the project-local `.ai/reports/` (or wherever the user specifies).

## Reference Catalog

Load only the references you need, when you need them. The list is grouped by review phase.

### Entry-point reviews (pick one per invocation)

- `references/repo-review.md` — full repository audit (no diff)
- `references/pr-review.md` — pull request review with CI and metadata
- `references/commit-review.md` — single commit or patch review
- `references/branch-review.md` — feature branch diff against base
- `references/remediate-review.md` — orchestrate Open-finding burn-down
- `references/verify-report.md` — validate a completed report

### Pipeline stages (sequential within a review)

- `references/inventory.md` — provenance, toolchain, MCP tools, report surface
- `references/baseline-map.md` — focus list + Prior Findings Index + dep-advisory pass
- `references/risk-scan.md` — one bounded domain per call (error-handling, security-boundary, concurrency, performance, dependency, test-coverage-gap)
- `references/finding-verification.md` — per-hypothesis evidence + disproof
- `references/experiment-summary.md` — runtime/correctness/security/perf experiments
- `references/staleness-check.md` — detect outdated findings against current code
- `references/warning-analysis.md` — classify compiler/static-analysis warnings

### Deep confirmation (Medium+ contested findings)

- `references/deep-confirm.md` — orchestrator
- `references/deep-confirm-classify.md` — classify for confirmation
- `references/deep-confirm-experiment.md` — per-claim experiments
- `references/deep-confirm-record.md` — record confirmation results

### Reporting lifecycle

- `references/report-queue.md` — deterministic Open queue
- `references/report-triage.md` — categorize findings
- `references/report-resolution.md` — sequential burn-down
- `references/report-note-draft.md` — reviewer notes and comments
- `references/report-finalize.md` — template compliance + status sync
- `references/validation-summary.md` — summarize validation results
- `references/create-issues.md` — tracker issues for unresolved findings

### Remediation (Open findings, one at a time)

- `references/remediate-finding.md` — orchestrator
- `references/remediate-verify.md` — re-verify the finding still applies
- `references/remediate-experiment.md` — validate the fix approach
- `references/remediate-implement.md` — apply the fix
- `references/remediate-validate.md` — confirm no regressions
- `references/remediate-warn.md` — fix introduced warnings
- `references/remediate-cleanup.md` — cleanup + documentation
- `references/remediate-packet.md` — assemble remediation packet

## Common Workflows

### Repository audit

```
inventory → baseline-map → risk-scan (parallel) → finding-verification →
experiment-summary → report writing
```

### PR review

```
Fetch PR metadata → calibrate depth → run tools → inspect changes →
verify findings → write report
```

### Commit review

```
Get commit diff → inspect changed files → validate findings → write report
```

### Branch review

```
Get branch diff → calibrate depth → run tools → inspect changes →
verify findings → write report
```

### Remediate

```
Pick Open finding → verify still applies → validate fix approach →
implement → validate no regressions → cleanup → commit
```

### Deep-confirm

```
Classify → verify → experiment → record
```

## Integration Points

- **`requesting-code-review`** — run after each task as a fast pre-commit gate; this skill is the deeper review that follows.
- **`plan`** — this skill validates that implementation matches the plan.
- **`test-driven-development`** — verification stage checks that TDD discipline produced tests.
- **`systematic-debugging`** — when a finding becomes a live investigation, hand off to this skill.
- **`github-code-review`** — when findings become inline PR comments, hand off to this skill.

## Supported Harnesses

The skill installs as a single `SKILL.md` into any harness's personal skills directory. Verified paths:

| Harness | Skills path |
|---------|-------------|
| Hermes Agent | `~/.hermes/skills/` |
| Claude Code | `~/.claude/skills/` |
| Codex | `~/.codex/skills/` |
| Cursor | `~/.cursor/skills/` |
| VS Code Copilot | `~/.copilot/skills/` |
| Windsurf | `~/.windsurf/skills/` |
| Cline | `~/.cline/skills/` |
| Junie | `~/.junie/skills/` |
| Trae | `~/.trae/skills/` |
| Continue | `~/.continue/skills/` |
| Generic Agents | `~/.agents/skills/` |

Run `./install/install.sh` (auto-detect), `--harness <name>` for one harness, or `--target <path>` for a custom location. On Windows use the matching `.ps1` scripts.

## Common Pitfalls

- **Empty diff** — check `git status`; tell the user nothing to review.
- **Not a git repo** — for repo/branch/commit reviews, tell the user; PR review still works for remote refs.
- **Loading full reports** — use the `scripts/` surgical readers; never `cat` an entire report.
- **Parallel heavy validations** — risk-scan and verification are parallel-safe; never parallelize fix-and-verify or skip/confirm decisions.
- **Tags leaking into commits** — `tags` are report-only metadata. They must never appear in commit messages or change-request titles.
- **Inventing tool output** — never claim a tool passed unless it actually ran and you saw the exit status.
- **Subagent without isolation** — subagents must receive only the diff/scan output as data; never share your full context.
- **Skipping the report-dir question** — always ask or check memory first; never silently default to a directory that may belong to another project.
- **Stale scripts** — `scripts/get-next-finding-id.py` is a seed, not canonical. Always do a full directory scan before assigning a new `F-NNN`.

## Verification Checklist

Before declaring a review complete:

- [ ] Every finding has frontmatter with `id`, `title`, `severity`, `confidence`, `category`, `status`, `deep_confirmed`, `issue`, `affected_paths`.
- [ ] Every Medium+ finding has either a recorded experiment, a passing/failing test run, a primary-source citation, or a tool/compiler diagnostic.
- [ ] Prior Findings Index was scanned for dedup; no duplicates added.
- [ ] Tags list starts with the project name and `CodeReview`; no tags in commit messages.
- [ ] All `tmp_review_repro_<slug>.<ext>` files deleted or promoted.
- [ ] Report path, finding count, highest severity, and limitations recorded in the final summary.
- [ ] Report directory recorded to memory (`code-review.report_dir`) when applicable.

## License

MIT — see `LICENSE`.