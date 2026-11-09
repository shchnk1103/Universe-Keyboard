"""Tests for KOS-TOOLS-005: six PM-side tools under scripts/kos. Stdlib only, no network."""
from __future__ import annotations

import hashlib
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


def _sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def _write(path: Path, text: str) -> Path:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")
    return path


class ReportLintTests(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)

    def tearDown(self) -> None:
        self.tmp.cleanup()

    def _lint(self, report: Path, extra: list[str] | None = None):
        return _run_py("kos-report-lint.py", [str(report), *(extra or [])])

    def test_oversize_fails(self) -> None:
        p = _write(self.root / "big.md", "DONE\n" + ("x" * 13000))
        r = self._lint(p)
        self.assertEqual(r.returncode, 1)
        self.assertIn("超过上限", r.stdout)

    def test_bad_first_line_fails(self) -> None:
        p = _write(self.root / "bad.md", "NOT_A_STATUS\nbody\n")
        r = self._lint(p)
        self.assertEqual(r.returncode, 1)
        self.assertIn("第一行不是状态词", r.stdout)

    def test_repeated_prefix_fails(self) -> None:
        lines = ["DONE"] + [f"LUNA_PR_EXP line={i}" for i in range(25)]
        p = _write(self.root / "rep.md", "\n".join(lines) + "\n")
        r = self._lint(p)
        self.assertEqual(r.returncode, 1)
        self.assertIn("LUNA_PR_EXP", r.stdout)

    def test_sha_mismatch_fails(self) -> None:
        log = _write(self.root / "a.log", "hello\n")
        fake = "0" * 64
        p = _write(self.root / "r.md", f"DONE\n日志 {log} SHA-256 `{fake}`\n")
        r = self._lint(p)
        self.assertEqual(r.returncode, 1)
        self.assertIn("SHA 与实测不符", r.stdout)

    def test_ok_sample(self) -> None:
        p = _write(self.root / "ok.md", "DONE\nLucy Executor\n摘要足够短。\n")
        r = self._lint(p)
        self.assertEqual(r.returncode, 0)
        self.assertEqual(r.stdout.strip(), "OK")


class ContainsTests(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)

    def tearDown(self) -> None:
        self.tmp.cleanup()

    def test_all_present(self) -> None:
        log = _write(self.root / "log.txt", "alpha\nkeep LUNA_PR_A\nbeta\nkeep LUNA_PR_B\n")
        ref = _write(self.root / "ref.txt", "keep LUNA_PR_A\nkeep LUNA_PR_B\nnoise\n")
        r = _run_py("kos-contains.py", [r"LUNA_PR_", str(log), str(ref)])
        self.assertEqual(r.returncode, 0)
        self.assertIn("匹配 2 行，缺失 0 行", r.stdout)

    def test_missing_reports(self) -> None:
        log = _write(self.root / "log.txt", "keep LUNA_PR_A\nkeep LUNA_PR_MISSING\n")
        ref = _write(self.root / "ref.txt", "keep LUNA_PR_A\n")
        r = _run_py("kos-contains.py", [r"LUNA_PR_", str(log), str(ref)])
        self.assertEqual(r.returncode, 1)
        self.assertIn("匹配 2 行，缺失 1 行", r.stdout)
        self.assertIn("LUNA_PR_MISSING", r.stdout)


