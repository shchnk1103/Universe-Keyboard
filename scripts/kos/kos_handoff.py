#!/usr/bin/env python3
"""Unified O41 three-line renderer and conditional relay orchestrator."""
import argparse
import hashlib
import json
import os
import re
import subprocess
import sys
from pathlib import Path

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, SCRIPT_DIR)

from clauses_spec import PM_HANDOFF_ROLE, RELAY_SECTION_HEADING, THREE_LINE_FINAL_LABELS


def _sha256(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(65536), b""):
            h.update(chunk)
    return h.hexdigest()


def _join_fields(head, tail):
    head = (head or "").strip()
    tail = (tail or "").strip()
    if head and tail:
        return f"{head}，{tail}"
    return head or tail


KNOWN_ROLES = ("Alex", "Quinn", "Nick", "Lucy", "Cole", "Pete", "Wendy", "Ivy", "Jack")


def _extract_role_name(role_text):
    token = re.split(r"[\s（(：:,，]", (role_text or "").strip())[0]
    if token in KNOWN_ROLES:
        return token
    for role in KNOWN_ROLES:
        if re.search(rf"\b{re.escape(role)}\b", role_text or ""):
            return role
    return token


def _extract_entry_declared_roles(entry_path):
    with open(entry_path, encoding="utf-8") as f:
        head_lines = [next(f, "") for _ in range(10)]
    declared = []
    patterns = (
        re.compile(r"^#\s*([A-Za-z]+)\s*[：:]"),
        re.compile(r"(?:你的角色|角色)\s*[：:]?\s*([A-Za-z]+)"),
        re.compile(r"^派给\s*[：:]\s*([A-Za-z]+)"),
    )
    for line in head_lines:
        stripped = line.strip()
        for pat in patterns:
            m = pat.search(stripped)
            if m:
                declared.append(m.group(1))
    return declared


def _validate_render_handoff(status, next_role, entry_path, block_path):
    status_clean = (status or "").strip()
    has_entry = bool((entry_path or "").strip())
    has_block = bool((block_path or "").strip())
    if status_clean not in ("DONE", "PASS") and (has_entry or has_block):
        raise ValueError(
            f"STOPPED: non-passing status ({status_clean}) cannot dispatch a next-station entry; hand back to Jack（PM）"
        )
    if has_entry:
        expected_role = _extract_role_name(next_role)
        declared_roles = _extract_entry_declared_roles(entry_path)
        if declared_roles and expected_role not in declared_roles:
            raise ValueError(
                f"STOPPED: entry_path role mismatch: next_role={next_role} does not match {entry_path}"
            )


def render_three_line(status, summary, next_role, next_detail, report_path, entry_path=None, task_title=None, block_path=None):
    _validate_render_handoff(status, next_role, entry_path, block_path)
    real_report = os.path.realpath(report_path)
    report_sha = _sha256(real_report)
    l1, l2, l3 = THREE_LINE_FINAL_LABELS
    line1_body = _join_fields(status, summary)
    role_s = (next_role or "").strip()
    detail_s = (next_detail or "").strip()
    if role_s and detail_s and detail_s.startswith(role_s):
        line2_body = detail_s
    else:
        line2_body = _join_fields(role_s, detail_s)
    if block_path:
        with open(block_path, encoding="utf-8") as block_file:
            block = block_file.read().rstrip("\r\n")
    elif entry_path:
        real_entry = os.path.realpath(entry_path)
        block = "\n".join([
            f"派给：{role_s}",
            f"任务：{task_title or detail_s}",
            f"开工文档：{real_entry}",
            f"SHA-256：{_sha256(real_entry)}",
            "授权，直接执行",
        ])
    else:
        block = "\n".join([
            f"交回：{role_s}", f"事项：{detail_s}",
            f"报告：{real_report}", f"SHA-256：{report_sha}",
        ])
    return "\n\n".join([
        f"{l1}{line1_body}", f"{l2}{line2_body}",
        f"{l3}{real_report}（SHA-256 {report_sha}）", f"```text\n{block}\n```",
    ])


def _parse_report(report_path):
    text = open(report_path, encoding="utf-8").read()
    lines = text.splitlines()
    status = lines[0].strip().split()[0] if lines and lines[0].strip() else ""
    next_role = ""
    if RELAY_SECTION_HEADING in text:
        sec = text.split(RELAY_SECTION_HEADING, 1)[1]
        m = re.search(r"next_role[^\n:：]*[:：]\s*`?([^\n`]+)", sec)
        if m:
            next_role = m.group(1).strip()
    return status, next_role


