# Assignment: DIAGNOSTICS-READ-RECOVERY-001 — 诊断超预算读取恢复

Policy version: 1.0.0
Repository Change Type: `Implementation` + `Documentation`

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Completed` |
| **Phase** | Executor 实现与本地质量门已完成；等待独立 Quality reverify |
| **Non-claims** | 不处理候选栏、G2、真机或 Release；不改变 ADR 0027 的预算、排序、保留与隐私合同 |
| **Next** | 🧪 Quality, Performance & Release Maintainer 独立复核执行证据与状态转换 |
| **Residuals** | None |

---

## Authority

- Assignment Authority: Product Lead
- Decision Source / Date: [`PD-DIAGNOSTICS-READ-RECOVERY-001`](../product-decisions/DIAGNOSTICS-READ-RECOVERY-001-authorization.md), `2026-08-12 Asia/Shanghai`
- Product Approver: Human Product Lead（本会话）

## Boundary

- Scope:
  1. 当 v1 journal 因快照超出 5 MiB 或 10,000 事件预算而无法展示记录时，诊断页仍提供用户确认后的清空入口。
  2. 将清空结果显式返回给 Store；只有 generation clear 与 legacy clear 都成功时才呈现成功后的空状态，失败时保留可恢复提示。
  3. 修正超预算提示，使其只指向当前实现能保证的恢复动作。
  4. 添加 Main App 状态与 source 回归测试，并执行相关 Simulator 质量门。
- Non-goals:
  - 不修改候选栏触摸、Keyboard Extension、KeyboardCore 输入语义、RimeBridge 或万象模型 G2。
  - 不放宽读取预算，不改变严格全局最新优先分页或 cursor invalidation。
  - 不改变 7 天 / 100 MiB retention、generation clear、App Group ownership、日志字段或隐私合同。
  - 不连接真机、不安装真机 build、不创建 Release 或 Product Gate 结论。
- Required Inputs:
  - [`PD-DIAGNOSTICS-READ-RECOVERY-001`](../product-decisions/DIAGNOSTICS-READ-RECOVERY-001-authorization.md)
  - [`TD-013-DIAGNOSTICS-V1-P1`](td-013-diagnostics-v1-p1.md)
  - [ADR 0027](../architecture/decisions/0027-enterprise-local-diagnostic-observability.md)
  - 当前 `DiagnosticsLogSource`、`DiagnosticsStore`、`DiagnosticsView` 及相关测试。

## Assignment

- Domain Owner: 📱 App & Data Operations Maintainer（Main App 诊断查询与恢复表面）
- Executor: Current Codex（Human Product Lead 于 `2026-08-12 Asia/Shanghai` 明确授权）
- Environment Executor: Current Codex（仅本地静态检查、自动化测试与 Simulator）
- Human Dependency: Not Applicable — 当前范围不需要真机、账号、凭据或外部服务。
- Architecture Reviewer: Not Applicable — 修复保持 ADR 0027 的既有预算、排序、清除、保留与 ownership 合同，不引入新的架构决定。
- Quality Reviewer: 🧪 Quality, Performance & Release Maintainer（独立复核状态转换与相关 Simulator 证据）

## Gates

- Entry Criteria:
  - Product Decision 与本 Assignment 已记录且无 `UNKNOWN`。
  - 独立 worktree 基于最新 `origin/main`，G2 工作区未被带入。
  - 已确认根因为超预算状态隐藏清空入口及清空失败被静默吞掉，而非候选栏或 RIME runtime。
- Exit Criteria:
  - 超预算空页面可发起清空，普通空日志不会无条件开放破坏性动作。
  - source 清空成功/失败有显式结果，Store 仅在成功后切换为空状态，失败时显示可操作提示。
  - 自动刷新不会在清空进行中竞争更新页面状态。
  - 定向测试、Swift format 与 Main App Simulator 测试通过；未执行的质量门及原因明确记录。
- Stop Conditions:
  - 需要改变 ADR 0027 合同、删除尚未获授权的数据、记录自由文本或进入 Extension 热路径。
  - 需要触碰 G2 分支、其未提交文件、RimeBridge、候选栏或真机环境。
  - 发现清空行为无法在不扩大 user-data 合同的前提下可靠验证。

## Handoff

- Handoff Target: 🧪 Quality, Performance & Release Maintainer → Human Product Lead
- Required Handoff Content: 隔离基线、diff、状态转换测试、Simulator 命令与结果、未执行验证、文档影响与残余风险。
- Revalidation Trigger: 范围进入候选栏/G2/Extension/RimeBridge/真机，或需要改变读取预算、retention、generation 与隐私合同。

## History

- `2026-08-12 Asia/Shanghai`: Human Product Lead 明确授权最小诊断恢复修复，并要求与万象模型 G2 工作隔离；Assignment 完成 `Assigned → Acknowledged → Ready` 后进入 `Active`。
- `2026-08-12 Asia/Shanghai`: Executor 完成实现、定向 11 tests、完整 Main App 156 tests + Keyboard 6 tests，以及 Debug/Release Simulator build；证据见 [`execution evidence`](../evidence/diagnostics-read-recovery-001-execution-evidence-2026-08-12.md)。Lifecycle 进入 `Completed`，不冒充独立 Quality review 或真机结论。
