# Assignment: CANDIDATE-TOUCH-HITBOX-001 — 候选栏垂直命中与诊断浏览修复

Policy version: 1.0.0

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Active` |
| **Phase** | 本地实现、CI 等价门禁与独立复核完成；等待 Product 发布/合并决策 |
| **Non-claims** | 不修改候选排序、RIME、输入状态机、候选视觉尺寸或万象模型；不把旧探针零事件解释为 UIKit 未收到触摸 |
| **Next** | 发布边界清晰的 PR → Product 合并决策 → 获授权后一次真机残余验证 |
| **Residuals** | UIKit 几何仍需合并后以一次单指真机回归确认；本轮不增加人工轮次 |

---

## Authority

- Assignment Authority: Product Lead
- Decision Source / Date: 当前 Product 会话接受固定载荷单轮证据并明确“很好，继续吧”，`2026-08-13 Asia/Shanghai`
- Product Approver: Human Product Owner / 当前 Product 线程

## Boundary

- Scope:
  1. 普通候选 cell 的触摸高度覆盖既有 34 pt 可见栏与 14 pt 手势承接区，保持文字、highlight 与候选宽度不变。
  2. Debug 高保真候选触摸探针不再要求 `hitTest` 阶段 touch 已进入 `.began`；继续保持单指、短时、best-effort 与 typed allowlist。
  3. 自动刷新保持实时但不驱动工具栏 spinner；搜索展示期间暂停根刷新并在 5 MiB / 10,000 条安全上限内展开冻结分页。
  4. 合并同一布局 burst 的候选可见性事件，避免 500 条最近窗口被 per-cell 回调占满。
  5. 记录固定真机轮次、根因证据和诊断 UI 异常处置。
- Non-goals:
  - 不改变候选文字、顺序、宽度、字体、颜色、RIME selection 或提交语义。
  - 不扩大到候选栏横向边界之外，不改变展开按钮或 Path Bar。
  - 不移动 App Group 根、放宽日志字节/事件预算或引入无界内存读取。
  - 不触碰万象模型、schema 部署或 TD-012。

## Assignment

- Domain Owner: Keyboard UI + Diagnostics UI
- Executor: Codex `/root`
- Environment Executor: Codex `/root`（Swift 6 / Simulator）
- Human Dependency: 暂无；新的真机轮次必须在合并后由 Product 明确授权
- Architecture Reviewer: 独立 reviewer agent
- Quality Reviewer: 独立 reviewer agent
- Product Approver: Human Product Owner / 当前 Product 线程

## Gates

- Entry Criteria:
  - [x] PR #71 已合并且功能提交可从 `origin/main` 到达。
  - [x] 固定载荷单轮结果为 `0/5 · 5/5 · 5/5`，无需重复取样。
  - [x] legacy 日志显示 collection `48 pt`、cell `32 pt`、垂直起点约 `8 pt`。
  - [x] 页面 1 秒自动刷新直接切换 toolbar spinner，搜索只覆盖当前 500 条窗口。
- Exit Criteria:
  - [x] 普通候选 cell 覆盖完整既有垂直触摸容器且视觉中心不变。
  - [x] structured routed probe 在真机已观察的 `hitTest` phase 约束下不再被静默过滤。
  - [x] 自动刷新静默；搜索期间不重置页面并展开安全上限内全部冻结分页。
  - [x] 可见性事件按稳定布局 burst 合并，不再逐 cell 刷屏。
  - [x] Swift format、KeyboardCore、RimeBridgeTests、App + Keyboard tests、Debug/Release build 全绿。
  - [x] 独立 Architecture / Quality review 无未处置 blocker/major。
- Stop Conditions:
  - 修复需要改变候选内容/排序/提交、RIME 或 KeyboardCore 输入状态。
  - 搜索需要突破 5 MiB / 10,000 条上限或同步阻塞主线程。
  - 触摸路径需要文件 I/O、App Group 读取或等待 actor/锁。

## Handoff

- Handoff Target: Architecture review → Quality review → Product merge decision
- Required Handoff Content: 固定 commit、几何不变量、日志/搜索预算、自动化、独立审查与真机残余
- Revalidation Trigger: 改变候选视觉高度/布局、日志预算、Release 探针边界或安装载荷

## Evidence Input

- Run: `CTO-001-20260813-2130-f480dac-DE65`
- Device: iPhone 13 Pro / iOS 27.0 beta build `24A5408d`
- Result: upper `0/5`, middle `5/5`, lower `5/5`
- Legacy examples: bar y `28...31` maps to cell y `20...23`, proving cell frame minY ≈ `8`; successful hits resolve to cell descendant.
- Diagnostics page: refresh indicator flickers continuously; search presentation collapses/overlaps; copied recent window contains no new structured candidate touch events and is dominated by per-cell visibility events.

## Execution Update

- 2026-08-13: 紧凑 cell 扩至既有 48 pt 容器；探针限定单个 direct touch 且移除 `.began` 假设；诊断搜索、静默自动刷新与 visibility coalesce 完成。
- 2026-08-13: 聚焦 Store `21/21`；App `189 passed / 3 skipped`，Keyboard `6/6`；KeyboardCore `990/990`；RimeBridgeTests、严格 Debug/Release build 通过。
- 2026-08-13: Architecture 最终 `Blocker 0 / Major 0 / Minor 0`；Quality 最终 `Blocker 0 / Major 0`，只保留 UIKit 几何真机验证这一已声明 residual。
