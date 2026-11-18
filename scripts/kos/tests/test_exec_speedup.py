"""Tests for KOS-EXEC-SPEEDUP-001: kos_handoff final and doc_verify.sh. Stdlib only."""
import hashlib
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SCRIPT = ROOT / "scripts/kos/kos_handoff.py"
VERIFY = ROOT / "scripts/kos/doc_verify.sh"
IDENTITY = "Cowork 3P <cowork-3p@localhost>"

VERIFY_ENV_BASE = {"PATH": "/usr/bin:/bin:/usr/local/bin"}

def run_handoff(*args):
    return subprocess.run(
        [sys.executable, "-I", str(SCRIPT), *args], text=True, capture_output=True, check=False)

def init_repo(tmp: Path, status_line: str):
    repo = tmp / "repo"
    repo.mkdir()
    stubs = {
        "scripts/ci/classify_changes.py": "# fixture stub\n",
        "scripts/ci/run_lightweight_checks.sh": "# fixture stub\n",
        "scripts/ci/check_markdown_links.py": "# fixture stub\n",
        "scripts/kos/check_identity.py": "# fixture stub\n",
        "scripts/kos/kos-report-lint.py": "# fixture stub\n",
        "scripts/ci/tests/test_verify_final_gate.sh": "#!/bin/sh\nexit 0\n",
        "scripts/ci/tests/test_kos_trigger_paths.sh": "#!/bin/sh\nexit 0\n",
    }
    for rel, body in stubs.items():
        path = repo / rel
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(body)
    for rel in ["scripts/ci/tests", "scripts/kos/tests"]:
        (repo / rel).mkdir(parents=True, exist_ok=True)
        (repo / rel / "test_placeholder.py").write_text(
            "import unittest\n\n\nclass T(unittest.TestCase):\n    def test_placeholder(self):\n        pass\n")
    env = {"GIT_AUTHOR_NAME": IDENTITY.split(" <")[0], "GIT_AUTHOR_EMAIL": "cowork-3p@localhost",
           "GIT_COMMITTER_NAME": IDENTITY.split(" <")[0], "GIT_COMMITTER_EMAIL": "cowork-3p@localhost",
           "GIT_CONFIG_GLOBAL": "/dev/null", "GIT_CONFIG_SYSTEM": "/dev/null"}
    def git(*args):
        return subprocess.run(["git", "-C", str(repo), *args], text=True,
                              capture_output=True, check=True, env=env)
    git("init", "-b", "main")
    (repo / ".kos").mkdir()
    (repo / ".kos" / "project.json").write_text("{}")
    (repo / "a.txt").write_text("a\n")
    git("add", ".")
    git("commit", "-m", "base")
    base = git("rev-parse", "HEAD").stdout.strip()
    report = repo / "report.md"
    report.write_text(f"{status_line}\nCole（Executor）；运行时身份 Codex。\n")
    git("add", ".")
    git("commit", "-m", "report")
    head = git("rev-parse", "HEAD").stdout.strip()
    return repo, base, report, head

class FinalCommandTests(unittest.TestCase):
    def test_final_prints_status_realpath_and_sha(self):
        with tempfile.TemporaryDirectory() as tmp:
            _, _, report, _ = init_repo(Path(tmp), "DONE")
            before = report.read_bytes()
            result = run_handoff("final", "--report", str(report))
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            expected_sha = hashlib.sha256(before).hexdigest()
            self.assertIn(f"结论：DONE", result.stdout)
            self.assertIn(f"报告：{report.resolve()}（SHA-256 {expected_sha}）", result.stdout)
            self.assertIn("```text", result.stdout)
            self.assertEqual(report.read_bytes(), before)

    def test_final_reads_status_from_report_first_line(self):
        with tempfile.TemporaryDirectory() as tmp:
            _, _, report, _ = init_repo(Path(tmp), "PARTIAL")
            result = run_handoff("final", "--report", str(report))
            self.assertIn("结论：PARTIAL", result.stdout)

    def test_final_lint_failure_returns_nonzero(self):
        with tempfile.TemporaryDirectory() as tmp:
            _, _, report, _ = init_repo(Path(tmp), "NOT-A-STATUS")
            result = run_handoff("final", "--report", str(report))
            self.assertNotEqual(result.returncode, 0)
            self.assertNotIn(str(report), result.stdout)

    def test_final_skip_lint_bypasses_check_only(self):
        with tempfile.TemporaryDirectory() as tmp:
            _, _, report, _ = init_repo(Path(tmp), "NOT-A-STATUS")
            result = run_handoff("final", "--report", str(report), "--skip-lint")
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_render_still_works(self):
        with tempfile.TemporaryDirectory() as tmp:
            _, _, report, _ = init_repo(Path(tmp), "PASS")
            result = run_handoff("render", "--status", "PASS", "--summary", "ok",
                                 "--next-role", "Jack（PM）", "--report-path", str(report))
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertIn("结论：", result.stdout)

