"""KOS-LINT-NEWFILE-001: kos-pkg-lint E6 exemptions for declared new files and
$KOS_HOME/tools scripts. Stdlib only; never touches the real KOS home."""
from __future__ import annotations

import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SCRIPT = ROOT / "scripts/kos/kos-pkg-lint.py"
START = "a" * 40

NOTICE = "将 stdout 直接作为 Markdown 原样回复，严禁外层再套代码块。"


def run(text: str, kos_home: "str | None" = None) -> subprocess.CompletedProcess:
    with tempfile.TemporaryDirectory() as tmp:
        path = Path(tmp) / "task-package-impl.md"
        path.write_text(text, encoding="utf-8")
        env = dict(os.environ)
        if kos_home is not None:
            env["KOS_HOME"] = kos_home
            env["KOS_PROJECT"] = "Universe-Keyboard"
        return subprocess.run(
            [sys.executable, "-I", str(SCRIPT), "--start", START, str(path)],
            text=True, capture_output=True, check=False, env=env,
        )


PKG_TMPL = """# 任务包：KOS-DEMO-001（demo）
角色：Executor（代码）；你不是 PM
## 允许写入路径
{allow_section}
## 要做什么
{steps}
## 报告与交付
- `python3 scripts/kos/kos_handoff.py final --report <报告路径>`，{notice}
"""


def pkg(allow_lines: str, body_refs: str) -> str:
    steps = "\n".join("1. 引用 `%s` 并完成工作。" % r for r in body_refs)
    return PKG_TMPL.format(allow_section=allow_lines, steps=steps, notice=NOTICE)


class NewFileExemptionTests(unittest.TestCase):
    def test_declared_new_file_is_exempt_everywhere(self) -> None:
        allow = "- `scripts/kos/new_tool.py`（新增）\n"
        text = pkg(allow, ["scripts/kos/new_tool.py", "scripts/kos/new_tool.py"])
        r = run(text)
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
        self.assertNotIn("E6 ", r.stdout)

    def test_allow_marker_variants_are_exempt(self) -> None:
        # markdown bullet variants and bare paths without backticks
        allow = "* scripts/kos/star_tool.py（新增）\n  - `scripts/kos/nested_tool.py`（新增）\n"
        text = pkg(allow, ["scripts/kos/star_tool.py", "scripts/kos/nested_tool.py"])
        r = run(text)
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
        self.assertNotIn("E6 ", r.stdout)

    def test_undeclared_typo_script_still_e6(self) -> None:
        allow = "- `scripts/kos/new_tool.py`（新增）\n"
        text = pkg(allow, ["scripts/kos/typo_tool.py"])
        r = run(text)
        self.assertEqual(r.returncode, 1)
        self.assertIn("E6 ", r.stdout)
        self.assertIn("typo_tool.py", r.stdout)

    def test_new_marker_outside_allow_section_does_not_exempt(self) -> None:
        allow = "- `scripts/kos/new_tool.py`（新增）\n"
        text = pkg(allow, ["scripts/kos/new_tool.py", "scripts/kos/sneaky_tool.py"])
        # sneaky_tool.py declared (新增) only in prose, not in the allow section
        text = text.replace("引用 `scripts/kos/sneaky_tool.py` 并完成工作。",
                            "引用 `scripts/kos/sneaky_tool.py`（新增）并完成工作。")
        r = run(text)
        self.assertEqual(r.returncode, 1)
        self.assertIn("E6 ", r.stdout)
        self.assertIn("sneaky_tool.py", r.stdout)

    def test_kos_home_tools_script_is_exempt(self) -> None:
        with tempfile.TemporaryDirectory() as home:
            helper = Path(home) / "Universe-Keyboard" / "tools" / "helper.py"
            helper.parent.mkdir(parents=True)
            helper.write_text("# helper\n", encoding="utf-8")
            allow = "- `scripts/kos/new_tool.py`（新增）\n"
            text = pkg(allow, ["tools/helper.py"])
            r = run(text, kos_home=home)
            self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
            self.assertNotIn("E6 ", r.stdout)

    def test_kos_home_missing_tools_script_still_e6(self) -> None:
        with tempfile.TemporaryDirectory() as home:
            allow = "- `scripts/kos/new_tool.py`（新增）\n"
            text = pkg(allow, ["tools/ghost.py"])
            r = run(text, kos_home=home)
            self.assertEqual(r.returncode, 1)
            self.assertIn("E6 ", r.stdout)
            self.assertIn("ghost.py", r.stdout)

    def test_kos_home_tools_script_declared_new_is_also_exempt(self) -> None:
        # a tools/ path declared (新增) in the allow section is exempt even
        # though it does not exist yet anywhere
        allow = "- `tools/fresh_helper.py`（新增）\n"
        text = pkg(allow, ["tools/fresh_helper.py"])
        r = run(text)
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
        self.assertNotIn("E6 ", r.stdout)


if __name__ == "__main__":
    unittest.main()
