#!/usr/bin/env python3
"""O129-KOS-RELAY-DEPT-AND-CIWATCH-001: ci_watch.sh syntax, validation and polling states.

ci_watch.sh 是参数化 CI 监督脚本：不写死仓库/PR/run ID，用假 gh 桩驱动
queued/completed/PR 终态与超时分支，全部经 PATH 注入，不触网。
"""
import os
import subprocess
import tempfile
import unittest
from pathlib import Path

KOS_DIR = Path(__file__).resolve().parent.parent
SCRIPT = KOS_DIR / "ci_watch.sh"


def _run(args, env=None, cwd=None):
    merged = dict(os.environ)
    merged["PYTHONDONTWRITEBYTECODE"] = "1"
    if env:
        merged.update(env)
    return subprocess.run(["bash", str(SCRIPT), *args], capture_output=True, text=True,
                          env=merged, cwd=cwd, timeout=60)


class CiWatchSyntaxTests(unittest.TestCase):
    def test_bash_n_syntax_check_passes(self) -> None:
        result = subprocess.run(["bash", "-n", str(SCRIPT)], capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_script_is_executable(self) -> None:
        self.assertTrue(os.access(SCRIPT, os.X_OK), "ci_watch.sh must be chmod +x")


class CiWatchValidationTests(unittest.TestCase):
    def test_missing_repo_fails_with_usage(self) -> None:
        result = _run(["--run", "123"])
        self.assertEqual(result.returncode, 4, result.stdout + result.stderr)
        self.assertIn("--repo", result.stdout + result.stderr)

    def test_missing_run_fails_with_usage(self) -> None:
        result = _run(["--repo", "owner/name"])
        self.assertEqual(result.returncode, 4, result.stdout + result.stderr)
        self.assertIn("--run", result.stdout + result.stderr)

    def test_unknown_flag_fails(self) -> None:
        result = _run(["--repo", "owner/name", "--run", "1", "--bogus", "x"])
        self.assertEqual(result.returncode, 4)

    def test_non_integer_interval_fails(self) -> None:
        result = _run(["--repo", "owner/name", "--run", "1", "--interval", "abc"])
        self.assertEqual(result.returncode, 4)
        self.assertIn("interval", result.stdout + result.stderr)

    def test_non_integer_timeout_fails(self) -> None:
        result = _run(["--repo", "owner/name", "--run", "1", "--timeout", "1.5"])
        self.assertEqual(result.returncode, 4)

    def test_non_integer_queued_limit_fails(self) -> None:
        result = _run(["--repo", "owner/name", "--run", "1", "--queued-limit-min", "-3"])
        self.assertEqual(result.returncode, 4)

    def test_help_exits_zero(self) -> None:
        result = _run(["--help"])
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("--queued-limit-min", result.stdout)


class _FakeGhMixin(unittest.TestCase):
    """Inject a fake `gh` via PATH; state files drive each poll's answer."""

    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.run_state = self.root / "run-state.txt"
        self.pr_state = self.root / "pr-state.txt"
        self.run_state.write_text("queued\n", encoding="utf-8")
        self.pr_state.write_text("OPEN\n", encoding="utf-8")
        gh = self.root / "gh"
        gh.write_text(
            "#!/bin/bash\n"
            'if [ "$1" = "run" ]; then\n'
            '  state=$(cat "$FAKE_GH_RUN_STATE")\n'
            '  case "$*" in\n'
            '    *"--json status,conclusion"*)\n'
            '      if [ "$state" = "completed" ]; then\n'
            '        echo "completed success"\n'
            '      else\n'
            '        echo "$state -"\n'
            '      fi ;;\n'
            '    *"--json jobs"*)\n'
            '      if [ "$state" = "completed" ]; then\n'
            '        printf "build => success\\ntest => success\\n"\n'
            '      else\n'
            '        printf "build => -\\n"\n'
            '      fi ;;\n'
            "  esac\n"
            'elif [ "$1" = "pr" ]; then\n'
            '  cat "$FAKE_GH_PR_STATE"\n'
            "else\n"
            "  exit 64\n"
            "fi\n",
            encoding="utf-8")
        gh.chmod(0o755)
        self.env = {
            "PATH": f"{self.root}:{os.environ.get('PATH', '')}",
            "FAKE_GH_RUN_STATE": str(self.run_state),
            "FAKE_GH_PR_STATE": str(self.pr_state),
        }

    def tearDown(self) -> None:
        self.tmp.cleanup()


class CiWatchPollingTests(_FakeGhMixin):
    def test_completed_run_reports_terminal_and_jobs_exit_0(self) -> None:
        self.run_state.write_text("completed\n", encoding="utf-8")
        result = _run(["--repo", "owner/name", "--run", "42", "--interval", "1",
                       "--timeout", "30"], env=self.env)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("RUN_TERMINAL", result.stdout)
        self.assertIn("conclusion=success", result.stdout)
        self.assertIn("build => success", result.stdout)
        self.assertIn("test => success", result.stdout)

    def test_queued_beyond_limit_emits_waiting_ci_exit_3(self) -> None:
        result = _run(["--repo", "owner/name", "--run", "42", "--interval", "1",
                       "--timeout", "30", "--queued-limit-min", "0"], env=self.env)
        self.assertEqual(result.returncode, 3, result.stdout + result.stderr)
        self.assertIn("WAITING_CI", result.stdout)

    def test_queued_below_limit_then_completed_exits_0(self) -> None:
        # First poll queued (no WAITING_CI because limit not reached after
        # reset), second poll completed.
        flips = self.root / "flips"
        flips.write_text("2\n", encoding="utf-8")
        gh = self.root / "gh"
        gh.write_text(
            "#!/bin/bash\n"
            'if [ "$1" = "run" ]; then\n'
            '  case "$*" in\n'
            '    *"--json status,conclusion"*)\n'
            '      n=$(cat "$FAKE_GH_FLIPS")\n'
            '      if [ "$n" -gt 0 ]; then\n'
            '        echo "$n" | tee "$FAKE_GH_FLIPS" > /dev/null\n'
            '        n=$((n - 1))\n'
            '        echo "$n" > "$FAKE_GH_FLIPS"\n'
            '        echo "in_progress -"\n'
            '      else\n'
            '        echo "completed success"\n'
            '      fi ;;\n'
            '    *"--json jobs"*) printf "build => success\\n" ;;\n'
            "  esac\n"
            "fi\n",
            encoding="utf-8")
        gh.chmod(0o755)
        env = dict(self.env)
        env["FAKE_GH_FLIPS"] = str(flips)
        result = _run(["--repo", "owner/name", "--run", "42", "--interval", "1",
                       "--timeout", "30"], env=env)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("RUN_TERMINAL", result.stdout)

    def test_timeout_emits_budget_exhausted_exit_2(self) -> None:
        self.run_state.write_text("in_progress\n", encoding="utf-8")
        result = _run(["--repo", "owner/name", "--run", "42", "--interval", "1",
                       "--timeout", "1"], env=self.env)
        self.assertEqual(result.returncode, 2, result.stdout + result.stderr)
        self.assertIn("BUDGET_EXHAUSTED", result.stdout)

    def test_pr_terminal_state_exits_0(self) -> None:
        self.run_state.write_text("in_progress\n", encoding="utf-8")
        self.pr_state.write_text("MERGED\n", encoding="utf-8")
        result = _run(["--repo", "owner/name", "--run", "42", "--pr", "7",
                       "--interval", "1", "--timeout", "30"], env=self.env)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("PR_TERMINAL", result.stdout)
        self.assertIn("MERGED", result.stdout)


if __name__ == "__main__":
    unittest.main()
