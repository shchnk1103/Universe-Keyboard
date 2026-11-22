"""KOS-BOARD-RESERVE-001 (O77): dispatch reserve -> busy lifecycle -> final auto-idle.

All cases run against a temporary KOS_HOME with stub board tools; the real
BOARD.md is never touched.
"""
from __future__ import annotations

import importlib.util
import json
import os
import re
import subprocess
import sys
import tempfile
import textwrap
import time
import unittest
from pathlib import Path

REPO = Path(__file__).resolve().parents[3]
KOS = REPO / "scripts" / "kos"
PY = sys.executable

ROSTER = """# 名册（试行）
| 名字 | 角色 | 当前担任者 | 角色卡 |
|---|---|---|---|
| Pete | Quality | Claude | Pete.md |
| Ivy | Quality | Claude | Ivy.md |
| Cole | Executor（代码） | Codex | Cole.md |
"""


def load_module(name: str, path: Path):
    spec = importlib.util.spec_from_file_location(name, path)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def board(home: Path, *args: str) -> subprocess.CompletedProcess:
    return subprocess.run(
        [PY, "-B", str(home / "tools" / "kos-board.py"), *args],
        env={**os.environ, "KOS_HOME": str(home)},
        capture_output=True, text=True, timeout=120)


def init_home(root: Path) -> Path:
    """Fake KOS_HOME with a roster of Pete/Ivy (quality) + Cole (code)."""
    home = root / "home"
    roles = home / "KOS-ROLES-001" / "roles"
    tools = home / "tools"
    roles.mkdir(parents=True)
    tools.mkdir(parents=True)
    (roles / "ROSTER.md").write_text(ROSTER, encoding="utf-8")
    return home


def place_board_tool(home: Path) -> None:
    """Copy the real external kos-board.py into the fake home's tools/."""
    real = Path("/Users/doubleshy0n/.kos-work/Universe-Keyboard/tools/kos-board.py")
    (home / "tools" / "kos-board.py").write_text(real.read_text(encoding="utf-8"), encoding="utf-8")


def rows(home: Path) -> dict:
    out = {}
    p = home / "KOS-ROLES-001" / "BOARD.md"
    if not p.exists():
        return out
    for l in p.read_text(encoding="utf-8").splitlines():
        c = [x.strip() for x in l.strip().strip("|").split("|")]
        if len(c) >= 5 and c[0] not in ("名字", "---", "") and not c[0].startswith("-"):
            out[c[0]] = c
    return out


