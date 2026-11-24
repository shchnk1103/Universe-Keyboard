#!/usr/bin/env python3
"""kos_pack.py -- one-shot KOS task packaging CLI (KOS-PACK-CLI-001).

Computes frozen SHA-256 digests straight from disk bytes (no hand copying),
writes an executor task package (and optional preflight package), re-verifies
both with kos-verify-inputs.py and kos-pkg-lint.py (fail closed), asks the
board tool for a candidate, and prints a ready-to-paste dispatch block.

Stdlib only; Python 3.9+.
"""
from __future__ import annotations

import argparse
import hashlib
import os
import re
import shlex
import subprocess
import sys
from pathlib import Path

KOS_DIR = Path(__file__).resolve().parent
REPO_ROOT = KOS_DIR.parent.parent
KOS_TASK_ROOT = os.path.expanduser("~/.kos-work/Universe-Keyboard")
DEFAULT_BOARD_TOOL = os.path.join(KOS_TASK_ROOT, "tools", "kos-board.py")
GRADES = ("code-fix", "doc-rule", "doc-light", "feature")
PICK_RE = re.compile(r"PICK[^:：]*[:：]\s*(\S+?)（")

# KOS-PACK-CLI-002 (O81): one-shot presets for the four standard packet kinds.
# Each preset fixes the grade and the standard closing clauses so the PM only
# writes goals and acceptance bounds.
QUICK_KINDS = {
    "diag": {"grade": "code-fix", "role": "Executor（代码·只读诊断）", "board": "code", "handoff": "final"},
    "code-fix": {"grade": "code-fix", "role": "Executor（代码）", "board": "code", "handoff": "relay-quality"},
    "doc-light": {"grade": "doc-light", "role": "Executor（记录/文档）", "board": "doc", "handoff": "final"},
    "publish": {"grade": "doc-rule", "role": "Executor（发布）", "board": "release", "handoff": "final"},
}

QUICK_STANDARD_STEPS = (
    "过程静默：工具调用间隙保持静默，不输出过程播报。",
    "只改任务包允许写入路径内的文件；禁止合并。",
    "报告如实注明是否使用开发子代理；不得虚构哈希、计数或测试结果。",
    "报告写入包内指定的 reports/ 路径，首行 DONE/PARTIAL/BLOCKED（预检包首行 PASS/FAIL）。",
)


# Kind-specific opening step and the role the executor takes over to at close.
QUICK_KIND_STEPS = {
    "diag": "只做诊断与证据收集，不实现修复、不提交。",
    "code-fix": "在隔离 worktree 红绿测试（先红后绿）、实现修复，恰 1 个干净提交。",
    "doc-light": "只改文档：按目标逐条落稿，不改动任何代码文件。",
    "publish": "核对待发布提交、测试与发布授权；仅执行目标中明确授权的发布动作，禁止合并。",
}


def build_quick_steps(goals: "list[str]", kind: str) -> "list[str]":
    """Kind lead step, then PM-supplied goals, then standard closing clauses."""
    return [QUICK_KIND_STEPS[kind]] + list(goals) + list(QUICK_STANDARD_STEPS)


def die(code: int, message: str) -> "int":
    print(message, file=sys.stderr)
    return code


