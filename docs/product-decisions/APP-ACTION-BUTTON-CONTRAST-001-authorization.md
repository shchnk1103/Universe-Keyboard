# Product Decision: APP-ACTION-BUTTON-CONTRAST-001 — 主 App 操作按钮深浅色对比度

**Decision ID:** `PD-APP-ACTION-BUTTON-CONTRAST-001`
**Lifecycle status:** `Recorded — Product Gate Accepted; Assignment Closed`
**Date / timezone:** `2026-09-23 Asia/Shanghai`
**Assignment:** [`APP-ACTION-BUTTON-CONTRAST-001`](../assignments/app-action-button-contrast-001.md)
**Authorization (this slice):** [`AUTH-APP-ACTION-BUTTON-CONTRAST-001`](../authorizations/AUTH-APP-ACTION-BUTTON-CONTRAST-001.md)
**Authorization (implementation slice):** [`AUTH-APP-ACTION-BUTTON-CONTRAST-001-IMPLEMENT`](../authorizations/AUTH-APP-ACTION-BUTTON-CONTRAST-001-IMPLEMENT.md)
**Authorization (Quality):** [`AUTH-APP-ACTION-BUTTON-CONTRAST-001-QUALITY`](../authorizations/AUTH-APP-ACTION-BUTTON-CONTRAST-001-QUALITY.md)
**Quality review:** [`app-action-button-contrast-001-quality-review.md`](../reviews/app-action-button-contrast-001-quality-review.md) — **Pass with conditions**
**Authorization (Product Gate):** [`AUTH-APP-ACTION-BUTTON-CONTRAST-001-PRODUCT-GATE`](../authorizations/AUTH-APP-ACTION-BUTTON-CONTRAST-001-PRODUCT-GATE.md)
**Product Gate:** [`PD-APP-ACTION-BUTTON-CONTRAST-001-PRODUCT-GATE`](APP-ACTION-BUTTON-CONTRAST-001-product-gate.md) — Accepted

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | Recorded — Product Gate Accepted |
| **Phase** | 合同仍有效；Assignment `Closed`（Human Product Gate Passed with accepted evidence conditions） |
| **Non-claims** | 不等于 Device-attested、commit / push / merge、TestFlight 或 Release |
| **Next** | 本 Assignment 无下一步；commit 或发布另需授权 |
| **Residuals** | `AABC-01`–`AABC-06` 已由 Product Gate 接受，边界保持不变 |

---

## Authority

- **Product Approver / Decision maker:** Human Product Owner, acting as Product Lead in the current Grok session (`2026-09-23 Asia/Shanghai`). Human 用同步页「立即同步」截图确认：深色下 primary 几乎看不见，浅色下可点击却呈灰色；要求在保留 Liquid Glass 的前提下重做颜色，并锁定可点击 primary 为浅色黑底白字、深色白底黑字。`2026-09-23 Asia/Shanghai` 第二次指示确认补充态并授权实施。
- **Assignment Authority:** Product Lead under [`ASSIGNMENT_POLICY.md`](../ASSIGNMENT_POLICY.md).
- **Domain Owner:** 📱 App & Data Operations Maintainer（主 App 设置 / 同步 / 引导 SwiftUI）
- **Architecture / Quality:** Architecture review **Not Applicable** while the change stays inside existing `AppActionButton` + `glassEffect(.regular.interactive())` and does not invent a second button family. Quality, Performance & Release Maintainer is required after an implementation slice is authorized. Independent review is **Not Applicable** to this record slice.

This Decision records the **visual contract** for main-App content action buttons. This record slice does **not** authorize Swift, style-guide rewrite as if implemented, commit, push, merge, TestFlight or Release.

## Product Problem

主 App 内容操作按钮已抽到共享 [`AppActionButton`](../../Universe%20Keyboard/Views/Components/AppActionButton.swift)，iOS 26 走 `glassEffect(.regular.tint(...).interactive())`。当前 primary 固定：

- 玻璃 tint：`.black.opacity(0.60)`
- 文字：始终 `.white`
- iOS 18 fallback：实心 `.black`

深色模式下 60% 黑玻璃叠在 grouped 深色底上几乎消失（Human 截图 1）。浅色模式下半透明黑玻璃合成成中灰胶囊，可点击却像禁用（Human 截图 2，「立即同步」）。根因在共享组件，不是同步页单点样式。

