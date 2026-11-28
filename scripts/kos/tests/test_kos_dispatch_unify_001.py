#!/usr/bin/env python3
"""KOS-DISPATCH-UNIFY-001: single dispatch-block renderer in kos_handoff.py.

O95: PM 与员工交接共用唯一派发块渲染源。format_dispatch_block() 固定输出
洁净 5 行（任务名/角色/包路径/SHA-256/授权，直接执行），不套外层围栏；
relay-exec、relay-quality 与新增 dispatch 子命令都必须经由它渲染。

O207: 派发块角色字段经部门池规范（kos-pm-next.py load_department_pools，
ROSTER.md 6 部门池）归一，个人名/旧别名自动映射为标准部门名，无法映射即
拒绝；测试经 KOS_ROSTER 注入 /tmp 夹具花名册，不读写真实台账。
"""
from __future__ import annotations

FIXTURE_ROSTER = """# 名册（O95/O207 测试夹具）
| 名字 | 角色 | 当前担任者 | 角色卡 |
|---|---|---|---|
| Jack | PM | Fixture | Jack.md |
| Pete | Preflight | Fixture | Pete.md |

## 部门池与流转规则（测试夹具）

| 部门池 | 全员名单 | 对应单卡 |
|---|---|---|
| Preflight 部门 | Pete、Reed | Pete.md、Reed.md |
| Executor（代码）部门 | Cole、Lucy、Ivy | Cole.md、Lucy.md、Ivy.md |
| Executor（文档）部门 | Sam、Wendy | Sam.md、Wendy.md |
| Quality 部门 | Quinn、Maya | Quinn.md、Maya.md |
| Publish 部门 | Wendy、Sam | Wendy.md、Sam.md |
| 架构 / 设计 部门 | Nick、Alex | Nick.md、Alex.md |
"""
import hashlib
import json
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

KOS_DIR = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(KOS_DIR))
sys.path.insert(0, str(Path(__file__).resolve().parent))

import _kos_pm_next_fixture  # noqa: E402
import kos_handoff  # noqa: E402


def _write(path: Path, text: str) -> Path:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")
    return path


def _run_py(script: str, args: list, env: dict | None = None):
    merged = dict(os.environ)
    merged["PYTHONDONTWRITEBYTECODE"] = "1"
    if env:
        merged.update(env)
    return subprocess.run(
        [sys.executable, "-I", "-B", str(KOS_DIR / script), *args],
        capture_output=True, text=True, env=merged,
    )


def _expected_block(task_name: str, role: str, packet_path: str, sha256: str) -> str:
    return "\n".join([
        f"任务：{task_name}",
        f"角色：{role}",
        f"包路径：{packet_path}",
        f"SHA-256：{sha256}",
        "授权，直接执行",
    ])


class _RosterEnvMixin(unittest.TestCase):
    """O207: inject a /tmp 6-pool roster fixture via KOS_ROSTER and a /tmp
    kos-pm-next.py fixture tool via KOS_PM_NEXT_TOOL (never the real external
    KOS ledger), for both in-process and subprocess calls. The kos_handoff
    external-module cache is cleared per case so no cached tool module leaks."""

    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        roster = Path(self.tmp.name) / "ROSTER.md"
        roster.write_text(FIXTURE_ROSTER, encoding="utf-8")
        self.roster_env = {"KOS_ROSTER": str(roster)}
        self._old = os.environ.get("KOS_ROSTER")
        os.environ["KOS_ROSTER"] = str(roster)
        self._pm_next_saved = _kos_pm_next_fixture.install(set_roster=True)

    def tearDown(self) -> None:
        _kos_pm_next_fixture.uninstall(self._pm_next_saved)
        if self._old is None:
            os.environ.pop("KOS_ROSTER", None)
        else:
            os.environ["KOS_ROSTER"] = self._old
        self.tmp.cleanup()