class BoardReserveTests(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        self.home = init_home(Path(self.tmp.name))
        place_board_tool(self.home)

    def tearDown(self) -> None:
        self.tmp.cleanup()

    def test_pick_reserve_skips_reserved(self) -> None:
        r = board(self.home, "pick", "--role", "quality", "--reserve", "KOS-DEMO-001")
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
        first = r.stdout.splitlines()[0]
        m = re.match(r"PICK \[[^\]]+\]:\s*(\S+?)（", first)
        self.assertIsNotNone(m, r.stdout)
        picked1 = m.group(1)
        other = "Ivy" if picked1 == "Pete" else "Pete"
        self.assertEqual(rows(self.home)[picked1][1], "已预占")
        self.assertEqual(rows(self.home)[picked1][2], "KOS-DEMO-001")
        r2 = board(self.home, "pick", "--role", "quality")
        self.assertEqual(r2.returncode, 0, r2.stdout + r2.stderr)
        self.assertNotIn(f"PICK [Quality]: {picked1}", r2.stdout)
        self.assertIn(other, r2.stdout.splitlines()[0])

    def test_reserve_ttl_auto_release(self) -> None:
        r = board(self.home, "pick", "--role", "quality", "--reserve", "KOS-DEMO-001", "--ttl", "0.5")
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
        first = r.stdout.splitlines()[0]
        m = re.match(r"PICK \[[^\]]+\]:\s*(\S+?)（", first)
        self.assertIsNotNone(m, r.stdout)
        picked1 = m.group(1)
        self.assertEqual(rows(self.home)[picked1][1], "已预占")
        time.sleep(0.7)
        r2 = board(self.home, "pick", "--role", "quality")
        self.assertEqual(r2.returncode, 0, r2.stdout + r2.stderr)
        # released: the slot no longer blocks the pick, whoever wins
        self.assertNotEqual(rows(self.home)[picked1][1], "已预占")
        m2 = re.match(r"PICK \[[^\]]+\]:\s*(\S+?)（", r2.stdout.splitlines()[0])
        self.assertIsNotNone(m2, r2.stdout)
        self.assertIn(m2.group(1), ("Pete", "Ivy"))

    def test_set_busy_idle_still_works(self) -> None:
        board(self.home, "pick", "--role", "quality", "--reserve", "KOS-DEMO-001")
        roles_dir = str(self.home / "KOS-ROLES-001")
        r = board(self.home, "set", roles_dir, "Pete", "busy", "T-1")
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
        self.assertEqual(rows(self.home)["Pete"][1], "工作中")
        r = board(self.home, "set", roles_dir, "Pete", "idle", "T-1", "done")
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
        self.assertEqual(rows(self.home)["Pete"][1], "空闲")

    def test_final_releases_actor_idle(self) -> None:
        roles_dir = self.home / "KOS-ROLES-001"
        (roles_dir / "BOARD.md").write_text(
            "# 岗位牌子\n| 名字 | 牌子 | 任务 | 更新时间 | 备注 |\n|---|---|---|---|---|\n"
            "| Cole | 工作中 | KOS-DEMO-001 | 2026-11-22 09:00 | |\n", encoding="utf-8")
        task = self.home / "KOS-DEMO-001"
        (task / "reports").mkdir(parents=True)
        report = task / "reports" / "r.md"
        report.write_text(
            "DONE\nCole（Executor（代码））；运行时身份 Codex，主机用户 t。本会话未参与 KOS-DEMO-001 的包撰写；既往无。\n\n"
            "## 下一站接力（O41）\n- next_role：Jack（PM）\n- next_step：终审\n",
            encoding="utf-8")
        r = subprocess.run(
            [PY, "-I", "-B", str(KOS / "kos_handoff.py"), "final",
             "--report", str(report),
             "--board-roles-dir", str(roles_dir), "--skip-lint"],
            env={**os.environ, "KOS_HOME": str(self.home)},
            capture_output=True, text=True, timeout=120)
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertIn("结论：DONE", r.stdout)
        row = rows(self.home)["Cole"]
        self.assertEqual(row[1], "空闲")
        self.assertEqual(row[2], "KOS-DEMO-001")

    def test_final_release_failure_is_nonfatal(self) -> None:
        task = self.home / "KOS-DEMO-001"
        (task / "reports").mkdir(parents=True)
        report = task / "reports" / "r.md"
        report.write_text(
            "DONE\nCole（Executor（代码））；运行时身份 Codex，主机用户 t。既往无。\n\n"
            "## 下一站接力（O41）\n- next_role：Jack（PM）\n- next_step：终审\n",
            encoding="utf-8")
        roles_dir = self.home / "KOS-ROLES-001"
        r = subprocess.run(
            [PY, "-I", "-B", str(KOS / "kos_handoff.py"), "final",
             "--report", str(report),
             "--board", PY,
             "--board-args", json.dumps(["/nonexistent/board-tool.py"]),
             "--board-roles-dir", str(roles_dir), "--skip-lint"],
            env={**os.environ, "KOS_HOME": str(self.home)},
            capture_output=True, text=True, timeout=120)
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertIn("结论：DONE", r.stdout)

    def test_relay_pick_sends_reserve(self) -> None:
        mod = load_module("kos_handoff_reserve", KOS / "kos_handoff.py")
        calls: list[list[str]] = []

        stub = self.home / "tools" / "stub_board.py"
        stub.write_text(textwrap.dedent("""
            import json, os, sys
            argv = sys.argv[1:]
            out = os.environ["STUB_LOG"]
            with open(out, "a", encoding="utf-8") as f:
                f.write(json.dumps(argv) + "\\n")
            role = argv[argv.index("--role") + 1]
            print(f"PICK [x]: Pete（r）")
        """), encoding="utf-8")
        log = self.home / "stub-log.jsonl"
        env = {**os.environ, "STUB_LOG": str(log)}
        picked, line = mod._relay_pick_with_reserve(
            sys.executable, json.dumps([str(stub)]), [], role="quality",
            reserve_task="KOS-DEMO-009", env=env)
        self.assertEqual(picked, "Pete", line)
        sent = json.loads(log.read_text(encoding="utf-8").splitlines()[-1])
        self.assertIn("--reserve", sent)
        self.assertEqual(sent[sent.index("--reserve") + 1], "KOS-DEMO-009")

    def test_relay_pick_falls_back_without_reserve(self) -> None:
        mod = load_module("kos_handoff_fallback", KOS / "kos_handoff.py")
        stub = self.home / "tools" / "stub_old_board.py"
        stub.write_text(textwrap.dedent("""
            import sys
            if "--reserve" in sys.argv:
                sys.stderr.write("unrecognized arguments: --reserve")
                sys.exit(2)
            print("PICK [x]: Pete（r）")
        """), encoding="utf-8")
        picked, line = mod._relay_pick_with_reserve(
            sys.executable, json.dumps([str(stub)]), [], role="quality",
            reserve_task="KOS-DEMO-009")
        self.assertEqual(picked, "Pete", line)

    def test_pack_board_pick_sends_reserve(self) -> None:
        mod = load_module("kos_pack_reserve", KOS / "kos_pack.py")
        stub = self.home / "tools" / "stub_pack_board.py"
        log = self.home / "stub-pack-log.jsonl"
        stub.write_text(textwrap.dedent("""
            import json, os, sys
            argv = sys.argv[1:]
            with open(os.environ["STUB_LOG"], "a", encoding="utf-8") as f:
                f.write(json.dumps(argv) + "\\n")
            print("PICK [Executor（代码）]: Cole（Executor（代码） | 上次：从未记录 -）")
        """), encoding="utf-8")
        env = {**os.environ, "STUB_LOG": str(log)}
        argv = [sys.executable, "-B", str(stub), "pick", "--role", "code"]
        # board_pick must forward a reserve task id
        picked = mod.board_pick_with_reserve(str(stub), "code", "KOS-DEMO-007", env=env)
        self.assertIsNotNone(picked)
        sent = json.loads(log.read_text(encoding="utf-8").splitlines()[-1])
        self.assertIn("--reserve", sent)
        self.assertEqual(sent[sent.index("--reserve") + 1], "KOS-DEMO-007")


if __name__ == "__main__":
    unittest.main()
