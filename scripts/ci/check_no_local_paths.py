#!/usr/bin/env python3
"""KOS-TEST-LOCALPATH-001: ratchet guard against hardcoded local paths.

Tests must not hardcode /Users/... or .kos-work paths without a
skipUnless guard: CI runners have no such paths and local-only tests
should opt in explicitly. Ratchet semantics: files already carrying
local paths on the baseline commit stay exempt; any NEW offending
test_*.py fails closed with file name and line number.
"""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

# Files verified to already contain local paths on the baseline commit
# 4470ad7f5d7283f1cef0c9114280a21ba8489f07. Ratchet: exempt forever
# unless someone re-audits and shrinks the list.
BASELINE_COMMIT = "4470ad7f5d7283f1cef0c9114280a21ba8489f07"
BASELINE_EXEMPT = frozenset({
    "scripts/ci/tests/test_kos_tools.py",
    "scripts/kos/tests/test_templates_contract.py",
    "scripts/kos/tests/test_tools_006.py",
    "scripts/kos/tests/test_pkg_lint_guardrails.py",
    "scripts/kos/tests/test_kos_pack.py",
    "scripts/kos/tests/test_templates_relay_001.py",
    "scripts/kos/tests/test_tools_005.py",
})

LOCAL_PATH = re.compile(r"(/Users/|\.kos-work)")
SKIP_GUARD = re.compile(r"skipUnless")
BASELINE_EXEMPT_NAMES = frozenset(Path(p).name for p in BASELINE_EXEMPT)


def _rel_name(path: Path, roots: list[Path]) -> str:
    for root in roots:
        try:
            rel = path.relative_to(root.parent if False else Path.cwd())
            break
        except ValueError:
            continue
    else:
        rel = path
    return str(rel)


def _offenses(path: Path) -> list[int]:
    """Line numbers with local paths in a file lacking a skipUnless guard."""
    text = path.read_text(encoding="utf-8", errors="replace")
    if SKIP_GUARD.search(text):
        return []
    out = []
    for i, line in enumerate(text.splitlines()):
        hits = sorted({m.group(0) for m in LOCAL_PATH.finditer(line)})
        if hits:
            out.append((i + 1, ", ".join(hits)))
    return out


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "dirs",
        nargs="*",
        default=["scripts/kos/tests", "scripts/ci/tests"],
        help="directories to scan (default: kos and ci test dirs)",
    )
    parser.add_argument(
        "--baseline",
        default=",".join(sorted(BASELINE_EXEMPT)),
        help="comma-separated extra exempt file names; pass empty string to disable",
    )
    args = parser.parse_args()

    extra_exempt = {name for name in args.baseline.split(",") if name.strip()}
    roots = [Path(d) for d in args.dirs]
    failures: list[str] = []
    scanned = 0
    for root in roots:
        if not root.is_dir():
            print(f"no-local-paths: directory not found: {root}", file=sys.stderr)
            raise SystemExit(2)
        for path in sorted(root.rglob("test_*.py")):
            scanned += 1
            name = path.name
            if name in extra_exempt or name in BASELINE_EXEMPT_NAMES:
                continue
            for line, matched in _offenses(path):
                failures.append(
                    f"no-local-paths: {path}:{line} hardcoded local path ({matched})"
                )
    if failures:
        print("\n".join(failures))
        print(f"SUMMARY scanned={scanned} offenders={len(failures)}")
        raise SystemExit(1)
    print(f"PASS no-local-paths scanned={scanned} offenders=0")


if __name__ == "__main__":
    main()
