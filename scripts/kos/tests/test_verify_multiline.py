"""KOS-VERIFY-MULTILINE-001: multiline path/SHA-256 pairing in kos-verify-inputs.
Stdlib only; all fixtures live in temp dirs, never the real KOS home."""
from __future__ import annotations

import hashlib
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SCRIPT = ROOT / "scripts/kos/kos-verify-inputs.py"


def _sha(p: Path) -> str:
    return hashlib.sha256(p.read_bytes()).hexdigest()


class VerifyMultilineTests(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        self.dir = Path(self.tmp.name)
        self.aaa = self.dir / "aaa.txt"
        self.aaa.write_text("aaa\n", encoding="utf-8")
        self.bbb = self.dir / "bbb.txt"
        self.bbb.write_text("bbb\n", encoding="utf-8")
        self.sha_aaa = _sha(self.aaa)
        self.sha_bbb = _sha(self.bbb)

    def tearDown(self) -> None:
        self.tmp.cleanup()

    def _run(self, text: str, quiet: bool = False) -> subprocess.CompletedProcess:
        with tempfile.TemporaryDirectory() as tmp:
            pkg = Path(tmp) / "pkg.md"
            pkg.write_text(text, encoding="utf-8")
            argv = [sys.executable, "-B", str(SCRIPT), str(pkg)]
            if quiet:
                argv.append("--quiet")
            return subprocess.run(argv, capture_output=True, text=True)

    def test_multiline_bare_path_ok(self) -> None:
        text = "## 冻结输入\n- %s\n  SHA-256: %s\n" % (self.aaa, self.sha_aaa)
        r = self._run(text)
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
        self.assertIn("OK %s" % self.sha_aaa[:8], r.stdout)
        self.assertIn("SUMMARY ok=1 mismatch=0 missing=0 skip=0 badlen=0", r.stdout)

    def test_multiline_backticked_path_ok(self) -> None:
        text = "## 冻结输入\n- `%s`\n  SHA-256: %s\n" % (self.aaa, self.sha_aaa)
        r = self._run(text)
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
        self.assertIn("OK %s" % self.sha_aaa[:8], r.stdout)
        self.assertIn("SUMMARY ok=1 mismatch=0 missing=0 skip=0 badlen=0", r.stdout)

    def test_multiline_truncated_57_is_badlen(self) -> None:
        text = "## 冻结输入\n- %s\n  SHA-256: %s\n" % (self.aaa, self.sha_aaa[:57])
        r = self._run(text)
        self.assertEqual(r.returncode, 1, r.stdout + r.stderr)
        self.assertIn("BADLEN len=57 %s" % self.sha_aaa[:8], r.stdout)
        # BADLEN prints even under --quiet (KOS-VERIFY-QUIET-001)
        rq = self._run(text, quiet=True)
        self.assertEqual(rq.returncode, 1)
        self.assertIn("BADLEN len=57", rq.stdout)

    def test_multiline_mismatch_fails(self) -> None:
        wrong = "f" * 64
        text = "## 冻结输入\n- %s\n  SHA-256: %s\n" % (self.aaa, wrong)
        r = self._run(text)
        self.assertEqual(r.returncode, 1, r.stdout + r.stderr)
        self.assertIn("MISMATCH %s" % wrong[:8], r.stdout)

    def test_interleaved_path_does_not_mispair(self) -> None:
        # aaa's hash line is claimed by an intervening bbb path line: aaa must
        # not steal bbb's hash, and bbb (adjacent to the hash line) pairs fine
        text = (
            "## 冻结输入\n"
            "- %s\n"
            "- %s\n"
            "  SHA-256: %s\n" % (self.aaa, self.bbb, self.sha_bbb)
        )
        r = self._run(text)
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
        self.assertIn("OK %s %s" % (self.sha_bbb[:8], self.bbb), r.stdout)
        self.assertNotIn(str(self.aaa), r.stdout.split("SUMMARY")[0])
        self.assertIn("SUMMARY ok=1 mismatch=0 missing=0 skip=0 badlen=0", r.stdout)

    def test_interleaved_git_sha_breaks_pairing_not_badlen(self) -> None:
        git40 = "c" * 40
        text = (
            "## 冻结输入\n"
            "- %s\n"
            "  base commit %s\n"
            "  SHA-256: %s\n" % (self.aaa, git40, self.sha_aaa)
        )
        r = self._run(text)
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
        self.assertNotIn("BADLEN", r.stdout)
        self.assertNotIn("OK %s" % self.sha_aaa[:8], r.stdout)

    def test_git_sha_on_sha_line_is_exempt(self) -> None:
        git40 = "d" * 40
        text = "## 冻结输入\n- %s\n  SHA-256: %s\n" % (self.aaa, git40)
        r = self._run(text)
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
        self.assertNotIn("BADLEN", r.stdout)
        self.assertNotIn("MISMATCH", r.stdout)

    def test_same_line_pairing_unchanged(self) -> None:
        text = "## 冻结输入\n- `%s` SHA-256 `%s`\n" % (self.aaa, self.sha_aaa)
        r = self._run(text)
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
        self.assertIn("OK %s" % self.sha_aaa[:8], r.stdout)
        self.assertIn("SUMMARY ok=1 mismatch=0 missing=0 skip=0 badlen=0", r.stdout)

    def test_sameline_truncated_still_badlen(self) -> None:
        text = "## 冻结输入\n- `%s` SHA-256 `%s`\n" % (self.aaa, self.sha_aaa[:57])
        r = self._run(text)
        self.assertEqual(r.returncode, 1, r.stdout + r.stderr)
        self.assertIn("BADLEN len=57", r.stdout)


if __name__ == "__main__":
    unittest.main()
