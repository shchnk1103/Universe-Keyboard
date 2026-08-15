# Product Decision: DEBUG-KEY-HITBOX-001 — Debug 按键触摸范围可视化

**Decision ID:** `PD-DEBUG-KEY-HITBOX-001`
**Lifecycle status:** `Recorded` — Assignment `DEBUG-KEY-HITBOX-001` 已 `Closed`
**Date / timezone:** `2026-08-14 Asia/Shanghai`
**Assignment:** [`DEBUG-KEY-HITBOX-001`](../assignments/debug-key-hitbox-001.md)
**Related:** [`CANDIDATE-TOUCH-HITBOX-001`](../assignments/candidate-touch-hitbox-001.md)（候选栏命中，范围外）、[`DIAGNOSTICS-OBSERVABILITY-001`](../assignments/diagnostics-observability-001.md)（日志，不替代本可视化）

## Current Status (KOS 2.1 M-01)

| Field | Value |
|---|---|
| **Lifecycle** | `Recorded` |
| **Phase** | Assignment `Closed`；Human Product Gate Passed |
| **Non-claims** | 不进 Release / TestFlight |
| **Next** | 无；触摸铺满回归已由 [`KEY-TOUCH-FILL-001`](../assignments/key-touch-fill-001.md) 完成 |
| **Residuals** | 无；26 键嵌套第三行 / overlay 开关命中漂移已通过 Human 真机 Product Gate |

---

## Authority

- **Product Approver:** Human Product Owner / Product Lead，当场锁定三条：仅 Debug；首版不画候选栏；先写短 PD。
- **Assignment Authority:** Product Lead under [`ASSIGNMENT_POLICY.md`](../ASSIGNMENT_POLICY.md)。
- **Domain Owner（实现时）:** ⌨️ Keyboard Experience Maintainer（键盘 overlay）；主 App 诊断开关由 📱 App & Data Operations 接线，不另建诊断产品面。
- **Architecture / Quality:** 不改 hit-test 合同、App Group 所有权、隐私字段或热路径读盘则 **不强制新 ADR**。Quality 验收硬条件见下。

## Product Problem

按键视觉框与真实触摸单元不是同一套几何：`KeyboardInputHitAreaStackView` 按相邻键中线切分空隙，并用近乎不可见的 backing 承接间隙触摸。历史红底诊断曾改变被测表面，后被去掉。内部现在只能靠点按猜测缝归谁。需要一个 **不参与 hit-test 的现场观察层**。

## Bound Product Decisions

1. **形态：** 主 App 现有「诊断」里一个 **默认关** 的开关（例如「显示按键触摸范围」）。打开后，键盘叠一层只读描边。首版 **不做** 独立调试页、坐标表或点按高亮。
2. **仅 Debug：** 开关与 overlay 只存在于 Debug 构建。Release 编译路径必须不可见、不可开；不得只靠 UserDefaults 在 Release 里生效。不进 TestFlight / 商店构建。
3. **观察层，不是命中层：** overlay `isUserInteractionEnabled = false`，不得画在现有 touch-cell backing 上，不得 `bringSubviewToFront` 那些 backing。打开再关闭后，同一点必须落到同一颗键。
4. **画什么：** 实线 = 当前 hit-test 正在使用的矩形；虚线 = 对应视觉层。框内不写键值、候选或任何输入内容。
5. **覆盖范围：**
   - 26 键与九键的字母 / 功能键（`KeyTouchCellLayout` 快照）。
   - 候选栏：每个 compact cell 的 `bounds`（含 48 pt 触控高）、展开按钮的 `expandedButtonHitFrame`。
   - Path bar：每个 Path cell 的 `bounds`，以及 `point(inside:)` 实际使用的竖向扩展框（44 pt 下限）。
   > **Superseded for current status (`2026-08-14`):** Human Product Owner 在按键 overlay 目视通过后授权继续画候选栏与 Path bar。下文历史「不画候选栏 / Path」不再是当前合同。
6. **仍不画：** 展开候选面板、地球仪等系统控件。另开 Decision。
7. **热路径：** `hitTest` / `pointInside` / 按键处理不得同步读 App Group 或 UserDefaults。开关只在布局 / appear 时读入内存。
8. **V1 UI Freeze：** 本层是 Debug 诊断，不是产品皮肤；不得改键高、间距、圆角或候选栏常量。

## Amendment — 2026-08-14 Human Product Owner

当场授权三条，覆盖上文「不得改命中几何」中与九键空隙相关的部分：

1. **九键与 26 键同一套中线填缝。** 九键只按左/右列和行切网，不把整列收成一格。
2. **Overlay：** 每个按键（含空格、回车）画实线触摸框与虚线显示框，框等于 hit-test 快照。
3. **分组缝不再留死区：** WXYZ–空格按中线对半分给两颗邻键。

## Amendment — 2026-08-15 Human Product Owner

产品规则不变。Human 报告 26 键触摸盒未铺满（`z…m` 最明显）以及关闭 overlay 后命中变小。后续修复由 [`PD-KEY-TOUCH-FILL-001`](KEY-TOUCH-FILL-001-authorization.md) 授权；本 Decision 仍禁止 overlay 成为第二条命中路径。

## Explicit non-authorization

- 为了“画得好看”另算一套与 `hitTest` 不同的矩形
- 把 26 键改成九键容差，或把九键改回整缝中线分配
- Release / TestFlight 默认开或可开
- 记录坐标、键值、候选文字或把 overlay 画面写入诊断 journal
- 独立调试页、首屏高保真探针改约、或关闭 `CANDIDATE-TOUCH-HITBOX-001` 的真机残余

## Acceptance (when later implemented)

- Debug 可开关；Release 构建无此开关、无可见描边。
- Overlay 开/关不改变任何点的命中目标（自动化或可复核的几何对照）。
- 浅色 / 深色下描边可辨，但不表现为键变大。
- 不新增热路径 I/O。

## Revalidation

改 Release 可见性、把 overlay 接到 hit-test、纳入展开候选面板、记录内容级数据，或改变任何触摸几何，必须停止并修订本 Decision。
