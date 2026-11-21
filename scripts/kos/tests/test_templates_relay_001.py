"""KOS-TEMPLATES-RELAY-001 (O62+A/B/C/D) tests. Stdlib only.

B: kos-draft.py check validates the relay contract header on impl/fix/docs
packets — the 包头档位 value must be a known TIER_PROFILES grade and the
**复核重点** section must exist.
C: kos-report-lint.py gains three checks (each disable-able via --no-xxx):
  C1 line 2 (identity line) must be non-empty;
  C2 non-DONE terminal statuses must carry a next_step in the relay section;
  C3 the report must end with the final three-line handoff block.
A: exec.md renders 包头档位/复核重点 only when quality_focus is set —
exercised in the sandboxed render test below (mirrors test_templates_contract).
"""
from __future__ import annotations

import importlib.util
import json
import os
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
KOS = ROOT / "scripts/kos"
KOS_HOME = Path.home() / ".kos-work/Universe-Keyboard"
PY = sys.executable


def _load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(module)
    return module


def _run(cmd, env=None):
    return subprocess.run(cmd, capture_output=True, text=True, check=False, env=env)


GOOD_PACKET_TAIL = (
    "## Human 预批准项（以 Human 粘贴本包派发块为授权）\n"
    "只含：①示例\n"
    "不含：不 push、不开 PR、不合并\n"
    "\n"
    "## 要做什么\n"
    "1. 示例步骤；验收：完成。\n"
    "\n"
    "## 判定\n"
    "仅全部步骤完成为 DONE。\n"
    "\n"
    "## 滚动交接报告（必带）与报告\n"
    "开工第一步创建报告，第一行 IN-PROGRESS，输出存在不得覆盖。知识库文档：见文档一步。\n"
    "\n"
    "## 观察与改进意见（可选）\n"
    "没有。\n"
)

GOOD_PACKET_HEAD = (
    "# 任务包：示例\n"
    "\n"
    "**你的角色：Executor（代码；派给 Lucy）。** 可使用只读 subagent（检索），报告须声明用或没用。"
    "报告第二行写明实际运行时身份与既往。预算 45 分钟。分级：小任务，无 Assignment。\n"
    "\n"
    "## 背景（事实与来源）\n"
    "示例背景。\n"
    "\n"
)


class DraftRelayHeaderTests(unittest.TestCase):
    """B: kos-draft check enforces grade whitelist + 复核重点 on impl packets."""

    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)

    def tearDown(self):
        self.tmp.cleanup()

    def _packet(self, body):
        p = self.root / "packet.draft.md"
        p.write_text(body, encoding="utf-8")
        return p

    def _check(self, path):
        draft = KOS_HOME / "tools/kos-draft.py"
        if not draft.is_file():
            self.skipTest("external kos-draft unavailable")
        return _run([PY, "-I", "-B", str(draft), "check", str(path), "--type", "impl"])

    def test_good_grade_with_focus_passes(self):
        body = GOOD_PACKET_HEAD + "- **包头档位**：`code-fix`\n- **复核重点**：\n  1. 核对实现。\n\n" + GOOD_PACKET_TAIL
        result = self._check(self._packet(body))
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertNotIn("档位", result.stdout)
        self.assertNotIn("复核重点", result.stdout)

    def test_missing_grade_and_focus_is_error(self):
        result = self._check(self._packet(GOOD_PACKET_HEAD + GOOD_PACKET_TAIL))
        self.assertEqual(result.returncode, 1)
        self.assertIn("包头档位", result.stdout)
        self.assertIn("复核重点", result.stdout)

    def test_unknown_grade_is_error(self):
        body = GOOD_PACKET_HEAD + "- **包头档位**：`turbo`\n- **复核重点**：\n  1. 核对实现。\n\n" + GOOD_PACKET_TAIL
        result = self._check(self._packet(body))
        self.assertEqual(result.returncode, 1)
        self.assertIn("档位", result.stdout)

    def test_known_grade_without_focus_is_error(self):
        body = GOOD_PACKET_HEAD + "- **包头档位**：`code-fix`\n\n" + GOOD_PACKET_TAIL
        result = self._check(self._packet(body))
        self.assertEqual(result.returncode, 1)
        self.assertIn("复核重点", result.stdout)