class FormatDispatchBlockTests(_RosterEnvMixin):
    """format_dispatch_block 固定 5 行洁净输出，无围栏；O207 起角色字段
    经部门池规范归一，个人名组合自动映射为标准部门名。"""

    def test_five_clean_lines_without_fence(self) -> None:
        sha = "a" * 64
        block = kos_handoff.format_dispatch_block("T-1", "Quinn（Quality）", "/tmp/pkg.md", sha)
        self.assertEqual(block, _expected_block("T-1", "Quality 部门", "/tmp/pkg.md", sha))
        self.assertNotIn("Quinn", block)
        self.assertNotIn("```", block)
        self.assertEqual(len(block.splitlines()), 5)

    def test_matches_legacy_kos_render_content(self) -> None:
        """O207: 角色字段只接受标准部门名；与 O95 旧 5 行格式逐字节一致，
        但不再复刻 kos_render 的 个人名（职务） 组合（该形态已被部门池归一取代）。"""
        sha = "b" * 64
        self.assertEqual(
            kos_handoff.format_dispatch_block("T-2", "Quality 部门", "/tmp/pkg.md", sha),
            _expected_block("T-2", "Quality 部门", "/tmp/pkg.md", sha),
        )
        # 旧个人名组合入口仍可用，但产出被归一为标准部门名。
        self.assertEqual(
            kos_handoff.format_dispatch_block("T-2", "Quinn（Quality）", "/tmp/pkg.md", sha),
            _expected_block("T-2", "Quality 部门", "/tmp/pkg.md", sha),
        )


class DispatchSubcommandTests(_RosterEnvMixin):
    """kos_handoff.py dispatch 子命令。"""

    def setUp(self) -> None:
        super().setUp()
        self.root = Path(self.tmp.name)
        self.packet = _write(self.root / "pkg.md", "# 任务包\n内容\n")
        self.sha = hashlib.sha256(self.packet.read_bytes()).hexdigest()

    def test_dispatch_prints_clean_block(self) -> None:
        result = _run_py("kos_handoff.py", [
            "dispatch", "--packet", str(self.packet), "--role", "Quinn（Quality）",
        ], env=self.roster_env)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(
            result.stdout,
            _expected_block(self.packet.stem, "Quality 部门",
                            str(self.packet.resolve()), self.sha) + "\n",
        )
        self.assertNotIn("```", result.stdout)

    def test_dispatch_task_name_override(self) -> None:
        result = _run_py("kos_handoff.py", [
            "dispatch", "--packet", str(self.packet), "--role", "Lucy（Executor（代码））",
            "--task-name", "KOS-DISPATCH-UNIFY-001",
        ], env=self.roster_env)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("任务：KOS-DISPATCH-UNIFY-001", result.stdout)
        self.assertIn("角色：Executor（代码）部门", result.stdout)
        self.assertIn(f"SHA-256：{self.sha}", result.stdout)

    def test_dispatch_missing_packet_fails(self) -> None:
        result = _run_py("kos_handoff.py", [
            "dispatch", "--packet", str(self.root / "nope.md"), "--role", "Quinn（Quality）",
        ])
        self.assertEqual(result.returncode, 2)
        self.assertIn("STOPPED", result.stderr)


class RelayExecUnifiedBlockTests(_RosterEnvMixin):
    """relay-exec 落盘与打印的派发块必须来自 format_dispatch_block。"""

    def setUp(self) -> None:
        super().setUp()
        self.root = Path(self.tmp.name)
        self.packet = _write(self.root / "packet.md",
                             "Executor（代码）；你不是 PM\n\n"
                             "# 任务包：示例\n\n"
                             "- **包头档位**：`code-fix`\n"
                             "- **复核重点**：\n  1. 检查。\n")
        self.report = _write(self.root / "precheck.md",
                             "PASS\nPete（Preflight）；运行时身份 Codex。跨会话独立性声明：本审查与前序参与者跨会话独立。\n")
        self.verify_ok = _write(self.root / "verify_ok.py", "import sys\nsys.exit(0)\n")
        self.lint_ok = _write(self.root / "lint_ok.py", "import sys\nsys.exit(0)\n")
        self.pick = _write(self.root / "pick_stub.py",
                           "print('PICK [Executor（代码）]: Nick（Executor（代码） | -）')\n")

    def test_relay_exec_block_is_unified(self) -> None:
        out = self.root / "exec-relay-block.txt"
        result = _run_py("kos_handoff.py", [
            "relay-exec",
            "--report", str(self.report),
            "--packet", str(self.packet),
            "--base", "0" * 40,
            "--repo", str(self.root),
            "--verify-tool", str(self.verify_ok),
            "--pkg-lint-tool", str(self.lint_ok),
            "--board", sys.executable,
            "--board-args", json.dumps([str(self.pick)]),
            "--out", str(out),
        ], env=self.roster_env)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        sha = hashlib.sha256(self.packet.read_bytes()).hexdigest()
        expected = _expected_block(self.packet.stem, "Executor（代码）部门",
                                   str(self.packet.resolve()), sha)
        content = out.read_text(encoding="utf-8")
        # O129: the relay packet starts with the department-pool claim hint,
        # then the unified 5-line block stays intact below it.
        self.assertTrue(content.startswith("开工领牌"), content)
        self.assertIn(expected + "\n", content)
        self.assertIn(" claim ", content)
        self.assertNotIn(" busy ", content)
        self.assertIn(f"```text\n{expected}\n```", result.stdout)


