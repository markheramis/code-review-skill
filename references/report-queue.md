---
name: report-queue
description: "Build a deterministic Open queue from report findings sorted by severity, dependency chain, and report order"
version: 1.0.0
author: Mark Heramis
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [code-review, evidence-first, reporting]
    related_skills: [evidence-first-code-review]
---

# Report Queue

Build a deterministic remediation queue from the report's Open findings. Sort by severity (descending), then by dependency chain (dependency before dependent), preserving original report order for ties. Output the ordered queue with dependency edges.

## Purpose

- Create ordered queue of findings to remediate
- Respect dependency relationships between findings
- Prioritize by severity
- Enable systematic burn-down of findings

## Inputs

- Report directory under `KILO_REPORT_DIRECTORY` (directory of finding files)
- `KILO_FINDINGS_STATUS` - `<KILO_CONFIG_ROOT>/fixtures/status-findings.json`

## Tools

- `~/.config/kilo/tools/build-remediation-queue.mjs` - Builds deterministic remediation queue

## Output Schema

```json
{
  "report_dir": "reports",
  "queue": [
    {
      "position": 1,
      "finding_id": "F-004",
      "finding_file": "F-004-buffer-overflow.md",
      "severity": "Critical",
      "category": "Security",
      "depends_on": [],
      "path": "src/auth/login.ts"
    },
    {
      "position": 2,
      "finding_id": "F-007",
      "finding_file": "F-007-sql-injection.md",
      "severity": "Critical",
      "category": "Security",
      "depends_on": ["F-004"],
      "path": "src/database/query.go"
    }
  ],
  "dependency_graph": {
    "F-004": [],
    "F-007": ["F-004"]
  },
  "stats": {
    "total_open": 12,
    "by_severity": {
      "Critical": 2,
      "High": 4,
      "Medium": 5,
      "Low": 1
    },
    "with_deps": 3,
    "leaf_nodes": 9
  }
}
```

## Workflow

1. **Scan report directory**
   - Find all finding files (`F-NNN-*.md`)
   - Parse frontmatter for status
   - Include only `Open` findings (case-insensitive)

2. **Parse dependencies**
   - Read `depends_on` field from frontmatter
   - Infer dependencies from file overlap when needed
   - Build dependency graph

3. **Sort queue**
   - Primary: severity rank (Critical > High > Medium > Low > Info)
   - Secondary: dependency depth (dependencies before dependents)
   - Tertiary: file/finding-ID order

4. **Detect circular dependencies**
   - Identify circular dependency chains
   - Break by severity then file order
   - Emit `circular_dependency_warning` in stats

5. **Deduplicate findings**
   - Check against `status-findings.json`
   - Use fixture status for conflicts
   - Skip from Open queue if not Open in fixture

6. **Handle missing data**
   - Default missing severity to `Medium`
   - Emit `missing_severity_warning` per finding
   - Emit `missing_frontmatter_warning` for files without frontmatter

7. **Build output**
   - Generate ordered queue
   - Include dependency graph
   - Calculate statistics

## Rules

- **Only Open findings** - Include only findings with `status: Open`
- **Deterministic sorting** - Same inputs always produce same order
- **Dependencies before dependents** - Topological sort within severity
- **No data loss** - Never discard findings without user confirmation
- **Fixture status is canonical** - Use `status-findings.json` for conflicts

## Integration

This skill is the first step in remediation:
```
report-queue → report-triage → report-resolution
```

## Dependencies

- Requires report directory with finding files
- Requires `KILO_CONFIG_ROOT` for tool access
- Requires `status-findings.json` for cross-report sync

## See Also

- `report-triage` - Classifies In-Progress findings
- `report-resolution` - Sequential burn-down of findings
- `build-remediation-queue.mjs` - Mechanical queue construction