"""pr_flow open/land behavior with an injected command runner. No network."""
from __future__ import annotations

import contextlib
import fcntl
import io
import json
import os
import subprocess
import sys
import tarfile
import tempfile
import unittest
from io import BytesIO
from pathlib import Path

from test_tools_fix_001 import load

FLOW = load("kos_pr_flow", "pr_flow.py")
FIXTURE = Path(__file__).resolve().parent / "fixtures" / "failed-log-sample-pr266.txt"
FLAKY = Path(__file__).resolve().parents[1] / "known-flaky.txt"
HEAD = "a" * 40
OTHER = "b" * 40
ORIGIN_TIP = "c" * 40
IDENTITY = "Cowork 3P <cowork-3p@localhost>"
CASE = (
    "KeyboardExtensionTests.TypoCorrectionRecallCoordinatorIntegrationTests."
    "testHostCallbackPersistsMeasuredQueriesThroughTypedJournalRuntime"
)


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


def fail(text="", code=1):
    return FLOW.Result(code, "", text)


def has(*parts):
    return lambda argv: all(part in argv for part in parts)


class ParseTests(unittest.TestCase):
    def test_final_skipped_is_distinct_from_skipping(self) -> None:
        rows = FLOW._snapshot_rows(json.dumps([
            {"name": "finished", "bucket": "skipping", "state": "SKIPPED"},
            {"name": "running", "bucket": "skipping", "state": "IN_PROGRESS"},
        ]))
        self.assertEqual([row["state"] for row in rows], ["skipped", "skipping"])
        # Final skipped is a valid snapshot state; the matrix decides whether it is allowed.
        self.assertFalse(FLOW._snapshot_buckets_invalid(rows))
        self.assertEqual([row["name"] for row in FLOW._pending_states(rows)], ["running"])

    def test_fixture_parses_known_case_and_error_quote(self) -> None:
        log = FIXTURE.read_text(encoding="utf-8")
        cases = FLOW._parse_cases(log)
        self.assertEqual([name for name, _quote in cases], [CASE])
        quote = cases[0][1]
        self.assertLessEqual(len(quote), 300)
        self.assertTrue(quote.startswith("error:"))
        self.assertIn(quote, log)
        self.assertIn("stage=read-after-barrier", quote)


class MatrixTests(unittest.TestCase):
    def test_all_tiers_and_rejections(self) -> None:
        spec = load("kos_clauses_matrix", "clauses_spec.py")
        common = spec.COMMON_REQUIRED_CHECKS
        heavy = spec.HEAVY_CHECKS
        matrix = spec.CLASSIFICATION_REQUIRED_HEAVY
        for tier, required in matrix.items():
            rows = ([{"name": name, "state": "pass"} for name in common | required]
                    + [{"name": name, "state": "skipped"} for name in heavy - required])
            with self.subTest(tier=tier):
                check = lambda items, name=tier: FLOW._matrix_error(items, name, common, matrix, heavy)
                self.assertIsNone(check(rows))
                self.assertIsNotNone(check(rows[:-1]))
                self.assertIsNotNone(check(rows + [rows[0]]))
                for state in ("skipping", "pending", "fail", "cancel", "not watching"):
                    self.assertIsNotNone(check(rows + [{"name": "other", "state": state}]))
                self.assertIsNotNone(check(rows + [{"name": "other", "state": "skipped"}]))
                wrong = [dict(row) for row in rows]
                next(row for row in wrong if row["name"] in common)["state"] = "skipped"
                self.assertIsNotNone(check(wrong))
                all_pass = [dict(row, state="pass") for row in rows]
                self.assertIsNone(check(all_pass))
        self.assertIsNotNone(FLOW._matrix_error([], "unknown", common, matrix, heavy))

    def test_classification_evidence_is_bound_to_head_and_base(self) -> None:
        spec = load("kos_clauses_binding", "clauses_spec.py")
        matrix = spec.CLASSIFICATION_REQUIRED_HEAVY
        evidence = {"head_sha": HEAD, "base_sha": OTHER, "classification": "docs_only"}
        check = lambda value: FLOW._classification_error(value, HEAD, OTHER, matrix)
        self.assertIsNone(check(evidence))
        for field, value in (("head_sha", OTHER), ("base_sha", HEAD),
                             ("classification", "unknown")):
            self.assertIsNotNone(check(dict(evidence, **{field: value})))
        self.assertIsNotNone(check(None))


class CleanupPathTests(unittest.TestCase):
    def test_arbitrary_allowed_path_is_never_removed(self) -> None:
        from types import SimpleNamespace

        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            victim = root / "victim"
            victim.symlink_to(root / "target")
            args = SimpleNamespace(main_checkout=str(root), cleanup_worktree=str(root),
                                   cleanup_branch="feature", cleanup_allow_untracked=["victim"])
            runner = Queue([
                (has("rev-parse"), ok(HEAD)),
                (has("merge-base"), ok()),
                (has("worktree", "list"), ok(f"worktree {root}\n")),
                (has("rev-parse"), ok(HEAD)),
                (has("status"), ok("?? victim\n")),
            ])
            self.assertEqual(FLOW._run_cleanup(args, runner, HEAD), "skipped:unsupported-allowed-path")
            self.assertTrue(victim.is_symlink())
            self.assertFalse(runner.steps)

    def test_main_checkout_vendor_symlink_is_not_unlinked(self) -> None:
        from types import SimpleNamespace

        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            vendor = root / "Packages" / "RimeBridge" / "Vendor"
            vendor.parent.mkdir(parents=True)
            vendor.symlink_to(root / "outside")
            args = SimpleNamespace(main_checkout=str(root), cleanup_worktree=str(root),
                                   cleanup_branch="feature",
                                   cleanup_allow_untracked=["Packages/RimeBridge/Vendor"])
            runner = Queue([
                (has("rev-parse"), ok(HEAD)),
                (has("merge-base"), ok()),
                (has("worktree", "list"), ok(f"worktree {root}\n")),
                (has("rev-parse"), ok(HEAD)),
                (has("status"), ok("?? Packages/RimeBridge/Vendor\n")),
            ])
            self.assertEqual(FLOW._run_cleanup(args, runner, HEAD), "skipped:main-checkout")
            self.assertTrue(vendor.is_symlink())
            self.assertFalse(any("worktree" in call and "remove" in call for call in runner.calls))

    def test_vendor_symlink_unlinked_before_worktree_remove(self) -> None:
        from types import SimpleNamespace

        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            main = root / "main"
            wt = root / "wt"
            main.mkdir()
            vendor = wt / "Packages" / "RimeBridge" / "Vendor"
            vendor.parent.mkdir(parents=True)
            vendor.symlink_to(root / "outside")
            args = SimpleNamespace(main_checkout=str(main), cleanup_worktree=str(wt),
                                   cleanup_branch="feature",
                                   cleanup_allow_untracked=["Packages/RimeBridge/Vendor"])
            runner = Queue([
                (has("rev-parse"), ok(HEAD)),
                (has("merge-base"), ok()),
                (has("worktree", "list"), ok(f"worktree {wt}\n")),
                (has("rev-parse"), ok(HEAD)),
                (has("status"), ok("?? Packages/RimeBridge/Vendor\n")),
                (has("worktree", "remove"), ok()),
            ])
            self.assertEqual(FLOW._run_cleanup(args, runner, HEAD), "worktree-removed")
            self.assertFalse(vendor.exists() or vendor.is_symlink())
            removed = [call for call in runner.calls if "remove" in call]
            self.assertEqual(len(removed), 1)
            self.assertNotIn("--force", removed[0])

    def test_plain_vendor_directory_is_not_removed(self) -> None:
        from types import SimpleNamespace

        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            main = root / "main"
            wt = root / "wt"
            main.mkdir()
            vendor = wt / "Packages" / "RimeBridge" / "Vendor"
            vendor.mkdir(parents=True)
            (vendor / "keep").write_text("x", encoding="utf-8")
            args = SimpleNamespace(main_checkout=str(main), cleanup_worktree=str(wt),
                                   cleanup_branch="feature",
                                   cleanup_allow_untracked=["Packages/RimeBridge/Vendor"])
            runner = Queue([
                (has("rev-parse"), ok(HEAD)),
                (has("merge-base"), ok()),
                (has("worktree", "list"), ok(f"worktree {wt}\n")),
                (has("rev-parse"), ok(HEAD)),
                (has("status"), ok("?? Packages/RimeBridge/Vendor/\n")),
            ])
            self.assertEqual(FLOW._run_cleanup(args, runner, HEAD), "skipped:allowed-path-not-symlink")
            self.assertTrue((vendor / "keep").is_file())
            self.assertFalse(any("remove" in call for call in runner.calls))