def cmd_render(args):
    if not os.path.isfile(args.report_path):
        print(f"STOPPED: report not found: {args.report_path}", file=sys.stderr)
        return 2
    for path in (args.entry_path, args.block_path):
        if path and not os.path.isfile(path):
            print(f"STOPPED: file not found: {path}", file=sys.stderr)
            return 2
    try:
        output = render_three_line(
            args.status, args.summary, args.next_role, args.next_detail, args.report_path,
            args.entry_path, args.task_title, args.block_path,
        )
    except ValueError as exc:
        print(str(exc), file=sys.stderr)
        return 2
    print(output)
    return 0


def cmd_handoff(args):
    if not os.path.isfile(args.report_path):
        print(f"STOPPED: report not found: {args.report_path}", file=sys.stderr)
        return 2

    lint_cmd = [
        sys.executable,
        "-I",
        "-B",
        os.path.join(SCRIPT_DIR, "kos-report-lint.py"),
        "--require-o41",
        args.report_path,
    ]
    lint_res = subprocess.run(lint_cmd, capture_output=True, text=True)
    if lint_res.returncode != 0:
        sys.stderr.write(lint_res.stdout + lint_res.stderr)
        return lint_res.returncode

    status, report_next_role = _parse_report(args.report_path)
    is_success = status in ("DONE", "PASS")
    can_relay_next = (
        is_success
        and not args.terminal
        and args.next_pkg
        and args.next_params
        and args.next_block
        and args.next_role
        and args.next_step
        and args.auth_path
        and os.path.isfile(args.auth_path)
    )

    if can_relay_next:
        block_cmd = [
            "bash",
            os.path.join(SCRIPT_DIR, "kos-block.sh"),
            args.next_role,
            args.next_step,
            args.next_pkg,
            args.next_params,
            args.next_block,
            "--task-dir",
            args.task_dir,
            "--task-id",
            args.task_id,
            "--active-step",
            args.next_step,
            "--role",
            args.next_role,
            "--auth-path",
            args.auth_path,
            "--expect-rev",
            str(args.expect_rev),
            "--claim-id",
            args.claim_id,
            "--updated-by",
            args.updated_by,
        ]
        res = subprocess.run(block_cmd, capture_output=True, text=True)
        if res.returncode != 0:
            sys.stderr.write(res.stdout + res.stderr)
            return res.returncode
        next_role_out = args.next_role
        next_detail = f"块已生成未派发（待 Human 通知），入口 {os.path.realpath(args.task_dir)}/CURRENT.json"
    elif is_success and args.terminal:
        comp_cmd = [
            sys.executable,
            "-I",
            "-B",
            os.path.join(SCRIPT_DIR, "kos_current.py"),
            "complete",
            "--task-dir",
            args.task_dir,
            "--expect-rev",
            str(args.expect_rev),
            "--claim-id",
            args.claim_id,
            "--updated-by",
            args.updated_by,
        ]
        res = subprocess.run(comp_cmd, capture_output=True, text=True)
        if res.returncode != 0:
            sys.stderr.write(res.stdout + res.stderr)
            return res.returncode
        next_role_out = report_next_role or f"{PM_HANDOFF_ROLE}（PM）"
        next_detail = "已完成当前阶段，等待 Human / PM 后续决定"
    else:
        reason = args.reason or (f"status={status}" if not is_success else "missing next-station authorization")
        upg_cmd = [
            sys.executable,
            "-I",
            "-B",
            os.path.join(SCRIPT_DIR, "kos_current.py"),
            "upgrade",
            "--task-dir",
            args.task_dir,
            "--expect-rev",
            str(args.expect_rev),
            "--claim-id",
            args.claim_id,
            "--updated-by",
            args.updated_by,
            "--reason",
            reason,
        ]
        res = subprocess.run(upg_cmd, capture_output=True, text=True)
        if res.returncode != 0:
            sys.stderr.write(res.stdout + res.stderr)
            return res.returncode
        next_role_out = f"{PM_HANDOFF_ROLE}（PM）"
        next_detail = f"已升级至 PM（{reason}），未生成下一站入口"

    print(render_three_line(status, args.summary, next_role_out, next_detail, args.report_path,
                            block_path=args.next_block if can_relay_next else None))
    return 0




DEFAULT_IDENTITY = "Cowork 3P <cowork-3p@localhost>"
FORBIDDEN_WORDS = ("git push", "pr_flow.py", "--merge")


