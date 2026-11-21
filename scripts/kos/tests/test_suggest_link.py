"""KOS-SUGGEST-LINK-001 (O75): check_report links to kos-suggest pending; Oxx link format.

The real SUGGESTIONS.json / suggestions-ledger.md / BOARD.md are never touched:
every case runs either a stub --suggest-tool or the external kos-suggest.py with
KOS_HOME pointed at a temporary directory.
"""
import json
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

KOS = Path(__file__).resolve().parents[1]
CHECK = KOS / "check_report.py"
# KOS-SUGGEST-LINK-001 fix R1: cases that need the machine-local external tool
# are gated on its existence so hosted CI (without it) still runs all green.
EXTERNAL_SUGGEST_TOOL = Path(os.environ.get(
    "KOS_TEST_EXTERNAL_SUGGEST_TOOL",
    "/Users/doubleshy0n/.kos-work/Universe-Keyboard/tools/kos-suggest.py"))
SUGGEST = EXTERNAL_SUGGEST_TOOL
PY = sys.executable


def write_report(task: Path, body: str = "1. 某某建议") -> Path:
    (task / "reports").mkdir(parents=True, exist_ok=True)
    report = task / "reports" / "r.md"
    report.write_text(
        "DONE\nCole\n\n"
        "## 观察与改进意见（不影响状态，不在本包范围）\n" + body + "\n",
        encoding="utf-8",
    )
    return report


def run_check(report: Path, *extra: str) -> subprocess.CompletedProcess:
    return subprocess.run([PY, "-B", str(CHECK), str(report), *extra],
                          capture_output=True, text=True, timeout=120)


def stub(tmp: Path, code: int, out: str = "") -> str:
    p = tmp / "stub_suggest.py"
    p.write_text(
        "import sys\n"
        f"print({out!r})\n"
        f"sys.exit({code})\n",
        encoding="utf-8",
    )
    return str(p)


def init_home(root: Path) -> Path:
    """A fake KOS_HOME: empty SUGGESTIONS.json, empty queue, REGISTER with O75."""
    home = root / "home"
    (home / "PM-LOG").mkdir(parents=True)
    (home / "tools").mkdir()
    (home / "SUGGESTIONS.json").write_text('{"topics": {}}', encoding="utf-8")
    (home / "QUEUE.json").write_text('{"items": [{"id": "Q-TASK-1"}]}', encoding="utf-8")
    (home / "KOS-IMPROVEMENT-REGISTER.md").write_text(
        "# KOS 优化登记清单\n\n| 编号 | 内容 |\n| O75 | 建议闭环 |\n",
        encoding="utf-8",
    )
    return home


def run_suggest(home: Path, *args: str) -> subprocess.CompletedProcess:
    return subprocess.run([PY, "-B", str(SUGGEST), *args],
                          env={**os.environ, "KOS_HOME": str(home)},
                          capture_output=True, text=True, timeout=120)


class CheckReportSuggestLink(unittest.TestCase):
    """O75: check_report probes a suggest tool, read-only, exit code untouched."""

    def test_stub_ok(self):
        with tempfile.TemporaryDirectory() as tmp:
            task = Path(tmp)
            report = write_report(task)
            r = run_check(report, "--suggest-tool", stub(task, 0, "无意见需要登记"))
            self.assertEqual(r.returncode, 0, r.stderr)
            self.assertIn("SUGGESTIONS: ok", r.stdout)
            self.assertNotIn("UNREGISTERED", r.stdout)

    def test_stub_unregistered_keeps_exit_code(self):
        with tempfile.TemporaryDirectory() as tmp:
            task = Path(tmp)
            report = write_report(task, "1. 意见甲\n2. 意见乙")
            tool = stub(task, 1, "该报告有 2 条意见，已登记 0 条。\n  - 意见甲\n  - 意见乙")
            r = run_check(report, "--suggest-tool", tool)
            self.assertEqual(r.returncode, 0, r.stderr)  # read-only probe: no exit change
            self.assertIn("SUGGESTIONS: UNREGISTERED (2)", r.stdout)
            self.assertIn("意见甲", r.stdout)  # tool output excerpt included

    def test_missing_tool_degrades(self):
        with tempfile.TemporaryDirectory() as tmp:
            report = write_report(Path(tmp))
            r = run_check(report, "--suggest-tool", str(Path(tmp) / "nope.py"))
            self.assertEqual(r.returncode, 0, r.stderr)
            self.assertIn("SUGGESTIONS: skipped (no-tool)", r.stdout)

    def test_no_suggest_check_flag(self):
        with tempfile.TemporaryDirectory() as tmp:
            report = write_report(Path(tmp))
            r = run_check(report, "--no-suggest-check")
            self.assertEqual(r.returncode, 0, r.stderr)
            self.assertIn("SUGGESTIONS: skipped (disabled)", r.stdout)
            self.assertNotIn("UNREGISTERED", r.stdout)

    @unittest.skipUnless(EXTERNAL_SUGGEST_TOOL.is_file(), "external kos-suggest.py not present")
    def test_real_tool_pending_readonly(self):
        # default tool path, real (read-only) pending against a temp report
        with tempfile.TemporaryDirectory() as tmp:
            report = write_report(Path(tmp))
            r = run_check(report)
            self.assertEqual(r.returncode, 0, r.stderr)
            self.assertRegex(r.stdout, r"SUGGESTIONS: UNREGISTERED \(\d+\)")


