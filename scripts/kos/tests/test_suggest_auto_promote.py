"""KOS-SUGGEST-AUTO-PROMOTE-001 (O94): deduped mention counting and auto-register.

The real SUGGESTIONS.json / suggestions-ledger.md / KOS-IMPROVEMENT-REGISTER.md are
never touched: every case runs the in-repo scripts/kos/kos_suggest.py with KOS_HOME
pointed at a temporary directory and --register at a temporary register file.
"""
import json
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

KOS = Path(__file__).resolve().parents[1]
SUGGEST = KOS / "kos_suggest.py"
PY = sys.executable

REGISTER_HEAD = """# KOS 优化登记清单

编号登记（主表）：

| 编号 | 内容 | 组别 | 来源 | 当前处置 | 承接 | 计划 | 价值 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| O93 | 历史项丙 | G6 | 2026-11-20 某报告 | 待处置 | — | 待排期 | 待评估 |
| O94 | 建议自动提级登记 | G6 | 2026-11-24 Human 提出 | 待实施 | KOS-SUGGEST-AUTO-PROMOTE-001 | 见任务包 | 见任务包 |
"""


def init_home(root: Path) -> Path:
    """A fake KOS_HOME: empty SUGGESTIONS.json, empty queue, register with O94."""
    home = root / "home"
    (home / "PM-LOG").mkdir(parents=True)
    (home / "tools").mkdir()
    (home / "SUGGESTIONS.json").write_text('{"topics": {}}', encoding="utf-8")
    (home / "QUEUE.json").write_text('{"items": [{"id": "Q-TASK-1", "zone": "queue", "rank": 9}]}', encoding="utf-8")
    (home / "KOS-IMPROVEMENT-REGISTER.md").write_text(REGISTER_HEAD, encoding="utf-8")
    return home


def write_report(task: Path, body: str = "1. 某某建议") -> Path:
    (task / "reports").mkdir(parents=True, exist_ok=True)
    report = task / "reports" / "r.md"
    report.write_text(
        "DONE\nCole\n\n"
        "## 观察与改进意见（不影响状态，不在本包范围）\n" + body + "\n",
        encoding="utf-8",
    )
    return report


def run_suggest(home: Path, *args: str) -> subprocess.CompletedProcess:
    return subprocess.run(
        [PY, "-B", str(SUGGEST), *args],
        env={**os.environ, "KOS_HOME": str(home)},
        capture_output=True, text=True, timeout=120,
    )


def add(home: Path, task: Path, topic: str, text: str = "某建议", link: str = "") -> subprocess.CompletedProcess:
    report = write_report(task)
    args = ["add", "--task", task.name, "--report", str(report),
            "--text", text, "--topic", topic]
    if link:
        args += ["--link", link]
    return run_suggest(home, *args)


def db_topics(home: Path) -> dict:
    return json.loads((home / "SUGGESTIONS.json").read_text(encoding="utf-8"))["topics"]


def register_text(home: Path) -> str:
    return (home / "KOS-IMPROVEMENT-REGISTER.md").read_text(encoding="utf-8")


class SuggestAutoPromote(unittest.TestCase):
    """O94: deduped counting and auto-promote into the external register."""

    def test_same_task_repeat_does_not_inflate_count(self):
        with tempfile.TemporaryDirectory() as tmp:
            home = init_home(Path(tmp))
            t1 = Path(tmp) / "T1"
            r1 = add(home, t1, "t-dup")
            self.assertEqual(r1.returncode, 0, r1.stderr + r1.stdout)
            r2 = add(home, t1, "t-dup", text="同任务换份报告再转述")
            self.assertEqual(r2.returncode, 0, r2.stderr + r2.stdout)
            self.assertIn("1 次", r2.stdout)
            self.assertEqual(db_topics(home)["t-dup"]["count"], 1)
            # a different task does count as an independent mention
            t2 = Path(tmp) / "T2"
            r3 = add(home, t2, "t-dup", text="另一任务独立提出")
            self.assertEqual(r3.returncode, 0, r3.stderr + r3.stdout)
            self.assertIn("2 次", r3.stdout)
            self.assertEqual(db_topics(home)["t-dup"]["count"], 2)

    def test_cross_three_tasks_auto_registers_oxx(self):
        with tempfile.TemporaryDirectory() as tmp:
            home = init_home(Path(tmp))
            for name in ("T1", "T2"):
                add(home, Path(tmp) / name, "t-auto")
            r3 = add(home, Path(tmp) / "T3", "t-auto")
            self.assertEqual(r3.returncode, 0, r3.stderr + r3.stdout)
            self.assertEqual(db_topics(home)["t-auto"]["count"], 3)
            text = register_text(home)
            self.assertIn("| O95 |", text)
            self.assertIn("待Human拍板", text)
            self.assertIn("t-auto", text)
            # the new row is inserted right after the previous max Oxx row
            self.assertLess(text.index("| O94 |"), text.index("| O95 |"))
            # auto-linked, status untouched elsewhere, no priority mutation
            self.assertEqual(db_topics(home)["t-auto"]["link"], "O95")
            queue = json.loads((home / "QUEUE.json").read_text(encoding="utf-8"))
            self.assertEqual(queue["items"][0]["rank"], 9)
            # a 4th mention must not create another row
            add(home, Path(tmp) / "T4", "t-auto")
            text2 = register_text(home)
            self.assertEqual(text2.count("| O95 |"), 1)
            self.assertNotIn("| O96 |", text2)
            self.assertEqual(db_topics(home)["t-auto"]["link"], "O95")

    def test_linked_oxx_never_re_registers(self):
        with tempfile.TemporaryDirectory() as tmp:
            home = init_home(Path(tmp))
            for name in ("T1", "T2", "T3", "T4"):
                add(home, Path(tmp) / name, "t-linked", link="O94")
            self.assertEqual(db_topics(home)["t-linked"]["count"], 4)
            self.assertEqual(db_topics(home)["t-linked"]["link"], "O94")
            text = register_text(home)
            self.assertNotIn("| O95 |", text)

    def test_link_command_recognizes_new_oxx(self):
        with tempfile.TemporaryDirectory() as tmp:
            home = init_home(Path(tmp))
            t1 = Path(tmp) / "T1"
            add(home, t1, "t-link")
            # register gains O95 out-of-band (e.g. by another tool or auto-promote)
            reg = home / "KOS-IMPROVEMENT-REGISTER.md"
            reg.write_text(reg.read_text(encoding="utf-8") + "| O95 | 新增项 | G6 | 外部 | 待Human拍板 | — | — | — |\n",
                           encoding="utf-8")
            l = run_suggest(home, "link", "t-link", "O95")
            self.assertEqual(l.returncode, 0, l.stderr + l.stdout)
            self.assertEqual(db_topics(home)["t-link"]["link"], "O95")

    def test_register_override_flag(self):
        with tempfile.TemporaryDirectory() as tmp:
            home = init_home(Path(tmp))
            alt = Path(tmp) / "alt-register.md"
            alt.write_text(REGISTER_HEAD, encoding="utf-8")
            t1 = Path(tmp) / "T1"
            report = write_report(t1)
            a = run_suggest(home, "add", "--task", "T1", "--report", str(report),
                            "--text", "某建议", "--topic", "t-override",
                            "--register", str(alt))
            self.assertEqual(a.returncode, 0, a.stderr + a.stdout)
            l = run_suggest(home, "link", "t-override", "O94", "--register", str(alt))
            self.assertEqual(l.returncode, 0, l.stderr + l.stdout)
            self.assertEqual(db_topics(home)["t-override"]["link"], "O94")


if __name__ == "__main__":
    unittest.main()
