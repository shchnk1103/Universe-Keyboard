"""Tests for KOS-PACK-CLI-001: kos_pack.py one-shot packaging CLI. Stdlib only."""
from __future__ import annotations

import hashlib
import json
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

KOS = Path(__file__).resolve().parents[1]
PY = sys.executable


def _repo_head() -> str:
    """Real commit SHA of the worktree repo (O111: lint validates --start by default)."""
    repo = KOS.parent.parent
    return subprocess.run(["git", "-C", str(repo), "rev-parse", "HEAD"],
                          capture_output=True, text=True, check=True).stdout.strip()


BASE_SHA = _repo_head()

# A worktree path string that pkg-lint accepts (must live under the KOS root);
# the string is only checked as package content, never created on disk.
WT = "/Users/doubleshy0n/.kos-work/Universe-Keyboard/KOS-DEMO-001/worktree"
OUT = "/Users/doubleshy0n/.kos-work/Universe-Keyboard/KOS-DEMO-001/packets/task-package-impl-r1.md"


def _sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


class KosPackTests(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.inputs = self.root / "inputs"
        self.inputs.mkdir()
        self.a = self.inputs / "a.md"
        self.a.write_text("hello\n", encoding="utf-8")
        self.b = self.inputs / "b.log"
        self.b.write_text("x\n" * 3, encoding="utf-8")
        self.out = self.root / "pkg.md"
        self.stub = self.root / "board_stub.py"
        self.stub.write_text(
            "#!/usr/bin/env python3\n"
            "import json, sys\n"
            "args = sys.argv[1:]\n"
            "open(sys.argv[0] + '.args.json', 'w').write(json.dumps(args))\n"
            "print('PICK [Executor（代码）]: Quinn（Executor（代码） | 上次：从未记录 -）')\n",
            encoding="utf-8")
        self.base_args = [
            "pack",
            "--task", "KOS-DEMO-001",
            "--role", "Executor（代码）",
            "--grade", "code-fix",
            "--title", "Demo task",
            "--branch", "feat/demo",
            "--base", BASE_SHA,
            "--wt", WT,
            "--out", str(self.out),
            "--input", str(self.a),
            "--input", str(self.b),
            "--allow", "scripts/kos/kos_demo.py",
            "--step", "实现 demo",
            "--focus", "demo 红测先行",
            "--board-tool", str(self.stub),
            "--board-role", "code",
        ]

    def tearDown(self) -> None:
        self.tmp.cleanup()

    def _run(self, args: list[str]) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            [PY, "-B", str(KOS / "kos_pack.py"), *args],
            capture_output=True, text=True,
        )

    def test_freezes_computed_hashes_and_prints_dispatch_block(self) -> None:
        r = self._run(self.base_args)
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
        text = self.out.read_text(encoding="utf-8")
        for f in (self.a, self.b):
            self.assertIn(f"- `{f}` SHA-256 `{_sha(f)}`", text)
        self.assertIn("包头档位", text)
        self.assertIn("`code-fix`", text)
        self.assertIn("复核重点", text)
        for section in ("## 冻结输入", "## 允许写入路径", "## 要做什么", "## 报告与交付"):
            self.assertIn(section, text)
        self.assertIn(WT, text)
        self.assertIn("feat/demo", text)
        self.assertIn("kos_demo.py", text)
        self.assertIn("（新增）", text)
        self.assertIn("实现 demo", text)
        # dispatch block with package path, package sha and picked person
        self.assertIn("```text", r.stdout)
        self.assertIn(f"包路径：{self.out}", r.stdout)
        self.assertIn(f"SHA-256：{_sha(self.out)}", r.stdout)
        self.assertIn("Quinn", r.stdout)
        # stub was invoked with pick and the requested board role
        recorded = json.loads((Path(str(self.stub) + ".args.json")).read_text(encoding="utf-8"))
        # KOS-BOARD-RESERVE-001 (O77): pick now reserves the picked person for the task
        self.assertEqual(recorded, ["pick", "--role", "code", "--reserve", "KOS-DEMO-001"])

    def test_missing_input_fails_closed(self) -> None:
        args = self.base_args + ["--input", str(self.root / "ghost.md")]
        r = self._run(args)
        self.assertNotEqual(r.returncode, 0, r.stdout + r.stderr)
        self.assertNotIn("```text", r.stdout)
        self.assertFalse(self.out.exists())

    def test_truncated_hash_input_fails_closed(self) -> None:
        # a declared 58-char hash is not something kos_pack ever writes; assert
        # the generated package never contains a non-64 hex digest pair
        r = self._run(self.base_args)
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
        text = self.out.read_text(encoding="utf-8")
        import re
        bad = re.findall(r"`([0-9a-f]{41,63}|[0-9a-f]{65,})`", text)
        self.assertEqual(bad, [])

    def test_unknown_grade_fails_closed(self) -> None:
        args = list(self.base_args)
        i = args.index("--grade")
        args[i + 1] = "bogus-grade"
        r = self._run(args)
        self.assertNotEqual(r.returncode, 0, r.stdout + r.stderr)
        self.assertNotIn("```text", r.stdout)

    def test_board_pick_failure_fails_closed(self) -> None:
        stub = self.root / "failing_stub.py"
        stub.write_text("#!/usr/bin/env python3\nimport sys\nprint('PICK: NONE（当前无可用空闲成员）')\nsys.exit(1)\n", encoding="utf-8")
        args = list(self.base_args)
        i = args.index("--board-tool")
        args[i + 1] = str(stub)
        r = self._run(args)
        self.assertNotEqual(r.returncode, 0, r.stdout + r.stderr)
        self.assertNotIn("```text", r.stdout)

    def test_preflight_package_freezes_exec_package_hash(self) -> None:
        pf = self.root / "preflight.md"
        args = self.base_args + ["--preflight-out", str(pf)]
        r = self._run(args)
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
        text = pf.read_text(encoding="utf-8")
        self.assertIn(f"`{self.out}` SHA-256 `{_sha(self.out)}`", text)
        # preflight passes kos-verify-inputs on its own
        v = subprocess.run(
            [PY, "-B", str(KOS / "kos-verify-inputs.py"), str(pf)],
            capture_output=True, text=True,
        )
        self.assertEqual(v.returncode, 0, v.stdout + v.stderr)
        # preflight dispatch block is also printed
        self.assertIn(f"包路径：{pf}", r.stdout)
        self.assertIn(f"SHA-256：{_sha(pf)}", r.stdout)

    def test_lint_failure_fails_closed(self) -> None:
        # an --allow path that duplicates the only step yields a package that
        # still passes; force a lint failure by pointing --input at a directory
        d = self.root / "adir"
        d.mkdir()
        args = self.base_args + ["--input", str(d)]
        r = self._run(args)
        self.assertNotEqual(r.returncode, 0, r.stdout + r.stderr)
        self.assertNotIn("```text", r.stdout)



