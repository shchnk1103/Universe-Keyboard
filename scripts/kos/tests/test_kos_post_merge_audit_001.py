import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


SCRIPT = Path(__file__).resolve().parents[1] / "kos_post_merge_audit.py"


class PostMergeAuditTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.kos = self.root / "kos"
        self.repo = self.root / "repo"
        self.task = self.kos / "PB-006-IMPL-001"
        (self.task / "reports").mkdir(parents=True)
        (self.repo / "docs" / "releases").mkdir(parents=True)
        (self.task / "reports" / "publish-test.md").write_text(
            "DONE\nPR #42 已合并。\n", encoding="utf-8"
        )
        self.portfolio = self.repo / "docs" / "PORTFOLIO.md"
        self.release = self.repo / "docs" / "releases" / "v1.0.3.md"
        self.portfolio.write_text("| PB-006 | 已完成 |\n", encoding="utf-8")
        self.release.write_text("- **Status:** `In Preparation`\n| PB-006 | 已完成 |\n", encoding="utf-8")

    def run_audit(self):
        env = dict(os.environ, HOME=str(self.root / "home"), PATH="")
        return subprocess.run(
            [sys.executable, "-B", str(SCRIPT), "--kos-root", str(self.kos), "--repo", str(self.repo)],
            capture_output=True, text=True, env=env, check=False,
        )

    def test_r2_negative_merge(self):
        (self.task / "worktree").mkdir()
        for text in ("PR was never merged.", "PR not merged.", "PR 未合并。", "STOPPED\nPR merged."):
            with self.subTest(text=text):
                (self.task / "reports" / "publish-test.md").write_text(text, encoding="utf-8")
                result = self.run_audit()
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                self.assertNotIn("merged evidence", result.stdout)

    def test_r2_status_column(self):
        for row in ("| PB-006 | 未开始 |", "| 1 | PB-006 | 进行中 |", "| PB-006 | 部分落地 |", "| PB-006 | 待审核 |", "| PB-006 | 规划中 |", "| PB-006 | 神秘状态 |"):
            with self.subTest(row=row):
                self.portfolio.write_text(row + "\n", encoding="utf-8")
                result = self.run_audit()
                self.assertNotEqual(result.returncode, 0, result.stdout)
                self.assertIn("PORTFOLIO.md", result.stdout)

    def test_r2_table_headers_choose_status_not_notes(self):
        self.portfolio.write_text(
            "| 编号 | 优先级 | 描述 | 当前状态 | 备注 |\n"
            "| --- | --- | --- | --- | --- |\n"
            "| PB-006 | P2 | 示例 | 已合入 | 历史待修复 |\n", encoding="utf-8"
        )
        self.release.write_text(
            "- **Status:** `In Preparation`\n| 序号 | 项 | 状态 | 备注 |\n"
            "| --- | --- | --- | --- |\n| 1 | PB-006 | Released | 待修复历史 |\n", encoding="utf-8"
        )
        result = self.run_audit()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_r2_prose_is_not_a_ledger_row(self):
        self.portfolio.write_text("PB-006 mentioned in prose.\n", encoding="utf-8")
        self.release.write_text("- **Status:** `In Preparation`\n", encoding="utf-8")
        result = self.run_audit()
        self.assertNotEqual(result.returncode, 0, result.stdout)
        self.assertIn("not found", result.stdout)

    def test_r2_completed_and_unrelated_reference(self):
        self.portfolio.write_text("| PB-006 | 已完成 | 过去待修复，现已解决 |\n| PB-009 | 待实现 |\n", encoding="utf-8")
        (self.task / "reports" / "publish-test.md").write_text(
            "DONE\n# 任务：PB-006-IMPL-001\nPR 已合并。另见 PB-009。\n", encoding="utf-8"
        )
        result = self.run_audit()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("clean", result.stdout)

    def test_r3_null_merged_value(self):
        for text in ("PR mergedAt: null", "merged: false", 'mergedAt: ""'):
            with self.subTest(text=text):
                (self.task / "reports" / "publish-test.md").write_text(text, encoding="utf-8")
                result = self.run_audit()
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                self.assertNotIn("merged evidence", result.stdout)

    def test_r3_english_negative_status(self):
        for row in ("| PB-006 | Not Released |", "| PB-006 | Not Merged |", "| PB-006 | Pending Release |"):
            with self.subTest(row=row):
                self.portfolio.write_text(row + "\n", encoding="utf-8")
                result = self.run_audit()
                self.assertNotEqual(result.returncode, 0, result.stdout)
                self.assertIn("PORTFOLIO.md", result.stdout)

    def test_r3_metadata_targets_verified_individually(self):
        self.task.rename(self.kos / "AUDIT-001")
        self.task = self.kos / "AUDIT-001"
        (self.task / "reports" / "publish-test.md").write_text(
            "DONE\n- **任务 ID：** PB-006-IMPL-001\n- **目标：** PB-006、PB-009\nPR 已合并。\n",
            encoding="utf-8",
        )
        self.portfolio.write_text("| PB-006 | 已完成 |\n| PB-009 | 待实现 |\n", encoding="utf-8")
        result = self.run_audit()
        self.assertNotEqual(result.returncode, 0, result.stdout)
        self.assertIn("PB-009", result.stdout)
        self.portfolio.write_text("| PB-006 | 已完成 |\n| PB-009 | 已完成 |\n", encoding="utf-8")
        result = self.run_audit()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("clean", result.stdout)

    def test_r3_product_missing_portfolio_row(self):
        self.task.rename(self.kos / "AUDIT-002")
        self.task = self.kos / "AUDIT-002"
        (self.task / "reports" / "publish-test.md").write_text(
            "DONE\n- **目标：** PB-042\nPR 已合并。\n", encoding="utf-8"
        )
        self.portfolio.write_text("| PB-006 | 已完成 |\n", encoding="utf-8")
        self.release.write_text("- **Status:** `In Preparation`\n| PB-042 | Released |\n", encoding="utf-8")
        result = self.run_audit()
        self.assertNotEqual(result.returncode, 0, result.stdout)
        self.assertIn("PB-042", result.stdout)
        self.assertIn("PORTFOLIO", result.stdout)
        self.release.write_text("- **Status:** `In Preparation`\n| PB-042 | 待实现 |\n", encoding="utf-8")
        result = self.run_audit()
        self.assertNotEqual(result.returncode, 0, result.stdout)
        self.assertIn("v1.0.3.md", result.stdout)

    def test_r4_merge_detection_strict(self):
        self.task.rename(self.kos / "AUDIT-003")
        self.task = self.kos / "AUDIT-003"
        (self.task / "reports" / "publish-test.md").write_text(
            "DONE\n- **目标：** PB-042\nPR 已合并。\n", encoding="utf-8"
        )
        self.portfolio.write_text("| PB-042 | 已完成 |\n", encoding="utf-8")
        self.release.write_text("- **Status:** `In Preparation`\n| PB-042 | 已完成 |\n", encoding="utf-8")
        for text in (
            "mergedAt: false", 'merged: ""', "merged_at: null", "will be merged tomorrow",
            "准备合入，等待 CI。", "cannot be merged", "hasn't been merged",
            "Merged in PR #416, then reverted.",
        ):
            with self.subTest(text=text):
                (self.task / "reports" / "publish-test.md").write_text(
                    f"DONE\n- **目标：** PB-042\nPR {text}\n", encoding="utf-8"
                )
                result = self.run_audit()
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                self.assertNotIn("merged evidence", result.stdout)
        # snake_case real merges must be recognized, not silently skipped.
        (self.task / "reports" / "publish-test.md").write_text(
            "DONE\n- **目标：** PB-042\nmerged_at: 2026-11-24\nPR 已合并。\n", encoding="utf-8"
        )
        result = self.run_audit()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("merged evidence", result.stdout)

    def test_r4_partial_is_open(self):
        for row in ("| PB-006 | Partially done |", "| PB-006 | Released (partially) |", "| PB-006 | partial |"):
            with self.subTest(row=row):
                self.portfolio.write_text(row + "\n", encoding="utf-8")
                result = self.run_audit()
                self.assertNotEqual(result.returncode, 0, result.stdout)
                self.assertIn("PORTFOLIO.md", result.stdout)

    def test_r4_related_tasks_not_targets(self):
        self.task.rename(self.kos / "AUDIT-004")
        self.task = self.kos / "AUDIT-004"
        (self.task / "reports" / "publish-test.md").write_text(
            "DONE\n# 任务：PB-006\nPR 已合并。\n相关任务：PB-099\n", encoding="utf-8"
        )
        self.portfolio.write_text("| PB-006 | 已完成 |\n| PB-099 | 待实现 |\n", encoding="utf-8")
        self.release.write_text("- **Status:** `In Preparation`\n| PB-006 | 已完成 |\n", encoding="utf-8")
        result = self.run_audit()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("clean", result.stdout)

    def test_r4_no_active_release_distinguishable(self):
        self.release.write_text("- **Status:** `Not Released`\n| PB-006 | 已完成 |\n", encoding="utf-8")
        result = self.run_audit()
        self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("no active release", result.stdout + result.stderr)
        self.release.write_text("| PB-006 | 已完成 |\n", encoding="utf-8")
        result = self.run_audit()
        self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("no active release", result.stdout + result.stderr)

    def test_clean(self):
        result = self.run_audit()
        self.assertEqual(result.returncode, 0, result.stderr + result.stdout)
        self.assertIn("PB-006-IMPL-001", result.stdout)
        self.assertIn("clean", result.stdout.lower())

    def test_worktree_remaining(self):
        (self.task / "worktree").mkdir()
        result = self.run_audit()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("worktree", result.stdout)
        self.assertIn("PB-006-IMPL-001", result.stdout)

    def test_ledger_outstanding(self):
        self.portfolio.write_text("| PB-006 | Backlog |\n", encoding="utf-8")
        self.release.write_text("- **Status:** `In Preparation`\n| PB-006 | 待实现 |\n", encoding="utf-8")
        result = self.run_audit()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("PORTFOLIO.md", result.stdout)
        self.assertIn("v1.0.3.md", result.stdout)

    def test_product_id_only_in_report_text(self):
        self.task.rename(self.kos / "EXAMPLE-IMPL-001")
        self.task = self.kos / "EXAMPLE-IMPL-001"
        (self.task / "reports" / "publish-test.md").write_text(
            "DONE\n目标：PB-006\nPR #42 已合并。另见 PB-009。\n", encoding="utf-8"
        )
        self.portfolio.write_text("| PB-006 | Backlog |\n", encoding="utf-8")
        self.release.write_text("- **Status:** `In Preparation`\n| PB-006 | 待实现 |\n", encoding="utf-8")
        result = self.run_audit()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("PB-006", result.stdout)

    def test_no_ledger_record_is_not_clean(self):
        # No ledger row mentions the task id or any product id: not clean.
        self.portfolio.write_text("| PB-009 | 已完成 |\n", encoding="utf-8")
        self.release.write_text("- **Status:** `In Preparation`\n| PB-009 | 已完成 |\n", encoding="utf-8")
        result = self.run_audit()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("PB-006-IMPL-001", result.stdout)
        self.assertNotIn("clean", result.stdout.lower())


if __name__ == "__main__":
    unittest.main()
