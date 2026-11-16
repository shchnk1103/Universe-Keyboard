#!/usr/bin/env python3
"""Tests for KOS O41 minimal relay loop (CURRENT.json atomic state machine, freeze, report-lint, kos-block.sh)."""
import concurrent.futures
import hashlib
import json
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

KOS_DIR = Path(__file__).resolve().parent.parent
REPO_ROOT = KOS_DIR.parent.parent
sys.path.insert(0, str(KOS_DIR))

import clauses_spec  # noqa: E402
import freeze  # noqa: E402


def _write(path: Path, text: str) -> Path:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")
    return path


def _run_py(script: str, args: list[str], env: dict[str, str] | None = None):
    merged_env = dict(os.environ)
    merged_env["PYTHONDONTWRITEBYTECODE"] = "1"
    if env:
        merged_env.update(env)
    return subprocess.run(
        [sys.executable, "-I", "-B", str(KOS_DIR / script), *args],
        capture_output=True,
        text=True,
        env=merged_env,
    )


class O41CurrentStateMachineTests(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.task_a = self.root / "TASK-A"
        self.task_b = self.root / "TASK-B"
        self.pkg1 = _write(self.task_a / "pkg-v1.md", "# pkg v1\n")
        self.pkg2 = _write(self.task_a / "pkg-v2.md", "# pkg v2\n")
        self.params1 = _write(self.task_a / "params-v1.txt", "params v1\n")
        self.params2 = _write(self.task_a / "params-v2.txt", "params v2\n")
        self.auth = _write(self.task_a / "auth.md", "Human auth\n")

    def tearDown(self) -> None:
        self.tmp.cleanup()

    def _dispatch(self, task_dir: Path, task_id: str, role: str, pkg: Path, params: Path, auth: Path, expect_rev: int = 0, claim_id: str | None = None):
        args = [
            "dispatch",
            "--task-dir", str(task_dir),
            "--task-id", task_id,
            "--active-step", "step-1",
            "--role", role,
            "--package-path", str(pkg),
            "--params-path", str(params),
            "--authorization-path", str(auth),
            "--updated-by", "Jack",
            "--expect-rev", str(expect_rev),
        ]
        if claim_id:
            args.extend(["--claim-id", claim_id])
        return _run_py("kos_current.py", args)

    def test_concurrent_dispatch_and_claim_and_task_isolation(self) -> None:
        # Two concurrent dispatches at expect_rev=0: exactly one succeeds, one fails with conflict
        with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:
            f1 = pool.submit(self._dispatch, self.task_a, "TASK-A", "Pete", self.pkg1, self.params1, self.auth, 0)
            f2 = pool.submit(self._dispatch, self.task_a, "TASK-A", "Pete", self.pkg1, self.params1, self.auth, 0)
            r1, r2 = f1.result(), f2.result()
        codes = sorted([r1.returncode, r2.returncode])
        self.assertEqual(codes, [0, 3], f"r1={r1.returncode}:{r1.stderr} r2={r2.returncode}:{r2.stderr}")

        # Different task dir TASK-B is completely isolated
        pkg_b = _write(self.task_b / "pkg-b.md", "# pkg b\n")
        params_b = _write(self.task_b / "params-b.txt", "params b\n")
        auth_b = _write(self.task_b / "auth-b.md", "auth b\n")
        rb = self._dispatch(self.task_b, "TASK-B", "Quinn", pkg_b, params_b, auth_b, 0)
        self.assertEqual(rb.returncode, 0, rb.stderr)

        # Two concurrent claims on TASK-A: exactly one succeeds, one is rejected
        with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:
            c1 = pool.submit(_run_py, "kos_current.py", ["claim", "--task-dir", str(self.task_a), "--role", "Pete", "--claimed-by", "Pete (A)"])
            c2 = pool.submit(_run_py, "kos_current.py", ["claim", "--task-dir", str(self.task_a), "--role", "Pete", "--claimed-by", "Pete (B)"])
            rc1, rc2 = c1.result(), c2.result()
        self.assertEqual(sorted([rc1.returncode, rc2.returncode]), [0, 5])

    def test_stale_entry_rejected_and_short_notice_locates_latest(self) -> None:
        self.assertEqual(self._dispatch(self.task_a, "TASK-A", "Pete", self.pkg1, self.params1, self.auth, 0).returncode, 0)
        self.assertEqual(self._dispatch(self.task_a, "TASK-A", "Pete", self.pkg2, self.params2, self.auth, 1).returncode, 0)

        # Stale pkg1 rejected
        r_stale = _run_py("kos_current.py", ["verify", "--task-dir", str(self.task_a), "--role", "Pete", "--package-path", str(self.pkg1)])
        self.assertEqual(r_stale.returncode, 7)
        self.assertIn("stale", r_stale.stderr)

        # Short notice (no --package-path) locates pkg2
        r_ok = _run_py("kos_current.py", ["verify", "--task-dir", str(self.task_a), "--role", "Pete"])
        self.assertEqual(r_ok.returncode, 0, r_ok.stderr)
        cur = json.loads((self.task_a / "CURRENT.json").read_text(encoding="utf-8"))
        self.assertEqual(cur["package_path"], str(self.pkg2.resolve()))
        self.assertEqual(cur["prev_entry"]["package_path"], str(self.pkg1.resolve()))

    def test_symlink_equivalent_path_accepted_and_different_target_rejected(self) -> None:
        self.assertEqual(self._dispatch(self.task_a, "TASK-A", "Pete", self.pkg1, self.params1, self.auth, 0).returncode, 0)
        self.assertEqual(self._dispatch(self.task_a, "TASK-A", "Pete", self.pkg2, self.params2, self.auth, 1).returncode, 0)

        link_dir = self.root / "alias_dir"
        os.symlink(self.task_a, link_dir)
        pkg2_via_link = link_dir / "pkg-v2.md"
        pkg1_via_link = link_dir / "pkg-v1.md"

        # Symlink path resolving to the same canonical target as pkg2 is accepted
        r_equiv = _run_py("kos_current.py", ["verify", "--task-dir", str(self.task_a), "--role", "Pete", "--package-path", str(pkg2_via_link)])
        self.assertEqual(r_equiv.returncode, 0, r_equiv.stderr)

        # Symlink path resolving to a different package (pkg1) is still rejected as stale
        r_diff = _run_py("kos_current.py", ["verify", "--task-dir", str(self.task_a), "--role", "Pete", "--package-path", str(pkg1_via_link)])
        self.assertEqual(r_diff.returncode, 7)
        self.assertIn("stale", r_diff.stderr)

        # Dispatching via symlinked paths stores canonical realpath in CURRENT.json
        r_disp = self._dispatch(self.task_a, "TASK-A", "Pete", pkg2_via_link, link_dir / "params-v2.txt", link_dir / "auth.md", 2)
        self.assertEqual(r_disp.returncode, 0, r_disp.stderr)
        cur = json.loads((self.task_a / "CURRENT.json").read_text(encoding="utf-8"))
        self.assertEqual(cur["package_path"], str(self.pkg2.resolve()))
        self.assertEqual(cur["params_path"], str(self.params2.resolve()))
        self.assertEqual(cur["authorization_path"], str(self.auth.resolve()))

    def test_claimed_blocks_takeover_recover_issues_new_token_and_blocks_old_session(self) -> None:
        self.assertEqual(self._dispatch(self.task_a, "TASK-A", "Lucy", self.pkg1, self.params1, self.auth, 0).returncode, 0)
        r_claim1 = _run_py("kos_current.py", ["claim", "--task-dir", str(self.task_a), "--role", "Lucy", "--claimed-by", "Lucy (Session1)"])
        self.assertEqual(r_claim1.returncode, 0, r_claim1.stderr)
        data1 = json.loads(r_claim1.stdout)
        old_claim_id = data1["claim_id"]

        # New session trying to claim/verify while CLAIMED is rejected
        r_takeover = _run_py("kos_current.py", ["claim", "--task-dir", str(self.task_a), "--role", "Lucy", "--claimed-by", "Lucy (Session2)"])
        self.assertEqual(r_takeover.returncode, 5)
        self.assertIn("Lucy (Session1)", r_takeover.stderr)

        # Non-Jack or missing --recover is rejected
        r_bad_rec = _run_py("kos_current.py", [
            "recover", "--task-dir", str(self.task_a), "--expect-rev", "2",
            "--updated-by", "Lucy", "--resume-from-report", str(self.task_a / "rep.md"), "--recover",
        ])
        self.assertEqual(r_bad_rec.returncode, 6)

        # Jack --recover succeeds, invalidates old claim_id, sets resume_from_report
        rep_path = str(self.task_a / "executor-report.md")
        r_rec = _run_py("kos_current.py", [
            "recover", "--task-dir", str(self.task_a), "--expect-rev", "2",
            "--updated-by", "Jack（PM）", "--resume-from-report", rep_path, "--reason", "quota exhausted", "--recover",
        ])
        self.assertEqual(r_rec.returncode, 0, r_rec.stderr)
        rec_data = json.loads(r_rec.stdout)
        self.assertEqual(rec_data["state"], "READY_TO_DISPATCH")
        self.assertEqual(rec_data["resume_from_report"], rep_path)
        self.assertIsNone(rec_data["claim_id"])

        # Session 2 claims with new token
        r_claim2 = _run_py("kos_current.py", ["claim", "--task-dir", str(self.task_a), "--role", "Lucy", "--claimed-by", "Lucy (Session2)"])
        self.assertEqual(r_claim2.returncode, 0, r_claim2.stderr)
        new_claim_id = json.loads(r_claim2.stdout)["claim_id"]
        self.assertNotEqual(new_claim_id, old_claim_id)

        # Resurrected Session 1 trying to complete with old claim_id or old rev is rejected
        r_old_comp = _run_py("kos_current.py", [
            "complete", "--task-dir", str(self.task_a), "--expect-rev", "4",
            "--claim-id", old_claim_id, "--updated-by", "Lucy (Session1)",
        ])
        self.assertEqual(r_old_comp.returncode, 4)

    def test_verify_rejects_wrong_role_and_sha_mismatch(self) -> None:
        self.assertEqual(self._dispatch(self.task_a, "TASK-A", "Quinn", self.pkg1, self.params1, self.auth, 0).returncode, 0)
        r_role = _run_py("kos_current.py", ["verify", "--task-dir", str(self.task_a), "--role", "Pete"])
        self.assertEqual(r_role.returncode, 6)

        # Tamper package file after dispatch
        self.pkg1.write_text("# tampered\n", encoding="utf-8")
        r_sha = _run_py("kos_current.py", ["verify", "--task-dir", str(self.task_a), "--role", "Quinn"])
        self.assertEqual(r_sha.returncode, 8)
        self.assertIn("package_sha256 mismatch", r_sha.stderr)

    def test_missing_auth_and_kos_block_normal_and_upgrade_relay(self) -> None:
        missing_auth = self.task_a / "missing-auth.md"
        r_no_auth = self._dispatch(self.task_a, "TASK-A", "Pete", self.pkg1, self.params1, missing_auth, 0)
        self.assertEqual(r_no_auth.returncode, 2)

        # Normal relay via kos-block.sh
        params_out = self.task_a / "params-next.txt"
        block_out = self.task_a / "block-next.txt"
        r_block = subprocess.run(
            [
                "bash", str(KOS_DIR / "kos-block.sh"),
                "Quinn（Quality）", "独立质量复核", str(self.pkg1), str(params_out), str(block_out),
                "--task-dir", str(self.task_a),
                "--task-id", "TASK-A",
                "--active-step", "quality-r1",
                "--role", "Quinn",
                "--auth-path", str(self.auth),
                "--expect-rev", "0",
                "--updated-by", "Pete",
            ],
            capture_output=True,
            text=True,
        )
        self.assertEqual(r_block.returncode, 0, r_block.stderr)
        cur = json.loads((self.task_a / "CURRENT.json").read_text(encoding="utf-8"))
        self.assertEqual(cur["state"], "READY_TO_DISPATCH")
        self.assertEqual(cur["role"], "Quinn")

        # Claim then upgrade to PM blocks subsequent verify
        rc = _run_py("kos_current.py", ["claim", "--task-dir", str(self.task_a), "--role", "Quinn", "--claimed-by", "Quinn (Test)"])
        self.assertEqual(rc.returncode, 0)
        cid = json.loads(rc.stdout)["claim_id"]
        ru = _run_py("kos_current.py", [
            "upgrade", "--task-dir", str(self.task_a), "--expect-rev", "2",
            "--claim-id", cid, "--updated-by", "Quinn (Test)", "--reason", "missing device",
        ])
        self.assertEqual(ru.returncode, 0)
        rv = _run_py("kos_current.py", ["verify", "--task-dir", str(self.task_a), "--role", "Quinn"])
        self.assertEqual(rv.returncode, 5)
        self.assertIn("UPGRADED_TO_PM", rv.stderr)


class O41ClausesAndLintTests(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)

    def tearDown(self) -> None:
        self.tmp.cleanup()

    def test_clauses_doc_and_spec_in_sync(self) -> None:
        doc = (REPO_ROOT / "docs" / "kos" / "pm-packet-clauses.md").read_text(encoding="utf-8")
        for marker in clauses_spec.CLAUSES_DOC_SYNC_MARKERS:
            self.assertIn(marker, doc, f"pm-packet-clauses.md missing marker: {marker}")

    def test_freeze_accepts_three_line_and_legacy_and_rejects_neither(self) -> None:
        base_body = (
            "**你的角色：Executor。你不是 PM。写入被拒即停。不写 /tmp。"
            "授权原文另存 reports/auth.md。报告 reports/out.md。**\n"
        )
        three_line = base_body + "结论：DONE\n下一位交付：Pete\n报告：/x + sha\n"
        legacy = base_body + "最终消息只写一句话。\n"
        neither = base_body + "没有结束格式。\n"

        self.assertEqual(freeze.lint_problems(three_line), [])
        self.assertEqual(freeze.lint_problems(legacy), [])
        self.assertNotEqual(freeze.lint_problems(neither), [])

    def test_report_lint_o41_relay_section(self) -> None:
        no_relay = _write(self.root / "no_relay.md", "DONE\nLucy（Executor）；运行时身份 Test\n摘要。\n")
        r1 = _run_py("kos-report-lint.py", ["--require-o41", str(no_relay)])
        self.assertEqual(r1.returncode, 1)
        self.assertIn("缺少 O41 接力节", r1.stdout)

        bad_fail = _write(
            self.root / "bad_fail.md",
            "BLOCKED\nLucy（Executor）；运行时身份 Test\n\n## 下一站接力（O41）\n- next_role: Quinn\n",
        )
        r2 = _run_py("kos-report-lint.py", ["--require-o41", str(bad_fail)])
        self.assertEqual(r2.returncode, 1)
        self.assertIn("必须交 Jack", r2.stdout)

        ok_done = _write(
            self.root / "ok_done.md",
            "DONE\nLucy（Executor）；运行时身份 Test\n\n## 下一站接力（O41）\n- next_role: Pete（Preflight）\n- 状态：块已生成未派发（待 Human 通知）\n",
        )
        r3 = _run_py("kos-report-lint.py", ["--require-o41", str(ok_done)])
        self.assertEqual(r3.returncode, 0, r3.stdout)


class O41ActivationGapFixTests(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.task_dir = self.root / "TASK-FIX"
        self.pkg1 = _write(self.task_dir / "pkg-1.md", "# pkg 1\n")
        self.pkg2 = _write(self.task_dir / "pkg-2.md", "# pkg 2\n")
        self.params1 = _write(self.task_dir / "params-1.txt", "p1\n")
        self.auth = _write(self.task_dir / "auth.md", "auth\n")

    def tearDown(self) -> None:
        self.tmp.cleanup()

    def test_claim_rechecks_input_hashes_inside_lock(self) -> None:
        r_d = _run_py("kos_current.py", [
            "dispatch", "--task-dir", str(self.task_dir), "--task-id", "TASK-FIX",
            "--active-step", "step-1", "--role", "Wendy", "--package-path", str(self.pkg1),
            "--params-path", str(self.params1), "--authorization-path", str(self.auth),
            "--updated-by", "Jack", "--expect-rev", "0",
        ])
        self.assertEqual(r_d.returncode, 0, r_d.stderr)
        # verify passes before swap
        self.assertEqual(_run_py("kos_current.py", ["verify", "--task-dir", str(self.task_dir), "--role", "Wendy"]).returncode, 0)
        # Swap package file between verify and claim
        self.pkg1.write_text("# swapped after verify\n", encoding="utf-8")
        r_c = _run_py("kos_current.py", ["claim", "--task-dir", str(self.task_dir), "--role", "Wendy", "--claimed-by", "Wendy (Test)"])
        self.assertEqual(r_c.returncode, 8)
        self.assertIn("package_sha256 mismatch", r_c.stderr)

    def test_live_kos_dir_write_denied_by_default(self) -> None:
        fake_live_root = self.root / "live_kos"
        live_task = fake_live_root / "REAL-TASK-001"
        live_task.mkdir(parents=True)
        r = _run_py("kos_current.py", [
            "dispatch", "--task-dir", str(live_task), "--task-id", "REAL-TASK-001",
            "--active-step", "step-1", "--role", "Wendy", "--package-path", str(self.pkg1),
            "--params-path", str(self.params1), "--authorization-path", str(self.auth),
            "--updated-by", "Jack", "--expect-rev", "0",
        ], env={"KOS_WORK_ROOT": str(fake_live_root)})
        self.assertEqual(r.returncode, 9)
        self.assertIn("refusing write to live/shared task dir", r.stderr)

    def test_handoff_orchestrator_normal_upgrade_and_three_line_render(self) -> None:
        self.assertEqual(_run_py("kos_current.py", [
            "dispatch", "--task-dir", str(self.task_dir), "--task-id", "TASK-FIX",
            "--active-step", "step-1", "--role", "Wendy", "--package-path", str(self.pkg1),
            "--params-path", str(self.params1), "--authorization-path", str(self.auth),
            "--updated-by", "Jack", "--expect-rev", "0",
        ]).returncode, 0)
        rc = _run_py("kos_current.py", ["claim", "--task-dir", str(self.task_dir), "--role", "Wendy", "--claimed-by", "Wendy (Test)"])
        self.assertEqual(rc.returncode, 0, rc.stderr)
        cid1 = json.loads(rc.stdout)["claim_id"]

        # Normal relay to Pete
        rep_done = _write(self.task_dir / "rep-done.md", "DONE\nWendy（Executor）；运行时身份 Test\n\n## 下一站接力（O41）\n- next_role: Pete\n")
        r_h1 = _run_py("kos_handoff.py", [
            "handoff", "--task-dir", str(self.task_dir), "--task-id", "TASK-FIX",
            "--expect-rev", "2", "--claim-id", cid1, "--updated-by", "Wendy (Test)",
            "--report-path", str(rep_done), "--summary", "step-1 done",
            "--next-role", "Pete", "--next-step", "step-2",
            "--next-pkg", str(self.pkg2), "--next-params", str(self.task_dir / "params-2.txt"),
            "--next-block", str(self.task_dir / "block-2.txt"), "--auth-path", str(self.auth),
        ])
        self.assertEqual(r_h1.returncode, 0, r_h1.stderr)
        sections = r_h1.stdout.strip().split("\n\n", 3)
        self.assertEqual(len(sections), 4)
        out_lines = sections[:3]
        self.assertEqual(sections[3], "```text\n" + (self.task_dir / "block-2.txt").read_text(encoding="utf-8").rstrip("\r\n") + "\n```")
        self.assertNotIn(" + ", r_h1.stdout)
        self.assertTrue(out_lines[0].startswith("结论：DONE，"))
        self.assertTrue(out_lines[1].startswith("下一位交付：Pete，"))
        self.assertRegex(out_lines[2], r"^报告：/.+（SHA-256 [0-9a-f]{64}）$")
        cur = json.loads((self.task_dir / "CURRENT.json").read_text(encoding="utf-8"))
        self.assertEqual(cur["state"], "READY_TO_DISPATCH")
        self.assertEqual(cur["role"], "Pete")

        # Pete claims and then hits BLOCKED -> upgrades to Jack (PM)
        rc2 = _run_py("kos_current.py", ["claim", "--task-dir", str(self.task_dir), "--role", "Pete", "--claimed-by", "Pete (Test)"])
        self.assertEqual(rc2.returncode, 0, rc2.stderr)
        cid2 = json.loads(rc2.stdout)["claim_id"]
        rep_blk = _write(self.task_dir / "rep-blk.md", "BLOCKED\nPete（Preflight）；运行时身份 Test\n\n## 下一站接力（O41）\n- next_role: Jack（PM）\n")
        r_h2 = _run_py("kos_handoff.py", [
            "handoff", "--task-dir", str(self.task_dir), "--task-id", "TASK-FIX",
            "--expect-rev", "4", "--claim-id", cid2, "--updated-by", "Pete (Test)",
            "--report-path", str(rep_blk), "--summary", "missing dep", "--reason", "missing dep",
        ])
        self.assertEqual(r_h2.returncode, 0, r_h2.stderr)
        self.assertNotIn(" + ", r_h2.stdout)
        self.assertIn("下一位交付：Jack（PM），", r_h2.stdout)
        cur2 = json.loads((self.task_dir / "CURRENT.json").read_text(encoding="utf-8"))
        self.assertEqual(cur2["state"], "UPGRADED_TO_PM")

    def test_render_three_line_format_no_plus_no_dup_no_dangling_punctuation(self) -> None:
        rep = _write(self.task_dir / "rep-render.md", "PASS\nQuinn\n")
        # 1. next_detail already starts with next_role -> no duplicate recipient, no ' + ', no hash in conclusion
        r1 = _run_py("kos_handoff.py", [
            "render", "--status", "PASS", "--summary", "复核通过",
            "--next-role", "Quinn（Quality）",
            "--next-detail", "Quinn（Quality），整轮复核 r2 候选",
            "--report-path", str(rep),
        ])
        self.assertEqual(r1.returncode, 0, r1.stderr)
        sections1 = r1.stdout.strip().split("\n\n", 3)
        self.assertEqual(len(sections1), 4)
        lines1 = sections1[:3]
        self.assertTrue(sections1[3].startswith("```text\n交回：Quinn（Quality）\n"))
        self.assertTrue(sections1[3].endswith("\n```"))
        self.assertNotIn(" + ", r1.stdout)
        self.assertEqual(lines1[0], "结论：PASS，复核通过")
        self.assertEqual(lines1[1], "下一位交付：Quinn（Quality），整轮复核 r2 候选")
        self.assertNotRegex(lines1[0], r"[0-9a-f]{64}")
        self.assertRegex(lines1[2], r"^报告：/.+（SHA-256 [0-9a-f]{64}）$")

        # 2. Empty summary and empty next_detail -> no dangling comma
        r2 = _run_py("kos_handoff.py", [
            "render", "--status", "DONE", "--summary", "",
            "--next-role", "Jack（PM）", "--next-detail", "",
            "--report-path", str(rep),
        ])
        self.assertEqual(r2.returncode, 0, r2.stderr)
        sections2 = r2.stdout.strip().split("\n\n", 3)
        self.assertEqual(len(sections2), 4)
        lines2 = sections2[:3]
        self.assertIn("```text\n交回：Jack（PM）\n事项：\n报告：", sections2[3])
        self.assertTrue(sections2[3].endswith("\n```"))
        self.assertNotIn(" + ", r2.stdout)
        self.assertEqual(lines2[0], "结论：DONE")
        self.assertEqual(lines2[1], "下一位交付：Jack（PM）")

    def test_render_entry_and_missing_files(self) -> None:
        rep = _write(self.task_dir / "report.md", "DONE\nLucy\n")
        entry = _write(self.task_dir / "entry.md", "entry contents\n")
        args = ["render", "--status", "DONE", "--summary", "完成", "--next-role", "Quinn",
                "--next-detail", "复核", "--task-title", "独立复核", "--report-path", str(rep)]
        result = _run_py("kos_handoff.py", args + ["--entry-path", str(entry)])
        self.assertEqual(result.returncode, 0, result.stderr)
        parts = result.stdout.strip().split("\n\n", 3)
        self.assertEqual(len(parts), 4)
        self.assertNotIn(" + ", result.stdout)
        self.assertEqual(parts[3], "```text\n派给：Quinn\n任务：独立复核\n开工文档：" + str(entry.resolve())
                         + "\nSHA-256：" + hashlib.sha256(entry.read_bytes()).hexdigest() + "\n授权，直接执行\n```")
        self.assertEqual(_run_py("kos_handoff.py", args + ["--entry-path", str(entry) + ".missing"]).returncode, 2)
        self.assertEqual(_run_py("kos_handoff.py", args + ["--block-path", str(entry) + ".missing"]).returncode, 2)

    def test_handoff_terminal_complete_branch(self) -> None:
        self.assertEqual(_run_py("kos_current.py", [
            "dispatch", "--task-dir", str(self.task_dir), "--task-id", "TASK-FIX",
            "--active-step", "final-step", "--role", "Wendy", "--package-path", str(self.pkg1),
            "--params-path", str(self.params1), "--authorization-path", str(self.auth),
            "--updated-by", "Jack", "--expect-rev", "0",
        ]).returncode, 0)
        rc = _run_py("kos_current.py", ["claim", "--task-dir", str(self.task_dir), "--role", "Wendy", "--claimed-by", "Wendy (Term)"])
        self.assertEqual(rc.returncode, 0, rc.stderr)
        cid = json.loads(rc.stdout)["claim_id"]

        rep_term = _write(self.task_dir / "rep-term.md", "DONE\nWendy（Executor）；运行时身份 Test\n\n## 下一站接力（O41）\n- next_role: Jack（PM）\n")
        r_term = _run_py("kos_handoff.py", [
            "handoff", "--task-dir", str(self.task_dir), "--task-id", "TASK-FIX",
            "--expect-rev", "2", "--claim-id", cid, "--updated-by", "Wendy (Term)",
            "--report-path", str(rep_term), "--summary", "terminal step done", "--terminal",
        ])
        self.assertEqual(r_term.returncode, 0, r_term.stderr)
        sections = r_term.stdout.strip().split("\n\n", 3)
        self.assertEqual(len(sections), 4)
        lines = sections[:3]
        self.assertTrue(sections[3].startswith("```text\n交回：Jack（PM）\n"))
        self.assertTrue(sections[3].endswith("\n```"))
        self.assertNotIn(" + ", r_term.stdout)
        self.assertEqual(lines[0], "结论：DONE，terminal step done")
        self.assertTrue(lines[1].startswith("下一位交付：Jack（PM），"))
        self.assertRegex(lines[2], r"^报告：/.+（SHA-256 [0-9a-f]{64}）$")
        cur = json.loads((self.task_dir / "CURRENT.json").read_text(encoding="utf-8"))
        self.assertEqual(cur["state"], "COMPLETED")
        self.assertIsNone(cur["claim_id"])

    def test_o62_non_passing_status_rejects_entry_or_block_path(self) -> None:
        rep = _write(self.task_dir / "rep-fail.md", "CHANGES_REQUESTED\nQuinn\n")
        entry = _write(self.task_dir / "quinn-entry.md", "# Quinn：复核入口\n")
        block = _write(self.task_dir / "block.txt", "派给：Quinn\n")
        for status in ("CHANGES_REQUESTED", "FAIL", "PARTIAL", "BLOCKED", "STOPPED"):
            r_entry = _run_py("kos_handoff.py", [
                "render", "--status", status, "--summary", "rejected",
                "--next-role", "Quinn", "--next-detail", "复核",
                "--report-path", str(rep), "--entry-path", str(entry),
            ])
            self.assertEqual(r_entry.returncode, 2, f"status={status} should fail")
            self.assertIn(f"STOPPED: non-passing status ({status})", r_entry.stderr)

            r_block = _run_py("kos_handoff.py", [
                "render", "--status", status, "--summary", "rejected",
                "--next-role", "Quinn", "--next-detail", "复核",
                "--report-path", str(rep), "--block-path", str(block),
            ])
            self.assertEqual(r_block.returncode, 2, f"status={status} block_path should fail")
            self.assertIn(f"STOPPED: non-passing status ({status})", r_block.stderr)

    def test_o62_entry_path_role_mismatch_rejected(self) -> None:
        rep = _write(self.task_dir / "rep-pass.md", "PASS\nQuinn\n")
        alex_entry = _write(self.task_dir / "alex-entry.md", "# Alex：架构复核入口\n")
        r_mismatch = _run_py("kos_handoff.py", [
            "render", "--status", "PASS", "--summary", "ok",
            "--next-role", "Nick", "--next-detail", "设计",
            "--report-path", str(rep), "--entry-path", str(alex_entry),
        ])
        self.assertEqual(r_mismatch.returncode, 2)
        self.assertIn("STOPPED: entry_path role mismatch", r_mismatch.stderr)

    def test_o62_matching_role_and_passing_status_succeeds(self) -> None:
        rep = _write(self.task_dir / "rep-done.md", "DONE\nLucy\n")
        quinn_entry = _write(self.task_dir / "quinn-entry.md", "# Quinn：独立复核入口\n")
        r_ok = _run_py("kos_handoff.py", [
            "render", "--status", "DONE", "--summary", "守卫实现完成",
            "--next-role", "Quinn（Quality·独立复核）",
            "--next-detail", "独立复核 O62 守卫",
            "--report-path", str(rep), "--entry-path", str(quinn_entry),
            "--task-title", "[KOS-O62] 复核",
        ])
        self.assertEqual(r_ok.returncode, 0, r_ok.stderr)
        self.assertIn("派给：Quinn（Quality·独立复核）", r_ok.stdout)
        self.assertIn("授权，直接执行", r_ok.stdout)


if __name__ == "__main__":
    unittest.main()
