# code-review

A set of AI agent skills for structured code review and security auditing. Installs into Claude Code, Codex, Cursor, Windsurf, and Cline.

## Skills

| Skill | Trigger | Use when |
|-------|---------|----------|
| `commit-review` | `/commit-review` | Reviewing a single commit or patch |
| `branch-review` | `/branch-review` | Reviewing a feature branch before merge |
| `pr-review` | `/pr-review` | Reviewing a pull request with CI and metadata |
| `repo-review` | `/repo-review` | Auditing an entire repository |

Each skill produces a structured report with findings ordered by severity, confidence ratings, evidence, and a final recommendation (Approve / Approve with follow-ups / Request changes / Block release).

## Install

### Auto-detect (installs to all harnesses found on this machine)

```bash
./scripts/install.sh
```

### Specific harness

```bash
./scripts/install.sh --harness claude     # Claude Code
./scripts/install.sh --harness codex      # Codex
./scripts/install.sh --harness cursor     # Cursor
./scripts/install.sh --harness windsurf   # Windsurf
./scripts/install.sh --harness cline      # Cline
```

### Custom path

```bash
./scripts/install.sh --target /path/to/skills
```

### Windows (PowerShell)

```powershell
.\scripts\install-claude.ps1
.\scripts\install-codex.ps1
.\scripts\install-cursor.ps1
.\scripts\install-windsurf.ps1
.\scripts\install-cline.ps1
```

## Report format

Reports follow the template in [fixtures/report-template.md](fixtures/report-template.md):

- **Executive Summary** — overall risk level and key conclusions
- **Findings** — each with severity, confidence, evidence, impact, root cause, recommendation, and suggested tests
- **Security Review** — trust boundaries, sensitive assets, auth/authz/input/output/secrets/logging/deps
- **Test Coverage Review** — existing coverage gaps and recommended tests
- **Architecture Review** — coupling, error handling, performance considerations
- **Remediation Plan** — prioritized action table
- **Final Recommendation** — Approve / Approve with follow-ups / Request changes / Block release

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
commit-review/SKILL.md     skill definition for single-commit review
branch-review/SKILL.md     skill definition for branch diff review
pr-review/SKILL.md         skill definition for pull request review
repo-review/SKILL.md       skill definition for full repository audit
fixtures/
  report-template.md       output template used by all four skills
  lang-checklist.md        per-language audit commands
scripts/
  install.sh               bash installer (Linux/macOS)
  install-claude.ps1       PowerShell installers per harness
  install-codex.ps1
  install-cursor.ps1
  install-windsurf.ps1
  install-cline.ps1
```