def _relay_check_identity(repo: str, expect: str) -> tuple[bool, str]:
    result = subprocess.run(
        [sys.executable, "-I", os.path.join(SCRIPT_DIR, "check_identity.py"),
         "--repo", repo, "--expect", expect, "--rev", "HEAD"],
        capture_output=True, text=True)
    ok = result.returncode == 0 and "IDENTITY_MATCH" in result.stdout
    return ok, (result.stdout + result.stderr).strip()


def _relay_pick(board: str, board_args_json: str, excludes: list[str], role: str = "quality") -> tuple[str | None, str]:
    return _relay_pick_with_reserve(board, board_args_json, excludes, role=role, reserve_task=None)


TASK_ID_RE = re.compile(r"KOS-[A-Za-z0-9-]+")


def _relay_pick_with_reserve(board: str, board_args_json: str, excludes: list[str], role: str = "quality",
                             reserve_task: str | None = None, env: dict | None = None) -> tuple[str | None, str]:
    if reserve_task and not TASK_ID_RE.fullmatch(reserve_task):
        reserve_task = None  # only genuine KOS task ids reserve; scratch paths stay read-only
    """Pick a specialist, optionally asking the board to reserve them for a task.

    Falls back to a plain pick when the board tool does not know --reserve
    (older stubs), so the caller never breaks on legacy tools.
    """
    clean_excludes = [e for e in dict.fromkeys(e.strip() for e in excludes) if e]
    base_argv = [board] + json.loads(board_args_json) + ["pick", "--role", role, "--exclude", ",".join(clean_excludes)]

    def run(argv: list[str]) -> subprocess.CompletedProcess:
        return subprocess.run(argv, capture_output=True, text=True, env=env)

    result = None
    if reserve_task:
        result = run(base_argv + ["--reserve", reserve_task])
        if result.returncode != 0 and "unrecognized" in (result.stderr or ""):
            print("# NOTE: board tool rejected --reserve, retrying without it", file=sys.stderr)
            result = None
    if result is None:
        result = run(base_argv)
    first = (result.stdout or "").strip().splitlines()
    line = first[0].strip() if first else ""
    if result.returncode != 0 or not line.startswith("PICK ["):
        return None, line or (result.stderr or "pick failed").strip()
    match = re.match(r"PICK \[[^\]]+\]:\s*(\S+?)（", line)
    if not match:
        return None, "unparsed pick line: " + line
    name = match.group(1)
    if any(name == e.strip() for e in excludes):
        return None, f"picked {name} is excluded"
    return name, line


GENERIC_BOARD_ROLES = {
    "Quality Reviewer": "quality",
    "Quality": "quality",
    "Preflight Reviewer": "preflight",
    "Preflight": "preflight",
    "Executor（代码）": "code",
    "Executor（记录/文档）": "doc",
    "Architect": "architect",
    "独立 Architecture 审查": "architect",
}
FALLBACK_QUALITY_EXCLUDES = ["Cole", "Pete", "Ivy"]


def _identity_name(path: Path) -> str | None:
    """Extract the role-holder name from a report's line 2 (`Name（role）…`)."""
    try:
        lines = path.read_text(encoding="utf-8").splitlines()
    except OSError:
        return None
    if len(lines) < 2:
        return None
    m = re.match(r"^\s*([A-Za-z][A-Za-z0-9_-]*)（", lines[1].strip())
    return m.group(1) if m else None


def _collect_participant_names(report: Path, extra_patterns: tuple[str, ...] = ()) -> list[str]:
    """Names of people who already worked on this task, from report line-2 fields."""
    candidates = [report]
    seen = {report.resolve()}
    for pattern in extra_patterns:
        for p in sorted(report.parent.glob(pattern)):
            r = p.resolve()
            if r not in seen:
                seen.add(r)
                candidates.append(p)
    names: list[str] = []
    for p in candidates:
        name = _identity_name(p)
        if name and name not in names:
            names.append(name)
    return names


def _split_next_role(next_role: str) -> tuple[str | None, str]:
    """Split `Maya（Quality Reviewer）` into (name, duty). A bare duty has no name."""
    head = re.split(r"[，,]", (next_role or "").strip(), maxsplit=1)[0].strip()
    match = re.match(r"^([A-Za-z][A-Za-z0-9_-]*)（([^）]+)）$", head)
    if match:
        return match.group(1), match.group(2).strip()
    return None, head


def _board_roles_dir(args) -> str:
    explicit = getattr(args, "board_roles_dir", None)
    if explicit:
        return explicit
    if os.environ.get("KOS_HOME"):
        return os.path.join(os.environ["KOS_HOME"], "KOS-ROLES-001")
    return os.path.expanduser("~/.kos-work/Universe-Keyboard/KOS-ROLES-001")


