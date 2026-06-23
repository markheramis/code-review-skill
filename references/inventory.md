---
name: inventory
description: "Catalog the review's provenance, toolchain, connected MCP tools, and report surface before processing"
version: 1.0.0
author: Mark Heramis
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [baseline, code-review, evidence-first, workflow]
    related_skills: [evidence-first-code-review]
---

# Code Review Inventory

Catalog the full environment and inputs available to the code review workflow: report provenance, project toolchain, connected repository-host and CI MCP tools, and the report's finding surface.

## Purpose

This inventory gates whether the review can proceed by ensuring all critical inputs are available and accessible.

## Inputs

- Report directory under the configured report path (defaults to `.ai/reports/`) — see "Kilo backend compatibility" at the end of this file
- Current working directory and git remote configuration
- Connected MCP tool list (from the session's available tools)
- `package.json` or equivalent project manifest

## Tools

- `scripts/get-reports.py` — list reports with finding status counts
- `scripts/get-findings-by-status.py` — filter findings by status across the directory
- `scripts/get-next-finding-id.py` — get the next available `F-NNN` finding ID

## Output Schema

```json
{
  "report_dir": ".ai/reports/",
  "finding_files": ["F-001-buffer-overflow.md", "F-007-sql-injection.md"],
  "finding_count": 18,
  "by_severity": {
    "Critical": 2,
    "High": 5,
    "Medium": 8,
    "Low": 2,
    "Informational": 1
  },
  "by_status": {
    "Open": 10,
    "In-Progress": 3,
    "Resolved": 5
  },
  "repository": {
    "remote": "origin",
    "default_branch": "main",
    "host_detected": "gitlab",
    "host_mcp_available": true
  },
  "toolchain": {
    "runtime": "node",
    "package_manager": "npm",
    "test_runner": "vitest",
    "linter": "eslint",
    "type_checker": "typescript",
    "build_command": "npm run build"
  },
  "mcp_tools": {
    "git": true,
    "repository_host": {
      "available": true,
      "tool_name": "gitlab_mcp"
    },
    "ci": {
      "available": false,
      "reason": "no CI MCP tool connected"
    }
  },
  "readiness": "ready"
}
```

## Workflow

1. **Scan report directory**
   - Look for finding files matching `F-NNN-*.md` pattern
   - Parse frontmatter from each file (id, severity, status)
   - Count findings by severity and status
   - If directory missing/unreadable: `readiness: "report_missing"`
   - If no finding files: `readiness: "degraded"`

2. **Detect repository host**
   - Run `git remote get-url origin`
   - Match against patterns: `gitlab`, `github`, `bitbucket`, `gitea`, `gogs`
   - Output lowercase `host_detected` (never provider brand names)

3. **Map MCP tools**
   - Scan for git tools (prefix `git_` or namespace `git-mcp-server`)
   - Check for repository host tools by namespace matching
   - Check for CI tools
   - Set boolean availability flags

4. **Detect toolchain**
   - Parse `package.json` or equivalent
   - Detect test runner from `scripts.test` and devDependencies
   - Detect linter from `scripts.lint` and devDependencies
   - Detect TypeScript from `devDependencies.typescript` or `tsconfig.json`
   - Extract build command from `scripts.build`

5. **Determine readiness**
   - `ready` - All critical inputs available
   - `degraded` - Host MCP or CI unavailable but report dir and repo accessible
   - `blocked` - Report dir missing, repo not found, or no git remote

## Rules

- **Read-only operation** - Never modify files, create branches, or make network calls beyond local reads
- **Use the bundled scripts** - the `scripts/` Python utilities are the canonical implementation; invoke them directly rather than shelling out to external toolchains
- **Degraded doesn't block** - Main agent decides whether to proceed with degraded readiness
- **Blocked stops processing** - Workflow cannot continue without critical inputs
- **Resolve paths absolutely** - use `$REVIEW_REPORT_DIR` when set, otherwise `.ai/reports/` relative to the working directory; never silently fall back to another project's path

## Integration

This skill is typically called as the first step in:
- `repo-review` - Before beginning repository audit
- `pr-review` - Before fetching PR metadata
- `branch-review` - Before computing diff
- `remediate-review` - Before picking findings to fix

## Dependencies

- Requires a git repository with remote configured
- Requires Python 3.8+ to run the bundled `scripts/` utilities
- Does NOT require Node.js, Kilo, or any `KILO_*` environment variable to be set

## Kilo backend compatibility

This reference uses the bundled `scripts/` Python utilities and `fixtures/` JSON schemas as the canonical implementation. If the Kilo orchestrator is installed at `~/.config/kilo/`, the following `KILO_*` environment variables are honored as a compatible backend:

- `KILO_REPORT_DIRECTORY` — overrides the default `.ai/reports/` save path
- `KILO_CONFIG_ROOT` — when set, points at the Kilo fixtures and tools
- `KILO_TOOLS_PATH` — when set, the Node.js helpers under `~/.config/kilo/tools/*.mjs` may be used in place of the bundled Python scripts

When `KILO_*` variables are unset (the default), this reference works against the bundled `fixtures/` and `scripts/` directories only. Node.js and `~/.config/kilo/` are never required.

## See Also

- `baseline-map` - Builds focus areas and prior findings index
- `risk-scan` - Scans specific risk domains
- `finding-verification` - Validates findings with evidence