#!/usr/bin/env python3
"""Convert Delphi visibility sections that FPC cannot compile."""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path


PUBLISHED_SECTION = re.compile(r"^(?P<indent>\s*)published\s*$", re.IGNORECASE)
DECLARATION = re.compile(
    r"^(constructor|procedure|function|property)\b", re.IGNORECASE
)
IDENTIFIER_RENAMES = ((re.compile(r"\bExtractWord\b"), "ExtractWordList"),)


def has_method_after(lines: list[str], index: int) -> bool:
    """Return whether the section contains a method-like declaration next."""
    for line in lines[index + 1 :]:
        stripped = line.strip()
        if not stripped or stripped.startswith("//"):
            continue
        return bool(DECLARATION.match(stripped))
    return False


def convert_text(text: str) -> tuple[str, int]:
    lines = text.splitlines(keepends=True)
    converted = 0

    for index, line in enumerate(lines):
        if PUBLISHED_SECTION.match(line) and has_method_after(lines, index):
            indent = PUBLISHED_SECTION.match(line).group("indent")
            newline = "\n" if line.endswith("\n") else ""
            lines[index] = f"{indent}public{newline}"
            converted += 1

    converted_text = "".join(lines)
    for pattern, replacement in IDENTIFIER_RENAMES:
        converted_text, count = pattern.subn(replacement, converted_text)
        converted += count

    return converted_text, converted


def read_source(path: Path) -> tuple[str, str]:
    raw = path.read_bytes()
    try:
        return raw.decode("utf-8"), "utf-8"
    except UnicodeDecodeError:
        return raw.decode("cp1251"), "cp1251"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("root", type=Path, help="Source directory to scan")
    parser.add_argument(
        "--write", action="store_true", help="Write converted files in place"
    )
    parser.add_argument(
        "--check",
        action="store_true",
        help="Exit with status 1 when convertible sections are found",
    )
    args = parser.parse_args()

    changed_files = 0
    converted_sections = 0
    for path in sorted(args.root.rglob("*.pas")):
        original, encoding = read_source(path)
        converted, count = convert_text(original)
        if not count:
            continue

        changed_files += 1
        converted_sections += count
        print(f"{path}: {count} section(s)")
        if args.write:
            path.write_bytes(converted.encode(encoding))

    if args.check and converted_sections:
        return 1

    print(
        f"Found {converted_sections} convertible section(s) in "
        f"{changed_files} file(s)."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())