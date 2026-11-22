"""KOS-TEST-LOCALPATH-001: ratchet guard against hardcoded local paths in tests.

Stdlib only; all fixtures live in temp dirs, never the real KOS home."""
from __future__ import annotations

import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SCRIPT = ROOT / "scripts/ci/check_no_local_paths.py"


def _run(*args: str) -> subprocess.CompletedProcess:
    return subprocess.run(
        [sys.executable, "-B", str(SCRIPT), *args], capture_output=True, text=True
    )


class NoLocalPathsTests(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)

    def tearDown(self) -> None:
        self.tmp.cleanup()

    def _dir(self, name: str, files: dict[str, str]) -> str:
        d = self.root / name
        d.mkdir(parents=True)
        for rel, text in files.items():
            target = d / rel
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_text(text, encoding="utf-8")
        return str(d)

    def test_offender_outside_baseline_fails_closed(self) -> None:
        d = self._dir("t1", {
            "test_bad.py": "P = '/Users/foo/bar/KOS'\n",
        })
        r = _run("--baseline", "", d)
        self.assertNotEqual(r.returncode, 0, r.stdout + r.stderr)
        self.assertIn("test_bad.py", r.stdout + r.stderr)
        self.assertIn("/Users/", r.stdout + r.stderr)

    def test_kos_work_offender_outside_baseline_fails_closed(self) -> None:
        d = self._dir("t2", {
            "test_bad2.py": "Q = '/Users/doubleshy0n/.kos-work/Universe-Keyboard/tools/x.sh'\n",
        })
        r = _run("--baseline", "", d)
        self.assertNotEqual(r.returncode, 0, r.stdout + r.stderr)
        self.assertIn(".kos-work", r.stdout + r.stderr)
        self.assertIn("test_bad2.py", r.stdout + r.stderr)

    def test_offender_reports_line_number(self) -> None:
        d = self._dir("t3", {
            "test_lines.py": "ok = 1\n\nP = '/Users/someone/x'\n",
        })
        r = _run("--baseline", "", d)
        self.assertNotEqual(r.returncode, 0)
        self.assertRegex(r.stdout + r.stderr, r"test_lines\.py:(\d+)")

    def test_baseline_exempt_file_passes(self) -> None:
        d = self._dir("t4", {
            "test_legacy.py": "P = '/Users/legacy/x'\nQ = '.kos-work'\n",
        })
        r = _run("--baseline", "test_legacy.py", d)
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)

    def test_builtin_baseline_is_used_by_default(self) -> None:
        # the 7 shipped baseline files: exempted by default, no --baseline flag
        d = self._dir("t5", {
            "test_kos_tools.py": "P = '/Users/legacy/x'\n",
            "test_templates_contract.py": "P = '/Users/legacy/x'\n",
            "test_tools_006.py": "P = '/Users/legacy/x'\n",
            "test_pkg_lint_guardrails.py": "P = '/Users/legacy/x'\n",
            "test_kos_pack.py": "P = '/Users/legacy/x'\n",
            "test_templates_relay_001.py": "P = '/Users/legacy/x'\n",
            "test_tools_005.py": "P = '/Users/legacy/x'\n",
        })
        r = _run(d)
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)

    def test_skip_unless_guarded_file_passes(self) -> None:
        d = self._dir("t6", {
            "test_guarded.py": (
                "import os\nimport unittest\n"
                "ROOT = '/Users/doubleshy0n/.kos-work/Universe-Keyboard'\n"
                "@unittest.skipUnless(os.path.isdir(ROOT), 'local only')\n"
                "class T(unittest.TestCase):\n"
                "    def test_x(self):\n"
                "        self.assertTrue(True)\n"
            ),
        })
        r = _run("--baseline", "", d)
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)

    def test_clean_file_passes(self) -> None:
        d = self._dir("t7", {
            "test_clean.py": "import unittest\n\nclass T(unittest.TestCase):\n"
                             "    def test_ok(self):\n        self.assertTrue(True)\n",
            "not_a_test.py": "P = '/Users/ignored/non-test'\n",
        })
        r = _run("--baseline", "", d)
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)

    def test_repo_scan_zero_false_positives(self) -> None:
        r = _run(str(ROOT / "scripts/kos/tests"), str(ROOT / "scripts/ci/tests"))
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)


if __name__ == "__main__":
    unittest.main()