class DocVerifyTests(unittest.TestCase):
    def test_doc_verify_passes_on_clean_repo(self):
        with tempfile.TemporaryDirectory() as tmp:
            repo, base, report, head = init_repo(Path(tmp), "DONE")
            result = subprocess.run(
                ["bash", str(VERIFY), base], cwd=str(repo), text=True,
                capture_output=True, check=False,
                env={"PATH": "/usr/bin:/bin:/usr/local/bin", "EXPECT_IDENTITY": IDENTITY,
                     "GIT_CONFIG_GLOBAL": "/dev/null", "GIT_CONFIG_SYSTEM": "/dev/null"})
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertIn("DOC_VERIFY_PASS", result.stdout)

    def test_doc_verify_fails_on_dirty_worktree(self):
        with tempfile.TemporaryDirectory() as tmp:
            repo, base, _, head = init_repo(Path(tmp), "DONE")
            (repo / "b.txt").write_text("b\n")
            result = subprocess.run(
                ["bash", str(VERIFY), base], cwd=str(repo), text=True,
                capture_output=True, check=False,
                env={"PATH": "/usr/bin:/bin:/usr/local/bin", "EXPECT_IDENTITY": IDENTITY,
                     "GIT_CONFIG_GLOBAL": "/dev/null", "GIT_CONFIG_SYSTEM": "/dev/null"})
            self.assertNotEqual(result.returncode, 0)

if __name__ == "__main__":
    unittest.main()


class FinalThreeLineTests(unittest.TestCase):
    def _report_with_relay(self, tmp: Path, status: str, next_role: str | None, next_step: str | None = None):
        repo, _, report, _ = init_repo(tmp, status)
        relay = "## 下一站接力（O41）\n"
        if next_role:
            relay += f"next_role: {next_role}\n"
        if next_step:
            relay += f"next_step: {next_step}\n"
        report.write_text(report.read_text(encoding="utf-8") + relay, encoding="utf-8")
        return report

    def test_final_renders_three_line_with_report_next_role(self):
        with tempfile.TemporaryDirectory() as tmp:
            report = self._report_with_relay(Path(tmp), "DONE", "Quinn（Quality）", "请复核")
            before = report.read_bytes()
            result = run_handoff("final", "--report", str(report))
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertIn("结论：DONE", result.stdout)
            self.assertIn("下一位交付：Quinn（Quality）", result.stdout)
            self.assertIn("报告：", result.stdout)
            self.assertIn(hashlib.sha256(before).hexdigest(), result.stdout)
            self.assertIn("```text", result.stdout)
            self.assertIn(f"交回：Quinn（Quality）", result.stdout)
            self.assertEqual(report.read_bytes(), before)

    def test_final_defaults_to_pm_when_no_next_role(self):
        with tempfile.TemporaryDirectory() as tmp:
            # No relay section at all: lint allows it and final falls back to PM.
            _, _, report, _ = init_repo(Path(tmp), "PARTIAL")
            result = run_handoff("final", "--report", str(report))
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertIn("下一位交付：Jack（PM）", result.stdout)

    def test_final_explicit_next_role_overrides_report(self):
        with tempfile.TemporaryDirectory() as tmp:
            report = self._report_with_relay(Path(tmp), "DONE", "Quinn（Quality）")
            result = run_handoff("final", "--report", str(report), "--next-role", "Alex（Architecture）")
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertIn("下一位交付：Alex（Architecture）", result.stdout)

    def test_final_respects_status_flag(self):
        with tempfile.TemporaryDirectory() as tmp:
            report = self._report_with_relay(Path(tmp), "DONE", "Quinn（Quality）")
            result = run_handoff("final", "--report", str(report), "--status", "PARTIAL")
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertIn("结论：PARTIAL", result.stdout)
