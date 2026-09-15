# Product Decision: APP-SWITCH-CONTRAST-001 — 主 App 系统开关深浅色对比度

**Decision ID:** `PD-APP-SWITCH-CONTRAST-001`
**Lifecycle status:** `Recorded — Product Gate Accepted; Assignment Closed`
**Date / timezone:** `2026-09-15 Asia/Shanghai`
**Assignment:** [`APP-SWITCH-CONTRAST-001`](../assignments/app-switch-contrast-001.md)
**Authorization (this slice):** [`AUTH-APP-SWITCH-CONTRAST-001`](../authorizations/AUTH-APP-SWITCH-CONTRAST-001.md)
**Authorization (ASC-02 local commit):** [`AUTH-APP-SWITCH-CONTRAST-001-COMMIT`](../authorizations/AUTH-APP-SWITCH-CONTRAST-001-COMMIT.md)
**Authorization (Product Gate):** [`AUTH-APP-SWITCH-CONTRAST-001-PRODUCT-GATE`](../authorizations/AUTH-APP-SWITCH-CONTRAST-001-PRODUCT-GATE.md)
**Product Gate:** [`PD-APP-SWITCH-CONTRAST-001-PRODUCT-GATE`](APP-SWITCH-CONTRAST-001-product-gate.md) — Accepted

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | Recorded — Product Gate Accepted |
| **Phase** | 合同仍有效；Assignment `Closed`（Human Product Gate Passed with accepted evidence conditions） |
| **Non-claims** | 不等于 Device-attested、commit / push / merge、TestFlight 或 Release |
| **Next** | 本 Assignment 无下一步；发布或 Release 另需授权 |
| **Residuals** | `ASC-01`–`ASC-05` 已由 Product Gate 接受，边界保持不变 |

---

## Authority

- **Product Approver / Decision maker:** Human Product Owner, acting as Product Lead in the current Grok session (`2026-09-15 Asia/Shanghai`). Human 认可深色开启态小圆点须与轨道对比，并授权记录 Assignment；明确要求通过共享组件覆盖全部主 App 开关，而不是只改截图中的「上屏后联想」。
- **Assignment Authority:** Product Lead under [`ASSIGNMENT_POLICY.md`](../ASSIGNMENT_POLICY.md).
- **Domain Owner:** 📱 App & Data Operations Maintainer（主 App 设置 / 诊断 SwiftUI）
- **Architecture / Quality:** Architecture review **Not Applicable** while the Form crash contract is preserved (system `UISwitch`, no custom-drawn `ToggleStyle`). Quality, Performance & Release Maintainer is required after an implementation slice is authorized. Independent review is **Not Applicable** to this record slice.

This Decision records the **visual contract** for main-App switches. The original
record slice did not authorize implementation; implementation and the bounded
Product Gate are now recorded separately. This Decision still does not authorize
push, merge, TestFlight or Release.

## Product Problem

主 App 开关沿用系统 `Toggle` + `.toggleStyle(.switch)`，并叠加页面级 `.tint(.primary)` 以保持黑白强调。浅色开启态（黑槽 + 白点）可读。深色开启态轨道变成白色，系统小圆点仍为白色，圆点与轨道融为一体，开启态几乎无法辨认。Human 用浅色 / 深色截图确认该回归出现在设置页「上屏后联想」行，并要求全量开关一致，而不是单点修补。

既有约束（[`UI_STYLE_GUIDE.md`](../UI_STYLE_GUIDE.md)、[`DEBUGGING.md`](../DEBUGGING.md)）：Form 内手绘自定义 `ToggleStyle` 曾与 `SwiftUI.AsyncRenderer` / libdispatch 崩溃相关，**不得**为改颜色而重新引入。

## Bound Product Decisions

Human Product Owner locked:

1. **Shared owner.** 全部主 App 开关的开启/关闭外观必须由共享组件（或该组件暴露的单一 style / helper）拥有。禁止只改 `SettingsTab` 截图行，或在个别页面手写颜色。
2. **Contrast pair (not “dark thumb always black”).** 小圆点必须与当前轨道对比，而不是在深色模式固定黑色：
   - 浅色开启：黑槽 + 白点（保持现状）
   - 深色开启：白槽 + 黑点
   - 浅色关闭：浅槽 + 白点
   - 深色关闭：深槽 + 白点（关闭态不得改成黑点）
3. **System switch chrome.** 继续使用系统 `UISwitch` 公开 tint（`onTintColor` / `thumbTintColor` 或等价 SwiftUI 映射）。禁止用 Capsule / ZStack / 自绘圆点实现开关。
4. **Form crash contract unchanged.** 诊断页与其它 `Form` 仍遵守：系统 `UISwitch`（通过共享 `.appSwitch` style）、不因主开关插拔 Section、不加主开关驱动的 `.animation`。任何实施若再现 `AsyncRenderer` / libdispatch 断言，必须回退并升级，不得带病合并。
5. **Scope is main App only.** Keyboard Extension 不在本合同内。

## This slice vs implementation

At creation time, this Decision **recorded** the product contract and authorized
creating Assignment `APP-SWITCH-CONTRAST-001` in `Ready`; it did **not** authorize
Swift implementation, migrating call sites, updating `UI_STYLE_GUIDE.md` as if the
code already matched, commit, push, merge, TestFlight or Release. The later
implementation and Product Gate authorizations are linked above.

## Non-goals

- Keyboard Extension 开关或键盘按键外观
- 引入品牌强调色，或把开启态改回系统绿
- 重新手绘 `ToggleStyle`
- 改变任何开关的产品语义、默认值、绑定或 gated-child 插拔规则
- 关闭既有 Form crash 合同
- Profile envelope / `.kos/project.json` include
- commit / push / merge / TestFlight / Release

## Related Records

- Visual SoT (implementation will amend after code lands): [`UI_STYLE_GUIDE.md`](../UI_STYLE_GUIDE.md)
- Crash contract: [`DEBUGGING.md`](../DEBUGGING.md)
- Playbook: [`playbooks/main-app-ui.md`](../playbooks/main-app-ui.md)
- Assignment: [`APP-SWITCH-CONTRAST-001`](../assignments/app-switch-contrast-001.md)
- ASC-02 local commit authorization: [`AUTH-APP-SWITCH-CONTRAST-001-COMMIT`](../authorizations/AUTH-APP-SWITCH-CONTRAST-001-COMMIT.md)
- ASC-02 implementation identity: `5d3880b13109a65b8e441ded74b82f9927ffb9b4` on `codex/app-switch-contrast-001-asc02`
- Human Product Gate authorization: [`AUTH-APP-SWITCH-CONTRAST-001-PRODUCT-GATE`](../authorizations/AUTH-APP-SWITCH-CONTRAST-001-PRODUCT-GATE.md)
- Human Product Gate decision: [`PD-APP-SWITCH-CONTRAST-001-PRODUCT-GATE`](APP-SWITCH-CONTRAST-001-product-gate.md)
