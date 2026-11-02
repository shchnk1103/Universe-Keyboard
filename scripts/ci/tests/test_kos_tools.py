from __future__ import annotations

import hashlib
import importlib.util
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


KOS = Path(__file__).parents[2] / "kos"
SPEC = importlib.util.spec_from_file_location("kos_freeze", KOS / "freeze.py")
assert SPEC is not None and SPEC.loader is not None
FREEZE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(FREEZE)

HASH = "a" * 64


def run(args: list[str], env: dict[str, str] | None = None) -> subprocess.CompletedProcess[str]:
    full_env = dict(os.environ)
    full_env["PYTHONDONTWRITEBYTECODE"] = "1"
    if env:
        full_env.update(env)
    return subprocess.run(args, capture_output=True, text=True, env=full_env)


class ConsistencyTests(unittest.TestCase):
    def assert_flags(self, text: str, fragment: str) -> None:
        errors = FREEZE.consistency(text)
        self.assertTrue(any(fragment in e for e in errors), errors)

    def assert_clean(self, text: str) -> None:
        self.assertEqual(FREEZE.consistency(text), [])

    def test_clean_text_returns_empty_list(self) -> None:
        self.assert_clean("普通说明文字。\n没有任何冲突。")

    def test_frozen_input_without_absolute_path(self) -> None:
        self.assert_flags(f"- `input.md` `{HASH}`", "frozen input without absolute path")
        self.assert_clean(f"均位于 `/srv/task/`\n- `input.md` `{HASH}`")

    def test_test_ban_vs_lightweight_checks(self) -> None:
        self.assert_flags("不运行测试\n执行 run_lightweight_checks", "bans tests/builds")
        self.assert_clean("不运行测试\n执行 run_lightweight_checks\n允许运行轻量检查")

    def test_stop_vs_partial_in_one_sentence(self) -> None:
        self.assert_flags("不符就停止并记 PARTIAL", "stop vs PARTIAL")
        self.assert_clean("不符就停止并记 STOPPED")

    def test_exact_file_count_without_subset_rule(self) -> None:
        text = "DONE = 全部完成\n恰为 8 个文件\nPARTIAL = 部分完成"
        self.assert_flags(text, "no subset rule")
        self.assert_clean(text + "\n提交后文件集合必须是白名单的子集")

    def test_network_contradictions(self) -> None:
        self.assert_flags("不联网\n允许只读联网", "both '不联网'")
        self.assert_flags("用 HEAD 查 HTTP 状态码，再 GET 正文", "mixes HEAD and GET")
        self.assert_clean("不联网")
        self.assert_clean("用 HEAD 查 HTTP 状态码，仅 GET 正文")

    def test_build_without_output_location(self) -> None:
        self.assert_flags("运行 xcodebuild\n只写 scratch", "no build output location")
        self.assert_clean("运行 xcodebuild -derivedDataPath scratch/dd\n只写 scratch")

    def test_referenced_report_without_hash(self) -> None:
        self.assert_flags("采纳报告 `/srv/task/reports/r.md`", "referenced report without hash")
        self.assert_flags("采纳报告 `/Users/x/reports/r.md`", "referenced report without hash")
        self.assert_clean(f"采纳报告 `/srv/task/reports/r.md` `{HASH}`")


class NewTaskDirTests(unittest.TestCase):
    def test_creates_refuses_existing_and_rejects_invalid_id(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            env = {"KOS_HOME": directory, "KOS_PROJECT": "Demo"}
            script = str(KOS / "new_task_dir.sh")
            created = run(["bash", script, "TASK-001"], env)
            self.assertEqual(created.returncode, 0, created.stderr)
            task = Path(directory) / "Demo" / "TASK-001"
            self.assertEqual(created.stdout.strip(), str(task))
            for name in ("instructions", "reports", "scratch", "packets"):
                self.assertTrue((task / name).is_dir(), name)
            marker = task / "reports" / "keep.md"
            marker.write_text("keep", encoding="utf-8")
            again = run(["bash", script, "TASK-001"], env)
            self.assertEqual(again.returncode, 1)
            self.assertEqual(marker.read_text(encoding="utf-8"), "keep")
            invalid = run(["bash", script, "bad id"], env)
            self.assertEqual(invalid.returncode, 2)
            self.assertFalse((Path(directory) / "Demo" / "bad id").exists())


class FreezeOverwriteTests(unittest.TestCase):
    def test_existing_output_is_not_overwritten(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            draft = Path(directory) / "draft.md"
            draft.write_text("draft", encoding="utf-8")
            out = Path(directory) / "package.md"
            out.write_text("original", encoding="utf-8")
            result = run([sys.executable, "-B", str(KOS / "freeze.py"), str(draft), str(out), "--title", "T", "--role", "R"])
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("EXISTS", result.stderr)
            self.assertEqual(out.read_text(encoding="utf-8"), "original")


class VerifyTreeTests(unittest.TestCase):
    def test_matching_and_mismatching_inventory(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory) / "tree"
            root.mkdir()
            (root / "a.txt").write_bytes(b"alpha\n")
            digest = hashlib.sha256(b"alpha\n").hexdigest()
            good = Path(directory) / "good.txt"
            good.write_text(f"{digest}  a.txt\n", encoding="utf-8")
            bad = Path(directory) / "bad.txt"
            bad.write_text(f"{'0' * 64}  a.txt\n", encoding="utf-8")
            script = str(KOS / "verify-tree.py")
            self.assertEqual(run([sys.executable, "-B", script, str(root), "--inventory", str(good)]).returncode, 0)
            self.assertNotEqual(run([sys.executable, "-B", script, str(root), "--inventory", str(bad)]).returncode, 0)


if __name__ == "__main__":
    unittest.main()