class OpenTests(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        root = Path(self.tmp.name)
        self.files = root / "files.txt"
        self.files.write_text("scripts/kos/pr_flow.py\n", encoding="utf-8")
        self.body = root / "body.md"
        self.body.write_text("Summary: Ship the helper.\n发布这个助手。\n", encoding="utf-8")
        self.log_dir = root / "log"

    def tearDown(self) -> None:
        self.tmp.cleanup()

    def _args(self, extra=None):
        argv = [
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
            "Ship helper / 发布助手",
            "--body-file",
            str(self.body),
            "--log-dir",
            str(self.log_dir),
            "--allow-untracked",
            "Packages/RimeBridge/Vendor",
        ]
        return argv + (extra or [])

    def test_each_check_fails_and_one_path_passes(self) -> None:
        good_log = f"AUTHOR:{IDENTITY}\nCOMMITTER:{IDENTITY}\n"
        passing = Queue(
            [
                (has("rev-parse", "HEAD"), ok(HEAD + "\n")),
                (has("status", "--porcelain"), ok("?? Packages/RimeBridge/Vendor/librime.a\n")),
                (has("log"), ok(good_log)),
                (has("diff", "--name-only"), ok("scripts/kos/pr_flow.py\n")),
                (lambda a: "rev-parse" in a and any(str(x).startswith("refs/heads/") for x in a), ok(HEAD + "\n")),
                (has("ls-remote"), ok("")),
                (has("rev-parse", "origin/main"), fail("unknown revision")),
                (has("push"), ok("")),
                (has("pr", "create"), ok("https://example/pull/1\n")),
            ]
        )
        self.assertEqual(FLOW.main(self._args(), runner=passing), 0)
        self.assertIn("pr", passing.calls[-1])
        self.assertNotIn("--force", passing.calls[-2])

        mismatches = [
            ("head", [(has("rev-parse"), ok(OTHER + "\n"))]),
            (
                "dirty",
                [
                    (has("rev-parse"), ok(HEAD + "\n")),
                    (has("status"), ok(" M scripts/kos/pr_flow.py\n")),
                ],
            ),
            (
                "identity",
                [
                    (has("rev-parse"), ok(HEAD + "\n")),
                    (has("status"), ok("")),
                    (has("log"), ok("AUTHOR:Other <o@localhost>\nCOMMITTER:Other <o@localhost>\n")),
                ],
            ),
            (
                "files",
                [
                    (has("rev-parse"), ok(HEAD + "\n")),
                    (has("status"), ok("")),
                    (has("log"), ok(good_log)),
                    (has("diff"), ok("README.md\n")),
                ],
            ),
            (
                "remote",
                [
                    (has("rev-parse"), ok(HEAD + "\n")),
                    (has("status"), ok("")),
                    (has("log"), ok(good_log)),
                    (has("diff"), ok("scripts/kos/pr_flow.py\n")),
                    (lambda a: "rev-parse" in a and any(str(x).startswith("refs/heads/") for x in a), ok(HEAD + "\n")),
                    (has("ls-remote"), ok("abc\trefs/heads/feature/kos-pr-flow-001\n")),
                ],
            ),
        ]
        for name, steps in mismatches:
            with self.subTest(name=name):
                runner = Queue(steps)
                self.assertEqual(FLOW.main(self._args(), runner=runner), 1)
                self.assertFalse(any("push" in call for call in runner.calls))

    def test_body_signature_is_rejected(self) -> None:
        self.body.write_text("ok\nCo-authored-by: Bot\nGenerated with helper\n", encoding="utf-8")
        runner = Queue(
            [
                (has("rev-parse"), ok(HEAD + "\n")),
                (has("status"), ok("")),
                (has("log"), ok(f"AUTHOR:{IDENTITY}\nCOMMITTER:{IDENTITY}\n")),
                (has("diff"), ok("scripts/kos/pr_flow.py\n")),
            ]
        )
        self.assertEqual(FLOW.main(self._args(), runner=runner), 1)
        self.assertFalse(any("ls-remote" in call for call in runner.calls))

    def test_push_5xx_retries_once_then_stops(self) -> None:
        good_log = f"AUTHOR:{IDENTITY}\nCOMMITTER:{IDENTITY}\n"
        runner = Queue(
            [
                (has("rev-parse"), ok(HEAD + "\n")),
                (has("status"), ok("")),
                (has("log"), ok(good_log)),
                (has("diff"), ok("scripts/kos/pr_flow.py\n")),
                (lambda a: "rev-parse" in a and any(str(x).startswith("refs/heads/") for x in a), ok(HEAD + "\n")),
                (has("ls-remote"), ok("")),
                (has("rev-parse", "origin/main"), fail("unknown revision")),
                (has("push"), fail("HTTP 502")),
                (has("ls-remote"), ok("")),
                (has("push"), fail("HTTP 502")),
            ]
        )
        self.assertEqual(FLOW.main(self._args(), runner=runner), 1)
        self.assertEqual(sum(1 for call in runner.calls if "push" in call), 2)
        self.assertFalse(any("create" in call for call in runner.calls))

    def test_dry_run_does_not_push(self) -> None:
        runner = Queue(
            [
                (has("rev-parse"), ok(HEAD + "\n")),
                (has("status"), ok("")),
                (has("log"), ok(f"AUTHOR:{IDENTITY}\nCOMMITTER:{IDENTITY}\n")),
                (has("diff"), ok("scripts/kos/pr_flow.py\n")),
                (lambda a: "rev-parse" in a and any(str(x).startswith("refs/heads/") for x in a), ok(HEAD + "\n")),
                (has("ls-remote"), ok("")),
                (has("rev-parse", "origin/main"), fail("unknown revision")),
            ]
        )
        self.assertEqual(FLOW.main(self._args(["--dry-run"]), runner=runner), 0)
        self.assertFalse(any("push" in call for call in runner.calls))

    def _dry(self):
        return Queue([
            (has("rev-parse"), ok(HEAD + "\n")),
            (has("status"), ok("")),
            (has("log"), ok(f"AUTHOR:{IDENTITY}\nCOMMITTER:{IDENTITY}\n")),
            (has("diff"), ok("scripts/kos/pr_flow.py\n")),
            (lambda a: "rev-parse" in a and any(str(x).startswith("refs/heads/") for x in a), ok(HEAD + "\n")),
            (has("ls-remote"), ok("")),
            (has("rev-parse", "origin/main"), fail("unknown revision")),
        ])

    def test_monolingual_title_is_rejected(self) -> None:
        self.body.write_text("Summary: Add the gate.\n补上中文。\n", encoding="utf-8")
        for title in ("English only", "只有中文"):
            result = FLOW.main(self._args(["--title", title, "--dry-run"]), runner=self._dry())
            self.assertNotEqual(result, 0, title)

    def test_incomplete_body_is_rejected(self) -> None:
        self.body.write_text("English and 中文 without a summary line.\n", encoding="utf-8")
        self.assertNotEqual(FLOW.main(self._args(["--title", "Add gate / 补门禁", "--dry-run"]), runner=self._dry()), 0)
        self.body.write_text("Summary: English only.\nStill English.\n", encoding="utf-8")
        self.assertNotEqual(FLOW.main(self._args(["--title", "Add gate / 补门禁", "--dry-run"]), runner=self._dry()), 0)

    def test_bilingual_title_and_body_pass_dry_run(self) -> None:
        self.body.write_text("Summary: Add the gate.\n补上中文正文。\n", encoding="utf-8")
        runner = self._dry()
        self.assertEqual(FLOW.main(self._args(["--title", "Add gate / 补门禁", "--dry-run"]), runner=runner), 0)
        self.assertFalse(any("push" in call for call in runner.calls))


ROOT = Path(__file__).resolve().parents[3]
VERIFY = ROOT / "scripts" / "kos" / "doc_verify.sh"


def _verify_repo(tmp: Path):
    repo = tmp / "repo"
    repo.mkdir()
    stubs = {
        "scripts/ci/classify_changes.py": "print('ok')\n",
        "scripts/ci/run_lightweight_checks.sh": "#!/bin/sh\nexit 0\n",
        "scripts/ci/check_markdown_links.py": "\n",
        "scripts/ci/check_keyboard_values.py": (
            "import sys\nfrom pathlib import Path\n\n"
            "text = Path('docs/KEYBOARD_VALUES.md').read_text(encoding='utf-8')\n"
            "if 'KEYBOARD_VALUES' not in text:\n"
            "    print('KEYBOARD_VALUES_FAIL: fixture doc missing marker', file=sys.stderr)\n"
            "    sys.exit(1)\n"
            "print('KEYBOARD_VALUES_OK (fixture)')\n"
        ),
        "docs/KEYBOARD_VALUES.md": "# KEYBOARD_VALUES (fixture)\n",
        "scripts/kos/check_identity.py": "import sys\nprint('IDENTITY_MATCH')\n",
    }
    for rel, body in stubs.items():
        path = repo / rel
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(body)
    for rel in ("scripts/ci/tests", "scripts/kos/tests"):
        (repo / rel).mkdir(parents=True, exist_ok=True)
        (repo / rel / "test_placeholder.py").write_text("import unittest\nclass T(unittest.TestCase):\n def test_ok(self):\n  pass\n")
    (repo / "scripts/ci/tests/test_verify_final_gate.sh").write_text("#!/bin/sh\nexit 0\n")
    (repo / "scripts/ci/tests/test_kos_trigger_paths.sh").write_text("#!/bin/sh\nexit 0\n")
    env = {"GIT_AUTHOR_NAME": "Cowork 3P", "GIT_AUTHOR_EMAIL": "cowork-3p@localhost",
           "GIT_COMMITTER_NAME": "Cowork 3P", "GIT_COMMITTER_EMAIL": "cowork-3p@localhost",
           "GIT_CONFIG_GLOBAL": "/dev/null", "GIT_CONFIG_SYSTEM": "/dev/null", "PATH": "/usr/bin:/bin:/usr/local/bin"}
    def git(*args):
        subprocess.run(["git", "-C", str(repo), *args], check=True, env=env, capture_output=True, text=True)
    git("init", "-b", "main")
    (repo / ".kos").mkdir()
    (repo / ".kos/project.json").write_text("{}\n")
    bridge = repo / "Packages" / "RimeBridge"
    bridge.mkdir(parents=True)
    (bridge / ".gitkeep").write_text("\n")
    (repo / "a.txt").write_text("a\n")
    git("add", ".")
    git("commit", "-m", "base")
    base = subprocess.run(["git", "-C", str(repo), "rev-parse", "HEAD"], check=True, capture_output=True, text=True, env=env).stdout.strip()
    return repo, base, env


class VendorExemptionTests(unittest.TestCase):
    def _run(self, repo, base):
        return subprocess.run(["bash", str(VERIFY), base], cwd=str(repo), text=True, capture_output=True, check=False,
                              env={"PATH": "/usr/bin:/bin:/usr/local/bin", "EXPECT_IDENTITY": IDENTITY,
                                   "GIT_CONFIG_GLOBAL": "/dev/null", "GIT_CONFIG_SYSTEM": "/dev/null"})

    def test_vendor_symlink_alone_is_clean(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            repo, base, _ = _verify_repo(Path(tmp))
            os.symlink("/tmp", repo / "Packages" / "RimeBridge" / "Vendor")
            result = self._run(repo, base)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertIn("DOC_VERIFY_PASS", result.stdout)

    def test_other_untracked_or_regular_vendor_still_fails(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            repo, base, _ = _verify_repo(Path(tmp))
            os.symlink("/tmp", repo / "Packages" / "RimeBridge" / "Vendor")
            (repo / "extra.txt").write_text("x\n")
            result = self._run(repo, base)
            self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
            self.assertIn("DOC_VERIFY_FAIL", result.stderr)
        with tempfile.TemporaryDirectory() as tmp:
            repo, base, _ = _verify_repo(Path(tmp))
            (repo / "Packages" / "RimeBridge" / "Vendor").write_text("file\n")
            result = self._run(repo, base)
            self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
            self.assertIn("DOC_VERIFY_FAIL", result.stderr)


def _view(head=HEAD, state="OPEN"):
    return ok(json.dumps({"state": state, "headRefOid": head}))


def _ready(state="CLEAN", auto=None, head=HEAD):
    return ok(json.dumps({"mergeStateStatus": state, "autoMergeRequest": auto, "headRefOid": head}))


WATCH = Path(__file__).resolve().parent / "fixtures" / "watch-three-refreshes-pr267.txt"


def _job(name, bucket, run="999", job="111"):
    link = ""
    if run:
        link = f"https://github.com/shchnk1103/Universe-Keyboard/actions/runs/{run}/job/{job}"
    return {"name": name, "state": bucket, "bucket": bucket, "link": link}


def _watch_step(text="ignored watch table\n"):
    return (lambda argv: "checks" in argv and "--watch" in argv, ok(text))


def _json_step(items):
    return (lambda argv: "checks" in argv and "--json" in argv, ok(json.dumps(items)))


def _snap(items, watch="ignored watch table\n"):
    return [_watch_step(watch), _json_step(items)]


def _fail_items():
    return [_job("test-app-keyboard", "fail")]


def _pass_items():
    spec = load("kos_clauses_fixture", "clauses_spec.py")
    return [_job(name, "pass", "5", str(index)) for index, name in
            enumerate(sorted(spec.COMMON_REQUIRED_CHECKS | spec.HEAVY_CHECKS), 1)]


def _classification_steps():
    return [
        (has("baseRefOid,headRefOid"), ok(json.dumps({"baseRefOid": OTHER, "headRefOid": HEAD}))),
        (has("--base", "--head"), ok(json.dumps({"base_sha": OTHER, "head_sha": HEAD,
                                                  "classification": "full"}))),
    ]


class LandTests(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.pm = self.root / "pm-log"
        self.logs = self.root / "land"

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
            "--lock-file",
            str(self.root / "land.lock"),
        ] + (extra or [])

    def test_all_known_failures_rerun_once_then_stop_without_merge(self) -> None:
        log = FIXTURE.read_text(encoding="utf-8")
        runner = Queue(
            [
                (has("pr", "view"), _view()),
                *_snap(_fail_items()),
                (has("run", "view", "--log-failed"), ok(log)),
                (has("run", "rerun", "--failed"), ok("")),
                *_snap(_fail_items()),
                (has("run", "view", "--log-failed"), ok(log)),
            ]
        )
        code = FLOW.main(self._land(["--merge"]), runner=runner)
        self.assertEqual(code, 1)
        self.assertEqual(sum(1 for call in runner.calls if "rerun" in call), 1)
        self.assertFalse(any(call[1:3] == ["pr", "merge"] for call in runner.calls))
        record = next((self.pm / "ci").glob("pr266-run999-attempt*.md"))
        text = record.read_text(encoding="utf-8")
        self.assertIn(CASE, text)
        self.assertIn("stage=read-after-barrier", text)

    def test_case_outside_list_does_not_rerun(self) -> None:
        foreign = (
            "Test Case '-[KeyboardTests.OtherTests testUnknown]' failed.\n"
            "error: something else\n"
        )
        runner = Queue(
            [
                (has("pr", "view"), _view()),
                *_snap(_fail_items()),
                (has("--log-failed"), ok(foreign)),
            ]
        )
        self.assertEqual(FLOW.main(self._land(["--merge"]), runner=runner), 1)
        self.assertFalse(any("rerun" in call for call in runner.calls))

    def test_unparsed_job_does_not_rerun(self) -> None:
        runner = Queue(
            [
                (has("pr", "view"), _view()),
                *_snap(_fail_items()),
                (has("--log-failed"), ok("error: clang frontend failed\n")),
            ]
        )
        self.assertEqual(FLOW.main(self._land(["--merge"]), runner=runner), 1)
        self.assertFalse(any("rerun" in call for call in runner.calls))

    def test_head_change_does_not_merge(self) -> None:
        runner = Queue(
            [
                (has("pr", "view"), _view()),
                *_snap(_pass_items()),
                *_classification_steps(),
                (has("pr", "view"), _view(head=OTHER)),
            ]
        )
        self.assertEqual(FLOW.main(self._land(["--merge"]), runner=runner), 1)
        self.assertFalse(any(call[1:3] == ["pr", "merge"] for call in runner.calls))

    def test_without_merge_flag_does_not_merge(self) -> None:
        runner = Queue(
            [
                (has("pr", "view"), _view()),
                *_snap(_pass_items()),
                *_classification_steps(),
            ]
        )
        self.assertEqual(FLOW.main(self._land(), runner=runner), 0)
        self.assertFalse(any(call[1:3] == ["pr", "merge"] for call in runner.calls))

    def test_validator_mismatch_does_not_merge(self) -> None:
        buf = BytesIO()
        with tarfile.open(fileobj=buf, mode="w") as tar:
            pass
        runner = Queue(
            [
                (has("pr", "view"), _view()),
                *_snap(_pass_items()),
                *_classification_steps(),
                (has("pr", "view"), _view()),
                (has("pr", "diff"), ok("docs/kos/pm-packet-clauses.md\n")),
                (has("archive"), FLOW.Result(0, buf.getvalue(), "")),
                (has("bash"), FLOW.Result(0, "WARNING: left\n", "")),
                (has("bash"), FLOW.Result(1, "WARNING: right\n", "")),
            ]
        )
        code = FLOW.main(
            self._land(["--merge", "--validator", "/v.sh", "--kos-as-of", "2026-11-05"]),
            runner=runner,
        )
        self.assertEqual(code, 1)
        self.assertFalse(any(call[1:3] == ["pr", "merge"] for call in runner.calls))

    def test_main_not_on_main_or_dirty_does_not_fast_forward(self) -> None:
        merge_json = ok(json.dumps({"mergeCommit": {"oid": "c" * 40}}))
        not_main = Queue(
            [
                (has("pr", "view"), _view()),
                *_snap(_pass_items()),
                *_classification_steps(),
                (has("pr", "view"), _view()),
                (has("autoMergeRequest,mergeStateStatus,headRefOid"), _ready()),
                (has("pr", "merge"), ok("merged")),
                (has("mergeCommit"), merge_json),
                (has("fetch"), ok()),
                (has("--is-ancestor"), ok()),
                (has("--is-ancestor"), ok()),
                (has("--abbrev-ref"), ok("feature/x\n")),
                (has("status"), ok("")),
                (lambda a: "rev-parse" in a and "--abbrev-ref" not in a, ok("d" * 40 + "\n")),
            ]
        )
        self.assertEqual(FLOW.main(self._land(["--merge"]), runner=not_main), 0)
        self.assertFalse(any("--ff-only" in call for call in not_main.calls))

        dirty = Queue(
            [
                (has("pr", "view"), _view()),
                *_snap(_pass_items()),
                *_classification_steps(),
                (has("pr", "view"), _view()),
                (has("autoMergeRequest,mergeStateStatus,headRefOid"), _ready()),
                (has("pr", "merge"), ok("merged")),
                (has("mergeCommit"), merge_json),
                (has("fetch"), ok()),
                (has("--is-ancestor"), ok()),
                (has("--is-ancestor"), ok()),
                (has("--abbrev-ref"), ok("main\n")),
                (has("status"), ok(" M docs/kos/README.md\n")),
                (lambda a: "rev-parse" in a and "--abbrev-ref" not in a, ok("d" * 40 + "\n")),
            ]
        )
        self.assertEqual(FLOW.main(self._land(["--merge"]), runner=dirty), 0)
        self.assertFalse(any("--ff-only" in call for call in dirty.calls))

    def test_final_gate_alone_and_zero_reruns_stop(self) -> None:
        log = FIXTURE.read_text(encoding="utf-8")
        for steps, extra in [
            ([*_snap([_job("final-quality-gate", "fail", "", "")])], []),
            ([*_snap(_fail_items()), (has("--log-failed"), ok(log))], ["--max-reruns", "0"]),
        ]:
            runner = Queue([(has("view"), _view())] + steps)
            self.assertEqual(FLOW.main(self._land(["--merge"] + extra), runner=runner), 1)
            self.assertFalse(any("rerun" in c or c[1:3] == ["pr", "merge"] for c in runner.calls))

    def test_open_dry_run_does_not_check(self) -> None:
        runner = Queue([(has("view"), _view())])
        self.assertEqual(FLOW.main(self._land(["--dry-run"]), runner=runner), 0)
        self.assertFalse(any("checks" in c for c in runner.calls))

    def test_merge_readiness_and_fast_forward_outcomes(self) -> None:
        prefix = [(has("view"), _view()), *_snap(_pass_items()), *_classification_steps(), (has("view"), _view())]
        for ready in [_ready(auto={"enabledAt": "now"}), _ready(state="BLOCKED"), _ready(head=OTHER)]:
            runner = Queue(prefix + [(has("autoMergeRequest,mergeStateStatus,headRefOid"), ready)])
            self.assertEqual(FLOW.main(self._land(["--merge"]), runner=runner), 1)
            self.assertFalse(any(c[1:3] == ["pr", "merge"] for c in runner.calls))
        for ancestor, fast, expected, marker in [(fail("", 1), None, 0, "skipped:"), (ok(), fail("merge failed"), 1, "failed:")]:
            steps = prefix + [(has("autoMergeRequest,mergeStateStatus,headRefOid"), _ready()),
                (has("pr", "merge"), ok("merged")), (has("mergeCommit"), ok(json.dumps({"mergeCommit": {"oid": "c" * 40}}))),
                (has("fetch"), ok()),
                (has("--is-ancestor"), ok()), (has("--is-ancestor"), ok()),
                (has("--abbrev-ref"), ok("main")), (has("status"), ok()),
                (lambda a: "rev-parse" in a and "--abbrev-ref" not in a, ok("d" * 40 + "\n")),
                (has("--is-ancestor"), ancestor)]
            if fast is not None:
                steps.append((has("--ff-only"), fast))
            runner = Queue(steps)
            self.assertEqual(FLOW.main(self._land(["--merge"]), runner=runner), expected)
            merge = next(c for c in runner.calls if c[1:3] == ["pr", "merge"])
            self.assertNotIn("--auto", merge)
            payload = json.loads((self.logs / "land-266.json").read_text())
            self.assertTrue(payload["ff"].startswith(marker))
            self.assertIn("ff=" + payload["ff"], Path(payload["record"]).read_text())

    def test_archive_failure_stops_merge(self) -> None:
        runner = Queue([(has("view"), _view()), *_snap(_pass_items()), *_classification_steps(),
            (has("view"), _view()), (has("diff"), ok("docs/kos/a.md\n")), (has("archive"), fail("bad"))])
        self.assertEqual(FLOW.main(self._land(["--merge", "--validator", "/v.sh"]), runner=runner), 1)
        self.assertFalse(any(c[1:3] == ["pr", "merge"] for c in runner.calls))

    def test_watch_refreshes_are_ignored_and_final_snapshot_reruns_once(self) -> None:
        log = FIXTURE.read_text(encoding="utf-8")
        watch = WATCH.read_text(encoding="utf-8")
        self.assertEqual(watch.count("refresh "), 3)
        final = [
            _job("test-app-keyboard", "fail", "999", "111"),
            _job("build", "pass", "999", "222"),
        ]
        runner = Queue(
            [
                (has("pr", "view"), _view()),
                *_snap(final, watch),
                (has("--log-failed"), ok(log)),
                (has("run", "rerun", "--failed"), ok("")),
                *_snap(final, watch),
                (has("--log-failed"), ok(log)),
            ]
        )
        self.assertEqual(FLOW.main(self._land(["--merge"]), runner=runner), 1)
        self.assertEqual(sum(1 for call in runner.calls if "rerun" in call), 1)
        self.assertFalse(any(call[1:3] == ["pr", "merge"] for call in runner.calls))
        record = (self.pm / "ci" / "pr266-run999-attempt1.md").read_text(encoding="utf-8")
        jobs = record.split("## failures")[0]
        self.assertEqual(jobs.count("test-app-keyboard"), 1)
        self.assertEqual(jobs.count("build"), 1)
        self.assertNotIn("pending", jobs)
        self.assertIn("run=999", jobs)
        self.assertIn("job=111", jobs)

    def test_pending_snapshot_does_not_rerun_or_merge(self) -> None:
        runner = Queue(
            [
                (has("pr", "view"), _view()),
                *_snap([_job("build", "pending", "7", "8"), _job("test-app-keyboard", "fail")]),
            ]
        )
        self.assertEqual(FLOW.main(self._land(["--merge"]), runner=runner), 1)
        self.assertFalse(any("rerun" in call or call[1:3] == ["pr", "merge"] for call in runner.calls))
        payload = json.loads((self.logs / "land-266.json").read_text())
        self.assertEqual(payload["status"], "checks-pending")

    def test_skipping_waits_and_never_merges(self) -> None:
        runner = Queue(
            [
                (has("pr", "view"), _view()),
                *_snap([_job("build", "pass", "5", "6"), _job("optional", "skipping", "5", "7")]),
            ]
        )
        self.assertEqual(FLOW.main(self._land(), runner=runner), 1)
        self.assertFalse(any("rerun" in call or call[1:3] == ["pr", "merge"] for call in runner.calls))
        payload = json.loads((self.logs / "land-266.json").read_text())
        self.assertEqual(payload["status"], "checks-pending")

    def test_empty_missing_or_unknown_bucket_does_not_merge(self) -> None:
        missing = {"name": "build", "state": "pass", "link": ""}
        cases = [[], [missing], [_job("build", "queued")]]
        for items in cases:
            runner = Queue([(has("pr", "view"), _view()), *_snap(items)])
            self.assertEqual(FLOW.main(self._land(["--merge"]), runner=runner), 1)
            self.assertFalse(any(call[1:3] == ["pr", "merge"] or "rerun" in call for call in runner.calls))
            payload = json.loads((self.logs / "land-266.json").read_text())
            self.assertEqual(payload["status"], "checks-snapshot-invalid")

    def test_second_view_non_json_does_not_merge(self) -> None:
        runner = Queue(
            [
                (has("pr", "view"), _view()),
                *_snap(_pass_items()),
                *_classification_steps(),
                (has("pr", "view"), ok("not-json")),
            ]
        )
        self.assertEqual(FLOW.main(self._land(["--merge"]), runner=runner), 1)
        self.assertFalse(any(call[1:3] == ["pr", "merge"] for call in runner.calls))
        payload = json.loads((self.logs / "land-266.json").read_text())
        self.assertEqual(payload["status"], "view-unparsed")

    def test_uppercase_pass_and_fail_do_not_rerun_or_merge(self) -> None:
        items = [
            _job("build", "PASS", "1", "2"),
            _job("test-app-keyboard", "FAIL", "1", "3"),
        ]
        runner = Queue([(has("pr", "view"), _view()), *_snap(items)])
        self.assertEqual(FLOW.main(self._land(["--merge"]), runner=runner), 1)
        self.assertFalse(any(call[1:3] == ["pr", "merge"] or "rerun" in call for call in runner.calls))
        payload = json.loads((self.logs / "land-266.json").read_text())
        self.assertEqual(payload["status"], "checks-snapshot-invalid")

    def test_same_name_failures_stay_independent(self) -> None:
        known = FIXTURE.read_text(encoding="utf-8")
        blank = "error: clang frontend failed\n"
        jobs = [
            _job("test-app-keyboard", "fail", "999", "111"),
            _job("test-app-keyboard", "fail", "999", "222"),
        ]
        for logs in ((blank, known), (known, blank)):
            runner = Queue(
                [
                    (has("pr", "view"), _view()),
                    *_snap(jobs),
                    (has("--log-failed"), ok(logs[0])),
                    (has("--log-failed"), ok(logs[1])),
                ]
            )
            self.assertNotEqual(FLOW.main(self._land(["--merge"]), runner=runner), 0)
            self.assertFalse(any("rerun" in call or call[1:3] == ["pr", "merge"] for call in runner.calls))

    def test_same_name_known_failures_rerun_once(self) -> None:
        known = FIXTURE.read_text(encoding="utf-8")
        jobs = [
            _job("test-app-keyboard", "fail", "999", "111"),
            _job("test-app-keyboard", "fail", "999", "222"),
        ]
        runner = Queue(
            [
                (has("pr", "view"), _view()),
                *_snap(jobs),
                (has("--log-failed"), ok(known)),
                (has("--log-failed"), ok(known)),
                (has("run", "rerun", "--failed"), ok("")),
                *_snap(jobs),
                (has("--log-failed"), ok(known)),
                (has("--log-failed"), ok(known)),
            ]
        )
        self.assertNotEqual(FLOW.main(self._land(["--merge"]), runner=runner), 0)
        self.assertEqual(sum(1 for call in runner.calls if "rerun" in call), 1)
        self.assertFalse(any(call[1:3] == ["pr", "merge"] for call in runner.calls))
        record = (self.pm / "ci" / "pr266-run999-attempt1.md").read_text(encoding="utf-8")
        jobs = record.split("## failures")[0]
        failures = record.split("## failures", 1)[1]
        self.assertEqual(jobs.count("job=111"), 1)
        self.assertEqual(jobs.count("job=222"), 1)
        self.assertIn("job=111", failures)
        self.assertIn("job=222", failures)

    def test_closed_pr_stops_on_dry_run(self) -> None:
        runner = Queue([(has("pr", "view"), _view(state="MERGED"))])
        self.assertEqual(FLOW.main(self._land(["--dry-run"]), runner=runner), 1)
        self.assertEqual(len(runner.calls), 1)

    def _cleanup_land(self, extra_git):
        merge_json = ok(json.dumps({"mergeCommit": {"oid": "c" * 40}}))
        return [
            (has("pr", "view"), _view()),
            *_snap(_pass_items()),
            *_classification_steps(),
            (has("pr", "view"), _view()),
            (has("autoMergeRequest,mergeStateStatus,headRefOid"), _ready()),
            (has("pr", "merge"), ok("merged")),
            (has("mergeCommit"), merge_json),
            (has("fetch"), ok()),
            (has("--is-ancestor"), ok()),
            (has("--is-ancestor"), ok()),
            *extra_git,
        ]

    def test_cleanup_removes_worktree_then_ff_then_branch_d(self) -> None:
        steps = self._cleanup_land([
            (has("rev-parse"), ok(HEAD)),
            (has("--is-ancestor"), ok()),
            (has("worktree", "list"), ok("worktree /wt\n")),
            (has("rev-parse"), ok(HEAD)),
            (has("status"), ok()),
            (has("worktree", "remove"), ok()),
            (has("--abbrev-ref"), ok("main\n")),
            (has("status"), ok()),
            (lambda a: "rev-parse" in a and "--abbrev-ref" not in a, ok("d" * 40 + "\n")),
            (has("--is-ancestor"), ok()),
            (has("--ff-only"), ok()),
            (lambda a: "rev-parse" in a and "--abbrev-ref" not in a, ok("e" * 40 + "\n")),
            (has("--is-ancestor"), ok()),
            (has("branch", "-d"), ok()),
            (has("ls-remote"), ok()),
        ])
        runner = Queue(steps)
        extra = ["--cleanup-worktree", "/wt", "--cleanup-branch", "feature/x"]
        self.assertEqual(FLOW.main(self._land(["--merge"] + extra), runner=runner), 0)
        names = []
        for call in runner.calls:
            if "remove" in call:
                names.append("remove")
                self.assertNotIn("--force", call)
            elif "--ff-only" in call:
                names.append("ff")
            elif "branch" in call and "-d" in call:
                names.append("branch-d")
                self.assertNotIn("-D", call)
        self.assertEqual(names, ["remove", "ff", "branch-d"])

    def test_skipped_ff_does_not_delete_branch(self) -> None:
        steps = self._cleanup_land([
            (has("rev-parse"), ok(HEAD)),
            (has("--is-ancestor"), ok()),
            (has("worktree", "list"), ok("worktree /wt\n")),
            (has("rev-parse"), ok(HEAD)),
            (has("status"), ok()),
            (has("worktree", "remove"), ok()),
            (has("--abbrev-ref"), ok("main\n")),
            (has("status"), ok(" M docs/kos/README.md\n")),
            (lambda a: "rev-parse" in a and "--abbrev-ref" not in a, ok("d" * 40 + "\n")),
        ])
        runner = Queue(steps)
        extra = ["--cleanup-worktree", "/wt", "--cleanup-branch", "feature/x"]
        self.assertEqual(FLOW.main(self._land(["--merge"] + extra), runner=runner), 0)
        self.assertFalse(any("branch" in call and "-d" in call for call in runner.calls))
        self.assertFalse(any("-D" in call for call in runner.calls))
        payload = json.loads((self.logs / "land-266.json").read_text())
        self.assertTrue(payload["ff"].startswith("skipped:"))
        self.assertNotEqual(payload["cleanup"], "local-branch-deleted")


class SameModuleDriftTests(unittest.TestCase):
    """origin/main ahead of base and touching the same module must block open."""

    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        root = Path(self.tmp.name)
        self.files = root / "files.txt"
        self.files.write_text("scripts/kos/pr_flow.py\n", encoding="utf-8")
        self.body = root / "body.md"
        self.body.write_text("Summary: Ship the helper.\n发布这个助手。\n", encoding="utf-8")
        self.log_dir = root / "log"

    def tearDown(self) -> None:
        self.tmp.cleanup()

    def _args(self, extra=None):
        argv = [
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
            "Ship helper / 发布助手",
            "--body-file",
            str(self.body),
            "--log-dir",
            str(self.log_dir),
            "--allow-untracked",
            "Packages/RimeBridge/Vendor",
        ]
        return argv + (extra or [])

    def _gate_steps(self, diff_output):
        """Queue steps through bilingual check with origin/main ahead, then the drift diff."""
        good_log = f"AUTHOR:{IDENTITY}\nCOMMITTER:{IDENTITY}\n"
        return [
            (has("rev-parse", "HEAD"), ok(HEAD + "\n")),
            (has("status", "--porcelain"), ok("")),
            (has("log"), ok(good_log)),
            (lambda a: "diff" in a and "base" in a and "origin/main" not in a, ok("scripts/kos/pr_flow.py\n")),
            (lambda a: "rev-parse" in a and any(str(x).startswith("refs/heads/") for x in a), ok(HEAD + "\n")),
            (has("ls-remote"), ok("")),
            (lambda a: "rev-parse" in a and "origin/main" in a and "--abbrev-ref" not in a, ok(ORIGIN_TIP + "\n")),
            (has("merge-base"), ok("")),
            (lambda a: "diff" in a and ORIGIN_TIP in a, ok(diff_output)),
        ]

    def test_same_module_drift_blocks_dry_run(self) -> None:
        runner = Queue(self._gate_steps("scripts/kos/kos_lock.py\n") + [(has("push"), ok(""))])
        self.assertEqual(FLOW.main(self._args(["--dry-run"]), runner=runner), 1)
        self.assertFalse(any("push" in call for call in runner.calls))
        payload = json.loads((self.log_dir / "open-feature-kos-pr-flow-001.json").read_text())
        self.assertIn("drift", payload["error"])
        self.assertIn("rebase", payload["error"].lower())

    def test_same_module_drift_blocks_push(self) -> None:
        runner = Queue(self._gate_steps("scripts/kos/pr_flow.py\n"))
        self.assertEqual(FLOW.main(self._args(), runner=runner), 1)
        self.assertFalse(any("push" in call for call in runner.calls))

    def test_cross_module_drift_passes_dry_run(self) -> None:
        runner = Queue(self._gate_steps("docs/kos/board.md\n"))
        self.assertEqual(FLOW.main(self._args(["--dry-run"]), runner=runner), 0)
        self.assertFalse(any("push" in call for call in runner.calls))

    def test_no_drift_passes_dry_run(self) -> None:
        good_log = f"AUTHOR:{IDENTITY}\nCOMMITTER:{IDENTITY}\n"
        runner = Queue(
            [
                (has("rev-parse", "HEAD"), ok(HEAD + "\n")),
                (has("status", "--porcelain"), ok("")),
                (has("log"), ok(good_log)),
                (lambda a: "diff" in a and "base" in a and "origin/main" not in a, ok("scripts/kos/pr_flow.py\n")),
                (lambda a: "rev-parse" in a and any(str(x).startswith("refs/heads/") for x in a), ok(HEAD + "\n")),
                (has("ls-remote"), ok("")),
                (lambda a: "rev-parse" in a and "origin/main" in a and "--abbrev-ref" not in a, ok("base\n")),
            ]
        )
        self.assertEqual(FLOW.main(self._args(["--dry-run"]), runner=runner), 0)
        self.assertFalse(any("push" in call for call in runner.calls))


if __name__ == "__main__":
    unittest.main()

class SkippingIsPendingRegression(unittest.TestCase):
    def test_skipping_is_not_a_completed_check(self):
        self.assertEqual(FLOW._pending_states([{"state": "skipping"}]), [{"state": "skipping"}])


class LandLockTests(unittest.TestCase):
    """KOS-LAND-LOCK-001: land main-checkout critical section is lock-guarded."""

    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.pm = self.root / "pm-log"
        self.logs = self.root / "land"
        self.lock = self.root / "land.lock"

    def tearDown(self) -> None:
        self.tmp.cleanup()

    def _land(self, extra=None):
        return [
            "land", "266", "--expect-head", HEAD, "--main-checkout", "/main",
            "--pm-log", str(self.pm), "--log-dir", str(self.logs),
            "--known-flaky", str(FLAKY),
            "--lock-file", str(self.lock),
        ] + (extra or [])

    def _holder(self, path, hold_seconds):
        # separate process holds the lock, then releases
        code = (
            "import fcntl,os,sys,time\n"
            "fd=os.open(%r,os.O_CREAT|os.O_RDWR)\n"
            "fcntl.flock(fd,fcntl.LOCK_EX)\n"
            "sys.stdout.write('HELD\\n');sys.stdout.flush()\n"
            "time.sleep(%r)\n"
            "fcntl.flock(fd,fcntl.LOCK_UN)\n" % (str(path), hold_seconds)
        )
        return subprocess.Popen([sys.executable, "-c", code], stdout=subprocess.PIPE, text=True)

    def _happy_queue(self):
        return Queue([
            (has("pr", "view"), _view()),
            *_snap(_pass_items()),
            *_classification_steps(),
            (has("pr", "view"), _view()),
            (has("autoMergeRequest,mergeStateStatus,headRefOid"), _ready()),
            (has("pr", "merge"), ok("merged")),
            (has("mergeCommit"), ok(json.dumps({"mergeCommit": {"oid": "c" * 40}}))),
            (has("fetch"), ok()),
            (has("--is-ancestor"), ok()), (has("--is-ancestor"), ok()),
            (has("--abbrev-ref"), ok("main")), (has("status"), ok()),
            (lambda a: "rev-parse" in a and "--abbrev-ref" not in a, ok("d" * 40 + "\n")),
            (has("--is-ancestor"), ok()),
            (has("--ff-only"), ok()),
            (lambda a: "rev-parse" in a and "--abbrev-ref" not in a, ok("e" * 40 + "\n")),
        ])

    def test_lock_timeout_fail_closed_no_main_checkout_writes(self) -> None:
        holder = self._holder(self.lock, 5)
        try:
            self.assertEqual(holder.stdout.readline().strip(), "HELD")
            runner = self._happy_queue()
            err = io.StringIO()
            with contextlib.redirect_stderr(err):
                code = FLOW.main(self._land(["--merge", "--lock-timeout", "1"]), runner=runner)
            self.assertEqual(code, 1)
            self.assertIn("land-lock-timeout", err.getvalue())
            # fail-closed: nothing touched the main checkout, no ff, no cleanup
            self.assertFalse(any("fetch" in c or "--ff-only" in c or "worktree" in c for c in runner.calls))
        finally:
            holder.kill()
            holder.wait()

    def test_lock_waits_then_succeeds_after_release(self) -> None:
        holder = self._holder(self.lock, 1)
        try:
            self.assertEqual(holder.stdout.readline().strip(), "HELD")
            runner = self._happy_queue()
            code = FLOW.main(self._land(["--merge", "--lock-timeout", "10"]), runner=runner)
            self.assertEqual(code, 0)
            self.assertTrue(any("--ff-only" in c for c in runner.calls))
            payload = json.loads((self.logs / "land-266.json").read_text())
            self.assertTrue(str(payload["ff"]).startswith("ff-only"))
        finally:
            holder.wait()

    def test_lock_released_after_normal_end_and_exception(self) -> None:
        # normal end: lock file must be immediately acquirable afterwards
        runner = self._happy_queue()
        self.assertEqual(FLOW.main(self._land(["--merge"]), runner=runner), 0)
        fd = os.open(self.lock, os.O_RDWR)
        try:
            fcntl.flock(fd, fcntl.LOCK_EX | fcntl.LOCK_NB)  # must not block
            fcntl.flock(fd, fcntl.LOCK_UN)
        finally:
            os.close(fd)

        # exception inside the critical section: lock still released via finally
        class ExplodingRunner(Queue):
            def run(self, argv, cwd=None, env=None):
                if "fetch" in argv:
                    raise RuntimeError("fetch exploded")
                return super().run(argv, cwd=cwd, env=env)

        boom = ExplodingRunner([(has("pr", "view"), _view()), *_snap(_pass_items()),
                                *_classification_steps(), (has("pr", "view"), _view()),
                                (has("autoMergeRequest,mergeStateStatus,headRefOid"), _ready()),
                                (has("pr", "merge"), ok("merged")),
                                (has("mergeCommit"), ok(json.dumps({"mergeCommit": {"oid": "c" * 40}})))])
        with self.assertRaises(RuntimeError):
            FLOW.main(self._land(["--merge"]), runner=boom)
        fd = os.open(self.lock, os.O_RDWR)
        try:
            fcntl.flock(fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
            fcntl.flock(fd, fcntl.LOCK_UN)
        finally:
            os.close(fd)

    def test_dry_run_takes_no_lock(self) -> None:
        fd = os.open(self.lock, os.O_CREAT | os.O_RDWR)
        try:
            fcntl.flock(fd, fcntl.LOCK_EX)
            runner = Queue([(has("view"), _view())])
            self.assertEqual(FLOW.main(self._land(["--dry-run", "--lock-timeout", "1"]), runner=runner), 0)
            self.assertFalse(any("checks" in c for c in runner.calls))
        finally:
            fcntl.flock(fd, fcntl.LOCK_UN)
            os.close(fd)

    def test_default_lock_anchor_is_main_checkout_git_dir(self) -> None:
        fake = self.root / "mainco"
        (fake / ".git").mkdir(parents=True)
        args = FLOW._parser().parse_args(
            ["land", "1", "--expect-head", HEAD, "--main-checkout", str(fake), "--pm-log", "x"]
        )
        self.assertEqual(FLOW._land_lock_path(args), fake / ".git" / "land.lock")


class _Clock:
    def __init__(self):
        self.now = 0.0
        self.sleeps = []
        self.prints = []

    def sleep(self, seconds):
        self.sleeps.append(seconds)
        self.now += seconds

    def print(self, line):
        self.prints.append(line)


class WaitCiTests(unittest.TestCase):
    """KOS-PR-WAIT-CLEANUP-001: low-frequency CI backoff wait."""

    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.pm = self.root / "pm-log"
        self.logs = self.root / "land"
        self.clock = _Clock()

    def tearDown(self) -> None:
        self.tmp.cleanup()

    def _wait(self, extra=None):
        return [
            "wait", "266",
            "--expect-head", HEAD,
            "--repo", "shchnk1103/Universe-Keyboard",
            "--known-flaky", str(FLAKY),
            "--pm-log", str(self.pm),
            "--log-dir", str(self.logs),
        ] + (extra or [])

    def _inject_clock(self):
        # pr_flow reads the injectable clock via module attribute
        FLOW._WAIT_CLOCK = self.clock

    def test_pending_then_pass_prints_change_once_and_returns_0(self) -> None:
        self._inject_clock()
        runner = Queue([
            (has("pr", "view"), _view()),
            _json_step([_job("build", "pending", "7", "8"), _job("test-app-keyboard", "pending", "7", "9")]),
            _json_step([_job("build", "pending", "7", "8"), _job("test-app-keyboard", "pending", "7", "9")]),
            _json_step([_job("build", "pass", "7", "8"), _job("test-app-keyboard", "pass", "7", "9")]),
            *_classification_steps(),
        ])
        code = FLOW.main(self._wait(["--wait-timeout", "60", "--poll-interval", "10"]), runner=runner)
        self.assertEqual(code, 0, code)
        # dedup: identical pending snapshots produce no repeated summary lines
        printed = self.clock.prints
        pending_lines = [x for x in printed if "pending" in x]
        self.assertEqual(len(pending_lines), 1, printed)
        pass_lines = [x for x in printed if "pass" in x or "green" in x.lower()]
        self.assertTrue(pass_lines, printed)
        self.assertNotEqual(self.clock.sleeps, [])

    def test_any_failure_fails_closed_immediately(self) -> None:
        self._inject_clock()
        runner = Queue([
            (has("pr", "view"), _view()),
            _json_step([_job("build", "pending", "7", "8")]),
            _json_step([_job("build", "fail", "7", "8")]),
        ])
        code = FLOW.main(self._wait(["--wait-timeout", "60"]), runner=runner)
        self.assertEqual(code, 1)
        payload = json.loads((self.logs / "land-266.json").read_text())
        self.assertEqual(payload["status"], "ci-failed")

    def test_timeout_fails_closed(self) -> None:
        self._inject_clock()
        steps = [(has("pr", "view"), _view())]
        for _ in range(4):
            steps.append(_json_step([_job("build", "pending", "7", "8")]))
        runner = Queue(steps)
        code = FLOW.main(self._wait(["--wait-timeout", "30", "--poll-interval", "10"]), runner=runner)
        self.assertEqual(code, 1)
        payload = json.loads((self.logs / "land-266.json").read_text())
        self.assertEqual(payload["status"], "wait-timeout")


class LandAutoCleanupTests(unittest.TestCase):
    """KOS-PR-WAIT-CLEANUP-001: post-ff auto cleanup tool invocation."""

    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.pm = self.root / "pm-log"
        self.logs = self.root / "land"
        self.tool = self.root / "stub-cleanup.sh"

    def tearDown(self) -> None:
        self.tmp.cleanup()

    def _land(self, extra=None):
        return [
            "land", "266", "--expect-head", HEAD, "--main-checkout", "/main",
            "--pm-log", str(self.pm), "--log-dir", str(self.logs),
            "--known-flaky", str(FLAKY),
            "--lock-file", str(self.root / "land.lock"),
        ] + (extra or [])

    def _happy_queue(self):
        return Queue([
            (has("pr", "view"), _view()),
            *_snap(_pass_items()),
            *_classification_steps(),
            (has("pr", "view"), _view()),
            (has("autoMergeRequest,mergeStateStatus,headRefOid"), _ready()),
            (has("pr", "merge"), ok("merged")),
            (has("mergeCommit"), ok(json.dumps({"mergeCommit": {"oid": "c" * 40}}))),
            (has("fetch"), ok()),
            (has("--is-ancestor"), ok()), (has("--is-ancestor"), ok()),
            (has("--abbrev-ref"), ok("main")), (has("status"), ok()),
            (lambda a: "rev-parse" in a and "--abbrev-ref" not in a, ok("d" * 40 + "\n")),
            (has("--is-ancestor"), ok()),
            (has("--ff-only"), ok()),
            (lambda a: "rev-parse" in a and "--abbrev-ref" not in a, ok("e" * 40 + "\n")),
            (has("bash"), ok()),
        ])

    def _write_stub(self, fail=False):
        body = "#!/usr/bin/env bash\necho ARGS: $@\n"
        if fail:
            body += "exit 4\n"
        self.tool.write_text(body, encoding="utf-8")
        self.tool.chmod(0o755)

    def test_auto_cleanup_invoked_after_ff(self) -> None:
        self._write_stub()
        runner = self._happy_queue()
        code = FLOW.main(self._land([
            "--merge", "--task-id", "KOS-DEMO-001",
            "--cleanup-tool", str(self.tool),
        ]), runner=runner)
        self.assertEqual(code, 0)
        calls = [c for c in runner.calls if any("stub-cleanup.sh" in str(part) for part in c)]
        self.assertEqual(len(calls), 1)
        self.assertIn("r", calls[0])
        self.assertIn("KOS-DEMO-001", calls[0])
        self.assertIn("--apply", calls[0])

    def test_no_cleanup_on_dry_run_or_no_merge(self) -> None:
        self._write_stub()
        runner = Queue([(has("pr", "view"), _view())])
        self.assertEqual(FLOW.main(self._land([
            "--dry-run", "--task-id", "KOS-DEMO-001", "--cleanup-tool", str(self.tool)
        ]), runner=runner), 0)
        runner2 = Queue([
            (has("pr", "view"), _view()),
            *_snap(_pass_items()),
            *_classification_steps(),
        ])
        self.assertEqual(FLOW.main(self._land([
            "--task-id", "KOS-DEMO-001", "--cleanup-tool", str(self.tool)
        ]), runner=runner2), 0)
        for r in (runner, runner2):
            self.assertFalse(any("stub-cleanup.sh" in c for c in r.calls))

    def test_no_cleanup_without_ff_success(self) -> None:
        self._write_stub()
        runner = Queue([
            (has("pr", "view"), _view()),
            *_snap(_pass_items()),
            *_classification_steps(),
            (has("pr", "view"), _view()),
            (has("autoMergeRequest,mergeStateStatus,headRefOid"), _ready()),
            (has("pr", "merge"), ok("merged")),
            (has("mergeCommit"), ok(json.dumps({"mergeCommit": {"oid": "c" * 40}}))),
            (has("fetch"), ok()),
            (has("--is-ancestor"), ok()), (has("--is-ancestor"), ok()),
            (has("--abbrev-ref"), ok("main")), (has("status"), ok(" M x\n")),
            (lambda a: "rev-parse" in a and "--abbrev-ref" not in a, ok("d" * 40 + "\n")),
        ])
        code = FLOW.main(self._land([
            "--merge", "--task-id", "KOS-DEMO-001", "--cleanup-tool", str(self.tool)
        ]), runner=runner)
        self.assertEqual(code, 0)  # dirty main -> ff skipped, not fatal
        self.assertFalse(any("stub-cleanup.sh" in str(part) for c in runner.calls for part in c))

    def test_empty_task_id_is_rejected(self) -> None:
        self._write_stub()
        runner = self._happy_queue()
        code = FLOW.main(self._land([
            "--merge", "--task-id", "   ", "--cleanup-tool", str(self.tool)
        ]), runner=runner)
        self.assertEqual(code, 0)
        self.assertFalse(any("stub-cleanup.sh" in str(part) for c in runner.calls for part in c))
        payload = json.loads((self.logs / "land-266.json").read_text())
        self.assertTrue(str(payload["ff"]).startswith("ff-only"))

    def test_missing_tool_warns_not_fatal(self) -> None:
        runner = self._happy_queue()
        code = FLOW.main(self._land([
            "--merge", "--task-id", "KOS-DEMO-001",
            "--cleanup-tool", str(self.root / "nope.sh"),
        ]), runner=runner)
        self.assertEqual(code, 0)
        payload = json.loads((self.logs / "land-266.json").read_text())
        self.assertTrue(str(payload["ff"]).startswith("ff-only"))

    def test_tool_failure_warns_not_fatal(self) -> None:
        self._write_stub(fail=True)
        runner = self._happy_queue()
        runner.steps[-1] = (has("bash"), fail("", 4))
        code = FLOW.main(self._land([
            "--merge", "--task-id", "KOS-DEMO-001",
            "--cleanup-tool", str(self.tool),
        ]), runner=runner)
        self.assertEqual(code, 0)
        self.assertTrue(any("stub-cleanup.sh" in str(part) for c in runner.calls for part in c))
