"""Tests for KOS-TOOLS-007 impact, run and verify-inputs tools. Stdlib only."""
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
PY = sys.executable


def _run(args: list[str], *, cwd: Path | None = None, env: dict | None = None):
    return subprocess.run(args, capture_output=True, text=True, cwd=cwd, env=env)


def _git(repo: Path, *args: str) -> None:
    env = os.environ.copy()
    env.update({"GIT_AUTHOR_NAME": "t", "GIT_AUTHOR_EMAIL": "t@t.t",
                "GIT_COMMITTER_NAME": "t", "GIT_COMMITTER_EMAIL": "t@t.t"})
    result = subprocess.run(["git", "-C", str(repo), *args], capture_output=True, text=True, env=env)
    if result.returncode != 0:
        raise AssertionError(result.stderr)


class ImpactTests(unittest.TestCase):
    def setUp(self) -> None:
        if shutil.which("git") is None:
            self.skipTest("git missing")
        self.tmp = tempfile.TemporaryDirectory()
        self.repo = Path(self.tmp.name)
        _git(self.repo, "init", "-q")
        (self.repo / "a.txt").write_text("alpha alpha\n", encoding="utf-8")
        (self.repo / "b.txt").write_text("beta\n", encoding="utf-8")
        _git(self.repo, "add", ".")
        _git(self.repo, "commit", "-qm", "seed")

    def tearDown(self) -> None:
        self.tmp.cleanup()

    def test_classifies_and_orders_allowed_first(self) -> None:
        result = _run([PY, "-B", str(KOS / "kos-impact.py"), "--repo", str(self.repo),
                       "--term", "alpha", "--term", "missing",
                       "--allowed", "a.txt", "--later", "b.txt"])
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("TERM alpha: 1 hits in 1 files", result.stdout)
        self.assertLess(result.stdout.index("ALLOWED a.txt"), result.stdout.index("UNCLASSIFIED: none"))

    def test_unclassified_exits_one(self) -> None:
        result = _run([PY, "-B", str(KOS / "kos-impact.py"), "--repo", str(self.repo), "--term", "beta"])
        self.assertEqual(result.returncode, 1)
        self.assertIn("UNCLASSIFIED b.txt", result.stdout)

    def test_ref_reads_commit_not_worktree(self) -> None:
        (self.repo / "a.txt").write_text("gone\n", encoding="utf-8")
        work = _run([PY, "-B", str(KOS / "kos-impact.py"), "--repo", str(self.repo), "--term", "alpha"])
        head = _run([PY, "-B", str(KOS / "kos-impact.py"), "--repo", str(self.repo),
                     "--ref", "HEAD", "--term", "alpha", "--allowed", "a.txt"])
        self.assertNotIn("ALLOWED a.txt", work.stdout)
        self.assertEqual(head.returncode, 0)
        self.assertIn("ALLOWED a.txt (1)", head.stdout)

    def test_bad_repo_exits_two(self) -> None:
        result = _run([PY, "-B", str(KOS / "kos-impact.py"), "--repo", str(self.repo / "nope"), "--term", "x"])
        self.assertEqual(result.returncode, 2)


class RunTests(unittest.TestCase):
    def setUp(self) -> None:
        if shutil.which("bash") is None or shutil.which("git") is None:
            self.skipTest("bash or git missing")
        self.tmp = tempfile.TemporaryDirectory()
        self.repo = Path(self.tmp.name)
        _git(self.repo, "init", "-q")
        (self.repo / "f").write_text("x\n", encoding="utf-8")
        _git(self.repo, "add", "f")
        _git(self.repo, "commit", "-qm", "seed")

    def tearDown(self) -> None:
        self.tmp.cleanup()

    def test_existing_log_is_not_overwritten(self) -> None:
        log = self.repo / "run.log"
        log.write_text("keep\n", encoding="utf-8")
        result = _run(["bash", str(KOS / "kos-run.sh"), "--log", str(log), "--cwd", str(self.repo), "--", "echo", "no"])
        self.assertEqual(result.returncode, 3)
        self.assertEqual(log.read_text(encoding="utf-8"), "keep\n")

    def test_first_line_is_shell_quoted(self) -> None:
        log = self.repo / "quoted.log"
        args = ["echo", "a b", "c'd"]
        result = _run(["bash", str(KOS / "kos-run.sh"), "--log", str(log), "--cwd", str(self.repo), "--", *args])
        self.assertEqual(result.returncode, 0, result.stderr)
        expected = subprocess.run(["bash", "-c", 'printf "%q " "$@"', "bash", *args], capture_output=True, text=True)
        self.assertEqual(log.read_text(encoding="utf-8").splitlines()[0], expected.stdout.rstrip())

    def test_env_and_exit_code(self) -> None:
        log = self.repo / "exit.log"
        env = os.environ.copy()
        env["LC_ALL"] = "C"
        result = _run(["bash", str(KOS / "kos-run.sh"), "--log", str(log), "--cwd", str(self.repo),
                       "--env", "FOO=bar", "--", "bash", "-c", 'printf "%s\\n" "$FOO"; exit 7'], env=env)
        self.assertEqual(result.returncode, 7)
        lines = log.read_text(encoding="utf-8").splitlines()
        self.assertIn("bar", lines)
        self.assertEqual(lines[-2], "EXIT:7")


