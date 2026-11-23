"""O85 handoff reassignment and O84 portfolio reconcile reminder. Stdlib only."""
import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
HANDOFF = ROOT / "scripts/kos/kos_handoff.py"
LINT = ROOT / "scripts/kos/kos-pkg-lint.py"
FLOW = ROOT / "scripts/kos/pr_flow.py"


def _run(script: Path, args, env=None):
    return subprocess.run(
        [sys.executable, "-I", "-B", str(script), *args],
        text=True, capture_output=True, check=False, env=env,
    )


class HandoffBoardSyncTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)

    def tearDown(self):
        self.tmp.cleanup()

    def _board(self, rows: str) -> Path:
        roles = self.root / "roles"
        roles.mkdir()
        (roles / "BOARD.md").write_text(
            "| 名字 | 牌子 | 任务 | 更新时间 | 备注 |\n|---|---|---|---|---|\n" + rows,
            encoding="utf-8",
        )
        return roles

    def _stub(self, name="Quinn") -> Path:
        stub = self.root / "pick_stub.py"
        stub.write_text(
            "import os, sys\n"
            "out = os.environ.get('PICK_ARGS_OUT')\n"
            "if out:\n"
            "    open(out, 'w', encoding='utf-8').write('\\n'.join(sys.argv[1:]))\n"
            f"print('PICK [quality]: {name}（Quality Reviewer | 上次：-）')\n",
            encoding="utf-8",
        )
        return stub

    def _report(self, next_role: str) -> Path:
        report = self.root / "TASK-1" / "reports" / "report.md"
        report.parent.mkdir(parents=True)
        report.write_text(
            "DONE\nLucy（Executor（代码））；运行时身份 Codex。\n\n"
            "## 下一站接力（O41）\n"
            f"- next_role：{next_role}\n- next_step：复核\n\n"
            "```text\n"
            f"交回：{next_role}\n事项：复核\n```\n",
            encoding="utf-8",
        )
        return report

    def _final(self, report: Path, roles: Path, stub: Path):
        argv_out = self.root / "argv.txt"
        env = {"PICK_ARGS_OUT": str(argv_out), "PATH": "/usr/bin:/bin"}
        result = _run(HANDOFF, [
            "final", "--report", str(report), "--skip-lint",
            "--board", sys.executable, "--board-args", json.dumps([str(stub)]),
            "--board-roles-dir", str(roles),
        ], env=env)
        return result, argv_out

    def test_busy_named_reviewer_is_reassigned_to_idle_peer(self):
        roles = self._board("| Maya | 工作中 | TASK-1 | 2026-11-23 01:00 | |\n")
        result, argv_out = self._final(
            self._report("Maya（Quality Reviewer）"), roles, self._stub("Quinn"))
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("交回：Quinn（Quality Reviewer）", result.stdout)
        self.assertNotIn("交回：Maya", result.stdout)
        text = argv_out.read_text(encoding="utf-8")
        self.assertIn("Lucy", text)
        self.assertIn("Maya", text)

    def test_duty_only_next_role_picks_idle_person(self):
        roles = self._board("| Maya | 空闲 | - | 2026-11-23 01:00 | |\n")
        result, _argv = self._final(
            self._report("Quality Reviewer"), roles, self._stub("Wendy"))
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("交回：Wendy（Quality Reviewer）", result.stdout)

    def test_pkg_lint_warns_on_hardcoded_non_pm_name(self):
        packet = self.root / "code-touch-r1.md"
        packet.write_text(
            "角色：Executor（代码）\n包头档位：`code-fix`\n"
            "- next_role: Maya（Quality Reviewer）\n"
            "- next_role: Jack（PM）\n",
            encoding="utf-8",
        )
        result = _run(LINT, ["--start", "a" * 40, str(packet)])
        self.assertEqual(result.returncode, 0, result.stdout)
        self.assertIn("W6 ", result.stdout)
        self.assertIn("Maya", result.stdout)
        self.assertNotIn("Jack", result.stdout.split("W6", 1)[-1] if False else result.stdout.split("==")[0])
        # Jack must not be the warned name
        warned = [line for line in result.stdout.splitlines() if line.startswith("W6 ")]
        self.assertTrue(warned)
        self.assertTrue(all("Jack" not in line for line in warned))

    def test_land_prints_portfolio_todo_only_when_refs_match(self):
        spec = __import__("importlib.util").util.spec_from_file_location("pr_flow", FLOW)
        module = __import__("importlib.util").util.module_from_spec(spec)
        spec.loader.exec_module(module)
        hit = module._portfolio_refs("land PF-061 plus PB-010A and O85", "")
        self.assertEqual(hit, ["PF-061", "PB-010A", "O85"])
        self.assertEqual(module._portfolio_refs("KOS-HANDOFF-BOARD-SYNC-001", ""), [])
        line = module._portfolio_todo_line(["PF-061", "O85"])
        self.assertIn("PORTFOLIO_RECONCILE_TODO: PF-061, O85 -> 请同步更新 docs/PORTFOLIO.md 与当前 docs/releases/vX.Y.Z.md", line)
        self.assertEqual(module._portfolio_todo_line([]), "")


if __name__ == "__main__":
    unittest.main()