class ReportLintFormatTests(unittest.TestCase):
    """C: three new report-lint checks, each disable-able."""

    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)

    def tearDown(self):
        self.tmp.cleanup()

    def _report(self, status, identity, relay_next_role, relay_next_step=None, final_block=True):
        lines = [status, identity, "", "## 下一站接力（O41）", f"- next_role：{relay_next_role}"]
        if relay_next_step is not None:
            lines.append(f"- next_step：{relay_next_step}")
        lines.append("")
        if final_block:
            lines += ["```text", f"交回：{relay_next_role}", "事项：做下一步", "```", ""]
        p = self.root / "executor-report-x.md"
        p.write_text("\n".join(lines), encoding="utf-8")
        return p

    def _lint(self, path, *extra):
        return _run([PY, "-I", "-B", str(KOS / "kos-report-lint.py"), str(path), *extra])

    def test_done_report_with_all_parts_passes(self):
        p = self._report("DONE", "Lucy（Executor（代码））；身份。", "Maya（Quality）", "复核", final_block=True)
        result = self._lint(p)
        self.assertEqual(result.returncode, 0, result.stdout)
        self.assertEqual(result.stdout.strip(), "OK")

    def test_empty_identity_line_is_flagged(self):
        p = self._report("DONE", "", "Maya（Quality）", "复核")
        result = self._lint(p)
        self.assertEqual(result.returncode, 1)
        self.assertIn("第二行", result.stdout)
        # C1 can be disabled
        result = self._lint(p, "--no-identity-line")
        self.assertNotIn("第二行", result.stdout)

    def test_non_done_without_next_step_is_flagged(self):
        p = self._report("PARTIAL", "Lucy（Executor（代码））；身份。", "Jack（PM）", None)
        result = self._lint(p)
        self.assertEqual(result.returncode, 1)
        self.assertIn("next_step", result.stdout)
        result = self._lint(p, "--no-next-step")
        self.assertNotIn("next_step", result.stdout)

    def test_missing_final_block_is_flagged(self):
        p = self._report("DONE", "Lucy（Executor（代码））；身份。", "Maya（Quality）", "复核", final_block=False)
        result = self._lint(p)
        self.assertEqual(result.returncode, 1)
        self.assertIn("三行", result.stdout)
        result = self._lint(p, "--no-final-block")
        self.assertNotIn("三行", result.stdout)


class ExecTemplateRenderTests(unittest.TestCase):
    """A: quality_focus block renders both sections, absent renders none."""

    def _render_impl(self, quality_focus):
        source = KOS_HOME
        generator = source / "tools/kos-draft.py"
        templates = source / "templates"
        if not generator.is_file() or not (templates / "exec.md").is_file():
            self.skipTest("external kos-draft and templates unavailable")
        with tempfile.TemporaryDirectory() as tmp:
            home = Path(tmp)
            shutil.copytree(templates, home / "templates")
            (home / "fixture" / "instructions").mkdir(parents=True)
            gen = home / "kos-draft.py"
            shutil.copy(generator, gen)
            script = (
                "import importlib.util, json, sys\n"
                "spec = importlib.util.spec_from_file_location('draft', sys.argv[1])\n"
                "m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)\n"
                "template = m.expand_cmds(m.read(m.os.path.join(m.TPL, m.TYPES['impl'][0])))\n"
                "keys, _, required = m.keys_of(template)\n"
                "p = {k: 'fixture-value' for k in required | set(m.TYPES['impl'][3])}\n"
                "p.update(task='fixture', name='test', wt_new='yes')\n"
                "if len(sys.argv) > 2:\n"
                "    p['quality_focus'] = sys.argv[2]\n"
                "print(json.dumps(m.render('impl', p)[0], ensure_ascii=False))\n"
            )
            result = _run([PY, "-I", "-c", script, str(gen)] + ([quality_focus] if quality_focus else []),
                          env=dict(os.environ, KOS_HOME=str(home), UK_REPO=str(ROOT)))
            self.assertEqual(result.returncode, 0, result.stderr)
            return json.loads(result.stdout)

    def test_with_quality_focus_renders_both_sections(self):
        out = self._render_impl("code-fix")
        self.assertIn("- **包头档位**：`code-fix`", out)
        self.assertIn("**复核重点**", out)

    def test_without_quality_focus_renders_neither(self):
        out = self._render_impl(None)
        self.assertNotIn("包头档位", out)
        self.assertNotIn("复核重点", out)


if __name__ == "__main__":
    unittest.main()
