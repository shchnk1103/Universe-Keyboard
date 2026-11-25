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
            ["--start", start, str(pkg), "--no-git-check"],
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
        r = _run_py("kos-pkg-lint.py", ["--start", start, str(pkg), "--no-git-check"])
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
        r = _run_py("kos-pkg-lint.py", ["--start", start, str(pkg), "--no-git-check"])
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
        out = r.stdout
        self.assertEqual(out.count("W4 "), 2)
        self.assertIn("变量 $name 后紧跟非 ASCII 字符", out)
        self.assertIn("${name}", out)


class CleanupGuardTests(unittest.TestCase):
    """KOS-CLEANUP-GUARD-001: empty/invalid task ids fail closed; e-mode covers run-*/fx-*."""

    def setUp(self) -> None:
        if not (_which("bash") and _which("bc") and _which("du") and _which("tar")):
            self.skipTest("bash/bc/du/tar missing — only allowed skip for kos-cleanup.sh host deps")
        self.tmp = tempfile.TemporaryDirectory()
        self.home = Path(self.tmp.name)
        self.project = "Universe-Keyboard"
        self.root = self.home / self.project
        self.protected = "GUARD-PROT"
        self.neighbor = "GUARD-NEIGH"
        self.target = "GUARD-TARGET"
        for task in (self.protected, self.neighbor, self.target):
            (self.root / task / "scratch" / "DerivedData").mkdir(parents=True)
            (self.root / task / "scratch" / "DerivedData" / "blob.bin").write_bytes(b"x" * 8)
        (self.root / "KOS-CLEANUP-001").mkdir(parents=True)
        (self.root / "KOS-CLEANUP-001" / "protected.txt").write_text(self.protected + "\n", encoding="utf-8")
        (self.root / "manifests").mkdir(parents=True)
        self.env = _env(self.home, self.project)

    def tearDown(self) -> None:
        self.tmp.cleanup()

    def _blob(self, task: str) -> Path:
        return self.root / task / "scratch" / "DerivedData" / "blob.bin"

    def test_empty_task_id_apply_fails_closed_no_scan(self) -> None:
        r = _run_bash("kos-cleanup.sh", ["r", "", "--apply"], env=self.env)
        self.assertEqual(r.returncode, 2, r.stdout + r.stderr)
        for task in (self.protected, self.neighbor, self.target):
            self.assertTrue(self._blob(task).exists(), task)

    def test_invalid_task_ids_fail_closed(self) -> None:
        for bad in ("..", ".", "a/b", "x y", "  ", "a\tb"):
            r = _run_bash("kos-cleanup.sh", ["r", bad, "--apply"], env=self.env)
            self.assertEqual(r.returncode, 2, f"{bad!r}: {r.stdout + r.stderr}")
            for task in (self.protected, self.neighbor, self.target):
                self.assertTrue(self._blob(task).exists(), f"{bad!r} deleted {task}")
            e = _run_bash("kos-cleanup.sh", ["e", bad, "--apply"], env=self.env)
            self.assertEqual(e.returncode, 2, f"e {bad!r}: {e.stdout + e.stderr}")

    def test_e_mode_archives_run_and_fx_dirs(self) -> None:
        task = "GUARD-RUNFX"
        for name in ("run-1", "fx-ice"):
            d = self.root / task / name
            d.mkdir(parents=True)
            (d / "log.txt").write_text("evidence\n", encoding="utf-8")
        (self.root / "GUARD-RUNFX-unrelated" / "runner-x").mkdir(parents=True)
        r = _run_bash("kos-cleanup.sh", ["e", task, "--apply"], env=self.env)
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
        archive = self.root / "archive" / task
        self.assertTrue((archive / "run-1.tgz").exists(), sorted(p.name for p in archive.iterdir()))
        self.assertTrue((archive / "fx-ice.tgz").exists())
        self.assertTrue((archive / "SHA256SUMS.txt").exists())
        self.assertFalse((self.root / task / "run-1").exists())
        self.assertFalse((self.root / task / "fx-ice").exists())
        self.assertTrue((self.root / "GUARD-RUNFX-unrelated" / "runner-x").exists())
