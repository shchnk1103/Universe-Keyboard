"""Tests for KOS-GATE-DEDUP-001: kos_gate.py single gate wrapper + dedup cache. Stdlib only."""
from __future__ import annotations

import json
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

KOS = Path(__file__).resolve().parents[1]
PY = sys.executable

STUB = """#!/usr/bin/env bash
# stub doc_verify: counts invocations, optional forced failure
echo "COUNT=$(cat "$COUNT_FILE" 2>/dev/null || echo 0)" >/dev/null
n=$(cat "$COUNT_FILE" 2>/dev/null || echo 0)
echo $((n + 1)) > "$COUNT_FILE"
echo "stub doc_verify ran with base=$1"
if [ -f "$FAIL_FILE" ]; then
  echo "stub forced failure" >&2
  exit 3
fi
echo "DOC_VERIFY_PASS head=stubbed"
exit 0
"""


def _git(repo: Path, *args: str, env: dict | None = None) -> str:
    r = subprocess.run(["git", "-C", str(repo), *args], capture_output=True, text=True, env=env)
    assert r.returncode == 0, r.stdout + r.stderr
    return r.stdout.strip()


class KosGateTests(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.repo = self.root / "repo"
        (self.repo / "scripts" / "kos").mkdir(parents=True)
        env = {**os.environ, "GIT_AUTHOR_NAME": "t", "GIT_AUTHOR_EMAIL": "t@t",
               "GIT_COMMITTER_NAME": "t", "GIT_COMMITTER_EMAIL": "t@t"}
        _git(self.repo, "init", "-q", env=env)
        (self.repo / "f.txt").write_text("v1\n", encoding="utf-8")
        _git(self.repo, "add", ".", env=env)
        _git(self.repo, "commit", "-qm", "base", env=env)
        self.base = _git(self.repo, "rev-parse", "HEAD", env=env)
        (self.repo / "g.txt").write_text("v2\n", encoding="utf-8")
        self.stub = self.repo / "scripts" / "kos" / "stub_doc_verify.sh"
        self.stub.write_text(STUB, encoding="utf-8")
        self.stub.chmod(0o755)
        _git(self.repo, "add", ".", env=env)
        _git(self.repo, "commit", "-qm", "head", env=env)
        self.cache = self.root / "gate-cache"
        self.count_file = self.root / "count"
        self.fail_file = self.root / "fail"
        self.stub = self.repo / "scripts" / "kos" / "stub_doc_verify.sh"

    def tearDown(self) -> None:
        self.tmp.cleanup()

    def _run(self, mode: str = "executor", *extra: str) -> subprocess.CompletedProcess:
        env = {**os.environ,
               "COUNT_FILE": str(self.count_file),
               "FAIL_FILE": str(self.fail_file)}
        return subprocess.run(
            [PY, "-B", str(KOS / "kos_gate.py"),
             "--worktree", str(self.repo), "--base", self.base,
             "--mode", mode, "--cache-dir", str(self.cache),
             "--doc-verify", str(self.stub), *extra],
            capture_output=True, text=True, env=env,
        )

    def _count(self) -> int:
        return int(self.count_file.read_text().strip()) if self.count_file.exists() else 0

    def test_first_run_pass_then_cache_hit(self) -> None:
        r1 = self._run()
        self.assertEqual(r1.returncode, 0, r1.stdout + r1.stderr)
        self.assertIn("GATE_PASS", r1.stdout)
        self.assertEqual(self._count(), 1)
        r2 = self._run()
        self.assertEqual(r2.returncode, 0, r2.stdout + r2.stderr)
        self.assertIn("GATE_CACHED", r2.stdout)
        self.assertEqual(self._count(), 1)
        # structured summary is present on both runs
        for r in (r1, r2):
            self.assertIn('"mode": "executor"', r.stdout)
            self.assertIn('"base_sha"', r.stdout)
            self.assertIn('"head_sha"', r.stdout)
            self.assertIn('"tree_sha"', r.stdout)
            self.assertIn('"porcelain_clean": true', r.stdout)

    def test_quality_mode_never_hits_executor_cache(self) -> None:
        r1 = self._run("executor")
        self.assertEqual(r1.returncode, 0, r1.stdout + r1.stderr)
        r2 = self._run("quality")
        self.assertEqual(r2.returncode, 0, r2.stdout + r2.stderr)
        self.assertIn("GATE_PASS", r2.stdout)
        self.assertNotIn("GATE_CACHED", r2.stdout)
        self.assertEqual(self._count(), 2)
        # and back to executor: still cached
        r3 = self._run("executor")
        self.assertIn("GATE_CACHED", r3.stdout)
        self.assertEqual(self._count(), 2)

    def test_dirty_worktree_and_tree_change_miss_cache(self) -> None:
        r1 = self._run()
        self.assertEqual(r1.returncode, 0, r1.stdout + r1.stderr)
        # dirty worktree: untracked file (outside the vendor allowlist)
        (self.repo / "dirty.txt").write_text("d\n", encoding="utf-8")
        r2 = self._run()
        self.assertNotEqual(r2.returncode, 0, r2.stdout + r2.stderr)
        (self.repo / "dirty.txt").unlink()
        # tree change: new commit
        env = {**os.environ, "GIT_AUTHOR_NAME": "t", "GIT_AUTHOR_EMAIL": "t@t",
               "GIT_COMMITTER_NAME": "t", "GIT_COMMITTER_EMAIL": "t@t"}
        (self.repo / "g.txt").write_text("v3\n", encoding="utf-8")
        _git(self.repo, "add", ".", env=env)
        _git(self.repo, "commit", "-qm", "head2", env=env)
        r3 = self._run()
        self.assertEqual(r3.returncode, 0, r3.stdout + r3.stderr)
        self.assertIn("GATE_PASS", r3.stdout)
        self.assertEqual(self._count(), 2)

    def test_vendor_symlink_dirty_allowed(self) -> None:
        r1 = self._run()
        self.assertEqual(r1.returncode, 0, r1.stdout + r1.stderr)
        vendor = self.repo / "Packages" / "RimeBridge" / "Vendor"
        vendor.mkdir(parents=True, exist_ok=True)
        link = vendor / "some-link"
        if not link.exists():
            link.symlink_to(self.root / "nowhere-target")
        r2 = self._run()
        self.assertEqual(r2.returncode, 0, r2.stdout + r2.stderr)
        self.assertIn("GATE_CACHED", r2.stdout)
        self.assertEqual(self._count(), 1)

    def test_stub_failure_no_cache_fail_closed(self) -> None:
        self.fail_file.write_text("1\n", encoding="utf-8")
        r1 = self._run()
        self.assertNotEqual(r1.returncode, 0, r1.stdout + r1.stderr)
        self.assertNotIn("GATE_PASS", r1.stdout)
        self.assertNotIn("GATE_CACHED", r1.stdout)
        self.assertEqual(self._count(), 1)
        # no cache entry written: next run (with stub healthy) must run the stub again
        self.fail_file.unlink()
        r2 = self._run()
        self.assertEqual(r2.returncode, 0, r2.stdout + r2.stderr)
        self.assertIn("GATE_PASS", r2.stdout)
        self.assertEqual(self._count(), 2)

    def test_no_cache_flag_always_runs(self) -> None:
        r1 = self._run()
        self.assertEqual(r1.returncode, 0, r1.stdout + r1.stderr)
        r2 = self._run("executor", "--no-cache")
        self.assertEqual(r2.returncode, 0, r2.stdout + r2.stderr)
        self.assertIn("GATE_PASS", r2.stdout)
        self.assertEqual(self._count(), 2)


if __name__ == "__main__":
    unittest.main()