class SuggestOxxLink(unittest.TestCase):
    """O75: kos-suggest accepts Oxx links validated against the register."""

    @unittest.skipUnless(EXTERNAL_SUGGEST_TOOL.is_file(), "external kos-suggest.py not present")
    def test_add_and_digest_show_oxx(self):
        with tempfile.TemporaryDirectory() as tmp:
            home = init_home(Path(tmp))
            task = Path(tmp) / "task"
            r1 = write_report(task)
            r2 = write_report(task / "second", body="1. 某某建议\n2. 补充一句")
            a = run_suggest(home, "add", "--task", "T", "--report", str(r1),
                            "--text", "某建议", "--topic", "t-oxx", "--link", "O75")
            self.assertEqual(a.returncode, 0, a.stderr + a.stdout)
            db = json.loads((home / "SUGGESTIONS.json").read_text(encoding="utf-8"))
            self.assertEqual(db["topics"]["t-oxx"]["link"], "O75")
            run_suggest(home, "add", "--task", "T", "--report", str(r2),
                        "--text", "某建议", "--topic", "t-oxx", "--link", "O75")
            d = run_suggest(home, "digest")
            self.assertEqual(d.returncode, 0, d.stderr)
            self.assertIn("O75", d.stdout)

    @unittest.skipUnless(EXTERNAL_SUGGEST_TOOL.is_file(), "external kos-suggest.py not present")
    def test_link_command_accepts_oxx(self):
        with tempfile.TemporaryDirectory() as tmp:
            home = init_home(Path(tmp))
            task = Path(tmp) / "task"
            report = write_report(task)
            run_suggest(home, "add", "--task", "T", "--report", str(report),
                        "--text", "某建议", "--topic", "t-link")
            l = run_suggest(home, "link", "t-link", "O75")
            self.assertEqual(l.returncode, 0, l.stderr + l.stdout)
            db = json.loads((home / "SUGGESTIONS.json").read_text(encoding="utf-8"))
            self.assertEqual(db["topics"]["t-link"]["link"], "O75")

    @unittest.skipUnless(EXTERNAL_SUGGEST_TOOL.is_file(), "external kos-suggest.py not present")
    def test_link_rejects_unknown_oxx(self):
        with tempfile.TemporaryDirectory() as tmp:
            home = init_home(Path(tmp))
            task = Path(tmp) / "task"
            report = write_report(task)
            run_suggest(home, "add", "--task", "T", "--report", str(report),
                        "--text", "某建议", "--topic", "t-bad")
            l = run_suggest(home, "link", "t-bad", "O999")
            self.assertNotEqual(l.returncode, 0)
            self.assertIn("O999", l.stderr)

    @unittest.skipUnless(EXTERNAL_SUGGEST_TOOL.is_file(), "external kos-suggest.py not present")
    def test_queue_link_still_accepted(self):
        # compatibility: kos-q ids keep working next to Oxx ids
        with tempfile.TemporaryDirectory() as tmp:
            home = init_home(Path(tmp))
            task = Path(tmp) / "task"
            report = write_report(task)
            a = run_suggest(home, "add", "--task", "T", "--report", str(report),
                            "--text", "某建议", "--topic", "t-q", "--link", "Q-TASK-1")
            self.assertEqual(a.returncode, 0, a.stderr + a.stdout)

    @unittest.skipUnless(EXTERNAL_SUGGEST_TOOL.is_file(), "external kos-suggest.py not present")
    def test_pending_roundtrip(self):
        with tempfile.TemporaryDirectory() as tmp:
            home = init_home(Path(tmp))
            task = Path(tmp) / "task"
            report = write_report(task, "1. 意见甲\n2. 意见乙")
            p1 = run_suggest(home, "pending", str(report))
            self.assertEqual(p1.returncode, 1)
            self.assertIn("待登记", p1.stdout)
            run_suggest(home, "add", "--task", "T", "--report", str(report),
                        "--text", "意见甲", "--topic", "t-a")
            run_suggest(home, "add", "--task", "T", "--report", str(report),
                        "--text", "意见乙", "--topic", "t-b")
            p2 = run_suggest(home, "pending", str(report))
            self.assertEqual(p2.returncode, 0, p2.stderr + p2.stdout)
            self.assertIn("均已登记", p2.stdout)


if __name__ == "__main__":
    unittest.main()
