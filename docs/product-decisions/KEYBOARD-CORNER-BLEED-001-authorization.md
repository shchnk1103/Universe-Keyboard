# Product Decision: KEYBOARD-CORNER-BLEED-001 — 键盘顶圆角透白

**Decision ID:** `PD-KEYBOARD-CORNER-BLEED-001`
**Lifecycle status:** `Recorded — Closed; keep transparent; no implementation`
**Date / timezone:** `2026-09-28 Asia/Shanghai`
**Assignment:** [`KEYBOARD-CORNER-BLEED-001`](../assignments/keyboard-corner-bleed-001.md)
**Authorization (this slice):** [`AUTH-KEYBOARD-CORNER-BLEED-001`](../authorizations/AUTH-KEYBOARD-CORNER-BLEED-001.md)
**Authorization (close):** [`AUTH-KEYBOARD-CORNER-BLEED-001-CLOSE`](../authorizations/AUTH-KEYBOARD-CORNER-BLEED-001-CLOSE.md)
**Parent residual:** `CBID-CORNER` on Closed [`CANDIDATE-BAR-IDLE-DISMISS-001`](../assignments/candidate-bar-idle-dismiss-001.md)

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | Recorded — Closed |
| **Phase** | Human 锁定保持透明；Assignment `Closed`；无实施 |
| **Non-claims** | 不等于填灰、commit / push / merge、TestFlight 或 Release |
| **Next** | 无（本 Assignment）。关闭记录已 squash-merge `72dd21710f2a86c9f951d489f645bae89b053b58` |
| **Residuals** | None |

---

## Authority

- **Product Approver / Decision maker:** Human Product Owner, acting as Product Lead (`2026-09-28 Asia/Shanghai`). Human 确认该透白在关闭键切片之前已存在，light 更明显、dark 肉眼难察；关闭键工作 Closed 后授权开本跟进切片。
- **Assignment Authority:** Product Lead under [`ASSIGNMENT_POLICY.md`](../ASSIGNMENT_POLICY.md).
- **Domain Owner:** ⌨️ Keyboard Experience Maintainer
- **Architecture / Quality:** Architecture review **Not Applicable** while the change only fills the existing rectangular input-view backing behind the system rounded container, without a second `cornerRadius` chrome. Quality is required after implementation.

This Decision records the **top-corner host-bleed contract**. The record slice does **not** mutate Swift.

## Product Problem

iOS 26 把自定义键盘收成圆角卡片。扩展根视图目前是透明的（`view.backgroundColor = .clear`），表面也不再自画圆角，避免和第二层系统容器打架。light 模式下，矩形输入区域顶左右圆角外侧会透出宿主页面白底，看起来像键盘顶角有两块白。dark 模式几乎看不出。关闭键切片未改表面，Human 目视确认旧版本同样存在。

## Bound Product Decisions

1. **Keep transparent.** 输入视图 backing 保持 `view.backgroundColor = .clear`。不填 `keyboardBackgroundColor`。顶左右圆角外侧透出的是宿主页面，随 App 变化，这是目标观感。
2. **Do not add a second rounded frame.** 保持 `keyboardSurfaceView.layer.cornerRadius = 0`。
3. **Idle dismiss stays.** 不改候选栏右侧关闭/展开双模。
4. **Host-owned fillets.** 某些宿主在系统圆角卡片外仍画一层矩形底色。那是系统和宿主窗口，扩展画不到。系统键盘与搜狗同样会出现。不作为本键盘的适配缺口。

## Non-goals

- 第二套圆角玻璃框
- 改关闭键、候选栏、按键颜色
- 改 KeyboardCore / RimeBridge
- 主 App
- commit / push / merge / TestFlight / Release

## Related Records

- Parent residual: [`PD-CANDIDATE-BAR-IDLE-DISMISS-001`](CANDIDATE-BAR-IDLE-DISMISS-001-authorization.md) Deferred follow-up / Gate `CBID-CORNER`
- Surface owner: [`KeyboardViewController+KeyStyle.swift`](../../Keyboard/Controllers/KeyboardViewController+KeyStyle.swift) `applyKeyboardSurfaceStyle()`
- Playbook: [`playbooks/keyboard-ui.md`](../playbooks/keyboard-ui.md)
- Assignment: [`KEYBOARD-CORNER-BLEED-001`](../assignments/keyboard-corner-bleed-001.md)