class RelayQualityUnifiedBlockTests(_RosterEnvMixin):
    """relay-quality 打印的派发块来自 format_dispatch_block，且无双层围栏。"""

    def setUp(self) -> None:
        super().setUp()
        self.root = Path(self.tmp.name)
        self.repo = self.root / "repo"
        self.repo.mkdir()
        env = dict(os.environ)
        env.update({"GIT_AUTHOR_NAME": "Cowork 3P", "GIT_AUTHOR_EMAIL": "cowork-3p@localhost",
                    "GIT_COMMITTER_NAME": "Cowork 3P", "GIT_COMMITTER_EMAIL": "cowork-3p@localhost",
                    "GIT_CONFIG_GLOBAL": "/dev/null", "GIT_CONFIG_SYSTEM": "/dev/null"})

        def git(*a):
            r = subprocess.run(["git", "-C", str(self.repo), *a],
                               capture_output=True, text=True, env=env)
            self.assertEqual(r.returncode, 0, r.stderr)
            return r.stdout.strip()

        git("init", "-b", "main")
        (self.repo / ".kos").mkdir()
        (self.repo / ".kos" / "project.json").write_text("{}\n", encoding="utf-8")
        (self.repo / "base.txt").write_text("base\n", encoding="utf-8")
        git("add", ".")
        git("commit", "-m", "base")
        self.base = git("rev-parse", "HEAD")
        (self.repo / "tool.py").write_text("x = 1\n", encoding="utf-8")
        git("add", ".")
        git("commit", "-m", "work")
        self.packet = _write(self.root / "packet.md",
                             "Executor（代码）；你不是 PM\n\n# 任务包：示例\n\n"
                             "- **包头档位**：`code-fix`\n- **复核重点**：\n  1. 检查一切。\n")
        self.report = _write(self.root / "exec.md",
                             "DONE\nNick（Executor（代码））；运行时身份 Codex。\n")
        self.pick = _write(self.root / "pick_stub.py",
                           "print('PICK [Quality]: Quinn（Quality | 上次：-）')\n")

    def test_relay_quality_block_is_unified_and_single_fenced(self) -> None:
        result = _run_py("kos_handoff.py", [
            "relay-quality", "--report", str(self.report), "--packet", str(self.packet),
            "--base", self.base, "--repo", str(self.repo),
            "--board", sys.executable, "--board-args", json.dumps([str(self.pick)]),
        ], env=self.roster_env)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        out = self.packet.parent / "quality-relay-block.md"
        self.assertTrue(out.is_file(), result.stdout)
        out_sha = hashlib.sha256(out.read_bytes()).hexdigest()
        expected = _expected_block(self.packet.stem, "Quality 部门",
                                   str(out.resolve()), out_sha)
        self.assertIn(f"```text\n{expected}\n```", result.stdout)
        self.assertNotIn("Quinn（Quality）", result.stdout)
        # 不套外层双层围栏
        self.assertNotIn("```text\n```text", result.stdout)


if __name__ == "__main__":
    unittest.main()