def _board_slot_state(args, name: str) -> str | None:
    """Current BOARD.md slot for `name`, or None when the board cannot be read."""
    path = os.path.join(_board_roles_dir(args), "BOARD.md")
    try:
        lines = open(path, encoding="utf-8")
    except OSError:
        return None
    with lines:
        for line in lines:
            cols = [part.strip() for part in line.strip().strip("|").split("|")]
            if len(cols) >= 2 and cols[0] == name:
                return cols[1]
    return None


def _auto_pick_next_role(args, report: Path, status: str, next_role: str) -> str:
    """Fill a bare duty, or move a busy named person, to the longest-idle peer.

    Jack（PM） stays put. A missing or failing board tool keeps the original
    text and never fails the handoff (O85).
    """
    if status not in ("DONE", "PASS"):
        return next_role
    name, duty = _split_next_role(next_role)
    if name == PM_HANDOFF_ROLE or duty == "PM":
        return next_role
    board_role = GENERIC_BOARD_ROLES.get(duty)
    if not board_role:
        return next_role
    excludes = _collect_participant_names(report)
    if name:
        # A concrete person is only replaced while their slot is busy or reserved.
        state = _board_slot_state(args, name)
        if state not in ("工作中", "已预占"):
            return next_role
        if name not in excludes:
            excludes.append(name)
    if not getattr(args, "board", None):
        return next_role
    task_id = report.parent.parent.name
    try:
        picked, pick_line = _relay_pick_with_reserve(
            args.board, args.board_args, excludes, role=board_role, reserve_task=task_id)
    except (OSError, ValueError, subprocess.SubprocessError) as exc:
        print(f"# NOTE: auto-pick kept next_role={next_role}: {exc}", file=sys.stderr)
        return next_role
    if not picked:
        print(f"# NOTE: auto-pick kept next_role={next_role}: {pick_line}", file=sys.stderr)
        return next_role
    return f"{picked}（{duty}）"