既有约束（[`UI_STYLE_GUIDE.md`](../UI_STYLE_GUIDE.md)）：中性黑白灰层次、不引入品牌强调色、明确页内命令必须走 `AppActionButton`、与 [`APP-SWITCH-CONTRAST-001`](../assignments/app-switch-contrast-001.md) 的深浅反转配对保持同一套对比语言。

## Bound Product Decisions

Human Product Owner locked:

1. **Shared owner.** 全部主 App 内容操作按钮的可点击/禁用外观必须由 `AppActionButton` 拥有。禁止只改同步页「立即同步」，或在页面手写 `.borderedProminent` / 实心灰胶囊。
2. **Primary enabled pair (Human lock).** 可点击 primary 必须与当前外观对比，而不是永远黑底白字：
   - 浅色可点击：黑底 + 白字
   - 深色可点击：白底 + 黑字
3. **Liquid Glass remains the iOS 26 material.** 继续使用 `.glassEffect(.regular.tint(...).interactive())`。tint 必须足够不透明，使 primary 读成黑/白实心，同时保留玻璃高光与按压缩放；禁止为对比度改回无材质灰胶囊。
4. **Scope is main App only.** Keyboard Extension 按键、候选栏不在本合同内。

Human confirmed the following supplements on `2026-09-23 Asia/Shanghai` before implementation:

5. **Primary tokens.** iOS 26 glass tint = `Color.primary`（即 label：浅色黑、深色白）opacity `0.92`；文字 = `Color(uiColor: .systemBackground)`。iOS 18 fallback 用实心 `Color.primary` + 同样反色文字，无描边。
6. **Secondary enabled.** 安静但必须看得出能点：iOS 26 用近无 tint 的 `.regular.interactive()` 玻璃板 + `.primary` 文字；浅色不要再铺一层 tertiary 灰底，深色要有足够抬升以免融进 grouped 底。iOS 18 fallback：`secondarySystemGroupedBackground` + `.primary` 文字 + `0.5 pt` separator。
7. **Destructive enabled.** 保持语义红，不走黑白反转。iOS 26：`.red` tint opacity `0.22`（深色可到 `0.28`）+ 红字；iOS 18：红 `0.12` 底 + 红字 + 浅红描边。
8. **Disabled / busy.** 整控件 opacity `0.40`，颜色对仍与 enabled 相同（浅色黑底白字的淡化版，深色白底黑字的淡化版）。不要另做一套中灰填充，以免和当前「可点击却发灰」回归混淆。同步中的 ProgressView 继续放在状态行，按钮本身只进入 disabled。
9. **Pressed.** 只使用 glass `.interactive()`（及现有 `AppPressableButtonStyle` 若已套用）。禁止再叠一层灰色 overlay。
10. **Reduce Transparency.** `accessibilityReduceTransparency == true` 时，即使在 iOS 26 也走实心 fallback，避免玻璃把黑/白对比洗掉。
11. **Neutral palette.** 不引入品牌强调色。Destructive 红是既有语义例外，不是新 accent。

## This slice vs implementation

The record slice created the Assignment in `Ready`. Human later locked supplements 5–11 and authorized [`AUTH-APP-ACTION-BUTTON-CONTRAST-001-IMPLEMENT`](../authorizations/AUTH-APP-ACTION-BUTTON-CONTRAST-001-IMPLEMENT.md). This Decision still does not authorize Quality, Product Gate, commit, push, merge, TestFlight or Release.

## Non-goals

- Keyboard Extension 按键或候选外观
- 引入品牌强调色或系统蓝 prominent
- 放弃 Liquid Glass，或新增第二套按钮组件
- 改变任何按钮的产品语义、默认 prominence、disabled 绑定或同步/下载行为
- 修改 `AppSwitch` / Toggle 合同
- Profile envelope / `.kos/project.json` include
- commit / push / merge / TestFlight / Release

## Related Records

- Visual SoT (implementation will amend after code lands): [`UI_STYLE_GUIDE.md`](../UI_STYLE_GUIDE.md)
- Playbook: [`playbooks/main-app-ui.md`](../playbooks/main-app-ui.md)
- Precedent contrast pair: [`APP-SWITCH-CONTRAST-001`](../assignments/app-switch-contrast-001.md)
- Assignment: [`APP-ACTION-BUTTON-CONTRAST-001`](../assignments/app-action-button-contrast-001.md)
- Sync surface that exhibited the bug: [`RimeSyncSettingsView.swift`](../../Universe%20Keyboard/Views/Settings/RimeSyncSettingsView.swift)（调用点，不是样式所有者）