def sha256_file(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def run_tool(argv: list, cwd: str) -> int:
    proc = subprocess.run(argv, cwd=cwd, capture_output=True, text=True)
    if proc.returncode != 0:
        sys.stdout.write(proc.stdout)
        sys.stderr.write(proc.stderr)
        return proc.returncode
    return 0


def verify_and_lint(package: Path, base: str, cwd: str, use_lint: bool) -> "int | None":
    rc = run_tool([sys.executable, "-I", str(KOS_DIR / "kos-verify-inputs.py"), str(package)], cwd)
    if rc != 0:
        return die(4, "kos-verify-inputs failed for %s" % package)
    if use_lint:
        rc = run_tool(
            [sys.executable, "-I", str(KOS_DIR / "kos-pkg-lint.py"), "--start", base, str(package)],
            cwd,
        )
        if rc != 0:
            return die(5, "kos-pkg-lint failed for %s" % package)
    return None


def board_pick(board_tool: str, board_role: str) -> "tuple[str, str] | None":
    return board_pick_with_reserve(board_tool, board_role, reserve_task=None)


def board_pick_with_reserve(board_tool: str, board_role: str,
                            reserve_task: str | None = None,
                            env: dict | None = None) -> "tuple[str, str] | None":
    """Pick a candidate, optionally reserving them for a task (O77).

    Falls back to a plain pick when the board tool does not know --reserve.
    """
    argv = [board_tool, "pick", "--role", board_role]
    if board_tool.endswith(".py"):
        argv = [sys.executable, "-B", board_tool, "pick", "--role", board_role]
    proc = None
    if reserve_task and re.fullmatch(r"KOS-[A-Za-z0-9-]+", reserve_task):
        proc = subprocess.run(argv + ["--reserve", reserve_task],
                              capture_output=True, text=True, env=env)
        if proc.returncode != 0 and "unrecognized" in (proc.stderr or ""):
            print("# NOTE: board tool rejected --reserve, retrying without it", file=sys.stderr)
            proc = None
    if proc is None:
        proc = subprocess.run(argv, capture_output=True, text=True, env=env)
    lines = [l.strip() for l in (proc.stdout or "").splitlines() if l.strip()]
    first = lines[0] if lines else ""
    if proc.returncode != 0 or not first.startswith("PICK"):
        return None
    m = PICK_RE.match(first)
    if not m:
        return None
    return m.group(1), first


def render_allow(item: str) -> str:
    """Repo-relative script refs that do not exist yet are new files created by
    the task; render them as placeholders so pkg-lint E6 (referenced scripts
    must exist) stays green while keeping the "to be created" meaning."""
    tok = item.strip()
    if (
        "<" not in tok
        and "/" in tok
        and tok.endswith((".py", ".sh"))
        and not tok.startswith("/")
        and not (REPO_ROOT / tok).exists()
    ):
        # The task creates this file; mark it as new so pkg-lint E6 (referenced
        # scripts must exist) does not fire on a file that cannot exist yet.
        head, _, name = tok.rpartition("/")
        return "%s/<新文件 %s>（新增）" % (head, name)
    return tok


def build_exec_package(a, input_pairs: "list[tuple[str, str]]", close_cmd: str = "final --report <报告路径>") -> str:
    lines = []
    lines.append("%s；你不是 PM。" % a.role)
    lines.append("")
    lines.append("# 任务包：%s（%s）" % (a.task, a.title))
    lines.append("")
    lines.append("- **角色**：%s" % a.role)
    lines.append("- **任务**：%s" % a.task)
    lines.append("- **包头档位**：`%s`" % a.grade)
    lines.append("- **指派执行者**：%s" % a.role)
    lines.append("- **复核重点**：")
    for i, focus in enumerate(a.focus, 1):
        lines.append("  %d. %s" % (i, focus))
    lines.append("")
    lines.append("## 冻结输入（执行前必核）")
    lines.append("")
    lines.append("- 主检出基线 BASE = %s（git ls-remote --heads origin main 须等于 BASE；若 origin/main 已前移且 BASE 是其祖先且未改动本包允许文件，可顺延最新 origin/main 并在报告写明 ACTUAL_BASE）" % a.base)
    for path, digest in input_pairs:
        lines.append("- `%s` SHA-256 `%s`" % (path, digest))
    if getattr(a, "kind", None) == "publish":
        lines.append("- 待发布 worktree：%s（分支 `%s`；核验实际提交与冻结输入一致，不新建）" % (a.wt, a.branch))
    else:
        lines.append("- worktree：%s（分支 `%s`，从 BASE 新建，--no-track）" % (a.wt, a.branch))
    lines.append("")
    lines.append("## 允许写入路径")
    lines.append("")
    lines.append("- worktree 内仅限：")
    for allow in a.allow:
        lines.append("  - %s" % render_allow(allow))
    lines.append("- 任务外置目录：`%s/%s/`（reports/、logs/、scratch/）" % (KOS_TASK_ROOT, a.task))
    if getattr(a, "kind", None) == "diag":
        lines.append("- 主检出 `.git` 仅限 worktree 元数据与 objects/refs/logs；不改主检出工作区，不提交")
    else:
        lines.append("- 主检出 `.git` 仅限 worktree 元数据与 objects/refs/logs；禁止修改主检出工作区")
    if getattr(a, "kind", None) == "publish":
        lines.append("- 仅按目标中明确的发布授权执行 push 或开 PR；禁止合并")
    else:
        lines.append("- 禁止 push、开 PR、合并")
    lines.append("")
    lines.append("## 要做什么")
    lines.append("")
    for i, step in enumerate(a.step, 1):
        lines.append("%d. %s" % (i, step))
    lines.append("")
    lines.append("## 报告与交付")
    lines.append("")
    report = "%s/%s/reports/code-%s-r1.md" % (KOS_TASK_ROOT, a.task, a.task.lower())
    if a.command == "quick":
        next_role = "Quality Reviewer" if a.kind == "code-fix" else "Jack（PM）"
        lines.append("- 报告写入：`%s`（首行 DONE/PARTIAL/BLOCKED，写 `- next_role：%s`）" % (report, next_role))
        lines.append("- 依次运行 `python3 -I %s %s`（须 OK）与 `%s`，将 stdout 直接作为 Markdown 原样回复，严禁外层再套代码块。" %
                     (shlex.quote(str(KOS_DIR / "kos-report-lint.py")), shlex.quote(report), close_cmd))
    else:
        lines.append("- 报告写入：`<%s>/reports/code-%s-r1.md`（首行 DONE/PARTIAL/BLOCKED，写 `- next_role：Quality Reviewer`）" % (a.task, a.task.lower()))
        lines.append("- 依次运行 `python3 -I scripts/kos/kos-report-lint.py <报告路径>`（须 OK）与 `python3 scripts/kos/kos_handoff.py %s`，将 stdout 直接作为 Markdown 原样回复，严禁外层再套代码块。" % close_cmd)
    return "\n".join(lines) + "\n"


def quick_close_command(a, out: Path) -> str:
    report = Path(KOS_TASK_ROOT) / a.task / "reports" / ("code-%s-r1.md" % a.task.lower())
    action = QUICK_KINDS[a.kind]["handoff"]
    args = ["python3", str(KOS_DIR / "kos_handoff.py"), action, "--report", str(report)]
    if action == "relay-quality":
        args += ["--packet", str(out), "--base", a.base, "--repo", a.wt]
    return shlex.join(args)


def build_preflight_package(a, exec_path: Path, exec_sha: str) -> str:
    lines = []
    lines.append("Preflight；你不是 PM。")
    lines.append("")
    lines.append("# 预检包：%s（%s）" % (a.task, a.title))
    lines.append("")
    lines.append("- **任务**：%s" % a.task)
    lines.append("- 待检执行包：`%s` SHA-256 `%s`" % (exec_path, exec_sha))
    lines.append("- 核对：执行包结构与参数可执行性、冻结输入可达且哈希现场复算一致、依赖工具在位、worktree 与分支不存在、与在办任务零文件交集。")
    lines.append("- 严格只读：不改仓库、不建 worktree、不动 BOARD.md。")
    lines.append("- 报告写入：`<%s>/reports/preflight-%s-r1.md`（首行 PASS/FAIL，写 `- next_role：%s`）" % (a.task, a.task.lower(), a.role))
    if a.command == "quick":
        report = str(Path(KOS_TASK_ROOT) / a.task / "reports" / ("preflight-%s-r1.md" % a.task.lower()))
        action = "final" if a.grade == "doc-light" else "relay-exec"
        args = ["python3", str(KOS_DIR / "kos_handoff.py"), action, "--report", report]
        if action == "relay-exec":
            args += ["--packet", str(exec_path), "--base", a.base, "--repo", str(REPO_ROOT)]
        lines.append("- 过程静默；报告 lint 后运行 `%s`，将 stdout 直接作为 Markdown 原样回复，严禁外层再套代码块。" % shlex.join(args))
    return "\n".join(lines) + "\n"


def dispatch_block(task: str, name: str, role: str, package: Path, digest: str) -> str:
    return "\n".join([
        "```text",
        "任务：%s" % task,
        "角色：%s（%s）" % (name, role),
        "包路径：%s" % package,
        "SHA-256：%s" % digest,
        "```",
    ])


def main(argv: "list[str] | None" = None) -> int:
    parser = argparse.ArgumentParser(prog="kos_pack.py", description=__doc__.splitlines()[0])
    sub = parser.add_subparsers(dest="command", required=True)
    pack = sub.add_parser("pack", help="generate a task package (and optional preflight)")
    pack.add_argument("--task", required=True)
    pack.add_argument("--role", required=True)
    pack.add_argument("--grade", required=True, choices=GRADES)
    pack.add_argument("--title", required=True)
    pack.add_argument("--branch", required=True)
    pack.add_argument("--base", default=None, help="baseline commit (default: repo HEAD)")
    pack.add_argument("--wt", required=True, help="worktree path (must live under the KOS root)")
    pack.add_argument("--out", required=True, help="executor package output path")
    pack.add_argument("--input", action="append", default=[], help="frozen input file (repeatable; hashed live)")
    pack.add_argument("--allow", action="append", default=[], help="allowed write path inside the worktree (repeatable)")
    pack.add_argument("--step", action="append", default=[], help="task step (repeatable)")
    pack.add_argument("--focus", action="append", default=[], help="review focus item (repeatable)")
    pack.add_argument("--preflight-out", default=None)
    pack.add_argument("--board-tool", default=DEFAULT_BOARD_TOOL)
    pack.add_argument("--board-role", default="code")
    pack.add_argument("--no-lint", action="store_true", help="skip verification tools (debug only)")

    quick = sub.add_parser(
        "quick",
        help="one-shot packaging for the four standard kinds (diag/code-fix/doc-light/publish; O81)",
    )
    quick.add_argument("--task", required=True)
    quick.add_argument("--kind", required=True, choices=sorted(QUICK_KINDS),
                       help="standard packet kind (fixes grade + standard closing clauses)")
    quick.add_argument("--title", required=True)
    quick.add_argument("--role", default=None, help="override the kind's executor role")
    quick.add_argument("--branch", required=True)
    quick.add_argument("--base", default=None, help="baseline commit (default: repo HEAD, auto-read)")
    quick.add_argument("--wt", required=True, help="worktree path (must live under the KOS root)")
    quick.add_argument("--out", required=True, help="executor package output path")
    quick.add_argument("--input", action="append", default=[], help="frozen input file (repeatable; hashed live)")
    quick.add_argument("--allow", action="append", default=[], help="allowed write path inside the worktree (repeatable)")
    quick.add_argument("--goal", action="append", default=[],
                       help="product goal / acceptance bound written by the PM (repeatable; becomes task steps)")
    quick.add_argument("--preflight-out", default=None)
    quick.add_argument("--board-tool", default=DEFAULT_BOARD_TOOL)
    quick.add_argument("--board-role", default=None, help="override the kind's board role")
    quick.add_argument("--no-lint", action="store_true", help="skip verification tools (debug only)")
    quick.add_argument("--allow-unregistered-suggestions", action="store_true",
                       help="explicitly bypass the publish suggestion gate")
    a = parser.parse_args(argv)

    if a.command == "quick":
        if not a.goal:
            return die(2, "quick 需要至少一个 --goal（PM 写的产品目标/验收边界）")
        a.grade = QUICK_KINDS[a.kind]["grade"]
        a.role = a.role or QUICK_KINDS[a.kind]["role"]
        a.board_role = a.board_role or QUICK_KINDS[a.kind]["board"]
        a.focus = ["按任务包复核重点逐条核验；防套壳：报告必须基于真实工具输出"]
        a.step = build_quick_steps(a.goal, a.kind)

    if not a.allow:
        return die(2, "需要至少一个 --allow（允许写入路径）")
    if not a.step:
        return die(2, "需要至少一个 --step（任务步骤）")
    if not a.input:
        return die(2, "需要至少一个 --input（冻结输入文件）")

    base = a.base
    if not base:
        proc = subprocess.run(["git", "-C", str(REPO_ROOT), "rev-parse", "HEAD"], capture_output=True, text=True)
        if proc.returncode != 0:
            return die(2, "无法读取仓库 HEAD：+ proc.stderr")
        base = proc.stdout.strip()
    a.base = base

    input_pairs = []
    for raw in a.input:
        p = Path(os.path.abspath(os.path.expanduser(raw)))
        if not p.is_file():
            return die(2, "冻结输入不存在或不是文件：%s" % p)
        input_pairs.append((str(p), sha256_file(p)))

    if a.command == "quick" and a.kind == "publish" and not a.allow_unregistered_suggestions:
        task_root = Path(os.environ.get("KOS_HOME", KOS_TASK_ROOT))
        task_dir = task_root / a.task
        check = subprocess.run([sys.executable, "-B", str(KOS_DIR / "kos_suggest.py"),
                                "check-task", str(task_dir)], capture_output=True, text=True)
        if check.returncode:
            sys.stderr.write(check.stdout + check.stderr)
            return die(1, "发布包未生成：请先用 kos_suggest.py add 登记报告意见（或显式豁免）")

    out = Path(os.path.abspath(os.path.expanduser(a.out)))
    out.parent.mkdir(parents=True, exist_ok=True)
    close_cmd = quick_close_command(a, out) if a.command == "quick" else "final --report <报告路径>"
    out.write_text(build_exec_package(a, input_pairs, close_cmd), encoding="utf-8")
    exec_sha = sha256_file(out)

    rc = verify_and_lint(out, base, str(REPO_ROOT), not a.no_lint)
    if rc is not None:
        return rc

    preflight_path = None
    preflight_sha = None
    if a.preflight_out:
        preflight_path = Path(os.path.abspath(os.path.expanduser(a.preflight_out)))
        preflight_path.parent.mkdir(parents=True, exist_ok=True)
        preflight_path.write_text(build_preflight_package(a, out, exec_sha), encoding="utf-8")
        preflight_sha = sha256_file(preflight_path)
        rc = verify_and_lint(preflight_path, base, str(REPO_ROOT), not a.no_lint)
        if rc is not None:
            return rc

    picked = board_pick_with_reserve(a.board_tool, a.board_role, reserve_task=a.task)
    if picked is None:
        return die(3, "kos-board pick 失败（--board-tool %s --board-role %s）；不输出派发块" % (a.board_tool, a.board_role))
    name, pick_line = picked
    print("包：%s" % out)
    print("SHA-256：%s" % exec_sha)
    print("pick：%s" % pick_line)
    if preflight_path is not None:
        preflight_pick = board_pick_with_reserve(a.board_tool, "preflight", reserve_task=a.task)
        if preflight_pick is None:
            return die(3, "preflight pick 失败；不输出 preflight 派发块")
        print("预检包：%s" % preflight_path)
        print("预检包 SHA-256：%s" % preflight_sha)
        print()
        print(dispatch_block(a.task, preflight_pick[0], "Preflight", preflight_path, preflight_sha))
        print()
    print(dispatch_block(a.task, name, a.role, out, exec_sha))
    return 0


if __name__ == "__main__":
    sys.exit(main())