def cmd_relay_quality(args):
    pm = "Jack（PM）"

    def back(reason: str):
        print(f"STOPPED: relay-quality falls back to {pm}: {reason}", file=sys.stderr)
        return 1

    packet_text = Path(args.packet).read_text(encoding="utf-8")
    m_grade = re.search(r"包头档位[**：:\s]*`([^`]+)`", packet_text)
    grade = m_grade.group(1).strip() if m_grade else ""
    profile = TIER_PROFILES.get(grade)
    if not profile or "relay-quality" not in profile["relays"]:
        return back(f"packet grade {grade or '(none)'} does not allow relay-quality")
    m_focus = re.search(r"\*\*复核重点\*\*[：:]\s*\n((?:\s{2,}.*\n?)+)", packet_text)
    if not m_focus:
        return back("packet has no 复核重点 section")
    review_focus = m_focus.group(1).rstrip("\n")

    report = Path(args.report)
    report_text = report.read_text(encoding="utf-8")
    status = report_text.splitlines()[0].strip().split()[0] if report_text.strip() else ""
    if status != "DONE":
        return back(f"report status is {status}, not DONE")
    lint = subprocess.run([sys.executable, "-I", "-B", os.path.join(SCRIPT_DIR, "kos-report-lint.py"), str(report)],
                          capture_output=True, text=True)
    if lint.returncode != 0:
        return back("report lint failed: " + (lint.stdout + lint.stderr).strip().splitlines()[-1] if (lint.stdout + lint.stderr).strip() else "report lint failed")

    git = lambda *a: subprocess.run(["git", "-C", args.repo, *a], capture_output=True, text=True)
    count = git("rev-list", "--count", f"{args.base}..HEAD")
    if count.returncode != 0 or count.stdout.strip() != "1":
        return back(f"expected exactly 1 commit since {args.base}, got {count.stdout.strip() or count.stderr.strip()}")
    commit = git("rev-parse", "HEAD").stdout.strip()

    ok, detail = _relay_check_identity(args.repo, args.expect_identity)
    if not ok:
        return back("identity mismatch: " + detail)

    files_out = git("diff", "--name-only", args.base, "HEAD")
    files = [line for line in files_out.stdout.splitlines() if line.strip()]
    for path in files:
        m = re.search(re.escape(path) + r"[^\n]{0,40}?SHA-256[ ：:]*`?([0-9a-f]{64})", report_text)
        if not m:
            continue
        digest = hashlib.sha256(open(os.path.join(args.repo, path), "rb").read()).hexdigest()
        if digest != m.group(1):
            return back(f"log SHA mismatch for {path}")

    for word in FORBIDDEN_WORDS:
        if word in report_text:
            return back(f"report mentions forbidden word: {word}")

    excludes = list(FALLBACK_QUALITY_EXCLUDES)
    for name in _collect_participant_names(report, extra_patterns=("preflight*.md",)):
        if name not in excludes:
            excludes.append(name)
    picked, pick_line = _relay_pick_with_reserve(args.board, args.board_args, excludes,
                                                 role="quality",
                                                 reserve_task=Path(args.packet).parent.parent.name)
    if not picked:
        return back("pick did not yield a valid quality specialist: " + pick_line)

    log_shas = re.findall(r"(/[^\s`（）()]+?\.(?:log|txt|md|json|patch))[^\n]{0,40}?SHA-256[ ：:]*`?([0-9a-f]{64})", report_text)
    log_list = "\n".join(f"- {p}（SHA-256 `{h}`）" for p, h in log_shas) or "（无）"
    file_list = "\n".join(f"- {path}" for path in files) or "（无）"
    quality_report = report.parent / f"quality-{Path(args.packet).stem}.md"
    template = Path(SCRIPT_DIR, "quality_relay_template.md").read_text(encoding="utf-8")
    block = (template
             .replace("{TASK}", Path(args.packet).stem)
             .replace("{PICK}", f"{picked}（Quality）")
             .replace("{BASE}", args.base)
             .replace("{COMMIT}", commit)
             .replace("{WORKTREE}", str(Path(args.repo).resolve()))
             .replace("{PACKET}", str(Path(args.packet).resolve()))
             .replace("{PACKET_SHA}", hashlib.sha256(Path(args.packet).read_bytes()).hexdigest())
             .replace("{QUALITY_REPORT}", str(quality_report.resolve()))
             .replace("{EXCLUDES}", "、".join(excludes))
             .replace("{EXEC_REPORT}", str(report.resolve()))
             .replace("{EXEC_REPORT_SHA}", hashlib.sha256(report.read_bytes()).hexdigest())
             .replace("{FILE_LIST}", file_list)
             .replace("{LOG_SHA_LIST}", log_list)
             .replace("{REVIEW_FOCUS}", review_focus))
    out = Path(args.out) if getattr(args, "out", None) else Path(args.packet).parent / "quality-relay-block.md"
    if out.exists():
        return back(f"output already exists: {out}")
    out.write_text(block, encoding="utf-8")
    print(f"交回：{picked}（Quality）")
    print(f"事项：直通质检 {Path(args.packet).stem}")
    print(f"质检块：{out.resolve()}（SHA-256 {hashlib.sha256(out.read_bytes()).hexdigest()}）")
    out_sha = hashlib.sha256(out.read_bytes()).hexdigest()
    dispatch_block = "\n".join([
        f"任务：{Path(args.packet).stem}",
        f"角色：{picked}（Quality）",
        f"包路径：{out.resolve()}",
        f"SHA-256：{out_sha}",
        "授权，直接执行",
    ])
    print(f"```text\n{dispatch_block}\n```")
    _print_anti_wrap_note()
    return 0




TIER_PROFILES = {
    "doc-light": {
        "role": "doc",
        "stations": ["PM 写包", "实现·文档", "PM 终审", "发布*", "合并*"],
        "preflight": False,
        "red_tests": False,
        "independent_review": False,
        "relays": [],
    },
    "doc-rule": {
        "role": "doc",
        "stations": ["PM 写包", "预检", "实现·文档", "PM 终审", "发布*", "合并*"],
        "preflight": True,
        "red_tests": False,
        "independent_review": False,
        "relays": ["relay-exec"],
    },
    "code-fix": {
        "role": "code",
        "stations": ["PM 写包", "预检", "实现·代码（红测）", "独立复核", "PM 终审", "发布*", "真机(Human)*", "合并*"],
        "preflight": True,
        "red_tests": True,
        "independent_review": True,
        "relays": ["relay-exec", "relay-quality"],
    },
    "feature": {
        "role": "code",
        "stations": ["设计(Nick)", "架构审查(Alex)", "PM 写包", "预检", "实现·代码", "独立复核", "PM 终审", "发布*", "真机(Human)*", "合并*"],
        "preflight": True,
        "red_tests": True,
        "independent_review": True,
        "relays": [],
    },
}


