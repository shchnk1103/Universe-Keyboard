# Assignment: DIAGNOSTICS-VIEWER-LOAD-001 — 诊断查看加载态与有界读取

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "DIAGNOSTICS-VIEWER-LOAD-001",
  "record_type": "assignment",
  "title": "Diagnostics viewer load state and bounded read",
  "lifecycle": "active",
  "current_phase": "Independent Architecture Pass and Quality Pass with conditions recorded; waiting reviewable PR and Human Product Gate",
  "authorization_action": "implement",
  "updated_at": "2026-08-27T22:40:00+08:00",
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
| Lifecycle | active |
| Current Phase | Independent Architecture Pass and Quality Pass with conditions recorded; waiting reviewable PR and Human Product Gate |
| Material non-claims | No PR #83 merge; no scheme-download fix; no raised read budget; no merge without Human Product Gate |
| Next handoff / decision | Reviewable PR [#85](https://github.com/shchnk1103/Universe-Keyboard/pull/85)；Human 真机复验诊断加载面后再 Product Gate。Gate 前不 merge |
| Residuals | AUTH establish-assignment is consumed; TD-014 remaining if KOS-UPGRADE AUTH still needs follow-up |

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
