#!/usr/bin/env python3
"""Classify fixed-string git grep hits. Read-only."""
from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path


def fail(message: str) -> None:
    print(message, file=sys.stderr)
    raise SystemExit(2)


def classify(path: str, allowed: set[str], later: set[str], ignores: list[str]) -> str:
    if path in allowed:
        return "ALLOWED"
    if path in later:
        return "LATER"
    if any(path.startswith(prefix) for prefix in ignores):
        return "IGNORED"
    return "UNCLASSIFIED"


def grep(repo: str, term: str, ref: str | None) -> list[tuple[str, int]]:
    command = ["git", "-C", repo, "grep", "-c", "-F", "-e", term]
    if ref:
        command.extend([ref, "--"])
    result = subprocess.run(command, capture_output=True, text=True)
    if result.returncode == 1 and not result.stdout:
        return []
    if result.returncode not in (0, 1):
        sys.stderr.write(result.stderr)
        raise SystemExit(2)
    hits: list[tuple[str, int]] = []
    for line in result.stdout.splitlines():
        left, count = line.rsplit(":", 1)
        if ref and left.startswith(ref + ":"):
            left = left[len(ref) + 1:]
        hits.append((left, int(count)))
    return hits


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--repo", required=True)
    parser.add_argument("--ref")
    parser.add_argument("--term", action="append", default=[])
    parser.add_argument("--allowed", action="append", default=[])
    parser.add_argument("--later", action="append", default=[])
    parser.add_argument("--ignore", action="append", default=[])
    args = parser.parse_args()
    if not args.term:
        fail("至少需要一个 --term")
    probe = subprocess.run(
        ["git", "-C", args.repo, "rev-parse", "--is-inside-work-tree"],
        capture_output=True,
        text=True,
    )
    if probe.returncode != 0 or probe.stdout.strip() != "true":
        fail(f"不是 git 仓库：{args.repo}")
    allowed, later = set(args.allowed), set(args.later)
    unclassified: set[str] = set()
    exit_code = 0
    for term in args.term:
        hits = sorted(grep(args.repo, term, args.ref))
        total = sum(count for _, count in hits)
        print(f"TERM {term}: {total} hits in {len(hits)} files")
        for path, count in hits:
            kind = classify(path, allowed, later, args.ignore)
            if kind == "UNCLASSIFIED":
                unclassified.add(path)
                exit_code = 1
            print(f"{kind} {path} ({count})")
    names = " ".join(sorted(unclassified)) if unclassified else "none"
    print(f"UNCLASSIFIED: {names}")
    print(f"SUMMARY unclassified={len(unclassified)}")
    raise SystemExit(exit_code)


if __name__ == "__main__":
    main()