def cmd_profile(args):
    pm = "Jack（PM）"
    grade = (args.grade or "").strip()
    profile = TIER_PROFILES.get(grade)
    if not profile:
        print(f"STOPPED: unknown grade: {grade}", file=sys.stderr)
        return 2
    if args.action:
        action = args.action.strip()
        if action not in ("relay-exec", "relay-quality"):
            print(f"STOPPED: unknown action: {action}", file=sys.stderr)
            return 2
        if action not in profile["relays"]:
            print(
                f"STOPPED: {grade} 不允许 {action} 直通（允许: {', '.join(profile['relays']) or '无'}），回退 {pm}",
                file=sys.stderr)
            return 1
        print(f"{grade}: {action} allowed")
        return 0
    lines = [f"{grade}:"]
    lines.append("站点: " + " → ".join(profile["stations"]))
    lines.append(f"预检: {'必经' if profile['preflight'] else '免'}")
    lines.append(f"红测: {'必经' if profile['red_tests'] else '免'}")
    lines.append(f"独立复核: {'必经' if profile['independent_review'] else '免'}")
    lines.append("直通: " + (", ".join(profile["relays"]) if profile["relays"] else "无（严禁越级直通）"))
    print("\n".join(lines))
    return 0


EXEC_ROLE_LABELS = {"code": "Executor（代码）", "doc": "Executor（记录/文档）"}
EXEC_GRADE_ROLES = {"code-fix": "code", "doc-rule": "doc"}


def cmd_relay_exec(args):
    pm = "Jack（PM）"

    def back(reason: str):
        print(f"STOPPED: relay-exec falls back to {pm}: {reason}", file=sys.stderr)
        return 1

    report = Path(args.report)
    report_lines = report.read_text(encoding="utf-8").splitlines()
    if not report_lines or report_lines[0].strip() != "PASS":
        return back("precheck report first line is not PASS")
    m = re.match(r"^([A-Za-z]+)（", report_lines[1].strip()) if len(report_lines) > 1 else None
    if not m:
        return back("precheck report line 2 has no identity")
    excludes = [m.group(1)]

    packet = Path(args.packet)
    packet_text = packet.read_text(encoding="utf-8")
    m_grade = re.search(r"包头档位[**：:\s]*`([^`]+)`", packet_text)
    grade = m_grade.group(1).strip() if m_grade else ""
    profile = TIER_PROFILES.get(grade)
    if not profile or "relay-exec" not in profile["relays"]:
        return back(f"packet grade {grade or '(none)'} does not allow relay-exec")
    role = profile["role"]
    m_author = re.search(r"^\s*[-*]?\s*\*?\*?包作者\*?\*?[：:]\s*(\S+)", packet_text, re.MULTILINE)
    if m_author:
        excludes.append(m_author.group(1))
    else:
        excludes.append("Jack")

    verify = subprocess.run([sys.executable, "-I", args.verify_tool, str(packet)], capture_output=True, text=True)
    if verify.returncode != 0:
        return back("kos-verify-inputs failed: " + (verify.stdout + verify.stderr).strip().splitlines()[-1] if (verify.stdout + verify.stderr).strip() else "kos-verify-inputs failed")
    lint = subprocess.run([sys.executable, "-I", args.pkg_lint_tool, "--start", args.base, str(packet)], capture_output=True, text=True)
    if lint.returncode != 0:
        return back("kos-pkg-lint failed: " + (lint.stdout + lint.stderr).strip().splitlines()[-1] if (lint.stdout + lint.stderr).strip() else "kos-pkg-lint failed")

    picked, pick_line = _relay_pick_with_reserve(args.board, args.board_args, excludes,
                                                 role=role,
                                                 reserve_task=Path(args.packet).parent.parent.name)
    if not picked:
        return back("pick did not yield a valid specialist: " + pick_line)

    out = Path(args.out) if getattr(args, "out", None) else packet.parent / "exec-relay-block.txt"
    if out.exists():
        return back(f"output already exists: {out}")
    packet_sha = hashlib.sha256(packet.read_bytes()).hexdigest()
    report_sha = hashlib.sha256(report.read_bytes()).hexdigest()
    block = "\n".join([
        f"任务：{packet.stem}",
        f"角色：{picked}（{EXEC_ROLE_LABELS[role]}）",
        f"包路径：{packet.resolve()}",
        f"SHA-256：{packet_sha}",
        "授权，直接执行",
    ])
    out.write_text(block + "\n", encoding="utf-8")
    print("\n\n".join([
        f"结论：PASS",
        f"下一位交付：{picked}（{EXEC_ROLE_LABELS[role]}）",
        f"报告：{report.resolve()}（SHA-256 {report_sha}）",
        f"```text\n{block}\n```",
    ]))
    _print_anti_wrap_note()
    return 0


