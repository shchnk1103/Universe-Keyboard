# Product Decision: APP-ACTION-BUTTON-HIT-AREA-001 — 主 App 操作按钮整块可点

**Decision ID:** `PD-APP-ACTION-BUTTON-HIT-AREA-001`
**Lifecycle status:** `Recorded — Product Gate Accepted; Assignment Closed`
**Date / timezone:** `2026-09-28 Asia/Shanghai`
**Assignment:** [`APP-ACTION-BUTTON-HIT-AREA-001`](../assignments/app-action-button-hit-area-001.md)
**Authorization (this slice):** [`AUTH-APP-ACTION-BUTTON-HIT-AREA-001`](../authorizations/AUTH-APP-ACTION-BUTTON-HIT-AREA-001.md)
**Authorization (implementation slice):** [`AUTH-APP-ACTION-BUTTON-HIT-AREA-001-IMPLEMENT`](../authorizations/AUTH-APP-ACTION-BUTTON-HIT-AREA-001-IMPLEMENT.md)
**Authorization (Quality):** [`AUTH-APP-ACTION-BUTTON-HIT-AREA-001-QUALITY`](../authorizations/AUTH-APP-ACTION-BUTTON-HIT-AREA-001-QUALITY.md)
**Quality review:** [`app-action-button-hit-area-001-quality-review.md`](../reviews/app-action-button-hit-area-001-quality-review.md) — **Pass with conditions**
**Authorization (Product Gate):** [`AUTH-APP-ACTION-BUTTON-HIT-AREA-001-PRODUCT-GATE`](../authorizations/AUTH-APP-ACTION-BUTTON-HIT-AREA-001-PRODUCT-GATE.md)
**Product Gate:** [`PD-APP-ACTION-BUTTON-HIT-AREA-001-PRODUCT-GATE`](APP-ACTION-BUTTON-HIT-AREA-001-product-gate.md) — Accepted

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | Recorded — Product Gate Accepted |
| **Phase** | 合同仍有效；Assignment `Closed`（Human Product Gate Passed with accepted evidence conditions） |
| **Non-claims** | 不等于 Device-attested、commit / push / merge、TestFlight 或 Release |
| **Next** | 本 Assignment 无下一步；commit 或发布另需授权 |
| **Residuals** | `AABH-01`–`AABH-05` 已由 Product Gate 接受，边界保持不变 |

---

## Authority

- **Product Approver / Decision maker:** Human Product Owner, acting as Product Lead in the current Grok session (`2026-09-28 Asia/Shanghai`). Human 确认主 App 按钮应在可见区域任意位置生效，并授权 `APP-ACTION-BUTTON-HIT-AREA-001` 记录与实施。
- **Assignment Authority:** Product Lead under [`ASSIGNMENT_POLICY.md`](../ASSIGNMENT_POLICY.md).
- **Domain Owner:** 📱 App & Data Operations Maintainer（主 App 设置 / 同步 / 引导 SwiftUI）
- **Architecture / Quality:** Architecture review **Not Applicable** while the change stays inside existing `AppActionButton` and adds a hit-fill `contentShape` matching the visible capsule. Quality, Performance & Release Maintainer is required after the implementation slice lands. Independent review is **Not Applicable** to this record slice.

This Decision records the **hit-area contract** for main-App content action buttons. The record slice does **not** itself mutate Swift; implementation is authorized by the matching implementation Authorization.

## Product Problem

主 App 内容操作按钮已抽到共享 [`AppActionButton`](../../Universe%20Keyboard/Views/Components/AppActionButton.swift)。可见表面是整块圆角胶囊（iOS 26 Liquid Glass 或实心 fallback），标题和图标居中。Human 观察到几乎只有点到文字才触发。

根因在共享组件：`.buttonStyle(.plain)` 默认只命中 `Label` 的不透明字形，布局上的 `.frame(maxWidth: .infinity)` 没有变成命中形状。`SettingsNavigationLink` 已使用 `.contentShape(Rectangle())`；`AppActionButton` 没有对等规则。问题在共享组件，不是某一页的单点样式。

既有对比度合同 [`PD-APP-ACTION-BUTTON-CONTRAST-001`](APP-ACTION-BUTTON-CONTRAST-001-authorization.md) 仍然有效，本 Decision 不改颜色、玻璃 tint 或 disabled 透明度。

## Bound Product Decisions

Human Product Owner locked:

1. **Shared owner.** 全部主 App 内容操作按钮的命中区域必须由 `AppActionButton` 拥有。禁止只改某一个调用点。
2. **Full visible capsule.** 点按钮可见区域的任意部分都必须触发，包括玻璃空白、图标两侧和上下内边距。
3. **Shape follows chrome.** 命中形状与现有 `cornerRadius: 16` 连续圆角胶囊对齐；不另做更大的不可见热区，也不改视觉尺寸。
4. **Both interaction kinds.** 普通 `Button` 与 `ShareLink` 变体使用同一命中规则。
5. **Scope is main App only.** Keyboard Extension 按键、候选栏不在本合同内。
6. **Contrast contract stays.** 不改 `PD-APP-ACTION-BUTTON-CONTRAST-001` 的颜色、玻璃、Reduce Transparency 或 disabled 透明度。

## Non-goals

- Keyboard Extension 按键或候选命中
- 改变任何按钮的产品语义、默认 prominence、disabled 绑定或同步/下载行为
- 修改对比度 token 或放弃 Liquid Glass
- 新增第二套按钮组件
- 修改 `AppSwitch` / Toggle 合同
- Profile envelope / `.kos/project.json` include
- commit / push / merge / TestFlight / Release

## Related Records

- Visual SoT: [`UI_STYLE_GUIDE.md`](../UI_STYLE_GUIDE.md)
- Contrast contract: [`PD-APP-ACTION-BUTTON-CONTRAST-001`](APP-ACTION-BUTTON-CONTRAST-001-authorization.md)
- Playbook: [`playbooks/main-app-ui.md`](../playbooks/main-app-ui.md)
- Assignment: [`APP-ACTION-BUTTON-HIT-AREA-001`](../assignments/app-action-button-hit-area-001.md)
