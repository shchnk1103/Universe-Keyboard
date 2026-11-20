"""Tests for KOS-TOOLS-003: identity check, open tip guard/log, land cleanup, freeze --identity."""
from __future__ import annotations

import json
import subprocess
import tempfile
import unittest
from pathlib import Path

from test_tools_fix_001 import load
from test_pr_flow import (
    FLAKY,
    HEAD,
    IDENTITY,
    OTHER,
    Queue,
    fail,
    has,
    ok,
    _classification_steps,
    _job,
    _pass_items,
    _ready,
    _snap,
    _view,
)

CI = load("kos_check_identity_003", "check_identity.py")
FREEZE = load("kos_freeze_003", "freeze.py")
FLOW = load("kos_pr_flow_003", "pr_flow.py")


class IdentityTests(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        self.repo = Path(self.tmp.name) / "repo"
        self.repo.mkdir()
        subprocess.run(["git", "init"], cwd=self.repo, check=True, capture_output=True)
        subprocess.run(
            ["git", "-c", "user.name=Cowork 3P", "-c", "user.email=cowork-3p@localhost", "commit", "--allow-empty", "-m", "init"],
            cwd=self.repo,
            check=True,
            capture_output=True,
        )

    def tearDown(self) -> None:
        self.tmp.cleanup()

    def test_match(self) -> None:
        text, code = CI.check_identity(str(self.repo), "Cowork 3P <cowork-3p@localhost>")
        self.assertEqual(code, 0)
        self.assertIn("IDENTITY_MATCH", text)
        self.assertIn(
            "Cowork 3P <cowork-3p@localhost>|Cowork 3P <cowork-3p@localhost>",
            text,
        )

    def test_mismatch_author_or_committer(self) -> None:
        (self.repo / "g.txt").write_text("g\n", encoding="utf-8")
        subprocess.run(["git", "add", "g.txt"], cwd=self.repo, check=True, capture_output=True)
        subprocess.run(
            [
                "git",
                "-c",
                "user.name=Other",
                "-c",
                "user.email=o@localhost",
                "commit",
                "-m",
                "other",
            ],
            cwd=self.repo,
            check=True,
            capture_output=True,
        )
        text, code = CI.check_identity(str(self.repo), "Cowork 3P <cowork-3p@localhost>")
        self.assertEqual(code, 1)
        self.assertIn("IDENTITY_MISMATCH", text)

    def test_error(self) -> None:
        text, code = CI.check_identity(str(self.repo / "missing"), "Cowork 3P <cowork-3p@localhost>")
        self.assertEqual(code, 2)
        self.assertTrue(text.startswith("IDENTITY_ERROR"))


class OpenGuardTests(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        root = Path(self.tmp.name)
        self.files = root / "files.txt"
        self.body = root / "body.md"
        self.logs = root / "logs"
        self.files.write_text("scripts/kos/pr_flow.py\n", encoding="utf-8")
        self.body.write_text("Summary: Record the open log.\n记录开 PR 的日志。\n", encoding="utf-8")

    def tearDown(self) -> None:
        self.tmp.cleanup()

    def _args(self, extra=None):
        return [
            "open",
            "--worktree",
            "/wt",
            "--branch",
            "feature/kos-pr-flow-001",
            "--base-sha",
            "base",
            "--expect-head",
            HEAD,
            "--files",
            str(self.files),
            "--title",
            "Record open log / 记录开 PR 日志",
            "--body-file",
            str(self.body),
            "--log-dir",
            str(self.logs),
        ] + (extra or [])

    def test_branch_tip_mismatch_stops_before_push(self) -> None:
        good_log = f"AUTHOR:{IDENTITY}\nCOMMITTER:{IDENTITY}\n"
        runner = Queue(
            [
                (has("rev-parse", "HEAD"), ok(HEAD + "\n")),
                (has("status"), ok("")),
                (has("log"), ok(good_log)),
                (has("diff"), ok("scripts/kos/pr_flow.py\n")),
                (lambda a: "rev-parse" in a and any(str(x).startswith("refs/heads/") for x in a), ok(OTHER + "\n")),
            ]
        )
        self.assertEqual(FLOW.main(self._args(), runner=runner), 1)
        self.assertFalse(any("ls-remote" in c or "push" in c for c in runner.calls))
        log = json.loads((self.logs / "open-feature-kos-pr-flow-001.json").read_text(encoding="utf-8"))
        self.assertEqual(log["status"], "error")
        self.assertIn("branch ref", log["error"])
        self.assertIsNone(log["pr_url"])

    def test_log_dir_writes_on_success_and_failure(self) -> None:
        good_log = f"AUTHOR:{IDENTITY}\nCOMMITTER:{IDENTITY}\n"
        ok_runner = Queue(
            [
                (has("rev-parse", "HEAD"), ok(HEAD + "\n")),
                (has("status"), ok("")),
                (has("log"), ok(good_log)),
                (has("diff"), ok("scripts/kos/pr_flow.py\n")),
                (lambda a: "rev-parse" in a and any(str(x).startswith("refs/heads/") for x in a), ok(HEAD + "\n")),
                (has("ls-remote"), ok("")),
                (has("rev-parse", "origin/main"), fail("unknown revision")),
                (has("push"), ok("")),
                (has("pr", "create"), ok("https://example/pull/9\n")),
            ]
        )
        self.assertEqual(FLOW.main(self._args(), runner=ok_runner), 0)
        success = json.loads((self.logs / "open-feature-kos-pr-flow-001.json").read_text(encoding="utf-8"))
        self.assertEqual(success["status"], "opened")
        self.assertEqual(success["pr_url"], "https://example/pull/9")
        self.assertIsNone(success["error"])

        bad = Queue([(has("rev-parse", "HEAD"), ok(OTHER + "\n"))])
        self.assertEqual(FLOW.main(self._args(), runner=bad), 1)
        failure = json.loads((self.logs / "open-feature-kos-pr-flow-001.json").read_text(encoding="utf-8"))
        self.assertEqual(failure["status"], "error")
        self.assertIsNone(failure["pr_url"])
        self.assertTrue(failure["error"])


class LandCleanupTests(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.pm = self.root / "pm-log"
        self.logs = self.root / "land"
        self.wt = self.root / "wt"
        (self.wt / "Packages" / "RimeBridge").mkdir(parents=True)
        (self.wt / "Packages" / "RimeBridge" / "Vendor").symlink_to("/var/empty")

    def tearDown(self) -> None:
        self.tmp.cleanup()

    def _land(self, extra=None):
        return [
            "land",
            "266",
            "--expect-head",
            HEAD,
            "--main-checkout",
            "/main",
            "--pm-log",
            str(self.pm),
            "--log-dir",
            str(self.logs),
            "--known-flaky",
            str(FLAKY),
            "--merge",
        ] + (extra or [])

    def _pre_cleanup(self):
        """Steps up to and including post-merge reachability checks."""
        return [
            (has("view"), _view()),
            *_snap(_pass_items()),
            *_classification_steps(),
            (has("view"), _view()),
            (has("autoMergeRequest,mergeStateStatus,headRefOid"), _ready()),
            (has("pr", "merge"), ok("merged")),
            (has("mergeCommit"), ok(json.dumps({"mergeCommit": {"oid": "c" * 40}}))),
            (has("fetch"), ok()),
            (has("--is-ancestor"), ok()),
            (has("--is-ancestor"), ok()),
        ]

    def _post_cleanup_ff(self):
        """Steps after a successful worktree cleanup."""
        return [
            (has("--abbrev-ref"), ok("main\n")),
            (has("status"), ok("")),
            (lambda a: a[-2:] == ["rev-parse", "HEAD"] and "--abbrev-ref" not in a, ok("d" * 40 + "\n")),
            (has("--is-ancestor"), ok()),
            (has("--ff-only"), ok("")),
            (lambda a: a[-2:] == ["rev-parse", "HEAD"] and "--abbrev-ref" not in a, ok("newmain\n")),
        ]

    def _green_to_ff(self):
        return self._pre_cleanup() + self._post_cleanup_ff()

    def test_one_cleanup_arg_errors_before_gh(self) -> None:
        runner = Queue([])
        code = FLOW.main(self._land(["--cleanup-worktree", str(self.wt)]), runner=runner)
        self.assertEqual(code, 1)
        self.assertEqual(runner.calls, [])

    def test_successful_cleanup_order(self) -> None:
        steps = self._pre_cleanup() + [
            (lambda a: "rev-parse" in a and any(str(x).startswith("refs/heads/") for x in a), ok(HEAD + "\n")),
            (has("merge-base", "--is-ancestor", "fix/kos"), ok("")),
            (has("worktree", "list"), ok(f"worktree {self.wt}\nHEAD {HEAD}\n")),
            (
                lambda a: len(a) >= 4 and a[1] == "-C" and a[2] == str(self.wt) and "rev-parse" in a,
                ok(HEAD + "\n"),
            ),
            (
                lambda a: len(a) >= 4 and a[1] == "-C" and a[2] == str(self.wt) and "status" in a,
                ok("?? Packages/RimeBridge/Vendor\n"),
            ),
            (has("worktree", "remove"), ok("")),
        ] + self._post_cleanup_ff() + [
            (has("merge-base", "--is-ancestor", "fix/kos"), ok("")),
            (has("branch", "-d"), ok("")),
            (has("ls-remote"), ok("")),
        ]
        runner = Queue(steps)
        code = FLOW.main(
            self._land(["--cleanup-worktree", str(self.wt), "--cleanup-branch", "fix/kos"]),
            runner=runner,
        )
        self.assertEqual(code, 0, runner.calls)
        joined = [" ".join(map(str, c)) for c in runner.calls]
        cleanup_anc = [
            i
            for i, c in enumerate(joined)
            if "merge-base --is-ancestor fix/kos origin/main" in c
        ]
        rem_i = next(i for i, c in enumerate(joined) if "worktree remove" in c)
        del_i = next(i for i, c in enumerate(joined) if "branch -d" in c)
        self.assertTrue(cleanup_anc)
        # Worktree removal must precede the fast-forward; branch deletion follows it.
        self.assertLess(cleanup_anc[0], rem_i)
        self.assertLess(rem_i, del_i)
        payload = json.loads((self.logs / "land-266.json").read_text(encoding="utf-8"))
        self.assertEqual(payload["status"], "merged")
        self.assertEqual(payload["cleanup"], "already_deleted_on_origin")

    def test_dirty_worktree_skips_remove(self) -> None:
        steps = self._pre_cleanup() + [
            (lambda a: "rev-parse" in a and any(str(x).startswith("refs/heads/") for x in a), ok(HEAD + "\n")),
            (has("merge-base", "--is-ancestor", "fix/kos"), ok("")),
            (has("worktree", "list"), ok(f"worktree {self.wt}\n")),
            (
                lambda a: len(a) >= 4 and a[1] == "-C" and a[2] == str(self.wt) and "rev-parse" in a,
                ok(HEAD + "\n"),
            ),
            (
                lambda a: len(a) >= 4 and a[1] == "-C" and a[2] == str(self.wt) and "status" in a,
                ok(" M dirty.txt\n"),
            ),
        ] + self._post_cleanup_ff()
        runner = Queue(steps)
        code = FLOW.main(
            self._land(["--cleanup-worktree", str(self.wt), "--cleanup-branch", "fix/kos"]),
            runner=runner,
        )
        self.assertEqual(code, 1)
        self.assertFalse(any("worktree remove" in " ".join(map(str, c)) for c in runner.calls))
        payload = json.loads((self.logs / "land-266.json").read_text(encoding="utf-8"))
        self.assertEqual(payload["status"], "cleanup-stopped")
        self.assertEqual(payload["cleanup"], "skipped:worktree-dirty")

    def test_branch_tip_mismatch_skips(self) -> None:
        steps = self._pre_cleanup() + [
            (lambda a: "rev-parse" in a and any(str(x).startswith("refs/heads/") for x in a), ok(OTHER + "\n")),
        ] + self._post_cleanup_ff()
        runner = Queue(steps)
        code = FLOW.main(
            self._land(["--cleanup-worktree", str(self.wt), "--cleanup-branch", "fix/kos"]),
            runner=runner,
        )
        self.assertEqual(code, 1)
        payload = json.loads((self.logs / "land-266.json").read_text(encoding="utf-8"))
        self.assertEqual(payload["status"], "cleanup-stopped")
        self.assertEqual(payload["cleanup"], "skipped:branch-tip-mismatch")
        self.assertFalse(any("worktree remove" in " ".join(map(str, c)) for c in runner.calls))

    def test_allowed_path_not_symlink_skips(self) -> None:
        vendor = self.wt / "Packages" / "RimeBridge" / "Vendor"
        vendor.unlink()
        vendor.mkdir()
        steps = self._pre_cleanup() + [
            (lambda a: "rev-parse" in a and any(str(x).startswith("refs/heads/") for x in a), ok(HEAD + "\n")),
            (has("merge-base", "--is-ancestor", "fix/kos"), ok("")),
            (has("worktree", "list"), ok(f"worktree {self.wt}\n")),
            (
                lambda a: len(a) >= 4 and a[1] == "-C" and a[2] == str(self.wt) and "rev-parse" in a,
                ok(HEAD + "\n"),
            ),
            (
                lambda a: len(a) >= 4 and a[1] == "-C" and a[2] == str(self.wt) and "status" in a,
                ok(""),
            ),
        ] + self._post_cleanup_ff()
        runner = Queue(steps)
        code = FLOW.main(
            self._land(["--cleanup-worktree", str(self.wt), "--cleanup-branch", "fix/kos"]),
            runner=runner,
        )
        self.assertEqual(code, 1)
        payload = json.loads((self.logs / "land-266.json").read_text(encoding="utf-8"))
        self.assertEqual(payload["status"], "cleanup-stopped")
        self.assertEqual(payload["cleanup"], "skipped:allowed-path-not-symlink")

    def test_cleanup_null_when_not_requested(self) -> None:
        runner = Queue(self._green_to_ff())
        code = FLOW.main(self._land(), runner=runner)
        self.assertEqual(code, 0)
        payload = json.loads((self.logs / "land-266.json").read_text(encoding="utf-8"))
        self.assertIsNone(payload["cleanup"])


class FreezeIdentityTests(unittest.TestCase):
    def test_identity_default_and_override(self) -> None:
        base = (
            "**你的角色：Executor（测）。你不是 PM：只做本包；不派发任务、不讨论本包以外的事。"
            "所有结果写进报告；最终消息只写一句话：状态 + 报告路径 + SHA-256。**\n"
            "写入被拒。不主动写 /tmp。授权原文另存 `/x/y.md`。reports/out.md\n"
            "无 Assignment：小任务分级。\n"
            "滚动交接报告\n"
        )
        with_default = base + "Cowork 3P <cowork-3p@localhost>\n"
        self.assertEqual(FREEZE.lint_problems(with_default, requires_commit=True), [])
        custom = "Other Name <other@localhost>"
        self.assertIn(
            "commit identity with email",
            FREEZE.lint_problems(with_default, requires_commit=True, identity=custom),
        )
        self.assertEqual(
            FREEZE.lint_problems(base + custom + "\n", requires_commit=True, identity=custom),
            [],
        )


if __name__ == "__main__":
    unittest.main()
