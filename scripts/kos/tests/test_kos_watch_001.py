"""Tests for KOS-REPORT-WATCH-001 (O90): kos_handoff.py watch read-only scan.

Stdlib only; everything runs in an isolated TemporaryDirectory KOS root,
never touching real kos-work data.
"""
from __future__ import annotations

import importlib.util
import json
import os
import subprocess
import sys
import tempfile
import time
import unittest
from pathlib import Path

KOS = Path(__file__).resolve().parents[1]
HANDOFF = KOS / "kos_handoff.py"
WATCH = KOS / "kos_watch.py"
PY = sys.executable

RELAY = "## 下一站接力（O41）"


def _load_module(name: str, path: Path):
    spec = importlib.util.spec_from_file_location(name, path)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def _report_text(status: str, next_role: str = "Jack（PM）", next_step: str = "核对报告并派发。") -> str:
    return (
        f"{status}\n"
        "tester（Executor-code）；运行时身份 test-runner；本会话未参与包撰写。\n"
        "\n"
        f"{RELAY}\n"
        f"- next_role：{next_role}\n"
        f"- next_step：{next_step}\n"
    )


def _touch(path: Path, epoch: float) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("x\n", encoding="utf-8") if not path.exists() else None
    os.utime(path, (epoch, epoch))


def _write_report(path: Path, status: str, epoch: float, **kw) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(_report_text(status, **kw), encoding="utf-8")
    os.utime(path, (epoch, epoch))


def _board_text(rows: list[tuple[str, str, str, str]]) -> str:
    lines = [
        "# 岗位牌子（领取角色时自动挂“工作中”，收尾运行 kos-role-release.sh 改回“空闲”）",
        "| 名字 | 牌子 | 任务 | 更新时间 | 备注 |",
        "|---|---|---|---|---|",
    ]
    lines += [f"| {n} | {b} | {t} | {ts} |  |" for n, b, t, ts in rows]
    return "\n".join(lines) + "\n"


class KosWatchCollectTests(unittest.TestCase):
    """Unit tests against kos_watch.collect with an isolated KOS root."""

    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.now = time.time()

    def tearDown(self) -> None:
        self.tmp.cleanup()

    def _watch(self):
        return _load_module("kos_watch_test", WATCH)

    def test_success_latest_report_without_followup_is_flagged(self) -> None:
        task = self.root / "T-A"
        old = self.now - 3600
        _touch(task / "instructions" / "packet.md", old - 600)
        _write_report(task / "reports" / "code-a-r1.md", "PASS", old)
        items = self._watch().collect(str(self.root), include_all=True, now=self.now)
        self.assertEqual([i["task"] for i in items], ["T-A"])
        item = items[0]
        self.assertEqual(item["status"], "PASS")
        self.assertEqual(item["report"], "code-a-r1.md")
        self.assertIn("awaiting-relay", item["reasons"])
        self.assertEqual(item["next_role"], "Jack（PM）")

    def test_newer_instruction_file_clears_awaiting_relay(self) -> None:
        task = self.root / "T-B"
        old = self.now - 3600
        _write_report(task / "reports" / "code-b-r1.md", "PASS", old)
        _touch(task / "instructions" / "exec-relay-block-r2.txt", old + 60)
        items = self._watch().collect(str(self.root), include_all=True, now=self.now)
        self.assertEqual(items, [])

    def test_board_idle_with_newer_report_is_flagged(self) -> None:
        task = self.root / "T-C"
        report_epoch = self.now - 1200
        _write_report(task / "reports" / "quality-c-r1.md", "FAIL", report_epoch)
        # instructions newer than the report: no awaiting-relay flag expected
        _touch(task / "instructions" / "packet.md", report_epoch + 60)
        roles = self.root / "roles"
        roles.mkdir()
        # board row updated BEFORE the report came back
        stamp = time.strftime("%Y-%m-%d %H:%M", time.localtime(report_epoch - 1800))
        (roles / "BOARD.md").write_text(
            _board_text([("Cole", "空闲", "T-C", stamp)]), encoding="utf-8")
        items = self._watch().collect(
            str(self.root), roles_dir=str(roles), include_all=True, now=self.now)
        self.assertEqual(len(items), 1)
        self.assertEqual(items[0]["task"], "T-C")
        self.assertIn("board-idle-newer-report", items[0]["reasons"])
        self.assertNotIn("awaiting-relay", items[0]["reasons"])
        self.assertEqual(items[0]["status"], "FAIL")

    def test_board_busy_row_and_stale_report_not_flagged(self) -> None:
        task = self.root / "T-D"
        old = self.now - 9000
        _write_report(task / "reports" / "code-d-r1.md", "DONE", old)
        _touch(task / "instructions" / "packet.md", old + 30)
        roles = self.root / "roles"
        roles.mkdir()
        stamp = time.strftime("%Y-%m-%d %H:%M", time.localtime(self.now - 60))
        (roles / "BOARD.md").write_text(
            _board_text([("Lucy", "工作中", "T-D", stamp)]), encoding="utf-8")
        items = self._watch().collect(
            str(self.root), roles_dir=str(roles), now=self.now)
        self.assertEqual(items, [])

    def test_since_window_excludes_old_latest_report(self) -> None:
        task = self.root / "T-E"
        old = self.now - 6 * 3600
        _write_report(task / "reports" / "code-e-r1.md", "PASS", old)
        items = self._watch().collect(str(self.root), since_minutes=120, now=self.now)
        self.assertEqual(items, [])
        items_all = self._watch().collect(
            str(self.root), since_minutes=120, include_all=True, now=self.now)
        self.assertEqual([i["task"] for i in items_all], ["T-E"])

    def test_unrecognized_first_line_is_not_flagged(self) -> None:
        task = self.root / "T-F"
        _write_report(task / "reports" / "Cole.md", "IN-PROGRESS", self.now - 60)
        items = self._watch().collect(str(self.root), include_all=True, now=self.now)
        self.assertEqual(items, [])

    def test_scan_is_read_only(self) -> None:
        task = self.root / "T-G"
        old = self.now - 600
        _write_report(task / "reports" / "code-g-r1.md", "PASS", old)
        _touch(task / "instructions" / "packet.md", old - 60)
        before = {}
        for p in sorted(self.root.rglob("*")):
            st = p.stat()
            before[str(p)] = (st.st_mtime_ns, p.read_bytes() if p.is_file() else None)
        self._watch().collect(str(self.root), include_all=True, now=self.now)
        after = {}
        for p in sorted(self.root.rglob("*")):
            st = p.stat()
            after[str(p)] = (st.st_mtime_ns, p.read_bytes() if p.is_file() else None)
        self.assertEqual(before, after)


