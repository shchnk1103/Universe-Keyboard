#!/usr/bin/env python3
"""O207-HANDOFF-UNIFY-DISPATCH-001: kos_handoff.py 派发块角色字段部门池统一。

O207: kos_handoff.py 生成下游接力派发块（标准 5 行）时必须复用外置
kos-pm-next.py 的 6 部门池规范（load_department_pools，ROSTER.md 为唯一
权威）。角色字段只能是标准部门池名（如 `Quality 部门`）；个人名、
`某人（职务）` 组合与旧别名（arch/architect/arch-review/架构/设计/单职务
名）自动映射为标准部门名；无法唯一映射时 fail-closed 拒绝生成派发块。
严禁个人名直通派发块第 2 行。

测试全部通过 KOS_ROSTER 注入 /tmp 夹具花名册，不读写真实
~/.kos-work 台账或真实 ROSTER.md。
"""
import hashlib
import importlib.util
import json
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

KOS_DIR = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(KOS_DIR))

import kos_handoff  # noqa: E402

PM_NEXT_TOOL = Path(os.environ.get(
    "KOS_PM_NEXT_TOOL",
    os.path.expanduser("~/.kos-work/Universe-Keyboard/tools/kos-pm-next.py")))

# 6 部门池夹具（结构与 KOS-ROLES-001/roles/ROSTER.md 部门池表一致，
# 存放在临时目录，不触碰真实台账）。
FIXTURE_ROSTER = """# 名册（O207 测试夹具）
| 名字 | 角色 | 当前担任者 | 角色卡 |
|---|---|---|---|
| Jack | PM | Fixture | Jack.md |
| Pete | Preflight | Fixture | Pete.md |

## 部门池与流转规则（测试夹具）

按部门派发时（除 PM 外共六个部门池），各部门全员名单如下。

| 部门池 | 全员名单 | 对应单卡 |
|---|---|---|
| Preflight 部门 | Pete、Reed | Pete.md、Reed.md |
| Executor（代码）部门 | Cole、Lucy、Ivy | Cole.md、Lucy.md、Ivy.md |
| Executor（文档）部门 | Sam、Wendy | Sam.md、Wendy.md |
| Quality 部门 | Quinn、Maya | Quinn.md、Maya.md |
| Publish 部门 | Wendy、Sam | Wendy.md、Sam.md |
| 架构 / 设计 部门 | Nick、Alex | Nick.md、Alex.md |
"""

SIX_POOLS = (
    "Preflight 部门",
    "Executor（代码）部门",
    "Executor（文档）部门",
    "Quality 部门",
    "Publish 部门",
    "架构 / 设计 部门",
)


def _write(path: Path, text: str) -> Path:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")
    return path


def _expected_block(task_name: str, role: str, packet_path: str, sha256: str) -> str:
    return "\n".join([
        f"任务：{task_name}",
        f"角色：{role}",
        f"包路径：{packet_path}",
        f"SHA-256：{sha256}",
        "授权，直接执行",
    ])


class _RosterFixtureMixin(unittest.TestCase):
    """每个用例注入 /tmp 夹具花名册（KOS_ROSTER），结束后还原环境。"""

    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.roster = _write(self.root / "KOS-ROLES-001" / "roles" / "ROSTER.md",
                             FIXTURE_ROSTER)
        self._old_roster_env = os.environ.get("KOS_ROSTER")
        self._old_tool_env = os.environ.get("KOS_PM_NEXT_TOOL")
        self._old_home_env = os.environ.get("KOS_HOME")
        os.environ["KOS_ROSTER"] = str(self.roster)
        os.environ.pop("KOS_HOME", None)

    def tearDown(self) -> None:
        for key, value in (("KOS_ROSTER", self._old_roster_env),
                           ("KOS_PM_NEXT_TOOL", self._old_tool_env),
                           ("KOS_HOME", self._old_home_env)):
            if value is None:
                os.environ.pop(key, None)
            else:
                os.environ[key] = value
        self.tmp.cleanup()

    def _run_py(self, args: list) -> subprocess.CompletedProcess:
        merged = dict(os.environ)
        merged["PYTHONDONTWRITEBYTECODE"] = "1"
        return subprocess.run(
            [sys.executable, "-I", "-B", str(KOS_DIR / "kos_handoff.py"), *args],
            capture_output=True, text=True, env=merged,
        )