class PkgLintTests(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.start = "a" * 40
        self.charter = _write(
            self.root / "STAGE-CHARTER.md",
            "\n".join(
                [
                    "# charter",
                    "| 键 | 含义 | 由谁产出 | 谁需要 |",
                    "|---|---|---|---|",
                    "| commit | c | M1 | M2 |",
                    "| N | n | M1 | M2 |",
                    "",
                    "U1. 主题甲在章程里的写法足够长以便与实现包比对相似度一二三四五六七八九十",
                    "",
                ]
            )
            + "\n",
        )

    def tearDown(self) -> None:
        self.tmp.cleanup()

    def _run(self, files: list[Path], *, start: str | None = None, prev: Path | None = None, charter: Path | None = None):
        args = ["--start", start or self.start]
        if prev is not None:
            args += ["--prev", str(prev)]
        if charter is not None:
            args += ["--charter", str(charter)]
        elif charter is not False:
            args += ["--charter", str(self.charter)]
        args += [str(f) for f in files]
        return _run_py("kos-pkg-lint.py", args, env=_env(self.root))

    def test_e1_start_mismatch(self) -> None:
        wrong = "b" * 40
        pkg = _write(self.root / "task-package-impl.md", f"起点 HEAD 必须是 {wrong}\n")
        r = self._run([pkg])
        self.assertEqual(r.returncode, 1)
        self.assertIn("E1", r.stdout)

    def test_e2_prev_sha_leftover(self) -> None:
        prev = self.root / "prev"
        leftover = "c" * 40
        _write(prev / "instructions" / "task-package-impl.md", f"冻结 {leftover}\n")
        _write(prev / "STAGE-CHARTER.md", "empty\n")
        pkg = _write(self.root / "task-package-impl.md", f"正文引用 {leftover}\n")
        r = self._run([pkg], prev=prev)
        self.assertEqual(r.returncode, 1)
        self.assertIn("E2", r.stdout)

    def test_e3_unknown_block_key(self) -> None:
        pkg = _write(
            self.root / "task-package-impl.md",
            "运行 `kos-block.sh x y pkg params block weird_key=1 commit=abc`\n",
        )
        r = self._run([pkg])
        self.assertEqual(r.returncode, 1)
        self.assertIn("E3", r.stdout)
        self.assertIn("weird_key", r.stdout)

    def test_e4_missing_users_path(self) -> None:
        pkg = _write(
            self.root / "task-package-impl.md",
            "路径 /Users/this-path-definitely-does-not-exist-kos-tools-005/file.md 应报。\n"
            "另写 /Users/doubleshy0n/Dev/Universe Keyboard/x 不应报 E4。\n",
        )
        r = self._run([pkg])
        self.assertEqual(r.returncode, 1)
        self.assertIn("E4", r.stdout)
        self.assertIn("this-path-definitely-does-not-exist-kos-tools-005", r.stdout)
        self.assertNotIn("Universe Keyboard/x", r.stdout)

    def test_w3_item_divergence(self) -> None:
        a = _write(
            self.root / "task-package-impl.md",
            "U1. 完全不同的实现包措辞甲乙丙丁戊己庚辛壬癸子丑寅卯辰巳午未申酉戌亥\n",
        )
        b = _write(
            self.root / "task-package-quality.md",
            "U1. 主题甲在章程里的写法足够长以便与实现包比对相似度一二三四五六七八九十\n",
        )
        # Use charter that also has U1 matching b closely; compare a vs b
        r = self._run([a, b])
        self.assertIn("W3", r.stdout)

    def test_clean_sample_ok(self) -> None:
        pkg = _write(
            self.root / "task-package-impl.md",
            f"起点 HEAD 必须是 {self.start}\n"
            "运行 `kos-block.sh x y pkg params block commit=abc N=1`\n"
            "U1. 主题甲在章程里的写法足够长以便与实现包比对相似度一二三四五六七八九十\n",
        )
        r = self._run([pkg])
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
        self.assertIn("错误 0", r.stdout)


class BlockTests(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.pkg = _write(self.root / "pkg.md", "# package\n")

    def tearDown(self) -> None:
        self.tmp.cleanup()

    def _block(self, params: Path, block: Path, *, env: dict | None = None, extra: list[str] | None = None):
        args = [
            "Quinn",
            "步骤甲",
            str(self.pkg),
            str(params),
            str(block),
            "--next",
            "下一步：贴给 Quinn",
            f"executor_report_path={self.pkg}",
            "N=1",
            *(extra or []),
        ]
        return _run_bash("kos-block.sh", args, env=env)

    def test_three_line_block_and_params(self) -> None:
        params = self.root / "params.txt"
        block = self.root / "block.txt"
        r = self._block(params, block)
        self.assertEqual(r.returncode, 0, r.stderr)
        lines = block.read_text(encoding="utf-8").splitlines()
        self.assertEqual(len(lines), 3)
        self.assertIn("步骤甲", lines[0])
        self.assertIn(str(params), lines[1])
        self.assertIn("SHA-256", lines[1])
        self.assertEqual(lines[2], "授权，直接执行")
        ptxt = params.read_text(encoding="utf-8")
        self.assertIn("- package_path:", ptxt.splitlines()[1])
        self.assertIn("SHA-256", ptxt.splitlines()[1])
        self.assertIn(f"executor_report_path: {self.pkg}（SHA-256 {_sha(self.pkg)}）", ptxt)
        self.assertIn("- N: 1", ptxt)

    def test_refuse_overwrite_unless_force(self) -> None:
        params = self.root / "params2.txt"
        block = self.root / "block2.txt"
        params.write_text("old\n", encoding="utf-8")
        r = self._block(params, block)
        self.assertEqual(r.returncode, 3, r.stderr)
        self.assertIn("拒绝覆盖", r.stderr)
        env = os.environ.copy()
        env["KOS_BLOCK_FORCE"] = "1"
        r2 = self._block(params, block, env=env)
        self.assertEqual(r2.returncode, 0, r2.stderr)

    def test_lc_all_c_no_unbound(self) -> None:
        params = self.root / "params3.txt"
        block = self.root / "block3.txt"
        env = os.environ.copy()
        env["LC_ALL"] = "C"
        r = self._block(params, block, env=env)
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertNotIn("unbound", (r.stderr + r.stdout).lower())
        # trigger exists branch under LC_ALL=C
        r2 = self._block(params, block, env=env)
        self.assertEqual(r2.returncode, 3, r2.stderr)
        self.assertNotIn("unbound", (r2.stderr + r2.stdout).lower())
        self.assertIn("拒绝覆盖", r2.stderr)


class SignalsTests(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        self.home = Path(self.tmp.name)
        self.project = "Proj"
        self.root = self.home / self.project
        self.root.mkdir()
        self.env = _env(self.home, self.project)

    def tearDown(self) -> None:
        self.tmp.cleanup()

    def _seed(self) -> None:
        _write(
            self.root / "CAUSE-TAGS.tsv",
            "# 阶段|时间前缀|原因\n"
            "TASK-A|2026-11-09T10:00|PM包\n"
            "TASK-A|2026-11-09T11:00|PM包\n",
        )
        _write(
            self.root / "TASK-A" / "STAGE-LEDGER.md",
            "2026-11-09T10:00 | Lucy | STOPPED | /no.md | - | - | 升级 PM\n"
            "2026-11-09T11:00 | Lucy | FAIL | /no.md | - | - | 升级 PM\n"
            "2026-11-09T12:00 | Lucy | PARTIAL | /no.md | - | - | 升级 PM\n",
        )
        _write(self.root / "KOS-IMPROVEMENT-BACKLOG.md", "- 状态：待\n")

    def test_repeat_cause_and_untagged(self) -> None:
        self._seed()
        r = _run_py("kos-signals.py", [], env=self.env)
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertIn("重复原因", r.stdout)
        self.assertIn("未标原因的事件", r.stdout)
        self.assertIn("TASK-A 2026-11-09T12:00", r.stdout)

    def test_inbox_pending_increments(self) -> None:
        self._seed()
        r1 = _run_py("kos-signals.py", ["--inbox", "一条建议"], env=self.env)
        self.assertEqual(r1.returncode, 0)
        self.assertIn("已入收件箱", r1.stdout)
        r2 = _run_py("kos-signals.py", [], env=self.env)
        self.assertEqual(r2.returncode, 0)
        self.assertIn("收件箱待转 1 条", r2.stdout)
        r3 = _run_py("kos-signals.py", ["--inbox", "第二条"], env=self.env)
        self.assertEqual(r3.returncode, 0)
        r4 = _run_py("kos-signals.py", [], env=self.env)
        self.assertIn("收件箱待转 2 条", r4.stdout)


class CleanupTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        missing = [n for n in ("bash", "bc", "du") if not _which(n)]
        if missing:
            raise unittest.SkipTest(f"missing host tools: {', '.join(missing)}")

    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        self.home = Path(self.tmp.name)
        self.project = "Proj"
        self.root = self.home / self.project
        self.root.mkdir()
        self.env = _env(self.home, self.project)
        self.task = "TASK-CLEAN"
        d = self.root / self.task
        (d / "scratch" / "derived" / "obj").mkdir(parents=True)
        (d / "scratch" / "derived" / "Logs").mkdir(parents=True)
        (d / "scratch" / "tmp").mkdir(parents=True)
        (d / "reports").mkdir(parents=True)
        (d / "worktree").mkdir(parents=True)
        (d / "scratch" / "derived" / "obj" / "a.bin").write_text("bin", encoding="utf-8")
        (d / "scratch" / "derived" / "Logs" / "keep.log").write_text("log", encoding="utf-8")
        (d / "scratch" / "tmp" / "t.txt").write_text("tmp", encoding="utf-8")
        (d / "reports" / "r.md").write_text("report", encoding="utf-8")
        (d / "worktree" / "w.txt").write_text("wt", encoding="utf-8")

    def tearDown(self) -> None:
        self.tmp.cleanup()

    def test_default_dry_run_no_delete(self) -> None:
        r = _run_bash("kos-cleanup.sh", ["r", self.task], env=self.env)
        # dry-run ends with `[ $APPLY -eq 1 ] && …` so bash exit status is 1 when APPLY=0; behavior is still demo-only.
        self.assertIn(r.returncode, (0, 1), r.stderr + r.stdout)
        self.assertIn("将处理", r.stdout)
        self.assertTrue((self.root / self.task / "scratch" / "derived" / "obj" / "a.bin").exists())
        self.assertTrue((self.root / self.task / "reports" / "r.md").exists())

    def test_protected_rejected(self) -> None:
        # script creates KOS-CLEANUP-001/protected.txt on run; seed protection first via a probe run
        _run_bash("kos-cleanup.sh", ["report"], env=self.env)
        prot = self.root / "KOS-CLEANUP-001" / "protected.txt"
        prot.write_text(self.task + "\n", encoding="utf-8")
        r = _run_bash("kos-cleanup.sh", ["--apply", "r", self.task], env=self.env)
        self.assertEqual(r.returncode, 0, r.stderr + r.stdout)
        self.assertIn("受保护", r.stdout)
        self.assertTrue((self.root / self.task / "scratch" / "derived" / "obj" / "a.bin").exists())

    def test_apply_r_clears_class_a_keeps_logs_reports_worktree(self) -> None:
        r = _run_bash("kos-cleanup.sh", ["--apply", "r", self.task], env=self.env)
        self.assertEqual(r.returncode, 0, r.stderr + r.stdout)
        self.assertIn("已处理", r.stdout)
        self.assertFalse((self.root / self.task / "scratch" / "derived" / "obj").exists())
        self.assertTrue((self.root / self.task / "scratch" / "derived").is_dir())
        self.assertTrue((self.root / self.task / "scratch" / "derived" / "Logs" / "keep.log").exists())
        self.assertTrue((self.root / self.task / "reports" / "r.md").exists())
        self.assertTrue((self.root / self.task / "worktree" / "w.txt").exists())
        # tmp contents cleared, dir retained
        self.assertTrue((self.root / self.task / "scratch" / "tmp").is_dir())
        self.assertEqual(list((self.root / self.task / "scratch" / "tmp").iterdir()), [])


if __name__ == "__main__":
    unittest.main()