def main(argv=None):
    parser = argparse.ArgumentParser(description="KOS O41 three-line renderer and relay orchestrator")
    sub = parser.add_subparsers(dest="cmd", required=True)

    p_ren = sub.add_parser("render")
    p_ren.add_argument("--status", required=True)
    p_ren.add_argument("--summary", default="")
    p_ren.add_argument("--next-role", required=True)
    p_ren.add_argument("--next-detail", default="")
    p_ren.add_argument("--report-path", required=True)
    p_ren.add_argument("--entry-path")
    p_ren.add_argument("--task-title")
    p_ren.add_argument("--block-path")

    p_han = sub.add_parser("handoff")
    p_han.add_argument("--task-dir", required=True)
    p_han.add_argument("--task-id", required=True)
    p_han.add_argument("--expect-rev", type=int, required=True)
    p_han.add_argument("--claim-id", required=True)
    p_han.add_argument("--updated-by", required=True)
    p_han.add_argument("--report-path", required=True)
    p_han.add_argument("--summary", required=True)
    p_han.add_argument("--terminal", action="store_true")
    p_han.add_argument("--next-role", default=None)
    p_han.add_argument("--next-step", default=None)
    p_han.add_argument("--next-pkg", default=None)
    p_han.add_argument("--next-params", default=None)
    p_han.add_argument("--next-block", default=None)
    p_han.add_argument("--auth-path", default=None)
    p_han.add_argument("--reason", default="")

    p_fin = sub.add_parser("final")
    p_fin.add_argument("--report", required=True)
    p_fin.add_argument("--status", default=None)
    p_fin.add_argument("--skip-lint", action="store_true")
    p_fin.add_argument("--summary", default="")
    p_fin.add_argument("--next-role", default=None)
    p_fin.add_argument("--next-detail", default=None)
    p_fin.add_argument("--entry-path")
    p_fin.add_argument("--task-title")
    p_fin.add_argument("--block-path")
    p_fin.add_argument("--board", default=sys.executable)
    p_fin.add_argument("--board-args", default=json.dumps([os.path.expanduser("~/.kos-work/Universe-Keyboard/tools/kos-board.py")]))
    p_fin.add_argument("--actor", default=None, help="override actor name for board idle release")
    p_fin.add_argument("--board-roles-dir", default=None, help="KOS-ROLES dir for board idle release (default: KOS_HOME or ~/.kos-work)")

    p_rel = sub.add_parser("relay-quality")
    p_rel.add_argument("--report", required=True)
    p_rel.add_argument("--packet", required=True)
    p_rel.add_argument("--base", required=True)
    p_rel.add_argument("--repo", required=True)
    p_rel.add_argument("--expect-identity", default=DEFAULT_IDENTITY)
    p_rel.add_argument("--board", default=sys.executable)
    p_rel.add_argument("--board-args", default=json.dumps([os.path.expanduser("~/.kos-work/Universe-Keyboard/tools/kos-board.py")]))
    p_rel.add_argument("--board-roles-dir", default=None, help="KOS-ROLES dir for board idle release (default: KOS_HOME or ~/.kos-work)")
    p_rel.add_argument("--out")

    p_prof = sub.add_parser("profile")
    p_prof.add_argument("--grade", required=True)
    p_prof.add_argument("--action", default=None)

    p_exe = sub.add_parser("relay-exec")
    p_exe.add_argument("--report", required=True)
    p_exe.add_argument("--packet", required=True)
    p_exe.add_argument("--base", required=True)
    p_exe.add_argument("--repo", required=True)
    p_exe.add_argument("--verify-tool", default=os.path.expanduser("~/.kos-work/Universe-Keyboard/tools/kos-verify-inputs.py"))
    p_exe.add_argument("--pkg-lint-tool", default=os.path.expanduser("~/.kos-work/Universe-Keyboard/tools/kos-pkg-lint.py"))
    p_exe.add_argument("--board", default=sys.executable)
    p_exe.add_argument("--board-args", default=json.dumps([os.path.expanduser("~/.kos-work/Universe-Keyboard/tools/kos-board.py")]))
    p_exe.add_argument("--board-roles-dir", default=None, help="KOS-ROLES dir for board idle release (default: KOS_HOME or ~/.kos-work)")
    p_exe.add_argument("--out")

    args = parser.parse_args(argv)
    if args.cmd == "render":
        return cmd_render(args)
    if args.cmd == "final":
        return cmd_final(args)
    if args.cmd == "relay-quality":
        return cmd_relay_quality(args)
    if args.cmd == "relay-exec":
        return cmd_relay_exec(args)
    if args.cmd == "profile":
        return cmd_profile(args)
    return cmd_handoff(args)