class VerifyTests(unittest.TestCase):
    def test_ok_mismatch_missing_skip_and_placeholders(self) -> None:
        tmp = tempfile.TemporaryDirectory()
        root = Path(tmp.name)
        good = root / "good.txt"
        bad = root / "bad.txt"
        folder = root / "dir"
        good.write_text("yes\n", encoding="utf-8")
        bad.write_text("no\n", encoding="utf-8")
        folder.mkdir()
        digest = subprocess.run(["shasum", "-a", "256", str(good)], capture_output=True, text=True).stdout.split()[0]
        wrong = "0" * 64
        package = root / "pkg.md"
        package.write_text(
            f"good `{good}` SHA-256 `{digest}`\n"
            f"bad `{bad}` SHA-256 `{wrong}`\n"
            f"gone `{root / 'gone.txt'}` SHA-256 `{wrong}`\n"
            f"dir `{folder}` SHA-256 `{wrong}`\n"
            "placeholder `</path/to/file>` SHA-256 `aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa`\n",
            encoding="utf-8",
        )
        result = _run([PY, "-B", str(KOS / "kos-verify-inputs.py"), str(package)])
        self.assertEqual(result.returncode, 1)
        self.assertIn(f"OK {digest[:8]} {good}", result.stdout)
        self.assertIn("MISMATCH", result.stdout)
        self.assertIn("MISSING", result.stdout)
        self.assertIn("SKIP", result.stdout)
        self.assertNotIn("aaaaaaaa", result.stdout)
        self.assertIn("SUMMARY ok=1 mismatch=1 missing=1 skip=1", result.stdout)
        tmp.cleanup()

    def test_truncated_hex_fails_closed(self) -> None:
        tmp = tempfile.TemporaryDirectory()
        root = Path(tmp.name)
        truncated = "ab" * 29  # 58 chars: a hand-copied truncated SHA-256
        package = root / "pkg.md"
        package.write_text(f"target `{root / 'f.txt'}` SHA-256 `{truncated}`\n", encoding="utf-8")
        result = _run([PY, "-B", str(KOS / "kos-verify-inputs.py"), str(package)])
        self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
        self.assertIn("BADLEN len=58", result.stdout)
        self.assertIn("SUMMARY ok=0 mismatch=0 missing=0 skip=0 badlen=1", result.stdout)
        tmp.cleanup()

    def test_overlong_hex_fails_closed(self) -> None:
        tmp = tempfile.TemporaryDirectory()
        root = Path(tmp.name)
        overlong = "cd" * 33  # 66 chars: overlong hex run
        package = root / "pkg.md"
        package.write_text(f"target `{root / 'f.txt'}` SHA-256 `{overlong}`\n", encoding="utf-8")
        result = _run([PY, "-B", str(KOS / "kos-verify-inputs.py"), str(package)])
        self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
        self.assertIn("BADLEN len=66", result.stdout)
        self.assertIn("badlen=1", result.stdout)
        tmp.cleanup()

    def test_valid_64_and_git40_are_not_flagged(self) -> None:
        tmp = tempfile.TemporaryDirectory()
        root = Path(tmp.name)
        target = root / "real.txt"
        target.write_text("payload\n", encoding="utf-8")
        digest = subprocess.run(["shasum", "-a", "256", str(target)],
                                capture_output=True, text=True).stdout.split()[0]
        git_sha = "0123456789abcdef0123456789abcdef01234567"  # 40-char commit SHA
        package = root / "pkg.md"
        package.write_text(
            f"file `{target}` SHA-256 `{digest}`\n"
            f"commit `{root / 'log.md'}` HEAD `{git_sha}`\n",
            encoding="utf-8",
        )
        result = _run([PY, "-B", str(KOS / "kos-verify-inputs.py"), str(package)])
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn(f"OK {digest[:8]} {target}", result.stdout)
        self.assertNotIn("BADLEN", result.stdout)
        self.assertIn("badlen=0", result.stdout)
        tmp.cleanup()


