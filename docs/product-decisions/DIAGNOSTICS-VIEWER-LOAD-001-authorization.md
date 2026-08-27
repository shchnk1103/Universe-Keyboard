# Product Decision: DIAGNOSTICS-VIEWER-LOAD-001 — 诊断查看加载态与有界读取

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "PD-DIAGNOSTICS-VIEWER-LOAD-001",
  "record_type": "decision",
  "title": "Diagnostics viewer load state before Wanxiang retry",
  "status": "accepted",
  "updated_at": "2026-08-27T19:50:00+08:00",
  "revalidation_triggers": ["scope_changed", "authority_revoked"],
  "decision": {
    "authority_role": "Human Product Owner",
    "decision_source": "in-session 2026-08-27 Asia/Shanghai diagnostics-first sequence",
    "scope": "Record and later implement bounded diagnostics viewer load UX",
    "outcome": "Assignment established; implementation still requires a later explicit authorization",
    "expires_at": null
  }
}
```

**Decision ID:** `PD-DIAGNOSTICS-VIEWER-LOAD-001`
**Date / timezone:** `2026-08-27 Asia/Shanghai`
**Assignment:** [`DIAGNOSTICS-VIEWER-LOAD-001`](../assignments/diagnostics-viewer-load-001.md)

## Current Status

| Field | Value |
|---|---|
| Status | accepted |

---

## Decision

Human Product Lead 接受先前讨论的顺序，并把它收成当前正式工作：

1. 先修复主 App 诊断查看：加载中不得伪装成「暂无诊断日志」；长时间读取必须有可见进度；主 App 读取不得把进程打到异常 CPU / GB 级内存。
2. 查看恢复后，用「记录诊断数据」开启、首屏高保真关闭的路径，再做万象下载失败分类。
3. 在分类完成前，不授权猜修方案下载，不授权合并 PR #83。

GitHub Swift 6 Quality 已绿，只关闭 INTEGRITY-001 的稳定工具链编译门，不改变上述顺序。

## Non-goals

- 不改变 Keyboard Extension 写入热路径、v1 writer 分段、generation clear、7 天 / 100 MiB retention 或隐私字段 allowlist。
- 不提高 5 MiB / 10,000 事件安全预算来“解决”加载。
- 不把首屏高保真窗口扩成常开，也不用它诊断方案下载。
- 不在本 Assignment 内修改方案下载、安装、回退或完整性校验。
- 不授权 merge、TestFlight 或 Release。

## Authorization source

Human Product Lead, in-session `2026-08-27 Asia/Shanghai`：同意先修诊断查看再复测万象；确认 GitHub CI 已绿后指示按 KOS 推进，需要则先处理 CI。CI 处理限于记录证据与禁止合并。

## Revalidation triggers

若实现需要改 writer / Extension hot path、提高读取预算、改方案交付合同、合并 PR #83，或把空态误报当作“确实没有日志”而不加加载态，必须停止并重新取得 Product 授权。
