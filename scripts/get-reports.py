#!/usr/bin/env python3
"""
List review reports and their finding status counts as JSON.

Usage:
    python get-reports.py <report_dir>
    python get-reports.py <report_dir> --open-only      # only reports with Open/In-Progress
    python get-reports.py <report_dir> --summary         # total counts across all reports

Output: JSON array of {file, findings: {open, in-progress, completed, accepted-risk, needs-verification}}
"""

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any


STATUS_KEYS = ("open", "in-progress", "completed", "accepted-risk", "needs-verification")
FINDINGS_SUMMARY_RE = re.compile(
    r'##\s+Findings\s+Summary\s*\n(.*?)(?=\n##\s|\Z)',
    re.DOTALL | re.IGNORECASE,
)


def normalize_status(raw: str) -> str:
    """Normalize a status string to the canonical key."""
    s = raw.strip().lower()
    mapping = {
        "open": "open",
        "in-progress": "in-progress",
        "in progress": "in-progress",
        "completed": "completed",
        "accepted-risk": "accepted-risk",
        "accepted risk": "accepted-risk",
        "needs-verification": "needs-verification",
        "needs verification": "needs-verification",
    }
    return mapping.get(s, "open")  # default to open if unrecognized


def parse_findings_table(text: str) -> dict[str, int]:
    """
    Parse the '## Findings Summary' table from a report.
    Returns counts keyed by normalized status.
    """
    counts: dict[str, int] = {k: 0 for k in STATUS_KEYS}

    # Find the findings summary section
    match = FINDINGS_SUMMARY_RE.search(text)
    if not match:
        return counts

    section = match.group(1)
    lines = section.strip().split("\n")

    # Skip header rows (first line is column headers, second is separator)
    in_table = False
    for line in lines:
        line = line.strip()
        if not line.startswith("|"):
            continue
        if "---" in line:
            in_table = True
            continue
        if not in_table:
            continue

        cells = [c.strip() for c in line.strip("|").split("|")]
        if len(cells) < 6:
            continue
        # Columns: ID, Severity, Confidence, Category, Title, Status
        status = normalize_status(cells[5])
        if status in counts:
            counts[status] += 1

    return counts


def sibling_reports_dir(report_dir: Path) -> Path | None:
    """Return .ai/reports when the caller passed the common singular .ai/report path."""
    if report_dir.name.lower() != "report":
        return None

    candidate = report_dir.with_name("reports")
    if candidate.is_dir():
        return candidate

    return None


def scan_reports(report_dir: Path) -> list[dict[str, Any]]:
    """Scan a directory for report markdown files and return finding counts."""
    files = sorted(report_dir.glob("*-review-*.md"), key=lambda path: path.name.lower())

    results: list[dict[str, Any]] = []
    for filepath in files:
        try:
            content = filepath.read_text(encoding="utf-8")
        except (OSError, UnicodeDecodeError) as exc:
            print(f"Warning: could not read {filepath}: {exc}", file=sys.stderr)
            continue

        findings = parse_findings_table(content)
        results.append({
            "file": filepath.name,
            "findings": findings,
        })

    return results


def main() -> None:
    parser = argparse.ArgumentParser(description="List review report finding counts.")
    parser.add_argument("report_dir", help="Directory containing review reports")
    parser.add_argument("--open-only", action="store_true",
                        help="Only show reports with Open or In-Progress findings")
    parser.add_argument("--summary", action="store_true",
                        help="Output aggregate counts across all reports instead of per-file")
    args = parser.parse_args()

    report_dir = Path(args.report_dir)

    if not report_dir.is_dir():
        fallback = sibling_reports_dir(report_dir)
        if fallback is None:
            print(f"Error: directory not found: {report_dir}", file=sys.stderr)
            sys.exit(1)

        print(f"Warning: directory not found: {report_dir}; using {fallback}", file=sys.stderr)
        report_dir = fallback

    reports = scan_reports(report_dir)

    fallback = sibling_reports_dir(report_dir)
    if not reports and fallback is not None:
        fallback_reports = scan_reports(fallback)
        if fallback_reports:
            print(f"Warning: no review reports found in {report_dir}; using {fallback}", file=sys.stderr)
            report_dir = fallback
            reports = fallback_reports

    if not reports:
        print(f"Warning: no review reports found in {report_dir}", file=sys.stderr)

    if args.open_only:
        reports = [
            r for r in reports
            if r["findings"].get("open", 0) > 0 or r["findings"].get("in-progress", 0) > 0
        ]

    if args.summary:
        totals: dict[str, int] = {k: 0 for k in STATUS_KEYS}
        for r in reports:
            for k in STATUS_KEYS:
                totals[k] += r["findings"].get(k, 0)
        print(json.dumps({"total_reports": len(reports), "findings": totals}, indent=2))
    else:
        print(json.dumps(reports, indent=2))


if __name__ == "__main__":
    main()
