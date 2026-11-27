#!/usr/bin/env python3
"""KOS-DISPATCH-LINT-HARDEN-002 regression tests (O108 / O109 / O105).

Five failure scenarios from the frozen packet:

1. relay-quality / relay-exec target relay-block file already exists -> bump a
   numbered suffix (quality-relay-block-2.md) instead of dying with STOPPED;
2. relay-exec / relay-quality generated direct-relay packets carry a
   `kos-board.py set ... busy` start-of-work command;
3. pick failure or rejected fallback never leaves a dirty 已预占 reserve row
   on the board (reserve is written only after the pick validates);
4. `kos_handoff.py dispatch` keeps the standard 5-line block and supports
   `--department` / `--members` role-line department member hints (O105);
5. kos-pkg-lint merges `\\` continuations before parsing multi-line
   kos_handoff.py calls and hard-checks illegal flags (--grade, --target) and
   missing required flags (--packet, --report, --base, --repo) (O109).

Stdlib only; style mirrors test_o41_relay.py / test_board_reserve.py.
"""
from __future__ import annotations

import importlib.util
import json
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

KOS_DIR = Path(__file__).resolve().parent.parent
REPO_ROOT = KOS_DIR.parent.parent
PY = sys.executable

# KOS-BOARD-RESERVE-001 convention: real-board cases are gated on the
# machine-local external kos-board.py so hosted CI (without it) runs green.
EXTERNAL_BOARD_TOOL = Path(os.environ.get(
    "KOS_TEST_EXTERNAL_BOARD_TOOL",
    "/Users/doubleshy0n/.kos-work/Universe-Keyboard/tools/kos-board.py"))

ROSTER = """# 名册（试行）
| 名字 | 角色 | 当前担任者 | 角色卡 |
|---|---|---|---|
| Quinn | Quality | Claude | Quinn.md |
| Reed | Preflight | Codex | Reed.md |
"""


def _write(path: Path, text: str) -> Path:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")
    return path


def _run_py(script: str, args: list[str], env: dict[str, str] | None = None):
    merged_env = dict(os.environ)
    merged_env["PYTHONDONTWRITEBYTECODE"] = "1"
    if env:
        merged_env.update(env)
    return subprocess.run(
        [sys.executable, "-I", "-B", str(KOS_DIR / script), *args],
        capture_output=True, text=True, env=merged_env)


def _load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(module)
    return module


def board_rows(home: Path) -> dict:
    out = {}
    p = home / "KOS-ROLES-001" / "BOARD.md"
    if not p.exists():
        return out
    for line in p.read_text(encoding="utf-8").splitlines():
        cols = [x.strip() for x in line.strip().strip("|").split("|")]
        if len(cols) >= 5 and cols[0] not in ("名字", "---", "") and not cols[0].startswith("-"):
            out[cols[0]] = cols
    return out


# Pick stub that records every invocation in a JSON state file so tests can
# verify whether a reserve was written.  It deliberately ignores --exclude
# (loose-board simulation) so the caller-side rejection path is exercised.
STATEFUL_BOARD_STUB = r'''
import json, os, sys
state_path = os.environ["STUB_BOARD_STATE"]
state = json.load(open(state_path, encoding="utf-8")) if os.path.exists(state_path) else {"picks": [], "reserves": []}
args = sys.argv[1:]
if args and args[0] == "pick":
    role = args[args.index("--role") + 1]
    reserve = args[args.index("--reserve") + 1] if "--reserve" in args else ""
    name = os.environ.get("STUB_PICK_NAME", "Quinn")
    mode = os.environ.get("STUB_PICK_MODE", "match")
    if mode == "fallback":
        print("PICK(兜底，无空闲专职 '%s'): %s（X | -）" % (role, name))
    else:
        print("PICK [%s]: %s（X | -）" % (role, name))
    state["picks"].append({"argv": args, "reserve": reserve})
    if reserve:
        state["reserves"].append({"name": name, "task": reserve})
        print("RESERVE: %s -> 已预占（任务 %s，TTL 600s）" % (name, reserve))
    json.dump(state, open(state_path, "w", encoding="utf-8"))
    sys.exit(0)
sys.exit(2)
'''


