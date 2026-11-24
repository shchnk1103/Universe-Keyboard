"""kos_render.py -- single source for KOS dispatch / final / entry block rendering.

O92 / KOS-RELAY-UNIFY-CORE-001: the block formats previously hand-joined in
kos_pack.py, kos_handoff.py render_three_line and cmd_relay_quality all come
from here so the three call sites stay byte-identical. Stdlib only.

cmd_final uses final_block with the PM as the hand-back owner and
prints any auto-picked employee as a separate suggestion block.
"""
from __future__ import annotations

PM_HANDBACK = "Jack（PM）"


def dispatch_block(task: str, name: str, role: str, package, digest: str,
                   auth_line: str | None = None, fenced: bool = True) -> str:
    """Dispatch block: 任务/角色/包路径/SHA-256 (+ auth_line, e.g. 授权，直接执行)."""
    lines = [
        "任务：%s" % task,
        "角色：%s（%s）" % (name, role),
        "包路径：%s" % package,
        "SHA-256：%s" % digest,
    ]
    if auth_line:
        lines.append(auth_line)
    if fenced:
        return "```text\n%s\n```" % "\n".join(lines)
    return "\n".join(lines)


def final_block(role: str, detail: str, report, digest: str, fenced: bool = True) -> str:
    """Hand-back block: 交回 uses the role given (cmd_final passes the PM)."""
    lines = [
        "交回：%s" % role,
        "事项：%s" % detail,
        "报告：%s" % report,
        "SHA-256：%s" % digest,
    ]
    if fenced:
        return "```text\n%s\n```" % "\n".join(lines)
    return "\n".join(lines)


def entry_block(role: str, task: str, entry, digest: str, fenced: bool = True) -> str:
    """Next-station entry block: 派给 + auth line for a pre-read entry file."""
    lines = [
        "派给：%s" % role,
        "任务：%s" % task,
        "开工文档：%s" % entry,
        "SHA-256：%s" % digest,
        "授权，直接执行",
    ]
    if fenced:
        return "```text\n%s\n```" % "\n".join(lines)
    return "\n".join(lines)