class LoadDepartmentPoolsReuseTests(_RosterFixtureMixin):
    """kos_handoff 复用 kos-pm-next.py 的 load_department_pools 规范。"""

    @unittest.skipUnless(PM_NEXT_TOOL.is_file(), "external kos-pm-next.py not available")
    def test_pools_equal_external_tool_result(self) -> None:
        spec = importlib.util.spec_from_file_location("kos_pm_next_o207", PM_NEXT_TOOL)
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        self.assertEqual(
            kos_handoff.load_department_pools(),
            module.load_department_pools(self.roster),
        )

    def test_six_standard_pools_parsed(self) -> None:
        pools = kos_handoff.load_department_pools()
        self.assertEqual(tuple(pools), SIX_POOLS)

    def test_missing_roster_is_rejected(self) -> None:
        os.environ["KOS_ROSTER"] = str(self.root / "nope" / "ROSTER.md")
        with self.assertRaises(ValueError) as ctx:
            kos_handoff.load_department_pools()
        self.assertIn("STOPPED", str(ctx.exception))


class CanonicalDepartmentRoleTests(_RosterFixtureMixin):
    """角色 → 标准部门池名：精确名 / 职务 / 旧别名 / 个人名 / 拒绝。"""

    def test_exact_pool_name_passthrough(self) -> None:
        for pool in SIX_POOLS:
            self.assertEqual(kos_handoff.canonical_department_role(pool), pool)

    def test_composite_personal_duty_maps_to_department(self) -> None:
        self.assertEqual(kos_handoff.canonical_department_role("Quinn（Quality）"), "Quality 部门")
        self.assertEqual(kos_handoff.canonical_department_role("Maya（Quality Reviewer）"), "Quality 部门")
        self.assertEqual(
            kos_handoff.canonical_department_role("Lucy（Executor（代码））"),
            "Executor（代码）部门",
        )

    def test_bare_personal_name_single_pool_maps(self) -> None:
        self.assertEqual(kos_handoff.canonical_department_role("Maya"), "Quality 部门")
        self.assertEqual(kos_handoff.canonical_department_role("Ivy"), "Executor（代码）部门")

    def test_legacy_aliases_map(self) -> None:
        for alias in ("architect", "arch-review", "arch", "架构", "设计", "Architect"):
            self.assertEqual(
                kos_handoff.canonical_department_role(alias), "架构 / 设计 部门", alias)
        for alias in ("Preflight", "Preflight Reviewer"):
            self.assertEqual(
                kos_handoff.canonical_department_role(alias), "Preflight 部门", alias)
        for alias in ("Quality", "Quality Reviewer"):
            self.assertEqual(
                kos_handoff.canonical_department_role(alias), "Quality 部门", alias)
        for alias in ("code", "Executor（代码）"):
            self.assertEqual(
                kos_handoff.canonical_department_role(alias), "Executor（代码）部门", alias)
        for alias in ("doc", "Executor（文档）", "Executor（记录/文档）"):
            self.assertEqual(
                kos_handoff.canonical_department_role(alias), "Executor（文档）部门", alias)
        self.assertEqual(kos_handoff.canonical_department_role("publish"), "Publish 部门")

    def test_multipool_personal_name_rejected(self) -> None:
        # Wendy / Sam 同属 Executor（文档）与 Publish，无法唯一定位 → 拒绝。
        for name in ("Wendy", "Sam"):
            with self.assertRaises(ValueError) as ctx:
                kos_handoff.canonical_department_role(name)
            self.assertIn("STOPPED", str(ctx.exception))

    def test_unknown_role_rejected(self) -> None:
        for role in ("NoSuchPerson", "Jack（PM）", "PM", ""):
            with self.assertRaises(ValueError) as ctx:
                kos_handoff.canonical_department_role(role)
            self.assertIn("STOPPED", str(ctx.exception))