class _GitRepoMixin:
    """Minimal throwaway repo committed as Cowork 3P, like RelayQualityTests."""

    def _init_repo(self, root: Path):
        repo = root / "repo"
        repo.mkdir()
        env = dict(os.environ)
        env.update({
            "GIT_AUTHOR_NAME": "Cowork 3P", "GIT_AUTHOR_EMAIL": "cowork-3p@localhost",
            "GIT_COMMITTER_NAME": "Cowork 3P", "GIT_COMMITTER_EMAIL": "cowork-3p@localhost",
            "GIT_CONFIG_GLOBAL": "/dev/null", "GIT_CONFIG_SYSTEM": "/dev/null",
        })

        def git(*a):
            r = subprocess.run(["git", "-C", str(repo), *a], capture_output=True, text=True, env=env)
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
        return repo, base


class RelayBlockCollisionTests(_GitRepoMixin, unittest.TestCase):
    """Scenario 1 (O108): existing relay-block file -> numbered bump, no STOP."""

    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.task = self.root / "KOS-SELFTEST-001"
        self.task.mkdir()
        self.repo, self.base = self._init_repo(self.root)
        self.ok_stub = _write(self.root / "ok.py", "import sys\nsys.exit(0)\n")
        self.packet = _write(self.task / "instructions" / "pkg.md",
                             "Executor（代码）；你不是 PM\n\n# 任务包：示例\n\n"
                             "- **包头档位**：`code-fix`\n- **复核重点**：\n  1. 检查一切。\n")
        self.done_report = _write(self.task / "reports" / "exec.md",
                                  "DONE\nNick（Executor（代码））；运行时身份 Codex。\n")
        self.precheck_report = _write(self.task / "reports" / "precheck.md",
                                      "PASS\nPete（Preflight）；运行时身份 Codex。跨会话独立性声明：本审查与前序参与者跨会话独立。\n")
        self.pick_stub_path = _write(self.root / "tools" / "kos-board.py",
                                     "print('PICK [Quality]: Quinn（Quality | -）')\n")

    def tearDown(self):
        self.tmp.cleanup()

    def _board_args(self):
        return ["--board", sys.executable, "--board-args", json.dumps([str(self.pick_stub_path)])]

    def test_relay_quality_bumps_existing_block(self) -> None:
        existing = self.task / "instructions" / "quality-relay-block.md"
        existing.write_text("previous relay block\n", encoding="utf-8")
        result = _run_py("kos_handoff.py", [
            "relay-quality", "--report", str(self.done_report), "--packet", str(self.packet),
            "--base", self.base, "--repo", str(self.repo), *self._board_args(),
        ])
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        bumped = self.task / "instructions" / "quality-relay-block-2.md"
        self.assertTrue(bumped.is_file(), result.stdout + result.stderr)
        self.assertEqual(existing.read_text(encoding="utf-8"), "previous relay block\n")
        self.assertIn(str(bumped.resolve()), result.stdout)

    def test_relay_exec_bumps_existing_block(self) -> None:
        existing = self.task / "instructions" / "exec-relay-block.txt"
        existing.write_text("previous exec block\n", encoding="utf-8")
        result = _run_py("kos_handoff.py", [
            "relay-exec", "--report", str(self.precheck_report), "--packet", str(self.packet),
            "--base", self.base, "--repo", str(self.repo),
            "--verify-tool", str(self.ok_stub), "--pkg-lint-tool", str(self.ok_stub),
            *self._board_args(),
        ])
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        bumped = self.task / "instructions" / "exec-relay-block-2.txt"
        self.assertTrue(bumped.is_file(), result.stdout + result.stderr)
        self.assertEqual(existing.read_text(encoding="utf-8"), "previous exec block\n")


