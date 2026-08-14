# Assignment: DEBUG-KEY-HITBOX-001 — Debug 按键真实触摸范围可视化

Policy version: 1.0.0

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Completed` |
| **Phase** | Executor 已交付；Human 确认命中与 overlay；未做独立 Quality / Product Gate |
| **Non-claims** | 不是 Reviewed / Closed；不进 Release / TestFlight |
| **Next** | PR #73 已合并到 `main`；可选 Quality 独立复核 → Product Lead 决定是否 Closed |
| **Residuals** | Path 空闲文案已下线（同会话附带） |

---

## Authority

- Assignment Authority: Product Lead
- Decision Source / Date: [`PD-DEBUG-KEY-HITBOX-001`](../product-decisions/DEBUG-KEY-HITBOX-001-authorization.md)；Human Product Owner 「立 Assignment 并实现」，并强调显示必须是真实触摸区域，`2026-08-14 Asia/Shanghai`
- Product Approver: Human Product Owner / 当前 Product 线程

## Boundary

- Scope:
  1. 主 App 诊断页增加 **仅 Debug、默认关** 的「显示按键触摸范围」开关。
  2. 键盘在 Debug 下于布局 / 可见性边界读取开关到内存；`hitTest` 不读 App Group。
  3. Overlay 只绘制 **同一份** hit-test 正在使用的矩形（实线）与对应视觉层（虚线）。禁止另算、另布一套触摸区域。
  4. Overlay `isUserInteractionEnabled = false`，不得改 backing、不得改变命中结果。
  5. 覆盖：26 键 / 九键字母与功能键；候选栏 compact cell 与展开/收起按钮；展开面板 cell；Path bar cell 与竖向 44 pt 扩展。
- Non-goals:
  - 为 overlay 另算一套与 `hitTest` 不同的矩形。
  - 改变 26 键中线填缝。
  - Release / TestFlight 可见或可开。
  - 独立调试页、点按高亮、记录坐标 / 键值 / 候选文字。
  - 关闭 `CANDIDATE-TOUCH-HITBOX-001` 真机残余。
- Required Inputs: `PD-DEBUG-KEY-HITBOX-001`；`KeyboardInputHitAreaStackView` 现有触摸单元算法。

## Assignment

- Domain Owner: ⌨️ Keyboard Experience Maintainer
- Executor: 当前 Grok 会话
- Environment Executor: 当前 Grok 会话（Simulator / `swift test`）
- Human Dependency: Not Applicable — V1 验收以 Debug 构建与几何对照测试为准；真机目视不构成本轮 Exit。
- Architecture Reviewer: Not Applicable — 不改 hit-test 合同、App Group 所有权或隐私字段；overlay 仅为观察层。
- Quality Reviewer: 🧪 Quality, Performance & Release Maintainer（本轮 Executor 先自跑 KeyboardCore 套件；独立复核不阻塞实现提交）
- Product Approver: Human Product Owner / 当前 Product 线程

## Gates

- Entry Criteria:
  - [x] `PD-DEBUG-KEY-HITBOX-001` 已 Recorded。
  - [x] Active Work 容量允许（进入时 3/10）。
  - [x] Product 明示立 Assignment 并实现；真实触摸区域约束已写入 Scope。
- Exit Criteria:
  - [x] Debug 开关默认关；Release 编译路径无开关、无描边。
  - [x] Overlay 框等于 hit-test 快照 `touchFrame`，有自动化对照。
  - [x] `hitTest` / `pointInside` 不读 App Group。
  - [x] KeyboardCore 相关测试通过（`KeyTouchCellLayoutTests`；中线填缝 + 本地触摸盒）。
- Stop Conditions:
  - Overlay 参与 hit-test 或为了好看另画一套矩形。
  - 把 26 键改成九键容差。
  - Release 构建能打开或看见描边。
  - 热路径同步读盘 / App Group。

## Handoff

- Handoff Target: Quality（可选独立复核）→ Product Lead
- Required Handoff Content: 改动文件、几何同源证明、测试命令与结果、未做的真机目视
- Revalidation Trigger: 改触摸几何、Release 可见性、纳入候选栏 / Path、记录内容级数据

## History

- 2026-08-14: Product 授权创建本 Assignment 并实现。
- 2026-08-14: 按键 overlay 目视通过后，Product 授权同一开关扩展到候选栏与 Path bar。
- 2026-08-14: Device-attested 探针 `hit=UIView idx=0 cellH=48 contentH=48 y=1…16` 仍不提交。判定为选词未送达，不是框画小了。Collection 在 item frame 内把非 cell 铬层交回 cell；下滑展开不再 `cancelsTouchesInView`。
- 2026-08-14: 二次探针 `UIView<CandidateCollectionCell … inCell y=9` 仍不提交。根因是 UICollectionView 的 `didSelect` 等条上下滑 pan 失败。已加 item tap（不要求下滑失败）并由 Human 确认顶部可提交。
- 2026-08-14: 展开按钮橙框是 `expandedButtonHitFrame` 被压成栏顶 34 pt 整条（按钮 56 + 左右 outset，并伸出栏外）。改为按钮自身 outset 盒 ∩ 栏 bounds；有候选 item 时不再先交给展开钮。
- 2026-08-14: 展开面板 cell 已有 overlay；收回按钮原先不在绘制范围，现用 `collapseButtonHitFrame ∩ container`（与 hitTest 同一份）。
- 2026-08-14: 九键改走方案 B：`T9NineKeyChromeHost` 左右分栏切缝；回车只在右列，禁止一行一键撑满全键盘。26 键仍用全局 midY 算法。
- 2026-08-14: Human 确认 WXYZ–空格缝误中 DEF；授权九键改为有上限邻键容差 + 最近视觉框；overlay 必须画出每个按键（含空格/回车）的显示区与触摸区。
- 2026-08-14: Human 截图仍是整列一条框。判定 overlay 画在 `UIStackView` 内被拉成列高。改为 superview 画布 + 每键一对 shape path；误中 DEF 留到框完成后再查。
- 2026-08-14: 五列整条框 + 点 JKL 亮 ABC。根因是按列 flatten/midY 把整列收成一行，ABC 触摸框变成列高。改回 arranged 行结构；键面命中优先；outset 封顶 4 pt。
- 2026-08-14: 点按已对，overlay 仍是五列。改为每个 `KeyboardKeyButton` 自绘一对框，并钳掉列高 snapshot；删掉 stack 外旧画布。
- 2026-08-14: 框已对，间隙仍点亮 DEF。hit-test 改为使用与 overlay 同一份钳制框，整列快照不能再把 MNO/WXYZ 缝分给 DEF。
- 2026-08-14: Product 认可与 26 键共用中线填缝。去掉九键 4 pt 钳制 / 双路径；`KeyTouchCellLayout` 为唯一切缝算法，九键只提供列/行。
- 2026-08-14: 共用中线后又出现点 JKL 上屏 ABC。`convert(bounds)` 在祖先被拉高时变成整列高。改为 `hostFrame(localSize + origin)` 按 midY 分行；键面命中取面积最小的视觉框。
- 2026-08-14: Product 确认九宫格也不要「先键面再缝」。删掉 `liveVisualKey`；hitTest 只认共用 `touchFrame`；九键行来自 chrome arranged 行，不再 midY 摊平。
- 2026-08-14: 列顶键再次吃掉整列。根因是 `super.hitTest` + 列高 `outsets` 仍能选中 ABC/DEF。改为命中只问快照 `touchFrame`；不再往 UIStackView 塞 backing；九键用屏幕坐标量键。
- 2026-08-14: 列顶问题仍在。改为把点击点 `convert` 进每颗键，用 stack `spacing` 的一半扩 `bounds`；不再用根 stack 坐标系里的列高快照选键。
- 2026-08-14: Human 确认按键与空隙命中已修好。实现侧收口：Assignment 仍 Active，等待 Product 是否 Closed / 移出 Active。未开 PR、未跑 App+Extension 全量门禁。
- 2026-08-14: KOS 收口：Lifecycle → `Completed`（Executor 交付 + Human 确认实现；非 Quality/Product Gate）。移出 Active Work。Closed 仍须 Product Lead。
- 2026-08-14: 功能分支 `feat/debug-key-hitbox-001` 已推送；PR #73。PR 未合并，本地与远端功能分支均保留。
- 2026-08-14: PR #73 已合并；`2817f19` 可从 `origin/main` 到达（merge `fb7b80a`）。CI `Swift 6 Quality` 绿。功能分支待安全删除。
