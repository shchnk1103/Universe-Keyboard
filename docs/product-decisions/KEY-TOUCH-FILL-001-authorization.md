# Product Decision: KEY-TOUCH-FILL-001 — 26 键触摸盒铺满键区且 overlay 不得改命中

**Decision ID:** `PD-KEY-TOUCH-FILL-001`
**Lifecycle status:** `Recorded`
**Date / timezone:** `2026-08-15 Asia/Shanghai`
**Assignment:** [`KEY-TOUCH-FILL-001`](../assignments/key-touch-fill-001.md)
**Parent contract:** [`PD-DEBUG-KEY-HITBOX-001`](DEBUG-KEY-HITBOX-001-authorization.md)

## Current Status (KOS 2.1 M-01)

| Field | Value |
|---|---|
| **Lifecycle** | `Recorded` |
| **Phase** | 授权实现已完成；26 键/九键 overlay 关开同点 Human 真机 Product Gate Passed |
| **Non-claims** | 不改键面尺寸 / 间距 / 圆角；不进 Release overlay；不重开万象 G2 |
| **Next** | 无；实现状态见 Completed Assignment |
| **Residuals** | 无 |

---

## Decision

Human Product Owner 在 `2026-08-15` 提供 26 键 Debug overlay 截图，并报告两则缺陷，当场要求按 KOS 先查后改、禁止猜修：

1. 可触摸区域没有铺满键盘；`z/x/c/v/b/n/m` 最明显。
2. 关闭「显示按键触摸范围」后，实际可点范围变小（例如 `a` 左侧空隙原先会命中 `a`，关闭后无响应）。

本 Decision **不改** `PD-DEBUG-KEY-HITBOX-001` 的产品规则，只授权把实现收回到该规则：

- 视觉盒 = 键面；触摸盒按相邻键中线填满键区。
- 点落在哪颗键的触摸盒，哪颗键响应（高亮 + 插入）。
- Overlay 只绘制同一份 hit-test 快照；开/关不得改变任一坐标的命中目标。
- Overlay `isUserInteractionEnabled = false`，不得成为第二条命中路径。

## Bound Product Decisions

1. 26 键第三行必须把 Shift、`z…m`、删除看成 **同一视觉行**；`z…m` 必须分到与上下行、与 Shift/删除之间的中线缝。不得因为字母被嵌套进子 `UIStackView` 就丢掉竖向缝和功能键缝。
2. 第二行 18 pt 内缩产生的左右槽，按中线规则归 `a` / `l`（或该行首尾键），不得留死区。
3. 九键继续按左/右列结构化切网；禁止为了铺满 26 键而把九键回车摊成整宽。
4. 候选栏上方条带仍不归第一行字母（首行保持视觉顶）。
5. 修复只动命中几何与 overlay 同源绘制；不改键高、间距常量、圆角或候选/Path 合同。

## Authorization Source

Human Product Owner，当前会话 `2026-08-15 Asia/Shanghai`：提供截图，点名两则 bug，要求「严格按照 KOS 设定去修复」「不要一开始直接进行修改，也不要靠猜测修改」。

## Explicit non-authorization

- 为了 overlay 好看另算一套矩形
- 重开 `DEBUG-KEY-HITBOX-001` 已关闭的 Product Gate 作为本项验收替代
- 改 Release 可见性、记录键值/坐标、或把 `.gram` / 万象 G2 绑进来

## Revalidation

改变中线规则、把 overlay 接到 hit-test、或把九键改回整行摊平，必须停止并修订本 Decision。
