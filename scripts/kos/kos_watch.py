#!/usr/bin/env python3
"""kos_watch.py -- O90 read-only PM report watch.

Scans ``<kos_root>/*/reports/*.md`` and surfaces two categories of items
that need PM attention:

1. ``board-idle-newer-report``: the role board shows the task's member back
   to ``空闲`` while the task has a report newer than the board record.
2. ``awaiting-relay``: the task's latest report is a terminal status word
   (PASS / FAIL / DONE / STOPPED / BLOCKED / PARTIAL) but neither a later
   report nor a relay/dispatch block has appeared under the task directory.

Strictly read-only: no file is written and BOARD.md is never modified.
Stdlib only; Python 3.9+.
"""
from __future__ import annotations

import argparse
import json
import os
import re
import sys
from datetime import datetime, timedelta
from pathlib import Path

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, SCRIPT_DIR)

from clauses_spec import RELAY_SECTION_HEADING

STATUS_WORDS = ("PASS", "FAIL", "DONE", "STOPPED", "BLOCKED", "PARTIAL")
REASON_AWAITING_RELAY = "awaiting-relay"
REASON_BOARD_IDLE = "board-idle-newer-report"
REASON_LABELS = {
    REASON_AWAITING_RELAY: "最新报告已产出但尚无后续阶段更新报告或派发块",
    REASON_BOARD_IDLE: "看板已恢复空闲但任务有比看板记录更新的报告",
}
DEFAULT_SINCE_MINUTES = 120
IDLE_BADGE = "空闲"
BOARD_TIME_FORMAT = "%Y-%m-%d %H:%M"


def default_kos_root() -> str:
    """KOS root from KOS_HOME / KOS_PROJECT, never a hardcoded personal path."""
    home = os.environ.get("KOS_HOME", os.path.expanduser("~/.kos-work"))
    project = os.environ.get("KOS_PROJECT", "Universe-Keyboard")
    return os.path.join(home, project)


def default_board_roles_dir(kos_root: str) -> str:
    """Board roles dir lives next to the KOS root (KOS-ROLES-001)."""
    return os.path.join(kos_root, "KOS-ROLES-001")


def parse_board_idle(roles_dir: str) -> dict:
    """Map task -> most recent ``空闲`` board update time for that task.

    Only rows whose 牌子 is ``空闲`` and whose 任务 matches a task name are
    considered; malformed rows and unparseable timestamps are skipped.
    """
    board = Path(roles_dir) / "BOARD.md"
    try:
        text = board.read_text(encoding="utf-8")
    except OSError:
        return {}
    idle: dict = {}
    for line in text.splitlines():
        cols = [c.strip() for c in line.strip().strip("|").split("|")]
        if len(cols) < 4 or cols[0] in ("名字", "---") or not cols[0]:
            continue
        if cols[1] != IDLE_BADGE or not cols[2]:
            continue
        try:
            updated = datetime.strptime(cols[3], BOARD_TIME_FORMAT)
        except ValueError:
            continue
        task = cols[2]
        prev = idle.get(task)
        if prev is None or updated > prev:
            idle[task] = updated
    return idle


def parse_report_meta(report: Path) -> dict:
    """Read-only report header info: first-line status word and next_role."""
    try:
        text = report.read_text(encoding="utf-8")
    except OSError:
        return {"status": "", "next_role": ""}
    lines = text.splitlines()
    status = lines[0].strip().split()[0] if lines and lines[0].strip() else ""
    next_role = ""
    if RELAY_SECTION_HEADING in text:
        relay = text.split(RELAY_SECTION_HEADING, 1)[1]
        m = re.search(r"next_role[^\n:：]*[:：]\s*`?([^\n`]+)", relay)
        if m:
            next_role = m.group(1).strip()
    return {"status": status, "next_role": next_role}


def _has_followup(task_dir: Path, latest_report: Path) -> bool:
    """True when some file under the task dir (reports/ or instructions/) is
    newer than the latest report — i.e. a later-stage report or relay block
    already exists."""
    latest_epoch = latest_report.stat().st_mtime
    for sub in ("reports", "instructions"):
        subdir = task_dir / sub
        if not subdir.is_dir():
            continue
        for path in subdir.rglob("*"):
            if not path.is_file() or path == latest_report:
                continue
            try:
                if path.stat().st_mtime > latest_epoch:
                    return True
            except OSError:
                continue
    return False


