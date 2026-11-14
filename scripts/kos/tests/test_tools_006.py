"""Tests for KOS-TOOLS-006: report-lint CONDITIONAL, cleanup dry-run exit 0, pkg-lint E1/E4/W4. Stdlib only."""
from __future__ import annotations

import os
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

KOS = Path(__file__).resolve().parents[1]
PY_EXE = sys.executable


def _which(name: str) -> bool:
    return shutil.which(name) is not None


def _env(home: Path, project: str = "Universe-Keyboard") -> dict:
    env = os.environ.copy()
    env["KOS_HOME"] = str(home)
    env["KOS_PROJECT"] = project
    env["PYTHONDONTWRITEBYTECODE"] = "1"
    return env


def _run_py(script: str, args: list[str], *, env: dict | None = None, cwd: Path | None = None):
    return subprocess.run(
        [PY_EXE, "-B", str(KOS / script), *args],
        capture_output=True,
        text=True,
        env=env,
        cwd=cwd,
    )


def _run_bash(script: str, args: list[str], *, env: dict | None = None, cwd: Path | None = None):
    return subprocess.run(
        ["bash", str(KOS / script), *args],
        capture_output=True,
        text=True,
        env=env,
        cwd=cwd,
    )


def _write(path: Path, text: str) -> Path:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")
    return path


class ReportLintConditionalTests(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)

    def tearDown(self) -> None:
        self.tmp.cleanup()

    def test_conditional_ok(self) -> None:
        p = _write(self.root / "c.md", "CONDITIONAL\n短摘要。\n")
        r = _run_py("kos-report-lint.py", [str(p)])
        self.assertEqual(r.returncode, 0)
        self.assertEqual(r.stdout.strip(), "OK")

    def test_maybe_rejected(self) -> None:
        p = _write(self.root / "m.md", "MAYBE\n短摘要。\n")
        r = _run_py("kos-report-lint.py", [str(p)])
        self.assertEqual(r.returncode, 1)
        self.assertIn("第一行不是状态词", r.stdout)


class CleanupDryRunExitTests(unittest.TestCase):
    def setUp(self) -> None:
        if not (_which("bash") and _which("bc") and _which("du")):
            self.skipTest("bash/bc/du missing — only allowed skip for kos-cleanup.sh host deps")
        self.tmp = tempfile.TemporaryDirectory()
        self.home = Path(self.tmp.name)
        self.project = "Universe-Keyboard"
        self.root = self.home / self.project
        self.task = "TOOLS006-CLEAN"
        (self.root / self.task / "scratch" / "tmp").mkdir(parents=True)
        (self.root / self.task / "scratch" / "tmp" / "a.bin").write_bytes(b"x" * 16)
        (self.root / "KOS-CLEANUP-001").mkdir(parents=True)
        (self.root / "KOS-CLEANUP-001" / "protected.txt").write_text("", encoding="utf-8")
        (self.root / "manifests").mkdir(parents=True)
        self.env = _env(self.home, self.project)

    def tearDown(self) -> None:
        self.tmp.cleanup()

    def test_dry_run_r_and_e_exit_zero_keep_file(self) -> None:
        target = self.root / self.task / "scratch" / "tmp" / "a.bin"
        r = _run_bash("kos-cleanup.sh", ["r", self.task], env=self.env)
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
        self.assertTrue(target.exists())
        e = _run_bash("kos-cleanup.sh", ["e", self.task], env=self.env)
        self.assertEqual(e.returncode, 0, e.stdout + e.stderr)
        self.assertTrue(target.exists())

    def test_unknown_mode_exit_2(self) -> None:
        r = _run_bash("kos-cleanup.sh", ["nope"], env=self.env)
        self.assertEqual(r.returncode, 2)

    def test_r_without_task_exit_2(self) -> None:
        r = _run_bash("kos-cleanup.sh", ["r"], env=self.env)
        self.assertEqual(r.returncode, 2)
        self.assertIn("需要至少一个任务号", r.stdout + r.stderr)


class PkgLintE1ReadonlyBaselineTests(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)

    def tearDown(self) -> None:
        self.tmp.cleanup()

    def test_readonly_main_head_line_skipped_but_start_line_still_e1(self) -> None:
        start = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
        other = "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
        wrong = "cccccccccccccccccccccccccccccccccccccccc"
        pkg = _write(
            self.root / "task-package-impl.md",
            "标题\n"
            f"主检出 /Users/doubleshy0n/Dev/Universe Keyboard 只读 main HEAD（预期 {other}）。\n"
            f"起点提交 {wrong}\n",
        )
        r = _run_py(
            "kos-pkg-lint.py",
            ["--start", start, str(pkg)],
        )
        self.assertEqual(r.returncode, 1)
        out = r.stdout
        # must not E1 on the readonly baseline line (other)
        self.assertNotRegex(out, rf"E1 .*SHA {other[:8]}")
        # must E1 on 起点提交 wrong
        self.assertIn(f"E1 {pkg.name}:", out)
        self.assertIn(wrong[:8], out)


class PkgLintE4OpenJsonTests(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)

    def tearDown(self) -> None:
        self.tmp.cleanup()

    def test_open_json_exempt_other_users_path_still_e4(self) -> None:
        start = "dddddddddddddddddddddddddddddddddddddddd"
        pkg = _write(
            self.root / "task-package-impl.md",
            "包\n"
            "/Users/kos-tools-006-definitely-missing/PM-LOG/open-x-001.json\n"
            "/Users/kos-tools-006-definitely-missing/other.txt\n",
        )
        r = _run_py("kos-pkg-lint.py", ["--start", start, str(pkg)])
        self.assertEqual(r.returncode, 1)
        out = r.stdout
        self.assertNotIn("open-x-001.json", out)
        self.assertIn("/Users/kos-tools-006-definitely-missing/other.txt", out)
        self.assertIn("E4", out)


class PkgLintW4Tests(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)

    def tearDown(self) -> None:
        self.tmp.cleanup()

    def test_w4_warns_without_failing(self) -> None:
        start = "eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee"
        pkg = _write(
            self.root / "task-package-impl.md",
            "行1 $name中文\n"
            "行2 $name，\n"
            "行3 ${name}中文\n"
            "行4 $name 中文\n"
            "行5 $name.\n",
        )
        r = _run_py("kos-pkg-lint.py", ["--start", start, str(pkg)])
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
        out = r.stdout
        self.assertEqual(out.count("W4 "), 2)
        self.assertIn("变量 $name 后紧跟非 ASCII 字符", out)
        self.assertIn("${name}", out)
