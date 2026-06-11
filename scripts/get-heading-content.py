#!/usr/bin/env python3
"""
Surgically extract the content of a specific heading from a Markdown report.

Usage:
    python get-heading-content.py <report.md> --title "Executive Summary"
    python get-heading-content.py <report.md> --title "Findings" --type h2
    python get-heading-content.py <report.md> --title "F-001" --type h3

Output: the raw Markdown content from the heading's start_line to end_line.
"""

import argparse
import re
import sys
from pathlib import Path
from typing import Any

# Matches ATX headings: 1-6 # characters followed by a space and title text.
HEADING_RE = re.compile(r'^(#{1,6})\s+(.+?)(?:\s+#+\s*)?$')


def find_heading_range(
    content: str,
    title: str,
    heading_type: str | None = None,
) -> tuple[int, int] | None:
    """
    Find the (start_line, end_line) for a heading matching the given title.

    Returns None if no matching heading is found.
    """
    lines = content.split("\n")

    # Build list of all headings with their levels
    headings: list[dict[str, Any]] = []
    for i, line in enumerate(lines):
        m = HEADING_RE.match(line)
        if not m:
            continue
        level = len(m.group(1))
        h_title = m.group(2).strip()

        # Filter by type if specified
        if heading_type is not None:
            if f"h{level}" != heading_type:
                continue

        # Filter by title (case-insensitive substring match)
        if title.lower() not in h_title.lower():
            continue

        headings.append({
            "title": h_title,
            "start_line": i + 1,
            "level": level,
        })

    if not headings:
        return None

    # If multiple matches, use the first one
    match = headings[0]

    # Compute end_line: next heading of equal or higher level, or EOF
    end_line = len(lines)
    # Re-scan from after the match to find the terminator
    for i in range(match["start_line"], len(lines)):
        m2 = HEADING_RE.match(lines[i])
        if m2:
            next_level = len(m2.group(1))
            if next_level <= match["level"]:
                end_line = i  # 1-indexed line of the next heading
                break

    return (match["start_line"], end_line)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Surgically extract the content of a specific heading from a Markdown report."
    )
    parser.add_argument("report", help="Path to a report .md file")
    parser.add_argument("--title", type=str, required=True,
                        help="Heading title to extract (case-insensitive substring match)")
    parser.add_argument("--type", type=str, default=None,
                        help="Heading type to filter by (h1, h2, h3, h4, h5, h6)")
    args = parser.parse_args()

    if args.type is not None:
        valid_types = {"h1", "h2", "h3", "h4", "h5", "h6"}
        if args.type not in valid_types:
            print(f"Error: --type must be one of {', '.join(sorted(valid_types))}", file=sys.stderr)
            sys.exit(1)

    report_path = Path(args.report)
    if not report_path.is_file():
        print(f"Error: file not found: {report_path}", file=sys.stderr)
        sys.exit(1)

    try:
        content = report_path.read_text(encoding="utf-8")
    except (OSError, UnicodeDecodeError) as exc:
        print(f"Error: could not read {report_path}: {exc}", file=sys.stderr)
        sys.exit(1)

    result = find_heading_range(content, args.title, args.type)
    if result is None:
        print(f"Error: no heading matching title='{args.title}' type='{args.type or 'any'}' found in {report_path}",
              file=sys.stderr)
        sys.exit(1)

    start_line, end_line = result
    lines = content.split("\n")
    # Print the range (start_line is 1-indexed, end_line is 1-indexed exclusive)
    print("\n".join(lines[start_line - 1:end_line]))


if __name__ == "__main__":
    main()