class FormatDispatchBlockO207Tests(_RosterFixtureMixin):
    """format_dispatch_block 角色字段必须是标准部门名，个人名不得直通。"""

    def test_personal_composite_role_canonicalized(self) -> None:
        block = kos_handoff.format_dispatch_block("T-1", "Quinn（Quality）", "/tmp/pkg.md", "a" * 64)
        self.assertIn("角色：Quality 部门", block)
        self.assertNotIn("Quinn", block)
        self.assertEqual(len(block.splitlines()), 5)

    def test_department_role_unchanged(self) -> None:
        block = kos_handoff.format_dispatch_block("T-1", "Quality 部门", "/tmp/pkg.md", "a" * 64)
        self.assertEqual(block.splitlines()[1], "角色：Quality 部门")

    def test_unmappable_role_rejected(self) -> None:
        with self.assertRaises(ValueError) as ctx:
            kos_handoff.format_dispatch_block("T-1", "NoSuchPerson", "/tmp/pkg.md", "a" * 64)
        self.assertIn("STOPPED", str(ctx.exception))

    def test_department_members_hint_keeps_department_anchor(self) -> None:
        block = kos_handoff.format_dispatch_block(
            "T-1", "Preflight", "/tmp/pkg.md", "a" * 64,
            members="Pete / Reed", department="Preflight")
        self.assertEqual(block.splitlines()[1], "角色：Preflight 部门（Pete / Reed）")


class DispatchSubcommandO207Tests(_RosterFixtureMixin):
    """dispatch 子命令：个人名/旧别名输入映射或拒绝。"""

    def setUp(self) -> None:
        super().setUp()
        self.packet = _write(self.root / "pkg.md", "# 任务包：O207\n内容\n")
        self.sha = hashlib.sha256(self.packet.read_bytes()).hexdigest()

    def test_personal_role_maps_to_department(self) -> None:
        result = self._run_py([
            "dispatch", "--packet", str(self.packet), "--role", "Quinn（Quality）",
        ])
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertNotIn("Quinn", result.stdout)
        self.assertEqual(
            result.stdout,
            _expected_block(self.packet.stem, "Quality 部门",
                            str(self.packet.resolve()), self.sha) + "\n",
        )

    def test_legacy_alias_maps_to_department(self) -> None:
        result = self._run_py([
            "dispatch", "--packet", str(self.packet), "--role", "architect",
        ])
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("角色：架构 / 设计 部门", result.stdout)

    def test_multipool_personal_name_stops(self) -> None:
        result = self._run_py([
            "dispatch", "--packet", str(self.packet), "--role", "Wendy",
        ])
        self.assertEqual(result.returncode, 2)
        self.assertIn("STOPPED", result.stderr)
        self.assertEqual(result.stdout, "")

    def test_missing_roster_stops(self) -> None:
        os.environ["KOS_ROSTER"] = str(self.root / "nope" / "ROSTER.md")
        result = self._run_py([
            "dispatch", "--packet", str(self.packet), "--role", "Quality 部门",
        ])
        self.assertEqual(result.returncode, 2)
        self.assertIn("STOPPED", result.stderr)


class FinalSuggestionDeptTests(_RosterFixtureMixin):
    """cmd_final 建议派发块：角色字段为标准部门名，不含个人姓名。"""

    def _report(self, next_role: str = "Quality Reviewer") -> Path:
        report = self.root / "KOS-O207-001" / "reports" / "report.md"
        report.parent.mkdir(parents=True, exist_ok=True)
        report.write_text(
            f"DONE\nLucy（Executor（代码））；运行时身份 Fixture。\n\n"
            "## 下一站接力（O41）\n"
            f"- next_role：{next_role}\n- next_step：复核\n\n"
            "```text\n"
            f"交回：{next_role}\n事项：复核\n报告：{report}\nSHA-256：{'0' * 64}\n"
            "```\n",
            encoding="utf-8")
        return report

    def _final(self, report: Path, stub_line: str):
        stub = self.root / "pick.py"
        stub.write_text(f"print({stub_line!r})\n", encoding="utf-8")
        return self._run_py([
            "final", "--report", str(report), "--skip-lint",
            "--board", sys.executable, "--board-args", json.dumps([str(stub)]),
        ])

    def test_suggestion_block_uses_department_role(self) -> None:
        report = self._report()
        result = self._final(report, "PICK [Quality]: Quinn（Quality | -）")
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("## 建议派发（PM 复核后使用）", result.stdout)
        self.assertIn("角色：Quality 部门", result.stdout)
        suggestion = result.stdout.split("## 建议派发（PM 复核后使用）", 1)[1]
        self.assertNotIn("Quinn", suggestion)
        # 3 行交回主块仍按 O92 指名给 PM 路由
        self.assertIn("下一位交付：Quinn（Quality Reviewer）", result.stdout)

    def test_unmappable_duty_refuses_block_keeps_pm_handback(self) -> None:
        # `某人（职务）` 组合中职务无法映射 → 拒绝生成建议派发块（stderr 注记），
        # 但 3 行交回主块仍正常交回 PM，不因辅助派发面阻塞收尾。
        report = self._report(next_role="Quinn（NoSuchDuty）")
        result = self._final(report, "PICK [x]: none")
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertNotIn("## 建议派发", result.stdout)
        self.assertIn("建议派发块已跳过", result.stderr)
        self.assertIn("交回：Jack（PM）", result.stdout)