def collect(kos_root: str, roles_dir: str | None = None,
            since_minutes: int | None = DEFAULT_SINCE_MINUTES,
            include_all: bool = False, now: float | None = None) -> list:
    """Return attention items sorted by task name; never writes anything."""
    root = Path(kos_root)
    if not root.is_dir():
        raise NotADirectoryError(kos_root)
    now_dt = datetime.fromtimestamp(now) if now is not None else datetime.now()
    idle_board = parse_board_idle(roles_dir) if roles_dir else {}
    items = []
    scanned = 0
    for task_dir in sorted(p for p in root.iterdir() if p.is_dir()):
        reports_dir = task_dir / "reports"
        reports = sorted(reports_dir.glob("*.md")) if reports_dir.is_dir() else []
        if not reports:
            continue
        scanned += 1
        latest = max(reports, key=lambda p: p.stat().st_mtime)
        latest_dt = datetime.fromtimestamp(latest.stat().st_mtime)
        if (not include_all and since_minutes is not None
                and latest_dt < now_dt - timedelta(minutes=since_minutes)):
            continue
        meta = parse_report_meta(latest)
        reasons = []
        if meta["status"] in STATUS_WORDS and not _has_followup(task_dir, latest):
            reasons.append(REASON_AWAITING_RELAY)
        idle_dt = idle_board.get(task_dir.name)
        if idle_dt is not None and latest_dt > idle_dt:
            reasons.append(REASON_BOARD_IDLE)
        if not reasons:
            continue
        items.append({
            "task": task_dir.name,
            "report": latest.name,
            "status": meta["status"],
            "mtime": latest_dt.strftime("%Y-%m-%d %H:%M:%S"),
            "next_role": meta["next_role"],
            "reasons": reasons,
        })
    items.sort(key=lambda i: i["task"])
    return items


def _format_text(items: list, since_minutes, include_all: bool) -> str:
    scope = ("全部（--all）" if include_all
             else f"最近 {since_minutes} 分钟")
    if not items:
        return f"KOS-REPORT-WATCH: 0 项需 PM 关注（扫描范围：{scope}）"
    lines = [f"KOS-REPORT-WATCH: {len(items)} 项需 PM 关注（扫描范围：{scope}）"]
    for item in items:
        reasons = "；".join(
            f"{REASON_LABELS[r]} [{r}]" for r in item["reasons"])
        lines.append(
            f"- {item['task']} | 最新报告: {item['report']} | "
            f"状态: {item['status'] or '未知'} | 修改时间: {item['mtime']} | "
            f"next_role: {item['next_role'] or '（未写）'} | 原因: {reasons}")
    return "\n".join(lines)


def execute(args) -> int:
    kos_root = args.kos_root or default_kos_root()
    if not Path(kos_root).is_dir():
        print(f"STOPPED: kos_root not found: {kos_root}", file=sys.stderr)
        return 2
    include_all = getattr(args, "all", False)
    since = None if include_all else args.since_minutes
    try:
        items = collect(kos_root, roles_dir=args.board_roles_dir,
                        since_minutes=since, include_all=include_all)
    except NotADirectoryError:
        print(f"STOPPED: kos_root not found: {kos_root}", file=sys.stderr)
        return 2
    if args.json:
        print(json.dumps({
            "items": items,
            "kos_root": kos_root,
            "since_minutes": since,
            "include_all": include_all,
        }, ensure_ascii=False))
    else:
        print(_format_text(items, since, include_all))
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="kos_handoff.py watch",
        description="O90 read-only scan for newly returned reports and pending relays")
    attach_arguments(parser)
    return parser


def attach_arguments(parser: argparse.ArgumentParser) -> None:
    """Add the watch option set to an external parser (kos_handoff.py wiring)."""
    parser.add_argument("--kos-root", default=None,
                        help="KOS root dir (default: $KOS_HOME/$KOS_PROJECT)")
    parser.add_argument("--board-roles-dir", default=None,
                        help="KOS-ROLES dir holding BOARD.md (default: <kos_root>/KOS-ROLES-001)")
    parser.add_argument("--since-minutes", type=int, default=DEFAULT_SINCE_MINUTES,
                        help="only flag tasks whose latest report is newer than N minutes ago (default: 120)")
    parser.add_argument("--all", action="store_true",
                        help="scan all task reports regardless of age")
    parser.add_argument("--json", action="store_true", help="JSON output")
    return parser


def run(argv=None) -> int:
    return execute(build_parser().parse_args(argv))


if __name__ == "__main__":
    sys.exit(run())
