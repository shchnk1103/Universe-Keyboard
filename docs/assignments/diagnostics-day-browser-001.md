# Assignment: DIAGNOSTICS-DAY-BROWSER-001 — 按日期浏览与有界最近窗口

Policy version: 1.0.0
Repository Change Type: `Contract` + `Implementation` + `Documentation`

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Completed` — Executor 实现与 CI 对齐 Simulator 门禁完成；独立 Architecture / Quality 复核待办 |
| **Phase** | Main-App-only 日期查询、超预算最近窗口和现代日期导航 UI 已完成 |
| **Non-claims** | 不改变 Extension 写入、retention/clear/隐私合同；不把部分预览称为完整历史；不处理 G2、候选栏或真机 |
| **Next** | 交给 Architecture / Quality 独立复核；真机视觉与时区切换验证作为后续产品证据 |
| **Residuals** | 完整超预算历史深分页列为后续架构工作，不在本阶段软关闭 |

---

## Authority

- Assignment Authority: Product Lead
- Decision Source / Date: [`PD-DIAGNOSTICS-DAY-BROWSER-001`](../product-decisions/DIAGNOSTICS-DAY-BROWSER-001-authorization.md), `2026-08-12 Asia/Shanghai`
- Product Approver: Human Product Lead（本会话）

## Boundary

- Scope:
  1. 在 `DiagnosticsJournalReader` 增加 Main-App-only 的本地日历日期发现与日期范围查询，不改变 writer 格式。
  2. 单日严格快照超预算时返回显式 `partial recent window`，在总读取预算内公平采样相关分段尾部并按既有 comparator 排序。
  3. 诊断页增加原生、紧凑、可访问的日期导航与完整性提示；保留搜索、分类、复制、加载更多与可靠清空。
  4. 为 UTC→本地日期映射、日期隔离、超预算预览和 Store/UI 状态补充测试。
- Non-goals:
  - 不新增 `Diagnostics/v2`，不迁移或重写已有 journal，不共享写日文件。
  - 不改变 Extension hot path、writer segment、1 MiB 轮转、generation clear、7 天/100 MiB retention 或字段 allowlist。
  - 不声称超预算预览包含全部事件；不实现磁盘索引式完整深分页。
  - 不触碰 RimeBridge、万象 G2、候选栏或真机。
- Required Inputs:
  - [`PD-DIAGNOSTICS-DAY-BROWSER-001`](../product-decisions/DIAGNOSTICS-DAY-BROWSER-001-authorization.md)
  - [ADR 0027](../architecture/decisions/0027-enterprise-local-diagnostic-observability.md) 与 [ADR 0028 proposal](../architecture/decisions/0028-diagnostics-calendar-query-and-bounded-preview.md)
  - [`DIAGNOSTICS-READ-RECOVERY-001`](diagnostics-read-recovery-001.md)
  - `DiagnosticsJournalReader`、诊断 source/store/view 与现有 UI style guide。

## Assignment

- Domain Owner: 📱 App & Data Operations Maintainer（诊断 repository 与 Main App 浏览体验）
- Executor: Current Codex（Human Product Lead 于 `2026-08-12 Asia/Shanghai` 明确授权继续）
- Environment Executor: Current Codex（静态检查、单元测试与 iOS Simulator）
- Human Dependency: Not Applicable — 当前阶段不需要真机、账号、凭据或外部服务。
- Architecture Reviewer: 🏛️ Architecture & Knowledge Steward（独立复核 ADR 0027 围栏、partial 完整性语义与后续索引边界）
- Quality Reviewer: 🧪 Quality, Performance & Release Maintainer（独立复核日期/时区、预算、UI 状态和回归证据）

## Gates

- Entry Criteria:
  - Product Decision、Assignment 与 ADR proposal 已记录且无 `UNKNOWN`。
  - 实现继续位于隔离诊断 worktree；G2 工作区未被带入。
  - 已确认 v1 writer 本身已有 UTC 小时 + 体积轮转，无需存储迁移即可先实现按日产品体验。
- Exit Criteria:
  - 用户可在可用本地日期间切换；日期范围不会混入范围外事件。
  - 严格快照在预算内保持原语义；超预算时显示非空的有界最近窗口或明确无可展示记录，并标明“不完整”。
  - UI 使用现有 tokens/semantic colors，支持 light/dark、Dynamic Type、VoiceOver 和 ≥44 pt 触点。
  - Core、Main App 定向测试、完整相关 Simulator 测试、Swift format 及 Debug/Release build 有 Executor-recorded 证据。
- Stop Conditions:
  - 需要共享日文件、改变跨进程锁序/retention/clear/隐私字段，或让 Extension 执行枚举、日期格式化、索引或等待。
  - 需要把有界最近窗口描述为完整、严格或可用于 Release 结论。
  - 需要触碰 G2、候选栏或真机。

## Handoff

- Handoff Target: 🏛️ Architecture & Knowledge Steward → 🧪 Quality, Performance & Release Maintainer → Human Product Lead
- Required Handoff Content: ADR mapping、diff、日期/时区和预算测试、Simulator receipts、完整性非主张、后续磁盘索引 residual。
- Revalidation Trigger: writer/storage 格式、隐私字段、retention、clear、Extension hot path、G2/候选栏/真机或完整深分页范围发生变化。

## History

- `2026-08-12 Asia/Shanghai`: Human Product Lead 接受日期浏览与有界查询方向并授权继续；Assignment 完成 `Assigned → Acknowledged → Ready` 后进入 `Active`。
- `2026-08-12 Asia/Shanghai`: Executor 完成实现、自动化与 CI 对齐 Simulator 门禁，记录[执行证据](../evidence/diagnostics-day-browser-001-execution-evidence-2026-08-12.md)并将生命周期收口为 `Completed`；ADR Acceptance 与独立 Quality 结论仍未授予。
