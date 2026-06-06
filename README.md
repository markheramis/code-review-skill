# code-review

A set of AI agent skills for structured code review, security auditing, project improvement discovery, and finding remediation. Installs into Claude Code, Codex, Cursor, VS Code Copilot, Windsurf, Cline, Continue, Hermes, Junie, Trae, and generic `.agents` skill roots.

## Skills

| Skill | Trigger | Use when |
|-------|---------|----------|
| `commit-review` | `/commit-review` | Reviewing a single commit or patch |
| `branch-review` | `/branch-review` | Reviewing a feature branch before merge |
| `pr-review` | `/pr-review` | Reviewing a pull request with CI and metadata |
| `repo-review` | `/repo-review` | Auditing an entire repository |
| `remediate-review` | `/remediate-review` | Fixing Open findings from a review report |

Each review skill produces a structured report with findings ordered by severity, confidence ratings, evidence, researched remediation analysis, how each fix helps, and a final recommendation (Approve / Approve with follow-ups / Request changes / Block release). Reviews look for security issues, optimization opportunities, complexity reduction, test coverage gaps, feature improvements, and other material improvements. The `remediate-review` skill reads an existing report and works through Open findings one at a time.

## Install

### Auto-detect (installs to existing harness skill directories)

```bash
./install/install.sh
```

### Specific harness

Specific harness installs only run when that harness's `skills` directory already exists. Use a custom path for an explicit new destination.

```bash
./install/install.sh --harness claude     # Claude Code
./install/install.sh --harness codex      # Codex
./install/install.sh --harness cursor     # Cursor
./install/install.sh --harness vscode     # VS Code Copilot
./install/install.sh --harness windsurf   # Windsurf
./install/install.sh --harness cline      # Cline
./install/install.sh --harness agents     # generic ~/.agents skills root
./install/install.sh --harness continue   # Continue
./install/install.sh --harness hermes     # Hermes
./install/install.sh --harness junie      # Junie
./install/install.sh --harness trae       # Trae
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
.\install\install-agents.ps1
.\install\install-continue.ps1
.\install\install-hermes.ps1
.\install\install-junie.ps1
.\install\install-trae.ps1
```

## Report format

Reports follow the template in [fixtures/report-template.md](fixtures/report-template.md) and the report output rules embedded in each review skill:

- **Executive Summary** — overall risk level and key conclusions
- **Findings** — each with severity, confidence, evidence, impact, root cause, remediation analysis, recommendation, how it helps, and suggested tests
- **Security Review** — trust boundaries, sensitive assets, auth/authz/input/output/secrets/logging/deps
- **Test Coverage Review** — coverage tooling checked, coverage result or absence explanation, existing gaps, and recommended tests
- **Architecture / Maintainability Review** — coupling, error handling, performance considerations
- **Final Recommendation** — Approve / Approve with follow-ups / Request changes / Block release

## Remediation

Use `remediate-review` to fix Open findings from a report:

1. Run `python scripts/get-reports.py <report_dir>` to list reports with finding counts
2. Invoke `/remediate-review` — it picks the report with Open findings and works through them one at a time
3. Each fix is committed to a descriptive branch, pushed, and then asks whether to create a pull request before moving to the next finding

### Severity scale

| Level | Meaning |
|-------|---------|
| Critical | Likely exploitable or production-breaking; requires immediate remediation |
| High | Significant bug or vulnerability likely to affect production |
| Medium | Real issue with limited scope or moderate risk |
| Low | Minor correctness, maintainability, feature, or test coverage issue |
| Informational | Observation or improvement opportunity that does not require immediate action |

## Supported languages

[fixtures/lang-checklist.md](fixtures/lang-checklist.md) lists the audit commands run during review for each language:

Rust · JavaScript/TypeScript · Python · Go · Java · C#/.NET · C/C++ · Ruby · PHP
