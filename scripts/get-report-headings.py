#!/usr/bin/env python3
"""
Return all Markdown headings in a review report with start/end line ranges.

Usage:
    python get-report-headings.py <report.md>
    python get-report-headings.py <report.md> --min-level 2   # only h2+
    python get-report-headings.py <report.md> --max-level 3   # only up to h3
    python get-report-headings.py <report.md> --title "Executive Summary"  # filter by title

Output: JSON array of {title, type, start_line, end_line}

type is one of: h1, h2, h3, h4, h5, h6.
start_line is the line where the heading appears (1-indexed).
end_line is the line just before the next heading of equal or higher level, or the last line of the file.
"""

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any

# Matches ATX headings: 1-6 # characters followed by a space and title text.
# Does not match closing # sequences (e.g., "## Title ##" — the trailing ## are ignored).
HEADING_RE = re.compile(r'^(#{1,6})\s+(.+?)(?:\s+#+\s*)?$')


def extract_headings(
    content: str,
    min_level: int = 1,
    max_level: int = 6,
    title_filter: str | None = None,
) -> list[dict[str, Any]]:
    """
    Parse all Markdown headings from content and compute their line ranges.

    A heading's range extends from its own line to the line just before the
    next heading of equal or higher level (i.e., the next heading whose level
    is <= this heading's level). If no such heading exists, the range extends
    to the last line of the file.
    """
    lines = content.split("\n")
    headings: list[dict[str, Any]] = []  # {title, type, start_line, level}

    for i, line in enumerate(lines):
        m = HEADING_RE.match(line)
        if not m:
            continue
        level = len(m.group(1))
        if level < min_level or level > max_level:
            continue
        title = m.group(2).strip()
        if title_filter is not None and title_filter.lower() not in title.lower():
            continue
        headings.append({
            "title": title,
            "type": f"h{level}",
            "start_line": i + 1,  # 1-indexed
            "level": level,
        })

    # Compute end_line for each heading
    for idx, h in enumerate(headings):
        level = h["level"]
        # Find the next heading of equal or higher level (i.e., level <= this level)
        end_line = len(lines)  # default: last line
        for j in range(idx + 1, len(headings)):
            if headings[j]["level"] <= level:
                end_line = headings[j]["start_line"] - 1
                break
        h["end_line"] = end_line

    # Drop the internal 'level' key from output
    for h in headings:
        del h["level"]

    return headings


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Return all Markdown headings in a review report with start/end line ranges."
    )
    parser.add_argument("report", help="Path to a report .md file")
    parser.add_argument("--min-level", type=int, default=1,
                        help="Minimum heading level to include (default: 1)")
    parser.add_argument("--max-level", type=int, default=6,
                        help="Maximum heading level to include (default: 6)")
    parser.add_argument("--title", type=str, default=None,
                        help="Filter headings by title (case-insensitive substring match)")
    args = parser.parse_args()

    report_path = Path(args.report)
    if not report_path.is_file():
        print(f"Error: file not found: {report_path}", file=sys.stderr)
        sys.exit(1)

    try:
        content = report_path.read_text(encoding="utf-8")
    except (OSError, UnicodeDecodeError) as exc:
        print(f"Error: could not read {report_path}: {exc}", file=sys.stderr)
        sys.exit(1)

    headings = extract_headings(
        content,
        min_level=args.min_level,
        max_level=args.max_level,
        title_filter=args.title,
    )

    print(json.dumps(headings, indent=2))


if __name__ == "__main__":
    main()
