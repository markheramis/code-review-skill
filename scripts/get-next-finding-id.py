#!/usr/bin/env python3
r"""
Return the next available F-XXX finding ID for a project's report directory.

Scans all *-review-*.md files in the directory, extracts every F-\d+ from
the '## Findings Summary' table in each, and returns the next available ID.

Usage:
    python get-next-finding-id.py <report_dir>

Output: JSON object {next_id, max_existing, reports_scanned}
    {"next_id": "F-011", "max_existing": 10, "reports_scanned": 8}
    {"next_id": "F-001", "max_existing": 0, "reports_scanned": 0}

Exit codes: 0 on success, 1 on error.
"""

import argparse
import json
import re
import sys
from pathlib import Path

# Matches the Findings Summary table: captures from the heading to the next
# ## heading or EOF. Same regex as get-reports.py.
FINDINGS_SUMMARY_RE = re.compile(
    r'##\s+Findings\s+Summary\s*\n(.*?)(?=\n##\s|\Z)',
    re.DOTALL | re.IGNORECASE,
)

# Extracts F-\d+ from the ID column of a findings summary table row.
# Table shape: | ID | Severity | Confidence | Category | Title | Status |
# We need the first cell after the leading |.
FINDING_ROW_RE = re.compile(
    r'^\|\s*(F-\d+)\s*\|',
    re.MULTILINE,
)


def sibling_reports_dir(report_dir: Path) -> Path | None:
    """Return .ai/reports when the caller passed .ai/report path."""
    if report_dir.name.lower() != "report":
        return None
    candidate = report_dir.with_name("reports")
    if candidate.is_dir():
        return candidate
    return None


def scan_next_id(report_dir: Path) -> dict:
    """
    Scan all *-review-*.md files in report_dir and return the next
    available F-XXX ID along with metadata.
    """
    files = sorted(report_dir.glob("*-review-*.md"), key=lambda p: p.name.lower())
    max_id = 0

    for filepath in files:
        try:
            content = filepath.read_text(encoding="utf-8")
        except (OSError, UnicodeDecodeError) as exc:
            print(f"Warning: could not read {filepath}: {exc}", file=sys.stderr)
            continue

        # Find the findings summary table
        match = FINDINGS_SUMMARY_RE.search(content)
        if not match:
            continue

        section = match.group(1)

        # Extract all F-XXX from the table rows
        for row_match in FINDING_ROW_RE.finditer(section):
            raw_id = row_match.group(1)
            try:
                num = int(raw_id.split("-")[1])
                if num > max_id:
                    max_id = num
            except (ValueError, IndexError):
                continue

    next_num = max_id + 1
    return {
        "next_id": f"F-{next_num:03d}",
        "max_existing": max_id,
        "reports_scanned": len(files),
    }


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Return the next available F-XXX finding ID for a project's report directory."
    )
    parser.add_argument("report_dir", help="Directory containing review reports")
    args = parser.parse_args()

    report_dir = Path(args.report_dir)

    if not report_dir.is_dir():
        fallback = sibling_reports_dir(report_dir)
        if fallback is None:
            print(f"Error: directory not found: {report_dir}", file=sys.stderr)
            sys.exit(1)
        print(f"Warning: directory not found: {report_dir}; using {fallback}", file=sys.stderr)
        report_dir = fallback

    result = scan_next_id(report_dir)
    print(json.dumps(result))


if __name__ == "__main__":
    main()
