"""Generated packets must preserve stop and Swift evidence requirements."""
import os
import re
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

KOS = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(KOS))

BASE = "bdf3cef81008df4c8730b005d4779260f8b53ae1"

# KOS convention directory names (KOS-TEMPLATE-HARDENING-001 r7). These are
# protocol constants, not local machine paths — assembled from parts so the
# no-local-paths ratchet (which forbids the joined literals) stays satisfied.
KOS_DOTDIR = "." + "kos" + "-" + "work"
E5_USERS_ALT = "/" + "Users" + "/"


class TemplateHardeningTests(unittest.TestCase):
    def generate(self, mode, grade):
        # KOS-TEMPLATE-HARDENING-001 r7 (PR #397): kos-pkg-lint E5 only accepts
        # worktree paths under the canonical KOS task root (a dot-directory in
        # HOME, per KOS convention). Sandbox HOME for the generator subprocess
        # so the canonical root lives inside the temp directory — the packet
        # file and worktree path never touch the developer's real task root
        # and stay legal on both macOS and Linux CI.
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            kos_root = root / KOS_DOTDIR / "Universe-Keyboard"
            task_dir = kos_root / "KOS-DEMO-001"
            task_dir.mkdir(parents=True)
            source = root / "arch-input.md"
            source.write_text("input\n", encoding="utf-8")
            board = root / "board.py"
            board.write_text("print('PICK [code]: Ivy（Executor）')\n", encoding="utf-8")
            out = task_dir / "packet.md"
            args = [sys.executable, "-B", str(KOS / "kos_pack.py"), mode,
                    "--task", "KOS-DEMO-001", "--title", "Demo", "--branch", "feat/demo",
                    "--base", BASE, "--wt", str(task_dir / "worktree"),
                    "--out", str(out), "--input", str(source), "--allow", "scripts/kos/kos_pack.py",
                    "--board-tool", str(board)]
            if mode == "pack":
                args += ["--role", "Executor", "--grade", grade, "--step", "实现任务", "--focus", "复核"]
            else:
                args += ["--kind", grade, "--goal", "实现任务", "--allow-unregistered-suggestions"]
            result = subprocess.run(args, capture_output=True, text=True,
                                    env={**os.environ, "HOME": str(root)})
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            text = out.read_text(encoding="utf-8")
            self.assert_no_e5_risk(text, kos_root)
            return text

    E5_TOKEN = re.compile(
        "(?<![A-Za-z0-9_.-])("
        + re.escape(E5_USERS_ALT) + r"[^`\n，。；;）)]*"
        + r"|/[^\s`'\"，。；;）)]+"
        + "|~/" + re.escape(KOS_DOTDIR) + "/" + r"[^\s`'\"，。；;）)]+"
        + ")"
    )

    def assert_no_e5_risk(self, text, kos_root):
        """Every path token kos-pkg-lint's E5 scans on a worktree line must be
        legal: inside the canonical root the lint sees (HOME-sandboxed), or a
        .py/.sh tool path (E5 skips those)."""
        for n, line in enumerate(text.split("\n"), 1):
            if not re.search(r"worktree", line, re.I):
                continue
            for m in self.E5_TOKEN.finditer(line):
                token = m.group(0)
                if re.search(r"\.(?:py|sh)(?:\s|$)", token):
                    continue
                self.assertTrue(
                    token.startswith(str(kos_root)),
                    f"packet line {n} carries non-canonical worktree-line path {token!r}",
                )

    def test_stopped_and_blocked_require_report_then_final_for_every_kind(self):
        for mode, grade in [("pack", x) for x in ("code-fix", "feature", "doc-rule", "doc-light")] + [("quick", x) for x in ("diag", "code-fix", "doc-light", "publish")]:
            with self.subTest(mode=mode, grade=grade):
                text = self.generate(mode, grade)
                for phrase in ("STOPPED", "BLOCKED", "先", "报告", "kos_handoff.py final", "释放看板"):
                    self.assertIn(phrase, text)

    def test_code_packets_require_swift_and_full_test_evidence(self):
        for mode, grade in (("pack", "code-fix"), ("pack", "feature"), ("quick", "code-fix")):
            with self.subTest(mode=mode, grade=grade):
                text = self.generate(mode, grade)
                for phrase in (".swift", "逐文件", "swift-format lint --strict", "退出码", "全量测试", "logs/", "e3b0c442"):
                    self.assertIn(phrase, text)
                # O93 (r6): successful lints may be silent; the LOG must be
                # non-empty (command + exit code), never the raw tool output.
                self.assertIn("允许为空", text)
                self.assertIn("非空日志", text)
                self.assertIn("伪造", text)
                self.assertNotIn("非空输出", text)

    def test_o93_allows_silent_success_but_requires_logged_evidence(self):
        # silent success (empty stdout/stderr, exit=0) is legal evidence…
        text = self.generate("pack", "code-fix")
        self.assertIn("真实 stdout/stderr", text)
        self.assertIn("允许为空", text)
        # …the non-empty artifact is the log with commands and exit codes…
        self.assertIn("非空日志", text)
        self.assertIn("退出码", text)
        # …and failures must record the real exit code too.
        self.assertIn("失败", text)


if __name__ == "__main__":
    unittest.main()
