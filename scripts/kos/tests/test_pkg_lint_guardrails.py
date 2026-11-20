"""Guardrail coverage for kos-pkg-lint E5–E8 and W5. Stdlib only."""
import importlib.util
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SCRIPT = ROOT / "scripts/kos/kos-pkg-lint.py"
START = "a" * 40

def run(text: str) -> subprocess.CompletedProcess[str]:
    with tempfile.TemporaryDirectory() as tmp:
        path = Path(tmp) / "task-package-impl.md"
        path.write_text(text, encoding="utf-8")
        return subprocess.run(
            [sys.executable, "-I", str(SCRIPT), "--start", START, str(path)],
            text=True, capture_output=True, check=False,
        )

class GuardrailTests(unittest.TestCase):
    def test_token_table_is_explicit(self) -> None:
        spec = importlib.util.spec_from_file_location("kos_pkg_lint", SCRIPT)
        module = importlib.util.module_from_spec(spec)
        assert spec.loader is not None
        spec.loader.exec_module(module)
        self.assertEqual(len(module.E7_REQUIRED_TOKENS), 6)
        self.assertIn(("CODE_SIGN_IDENTITY=-", "-only-testing"), module.E7_REQUIRED_TOKENS)

    def test_worktree_under_repository_is_e5(self) -> None:
        result = run("新建 worktree：/Users/doubleshy0n/Dev/Universe Keyboard/.worktrees/key\n")
        self.assertEqual(result.returncode, 1)
        self.assertIn("E5 ", result.stdout)

    def test_arbitrary_absolute_worktree_is_e5(self) -> None:
        result = run("新建 worktree /srv/invalid/worktree\n")
        self.assertIn("E5 ", result.stdout)

    def test_external_kos_worktree_is_allowed(self) -> None:
        result = run("新建 worktree：~/.kos-work/Universe-Keyboard/KOS-PKG-LINT-001/worktree\n")
        self.assertNotIn("E5 ", result.stdout)
        self.assertEqual(result.returncode, 0, result.stdout)

    def test_historical_cleanup_is_exempt(self) -> None:
        result = run("清理旧 /Users/doubleshy0n/Dev/Universe Keyboard/.worktrees/key，不再使用。\n".replace("不再使用。", "。"))
        self.assertNotIn("E5 ", result.stdout)

    def test_obsolete_handoff_script_is_e6(self) -> None:
        result = run("使用 render_handoff_v1.py 交接。\n")
        self.assertIn("E6 ", result.stdout)

    def test_canonical_handoff_script_exists(self) -> None:
        result = run("python3 -I scripts/kos/kos_handoff.py render\n")
        self.assertNotIn("E6 ", result.stdout)
        self.assertEqual(result.returncode, 0, result.stdout)

    def test_wrong_signing_flag_is_e7(self) -> None:
        result = run("命令含 CODE_SIGNING_IDENTITY=-。\n")
        self.assertIn("CODE_SIGNING_IDENTITY=-", result.stdout)
        self.assertIn("E7 ", result.stdout)

    def test_incomplete_full_gate_is_e7(self) -> None:
        result = run("本地 full 门禁只写 swift-format lint 与 swift test KeyboardCore。\n")
        self.assertIn("缺少步骤", result.stdout)

    def test_complete_full_gate_passes(self) -> None:
        text = "\n".join([
            "本地 full 门禁与 CI 参数完整一致，但 -retry-tests-on-failure 不属于本地门禁。",
            "xcrun swift-format lint --strict .",
            "swift test --package-path Packages/KeyboardCore",
            "xcodebuild -scheme RimeBridgeTests test",
            'xcodebuild -scheme "Universe Keyboard" test',
            'xcodebuild -scheme "Universe Keyboard" CODE_SIGN_IDENTITY=- -only-testing:UniverseKeyboardTests/RimeSyncModelTests/testRimeSyncSecretStorePersistsUpdatesAndDeletesAUniqueKeychainItem test',
            'xcodebuild -scheme "Universe Keyboard" -configuration Release build',
        ])
        result = run(text + "\n")
        self.assertNotIn("E7 ", result.stdout)
        self.assertEqual(result.returncode, 0, result.stdout)

    def test_unpaired_declared_hash_is_e8(self) -> None:
        result = run("运行 kos-verify-inputs.py\n/Users/a/frozen.md " + "b" * 64 + "\n")
        self.assertIn("E8 ", result.stdout)
        self.assertIn("W5 ", result.stdout)

    def test_backtick_pair_has_no_hash_warning(self) -> None:
        result = run("冻结输入：`/Users/doubleshy0n/.kos-work/Universe-Keyboard/KOS-PKG-LINT-001/reports/frozen.md` `" + "c" * 64 + "`\n")
        self.assertNotIn("E8 ", result.stdout)
        self.assertNotIn("W5 ", result.stdout)
        self.assertEqual(result.returncode, 0, result.stdout)

    def test_placeholder_pair_does_not_satisfy_verify(self) -> None:
        result = run('运行 kos-verify-inputs.py\n`/tmp/<file>.md` `' + 'a' * 64 + '`\n')
        self.assertIn('E8 ', result.stdout)

    def test_worktree_cannot_escape_root(self) -> None:
        result = run('新建 worktree ~/.kos-work/Universe-Keyboard/../../other/worktree\n')
        self.assertIn('E5 ', result.stdout)

    def test_scattered_tokens_are_not_commands(self) -> None:
        text = '''本地 full 门禁
swift-format lint
swift test KeyboardCore
RimeBridgeTests
scheme "Universe Keyboard" test
CODE_SIGN_IDENTITY=- -only-testing
-configuration Release build
'''
        self.assertIn('E7 ', run(text).stdout)

    def test_handoff_absolute_path_with_spaces_and_placeholder(self) -> None:
        result = run(f'python3 -I "{ROOT}/scripts/kos/kos_handoff.py" render\n`tools/<example>.py`\n')
        self.assertNotIn('E6 ', result.stdout)

    def test_missing_absolute_script_even_if_relative_exists(self) -> None:
        result = run('python3 scripts/kos/kos_handoff.py render\n`/tmp/no such place/scripts/kos/kos_handoff.py`\n')
        self.assertIn('E6 ', result.stdout)

    def test_markdown_list_full_gate_and_each_missing_step(self) -> None:
        commands = [
            "- `xcrun swift-format lint --strict .`",
            "1. `swift test --package-path Packages/KeyboardCore`",
            "* `xcodebuild -scheme RimeBridgeTests test`",
            '2. `xcodebuild -scheme "Universe Keyboard" test`',
            '3. `xcodebuild -scheme "Universe Keyboard" CODE_SIGN_IDENTITY=- -only-testing:UniverseKeyboardTests/RimeSyncModelTests/testRimeSyncSecretStorePersistsUpdatesAndDeletesAUniqueKeychainItem test`',
            '4. `xcodebuild -scheme "Universe Keyboard" -configuration Release build`',
        ]
        def package(lines):
            return "本地 full 门禁\n" + "\n".join(lines) + "\n"
        full = run(package(commands))
        self.assertEqual(full.returncode, 0, full.stdout)
        for i in range(len(commands)):
            with self.subTest(missing=i):
                self.assertIn("E7 ", run(package(commands[:i] + commands[i+1:])).stdout)

    def test_inline_backtick_fragments_in_command(self) -> None:
        text = '本地 full 门禁\n- `xcrun` swift-format `lint` --strict .\n'
        self.assertNotIn("swift-format", run(text).stdout.split("缺少步骤：", 1)[-1])

    def test_rule_and_revision_explanations_are_exempt(self) -> None:
        for text in [
            "出现 `render_handoff_v1.py` 报 E6。",
            "出现 `CODE_SIGNING_IDENTITY=-` 报 E7。",
            "已修正旧值 `CODE_SIGNING_IDENTITY=-` -> `CODE_SIGN_IDENTITY=-`。",
            "禁止 `render_handoff_v1.py`。",
        ]:
            with self.subTest(text=text):
                output = run(text + "\n").stdout
                self.assertNotIn("E6 ", output)
                self.assertNotIn("E7 ", output)

    def test_actual_invalid_commands_are_rejected(self) -> None:
        self.assertIn("E6 ", run("- `python3 render_handoff_v1.py`\n").stdout)
        self.assertIn("E7 ", run("- `xcodebuild CODE_SIGN_IDENTITY=- test`\n").stdout)
        self.assertIn("E6 ", run("使用 render_handoff_v1.py 交接\n").stdout)


