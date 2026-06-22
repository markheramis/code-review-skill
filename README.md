# Evidence-First Code Review

A single skill, `evidence-first-code-review`, that orchestrates an end-to-end code review: catalog the environment, baseline prior findings, scan risk domains, verify hypotheses, write a single-finding report, deep-confirm contested findings, create issues, and remediate Open findings — one bounded task at a time.

## What this is

A methodology-first replacement for the original flat `kilo-code-review` skill. The methodology is unchanged: every suspected issue is a hypothesis until current-code evidence, primary-source documentation, tool output, or a focused experiment confirms it. The structure changed: instead of six top-level skills that each carry their own copy of the same fixtures, this package ships **one** skill with the deep-dive details in a `references/` directory that the SKILL.md points at on demand.

## Why one skill instead of six

Hermes, Claude Code, Codex, Cursor, VS Code Copilot, Windsurf, Cline, Junie, Trae, Continue, and the generic Agents spec all load a skill by reading exactly one `SKILL.md`. A nested layout that keeps separate top-level skill folders (`repo-review/`, `pr-review/`, ...) is functionally just "more flat skills" — the harness still treats each folder as its own skill.

Putting the deep-dive docs in `references/` keeps navigation in a single place, makes the structure tree-readable in one glance, and lets the always-visible `SKILL.md` stay small enough to fit comfortably in any harness's context budget.

## Layout

```
evidence-first-code-review/
├── SKILL.md                    # Entry point — the only file harnesses load
├── README.md                   # This file
├── LICENSE                     # MIT
├── references/                 # 32 deep-dive docs, loaded on demand
│   ├── repo-review.md          # full repository audit
│   ├── pr-review.md            # pull request review
│   ├── commit-review.md        # single commit / patch review
│   ├── branch-review.md        # feature branch diff vs base
│   ├── remediate-review.md     # Open-finding burn-down orchestrator
│   ├── verify-report.md        # validate a completed report
│   ├── inventory.md            # provenance + toolchain + MCP tools
│   ├── baseline-map.md         # focus list + Prior Findings Index
│   ├── risk-scan.md            # one bounded domain per call
│   ├── finding-verification.md # per-hypothesis evidence + disproof
│   ├── experiment-summary.md   # runtime / correctness / security / perf
│   ├── staleness-check.md      # detect outdated findings
│   ├── warning-analysis.md     # classify compiler warnings
│   ├── deep-confirm.md         # deep confirmation orchestrator
│   ├── deep-confirm-classify.md
│   ├── deep-confirm-experiment.md
│   ├── deep-confirm-record.md
│   ├── report-queue.md         # deterministic Open queue
│   ├── report-triage.md        # categorize findings
│   ├── report-resolution.md    # sequential burn-down
│   ├── report-note-draft.md    # reviewer notes and comments
│   ├── report-finalize.md      # template compliance + status sync
│   ├── validation-summary.md   # summarize validation results
│   ├── create-issues.md        # tracker issues for unresolved findings
│   ├── remediate-finding.md    # remediate orchestrator
│   ├── remediate-verify.md
│   ├── remediate-experiment.md
│   ├── remediate-implement.md
│   ├── remediate-validate.md
│   ├── remediate-warn.md
│   ├── remediate-cleanup.md
│   └── remediate-packet.md
├── fixtures/                   # Templates and JSON schemas
│   ├── report-template.md      # single-finding template
│   ├── lang-checklist.md       # per-language audit commands
│   ├── scale-severity.json     # severity scale definition
│   ├── scale-confidence.json   # confidence scale definition
│   ├── status-findings.json    # finding status lifecycle
│   ├── status-issues.json      # issue status lifecycle
│   ├── status-deep-confirmation.json
│   └── workflow-manifest.json  # orchestrator stage metadata
├── scripts/                    # Python utilities (surgical readers)
│   ├── get-next-finding-id.py
│   ├── get-report-headings.py
│   ├── get-heading-content.py
│   ├── get-reports.py
│   └── get-findings-by-status.py
└── install/                    # multi-harness installer
    ├── install.sh / install.ps1        # main installer
    └── install-<harness>.{sh,ps1} × 11 harnesses
```

## Pipeline

```
inventory → baseline-map → risk-scan (parallel) → finding-verification →
experiment-summary → report writing
                                                  │
              ┌───────────────────────────────────┼──────────────────────┐
              ▼                                   ▼                      ▼
        deep-confirm                       create-issues          remediate
              │                                   │                      │
              └────────────► status update ◄──────┴────────── status update
```

## Install

### Auto-detect (every harness whose skills directory exists)

```bash
./install/install.sh
```

### Specific harness

```bash
./install/install.sh --harness hermes     # Hermes Agent
./install/install.sh --harness claude     # Claude Code
./install/install.sh --harness codex      # Codex
./install/install.sh --harness cursor     # Cursor
./install/install.sh --harness vscode     # VS Code Copilot
./install/install.sh --harness windsurf   # Windsurf
./install/install.sh --harness cline      # Cline
./install/install.sh --harness junie      # Junie
./install/install.sh --harness trae       # Trae
./install/install.sh --harness continue   # Continue
./install/install.sh --harness agents     # generic ~/.agents skills
```

