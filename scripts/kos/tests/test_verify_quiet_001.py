"""KOS-VERIFY-QUIET-001: BADLEN lines are always printed, even under --quiet.

Semantics fixed by the packet: BADLEN is a non-OK line, so per the README
contract for --quiet ("only non-OK lines and SUMMARY") it must print in both
modes; the old expression `if not args.quiet or True:` was always-true and is
replaced by unconditional printing. Stdlib only.
"""
from __future__ import annotations

import hashlib
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

KOS = Path(__file__).resolve().parents[1]
PY = sys.executable
SCRIPT = KOS / "kos-verify-inputs.py"


def run_verify(package: Path, *extra: str):
    return subprocess.run([PY, "-B", str(SCRIPT), str(package), *extra],
                          capture_output=True, text=True, check=False)


class BadlenQuietTests(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.package = self.root / "pkg.md"

    def tearDown(self) -> None:
        self.tmp.cleanup()

    def _write_truncated_package(self) -> None:
        truncated = "ab" * 29  # 58 chars: a hand-copied truncated SHA-256
        self.package.write_text(
            f"target `{self.root / 'f.txt'}` SHA-256 `{truncated}`\n", encoding="utf-8")

    def test_badlen_printed_without_quiet(self) -> None:
        self._write_truncated_package()
        result = run_verify(self.package)
        self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
        self.assertIn("BADLEN len=58 abababab", result.stdout)
        self.assertIn("SUMMARY ok=0 mismatch=0 missing=0 skip=0 badlen=1", result.stdout)

    def test_badlen_printed_with_quiet(self) -> None:
        self._write_truncated_package()
        result = run_verify(self.package, "--quiet")
        self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
        self.assertIn("BADLEN len=58 abababab", result.stdout)
        self.assertIn("SUMMARY ok=0 mismatch=0 missing=0 skip=0 badlen=1", result.stdout)

    def test_quiet_hides_ok_but_not_badlen(self) -> None:
        target = self.root / "real.txt"
        target.write_text("payload\n", encoding="utf-8")
        digest = hashlib.sha256(target.read_bytes()).hexdigest()
        self.package.write_text(
            f"target `{self.root / 'f.txt'}` SHA-256 `{'ab' * 29}`\n"
            f"file `{target}` SHA-256 `{digest}`\n",
            encoding="utf-8")
        result = run_verify(self.package, "--quiet")
        self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
        self.assertIn("BADLEN len=58", result.stdout)
        self.assertNotIn(f"OK {digest[:8]}", result.stdout)
        self.assertIn("SUMMARY ok=1 mismatch=0 missing=0 skip=0 badlen=1", result.stdout)

    def test_badlen_boundary_lengths_printed_with_quiet(self) -> None:
        self.package.write_text(
            f"a `{self.root / 'g.txt'}` SHA-256 `{'1' * 41}`\n"
            f"b `{self.root / 'h.txt'}` SHA-256 `{'2' * 63}`\n",
            encoding="utf-8")
        result = run_verify(self.package, "--quiet")
        self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
        self.assertIn("BADLEN len=41", result.stdout)
        self.assertIn("BADLEN len=63", result.stdout)
        self.assertIn("SUMMARY ok=0 mismatch=0 missing=0 skip=0 badlen=2", result.stdout)


if __name__ == "__main__":
    unittest.main()