ANTI_WRAP_NOTE = "# NOTE: 请将以上 stdout 直接作为 Markdown 原样回复，严禁外层再套代码块。"


def _print_anti_wrap_note() -> None:
    print(ANTI_WRAP_NOTE, file=sys.stderr)


def cmd_final(args):
    """Lint the report, then print the standard three-line handoff + block.

    The report file is never modified: lint, SHA-256 and parsing all read it
    in place, and `render_three_line` only consumes the digest.
    """
    import hashlib
    report = Path(args.report).resolve()
    if not report.is_file():
        print(f"report not found: {report}", file=sys.stderr)
        return 2
    if not args.skip_lint:
        lint = Path(__file__).resolve().parent / "kos-report-lint.py"
        linted = subprocess.run(
            [sys.executable, "-I", str(lint), str(report)],
            text=True, capture_output=True, check=False)
        if linted.returncode != 0:
            print("STOPPED: report lint failed", file=sys.stderr)
            print(linted.stdout, file=sys.stderr)
            return 1
    status, report_next_role, report_next_step = _parse_report_fields(report)
    status = (args.status or status).strip()
    next_role = (args.next_role or report_next_role or f"{PM_HANDOFF_ROLE}（PM）").strip()
    next_detail = (args.next_detail if args.next_detail is not None else (report_next_step or "")).strip()
    next_role = _auto_pick_next_role(args, report, status, next_role)
    _release_board_idle(args, report)
    print(render_three_line(status, args.summary, next_role, next_detail, str(report),
                            entry_path=args.entry_path, task_title=args.task_title,
                            block_path=args.block_path))
    _print_anti_wrap_note()
    return 0


def _release_board_idle(args, report: Path) -> None:
    """Best-effort: flip the report actor's board slot back to idle (O77).

    Reads the actor name from report line 2 (or --actor); any failure only
    prints a stderr note and never blocks the final handoff output.
    """
    name = getattr(args, "actor", None) or _identity_name(report)
    if not name:
        print("# NOTE: board idle release skipped: no actor name in report line 2", file=sys.stderr)
        return
    task_id = report.parent.parent.name
    explicit = getattr(args, "board_roles_dir", None)
    if explicit:
        roles_dir = explicit
    elif os.environ.get("KOS_HOME"):
        roles_dir = os.path.join(os.environ["KOS_HOME"], "KOS-ROLES-001")
    else:
        roles_dir = os.path.expanduser("~/.kos-work/Universe-Keyboard/KOS-ROLES-001")
    board_md = os.path.join(roles_dir, "BOARD.md")
    # Only flip the slot when the board actually shows this actor as busy on
    # this exact task; otherwise leave it alone (never touch other rows).
    hit = False
    try:
        for l in open(board_md, encoding="utf-8"):
            c = [x.strip() for x in l.strip().strip("|").split("|")]
            if len(c) >= 4 and c[0] == name and c[1] == "工作中" and c[2] == task_id:
                hit = True
                break
    except OSError:
        hit = False
    if not hit:
        print("# NOTE: board idle release skipped: no busy row for this actor+task", file=sys.stderr)
        return
    try:
        argv = [args.board] + json.loads(args.board_args) + ["set", roles_dir, name, "idle", task_id]
        result = subprocess.run(argv, capture_output=True, text=True, timeout=30)
        if result.returncode != 0:
            print("# NOTE: board idle release failed (nonfatal): "
                  + (result.stderr or result.stdout or "").strip(), file=sys.stderr)
    except (OSError, subprocess.SubprocessError, ValueError) as exc:
        print(f"# NOTE: board idle release failed (nonfatal): {exc}", file=sys.stderr)


def _parse_report_fields(report: Path) -> tuple[str, str, str]:
    """Return (status, next_role, next_step) read from the report without writing."""
    text = report.read_text(encoding="utf-8")
    lines = text.splitlines()
    status = lines[0].strip().split()[0] if lines and lines[0].strip() else ""
    next_role = ""
    next_step = ""
    if RELAY_SECTION_HEADING in text:
        sec = text.split(RELAY_SECTION_HEADING, 1)[1]
        m = re.search(r"next_role[^\n:：]*[:：]\s*`?([^\n`]+)", sec)
        if m:
            next_role = m.group(1).strip()
        m = re.search(r"next_step[^\n:：]*[:：]\s*`?([^\n`]+)", sec)
        if m:
            next_step = m.group(1).strip()
    return status, next_role, next_step


if __name__ == "__main__":
    sys.exit(main())
