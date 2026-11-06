#!/usr/bin/env python3
"""Print author|committer for a revision and judge it against --expect."""
from __future__ import annotations

import argparse
import subprocess
import sys


def check_identity(repo: str, expect: str, rev: str = "HEAD") -> tuple[str, int]:
    """Return (printed_line_including_verdict_lines_joined, exit_code).

    Exit 0 IDENTITY_MATCH, 1 IDENTITY_MISMATCH, 2 IDENTITY_ERROR.
    """
    try:
        proc = subprocess.run(
            [
                "git",
                "-C",
                repo,
                "log",
                "-1",
                "--format=%an <%ae>|%cn <%ce>",
                rev,
            ],
            capture_output=True,
            text=True,
            check=False,
        )
    except OSError as exc:
        return f"IDENTITY_ERROR {exc}", 2
    if proc.returncode != 0:
        err = (proc.stderr or proc.stdout or "git log failed").strip()
        return f"IDENTITY_ERROR {err}", 2
    line = proc.stdout.strip()
    parts = line.split("|", 1)
    if len(parts) != 2 or parts[0] != expect or parts[1] != expect:
        return f"{line}\nIDENTITY_MISMATCH", 1
    return f"{line}\nIDENTITY_MATCH", 0


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(prog="check_identity.py")
    parser.add_argument("--repo", required=True)
    parser.add_argument("--expect", required=True)
    parser.add_argument("--rev", default="HEAD")
    args = parser.parse_args(argv)
    text, code = check_identity(args.repo, args.expect, args.rev)
    print(text)
    return code


if __name__ == "__main__":
    sys.exit(main())
