"""KOS-DOCVERIFY-FAILTAG-001: doc_verify.sh failure exits carry a DOC_VERIFY_FAIL prefix."""
from __future__ import annotations

import os
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
VERIFY = ROOT / "scripts" / "kos" / "doc_verify.sh"
IDENTITY = "Cowork 3P <cowork-3p@localhost>"


def _git(repo: Path, *args: str) -> str:
    env = os.environ.copy()
    env.update({"GIT_AUTHOR_NAME": "Cowork 3P", "GIT_AUTHOR_EMAIL": "cowork-3p@localhost",
                "GIT_COMMITTER_NAME": "Cowork 3P", "GIT_COMMITTER_EMAIL": "cowork-3p@localhost",
                "GIT_CONFIG_GLOBAL": "/dev/null", "GIT_CONFIG_SYSTEM": "/dev/null", "GIT_AUTHOR_DATE": "2026-11-20T12:00:00+08:00",
                "GIT_COMMITTER_DATE": "2026-11-20T12:00:00+08:00"})
    result = subprocess.run(["git", "-C", str(repo), *args], capture_output=True, text=True, env=env)
    if result.returncode != 0:
        raise AssertionError(result.stderr)
    return result.stdout.strip()


def init_repo(tmp: Path, *, stub_check_markdown_links: bool = True) -> tuple[Path, str]:
    repo = tmp / "repo"
    repo.mkdir()
    stubs = {
        "scripts/ci/classify_changes.py": "# fixture stub\n",
        "scripts/ci/run_lightweight_checks.sh": "# fixture stub\n",
        "scripts/kos/check_identity.py": "# fixture stub\n",
        "scripts/kos/kos-report-lint.py": "# fixture stub\n",
        "scripts/ci/tests/test_verify_final_gate.sh": "#!/bin/sh\nexit 0\n",
        "scripts/ci/tests/test_kos_trigger_paths.sh": "#!/bin/sh\nexit 0\n",
        "scripts/ci/check_keyboard_values.py": (
            "import sys\nfrom pathlib import Path\n\n"
            "text = Path('docs/KEYBOARD_VALUES.md').read_text(encoding='utf-8')\n"
            "if 'KEYBOARD_VALUES' not in text:\n"
            "    print('KEYBOARD_VALUES_FAIL: fixture doc missing marker', file=sys.stderr)\n"
            "    sys.exit(1)\n"
            "print('KEYBOARD_VALUES_OK (fixture)')\n"
        ),
        "docs/KEYBOARD_VALUES.md": "# KEYBOARD_VALUES (fixture)\n",
    }
    if stub_check_markdown_links:
        stubs["scripts/ci/check_markdown_links.py"] = "# fixture stub\n"
    for rel, body in stubs.items():
        path = repo / rel
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(body, encoding="utf-8")
    for rel in ("scripts/ci/tests", "scripts/kos/tests"):
        (repo / rel).mkdir(parents=True, exist_ok=True)
        (repo / rel / "test_placeholder.py").write_text(
            "import unittest\n\n\nclass T(unittest.TestCase):\n    def test_ok(self):\n        pass\n",
            encoding="utf-8")
    (repo / ".kos").mkdir()
    (repo / ".kos" / "project.json").write_text("{}\n", encoding="utf-8")
    (repo / "a.txt").write_text("a\n", encoding="utf-8")
    _git(repo, "init", "-b", "main")
    _git(repo, "add", ".")
    _git(repo, "commit", "-qm", "base")
    base = _git(repo, "rev-parse", "HEAD")
    (repo / "report.md").write_text("DONE\nCole（Executor）；运行时身份 Codex。\n", encoding="utf-8")
    _git(repo, "add", ".")
    _git(repo, "commit", "-qm", "report")
    return repo, base


def run_verify(repo: Path, base: str):
    return subprocess.run(
        ["bash", str(VERIFY), base], cwd=str(repo), text=True, capture_output=True, check=False,
        env={"PATH": "/usr/bin:/bin:/usr/local/bin", "EXPECT_IDENTITY": IDENTITY,
             "GIT_CONFIG_GLOBAL": "/dev/null", "GIT_CONFIG_SYSTEM": "/dev/null"})


class DocVerifyFailTagTests(unittest.TestCase):
    def test_lightweight_failure_has_fail_prefix(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            repo, base = init_repo(Path(tmp), stub_check_markdown_links=False)
            result = run_verify(repo, base)
            self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertIn("DOC_VERIFY_FAIL:", result.stderr)
            self.assertIn("run_lightweight_checks failed", result.stderr)
            self.assertNotIn("DOC_VERIFY_PASS", result.stdout)

    def test_success_path_still_passes_without_fail_prefix(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            repo, base = init_repo(Path(tmp))
            result = run_verify(repo, base)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertIn("DOC_VERIFY_PASS", result.stdout)
            self.assertNotIn("DOC_VERIFY_FAIL", result.stdout)
            self.assertNotIn("DOC_VERIFY_FAIL", result.stderr)


if __name__ == "__main__":
    unittest.main()