### Custom path

```bash
./install/install.sh --target /path/to/skills
```

### Windows (PowerShell)

```powershell
.\install\install.ps1                                          # auto-detect
.\install\install-hermes.ps1                                   # Hermes
.\install\install-claude.ps1                                   # Claude
.\install\install-codex.ps1                                    # Codex
.\install\install.ps1 -Harness cursor                          # Cursor
.\install\install.ps1 -Target C:\path\to\skills                # custom
```

Per-harness `.sh` and `.ps1` wrappers exist for every harness.

## What gets installed

The installer copies one directory:

```
<skills-root>/evidence-first-code-review/
├── SKILL.md
├── references/  (32 docs)
├── fixtures/    (8 files)
└── scripts/     (5 Python utilities)
```

After install, load the skill in your harness:

- Hermes: `/skill evidence-first-code-review`
- Claude Code / Cursor / Codex / Windsurf / Copilot / Cline / Junie / Trae / Continue / Agents: invoke the skill by name; consult your harness's docs for the exact syntax.

## Quick start

```text
"Audit this repository for security and architecture issues, write findings to .ai/reports/"
"Review PR #123 before merge"
"Review commit abc123 for regressions"
"Review branch feature-x against main"
"Deep-confirm F-007 in the active report"
"Fix all Open findings in the latest review report"
```

The skill will:

1. Check memory for a project-specific report directory, or ask you where to save.
2. Load the entry-point reference for the chosen review type (`repo-review`, `pr-review`, `commit-review`, `branch-review`, `remediate-review`, or `verify-report`).
3. Run the pipeline stages described in the SKILL.md and the loaded reference.

## Configuration

| Variable | Default | Purpose |
|----------|---------|---------|
| `KILO_REPORT_DIRECTORY` | `.ai/reports/` | Where findings are saved |
| `KILO_CONFIG_ROOT` | `~/.config/kilo` | Original Kilo config root (kept for compatibility) |
| `KILO_REPORT_TEMPLATE` | `<KILO_CONFIG_ROOT>/fixtures/report-template.md` | Single-finding template |
| `KILO_TOOLS_PATH` | `<KILO_CONFIG_ROOT>/tools/` | Node-based Kilo tooling |
| `KILO_FINDINGS_STATUS` | `<KILO_CONFIG_ROOT>/fixtures/status-findings.json` | Status lifecycle |
| `KILO_DEEP_CONFIRMATION_STATUS` | `<KILO_CONFIG_ROOT>/fixtures/status-deep-confirmation.json` | Deep-confirm state |

When the `KILO_*` variables point at an installed Kilo config, the skill uses them. When they are absent, the skill falls back to the bundled `fixtures/` and `scripts/` directories.

## Evidence-first principles

1. **No proof, no finding.** Every confirmed finding needs evidence: a recorded experiment, a passing/failing test run, a primary-source citation, or a tool/compiler diagnostic. "Looks suspicious" → `Low`/`Needs Verification`; disproven hypotheses are excluded.
2. **Surgical reading.** Never load an entire report. Use the scripts in `scripts/` to read only the frontmatter or the specific heading you need.
3. **Single finding per file.** Every finding is its own `F-NNN-<slug>.md`; frontmatter is the single source of truth for metadata. Tags belong to reports, never to commit messages or change-request titles.
4. **Never invent.** No fabricated code behavior, tool output, dependency versions, or test results. No secrets, credentials, private source, or PII to external tools.
5. **Dedup against the Prior Findings Index.** Extend an existing Open/In-Progress/Needs-Verification finding rather than duplicate; re-raise Completed/Closed only with regression evidence.

## Migration from the old flat `kilo-code-review`

If you have the previous flat skill installed:

1. Re-run `./install/install.sh` — the new installer overwrites the old `evidence-first-code-review/` directory on top of any `kilo-code-review/` it finds (different name, no collision).
2. Manually remove the old `kilo-code-review/`, `repo-review/`, `pr-review/`, `commit-review/`, `branch-review/`, `remediate-review/`, and `verify-report/` directories from each harness's skills root:
   ```bash
   rm -rf ~/.hermes/skills/kilo-code-review \
          ~/.hermes/skills/repo-review \
          ~/.hermes/skills/pr-review \
          ~/.hermes/skills/commit-review \
          ~/.hermes/skills/branch-review \
          ~/.hermes/skills/remediate-review \
          ~/.hermes/skills/verify-report
   ```
3. Existing reports under `.ai/reports/` are unchanged and remain valid.

## Relationship to other skills

- **`requesting-code-review`** — fast pre-commit gate; this skill is the deeper review that follows when the gate flags something.
- **`plan`** — this skill validates that the implementation matches the plan.
- **`test-driven-development`** — verification stage checks that TDD discipline produced tests.
- **`systematic-debugging`** — hand off when a finding becomes a live investigation.
- **`github-code-review`** — hand off when findings become inline PR comments.
- **`document-writer`** — sibling package; uses the same install pattern and the same evidence-first verification discipline.

## Supported harnesses

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

## License

MIT — see `LICENSE`.