# Assignment: TD-013-DIAGNOSTICS-V1-P1 — Diagnostics v1 查询、生命周期与迁移硬化

Policy version: 1.0.0
Repository Change Type: `Contract` + `Documentation` + `Implementation`

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Completed` |
| **Phase** | 独立 Architecture `Pass`、Quality `Pass with conditions`；Human Product Gate 已通过 |
| **Non-claims** | 不宣称 Release/真机性能已验证，或 legacy 文本已迁移/删除 |
| **Next** | P2 residual 由 TD-013 技术债和新的 Assignment 处理；任何 legacy cohort migration 需新 Assignment |
| **Residuals** | [`TD-013`](../TECH_DEBT.md#td-013-diagnostics-v1-p1-查询生命周期与迁移硬化)；P0 Gate 见 [`DIAGNOSTICS-OBSERVABILITY-001`](diagnostics-observability-001.md) |

Current execution evidence: [`TD-013 P1 execution evidence`](../evidence/td-013-diagnostics-v1-p1-execution-evidence-2026-08-11.md). Historical first-round conclusions remain [`Architecture: Fail`](td-013-diagnostics-v1-p1-architecture-review.md) and [`Quality: Fail`](td-013-diagnostics-v1-p1-quality-review.md); the corrective re-reviews are recorded below. Passing Simulator receipts do not themselves grant a Product Gate.

---

## Authority

- Assignment Authority: Product Lead
- Decision Source / Date: [`PD-TD-013-DIAGNOSTICS-V1-P1`](../product-decisions/TD-013-DIAGNOSTICS-V1-P1-authorization.md), `2026-08-11 Asia/Shanghai`
- Product Approver: Human Product Lead（本会话）

## Boundary

- Scope:
  1. 基于 ADR 0027 和当前实现，定义严格的全局最新优先分页、显式 cursor invalidation 与不可变查询水位验收。
  2. 定义 Main-App-only retention cadence、writer/reclaim 竞争与失败重试矩阵，不改变 Extension hot path。
  3. 补强内容无关的 health/drop failure attribution、恢复语义和可注入故障测试。
  4. 盘点 legacy `Logger(String)` producer，按隐私风险和可迁移性制定 cohort 计划；仅在审查后的 cohort 中迁移。
  5. 维护受影响的 Assignment、技术债、计划、调试/隐私/性能/发布文档，并完成独立 Architecture 与 Quality 交接。
- Non-goals:
  - 不在未经审查的 cohort 中改动 legacy producer 或删除历史日志。
  - 不改变 ADR 0027 的 7 天 / 100 MiB、App Group ownership、typed allowlist、清除 generation 或本地-only 隐私合同。
  - 不迁移任何未完成隐私审查的自由文本；不删除 `rime_diag_log` 回退；不把日志上传或同步。
  - 不重新打开 P0 的 Product Gate，也不借此宣称设备或 Release 结论。
- Required Inputs:
  - [ADR 0027](../architecture/decisions/0027-enterprise-local-diagnostic-observability.md)、[ADR 0003](../architecture/decisions/0003-shared-container-ownership.md)、[ADR 0007](../architecture/decisions/0007-full-access-and-privacy-boundary.md)
  - [`DIAGNOSTICS-OBSERVABILITY-001`](diagnostics-observability-001.md)、[`TD-013`](../TECH_DEBT.md#td-013-diagnostics-v1-p1-查询生命周期与迁移硬化)
  - [`td-013-diagnostics-v1-p1-plan.md`](../plans/td-013-diagnostics-v1-p1-plan.md)
  - 当前 `DiagnosticsJournalReader`、`DiagnosticsJournalIngress`、`DiagnosticsJournalRetentionCoordinator` 和诊断 UI 的只读基线审计。

## Assignment

- Domain Owner: 📱 App & Data Operations Maintainer（诊断 repository、retention 与设置/查询表面）
- Executor: Current Codex（Human Product Lead 于 `2026-08-11 Asia/Shanghai` 明确授权实现）
- Environment Executor: Current Codex（本地静态审计、单元测试与 Simulator；任何真机步骤另行在证据任务中指定）
- Human Dependency: Not Applicable — 当前阶段不需要真机、账号、凭据或外部服务；未来若 P1 改变可见诊断体验，Product Gate/真机证据须作为独立明示依赖。
- Architecture Reviewer: 🏛️ Architecture & Knowledge Steward（独立审查 ADR 0027、跨 target 和持久化 contract）
- Quality Reviewer: 🧪 Quality, Performance & Release Maintainer（独立审查测试矩阵、热路径与证据结论）

## Gates

- Entry Criteria:
  - 本 Assignment、Product Decision 和 P1 plan 已发布并相互链接。
  - 当前基线的已实现能力与 P1 缺口已区分，不以技术债旧描述代替代码事实。
  - Product Lead 已指定 primary Domain Owner、独立 Architecture/Quality Reviewer，并授权实现。
- Exit Criteria:
  - 每个获授权 P1 phase 都有实现、定向测试与完整本地 CI 证据，且没有将文件/锁/等待带入 Extension 热路径。
  - 全局分页、cursor 失效、reclaim/retention 竞争、故障归因/恢复与 selected legacy cohort 有可复现的自动化证据。
  - 所有新增字段通过 typed allowlist/privacy review；P1 文档影响审查完成。
  - Architecture 与 Quality 各自给出独立结论；所有条件残余按 Assignment Policy M-03 处置；Product Lead 作出 Product Gate 决定。
- Stop Conditions:
  - 需要记录或恢复自由文本，或诊断需要离开设备。
  - 拟议行为要求 Extension 在按键/生命周期路径等待文件、锁、JSON、目录扫描或跨进程协调。
  - 需要改变 clear generation、lease/tombstone/fence、保留上限或 shared-container ownership，而 ADR 0027 未覆盖。
  - 任一新增持久化字段、删除 legacy 数据或可见语义没有明确 Product / Architecture 边界。
  - Assignment 角色、独立性或用户的实现授权失效。

## Handoff

- Handoff Target: 🏛️ Architecture & Knowledge Steward → 🧪 Quality, Performance & Release Maintainer → Human Product Lead
- Required Handoff Content:
  - 每 phase 的 diff、基线与验收映射；新增字段 allowlist 与隐私审计；完整 CI/Simulator 命令与结果；需要真机的主张与未覆盖条件；残余 ID、owner 与 disposition。
- Revalidation Trigger:
  - 代码/测试范围超出 P1 plan；ADR 0027 或隐私合同改变；新增 external/background capability；legacy migration 从审计扩大到删除；或 Product Lead 改变优先级/验收目标。

## History

- `2026-08-11 Asia/Shanghai`: Product Lead 授权 P1 的 KOS 准备；Assignment initially stayed `Assignment Pending` until task-level responsibility was explicit.
- `2026-08-11 Asia/Shanghai`: Product Lead 确认 Domain Owner、独立 Architecture / Quality Reviewer，并明确指示开始执行。Assignment completed `Assigned → Acknowledged → Ready` and entered `Active`。
- `2026-08-11 Asia/Shanghai`: 完成 Phase A、Phase B cadence、Phase C 有限 I/O failure reason，以及 Phase D inventory/P0-style 摘要收敛；尚未完成完整 CI 或独立 review，且未开始广泛 legacy cohort migration，Lifecycle 保持 `Active`。
- `2026-08-11 Asia/Shanghai`: 独立 Architecture 与 Quality review 均返回 `Fail`；快照线性化和硬上限等 blocking findings 已写入独立 review 记录。Assignment 保持 `Active`，不得进入 Product Gate。
- `2026-08-11 Asia/Shanghai`: 修复 generation-wide snapshot fence、v1 unavailable 回退、Core hard bounds、retention fencing 与证据记录后，独立 Architecture re-review 为 `Pass`；独立 Quality re-review 为 `Pass with conditions`。其 P2 条件仍登记于 `TD-013`。
- `2026-08-11 Asia/Shanghai`: Human Product Lead 明确通过 Product Gate。本 Assignment `Completed`；该决定不替代 Release、真机性能或 legacy 删除授权。