class RelayBusyStartCommandTests(_GitRepoMixin, unittest.TestCase):
    """Scenario 2 (O108): direct-relay packets carry a kos-board.py set busy command."""

    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.task = self.root / "KOS-SELFTEST-001"
        self.task.mkdir()
        self.repo, self.base = self._init_repo(self.root)
        self.ok_stub = _write(self.root / "ok.py", "import sys\nsys.exit(0)\n")
        self.packet = _write(self.task / "instructions" / "pkg.md",
                             "Executor（代码）；你不是 PM\n\n# 任务包：示例\n\n"
                             "- **包头档位**：`code-fix`\n- **复核重点**：\n  1. 检查一切。\n")
        self.done_report = _write(self.task / "reports" / "exec.md",
                                  "DONE\nNick（Executor（代码））；运行时身份 Codex。\n")
        self.precheck_report = _write(self.task / "reports" / "precheck.md",
                                      "PASS\nPete（Preflight）；运行时身份 Codex。跨会话独立性声明：本审查与前序参与者跨会话独立。\n")
        self.pick_stub_path = _write(self.root / "tools" / "kos-board.py",
                                     "print('PICK [Quality]: Quinn（Quality | -）')\n"
                                     "print('PICK2 stub does not handle exec')\n")
        # relay-exec 的选人桩需要 code 职责的 PICK 行；独立目录下仍命名
        # kos-board.py，以便断言开工指令含 "kos-board.py set"。
        self.exec_pick_stub = _write(self.root / "tools-exec" / "kos-board.py",
                                     "print('PICK [Executor（代码）]: Nick（Executor（代码） | -）')\n")

    def tearDown(self):
        self.tmp.cleanup()

    def test_relay_quality_block_starts_with_claim_hint(self) -> None:
        result = _run_py("kos_handoff.py", [
            "relay-quality", "--report", str(self.done_report), "--packet", str(self.packet),
            "--base", self.base, "--repo", str(self.repo),
            "--board", sys.executable, "--board-args", json.dumps([str(self.pick_stub_path)]),
        ])
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        out = self.task / "instructions" / "quality-relay-block.md"
        text = out.read_text(encoding="utf-8")
        # O129: department-pool claim hint replaces the named busy attachment.
        self.assertIn("kos-board.py claim", text)
        self.assertIn("--role quality", text)
        self.assertIn("KOS-SELFTEST-001", text)
        claim_lines = [l for l in text.splitlines() if "kos-board.py claim" in l]
        self.assertTrue(claim_lines, text)
        self.assertLess(text.splitlines().index(claim_lines[0]), 10,
                        "开工领牌指令必须写在直通包开头附近")
        self.assertNotIn(" busy ", text)
        self.assertNotIn("PICK", text)
        self.assertIn("Quality 部门", text)

    def test_relay_exec_block_carries_claim_hint(self) -> None:
        result = _run_py("kos_handoff.py", [
            "relay-exec", "--report", str(self.precheck_report), "--packet", str(self.packet),
            "--base", self.base, "--repo", str(self.repo),
            "--verify-tool", str(self.ok_stub), "--pkg-lint-tool", str(self.ok_stub),
            "--board", sys.executable, "--board-args", json.dumps([str(self.exec_pick_stub)]),
        ])
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        out = self.task / "instructions" / "exec-relay-block.txt"
        text = out.read_text(encoding="utf-8")
        self.assertIn("kos-board.py claim", text)
        self.assertIn("--role code", text)
        self.assertIn("KOS-SELFTEST-001", text)
        self.assertIn("授权，直接执行", text)
        self.assertNotIn(" busy ", text)
        self.assertNotIn("kos-board.py set", text)
        self.assertIn("kos-board.py claim", result.stdout)
        self.assertIn("Executor（代码）部门", result.stdout)


class PickReserveAtomicityTests(unittest.TestCase):
    """Scenario 3 (O108): reserve is written only after the pick validates."""

    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.state = self.root / "board-state.json"
        self.stub = _write(self.root / "tools" / "kos-board.py", STATEFUL_BOARD_STUB)
        self.kos_handoff = _load("_kos_handoff_harden", KOS_DIR / "kos_handoff.py")

    def tearDown(self):
        self.tmp.cleanup()

    def _env(self, **overrides) -> dict:
        env = {
            "STUB_BOARD_STATE": str(self.state),
            "STUB_PICK_NAME": "Quinn",
            "STUB_PICK_MODE": "match",
        }
        env.update(overrides)
        return env

    def _pick(self, excludes, env):
        return self.kos_handoff._relay_pick_with_reserve(
            sys.executable, json.dumps([str(self.stub)]), excludes,
            role="quality", reserve_task="KOS-UNIT-001", env=env)

    def _reserves(self) -> list:
        if not self.state.exists():
            return []
        return json.loads(self.state.read_text(encoding="utf-8")).get("reserves", [])

    def test_rejected_pick_writes_no_reserve(self) -> None:
        # Stub ignores --exclude, so the caller must reject Quinn itself.
        picked, reason = self._pick(["Quinn"], self._env())
        self.assertIsNone(picked, reason)
        self.assertIn("excluded", reason)
        self.assertEqual(self._reserves(), [], "拒绝的选人不得留下脏预占")

    def test_fallback_pick_writes_no_reserve(self) -> None:
        picked, reason = self._pick([], self._env(STUB_PICK_MODE="fallback"))
        self.assertIsNone(picked, reason)
        self.assertEqual(self._reserves(), [], "兜底被拒时不得留下脏预占")

    def test_validated_pick_reserves_afterwards(self) -> None:
        picked, _ = self._pick([], self._env())
        self.assertEqual(picked, "Quinn")
        self.assertEqual(self._reserves(), [{"name": "Quinn", "task": "KOS-UNIT-001"}])


