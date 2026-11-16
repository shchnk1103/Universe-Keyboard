# 普通键按下序重叠与完整触区知识卡（KEY-ROLLOVER-001）

写于 2026-11-16，依据 `KEY-ROLLOVER-001`（PR #308，原提交 `8db6c44f7e66f2e72b09b4d5aae97f290754c509` → merge `06eacc0ef83ede60f3abca5f107018c0118b12ee`）。本页只记已证事实、已定决定、边界不变量、代码入口、测试归属与外置证据位置，不记过程流水。

## 1. 它是什么
- 普通键（英文 26 键、中文 26 键、九宫格 `2–9`）的完整交互区域（视觉键帽 `KeyboardKeyButton` + 既有扩展触区 `KeyboardTouchCellControl`）统一接入 `OrdinaryKeyRolloverStateMachine`（`Packages/KeyboardCore`）与长按变体体系。
- 当手指按住普通键 A 尚未抬起、第二指按下另一普通键 B 时，状态机在 **B 按下瞬间** 按按下序先后消费 A 与 B（得 `ab`），并在随后抬手时抑制重复输入。

## 2. 已定口径与范围边界
- **适用键范围**：仅普通键（英文 26 键、中文 26 键、九宫格 `2–9`）纳入按下序重叠与完整触区一致行为。
- **隔离范围**：
  - 19 个原本带长按变体的字母键设置 `supportsOrdinaryLongPressVariants = true`；其余无变体字母键、九宫格数字键与标点键不新增变体，不挂载长按识别器。
  - 功能键（Shift、删除、空格、回车、切页、地球、`^_^`）与非键区（候选栏、工具栏）保持既有交互与区域边界，不扩大，不进入普通键 rollover 状态机。

## 3. 核心机制与边界不变量
- **按下序消费与抬手防双写**：
  - `KeyboardKeyButton` 与 `KeyboardTouchCellControl`（`isOrdinaryRolloverParticipant == true`）在 `beginTracking` / `continueTracking` / `endTracking` / `cancelTracking` 中发出 `OrdinaryKeyTrackingEvent`（携带 `ObjectIdentifier(touch)`），不再走 `sendActions(for: .touchUpInside)`。
  - 已被后键提前消费（`.consumed`）的触点在 `KeyboardKeyButton.touchesEnded` 等抬手路径中被抑制，不二次上屏。
- **一次性大写（`Shift.singleUse`）**：
  - 无论 A、B 落在键帽还是扩展区，后键 B 按下时状态机先消费前键 A（同时将 `Shift.singleUse` 置为 `.off` 并刷新小写标题），再捕获并消费 B 的载荷（得 `Ab` / `Abbb`）。
- **扩展触区与键帽同源长按变体**：
  - `KeyboardTouchCellControl` 覆盖与 `KeyboardKeyButton.localTouchBounds` 对齐的完整 `cell.touchFrame`。仅当 `isOrdinaryRolloverParticipant == true` 且 `KeyPopupView.hasVariants(for: key)` 为 `true` 时，挂载 `UILongPressGestureRecognizer(minimumPressDuration: 0.3)`。
  - `handleKeyLongPress(_:)` 经 `OrdinaryRolloverTouchControl` 解析出实际触发控件（`KeyboardKeyButton` 本身或 `KeyboardTouchCellControl` 的 `sourceButton`），对其调用 `cancelTracking(with: nil)`（若已 `.consumed` 则直接返回不取消）；`showVariantPopup(on: button)` 始终锚定视觉键帽 `button` 的坐标系，保证键帽与扩展区的弹窗位置、滑动选字与面板外滑出取消完全一致。
- **跨键第二指中断变体与复位**：
  - A（键帽或扩展区）处于 `.variantOwned` 弹出变体面板时，另一普通键 B 按下会发射 `.dismissVariantAndSuppressLongPress(buttonID: A)`，关闭 `variantPopupView`（不提交变体）并按序消费 `a` 与 `b`（得 `ab`）。
  - `suppressLongPressRecognizers` 与 `invalidateOrdinaryKeyRollover` 同步重置 A 键帽与对应 `ordinaryRolloverGapControl` 上的 `UILongPressGestureRecognizer`（`isEnabled = false; isEnabled = true`），防止 A 松手时再触发提交并确保后续单指长按正常恢复。
- **同键多指互斥**：
  - `KeyboardKeyButton` 与 `KeyboardTouchCellControl` 在 `beginTracking` 入口均校验 `canBeginOrdinaryRolloverTouch`（`phase == nil`），拒绝同键第二指。
  - `OrdinaryKeyLongPressDelegate.gestureRecognizerShouldBegin(_:)` 校验 `control.isTrackingOrdinaryRolloverTouch && phase == .pending`，防止第二指长按识别器抢占第一指。
- **生命周期清理**：
  - 切页、高度调整、内存警告或状态重置时递增 `sessionEpoch`、关闭 `variantPopupView` 并清空所有按钮与扩展触控控件的活跃触点，丢弃迟到事件。

## 4. 代码入口与测试归属
- **核心状态机**：`Packages/KeyboardCore/Sources/KeyboardCore/OrdinaryKeyRolloverStateMachine.swift`
- **键盘控制器与触区集成**：
  - `Keyboard/Controllers/KeyboardInputHitAreaStackView.swift`（`KeyboardTouchCellControl`）
  - `Keyboard/Controllers/KeyboardKeyButton.swift`
  - `Keyboard/Controllers/KeyboardViewController.swift`
  - `Keyboard/Controllers/KeyboardViewController+Gestures.swift`
  - `Keyboard/Controllers/KeyboardViewController+InputActions.swift`
  - `Keyboard/Controllers/KeyboardViewController+KeyFactory.swift`
  - `Keyboard/Controllers/KeyboardViewController+Rows.swift`
- **单元测试与集成测试**：
  - `Packages/KeyboardCore/Tests/KeyboardCoreTests/OrdinaryKeyRolloverStateMachineTests.swift`（`KeyboardCore` 单测 1415 tests、0 failures，含状态机 6/6 通过）
  - `KeyboardLayoutIntegrationTests/OrdinaryKeyRolloverIntegrationTests.swift`（覆盖 T1–T8，12/12 通过）
- **真机验收事实**：
  - 在 `iPhone 13 Pro`（`iOS 27.2.1`）完成英文 26 键、中文 26 键、中文九宫格三布局真机验收全部通过（完整触区点击/滑出取消、扩展区长按变体选字/取消、同键跨子区滑动、扩展区+键帽交叉、跨键第二指中断变体与恢复、`Shift.singleUse`、同键多指互斥、无变体/功能键隔离）。

## 5. 外置证据位置
- 完整设计与质量/真机证据位于 PM 外置任务目录（不在仓库内）：`KEY-ROLLOVER-001/reports/`（`design-touch-region-r2.md`、`quality-impl-touch-region-r1.md`、`human-device-touch-region-r1-20261116.md`、`executor-report-merge-r1.md`）。
