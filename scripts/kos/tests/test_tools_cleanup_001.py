"""KOS-TOOLS-CLEANUP-001: lock residue guard, cleanup guard order, H10 wording, profile snapshot."""
from __future__ import annotations

import json
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from types import SimpleNamespace

from test_tools_fix_001 import load

ROOT = Path(__file__).resolve().parents[3]
KOS = ROOT / "scripts" / "kos"
LOCK = KOS / "kos-lock.py"
HANDOFF = KOS / "kos_handoff.py"

FLOW = load("kos_pr_flow_cleanup", "pr_flow.py")

HEAD = "a" * 40


def run_lock(args, root):
    env = os.environ.copy()
    env["KOS_QUEUE_ROOT"] = str(root)
    env["PYTHONDONTWRITEBYTECODE"] = "1"
    return subprocess.run(
        ["python3", "-I", "-B", str(LOCK), *args],
        capture_output=True, text=True, env=env)


def run_handoff(args):
    env = os.environ.copy()
    env["PYTHONDONTWRITEBYTECODE"] = "1"
    return subprocess.run(
        ["python3", "-I", "-B", str(HANDOFF), *args],
        capture_output=True, text=True, env=env)


class Queue:
    def __init__(self, steps):
        self.steps = list(steps)
        self.calls = []

    def run(self, argv, cwd=None, env=None):
        self.calls.append(argv)
        if not self.steps:
            raise AssertionError(argv)
        pred, result = self.steps.pop(0)
        if not pred(argv):
            raise AssertionError(argv)
        return result


def ok(text=""):
    return FLOW.Result(0, text, "")


def has(*parts):
    return lambda argv: all(part in argv for part in parts)


class LockResidueTests(unittest.TestCase):
    """Invalid resource names must exit 2 before any RESOURCES.json.lock is created."""

    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name) / "queue"

    def tearDown(self):
        self.tmp.cleanup()

    def test_acquire_invalid_resource_exits_2_without_lock_file(self):
        result = run_lock(["acquire", "bogus", "--task", "TASK-A", "--session", "one"], self.root)
        self.assertEqual(result.returncode, 2, result.stdout + result.stderr)
        self.assertIn("非法", result.stderr)
        self.assertFalse((self.root / "RESOURCES.json.lock").exists())
        self.assertFalse((self.root / "RESOURCES.json").exists())


class CleanupGuardOrderTests(unittest.TestCase):
    """Main-checkout guard must fire before the dirty check, even on a dirty tree."""

    def test_main_checkout_guard_precedes_dirty_check(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            args = SimpleNamespace(main_checkout=str(root), cleanup_worktree=str(root),
                                   cleanup_branch="feature",
                                   cleanup_allow_untracked=["Packages/RimeBridge/Vendor"])
            runner = Queue([
                (has("rev-parse"), ok(HEAD)),
                (has("merge-base"), ok()),
                (has("worktree", "list"), ok(f"worktree {root}\n")),
                (has("rev-parse"), ok(HEAD)),
                (has("status"), ok("?? rogue.txt\n")),
            ])
            self.assertEqual(FLOW._run_cleanup(args, runner, HEAD), "skipped:main-checkout")
            self.assertFalse(any("worktree" in call and "remove" in call for call in runner.calls))
            self.assertFalse(runner.steps)


class H10WordingTests(unittest.TestCase):
    """H10 body message must match the actual rule: Chinese anywhere in the body."""

    NEW_BODY_MESSAGE = (
        "H10: body needs a Summary: line with English text and Chinese anywhere in the body"
    )

    def test_body_error_message_matches_actual_rule(self):
        result = FLOW._bilingual_error("Add gate / 补门禁", "Summary: English only.\nStill English.\n")
        self.assertEqual(result, self.NEW_BODY_MESSAGE)
        self.assertNotIn("Summary: line with English and Chinese", result)

    def test_chinese_outside_summary_line_passes(self):
        result = FLOW._bilingual_error("Add gate / 补门禁", "Summary: Add the gate.\n中文只出现在正文里。\n")
        self.assertIsNone(result)


class TierProfileSnapshotTests(unittest.TestCase):
    """`profile --grade <g>` output must stay in sync with the TIER_PROFILES table."""

    SNAPSHOTS = {
        "doc-light": (
            "doc-light:\n"
            "站点: PM 写包 → 实现·文档 → PM 终审 → 发布* → 合并*\n"
            "预检: 免\n"
            "红测: 免\n"
            "独立复核: 免\n"
            "直通: 无（严禁越级直通）\n"
        ),
        "doc-rule": (
            "doc-rule:\n"
            "站点: PM 写包 → 预检 → 实现·文档 → PM 终审 → 发布* → 合并*\n"
            "预检: 必经\n"
            "红测: 免\n"
            "独立复核: 免\n"
            "直通: relay-exec\n"
        ),
        "code-fix": (
            "code-fix:\n"
            "站点: PM 写包 → 预检 → 实现·代码（红测） → 独立复核 → PM 终审 → 发布* → 真机(Human)* → 合并*\n"
            "预检: 必经\n"
            "红测: 必经\n"
            "独立复核: 必经\n"
            "直通: relay-exec, relay-quality\n"
        ),
        "feature": (
            "feature:\n"
            "站点: 设计(Nick) → 架构审查(Alex) → PM 写包 → 预检 → 实现·代码 → 独立复核 → PM 终审 → 发布* → 真机(Human)* → 合并*\n"
            "预检: 必经\n"
            "红测: 必经\n"
            "独立复核: 必经\n"
            "直通: relay-exec, relay-quality\n"
        ),
    }

    def test_all_four_grades_match_snapshot(self):
        for grade, expected in self.SNAPSHOTS.items():
            result = run_handoff(["profile", "--grade", grade])
            self.assertEqual(result.returncode, 0, grade + ": " + result.stderr)
            self.assertEqual(result.stdout, expected, grade)

    def test_unknown_grade_fails_closed(self):
        result = run_handoff(["profile", "--grade", "no-such-grade"])
        self.assertEqual(result.returncode, 2)
        self.assertIn("STOPPED", result.stderr)


if __name__ == "__main__":
    unittest.main()
