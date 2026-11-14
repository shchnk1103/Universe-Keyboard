"""Rolling handoff clause and interrupted-report checks."""
from __future__ import annotations

import importlib.util
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

KOS = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("freeze_rolling", KOS / "freeze.py")
FREEZE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(FREEZE)
MARKER = "INTERRUPTED-OR-RUNNING: report never finalised; use last update as start"


class RollingFreezeTests(unittest.TestCase):
    def test_commit_draft_requires_clause(self) -> None:
        self.assertIn("rolling handoff report clause", FREEZE.lint_problems("", requires_commit=True))

    def test_commit_draft_with_clause_has_no_clause_error(self) -> None:
        problems = FREEZE.lint_problems("滚动交接报告", requires_commit=True)
        self.assertNotIn("rolling handoff report clause", problems)

    def test_readonly_draft_does_not_require_clause(self) -> None:
        problems = FREEZE.lint_problems("", readonly=True)
        self.assertNotIn("rolling handoff report clause", problems)


class InterruptedReportTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory()
        self.task = Path(self.temp.name)
        (self.task / "reports").mkdir()
        (self.task / "scratch" / "nested").mkdir(parents=True)
        self.report = self.task / "reports" / "report.md"

    def tearDown(self) -> None:
        self.temp.cleanup()

    def run_report(self, *extra: str) -> subprocess.CompletedProcess:
        return subprocess.run(
            [sys.executable, "-I", str(KOS / "check_report.py"), str(self.report), *extra],
            capture_output=True, text=True, check=True,
        )

    def test_in_progress_marks_interruption_after_status(self) -> None:
        self.report.write_text("IN-PROGRESS\nLucy\n", encoding="utf-8")
        lines = self.run_report().stdout.splitlines()
        self.assertEqual(lines[:2], ["STATUS: IN-PROGRESS", MARKER])

    def test_done_output_is_unchanged(self) -> None:
        self.report.write_text("DONE\nLucy\n", encoding="utf-8")
        output = self.run_report().stdout
        self.assertNotIn(MARKER, output)
        self.assertTrue(output.startswith("STATUS: DONE\nIDENTITY: Lucy\n"))

    def test_worktree_lists_only_commits_and_logs_after_report(self) -> None:
        repo = self.task / "repo"
        repo.mkdir()
        env = os.environ.copy()
        env.update({"GIT_AUTHOR_NAME": "Test", "GIT_AUTHOR_EMAIL": "test@example.invalid",
                    "GIT_COMMITTER_NAME": "Test", "GIT_COMMITTER_EMAIL": "test@example.invalid"})

        def git(*args: str, timestamp: int | None = None) -> None:
            git_env = env.copy()
            if timestamp is not None:
                git_env.update({"GIT_AUTHOR_DATE": f"@{timestamp} +0000",
                                "GIT_COMMITTER_DATE": f"@{timestamp} +0000"})
            subprocess.run(["git", "-C", str(repo), *args], env=git_env,
                           capture_output=True, text=True, check=True)

        git("init", "-q")
        git("commit", "--allow-empty", "-qm", "old entry", timestamp=1_600_000_000)
        git("commit", "--allow-empty", "-qm", "new entry", timestamp=1_600_000_020)
        self.report.write_text("IN-PROGRESS\nLucy\n", encoding="utf-8")
        os.utime(self.report, (1_600_000_010, 1_600_000_010))
        old = self.task / "scratch" / "old.log"
        new = self.task / "scratch" / "nested" / "new.log"
        old.write_text("old", encoding="utf-8")
        new.write_text("new", encoding="utf-8")
        os.utime(old, (1_600_000_000, 1_600_000_000))
        os.utime(new, (1_600_000_020, 1_600_000_020))
        output = self.run_report("--worktree", str(repo)).stdout
        self.assertIn(MARKER, output)
        self.assertIn("new entry", output)
        self.assertNotIn("old entry", output)
        self.assertIn("nested/new.log", output)
        self.assertNotIn("old.log", output)


if __name__ == "__main__":
    unittest.main()