if __name__ == "__main__":
    unittest.main()


class CheckReportAuditTests(unittest.TestCase):
    """KOS-REPORT-AUDIT-001 (O67): check_report resolves logs/packets/scratch,
    parses Markdown-table hash pairs, auto-mounts <task>/worktree, prints changed_files."""

    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        self.task = Path(self.tmp.name) / "TASK-AUDIT"
        (self.task / "reports").mkdir(parents=True)
        (self.task / "logs").mkdir(parents=True)
        (self.task / "packets").mkdir(parents=True)
        (self.task / "scratch").mkdir(parents=True)
        log = self.task / "logs" / "sample.log"
        log.write_text("COMMAND echo hi\nEXIT: 0\n", encoding="utf-8")
        log_sha = hashlib.sha256(log.read_bytes()).hexdigest()
        pkg = self.task / "packets" / "pkg.md"
        pkg.write_text("# pkg\n", encoding="utf-8")
        pkg_sha = hashlib.sha256(pkg.read_bytes()).hexdigest()
        self.report = self.task / "reports" / "executor-report-r1.md"
        self.report.write_text(
            "DONE\n"
            "Lucy（Executor（代码））；运行时身份 Test。\n"
            f"\n日志日志 logs/sample.log SHA-256 `{log_sha}`\n"
            "\n| 文件 | SHA-256 |\n|---|---|\n"
            f"| sample.log | `{log_sha}` |\n"
            f"| pkg.md | `{pkg_sha}` |\n",
            encoding="utf-8")
        self.log_sha = log_sha
        self.pkg_sha = pkg_sha

    def tearDown(self) -> None:
        self.tmp.cleanup()

    def _init_git_worktree(self) -> Path:
        import subprocess as sp
        repo = Path(self.tmp.name) / "seed"
        repo.mkdir()
        env = {**os.environ, "GIT_AUTHOR_NAME": "t", "GIT_AUTHOR_EMAIL": "t@t",
               "GIT_COMMITTER_NAME": "t", "GIT_COMMITTER_EMAIL": "t@t"}
        def g(*a, cwd=None):
            sp.run(["git", "-C", str(cwd or repo), *a], check=True, capture_output=True, env=env)
        g("init", "-q")
        (repo / "f.txt").write_text("v1\n", encoding="utf-8")
        g("add", ".")
        g("commit", "-qm", "base")
        base = sp.run(["git", "-C", str(repo), "rev-parse", "HEAD"], capture_output=True, text=True).stdout.strip()
        (repo / "f.txt").write_text("v2\n", encoding="utf-8")
        g("add", ".")
        g("commit", "-qm", "head")
        wt = self.task / "worktree"
        sp.run(["git", "-C", str(repo), "worktree", "add", "-q", str(wt), "HEAD"], check=True, capture_output=True)
        sp.run(["git", "-C", str(wt), "checkout", "-q", "-b", "feat/x"], check=True, capture_output=True)
        return Path(base)

    def test_table_hash_pairs_and_subdir_resolution(self) -> None:
        r = _run([PY, "-B", str(KOS / "check_report.py"), str(self.report)])
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
        self.assertIn(f"OK       sample.log", r.stdout)
        self.assertIn(f"OK       pkg.md", r.stdout)
        self.assertNotIn("MISSING", r.stdout)
        # logs section should find the log relative to the logs/ subdir too
        self.assertIn("logs/sample.log", r.stdout)

    def test_auto_worktree_mount_and_changed_files(self) -> None:
        base = self._init_git_worktree()
        r = _run([PY, "-B", str(KOS / "check_report.py"), str(self.report), "--base", base])
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
        self.assertIn("== worktree", r.stdout)
        self.assertIn("HEAD", r.stdout)
        self.assertIn("changed_files", r.stdout)
        self.assertIn("f.txt", r.stdout)
