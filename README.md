# code-review

A set of AI agent skills for structured code review, security auditing, and finding remediation. Installs into Claude Code, Codex, Cursor, VS Code Copilot, Windsurf, and Cline.

## Skills

| Skill | Trigger | Use when |
|-------|---------|----------|
| `commit-review` | `/commit-review` | Reviewing a single commit or patch |
| `branch-review` | `/branch-review` | Reviewing a feature branch before merge |
| `pr-review` | `/pr-review` | Reviewing a pull request with CI and metadata |
| `repo-review` | `/repo-review` | Auditing an entire repository |
| `remediate-review` | `/remediate-review` | Fixing Open findings from a review report |

Each review skill produces a structured report with findings ordered by severity, confidence ratings, evidence, and a final recommendation (Approve / Approve with follow-ups / Request changes / Block release). The `remediate-review` skill reads an existing report and works through Open findings one at a time.

## Install

### Auto-detect (installs to all harnesses found on this machine)

```bash
./install/install.sh
```

### Specific harness

```bash
./install/install.sh --harness claude     # Claude Code
./install/install.sh --harness codex      # Codex
./install/install.sh --harness cursor     # Cursor
./install/install.sh --harness vscode     # VS Code Copilot
./install/install.sh --harness windsurf   # Windsurf
./install/install.sh --harness cline      # Cline
```

### Custom path

```bash
./install/install.sh --target /path/to/skills
```

### Windows (PowerShell)

```powershell
.\install\install-claude.ps1
.\install\install-codex.ps1
.\install\install-cursor.ps1
.\install\install-vscode.ps1
.\install\install-windsurf.ps1
.\install\install-cline.ps1
```

## Report format

Reports follow the template in [fixtures/report-template.md](fixtures/report-template.md) and output rules in [fixtures/output-rules.md](fixtures/output-rules.md):

- **Executive Summary** — overall risk level and key conclusions
- **Findings** — each with severity, confidence, evidence, impact, root cause, recommendation, and suggested tests
- **Security Review** — trust boundaries, sensitive assets, auth/authz/input/output/secrets/logging/deps
- **Test Coverage Review** — existing coverage gaps and recommended tests
- **Architecture / Maintainability Review** — coupling, error handling, performance considerations
- **Final Recommendation** — Approve / Approve with follow-ups / Request changes / Block release

## Remediation

Use `remediate-review` to fix Open findings from a report:

1. Run `python scripts/get-reports.py <report_dir>` to list reports with finding counts
2. Invoke `/remediate-review` — it picks the report with Open findings and works through them one at a time
3. Each fix is committed to a descriptive branch and the report status is updated in-place

### Severity scale

| Level | Meaning |
|-------|---------|
| Critical | Likely exploitable or production-breaking; requires immediate remediation |
| High | Significant bug or vulnerability likely to affect production |
| Medium | Real issue with limited scope or moderate risk |
| Low | Minor correctness, maintainability, or test coverage issue |
| Informational | Observation that does not require immediate action |

## Supported languages

[fixtures/lang-checklist.md](fixtures/lang-checklist.md) lists the audit commands run during review for each language:

Rust · JavaScript/TypeScript · Python · Go · Java · C#/.NET · C/C++ · Ruby · PHP

## Project structure

```
commit-review/SKILL.md      skill definition for single-commit review
branch-review/SKILL.md      skill definition for branch diff review
pr-review/SKILL.md          skill definition for pull request review
repo-review/SKILL.md        skill definition for full repository audit
remediate-review/SKILL.md   skill definition for finding remediation
fixtures/
  report-template.md        output template used by all review skills
  output-rules.md           report production rules (applied, not included in output)
  lang-checklist.md         per-language audit commands
scripts/
  get-reports.py            list reports and their finding counts as JSON
install/
  install.sh                bash installer (Linux/macOS)
  install.ps1               PowerShell installer
  install-claude.ps1        per-harness wrappers
  install-codex.ps1
  install-cursor.ps1
  install-vscode.ps1
  install-windsurf.ps1
  install-cline.ps1
  install-claude.sh
  install-codex.sh
  install-cursor.sh
  install-vscode.sh
  install-windsurf.sh
  install-cline.sh
```
