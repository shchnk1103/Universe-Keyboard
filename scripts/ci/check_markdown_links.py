#!/usr/bin/env python3
"""Check repository-local links in Markdown files changed by a Git diff."""

from __future__ import annotations

import argparse
import re
import subprocess
import sys
from pathlib import Path
from urllib.parse import unquote, urlsplit


LINK = re.compile(r"!?\[[^\]]*\]\(([^)]+)\)")
SCHEME = re.compile(r"^[a-z][a-z0-9+.-]*:", re.IGNORECASE)


def changed_markdown(base: str, head: str) -> list[Path]:
    result = subprocess.run(
        [
            "git",
            "diff",
            "--name-only",
            "--no-renames",
            "--diff-filter=ACMRTUXB",
            "-z",
            base,
            head,
            "--",
            "*.md",
        ],
        check=True,
        capture_output=True,
    )
    return [
        Path(item.decode("utf-8", errors="surrogateescape"))
        for item in result.stdout.split(b"\0")
        if item
    ]


def normalize_target(raw_target: str) -> str | None:
    target = raw_target.strip()
    if target.startswith("<") and target.endswith(">"):
        target = target[1:-1]
    elif " " in target:
        target = target.split(None, 1)[0]

    if not target or target.startswith("#") or SCHEME.match(target):
        return None

    parsed = urlsplit(target)
    return unquote(parsed.path) or None


def missing_links(markdown_path: Path, repository_root: Path) -> list[tuple[int, str]]:
    failures: list[tuple[int, str]] = []
    text = markdown_path.read_text(encoding="utf-8")
    for line_number, line in enumerate(text.splitlines(), start=1):
        for raw_target in LINK.findall(line):
            target = normalize_target(raw_target)
            if target is None:
                continue
            candidate = (
                repository_root / target.lstrip("/")
                if target.startswith("/")
                else markdown_path.parent / target
            )
            if not candidate.resolve().exists():
                failures.append((line_number, raw_target))
    return failures


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--base", required=True)
    parser.add_argument("--head", required=True)
    args = parser.parse_args()

    root = Path.cwd().resolve()
    failures: list[str] = []
    try:
        paths = changed_markdown(args.base, args.head)
    except subprocess.CalledProcessError as error:
        print(f"FAIL: unable to enumerate changed Markdown: {error}", file=sys.stderr)
        return 2

    for path in paths:
        if not path.is_file():
            continue
        for line_number, target in missing_links(path, root):
            failures.append(f"{path}:{line_number}: missing local link target: {target}")

    if failures:
        print("\n".join(failures), file=sys.stderr)
        return 1

    print(f"PASS changed Markdown links ({len(paths)} files)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
