#!/usr/bin/env python3
"""Recompute frozen SHA-256 pairs quoted in a task package. Read-only."""
from __future__ import annotations

import argparse
import hashlib
import re
import sys
from pathlib import Path

PAIR = re.compile(r"`(/[^`]+)`(.{0,80}?)`([0-9a-f]{64})`")
# Hex runs of length 41-63 or >=65 next to a path: truncated or overlong
# SHA-256 (e.g. a hand-copied 58-char digest). Fail closed instead of
# silently skipping; plain 40-char git SHAs and short hex stay exempt.
PAIR_BADLEN = re.compile(r"`(/[^`]+)`(.{0,80}?)`([0-9a-f]{41,63}|[0-9a-f]{65,})`")


def skip_path(path: str) -> bool:
    return any(mark in path for mark in ("<", ">", "*", "$", "{{"))


# KOS-VERIFY-MULTILINE-001: path on one line, SHA-256 marker plus hex digest on
# the immediately following line. Only exactly-one path candidate per path line
# and only the adjacent line pair, so an interleaved path or a plain 40-char
# git SHA cannot be mispaired or misreported as BADLEN.
SHA_MARKER = re.compile(r"SHA-?256", re.IGNORECASE)
HEX_RUN = re.compile(r"(?<![0-9a-fA-F])[0-9a-fA-F]{40,}(?![0-9a-fA-F])")
PATH_CAND = re.compile(r"`(/[^`\n]+)`|(?<![\w`])(/[^\s`'\"，。；;）)]+)")


def multiline_entries(text: str) -> "tuple[list[tuple[str, str]], list[tuple[str, str]]]":
    """(badlen entries, pair entries) from adjacent line pairs."""
    badlen: list[tuple[str, str]] = []
    pairs: list[tuple[str, str]] = []
    lines = text.split("\n")
    for i in range(len(lines) - 1):
        cur, nxt = lines[i], lines[i + 1]
        if SHA_MARKER.search(cur):
            continue  # digest on the same line: same-line regexes own it
        tokens = [m.group(1) or m.group(2) for m in PATH_CAND.finditer(cur)]
        if len(tokens) != 1:
            continue
        if not SHA_MARKER.search(nxt):
            continue
        runs = HEX_RUN.findall(nxt)
        if not runs:
            continue
        path = tokens[0]
        if skip_path(path):
            continue
        digest = runs[0]
        if len(digest) == 40:
            continue  # plain git SHA on a SHA-256 line stays exempt
        if len(digest) == 64:
            pairs.append((path, digest))
        else:
            badlen.append((path, digest))
    return badlen, pairs


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
    counts = {"ok": 0, "mismatch": 0, "missing": 0, "skip": 0, "badlen": 0}
    for match in PAIR_BADLEN.finditer(text):
        path, digest = match.group(1), match.group(3)
        key = ("badlen", path, digest)
        if key in seen or skip_path(path):
            continue
        seen.add(key)
        counts["badlen"] += 1
        # BADLEN is a non-OK line: printed unconditionally, even under --quiet
        # (KOS-VERIFY-QUIET-001; the old `if not args.quiet or True:` was
        # always-true and misleading).
        print(f"BADLEN len={len(digest)} {digest[:8]} {path}")
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
    ml_badlen, ml_pairs = multiline_entries(text)
    for path, digest in ml_badlen:
        key = ("badlen", path, digest)
        if key in seen:
            continue
        seen.add(key)
        counts["badlen"] += 1
        # BADLEN is a non-OK line: printed unconditionally, even under --quiet
        print(f"BADLEN len={len(digest)} {digest[:8]} {path}")
    for path, digest in ml_pairs:
        key = (path, digest)
        if key in seen:
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
        "SUMMARY ok={ok} mismatch={mismatch} missing={missing} skip={skip} badlen={badlen}".format(**counts)
    )
    raise SystemExit(1 if counts["mismatch"] or counts["missing"] or counts["badlen"] else 0)


if __name__ == "__main__":
    main()