@unittest.skipUnless(EXTERNAL_BOARD_TOOL.is_file(), "external kos-board.py not available")
class RealBoardReserveTests(_GitRepoMixin, unittest.TestCase):
    """Scenario 3 end-to-end with the real external kos-board.py."""

    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.home = self.root / "home"
        roles = self.home / "KOS-ROLES-001" / "roles"
        tools = self.home / "tools"
        roles.mkdir(parents=True)
        tools.mkdir(parents=True)
        (roles / "ROSTER.md").write_text(ROSTER, encoding="utf-8")
        (tools / "kos-board.py").write_text(
            EXTERNAL_BOARD_TOOL.read_text(encoding="utf-8"), encoding="utf-8")
        self.repo, self.base = self._init_repo(self.root)
        self.packet = _write(self.root / "KOS-SELFTEST-001" / "instructions" / "pkg.md",
                             "Executor（代码）；你不是 PM\n\n# 任务包：示例\n\n"
                             "- **包头档位**：`code-fix`\n- **复核重点**：\n  1. 检查一切。\n")
        self.report = _write(self.root / "KOS-SELFTEST-001" / "reports" / "exec.md",
                             "DONE\nLucy（Executor（代码））；运行时身份 Codex。\n")
        self.kos_env = {"KOS_HOME": str(self.home)}

    def tearDown(self):
        self.tmp.cleanup()

    def _run_relay(self):
        return _run_py("kos_handoff.py", [
            "relay-quality", "--report", str(self.report), "--packet", str(self.packet),
            "--base", self.base, "--repo", str(self.repo),
            "--board", sys.executable,
            "--board-args", json.dumps([str(self.home / "tools" / "kos-board.py")]),
        ], env=self.kos_env)

    def test_relay_quality_writes_no_board_reserve(self) -> None:
        # O129: department-pool relay never picks or reserves on the board;
        # the taker claims atomically, so board rows must stay untouched.
        (self.home / "KOS-ROLES-001" / "roles" / "ROSTER.md").write_text(
            "# 名册（试行）\n| 名字 | 角色 | 当前担任者 | 角色卡 |\n|---|---|---|---|\n"
            "| Reed | Preflight | Codex | Reed.md |\n", encoding="utf-8")
        result = self._run_relay()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        rows = board_rows(self.home)
        for name, cols in rows.items():
            self.assertNotEqual(cols[1], "已预占", f"{name} 被留下预占: {cols}")
        self.assertIn("Quality 部门", result.stdout)
        block = (self.packet.parent / "quality-relay-block.md").read_text(encoding="utf-8")
        self.assertIn("claim --role quality", block)
        self.assertNotIn("已预占", result.stdout)

    def test_relay_quality_leaves_valid_roster_board_untouched(self) -> None:
        result = self._run_relay()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        rows = board_rows(self.home)
        for name, cols in rows.items():
            self.assertNotEqual(cols[1], "已预占", f"{name} 被留下预占: {cols}")
        self.assertNotIn(" busy ", result.stdout)
        self.assertIn("角色：Quality 部门", result.stdout)