class KosWatchCliTests(unittest.TestCase):
    """CLI tests: kos_handoff.py watch must expose the read-only scan."""

    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.now = time.time()

    def tearDown(self) -> None:
        self.tmp.cleanup()

    def _run_watch(self, *extra: str) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            [PY, "-I", "-B", str(HANDOFF), "watch",
             "--kos-root", str(self.root), *extra],
            capture_output=True, text=True, check=False)

    def test_json_output_reports_pending_relay(self) -> None:
        old = self.now - 300
        task = self.root / "T-H"
        _touch(task / "instructions" / "packet.md", old - 60)
        _write_report(task / "reports" / "code-h-r1.md", "STOPPED", old)
        res = self._run_watch("--all", "--json")
        self.assertEqual(res.returncode, 0, res.stderr)
        data = json.loads(res.stdout)
        self.assertEqual(data["since_minutes"], None)
        tasks = [i["task"] for i in data["items"]]
        self.assertEqual(tasks, ["T-H"])
        self.assertIn("awaiting-relay", data["items"][0]["reasons"])

    def test_json_empty_root_prints_no_items(self) -> None:
        res = self._run_watch("--all", "--json")
        self.assertEqual(res.returncode, 0, res.stderr)
        data = json.loads(res.stdout)
        self.assertEqual(data["items"], [])

    def test_missing_kos_root_fails_closed(self) -> None:
        res = self._run_watch("--all", "--json",
                              "--kos-root", str(self.root / "nope"))
        self.assertEqual(res.returncode, 2)

    def test_text_output_lists_attention_items(self) -> None:
        old = self.now - 120
        task = self.root / "T-I"
        _touch(task / "instructions" / "packet.md", old - 60)
        _write_report(task / "reports" / "code-i-r1.md", "DONE", old)
        res = self._run_watch("--all")
        self.assertEqual(res.returncode, 0, res.stderr)
        self.assertIn("T-I", res.stdout)
        self.assertIn("code-i-r1.md", res.stdout)
        self.assertIn("DONE", res.stdout)
        self.assertIn("awaiting-relay", res.stdout)


if __name__ == "__main__":
    unittest.main()
