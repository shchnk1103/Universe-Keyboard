# Product Decision: TD-013-DIAGNOSTICS-V1-P1 — 本地诊断 P1 规划授权

**Decision ID:** `PD-TD-013-DIAGNOSTICS-V1-P1`
**Lifecycle status:** `Accepted` — P1 已完成独立复核，Human Product Gate 已通过
**Date / timezone:** `2026-08-11 Asia/Shanghai`
**Parent debt:** [`TD-013`](../TECH_DEBT.md#td-013-diagnostics-v1-p1-查询生命周期与迁移硬化)
**Assignment:** [`TD-013-DIAGNOSTICS-V1-P1`](../assignments/td-013-diagnostics-v1-p1.md)

## Current Status (KOS 2.1 M-01)

| Field | Value |
|---|---|
| **Lifecycle** | `Accepted` — P1 Assignment 已完成并通过 Human Product Gate |
| **Phase** | Architecture R3 `Pass`、Quality R3 `Pass with conditions` 后，Human Product Lead 于本会话确认“本次可以通过” |
| **Non-claims** | 不授权 legacy 删除、远程诊断、真机性能或 Release；每个新增持久化字段仍受 allowlist 审查 |
| **Next** | TD-013 P2 residual 依技术债和后续独立 Assignment 处理 |
| **Residuals** | 真机三模式性能、完整文件系统 fault injection、广泛 legacy cohort migration/删除；不由本次 Gate 关闭 |

---

## Decision

Product 授权为 [`TD-013`](../TECH_DEBT.md#td-013-diagnostics-v1-p1-查询生命周期与迁移硬化) 建立独立 P1 Assignment 与实施计划。该授权的直接产物是可审查的范围、现状基线、验收条件、停止条件和交接，而不是实现本身。

后续实现若获单独的明确写代码指令，只能在以下边界内进行：

1. 将 v1 查询补强为全局、确定性的最新优先分页，并把 generation 或被回收段导致的 cursor 失效明确呈现给调用方；不得静默混入新事件或旧 generation。
2. 将 retention 从仅启动时的一次尝试扩展为 Main App 专属、合并且不影响 Extension 的受控 cadence；活动 writer、lease、tombstone 与同一 identity lock 的 ADR 0027 围栏保持不变。
3. 补齐已有 journal failure/drop 行为的受控归因与故障注入覆盖。任何不可用状态只能降低可观测性，不能等待、阻塞或改变输入/RIME 语义。
4. 审计 legacy `Logger(String)` producer；任何迁移必须逐 cohort 经过 typed allowlist 与隐私审查。未审计自由文本不得写入 v1。移除 `rime_diag_log` 只读回退需要一个后续、独立的 Product 决策。

## Non-goals

- 在本规划授权下改动生产代码、测试代码、App Group 数据或已有用户日志。
- 上传、自动分享、同步或导出到设备外的诊断数据。
- 记录键入文本、宿主文本、preedit、候选正文、YAML、RIME 原始日志、路径或任意自由文本。
- 改变 7 天 / 100 MiB 本地保留上限、Full Access 语义、RIME 部署边界或 Keyboard Extension 的输入热路径。
- 将 P0 已有 Simulator、CI 或真机观察改述为 P1 或 Release/Product Gate 证据。

## Authorization source

Human Product Lead, in-session `2026-08-11 Asia/Shanghai`：先授权 P1 的 KOS 准备，随后在收到已列出的任务责任建议后明确指示“开始执行”。该确认同时指定：📱 App & Data Operations Maintainer 为 primary Domain Owner；🏛️ Architecture & Knowledge Steward 与 🧪 Quality, Performance & Release Maintainer 分别为独立 Architecture / Quality Reviewer；Current Codex 为 Executor。实现不得越过本 Decision 与 Assignment 的非目标。

## Product Gate decision

Human Product Lead, in-session `2026-08-11 Asia/Shanghai`：在了解 Product Gate 含义和当前独立复核结论后确认“本次可以通过”。该决定接受 TD-013 P1 的产品范围和已登记 P2 residual，允许本 Assignment 收口；它不是 Release、上架、真机性能或 legacy 删除授权。

## Revalidation triggers

如出现下列任一情况，必须回到 Product Lead 重新确认范围：需要改变诊断保留/清除语义；需要新增可持久化字段；需要删除或迁移现有用户日志；需要 BackgroundTask/通知/网络能力；或 Architecture / Quality 发现 ADR 0027 的围栏不足以承载拟议实现。
