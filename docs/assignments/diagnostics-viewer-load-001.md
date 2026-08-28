# Assignment: DIAGNOSTICS-VIEWER-LOAD-001 — 诊断查看加载态与有界读取

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "DIAGNOSTICS-VIEWER-LOAD-001",
  "record_type": "assignment",
  "title": "Diagnostics viewer load state and bounded read",
  "lifecycle": "closed",
  "current_phase": "Human Product Gate passed; PR #85 merged as 420322b; residual scheme-delivery observability handed off to TD-015",
  "authorization_action": "implement",
  "updated_at": "2026-08-27T22:34:00+08:00",
  "revalidation_triggers": ["scope_changed", "implement_authorization_changed"],
  "authorization_refs": ["AUTH-DIAGNOSTICS-VIEWER-LOAD-001-IMPLEMENT"],
  "parent_refs": ["KOS-UPGRADE-UK-001"],
  "responsibilities": {
    "domain_owner": "Main App UI",
    "executor": "Current Grok session",
    "environment_executor": "Current Grok session",
    "human_dependency": "Human Product Owner",
    "architecture_reviewer": "Independent architecture_review subagent",
    "quality_reviewer": "Independent quality_review subagent",
    "product_approver": "Human Product Owner"
  }
}
```

**Policy version:** `1.0.0`
**Repository Change Type:** `Implementation` + `Documentation`
**Blocks:** scheme-download classification retry on PR #83 until this viewer is readable.

## Current Status

| Field | Value |
|---|---|
| Lifecycle | closed |
| Current Phase | Human Product Gate passed; PR #85 merged as 420322b; residual scheme-delivery observability handed off to TD-015 |
| Material non-claims | No PR #83 merge; no scheme-download fix; no raised read budget; Human 观察的 `<100 MB` 不是新的正式内存合同；high-fidelity 未纳入本 Gate |
| Next handoff / decision | 万象 journal 缺口见 [`TD-015`](../TECH_DEBT.md#td-015-方案交付日志未进入诊断-v1-journal)；再次分类万象失败前另立 Assignment，不在本任务里修。 |
| Residuals | Architecture / Quality 的 P2 处置保持原记录；KOS 升级 AUTH 卫生仍由 [`TD-014`](../TECH_DEBT.md#td-014-kos-22-auth-consumption_state-卫生) 追踪 |

---

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** [`PD-DIAGNOSTICS-VIEWER-LOAD-001`](../product-decisions/DIAGNOSTICS-VIEWER-LOAD-001-authorization.md), `2026-08-27 Asia/Shanghai`
- **Product Approver:** Human Product Owner acting as Product Lead

## Boundary

- **Scope:**
  1. 诊断日志页必须区分：正在加载、筛选无匹配、有界窗口无完整记录、以及真正没有可展示 journal。
  2. 根加载、日期切换和长时间 catalog/page 读取必须有可见进度或忙碌态；不得在加载完成前显示「暂无诊断日志」。
  3. 主 App 读取路径保持 ADR 0027 的 5 MiB / 10,000 事件预算；1 秒自动跟随不得对未变更 snapshot 做无界重扫；加载不得把主 App 打到异常 CPU 或 GB 级工作集。
  4. 补充 Store/UI 回归：空态不得出现在 `isRefreshing` 的根加载期间。
- **Non-goals:**
  - 不改 Keyboard Extension 写入、hot path、v1 writer 分段、generation、retention 或隐私字段。
  - 不提高读取预算，不把有界窗口描述为完整历史。
  - 不改首屏高保真探针合同，不用高保真诊断方案下载。
  - 不改方案下载/完整性/回退，不 merge PR #83，不做 TestFlight 或 Release。
- **Required Inputs:**
  - 本 Product Decision
  - [ADR 0027](../architecture/decisions/0027-enterprise-local-diagnostic-observability.md)
  - [ADR 0028](../architecture/decisions/0028-diagnostics-calendar-query-and-bounded-preview.md)（Proposed；本任务不要求 Acceptance）
  - [`DIAGNOSTICS-DAY-BROWSER-001`](diagnostics-day-browser-001.md) 与 [`DIAGNOSTICS-READ-RECOVERY-001`](diagnostics-read-recovery-001.md)
  - [`DEBUGGING.md`](../DEBUGGING.md) 诊断页合同
  - Human 真机证据 [`diagnostics-viewer-load-2026-08-27`](../evidence/diagnostics-viewer-load-2026-08-27.md)
  - Human Product Gate [`PD-DIAGNOSTICS-VIEWER-LOAD-001-GATE`](../product-decisions/DIAGNOSTICS-VIEWER-LOAD-001-product-gate.md)

## Assignment

- **Domain Owner:** 📱 Main App UI — 诊断浏览与 Store
- **Executor:** 当前 Grok 会话，仅在 Human 另发明确「授权实现」之后
- **Environment Executor:** 当前 Grok 会话 — 静态分析、单元测试与 iOS Simulator。真机复测不是本 Executor 的操作。
- **Human Dependency:** Human Product Owner — 已提供加载空态与 Activity Monitor 截图作为入口证据；实现后用同一诊断页做一次真机加载复验，并在查看恢复后按 INTEGRITY-001 复测万象。
- **Architecture Reviewer:** 独立 AI subagent `architecture_review` — 复核读取预算、主线程、live refresh 与 writer/Extension 隔离；不改代码。
- **Quality Reviewer:** 独立 AI subagent `quality_review` — 复核加载态、空态分类、内存/CPU 非主张与回归测试；不改代码。

## Gates

- **Entry Criteria:**
  - Product Decision 已 Accepted；本 Assignment 无 `UNKNOWN`。
  - 实现不开始，直到 Human 明确授权实现。
  - 冻结 ADR 0027 预算、writer 与 Extension hot path。
- **Exit Criteria:**
  - 根加载期间 UI 显示加载/忙碌，而不是「暂无诊断日志」。
  - 筛选空、partial 空、真正无 journal 三种空态文案可区分。
  - 读取保持既有字节/条数预算；live refresh 不在无变更时全量重解码。
  - 定向 Store/UI 测试、相关 Simulator 套件、swift-format、Debug/Release 模拟器 build 有 Executor-recorded 证据。
  - 独立 Architecture / Quality 结论已记录。
- **Stop Conditions:**
  - 需要提高预算、改 writer、改 Extension、改方案交付或合并 PR #83。
  - 把 1.39 GB 截图数字写成新的正式内存合同。
  - 实现开始时没有明确「授权实现」。
  - 把加载失败解释成「用户没开日志」而不验证 `isRefreshing`。

## Handoff

- **Handoff Target:** Human Product Owner，在 Architecture / Quality 结论之后，做诊断页真机复验，然后回到 INTEGRITY-001 的万象分类复测。
- **Required Handoff Content:** 加载态截图合同（Simulator）、空态分类、读取预算未放宽的证据、live-refresh 行为、独立审查结论。
- **Revalidation Trigger:** writer 格式、读取预算、live refresh 周期、诊断页信息架构或隐私字段变化。

## History

- `2026-08-27 Asia/Shanghai`: Human Product Lead 同意先修诊断查看再复测万象，并指示按 KOS 推进。Assignment 记为 `Ready`；实现未开始。
- `2026-08-27 Asia/Shanghai`: Human Product Owner 授权按 KOS 2.2 开始改诊断加载空态。`AUTH-DIAGNOSTICS-VIEWER-LOAD-001-IMPLEMENT` 签发；lifecycle `active`。
- `2026-08-27 Asia/Shanghai`: 实现 `878b02a`；Architecture `Pass with conditions`（A-P1-01）；peek-bind 修复 `ec5e8e9`；Architecture 复审 **Pass**（P0=0 · P1=0）；Quality **Pass with conditions**（P0=0 · P1=0）。IMPLEMENT AUTH 仍 `unconsumed`（TD-014）。不授权 merge。
- `2026-08-27 Asia/Shanghai`: Human 真机复测（高保真关，约 69 条可见）仍出现近 1 GB 工作集与满核 CPU；二次进入再次长加载。判定 1 秒 skip/日期目录仍抢 exclusive fence，与 writer shared fence 互锁后整页重扫。主 App 读取路径改为无锁目录水位 skip，并复用 Store。截图数字不是新的内存合同。
- `2026-08-27 Asia/Shanghai`: Human 报告修复后今天/昨天日志加载内存均不超过 100 MB（高保真关）。独立 Architecture **Pass with conditions**、Quality **Pass with conditions**（`5b4a0ea`，P0=0 · P1=0）。高保真不是本 Gate。等 Human Product Gate；不 merge。
- `2026-08-27 Asia/Shanghai`: Human 报告 PR #85 GitHub CI 已绿。CI 绿不等于可 merge。Human 同日重试万象拼音 UI 成功，但 v1 无交付日志；记为 [`TD-015`](../TECH_DEBT.md#td-015-方案交付日志未进入诊断-v1-journal)。不改高保真合同，不猜修下载，不 merge #83。
- `2026-08-27 Asia/Shanghai`: Human Product Owner 接受真机复验结果并明确授权合并 PR #85。PR #85 合并为 `420322b`；head `9c837d8` 可从 `origin/main` 到达，本地与远端功能分支已安全清理。Assignment `Closed`。实现 AUTH 因 advisory validator 的 Assignment 绑定规则暂保留 `active/unconsumed`，但不构成重放许可（TD-014）。该 Gate 不授权 PR #83、方案下载修复或 Release。
