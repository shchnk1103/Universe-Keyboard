import hashlib
import importlib.util
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


def run_suggest(home, *args):
    return subprocess.run([sys.executable, '-B', str(ROOT / 'kos_suggest.py'), *args],
                          env={**os.environ, 'KOS_HOME': str(home)}, capture_output=True, text=True)


class Tools008Tests(unittest.TestCase):
    def test_head_and_task_relative_paths(self):
        with tempfile.TemporaryDirectory() as tmp:
            task = Path(tmp)
            (task / 'reports').mkdir()
            (task / 'scratch').mkdir()
            log = task / 'scratch' / 'run.log'
            log.write_text('COMMAND: test\nHEAD=' + 'a' * 40 + '\nEXIT: 0\n')
            report = task / 'reports' / 'report.md'
            report.write_text('DONE\nLucy\n scratch/run.log scratch/missing.log\n')
            result = subprocess.run([sys.executable, '-B', str(ROOT / 'check_report.py'), str(report)],
                                    capture_output=True, text=True)
            self.assertIn('HEAD=aaaaaaaa', result.stdout)
            self.assertIn('MISSING  scratch/missing.log', result.stdout)
            self.assertNotIn('MISSING  scratch/run.log', result.stdout)

    def test_pending_matching_and_missing_section(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            (root / 'PM-LOG').mkdir()
            report = root / 'report.md'
            report.write_text('DONE\n')
            self.assertIn('MISSING_SECTION', run_suggest(root, 'pending', str(report)).stdout)
            report.write_text('## 观察与改进意见\n1. 真实建议\n2. 没有更多。\n')
            args = ['add', '--task', 'TEST-001', '--report', str(report), '--text', '真实建议', '--topic']
            self.assertEqual(run_suggest(root, *args, 'a').returncode, 0)
            self.assertEqual(run_suggest(root, 'pending', str(report)).returncode, 0)
            report.write_text('## 观察与改进意见\n1. 真实建议\n2. 第二建议\n')
            self.assertEqual(run_suggest(root, *args, 'b').returncode, 0)
            self.assertEqual(run_suggest(root, *args, 'c').returncode, 0)
            result = run_suggest(root, 'pending', str(report))
            self.assertNotEqual(result.returncode, 0)
            self.assertIn('第二建议', result.stdout)

    def test_source_task_not_target_and_evidence_tokens(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            (root / 'PM-LOG').mkdir()
            report = root / 'report.md'
            report.write_text('## 观察与改进意见\n无\n')
            args = ['add', '--task', 'SOURCE-001', '--report', str(report), '--text', '建议', '--topic', 'adopt']
            self.assertNotEqual(run_suggest(root, *args, '--status', '已采纳').returncode, 0)
            self.assertEqual(run_suggest(root, *args, '--status', '已采纳', '--target-task', 'TARGET-001').returncode, 0)
            self.assertNotEqual(run_suggest(root, 'status', 'adopt', '已关闭', '--evidence', '已处理').returncode, 0)
            self.assertEqual(run_suggest(root, 'status', 'adopt', '已关闭', '--evidence', 'PR #123').returncode, 0)

    def test_duplicate_report_items_count_once(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            (root / 'PM-LOG').mkdir()
            report = root / 'report.md'
            report.write_text('## 观察与改进意见\n1. 同一建议\n2. 同一建议。\n')
            result = run_suggest(root, 'add', '--task', 'TEST-001', '--report', str(report), '--text', '同一建议', '--topic', 'a')
            self.assertEqual(result.returncode, 0)
            self.assertEqual(run_suggest(root, 'pending', str(report)).returncode, 0)

    def test_colon_head_and_worktree_fallback(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            task = root / 'task'
            worktree = root / 'worktree'
            (task / 'reports').mkdir(parents=True)
            (worktree / 'scratch').mkdir(parents=True)
            (worktree / 'scratch' / 'run.log').write_text('COMMAND: test\nHEAD: ' + 'b' * 40 + '\nEXIT: 0\n')
            report = task / 'reports' / 'report.md'
            report.write_text('DONE\nLucy\n scratch/run.log\n')
            result = subprocess.run([sys.executable, '-B', str(ROOT / 'check_report.py'), str(report), '--worktree', str(worktree)], capture_output=True, text=True)
            self.assertIn('HEAD=bbbbbbbb', result.stdout)
            self.assertNotIn('MISSING  scratch/run.log', result.stdout)

    def test_status_validation_and_initial_rejection(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            (root / 'PM-LOG').mkdir()
            report = root / 'report.md'
            report.write_text('## 观察与改进意见\n无\n')
            args = ['add', '--task', 'TEST-001', '--report', str(report), '--text', '建议', '--topic', 'a']
            self.assertNotEqual(run_suggest(root, *args, '--status', '已拒绝').returncode, 0)
            self.assertEqual(run_suggest(root, *args, '--status', '已拒绝', '--reason', '不适用').returncode, 0)
            self.assertIn('已拒绝', run_suggest(root, 'topics').stdout)
            self.assertNotEqual(run_suggest(root, 'status', 'a', '已完成').returncode, 0)
            self.assertEqual(run_suggest(root, 'status', 'a', '已完成', '--evidence', '报告 reports/result.md').returncode, 0)
            self.assertNotEqual(run_suggest(root, 'status', 'a', '已采纳').returncode, 0)
            self.assertEqual(run_suggest(root, 'status', 'a', '已采纳', '--task', 'TEST-002').returncode, 0)


if __name__ == '__main__':
    unittest.main()
