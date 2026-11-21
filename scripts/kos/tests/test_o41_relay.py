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
            "DONE\nLucy（Executor）；运行时身份 Test\n\n## 下一站接力（O41）\n- next_role: Pete（Preflight）\n- next_step: 继续预检\n- 状态：块已生成未派发（待 Human 通知）\n\n```text\n交回：Pete（Preflight）\n事项：继续\n```\n",
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
        rep_done = _write(self.task_dir / "rep-done.md", "DONE\nWendy（Executor）；运行时身份 Test\n\n## 下一站接力（O41）\n- next_role: Pete\n- next_step: step-2\n\n```text\n交回：Pete\n事项：step-2\n```\n")
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
        rep_blk = _write(self.task_dir / "rep-blk.md", "BLOCKED\nPete（Preflight）；运行时身份 Test\n\n## 下一站接力（O41）\n- next_role: Jack（PM）\n- next_step: 人工处理依赖\n\n```text\n交回：Jack（PM）\n事项：依赖\n```\n")
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

        rep_term = _write(self.task_dir / "rep-term.md", "DONE\nWendy（Executor）；运行时身份 Test\n\n## 下一站接力（O41）\n- next_role: Jack（PM）\n- next_step: 收尾确认\n\n```text\n交回：Jack（PM）\n事项：收尾\n```\n")
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




