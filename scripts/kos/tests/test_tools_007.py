"""Tests for KOS-TOOLS-007 impact, run and verify-inputs tools. Stdlib only."""
from __future__ import annotations

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


if __name__ == "__main__":
    unittest.main()
