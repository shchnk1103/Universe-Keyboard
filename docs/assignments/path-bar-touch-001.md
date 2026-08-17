# Assignment: PATH-BAR-TOUCH-001 — 九键 Path Bar 上半区点击投递

Policy version: 1.0.0

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Completed` |
| **Phase** | Human 复验「好像没有问题了」；准备 PR |
| **Non-claims** | 不改 Path 语义、RIME、候选排序；不新增 DiagnosticEvent 字段；未跑与 CI 等价全套 xcodebuild |
| **Next** | 推功能分支并开 PR；Closed 等合并 |
| **Residuals** | 独立 Quality 书面复核未做（Assignment 不阻塞）；未做 5/5 分带矩阵 |

---

**Task ID:** `PATH-BAR-TOUCH-001`  
**Date / timezone:** `2026-08-17 Asia/Shanghai`  
**Repository Change Type:** `Bugfix`  
**Product Decision source:** 当前会话 Human Product Owner「授权你继续」；合同沿用 `UI_STYLE_GUIDE` Path ≥ 44 pt 与 `ChromeTouchHitGeometry.pathBarExpandedHitBounds`

## Authority

- Assignment Authority: Product Lead
- Decision Source / Date: Human Product Owner 当前会话，`2026-08-17 Asia/Shanghai`
- Product Approver: Human Product Owner / 当前 Product 线程

## Boundary

### Scope

1. Path Bar 点击投递对齐候选栏已修过的模型：item 框内的系统铬层回退到 cell；直接 tap，不等 `didSelect` 先等 pan 失败；`delaysContentTouches = false`。
2. 44 pt 扩高落到**每个 Path item**，与 overlay 橙框同一份 `pathBarExpandedHitBounds`。禁止只扩整条 bar、却选不中芯片。
3. Debug overlay 打开时，Path Bar 自己显示内容无关探针（band / hit / delivered），不写 Path 文字。
4. KeyboardCore 补 item 命中选择的纯几何测试。

### Non-goals

- 不改 Path 选择语义、组字、RIME、候选栏、键区填缝
- 不新增 `DiagnosticEvent` / ADR 0027 字段
- 不做系统整页拼音盘
- 不把 Simulator 结果写成真机 Product Gate

### Required Inputs

- Human 截图：橙框到顶，实际只能点 Path 中偏下
- Human 现有版本日志：只有 `touch.terminal` / `candidate.visibility_changed`，没有 Path 投递
- [`CANDIDATE-TOUCH-HITBOX-001`](candidate-touch-hitbox-001.md) 投递模型
- [`DEBUG-KEY-HITBOX-001`](debug-key-hitbox-001.md) overlay = 真实 hit 矩形
- [`UI_STYLE_GUIDE.md`](../UI_STYLE_GUIDE.md) Path ≥ 44 pt

## Assignment

- Domain Owner: ⌨️ Keyboard Experience Maintainer
- Executor: 当前 Codex 会话
- Environment Executor: 当前 Codex 会话 — Simulator / `swift test` / 必要时 `xcodebuild`
- Human Dependency: Human Product Owner — 真机点 Path 上/中/下是否选中
- Architecture Reviewer: Not Applicable — 复用候选栏投递与既有 44 pt 几何，不新立 ADR，不改 Core 状态机
- Quality Reviewer: 本轮 Executor 先跑 KeyboardCore 几何测试；独立书面复核不阻塞实现
- Product Approver: Human Product Owner / 当前 Product 线程

角色依据：Human Product Owner「授权你继续」。Human 保留真机 Product Gate。

## Gates

### Entry Criteria

- [x] Product 授权本阶段实现
- [x] Active Work 进入时 ≤ 10
- [x] 不新增 DiagnosticEvent 字段
- [x] 角色已指定，无 `UNKNOWN`

### Exit Criteria

- [x] Path 上/中/下点击都能选中对应芯片（自动化覆盖几何；真机由 Human 确认）
- [x] overlay 橙框与 item 扩高 hit 矩形同一份
- [x] 热路径不读 App Group、不写 Path 文字到日志
- [x] KeyboardCore 几何测试通过 — `KeyTouchCellLayoutTests` 22/0

### Stop Conditions

- 修复需要改 Path / RIME / 候选提交语义
- 需要新的 journal 字段才能观测
- Overlay 另画一套与 hit-test 不同的矩形
- Active Work 将超过 10 项

## Handoff

- Handoff Target: 开 PR 后等 CI；合并后 Closed
- Required Handoff Content: 改动文件、几何测试、Human 复验、未跑的全套 xcodebuild
- Revalidation Trigger: 改 Path 高度、改回只走 `didSelect`、把扩高再收成整条 bar

## History

- `2026-08-17 Asia/Shanghai`：Human 报告 Path 橙框到顶但只能点中偏下。现有 INFO DISP 不能证明。Product「授权你继续」。Lifecycle → `Active`。
- `2026-08-17 Asia/Shanghai`：Executor 落地 item 扩高命中、铬层回退、直接 tap、Debug 探针。`KeyTouchCellLayoutTests` 22/0。未跑 App+Keyboard xcodebuild，未开 PR。
- `2026-08-17 Asia/Shanghai`：Human 复验「好像没有问题了」。Product Gate Passed（非正式 5/5 分带）。Lifecycle → `Completed`。授权开 PR。