class RelayQualityTests(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.repo = self.root / "repo"
        self.repo.mkdir()
        self.template_src = KOS_DIR / "quality_relay_template.md"
        self.identity = "Cowork 3P <cowork-3p@localhost>"

    def tearDown(self) -> None:
        self.tmp.cleanup()

    def _git(self, *args, env_extra=None):
        env = dict(os.environ)
        env.update({
            "GIT_AUTHOR_NAME": "Cowork 3P", "GIT_AUTHOR_EMAIL": "cowork-3p@localhost",
            "GIT_COMMITTER_NAME": "Cowork 3P", "GIT_COMMITTER_EMAIL": "cowork-3p@localhost",
            "GIT_CONFIG_GLOBAL": "/dev/null", "GIT_CONFIG_SYSTEM": "/dev/null",
        })
        if env_extra:
            env.update(env_extra)
        return subprocess.run(["git", "-C", str(self.repo), *args], capture_output=True, text=True, env=env)

    def _init_repo(self, packet_text: str, report_text: str, extra_commits: int = 0):
        self._git("init", "-b", "main")
        (self.repo / ".kos").mkdir()
        (self.repo / ".kos/project.json").write_text("{}\n", encoding="utf-8")
        (self.repo / "base.txt").write_text("base\n", encoding="utf-8")
        self._git("add", ".")
        self._git("commit", "-m", "base")
        self.base = self._git("rev-parse", "HEAD").stdout.strip()
        packet = _write(self.root / "packet.md", packet_text)
        self.packet = packet
        (self.repo / "tool.py").write_text("x = 1\n", encoding="utf-8")
        (self.repo / "out.log").write_text("log line\n", encoding="utf-8")
        self._git("add", ".")
        self._git("commit", "-m", "work")
        for i in range(extra_commits):
            (self.repo / f"extra{i}.txt").write_text(str(i), encoding="utf-8")
            self._git("add", ".")
            self._git("commit", "-m", f"extra {i}")
        report = _write(self.root / "report.md", report_text)
        return packet, report

    def _pick_stub(self, name):
        stub = self.root / "pick.py"
        stub.write_text(
            "import sys\n"
            f"print('PICK [Quality]: {name}（Quality | 上次：-）')\n",
            encoding="utf-8")
        return stub

    def _run_relay(self, packet, report, pick_stub=None, extra=None):
        args = [
            "relay-quality",
            "--report", str(report),
            "--packet", str(packet),
            "--base", self.base,
            "--repo", str(self.repo),
            "--board", pick_stub if pick_stub else sys.executable,
            "--board-args", json.dumps(["-c", "print('PICK [Quality]: Quinn（Quality | -)')"]),
        ]
        if pick_stub:
            args = [
                "relay-quality",
                "--report", str(report),
                "--packet", str(packet),
                "--base", self.base,
                "--repo", str(self.repo),
                "--board", sys.executable,
                "--board-args", json.dumps([str(pick_stub)]),
            ]
        if extra:
            args.extend(extra)
        return _run_py("kos_handoff.py", args)

    GOOD_PACKET = (
        "Executor（代码）；你不是 PM\n\n"
        "# 任务包：示例\n\n"
        "- **包头档位**：`code-fix`\n"
        "- **复核重点**：\n"
        "  1. 检查一切。\n"
    )
    GOOD_REPORT = (
        "DONE\n"
        "Cole（Executor）；运行时身份 Codex。\n\n"
        "## 下一站接力（O41）\n- next_role：Quinn（Quality）\n- next_step：复核实现\n"
        "\n```text\n交回：Quinn（Quality）\n事项：复核\n```\n"
    )

    def _good_report_with_logs(self):
        report = _write(
            self.root / "report.md",
            self.GOOD_REPORT
            + f"\n日志 {self.repo / 'out.log'} SHA-256 `{hashlib.sha256((self.repo / 'out.log').read_bytes()).hexdigest()}`\n")
        return report

    def test_passing_path_emits_quality_block(self) -> None:
        packet, report = self._init_repo(self.GOOD_PACKET, self.GOOD_REPORT)
        report = self._good_report_with_logs()
        result = self._run_relay(packet, report)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("Quinn", result.stdout)
        self.assertIn("SHA-256", result.stdout)

    def test_review_focus_is_verbatim(self) -> None:
        packet, report = self._init_repo(self.GOOD_PACKET, self.GOOD_REPORT)
        report = self._good_report_with_logs()
        result = self._run_relay(packet, report)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        written = Path(result.stdout.split("质检块：", 1)[1].split("（", 1)[0].strip())
        self.assertIn("1. 检查一切。", written.read_text(encoding="utf-8"))

    def _expect_pm(self, result) -> None:
        self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("Jack", result.stdout + result.stderr)

    def test_feature_packet_falls_back(self) -> None:
        packet, report = self._init_repo(self.GOOD_PACKET.replace("`code-fix`", "`feature`"), self.GOOD_REPORT)
        report = self._good_report_with_logs()
        self._expect_pm(self._run_relay(packet, report))

    def test_non_done_status_falls_back(self) -> None:
        packet, report = self._init_repo(self.GOOD_PACKET, self.GOOD_REPORT)
        report = self._good_report_with_logs()
        report.write_text(report.read_text(encoding="utf-8").replace("DONE", "PARTIAL", 1), encoding="utf-8")
        self._expect_pm(self._run_relay(packet, report))

    def test_two_commits_fall_back(self) -> None:
        packet, report = self._init_repo(self.GOOD_PACKET, self.GOOD_REPORT, extra_commits=1)
        report = self._good_report_with_logs()
        self._expect_pm(self._run_relay(packet, report))

    def test_identity_mismatch_falls_back(self) -> None:
        packet, report = self._init_repo(self.GOOD_PACKET, self.GOOD_REPORT)
        report = self._good_report_with_logs()
        self._expect_pm(self._run_relay(packet, report, extra=["--expect-identity", "Someone Else <x@y>"]))

    def test_bad_log_hash_falls_back(self) -> None:
        packet, report = self._init_repo(self.GOOD_PACKET, self.GOOD_REPORT)
        bad = _write(
            self.root / "report.md",
            self.GOOD_REPORT + f"\n日志 {self.repo / 'out.log'} SHA-256 `{'0' * 64}`\n")
        self._expect_pm(self._run_relay(packet, bad))

    def test_forbidden_word_falls_back(self) -> None:
        packet, report = self._init_repo(self.GOOD_PACKET, self.GOOD_REPORT)
        push_report = _write(
            self.root / "report.md",
            self.GOOD_REPORT + "\n已按计划 git push 分支。\n")
        self._expect_pm(self._run_relay(packet, push_report))

    def test_pick_fallback_falls_back_to_pm(self) -> None:
        packet, report = self._init_repo(self.GOOD_PACKET, self.GOOD_REPORT)
        report = self._good_report_with_logs()
        stub = self.root / "fallback.py"
        stub.write_text("print('PICK(兜底，无空闲专职): Sam（Executor（记录/文档） |-)')\n", encoding="utf-8")
        self._expect_pm(self._run_relay(packet, report, pick_stub=stub))

    def test_pick_excluded_name_falls_back_to_pm(self) -> None:
        packet, report = self._init_repo(self.GOOD_PACKET, self.GOOD_REPORT)
        report = self._good_report_with_logs()
        stub = self._pick_stub("Cole")
        self._expect_pm(self._run_relay(packet, report, pick_stub=stub))

    def test_old_subcommands_still_work(self) -> None:
        for args in (["render", "--help"], ["handoff", "--help"], ["final", "--help"]):
            result = _run_py("kos_handoff.py", args)
            self.assertEqual(result.returncode, 0, args)




class RelayExecTests(unittest.TestCase):
    """relay-exec: preflight PASS -> implementation dispatch, fail-closed to PM."""

    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.repo = self.root / "repo"
        self.repo.mkdir()
        self.identity = "Cowork 3P <cowork-3p@localhost>"

    def tearDown(self) -> None:
        self.tmp.cleanup()

    def _git(self, *args):
        env = dict(os.environ)
        env.update({
            "GIT_AUTHOR_NAME": "Cowork 3P", "GIT_AUTHOR_EMAIL": "cowork-3p@localhost",
            "GIT_COMMITTER_NAME": "Cowork 3P", "GIT_COMMITTER_EMAIL": "cowork-3p@localhost",
            "GIT_CONFIG_GLOBAL": "/dev/null", "GIT_CONFIG_SYSTEM": "/dev/null",
        })
        return subprocess.run(["git", "-C", str(self.repo), *args], capture_output=True, text=True, env=env)

    def _init_repo(self):
        self._git("init", "-b", "main")
        (self.repo / ".kos").mkdir()
        (self.repo / ".kos/project.json").write_text("{}\n", encoding="utf-8")
        (self.repo / "base.txt").write_text("base\n", encoding="utf-8")
        self._git("add", ".")
        self._git("commit", "-m", "base")
        self.base = self._git("rev-parse", "HEAD").stdout.strip()

    def _stub(self, name, text):
        return _write(self.root / name, text)

    PASS_REPORT = "PASS\nPete（Preflight）；运行时身份 Codex。\n"
    FAIL_REPORT = "FAIL\nPete（Preflight）；运行时身份 Codex。\n"
    PACKET_CODE = (
        "Executor（代码）；你不是 PM\n\n"
        "# 任务包：示例实现\n\n"
        "- **包头档位**：`code-fix`\n"
        "- **复核重点**：\n  1. 检查。\n"
    )
    PACKET_DOC = (
        "Executor（记录/文档）；你不是 PM\n\n"
        "# 任务包：示例文档\n\n"
        "- **包头档位**：`doc-rule`\n"
        "- **复核重点**：\n  1. 检查。\n"
    )

    def _fixtures(self, packet_text, report_text=None, packet_author=None):
        self._init_repo()
        packet = _write(self.root / "packet.md", packet_text)
        if packet_author:
            packet.write_text(packet.read_text(encoding="utf-8") + f"\n- **包作者**：{packet_author}\n", encoding="utf-8")
        report = _write(self.root / "precheck.md", report_text if report_text is not None else self.PASS_REPORT)
        verify_ok = self._stub("verify_ok.py", "import sys\nsys.exit(0)\n")
        lint_ok = self._stub("lint_ok.py", "import sys\nsys.exit(0)\n")
        return packet, report, verify_ok, lint_ok

    def _pick_stub(self, line):
        return self._stub("pick_stub.py", f"print({line!r})\n")

    def _run(self, packet, report, verify_ok, lint_ok, pick_line="PICK [Executor（代码）]: Nick（Executor（代码） | -）", extra=None):
        args = [
            "relay-exec",
            "--report", str(report),
            "--packet", str(packet),
            "--base", self.base,
            "--repo", str(self.repo),
            "--verify-tool", str(verify_ok),
            "--pkg-lint-tool", str(lint_ok),
            "--board", sys.executable,
            "--board-args", json.dumps([str(self._pick_stub(pick_line))]),
        ]
        if extra:
            args.extend(extra)
        return _run_py("kos_handoff.py", args)

    def _expect_pm(self, result):
        self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("Jack", result.stdout + result.stderr)

    def test_passing_path_emits_dispatch_block(self) -> None:
        packet, report, verify_ok, lint_ok = self._fixtures(self.PACKET_CODE)
        result = self._run(packet, report, verify_ok, lint_ok)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("下一位交付：Nick", result.stdout)
        packet_sha = hashlib.sha256(packet.read_bytes()).hexdigest()
        self.assertIn(packet_sha, result.stdout)
        self.assertIn("授权，直接执行", result.stdout)

    def test_doc_rule_packet_infers_doc_role(self) -> None:
        packet, report, verify_ok, lint_ok = self._fixtures(self.PACKET_DOC)
        result = self._run(
            packet, report, verify_ok, lint_ok,
            pick_line="PICK [Executor（记录/文档）]: Maya（Executor（记录/文档） | -）")
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("Maya", result.stdout)

    def test_precheck_fail_falls_back(self) -> None:
        packet, report, verify_ok, lint_ok = self._fixtures(self.PACKET_CODE, report_text=self.FAIL_REPORT)
        self._expect_pm(self._run(packet, report, verify_ok, lint_ok))

    def test_feature_grade_falls_back(self) -> None:
        packet, report, verify_ok, lint_ok = self._fixtures(
            self.PACKET_CODE.replace("`code-fix`", "`feature`"))
        self._expect_pm(self._run(packet, report, verify_ok, lint_ok))

    def test_verify_tool_failure_falls_back(self) -> None:
        packet, report, _, lint_ok = self._fixtures(self.PACKET_CODE)
        bad = self._stub("verify_bad.py", "import sys\nsys.exit(1)\n")
        self._expect_pm(self._run(packet, report, bad, lint_ok))

    def test_pkg_lint_failure_falls_back(self) -> None:
        packet, report, verify_ok, _ = self._fixtures(self.PACKET_CODE)
        bad = self._stub("lint_bad.py", "import sys\nsys.exit(1)\n")
        self._expect_pm(self._run(packet, report, verify_ok, bad))

    def test_pick_fallback_line_falls_back(self) -> None:
        packet, report, verify_ok, lint_ok = self._fixtures(self.PACKET_CODE)
        result = self._run(
            packet, report, verify_ok, lint_ok,
            pick_line="PICK(兜底，无空闲专职): Sam（Executor（记录/文档） | -）")
        self._expect_pm(result)

    def test_pick_nonzero_exit_falls_back(self) -> None:
        packet, report, verify_ok, lint_ok = self._fixtures(self.PACKET_CODE)
        stub = self._stub("pick_fail.py", "import sys\nsys.exit(3)\n")
        args = [
            "relay-exec",
            "--report", str(report), "--packet", str(packet),
            "--base", self.base, "--repo", str(self.repo),
            "--verify-tool", str(verify_ok), "--pkg-lint-tool", str(lint_ok),
            "--board", sys.executable, "--board-args", json.dumps([str(stub)]),
        ]
        self._expect_pm(_run_py("kos_handoff.py", args))

    def test_precheck_author_excluded(self) -> None:
        packet, report, verify_ok, lint_ok = self._fixtures(self.PACKET_CODE)
        result = self._run(
            packet, report, verify_ok, lint_ok,
            pick_line="PICK [Executor（代码）]: Pete（Executor（代码） | -）")
        self._expect_pm(result)

    def test_packet_author_field_excluded(self) -> None:
        packet, report, verify_ok, lint_ok = self._fixtures(self.PACKET_CODE, packet_author="Cole")
        result = self._run(
            packet, report, verify_ok, lint_ok,
            pick_line="PICK [Executor（代码）]: Cole（Executor（代码） | -）")
        self._expect_pm(result)

    def test_old_subcommands_still_work(self) -> None:
        for args in (["render", "--help"], ["handoff", "--help"], ["final", "--help"], ["relay-quality", "--help"]):
            result = _run_py("kos_handoff.py", args)
            self.assertEqual(result.returncode, 0, args)




class TierProfileGateTests(unittest.TestCase):
    """4-tier profile routing as deterministic rules in kos_handoff.py."""

    def _profile(self, grade, action):
        return _run_py("kos_handoff.py", ["profile", "--grade", grade, "--action", action])

    def test_allowed_direct_relays_per_grade(self) -> None:
        for grade in ("doc-rule", "code-fix"):
            result = self._profile(grade, "relay-exec")
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertIn("allowed", (result.stdout + result.stderr).lower())
        result = self._profile("code-fix", "relay-quality")
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_forbidden_direct_relays_fail_closed(self) -> None:
        for grade in ("doc-light", "feature"):
            result = self._profile(grade, "relay-exec")
            self.assertNotEqual(result.returncode, 0, grade)
            self.assertIn("Jack", result.stdout + result.stderr)
        for grade in ("doc-light", "doc-rule", "feature"):
            result = self._profile(grade, "relay-quality")
            self.assertNotEqual(result.returncode, 0, grade)
            self.assertIn("Jack", result.stdout + result.stderr)

    def test_profile_lists_stations_and_gates(self) -> None:
        result = _run_py("kos_handoff.py", ["profile", "--grade", "code-fix"])
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("预检", result.stdout)
        self.assertIn("红测", result.stdout)
        self.assertIn("独立复核", result.stdout)

    def test_relay_exec_rejects_disallowed_grade(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            repo = root / "repo"
            repo.mkdir()
            packet = _write(root / "packet.md", "Executor（代码）；你不是 PM\n\n# 任务包\n\n- **包头档位**：`feature`\n")
            report = _write(root / "precheck.md", "PASS\nPete（Preflight）；身份。\n")
            ok_stub = _write(root / "ok.py", "import sys\nsys.exit(0)\n")
            args = ["relay-exec", "--report", str(report), "--packet", str(packet),
                    "--base", "x" * 40, "--repo", str(repo),
                    "--verify-tool", str(ok_stub), "--pkg-lint-tool", str(ok_stub),
                    "--board", sys.executable, "--board-args", json.dumps([str(ok_stub)])]
            result = _run_py("kos_handoff.py", args)
            self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertIn("Jack", result.stdout + result.stderr)

    def test_relay_quality_rejects_disallowed_grade(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            repo = root / "repo"
            repo.mkdir()
            packet = _write(root / "packet.md", "Executor（代码）；你不是 PM\n\n# 任务包\n\n- **包头档位**：`doc-rule`\n")
            report = _write(root / "report.md", "DONE\nCole（Executor）；身份。\n")
            args = ["relay-quality", "--report", str(report), "--packet", str(packet),
                    "--base", "x" * 40, "--repo", str(repo),
                    "--board", sys.executable, "--board-args", json.dumps([str(root / 'ok.py')]) ]
            before = None
            ok_stub = _write(root / "ok.py", "import sys\nsys.exit(0)\n")
            args = ["relay-quality", "--report", str(report), "--packet", str(packet),
                    "--base", "x" * 40, "--repo", str(repo),
                    "--board", sys.executable, "--board-args", json.dumps([str(ok_stub)])]
            result = _run_py("kos_handoff.py", args)
            self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertIn("Jack", result.stdout + result.stderr)


if __name__ == "__main__":
    unittest.main()


class HandoffAutoPickTests(unittest.TestCase):
    """KOS-HANDOFF-AUTO-PICK-001: final auto-pick + relay-quality dynamic excludes & dispatch block."""

    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)

    def tearDown(self) -> None:
        self.tmp.cleanup()

    def _record_stub(self, name: str = "Quinn", role: str = "Quality") -> Path:
        stub = self.root / "pick_stub.py"
        stub.write_text(
            "import os, sys\n"
            "out = os.environ.get('PICK_ARGS_OUT')\n"
            "if out:\n"
            "    with open(out, 'w', encoding='utf-8') as f:\n"
            "        f.write('\\n'.join(sys.argv[1:]))\n"
            f"print('PICK [{role}]: {name}（{role} | 上次：-）')\n",
            encoding="utf-8")
        return stub

    def _report(self, next_role: str = "Quality Reviewer",
                line2: str = "Lucy（Executor（代码））；运行时身份 Codex。",
                status: str = "DONE") -> Path:
        report = self.root / "reports" / "report.md"
        report.parent.mkdir(parents=True, exist_ok=True)
        report.write_text(
            f"{status}\n{line2}\n\n"
            "## 下一站接力（O41）\n"
            f"- next_role：{next_role}\n- next_step：复核\n\n"
            "```text\n"
            f"交回：{next_role}\n事项：复核\n报告：{self.root / 'reports' / 'report.md'}\nSHA-256：{'0' * 64}\n"
            "```\n",
            encoding="utf-8")
        return report

    def _final(self, report: Path, board_args: str, env=None):
        return _run_py("kos_handoff.py", [
            "final", "--report", str(report), "--skip-lint",
            "--board", sys.executable, "--board-args", board_args,
        ], env=env)

    def test_final_auto_picks_generic_quality_role_and_excludes_participants(self) -> None:
        report = self._report()
        argv_out = self.root / "pick-argv.txt"
        stub = self._record_stub()
        result = self._final(report, json.dumps([str(stub)]), env={"PICK_ARGS_OUT": str(argv_out)})
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("下一位交付：Quinn（Quality Reviewer）", result.stdout)
        self.assertIn("交回：Quinn（Quality Reviewer）", result.stdout)
        argv_text = argv_out.read_text(encoding="utf-8")
        self.assertIn("--exclude", argv_text)
        self.assertIn("Lucy", argv_text)

    def test_final_auto_pick_falls_back_when_board_unavailable(self) -> None:
        report = self._report()
        result = self._final(report, json.dumps(["-c", "raise SystemExit(3)"]))
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("下一位交付：Quality Reviewer", result.stdout)

    def test_final_keeps_concrete_next_role_untouched(self) -> None:
        report = self._report(next_role="Maya（Quality）")
        stub = self._record_stub()
        result = self._final(report, json.dumps([str(stub)]))
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("下一位交付：Maya（Quality）", result.stdout)
        self.assertNotIn("下一位交付：Quinn", result.stdout)

    def test_relay_quality_dynamic_excludes_and_dispatch_block(self) -> None:
        repo = self.root / "repo"
        repo.mkdir()
        env = dict(os.environ)
        env.update({"GIT_AUTHOR_NAME": "Cowork 3P", "GIT_AUTHOR_EMAIL": "cowork-3p@localhost",
                    "GIT_COMMITTER_NAME": "Cowork 3P", "GIT_COMMITTER_EMAIL": "cowork-3p@localhost",
                    "GIT_CONFIG_GLOBAL": "/dev/null", "GIT_CONFIG_SYSTEM": "/dev/null"})

        def git(*a):
            r = subprocess.run(["git", "-C", str(repo), *a], capture_output=True, text=True, env=env)
            self.assertEqual(r.returncode, 0, r.stderr)
            return r.stdout.strip()

        git("init", "-b", "main")
        (repo / ".kos").mkdir()
        (repo / ".kos" / "project.json").write_text("{}\n", encoding="utf-8")
        (repo / "base.txt").write_text("base\n", encoding="utf-8")
        git("add", ".")
        git("commit", "-m", "base")
        base = git("rev-parse", "HEAD")
        (repo / "tool.py").write_text("x = 1\n", encoding="utf-8")
        git("add", ".")
        git("commit", "-m", "work")
        packet = self.root / "packet.md"
        packet.write_text(
            "Executor（代码）；你不是 PM\n\n# 任务包：示例\n\n"
            "- **包头档位**：`code-fix`\n- **复核重点**：\n  1. 检查一切。\n",
            encoding="utf-8")
        report = self._report()
        argv_out = self.root / "pick-argv-relay.txt"
        stub = self._record_stub()
        result = _run_py("kos_handoff.py", [
            "relay-quality", "--report", str(report), "--packet", str(packet),
            "--base", base, "--repo", str(repo),
            "--board", sys.executable, "--board-args", json.dumps([str(stub)]),
        ], env={"PICK_ARGS_OUT": str(argv_out)})
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        argv_text = argv_out.read_text(encoding="utf-8")
        self.assertIn("Lucy", argv_text)
        self.assertIn("```text", result.stdout)
        self.assertIn("角色：Quinn（Quality）", result.stdout)
        self.assertIn(f"任务：{packet.stem}", result.stdout)
        self.assertIn("SHA-256：", result.stdout)
        self.assertIn("授权，直接执行", result.stdout)


class QualityRelayPackageCompletenessTests(unittest.TestCase):
    """KOS-RELAY-QUALITY-002 R2: quality-relay-block.md is a complete self-contained package."""

    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.repo = self.root / "repo"
        self.repo.mkdir()
        env = dict(os.environ)
        env.update({"GIT_AUTHOR_NAME": "Cowork 3P", "GIT_AUTHOR_EMAIL": "cowork-3p@localhost",
                    "GIT_COMMITTER_NAME": "Cowork 3P", "GIT_COMMITTER_EMAIL": "cowork-3p@localhost",
                    "GIT_CONFIG_GLOBAL": "/dev/null", "GIT_CONFIG_SYSTEM": "/dev/null"})

        def git(*a):
            r = subprocess.run(["git", "-C", str(self.repo), *a], capture_output=True, text=True, env=env)
            self.assertEqual(r.returncode, 0, r.stderr)
            return r.stdout.strip()

        self._git = git
        git("init", "-b", "main")
        (self.repo / ".kos").mkdir()
        (self.repo / ".kos" / "project.json").write_text("{}\n", encoding="utf-8")
        (self.repo / "base.txt").write_text("base\n", encoding="utf-8")
        git("add", ".")
        git("commit", "-m", "base")
        self.base = git("rev-parse", "HEAD")
        (self.repo / "tool.py").write_text("x = 1\n", encoding="utf-8")
        git("add", ".")
        git("commit", "-m", "work")
        self.packet = self.root / "packet.md"
        self.packet.write_text(
            "Executor（代码）；你不是 PM\n\n# 任务包：示例\n\n"
            "- **包头档位**：`code-fix`\n- **复核重点**：\n  1. 检查一切。\n",
            encoding="utf-8")
        report = self.root / "reports" / "report.md"
        report.parent.mkdir(parents=True, exist_ok=True)
        report.write_text(
            "DONE\nLucy（Executor（代码））；运行时身份 Codex。\n\n"
            "## 下一站接力（O41）\n- next_role：Quality Reviewer\n- next_step：复核\n\n"
            "```text\n交回：Quality Reviewer\n事项：复核\n```\n",
            encoding="utf-8")
        self.report = report

    def tearDown(self) -> None:
        self.tmp.cleanup()

    def _pick_stub(self) -> Path:
        stub = self.root / "pick.py"
        stub.write_text("print('PICK [Quality]: Quinn（Quality | 上次：-）')\n", encoding="utf-8")
        return stub

    def _run_relay(self):
        stub = self._pick_stub()
        return _run_py("kos_handoff.py", [
            "relay-quality", "--report", str(self.report), "--packet", str(self.packet),
            "--base", self.base, "--repo", str(self.repo),
            "--board", sys.executable, "--board-args", json.dumps([str(stub)]),
        ])

    def _block(self) -> tuple[Path, str]:
        result = self._run_relay()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        out = Path(result.stdout.split("质检块：", 1)[1].split("（", 1)[0].strip())
        return out, out.read_text(encoding="utf-8")

    def test_block_is_complete_package(self) -> None:
        out, text = self._block()
        self.assertTrue(text.splitlines()[0].startswith("Quality Reviewer；你不是 PM"), text.splitlines()[0])
        self.assertIn(str(self.packet.resolve()), text)
        self.assertIn(hashlib.sha256(self.packet.read_bytes()).hexdigest(), text)
        self.assertIn(str(self.report.resolve()), text)
        self.assertIn(hashlib.sha256(self.report.read_bytes()).hexdigest(), text)
        self.assertIn(str(self.repo.resolve()), text)  # worktree
        self.assertIn(str(self.report.parent / f"quality-{self.packet.stem}.md"), text)
        self.assertIn("kos-report-lint.py", text)
        self.assertIn("kos_handoff.py final", text)
        self.assertIn("直接作为 Markdown 原样回复", text)
        self.assertIn("严禁外层再套代码块", text)
        self.assertIn("## 观察与改进意见（不影响状态，不在本包范围）", text)
        self.assertIn("## 下一站接力（O41）", text)
        self.assertIn("next_role：Jack（PM）", text)

    def test_block_passes_verify_inputs(self) -> None:
        out, _ = self._block()
        result = _run_py("kos-verify-inputs.py", [str(out), "--quiet"])
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("mismatch=0", result.stdout)
        self.assertIn("missing=0", result.stdout)
        self.assertIn("badlen=0", result.stdout)

    def test_relay_pick_dedupes_and_drops_blank_excludes(self) -> None:
        sys.path.insert(0, str(KOS_DIR))
        import importlib
        kh = importlib.import_module("kos_handoff")
        stub = self.root / "argv_recorder.py"
        stub.write_text(
            "import os, sys\n"
            "out = os.environ.get('PICK_ARGS_OUT')\n"
            "if out:\n"
            "    with open(out, 'w', encoding='utf-8') as f:\n"
            "        f.write(' '.join(sys.argv[1:]))\n"
            "print('PICK [Quality]: Quinn（Quality | 上次：-）')\n",
            encoding="utf-8")
        argv_out = self.root / "argv.txt"
        os.environ["PICK_ARGS_OUT"] = str(argv_out)
        try:
            picked, line = kh._relay_pick(
                sys.executable, json.dumps([str(stub)]), ["Lucy", "", "Lucy", "  "], role="quality")
        finally:
            os.environ.pop("PICK_ARGS_OUT", None)
        self.assertEqual(picked, "Quinn", line)
        argv_text = argv_out.read_text(encoding="utf-8")
        self.assertEqual(argv_text.count("Lucy"), 1, argv_text)
        self.assertNotIn(",,", argv_text, argv_text)
        self.assertFalse(argv_text.rstrip().endswith(","), argv_text)