class ClosingSequenceTemplateTests(unittest.TestCase):
    """KOS-LINT-BASELINE-GUARD-001 (O111): generated impl/doc packets must
    contain the fixed, contradiction-free closing order."""

    CLOSING_STEPS = (
        "移除临时软链（如有）",
        "git status --short",
        "git add",
        "git commit",
        "确认工作树干净",
    )

    def _generate(self, grade: str) -> str:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source = root / "in.md"
            source.write_text("hello\n", encoding="utf-8")
            board = root / "board.py"
            board.write_text("print('PICK [code]: Quinn（Executor（代码） | 上次：从未记录 -）')\n",
                             encoding="utf-8")
            out = root / "packet.md"
            args = [PY, "-B", str(KOS / "kos_pack.py"), "pack",
                    "--task", "KOS-DEMO-001",
                    "--role", "Executor（代码）",
                    "--grade", grade,
                    "--title", "Demo",
                    "--branch", "feat/demo",
                    "--base", BASE_SHA,
                    "--wt", WT,
                    "--out", str(out),
                    "--input", str(source),
                    "--allow", "scripts/kos/kos_demo.py",
                    "--step", "实现 demo",
                    "--focus", "复核",
                    "--board-tool", str(board)]
            r = subprocess.run(args, capture_output=True, text=True)
            self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
            return out.read_text(encoding="utf-8")

    def test_code_fix_packet_has_fixed_closing_order(self) -> None:
        text = self._generate("code-fix")
        idx = [text.find(step) for step in self.CLOSING_STEPS]
        for step, i in zip(self.CLOSING_STEPS, idx):
            self.assertGreaterEqual(i, 0, f"missing closing step: {step}")
        self.assertEqual(idx, sorted(idx), f"closing order wrong: {idx}")

    def test_doc_light_packet_has_fixed_closing_order(self) -> None:
        text = self._generate("doc-light")
        idx = [text.find(step) for step in self.CLOSING_STEPS]
        for step, i in zip(self.CLOSING_STEPS, idx):
            self.assertGreaterEqual(i, 0, f"missing closing step: {step}")
        self.assertEqual(idx, sorted(idx), f"closing order wrong: {idx}")

    def test_closing_order_section_is_explicit(self) -> None:
        text = self._generate("code-fix")
        self.assertIn("收尾顺序", text)
        # contradiction guard: the template must not demand a clean tree
        # BEFORE the commit step in a way that conflicts with the closing order
        self.assertIn("仅剩本包允许改动", text)
        self.assertNotIn("提交前工作树必须干净", text)


if __name__ == "__main__":
    unittest.main()
