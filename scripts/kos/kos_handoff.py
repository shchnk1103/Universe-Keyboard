#!/usr/bin/env python3
"""Unified O41 three-line renderer and conditional relay orchestrator."""
import argparse
import hashlib
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

    args = parser.parse_args(argv)
    if args.cmd == "render":
        return cmd_render(args)
    if args.cmd == "final":
        return cmd_final(args)
    return cmd_handoff(args)


def cmd_final(args):
    """Print one line `<STATUS> <realpath> <sha256>` without touching the report."""
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
    status = args.status
    if not status:
        first = report.read_text(encoding="utf-8").splitlines()[0].strip()
        status = first.split()[0] if first.split() else ""
    digest = hashlib.sha256(report.read_bytes()).hexdigest()
    print(f"{status} {report} {digest}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
