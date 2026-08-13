# Assignment: CANDIDATE-TOUCH-OBSERVABILITY-001 — 候选栏垂直命中链诊断

Policy version: 1.0.0

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Completed` — PR #71 merged；固定载荷单轮真机证据完成 |
| **Phase** | 诊断探针交付并完成单轮真机取证；行为修复由 `CANDIDATE-TOUCH-HITBOX-001` 接续 |
| **Non-claims** | 不修改候选栏命中区、布局、手势或选择语义；不宣称当前已定位 iOS 27 beta 顶部触摸丢失根因 |
| **Next** | 见 `CANDIDATE-TOUCH-HITBOX-001` |
| **Residuals** | 真机证明 `.began` phase 假设使结构化 touch probe 零写入；该缺口与候选 cell 垂直命中修复转交后续 Assignment |

---

## Authority

- Assignment Authority: Product Lead
- Decision Source / Date: 当前 Product 会话在确认 iPhone 13 Pro / iOS 27 beta 5 上候选上部 `0/5`、中部 `5/5`、下部 `5/5` 后授权最小结构化探针，`2026-08-13 Asia/Shanghai`。
- Product Approver: Human Product Owner / 当前 Product 线程

## Boundary

- Scope:
  1. 在既有 `Diagnostics/v1` allowlist 中增加内容无关的候选触摸路由、手势终态与选择送达事件。
  2. 仅记录候选栏上/中/下粗分区、是否命中 candidate cell、是否进入/取消滚动手势及是否到达选择回调。
  3. 使用 `appearanceID` 与本地触摸序列对单指短时操作做 best-effort 关联；不记录候选索引或内容。
  4. 探针仅在 Debug 构建且用户主动开启的 30 分钟高保真窗口内写入。
  5. 修正诊断空状态中已过时的“引擎诊断日志”开关名称。
- Non-goals:
  - 不扩大或移动候选栏/cell 的实际命中区，不改变 `hitTest` 返回值。
  - 不改变候选提交、RIME、分页、Path、marked text 或 KeyboardCore 输入状态机。
  - 不记录按键、拼音、候选文字/索引、宿主 App/字段或宿主文本。
  - 不迁移其余 legacy `Logger` producer，不改变 retention、查询预算或日志默认开关。
- Required Inputs:
  - `7fdd5ef`（PR #70 合并后的 `main`）。
  - ADR 0027、ADR 0028、`DEBUGGING.md`、Keyboard UI / Debug Investigator / Test & Release playbook。
  - Device observation：iPhone 13 Pro、iOS 27 beta 5、Debug `⌘R`；上/中/下 `0/5 · 5/5 · 5/5`；日志连续刷新 5 次稳定。

## Assignment

- Domain Owner: Keyboard UI
- Executor: Codex `/root`
- Environment Executor: Codex `/root`（本地 Swift 6 / Simulator 验证）；Human Device Operator（下一轮真机安装与输入）
- Human Dependency: Human Product Owner / Device Operator 提供 iPhone 13 Pro 并按书面三分区序列完成一次人工输入轮次
- Architecture Reviewer: Architecture & Knowledge Steward 独立 reviewer agent
- Quality Reviewer: Test / Release 独立 reviewer agent
- Product Approver: Human Product Owner / 当前 Product 线程

## Gates

- Entry Criteria:
  - [x] `main` 与 `origin/main` 对齐且工作区干净。
  - [x] 症状在固定设备/OS/构建上按粗分区重复，选择业务路径在中/下部可工作。
  - [x] Product 明确授权诊断而非行为修复。
  - [x] 新字段可保持内容无关、有界、非阻塞并服从高保真自动到期。
- Exit Criteria:
  - [x] 新事件只能由 Debug 高保真窗口产生，普通/关闭状态不增加 v1 候选触摸事件。
  - [x] 每个事件只使用 allowlisted code/field；无自由文本、坐标、候选索引或内容。
  - [x] 触摸观测不改变 UIKit 命中返回值、gesture cancellation 或候选选择调用顺序。
  - [x] KeyboardCore allowlist/编码、主 App 展示和候选 UI 接线有自动化或静态合同证据。
  - [x] Swift format、KeyboardCore、RimeBridgeTests、App + Keyboard tests、Debug/Release build 全绿。
  - [x] 独立 Architecture 与 Quality review 无未处置阻断项。
  - [x] Human Device Operator 在冻结安装上完成上/中/下单轮复测并回传内容无关日志。
- Stop Conditions:
  - 需要记录坐标、候选索引/文字、拼音、按键或宿主内容。
  - 需要同步读取 App Group、等待 actor/锁、编码 JSON 或写磁盘才能完成触摸回调。
  - 探针会改变 hit-testing、gesture recognizer 或选择语义，或需要修改 RIME/KeyboardCore 状态机。
  - 自动化/独立审查表明事件无法可靠关联或高保真门失效。

## Handoff

- Handoff Target: 独立 Architecture review → 独立 Quality review → Human Device Operator → Product Lead 根因/修复决策
- Required Handoff Content: 固定提交、字段 allowlist、热路径副作用审计、自动化结果、review 结论、真机步骤和内容无关日志行
- Revalidation Trigger: 新增任何持久化字段、扩大到 Release/普通日志、改变候选触控行为、设备/OS/安装载荷变化或人工轮次超过一次

## History

- 2026-08-13: PR #70 后真机确认诊断读取/刷新稳定；候选栏同一候选上部 `0/5`、中部 `5/5`、下部 `5/5`。现有候选 `hitTest` 自由文本仍走 legacy Logger，而 v1 非空时 UI 不混入 legacy，故当前日志不能回答触摸在哪一层丢失。
- 2026-08-13: 最小探针实现与 CI 等价本地门禁通过；Architecture `Blocker 0 / Major 0`，Quality 复核 `Blocker 0 / Major 0 / Minor 2`。Minor 已通过单指短时判读边界和人工轮次限制处置，不授权泛化为触摸身份。
- 2026-08-13: PR #71 合并为 `f480dac`。固定 iPhone 13 Pro / iOS 27.0 build `24A5408d` / Debug 载荷完成唯一单指轮次，上/中/下为 `0/5 · 5/5 · 5/5`。legacy 几何日志证明 48 pt collection 内 cell 高 32 pt 且起点约 y=8；结构化候选事件为 0，后续转交 `CANDIDATE-TOUCH-HITBOX-001`。