class RelayDeptBlockO207Tests(_RosterFixtureMixin):
    """relay-exec / relay-quality 的派发块角色字段保持标准部门名。"""

    def test_relay_exec_block_role_is_department(self) -> None:
        packet = _write(self.root / "packet.md",
                        "Executor（代码）；你不是 PM\n\n# 任务包：示例\n\n"
                        "- **包头档位**：`code-fix`\n- **复核重点**：\n  1. 检查。\n")
        report = _write(self.root / "precheck.md",
                        "PASS\nPete（Preflight）；运行时身份 Fixture。"
                        "跨会话独立性声明：本审查与前序参与者跨会话独立。\n")
        verify_ok = _write(self.root / "verify_ok.py", "import sys\nsys.exit(0)\n")
        lint_ok = _write(self.root / "lint_ok.py", "import sys\nsys.exit(0)\n")
        out = self.root / "exec-relay-block.txt"
        result = self._run_py([
            "relay-exec",
            "--report", str(report),
            "--packet", str(packet),
            "--base", "0" * 40,
            "--repo", str(self.root),
            "--verify-tool", str(verify_ok),
            "--pkg-lint-tool", str(lint_ok),
            "--board", sys.executable,
            "--board-args", json.dumps([str(self.root / "none.py")]),
            "--out", str(out),
        ])
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        content = out.read_text(encoding="utf-8")
        self.assertIn("角色：Executor（代码）部门", content)
        self.assertIn("授权，直接执行", content)

    def test_relay_quality_block_role_is_department(self) -> None:
        repo = self.root / "repo"
        repo.mkdir()
        env = dict(os.environ)
        env.update({"GIT_AUTHOR_NAME": "Cowork 3P", "GIT_AUTHOR_EMAIL": "cowork-3p@localhost",
                    "GIT_COMMITTER_NAME": "Cowork 3P", "GIT_COMMITTER_EMAIL": "cowork-3p@localhost",
                    "GIT_CONFIG_GLOBAL": "/dev/null", "GIT_CONFIG_SYSTEM": "/dev/null"})

        def git(*a):
            r = subprocess.run(["git", "-C", str(repo), *a],
                               capture_output=True, text=True, env=env)
            self.assertEqual(r.returncode, 0, r.stderr)
            return r.stdout.strip()

        git("init", "-b", "main")
        (repo / ".kos").mkdir()
        (repo / ".kos" / "project.json").write_text("{}\n", encoding="utf-8")
        (repo / "base.txt").write_text("base\n", encoding="utf-8")
        git("add", ".")
        git("commit", "-m", "base")
        base = git("rev-parse", "HEAD")
        (repo / "tool.py").write_text("x = 1\n", encoding="utf-8")
        git("add", ".")
        git("commit", "-m", "work")
        packet = _write(self.root / "packet.md",
                        "Executor（代码）；你不是 PM\n\n# 任务包：示例\n\n"
                        "- **包头档位**：`code-fix`\n- **复核重点**：\n  1. 检查一切。\n")
        report = _write(self.root / "exec.md",
                        "DONE\nNick（Executor（代码））；运行时身份 Fixture。\n")
        result = self._run_py([
            "relay-quality", "--report", str(report), "--packet", str(packet),
            "--base", base, "--repo", str(repo),
            "--board", sys.executable,
            "--board-args", json.dumps([str(self.root / "none.py")]),
        ])
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        out = packet.parent / "quality-relay-block.md"
        self.assertTrue(out.is_file(), result.stdout)
        out_sha = hashlib.sha256(out.read_bytes()).hexdigest()
        self.assertIn("```text\n" + _expected_block(
            packet.stem, "Quality 部门", str(out.resolve()), out_sha) + "\n```",
            result.stdout)


if __name__ == "__main__":
    unittest.main()
