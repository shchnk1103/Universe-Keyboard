#!/usr/bin/env python3
"""Recompute frozen SHA-256 pairs quoted in a task package. Read-only."""
from __future__ import annotations

import argparse
import hashlib
import re
import sys
from pathlib import Path

PAIR = re.compile(r"`(/[^`]+)`(.{0,80}?)`([0-9a-f]{64})`")


def skip_path(path: str) -> bool:
    return any(mark in path for mark in ("<", ">", "*", "$", "{{"))


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("package")
    parser.add_argument("--quiet", action="store_true")
    args = parser.parse_args()
    package = Path(args.package)
    if not package.is_file():
        print(f"包文件不存在：{package}", file=sys.stderr)
        raise SystemExit(2)
    text = package.read_text(encoding="utf-8")
    seen: set[tuple[str, str]] = set()
    counts = {"ok": 0, "mismatch": 0, "missing": 0, "skip": 0}
    for match in PAIR.finditer(text):
        path, digest = match.group(1), match.group(3)
        key = (path, digest)
        if key in seen or skip_path(path):
            continue
        seen.add(key)
        target = Path(path)
        if target.is_dir():
            status = "SKIP"
        elif not target.is_file():
            status = "MISSING"
        else:
            actual = hashlib.sha256(target.read_bytes()).hexdigest()
            status = "OK" if actual == digest else "MISMATCH"
        counts[status.lower()] += 1
        if not args.quiet or status != "OK":
            print(f"{status} {digest[:8]} {path}")
    print(
        "SUMMARY ok={ok} mismatch={mismatch} missing={missing} skip={skip}".format(**counts)
    )
    raise SystemExit(1 if counts["mismatch"] or counts["missing"] else 0)


if __name__ == "__main__":
    main()
