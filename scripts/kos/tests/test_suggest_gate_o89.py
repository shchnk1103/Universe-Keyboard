"""Behavior tests for the task suggestion check and publish gate (O89)."""
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

KOS = Path(__file__).resolve().parents[1]


class SuggestGateTests(unittest.TestCase):
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
                             '--title', 'Gate test', '--branch', 'feat/gate',
                             '--wt', self.task / 'worktree', '--out', self.out,
                             '--input', self.input, '--allow', 'scripts/kos/example.py',
                             '--goal', 'verify gate', '--board-tool', self.board,
                             '--no-lint', *extra)

    def test_empty_and_reports_without_suggestions_pass_read_only(self):
        self.assertEqual(self.check().returncode, 0)
        self.report('no-section.md', '# Report\nNo suggestions section.\n')
        self.report('none.md', '# 观察与改进意见\n无。\n')
        result = self.check()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertFalse((self.home / 'SUGGESTIONS.json').exists())

    def test_reports_pending_counts_and_registration(self):
        first = self.report('first.md', '# 观察与改进意见\n- 第一条\n- 第二条\n')
        second = self.report('second.md', '# 观察与改进意见\n- 第三条\n')
        self.register(first, '第一条', 'first')
        before = (self.home / 'SUGGESTIONS.json').read_bytes()
        result = self.check()
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 1, output)
        for report in (first, second):
            self.assertIn(str(report), output)
        self.assertGreaterEqual(output.count('1'), 2, output)
        self.assertEqual((self.home / 'SUGGESTIONS.json').read_bytes(), before)
        self.register(first, '第二条', 'second')
        self.register(second, '第三条', 'third')
        result = self.check()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_publish_blocks_before_writing_and_identifies_report(self):
        report = self.report('pending.md', '# 观察与改进意见\n- 待登记事项\n')
        result = self.quick()
        output = result.stdout + result.stderr
        self.assertNotEqual(result.returncode, 0, output)
        self.assertIn(str(report), output)
        self.assertIn('add', output)
        self.assertFalse(self.out.exists())

    def test_publish_override_and_other_kinds_allow_pending(self):
        self.report('pending.md', '# 观察与改进意见\n- 待登记事项\n')
        for kind, extra in [('publish', ('--allow-unregistered-suggestions',)), ('doc-light', ())]:
            with self.subTest(kind=kind):
                result = self.quick(kind, *extra)
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                self.assertTrue(self.out.is_file())
                self.out.unlink()

    def test_publish_passes_after_registration(self):
        report = self.report('pending.md', '# 观察与改进意见\n- 待登记事项\n')
        self.register(report, '待登记事项', 'topic')
        result = self.quick()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertTrue(self.out.is_file())


if __name__ == '__main__':
    unittest.main()
