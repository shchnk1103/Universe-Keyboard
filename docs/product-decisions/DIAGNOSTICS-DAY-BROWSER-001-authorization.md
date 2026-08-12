# Product Decision: DIAGNOSTICS-DAY-BROWSER-001 — 按日期浏览与有界最近窗口

**Decision ID:** `PD-DIAGNOSTICS-DAY-BROWSER-001`
**Lifecycle status:** `Accepted` — 授权设计、实现与本地验证
**Date / timezone:** `2026-08-12 Asia/Shanghai`
**Assignment:** [`DIAGNOSTICS-DAY-BROWSER-001`](../assignments/diagnostics-day-browser-001.md)
**Architecture proposal:** [ADR 0028](../architecture/decisions/0028-diagnostics-calendar-query-and-bounded-preview.md)

## Current Status (KOS 2.1 M-01)

| Field | Value |
|---|---|
| **Lifecycle** | `Accepted` — Human Product Lead 已授权继续 |
| **Phase** | live-root revision 屏障完成，等待再次独立复核 |
| **Non-claims** | 不改变 Extension 写入热路径、7 天/100 MiB retention、隐私字段、G2 或候选栏；不宣称超预算预览是完整历史 |
| **Next** | Architecture / Quality 复核最终 remediation；不由 Executor 自授通过 |
| **Residuals** | writer 跨小时 batch、完整超预算深分页与真机门仍不在本轮授权内 |

---

## Decision

Human Product Lead 接受“按日期浏览、分段存储、有界查询、最新结果优先、完整性显式可见”的产品方向，并明确希望 UI 现代且美观。

本阶段复用 v1 已存在的“每 process 独占、按 UTC 小时和 1 MiB 轮转”的安全分段，不迁移为跨进程共享日文件。Main App 在读取层把这些 UTC 分段映射为本地日历日期：优先尝试该日的严格完整快照；若单日仍超过安全预算，展示明确标记为不完整的有界最近窗口，而不是空白页面。

## Non-goals

- 不让 Main App 与 Keyboard Extension append 同一个日文件。
- 不删除或自动迁移已有 v1 journal，不改变 generation clear、lease、lock、tombstone 与 reclaim 围栏。
- 不提高 5 MiB / 10,000 事件安全预算，不把最近窗口描述成严格完整结果。
- 不实现网络、上传、后台任务、自由文本字段、候选栏或万象模型 G2 改动。
- 不在本阶段承诺任意体量历史都可通过严格全局顺序完整翻页；该能力需要后续磁盘索引或外部归并设计。

## Authorization source

Human Product Lead, in-session `2026-08-12 Asia/Shanghai`：认可按日期与有界查询建议，要求 UI 现代美观，并明确指示“继续吧”。

独立 Architecture / Quality 首轮审查均为 `Fail` 后，Human Product Lead 同日明确指示“授权你先进行最小修复”。该授权绑定为冻结 watermark、typed 日期发现失败、请求 revision/旧请求失效、跨午夜跟随、partial 专用空态及确定性测试；不授权修改 writer 分段。

## Revalidation triggers

如实现需要改动 Extension hot path、日志字段/隐私合同、retention、generation、跨进程锁序、真实文件迁移、G2、候选栏或真机环境，必须停止并重新取得 Product 授权。
