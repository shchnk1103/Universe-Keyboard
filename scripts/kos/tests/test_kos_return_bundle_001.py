import hashlib
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[3]
CHECK = ROOT / 'scripts/kos/check_report.py'
SUGGEST = ROOT / 'scripts/kos/kos_suggest.py'


class ReturnBundleTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.home = Path(self.tmp.name)
        self.report = self.home / 'task/reports/report.md'
        self.report.parent.mkdir(parents=True)
        self.report.write_text('DONE\nLucy\n\n## 观察与改进意见\n- 检查一\n- 检查二\n', encoding='utf-8')
        self.env = dict(os.environ, KOS_HOME=str(self.home))

    def run_check(self, *args):
        return subprocess.run(['python3', str(CHECK), str(self.report), '--suggest-tool', str(SUGGEST), *args], env=self.env, text=True, capture_output=True)

    def test_missing_board_and_real_pending(self):
        result = self.run_check('--on-return')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn(hashlib.sha256(self.report.read_bytes()).hexdigest(), result.stdout)
        self.assertIn('RETURN PENDING: 2', result.stdout)
        self.assertIn('RETURN BOARD: unavailable', result.stdout)
        self.assertIn('RETURN CHECK:', result.stdout)

    def test_board_pick_and_no_mutation(self):
        tools = self.home / 'tools'
        tools.mkdir()
        board_tool = os.environ.get('KOS_BOARD_TOOL')
        if not board_tool or not Path(board_tool).is_file():
            self.skipTest('set KOS_BOARD_TOOL to test the external board tool')
        real_board = Path(board_tool)
        shutil.copy(real_board, tools / 'kos-board.py')
        roles = self.home / 'roles fixture'
        (roles / 'roles').mkdir(parents=True)
        (roles / 'roles/ROSTER.md').write_text('| 名字 | 职责 |\n| Maya | Quality |\n', encoding='utf-8')
        board = roles / 'BOARD.md'
        board.write_text('| 名字 | 牌子 | 任务 | 更新时间 | 备注 |\n| Maya | 已预占 | old | 2000-01-01 00:00 | TTL 1s |\n', encoding='utf-8')
        before = board.read_bytes()
        result = self.run_check('--on-return', '--board-roles-dir', str(roles), '--next-role', 'quality')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('Maya', result.stdout)
        self.assertEqual(before, board.read_bytes())

    def test_pending_failure_is_not_zero(self):
        self.report.write_text('DONE\nLucy\n', encoding='utf-8')
        result = self.run_check('--on-return')
        self.assertIn('RETURN PENDING: unavailable', result.stdout)

    def test_base_abbreviation_matches_baseline_with_board_option(self):
        base = '8112493f0cf3ac542af835d9748146c36f675494'
        baseline = subprocess.run(
            ['git', '-C', str(ROOT), 'show', f'{base}:scripts/kos/check_report.py'],
            check=True, capture_output=True, text=True,
        )
        baseline_script = self.home / 'baseline_check_report.py'
        baseline_script.write_text(baseline.stdout, encoding='utf-8')
        args = [str(self.report), '--worktree', str(ROOT), '--b', base, '--no-suggest-check']
        old = subprocess.run(['python3', str(baseline_script), *args], env=self.env,
                             text=True, capture_output=True)
        new = subprocess.run(['python3', str(CHECK), *args, '--board-roles-dir', str(self.home / 'roles')],
                             env=self.env, text=True, capture_output=True)
        self.assertEqual((new.returncode, new.stdout, new.stderr),
                         (old.returncode, old.stdout, old.stderr))
        returned = self.run_check('--worktree', str(ROOT), '--b', base, '--no-suggest-check',
                                  '--board-roles-dir', str(self.home / 'roles'), '--on-return',
                                  '--next-role', 'quality')
        self.assertEqual(returned.returncode, 0, returned.stderr)
        self.assertIn('RETURN BOARD: unavailable', returned.stdout)

    def test_legacy_output_unchanged_by_default(self):
        result = self.run_check()
        self.assertEqual(result.returncode, 0)
        self.assertNotIn('RETURN ', result.stdout)
        self.assertIn('SUGGESTIONS: UNREGISTERED (2)', result.stdout)
