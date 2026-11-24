"""O89 r3 regression tests: ### subheadings and multiple suggestion sections.

Red→green: both cases were missed by section_items before the r3 fix
(deep subheadings truncated the section; an empty first section masked
items in later sections).
"""
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

KOS = Path(__file__).resolve().parents[1]


class SuggestGateR3Tests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.home = Path(self.tmp.name)
        self.task = self.home / 'TASK-001'
        self.reports = self.task / 'reports'
        self.reports.mkdir(parents=True)
        (self.home / 'PM-LOG').mkdir()
        self.env = dict(os.environ, KOS_HOME=str(self.home), PYTHONDONTWRITEBYTECODE='1')
        self.input = self.home / 'input.md'
        self.input.write_text('input\n', encoding='utf-8')
        self.board = self.home / 'board.py'
        self.board.write_text("print('PICK [Executor（代码）]: Quinn（Executor（代码） | 上次：从未记录 -）')\n", encoding='utf-8')
        self.out = self.task / 'instructions' / 'publish.md'

    def run_tool(self, tool, *args):
        return subprocess.run([sys.executable, '-B', str(KOS / tool), *map(str, args)],
                              env=self.env, text=True, capture_output=True)

    def report(self, name, body):
        path = self.reports / name
        path.write_text(body, encoding='utf-8')
        return path

    def register(self, report, text, topic):
        result = self.run_tool('kos_suggest.py', 'add', '--task', 'TASK-001',
                               '--report', report, '--text', text, '--topic', topic)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def check(self):
        return self.run_tool('kos_suggest.py', 'check-task', self.task)

    def quick(self, kind='publish', *extra):
        return self.run_tool('kos_pack.py', 'quick', '--task', 'TASK-001', '--kind', kind,
                             '--title', 'Gate r3 test', '--branch', 'feat/gate-r3',
                             '--wt', self.task / 'worktree', '--out', self.out,
                             '--input', self.input, '--allow', 'scripts/kos/example.py',
                             '--goal', 'verify gate r3', '--board-tool', self.board,
                             '--no-lint', *extra)

    def test_subheading_items_are_detected(self):
        """Items under ### / #### subheadings must still be registered."""
        report = self.report('sub.md',
                             '# 报告\n正文\n\n'
                             '## 观察与改进意见\n'
                             '- 顶层意见\n'
                             '### 风险\n'
                             '- 子标题下意见\n'
                             '#### 更深\n'
                             '- 深层意见\n')
        result = self.check()
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 1, output)
        self.assertIn(str(report), output)
        for item in ('顶层意见', '子标题下意见', '深层意见'):
            self.assertIn(item, output)
        # gate: quick publish must fail and not write the packet
        result = self.quick()
        output = result.stdout + result.stderr
        self.assertNotEqual(result.returncode, 0, output)
        self.assertFalse(self.out.exists())
        # after registering all three items the check passes
        self.register(report, '顶层意见', 'r3-top')
        self.register(report, '子标题下意见', 'r3-sub')
        self.register(report, '深层意见', 'r3-deep')
        result = self.check()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        result = self.quick()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertTrue(self.out.is_file())

    def test_multiple_sections_merge_all_items(self):
        """An empty first 观察与改进意见 section must not mask a later one."""
        report = self.report('multi.md',
                             '# 报告\n'
                             '## 观察与改进意见\n'
                             '没有。\n'
                             '## 下一站接力\n'
                             '```text\n'
                             '暂无\n'
                             '```\n'
                             '# 复盘附录\n'
                             '## 观察与改进意见\n'
                             '- 第二节意见\n')
        result = self.check()
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 1, output)
        self.assertIn(str(report), output)
        self.assertIn('第二节意见', output)
        result = self.quick()
        output = result.stdout + result.stderr
        self.assertNotEqual(result.returncode, 0, output)
        self.assertFalse(self.out.exists())
        self.register(report, '第二节意见', 'r3-second')
        result = self.check()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)


if __name__ == '__main__':
    unittest.main()