class DispatchDepartmentTests(unittest.TestCase):
    """Scenario 4 (O105): dispatch keeps 5 lines and supports department hints."""

    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.packet = _write(self.root / "pkg.md", "# 任务包：示例\n")

    def tearDown(self):
        self.tmp.cleanup()

    def _dispatch(self, *extra: str) -> tuple[int, list[str]]:
        result = _run_py("kos_handoff.py", [
            "dispatch", "--packet", str(self.packet), "--role", "Preflight", *extra])
        lines = [l for l in result.stdout.splitlines() if l.strip()]
        return result.returncode, lines

    def test_department_members_hint_on_role_line(self) -> None:
        code, lines = self._dispatch("--department", "Preflight", "--members", "Pete / Reed")
        self.assertEqual(code, 0)
        self.assertEqual(len(lines), 5)
        self.assertEqual(lines[1], "角色：Preflight 部门（Pete / Reed）")
        self.assertEqual(lines[0], "任务：pkg")
        self.assertEqual(lines[-1], "授权，直接执行")

    def test_members_only_hint(self) -> None:
        code, lines = self._dispatch("--members", "Pete,Reed")
        self.assertEqual(code, 0)
        self.assertEqual(len(lines), 5)
        self.assertEqual(lines[1], "角色：Preflight（Pete / Reed）")

    def test_plain_dispatch_unchanged(self) -> None:
        code, lines = self._dispatch()
        self.assertEqual(code, 0)
        self.assertEqual(len(lines), 5)
        self.assertEqual(lines[1], "角色：Preflight")


class PkgLintMultilineContinuationTests(unittest.TestCase):
    """Scenario 5 (O109): \\-continued kos_handoff calls get full flag checks."""

    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.start = "b" * 40

    def tearDown(self):
        self.tmp.cleanup()

    GOOD_MULTI_LINE = (
        "Executor（代码）；你不是 PM\n\n# 任务包：续行夹具（合规）\n\n"
        "- **包头档位**：`code-fix`\n\n"
        "## 验证命令\n\n"
        "python3 scripts/kos/kos_handoff.py relay-exec \\\n"
        "  --packet pkgs/a.md \\\n"
        "  --report reports/a.md \\\n"
        "  --base basebranch \\\n"
        "  --repo somerepo\n\n"
        "结果直接作为 Markdown 原样回复，严禁外层再套代码块。\n"
    )

    ILLEGAL_FLAG_MULTI_LINE = (
        "Executor（代码）；你不是 PM\n\n# 任务包：续行夹具（非法参数）\n\n"
        "- **包头档位**：`code-fix`\n\n"
        "## 验证命令\n\n"
        "python3 scripts/kos/kos_handoff.py relay-exec \\\n"
        "  --packet pkgs/a.md \\\n"
        "  --report reports/a.md \\\n"
        "  --base basebranch \\\n"
        "  --grade feature \\\n"
        "  --target main\n\n"
        "结果直接作为 Markdown 原样回复，严禁外层再套代码块。\n"
    )

    MISSING_REQUIRED_MULTI_LINE = (
        "Executor（代码）；你不是 PM\n\n# 任务包：续行夹具（缺必填项）\n\n"
        "- **包头档位**：`code-fix`\n\n"
        "## 验证命令\n\n"
        "python3 scripts/kos/kos_handoff.py relay-exec \\\n"
        "  --packet pkgs/a.md \\\n"
        "  --report reports/a.md\n\n"
        "结果直接作为 Markdown 原样回复，严禁外层再套代码块。\n"
    )

    def _lint(self, text: str) -> subprocess.CompletedProcess:
        packet = _write(self.root / "packet.md", text)
        return _run_py("kos-pkg-lint.py", ["--start", self.start, str(packet), "--no-git-check"])

    def test_good_multiline_command_passes(self) -> None:
        result = self._lint(self.GOOD_MULTI_LINE)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_illegal_flag_on_continuation_line_is_error(self) -> None:
        result = self._lint(self.ILLEGAL_FLAG_MULTI_LINE)
        self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
        self.assertIn("非法选项：--grade", result.stdout)
        self.assertIn("非法选项：--target", result.stdout)

    def test_missing_required_flag_on_multiline_command_is_error(self) -> None:
        result = self._lint(self.MISSING_REQUIRED_MULTI_LINE)
        self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
        self.assertIn("缺少必填选项", result.stdout)
        self.assertIn("--repo", result.stdout)

    def test_single_line_illegal_flag_still_checked(self) -> None:
        text = (
            "Executor（代码）；你不是 PM\n\n# 任务包：单行夹具\n\n"
            "- **包头档位**：`code-fix`\n\n"
            "## 验证命令\n\n"
            "python3 scripts/kos/kos_handoff.py relay-exec "
            "--packet pkgs/a.md --report reports/a.md --base basebranch "
            "--repo somerepo --grade feature\n\n"
            "结果直接作为 Markdown 原样回复，严禁外层再套代码块。\n"
        )
        result = self._lint(text)
        self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
        self.assertIn("非法选项：--grade", result.stdout)


if __name__ == "__main__":
    unittest.main()
