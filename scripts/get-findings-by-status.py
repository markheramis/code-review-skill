#!/usr/bin/env python3
"""
Extract individual findings from review reports filtered by status.

Usage:
    python get-findings-by-status.py <report_path> <status>
    python get-findings-by-status.py <report_path> <status> --json              # JSON output (default)
    python get-findings-by-status.py <report_path> <status> --text              # human-readable
    python get-findings-by-status.py <report_path> <status> --include-context N # include N lines of context

Examples:
    python get-findings-by-status.py C:/reports/ needs-verification
    python get-findings-by-status.py report.md open --text
    python get-findings-by-status.py C:/reports/ completed --include-context 5

Output (JSON): array of {id, severity, confidence, category, title, status, path, line}
"""

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any

# ── Constants ─────────────────────────────────────────────────────────────────

STATUS_KEYS = ("open", "in-progress", "completed", "accepted-risk", "needs-verification")

# Matches a finding heading: ### F-001: Some Title
FINDING_HEADING_RE = re.compile(
    r'^###\s+(F-\d+):\s*(.+)$',
    re.MULTILINE,
)

# Matches metadata lines inside a finding block: **Severity:** High
META_LINE_RE = re.compile(
    r'^\*\*(Severity|Confidence|Category|Status):\*\*\s+(.+)$',
    re.MULTILINE,
)

# Matches the Findings Summary table to find report files
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
    return mapping.get(s, "open")


def _metadata_value(meta_key: str, raw: str) -> str:
    """Strip ** markers, trailing whitespace, and return the value part."""
    return raw.strip().lstrip("*").rstrip("*").strip()


def extract_findings(content: str, report_path: str) -> list[dict[str, Any]]:
    """
    Parse all individual finding blocks from a report's markdown content.

    Each finding block starts with `### F-XXX: Title` and contains metadata lines.
    We track the line number of the heading for surgical inspection.
    """
    findings: list[dict[str, Any]] = []
    lines = content.split("\n")

    i = 0
    while i < len(lines):
        line = lines[i]
        heading_match = FINDING_HEADING_RE.match(line)
        if not heading_match:
            i += 1
            continue

        finding_id = heading_match.group(1)
        finding_title = heading_match.group(2).strip()
        heading_line = i + 1  # 1-indexed line number

        severity = ""
        confidence = ""
        category = ""
        status = ""

        # Scan forward for metadata lines until next ## or ### or end
        j = i + 1
        while j < len(lines):
            next_line = lines[j]
            # Stop at next heading (## section or ### next finding)
            if next_line.startswith("## ") or (next_line.startswith("### ") and FINDING_HEADING_RE.match(next_line)):
                break
            if next_line.startswith("---"):
                break
            meta_match = META_LINE_RE.match(next_line)
            if meta_match:
                key = meta_match.group(1).lower()
                value = meta_match.group(2).strip()
                if key == "severity":
                    severity = value
                elif key == "confidence":
                    confidence = value
                elif key == "category":
                    category = value
                elif key == "status":
                    status = value
            j += 1

        findings.append({
            "id": finding_id,
            "severity": severity,
            "confidence": confidence,
            "category": category,
            "title": finding_title,
            "status": normalize_status(status) if status else "open",
            "path": report_path,
            "line": heading_line,
        })

        i = j
        continue

    return findings


def resolve_reports(path: Path) -> list[Path]:
    """Resolve input path to a list of report markdown files."""
    if path.is_file():
        if path.suffix == ".md":
            return [path]
        else:
            print(f"Warning: {path} is not a markdown file", file=sys.stderr)
            return []

    if path.is_dir():
        files = sorted(path.glob("*-review-*.md"), key=lambda p: p.name.lower())
        if not files:
            print(f"Warning: no review reports (*-review-*.md) found in {path}", file=sys.stderr)
        return files

    # Check for sibling .ai/reports directory when given .ai/report
    if path.name.lower() == "report":
        sibling = path.with_name("reports")
        if sibling.is_dir():
            print(f"Warning: {path} not found; using {sibling}", file=sys.stderr)
            return sorted(sibling.glob("*-review-*.md"), key=lambda p: p.name.lower())

    print(f"Error: {path} not found", file=sys.stderr)
    return []


def find_line_in_file(filepath: Path, finding_id: str) -> int:
    """Quick scan to find what line a finding ID appears on. Returns 1-indexed line or 0."""
    try:
        with open(filepath, encoding="utf-8") as f:
            for i, line in enumerate(f, start=1):
                if line.startswith(f"### {finding_id}:") or line.startswith(f"### {finding_id} "):
                    return i
    except (OSError, UnicodeDecodeError):
        pass
    return 0


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Extract individual findings from review reports filtered by status."
    )
    parser.add_argument("report_path", help="Path to a report .md file or directory of reports")
    parser.add_argument("status", help="Status to filter by (open, in-progress, completed, accepted-risk, needs-verification)")
    parser.add_argument("--json", action="store_true", default=True,
                        help="Output as JSON (default)")
    parser.add_argument("--text", action="store_true",
                        help="Output as human-readable text")
    parser.add_argument("--include-context", type=int, default=0,
                        help="Include N lines of context around each finding's heading (text mode only)")
    args = parser.parse_args()

    target_status = normalize_status(args.status)
    if target_status not in STATUS_KEYS:
        print(f"Error: unknown status '{args.status}'. Valid: {', '.join(STATUS_KEYS)}", file=sys.stderr)
        sys.exit(1)

    report_path = Path(args.report_path)
    report_files = resolve_reports(report_path)

    if not report_files:
        sys.exit(1)

    all_findings: list[dict[str, Any]] = []
    for rp in report_files:
        try:
            content = rp.read_text(encoding="utf-8")
        except (OSError, UnicodeDecodeError) as exc:
            print(f"Warning: could not read {rp}: {exc}", file=sys.stderr)
            continue

        findings = extract_findings(content, str(rp))
        all_findings.extend(f for f in findings if f["status"] == target_status)

    if args.text:
        for f in all_findings:
            # Short path for readability: just the filename
            short_path = Path(f["path"]).name
            print(f"[{f['id']}] {f['title']}")
            print(f"  Severity: {f['severity']}  Confidence: {f['confidence']}  Category: {f['category']}")
            print(f"  Status: {f['status']}  File: {short_path}  Line: {f['line']}")

            if args.include_context > 0:
                try:
                    report_content = Path(f["path"]).read_text(encoding="utf-8")
                    report_lines = report_content.split("\n")
                    start = max(0, f["line"] - 1 - args.include_context)
                    end = min(len(report_lines), f["line"] - 1 + args.include_context + 1)
                    print(f"  Context (lines {start+1}-{end}):")
                    for li in range(start, end):
                        prefix = ">>>" if li == f["line"] - 1 else "   "
                        print(f"  {prefix} {li+1}: {report_lines[li]}")
                except (OSError, UnicodeDecodeError) as exc:
                    print(f"  (could not read context: {exc})")
            print()
    else:
        print(json.dumps(all_findings, indent=2))


if __name__ == "__main__":
    main()