class HandoffFlagLintTests(unittest.TestCase):
    """E6 subcommand/flag legality and anti-wrapping notice requirements (KOS-LINT-HANDOFF-FLAGS)."""

    def _run(self, text: str) -> subprocess.CompletedProcess[str]:
        return run(text + "\n")

    def test_unknown_subcommand_is_e6(self) -> None:
        result = self._run("- `python3 scripts/kos/kos_handoff.py blast --report x.md`\n")
        self.assertIn("E6 ", result.stdout)
        self.assertIn("未知子命令", result.stdout)

    def test_illegal_flag_on_relay_subcommands_is_e6(self) -> None:
        for sub in ("relay-exec", "relay-quality", "final"):
            with self.subTest(sub=sub):
                result = self._run(f"- `python3 scripts/kos/kos_handoff.py {sub} --grade code-fix`\n")
                self.assertIn("E6 ", result.stdout)
                self.assertIn("--grade", result.stdout)

    def test_legal_relay_call_without_wrap_notice_is_e6(self) -> None:
        result = self._run("- `python3 scripts/kos/kos_handoff.py final --report x.md`\n")
        self.assertIn("E6 ", result.stdout)
        self.assertIn("防套", result.stdout)

    def test_legal_relay_call_with_wrap_notice_passes(self) -> None:
        result = self._run(
            "- `python3 scripts/kos/kos_handoff.py final --report x.md`\n"
            "- 将 stdout 直接作为 Markdown 原样回复，严禁外层再套代码块。\n"
        )
        self.assertNotIn("E6 ", result.stdout)
        self.assertEqual(result.returncode, 0, result.stdout)

    def test_profile_grade_is_legal(self) -> None:
        result = self._run(
            "- `python3 scripts/kos/kos_handoff.py profile --grade code-fix`\n"
            "- 无接力。\n"
        )
        self.assertNotIn("E6 ", result.stdout)
        self.assertEqual(result.returncode, 0, result.stdout)

    def test_render_handoff_flags_still_legal(self) -> None:
        result = self._run(
            "- `python3 scripts/kos/kos_handoff.py render --status DONE --summary s --next-role r --report-path p`\n"
            "- 无接力。\n"
        )
        self.assertNotIn("E6 ", result.stdout)
        self.assertEqual(result.returncode, 0, result.stdout)


