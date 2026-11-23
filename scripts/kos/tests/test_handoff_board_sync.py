"""O85 handoff reassignment and O84 portfolio reconcile reminder. Stdlib only."""
import contextlib
import importlib.util
import io
import json
import os
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


class HandoffGradeTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        root = Path(self.tmp.name)
        self.packet = root / "packet.md"
        self.report = root / "report.md"
        self.report.write_text("PASS\nPete（Preflight）\n", encoding="utf-8")
        spec = importlib.util.spec_from_file_location("kos_handoff", HANDOFF)
        self.module = importlib.util.module_from_spec(spec)
        sys.path.insert(0, str(HANDOFF.parent))
        try:
            spec.loader.exec_module(self.module)
        finally:
            sys.path.pop(0)

    def _check(self, action, header, expected):
        self.packet.write_text(header + "\n", encoding="utf-8")
        from types import SimpleNamespace
        args = SimpleNamespace(packet=str(self.packet), report=str(self.report),
                               verify_tool="/nonexistent", base="base", pkg_lint_tool="/nonexistent")
        stderr = io.StringIO()
        with contextlib.redirect_stderr(stderr):
            result = getattr(self.module, "cmd_relay_" + action)(args)
        self.assertEqual(result, 1)
        self.assertIn(expected, stderr.getvalue())

    def test_quality_accepts_code_fix_header_variants(self):
        for header in ("包头档位：`code-fix`（说明）", "包头档位：code-fix（说明）",
                       "包头档位: code-fix (description)"):
            with self.subTest(header=header):
                self._check("quality", header, "packet has no 复核重点 section")

    def test_exec_accepts_code_fix_and_doc_rule_header_variants(self):
        for header in ("包头档位：`code-fix`（说明）", "包头档位：code-fix（说明）",
                       "包头档位: doc-rule", "包头档位: doc-rule (description)"):
            with self.subTest(header=header):
                self._check("exec", header, "kos-verify-inputs failed")

    def test_disallowed_grades_fail_closed(self):
        for action, grade in (("exec", "doc-light"), ("exec", "feature"),
                              ("quality", "doc-rule"), ("quality", "feature")):
            for quote in ("", "`"):
                with self.subTest(action=action, grade=grade, quote=quote):
                    self._check(action, f"包头档位：{quote}{grade}{quote}（说明）",
                                f"packet grade {grade} does not allow relay-{action}")

    def test_missing_or_unextractable_grade_fails_closed(self):
        for action in ("exec", "quality"):
            for header, grade in (("包头档位：", "(none)"), ("包头档位：???", "(none)"),
                                  ("包头档位：unknown-grade", "unknown-grade")):
                with self.subTest(action=action, header=header):
                    self._check(action, header, f"packet grade {grade} does not allow relay-{action}")


class SuggestTriggerTests(unittest.TestCase):
    """O88: kos_suggest.py pending boundary + kos_handoff.py final auto-trigger."""

    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.kos_home = self.root / "kos-home"
        self.kos_home.mkdir()
        self.report_dir = self.root / "TASK-X" / "reports"
        self.report_dir.mkdir(parents=True)
        # Import kos_suggest with isolated KOS_HOME
        sys.path.insert(0, str(HANDOFF.parent))
        try:
            import importlib
            import kos_suggest as suggest_mod
            importlib.reload(suggest_mod)
            self.suggest = suggest_mod
        finally:
            sys.path.pop(0)

    def _write_report(self, suggestions_body: str, with_relay: bool = True) -> Path:
        """Write a report with an 观察与改进意见 section."""
        parts = ["DONE", "Lucy（Executor（代码））", ""]
        parts.append("## 观察与改进意见")
        parts.append(suggestions_body)
        parts.append("")
        if with_relay:
            parts.append("## 下一站接力（O41）")
            parts.append("- next_role：Quinn（Quality Reviewer）")
            parts.append("- next_step：复核")
            parts.append("")
            parts.append("```text")
            parts.append("交回：Quinn（Quality Reviewer）")
            parts.append("事项：复核")
            parts.append("```")
        report = self.report_dir / "r1.md"
        report.write_text("\n".join(parts) + "\n", encoding="utf-8")
        return report

    def test_pending_stops_at_fenced_handoff_block(self):
        """交回块 in fence must not be counted as suggestions."""
        report = self._write_report("- 建议A：改善X\n- 建议B：改善Y")
        items = self.suggest.section_items(str(report))
        self.assertEqual(items, ["建议A：改善X", "建议B：改善Y"])

    def test_pending_stops_at_bare_handback_line(self):
        """Bare 交回： line (no fence) must stop scanning."""
        report = self._write_report("- 建议A：改善X\n交回：Quinn（Quality Reviewer）\n- 建议B：改善Y")
        items = self.suggest.section_items(str(report))
        self.assertEqual(items, ["建议A：改善X"])

    def test_pending_stops_at_next_h2_heading(self):
        """## heading must stop scanning."""
        report = self._write_report("- 建议A：改善X\n\n## 其他章节\n- 建议B：改善Y")
        items = self.suggest.section_items(str(report))
        self.assertEqual(items, ["建议A：改善X"])

    def test_pending_missing_section_returns_none(self):
        """Report without 观察与改进意见 section returns None."""
        report = self.report_dir / "no-suggest.md"
        report.write_text("DONE\nLucy（Executor（代码））\n\n## 下一站接力（O41）\n- next_role：Jack（PM）\n", encoding="utf-8")
        self.assertIsNone(self.suggest.section_items(str(report)))

    def test_pending_empty_section_returns_empty(self):
        """Report with 观察与改进意见 but no items returns empty list."""
        report = self._write_report("没有。")
        self.assertEqual(self.suggest.section_items(str(report)), [])

    def test_final_auto_triggers_pending_warning(self):
        """final output includes ⚠ warning when report has unregistered suggestions."""
        report = self._write_report("- 建议A：改善X\n- 建议B：改善Y")
        env = dict(os.environ)
        env["KOS_HOME"] = str(self.kos_home)
        result = _run(HANDOFF, ["final", "--report", str(report), "--skip-lint"], env=env)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("⚠", result.stdout)
        self.assertIn("未登记", result.stdout)

    def test_final_no_warning_when_section_missing(self):
        """final output has no ⚠ warning when report lacks 观察与改进意见."""
        report = self.report_dir / "no-suggest.md"
        report.write_text(
            "DONE\nLucy（Executor（代码））\n\n## 下一站接力（O41）\n- next_role：Jack（PM）\n- next_step：待定\n",
            encoding="utf-8")
        env = dict(os.environ)
        env["KOS_HOME"] = str(self.kos_home)
        result = _run(HANDOFF, ["final", "--report", str(report), "--skip-lint"], env=env)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertNotIn("⚠", result.stdout)

    def test_final_no_warning_when_all_registered(self):
        """final output has no ⚠ when all suggestions are registered."""
        report = self._write_report("- 建议A：改善X")
        env = dict(os.environ)
        env["KOS_HOME"] = str(self.kos_home)
        # Register the suggestion first
        _run(Path(HANDOFF.parent / "kos_suggest.py"), [
            "add", "--task", "TASK-X", "--report", str(report),
            "--text", "建议A：改善X", "--topic", "test-topic-a",
        ], env=env)
        result = _run(HANDOFF, ["final", "--report", str(report), "--skip-lint"], env=env)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertNotIn("⚠", result.stdout)


if __name__ == "__main__":
    unittest.main()
