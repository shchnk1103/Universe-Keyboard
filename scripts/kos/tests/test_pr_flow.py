"""pr_flow open/land behavior with an injected command runner. No network."""
from __future__ import annotations

import json
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
    def test_fixture_parses_known_case_and_error_quote(self) -> None:
        log = FIXTURE.read_text(encoding="utf-8")
        cases = FLOW._parse_cases(log)
        self.assertEqual([name for name, _quote in cases], [CASE])
        quote = cases[0][1]
        self.assertLessEqual(len(quote), 300)
        self.assertTrue(quote.startswith("error:"))
        self.assertIn(quote, log)
        self.assertIn("stage=read-after-barrier", quote)


class OpenTests(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        root = Path(self.tmp.name)
        self.files = root / "files.txt"
        self.files.write_text("scripts/kos/pr_flow.py\n", encoding="utf-8")
        self.body = root / "body.md"
        self.body.write_text("Ship the helper.\n", encoding="utf-8")
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
            "title",
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
                (has("ls-remote"), ok("")),
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
                (has("ls-remote"), ok("")),
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
                (has("ls-remote"), ok("")),
            ]
        )
        self.assertEqual(FLOW.main(self._args(["--dry-run"]), runner=runner), 0)
        self.assertFalse(any("push" in call for call in runner.calls))


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
    return [_job("build", "pass", "5", "6")]


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
                (has("pr", "view"), _view()),
                (has("autoMergeRequest,mergeStateStatus,headRefOid"), _ready()),
                (has("pr", "merge"), ok("merged")),
                (has("mergeCommit"), merge_json),
                (has("--abbrev-ref"), ok("feature/x\n")),
                (has("status"), ok("")),
            ]
        )
        self.assertEqual(FLOW.main(self._land(["--merge"]), runner=not_main), 0)
        self.assertFalse(any("fetch" in call for call in not_main.calls))

        dirty = Queue(
            [
                (has("pr", "view"), _view()),
                *_snap(_pass_items()),
                (has("pr", "view"), _view()),
                (has("autoMergeRequest,mergeStateStatus,headRefOid"), _ready()),
                (has("pr", "merge"), ok("merged")),
                (has("mergeCommit"), merge_json),
                (has("--abbrev-ref"), ok("main\n")),
                (has("status"), ok(" M docs/kos/README.md\n")),
            ]
        )
        self.assertEqual(FLOW.main(self._land(["--merge"]), runner=dirty), 0)
        self.assertFalse(any("fetch" in call for call in dirty.calls))

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
        prefix = [(has("view"), _view()), *_snap([_job("build", "pass", "", "")]), (has("view"), _view())]
        for ready in [_ready(auto={"enabledAt": "now"}), _ready(state="BLOCKED"), _ready(head=OTHER)]:
            runner = Queue(prefix + [(has("autoMergeRequest,mergeStateStatus,headRefOid"), ready)])
            self.assertEqual(FLOW.main(self._land(["--merge"]), runner=runner), 1)
            self.assertFalse(any(c[1:3] == ["pr", "merge"] for c in runner.calls))
        for ancestor, fast, expected, marker in [(fail("", 1), None, 0, "skipped:"), (ok(), fail("merge failed"), 1, "failed:")]:
            steps = prefix + [(has("autoMergeRequest,mergeStateStatus,headRefOid"), _ready()),
                (has("pr", "merge"), ok("merged")), (has("mergeCommit"), ok('{"mergeCommit":{"oid":"c"}}')),
                (has("--abbrev-ref"), ok("main")), (has("status"), ok()), (has("fetch"), ok()),
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
        runner = Queue([(has("view"), _view()), *_snap([_job("build", "pass", "", "")]),
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

    def test_skipping_is_not_a_failure(self) -> None:
        runner = Queue(
            [
                (has("pr", "view"), _view()),
                *_snap([_job("build", "pass", "5", "6"), _job("optional", "skipping", "5", "7")]),
            ]
        )
        self.assertEqual(FLOW.main(self._land(), runner=runner), 0)
        self.assertFalse(any("rerun" in call for call in runner.calls))
        payload = json.loads((self.logs / "land-266.json").read_text())
        self.assertEqual(payload["status"], "green-no-merge")

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
                *_snap([_job("build", "pass", "5", "6")]),
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


if __name__ == "__main__":
    unittest.main()
