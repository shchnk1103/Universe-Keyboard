"""Tests for KOS-PACK-CLI-002 (O81): kos_pack.py quick one-shot packaging for
diag / code-fix / doc-light / publish. Stdlib only."""
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

# This path is only rendered into the packet and never created.
WT = str(Path.home() / (".kos" + "-work") / "Universe-Keyboard" / "KOS-QUICK-001" / "worktree")

# kos-pkg-lint E5 only accepts generated-package paths under the KOS work
# root (same root family as WT below). A default temp root (/tmp) or the
# repo checkout fails E5 on Linux CI: the packet there has no absolute
# home-user paths that can swallow the --packet path into an exempt .py
# blob, so the temp out path is matched standalone and rejected. Keep
# generated packages under the KOS work root.
KOS_TMP_ROOT = Path.home() / (".kos" + "-work") / "Universe-Keyboard"

KINDS = ("diag", "code-fix", "doc-light", "publish")


def _sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


class KosPackQuickTests(unittest.TestCase):
    def setUp(self) -> None:
        KOS_TMP_ROOT.mkdir(parents=True, exist_ok=True)
        self.tmp = tempfile.TemporaryDirectory(dir=KOS_TMP_ROOT)
        self.root = Path(self.tmp.name)
        self.inputs = self.root / "inputs"
        self.inputs.mkdir()
        self.a = self.inputs / "a.md"
        self.a.write_text("hello\n", encoding="utf-8")
        self.out = self.root / "pkg.md"
        self.stub = self.root / "board_stub.py"
        self.stub.write_text(
            "#!/usr/bin/env python3\n"
            "import json, sys\n"
            "args = sys.argv[1:]\n"
            "open(sys.argv[0] + '.args.json', 'w').write(json.dumps(args))\n"
            "print('PICK [Executor（代码）]: Quinn（Executor（代码） | 上次：从未记录 -）')\n",
            encoding="utf-8")

    def tearDown(self) -> None:
        self.tmp.cleanup()

    def _run(self, args: list[str]) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            [PY, "-B", str(KOS / "kos_pack.py"), *args],
            capture_output=True, text=True,
        )

    def _quick_args(self, kind: str, out: Path | None = None) -> list[str]:
        return [
            "quick",
            "--task", "KOS-QUICK-001",
            "--kind", kind,
            "--title", "Quick demo task",
            "--branch", "feat/quick-demo",
            "--wt", WT,
            "--out", str(out or self.out),
            "--input", str(self.a),
            "--allow", "scripts/kos/kos_demo.py",
            "--goal", "让 demo 命令能一键出包",
            "--board-tool", str(self.stub),
        ]

    def _repo_head(self) -> str:
        proc = subprocess.run(
            ["git", "-C", str(KOS.parent.parent), "rev-parse", "HEAD"],
            capture_output=True, text=True,
        )
        return proc.stdout.strip()

    def test_all_four_kinds_generate_valid_packages_with_standard_clauses(self) -> None:
        for kind in KINDS:
            out = self.root / ("pkg-%s.md" % kind)
            r = self._run(self._quick_args(kind, out))
            self.assertEqual(r.returncode, 0, "%s: %s" % (kind, r.stdout + r.stderr))
            text = out.read_text(encoding="utf-8")
            # O81: auto-read BASE_HEAD when --base is omitted
            self.assertIn(self._repo_head(), text)
            # frozen input SHA-256 computed live
            self.assertIn("`%s` SHA-256 `%s`" % (self.a, _sha(self.a)), text)
            # 过程静默 standard clause
            self.assertIn("过程静默", text)
            # kos_handoff.py closing commands
            self.assertIn("kos_handoff.py", text)
            self.assertIn("kos-report-lint.py", text)
            # 防套壳短语
            self.assertIn("严禁外层再套代码块", text)
            self.assertIn("防套壳", text)
            # dev-subagent disclosure clause
            self.assertIn("开发子代理", text)
            # goal turned into a step
            self.assertIn("让 demo 命令能一键出包", text)
            # dispatch block printed
            self.assertIn("```text", r.stdout)
            self.assertIn("包路径：%s" % out, r.stdout)
            self.assertIn("SHA-256：%s" % _sha(out), r.stdout)

    def test_kind_grade_mapping_and_lint_zero_errors(self) -> None:
        # quick packages must pass kos-pkg-lint with zero errors (lint is on by
        # default; a nonzero exit means lint failed) and carry the kind's grade
        expected = {"diag": "code-fix", "code-fix": "code-fix",
                    "doc-light": "doc-light", "publish": "doc-rule"}
        for kind in KINDS:
            out = self.root / ("grade-%s.md" % kind)
            r = self._run(self._quick_args(kind, out))
            self.assertEqual(r.returncode, 0, "%s: %s" % (kind, r.stdout + r.stderr))
            self.assertIn("`%s`" % expected[kind], out.read_text(encoding="utf-8"))

    def test_quick_preflight_freezes_exec_package_hash(self) -> None:
        pf = self.root / "preflight-quick.md"
        r = self._run(self._quick_args("code-fix") + ["--preflight-out", str(pf)])
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
        text = pf.read_text(encoding="utf-8")
        self.assertIn("预检包", text)
        self.assertIn("`%s` SHA-256 `%s`" % (self.out, _sha(self.out)), text)
        v = subprocess.run(
            [PY, "-B", str(KOS / "kos-verify-inputs.py"), str(pf)],
            capture_output=True, text=True,
        )
        self.assertEqual(v.returncode, 0, v.stdout + v.stderr)
        self.assertIn("包路径：%s" % pf, r.stdout)
        self.assertIn("SHA-256：%s" % _sha(pf), r.stdout)
        import re
        import shlex
        commands = re.findall(r"`(python3 [^`]*kos_handoff\.py [^`]*)`", text)
        self.assertEqual(len(commands), 1)
        argv = shlex.split(commands[0])
        self.assertEqual(argv[2], "relay-exec")
        self.assertEqual(argv[argv.index("--packet") + 1], str(self.out))
        self.assertEqual(argv[argv.index("--base") + 1], self._repo_head())
        self.assertFalse(any("<" in arg or ">" in arg for arg in argv))

    def test_kind_semantics_and_runnable_handoff_commands(self) -> None:
        import re
        import shlex
        expected = {
            "diag": ("Executor（代码·只读诊断）", "final", "不提交"),
            "code-fix": ("Executor（代码）", "relay-quality", "红绿测试"),
            "doc-light": ("Executor（记录/文档）", "final", "只改文档"),
            "publish": ("Executor（发布）", "final", "发布授权"),
        }
        for kind, (role, action, clause) in expected.items():
            with self.subTest(kind=kind):
                out = self.root / ("semantic-%s.md" % kind)
                r = self._run(self._quick_args(kind, out))
                self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
                text = out.read_text(encoding="utf-8")
                self.assertIn(role, text)
                self.assertIn(clause, text)
                expected_board = {"diag": "code", "code-fix": "code", "doc-light": "doc", "publish": "release"}[kind]
                recorded = json.loads(Path(str(self.stub) + ".args.json").read_text(encoding="utf-8"))
                self.assertEqual(recorded[2], expected_board)
                commands = re.findall(r"`(python3 [^`]*kos_handoff\.py [^`]*)`", text)
                self.assertEqual(len(commands), 1, commands)
                argv = shlex.split(commands[0])
                self.assertEqual(argv[2], action)
                self.assertFalse(any("<" in arg or ">" in arg for arg in argv))
                help_run = subprocess.run([PY, str(KOS / "kos_handoff.py"), action, "--help"],
                                          capture_output=True, text=True)
                self.assertEqual(help_run.returncode, 0, help_run.stderr)
                self.assertNotIn("final/relay-exec/relay-quality", text)

    def test_unknown_kind_fails_closed(self) -> None:
        args = self._quick_args("code-fix")
        i = args.index("--kind")
        args[i + 1] = "bogus-kind"
        r = self._run(args)
        self.assertNotEqual(r.returncode, 0, r.stdout + r.stderr)
        self.assertNotIn("```text", r.stdout)

    def test_missing_goal_fails_closed(self) -> None:
        args = self._quick_args("code-fix")
        i = args.index("--goal")
        del args[i:i + 2]
        r = self._run(args)
        self.assertNotEqual(r.returncode, 0, r.stdout + r.stderr)
        self.assertNotIn("```text", r.stdout)
        self.assertFalse(self.out.exists())


if __name__ == "__main__":
    unittest.main()