class HandoffStderrNoticeTests(unittest.TestCase):
    """final/relay-exec/relay-quality must print the anti-wrap NOTE to stderr, stdout unchanged."""

    def _run_py(self, args, cwd=None):
        return subprocess.run(
            [sys.executable, "-I", "-B", str(ROOT / "scripts/kos/kos_handoff.py"), *args],
            capture_output=True, text=True, check=False, cwd=cwd)

    def _final_report(self, tmp: Path):
        report = tmp / "report.md"
        report.write_text(
            "DONE\nLucy（Executor（代码））；身份。\n\n"
            "## 下一站接力（O41）\n- next_role：Maya（Quality）\n- next_step：复核\n",
            encoding="utf-8")
        return report

    def test_final_prints_stderr_note_and_keeps_stdout(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            report = self._final_report(Path(tmp))
            result = self._run_py(["final", "--report", str(report), "--skip-lint"])
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertIn("严禁外层再套代码块", result.stderr)
            self.assertIn("# NOTE:", result.stderr)
            self.assertNotIn("# NOTE:", result.stdout)
            self.assertTrue(result.stdout.startswith("结论："))

    def test_failing_final_has_no_note(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            missing = Path(tmp) / "nope.md"
            result = self._run_py(["final", "--report", str(missing)])
            self.assertEqual(result.returncode, 2)
            self.assertNotIn("# NOTE:", result.stderr)


LOOP_BUILT_HANDOFF = '''import argparse

FLAGS = {"final": ["--report"], "render": ["--status"]}

def main(argv=None):
    parser = argparse.ArgumentParser(prog="kos_handoff")
    sub = parser.add_subparsers(dest="cmd", required=True)
    for name, flags in FLAGS.items():
        p = sub.add_parser(name)
        for flag in flags:
            p.add_argument(flag)
    args = parser.parse_args(argv)
    return 0
'''

CRASHING_HANDOFF = 'raise RuntimeError("fixture: kos_handoff import fails")\n'


class HandoffFlagTableTests(unittest.TestCase):
    """_handoff_flag_table must reflect the real argparse parser and fail closed."""

    def _lint_with_sandbox(self, handoff_src: str, packet_text: str) -> subprocess.CompletedProcess[str]:
        with tempfile.TemporaryDirectory() as tmp:
            kos = Path(tmp) / "scripts" / "kos"
            kos.mkdir(parents=True)
            shutil.copy(ROOT / "scripts/kos/kos-pkg-lint.py", kos / "kos-pkg-lint.py")
            (kos / "kos_handoff.py").write_text(handoff_src, encoding="utf-8")
            packet = Path(tmp) / "packet.md"
            packet.write_text(packet_text + "\n", encoding="utf-8")
            return subprocess.run(
                [sys.executable, "-I", str(kos / "kos-pkg-lint.py"), "--start", START, str(packet)],
                text=True, capture_output=True, check=False)

    def test_reflection_catches_loop_built_parser_flag(self) -> None:
        result = self._lint_with_sandbox(
            LOOP_BUILT_HANDOFF,
            "- `python3 scripts/kos/kos_handoff.py final --bogus x.md`\n"
            "- 将 stdout 直接作为 Markdown 原样回复，严禁外层再套代码块。\n",
        )
        self.assertIn("E6 ", result.stdout)
        self.assertIn("--bogus", result.stdout)

    def test_reflection_accepts_legal_loop_built_call(self) -> None:
        result = self._lint_with_sandbox(
            LOOP_BUILT_HANDOFF,
            "- `python3 scripts/kos/kos_handoff.py final --report x.md`\n"
            "- 将 stdout 直接作为 Markdown 原样回复，严禁外层再套代码块。\n",
        )
        self.assertNotIn("E6 ", result.stdout)
        self.assertEqual(result.returncode, 0, result.stdout)

    def test_reflection_failure_fails_closed(self) -> None:
        result = self._lint_with_sandbox(
            CRASHING_HANDOFF,
            "- `python3 scripts/kos/kos_handoff.py final --report x.md`\n"
            "- 将 stdout 直接作为 Markdown 原样回复，严禁外层再套代码块。\n",
        )
        self.assertIn("E6 ", result.stdout)
        self.assertIn("argparse", result.stdout)

    def test_existing_e1_e4_w4_regressions(self) -> None:
        wrong = "c" * 40
        e1 = run(f"起点提交 {wrong}\n")
        self.assertIn("E1 ", e1.stdout)
        e4 = run("/Users/kos-tools-006-definitely-missing/other.txt\n")
        self.assertIn("E4 ", e4.stdout)
        w4 = run("命令 $name中文\n")
        self.assertEqual(w4.returncode, 0, w4.stdout)
        self.assertIn("W4 ", w4.stdout)

if __name__ == "__main__":
    unittest.main()
