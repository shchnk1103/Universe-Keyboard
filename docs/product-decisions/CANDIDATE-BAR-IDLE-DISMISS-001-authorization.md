# Product Decision: CANDIDATE-BAR-IDLE-DISMISS-001 — 空闲候选栏关闭键盘

**Decision ID:** `PD-CANDIDATE-BAR-IDLE-DISMISS-001`
**Lifecycle status:** `Recorded — Product Gate Accepted; Assignment Closed`
**Date / timezone:** `2026-09-28 Asia/Shanghai`
**Assignment:** [`CANDIDATE-BAR-IDLE-DISMISS-001`](../assignments/candidate-bar-idle-dismiss-001.md)
**Authorization (this slice):** [`AUTH-CANDIDATE-BAR-IDLE-DISMISS-001`](../authorizations/AUTH-CANDIDATE-BAR-IDLE-DISMISS-001.md)
**Authorization (implementation):** [`AUTH-CANDIDATE-BAR-IDLE-DISMISS-001-IMPLEMENT`](../authorizations/AUTH-CANDIDATE-BAR-IDLE-DISMISS-001-IMPLEMENT.md)
**Quality review:** [`candidate-bar-idle-dismiss-001-quality-review.md`](../reviews/candidate-bar-idle-dismiss-001-quality-review.md) — **Pass with conditions**
**Authorization (Product Gate):** [`AUTH-CANDIDATE-BAR-IDLE-DISMISS-001-PRODUCT-GATE`](../authorizations/AUTH-CANDIDATE-BAR-IDLE-DISMISS-001-PRODUCT-GATE.md)
**Product Gate:** [`PD-CANDIDATE-BAR-IDLE-DISMISS-001-PRODUCT-GATE`](CANDIDATE-BAR-IDLE-DISMISS-001-product-gate.md) — Accepted

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | Recorded — Product Gate Accepted |
| **Phase** | 合同仍有效；Assignment `Closed`（Human Product Gate Passed with accepted evidence conditions） |
| **Non-claims** | 不等于 Device-attested、commit / push / merge、TestFlight 或 Release |
| **Next** | 本 Assignment 无下一步；commit 另授权；`CBID-CORNER` 另开新工作项 |
| **Residuals** | `CBID-01`–`CBID-04`、`CBID-CORNER` 已由 Product Gate 接受 |

---

## Authority

- **Product Approver / Decision maker:** Human Product Owner, acting as Product Lead in the current Grok session (`2026-09-28 Asia/Shanghai`). Human 确认：联想仍走展开；全布局复用现有展开键；空闲态空心圆箭头关闭键盘；有可展开内容时保持向下箭头展开；下滑不关闭。
- **Assignment Authority:** Product Lead under [`ASSIGNMENT_POLICY.md`](../ASSIGNMENT_POLICY.md).
- **Domain Owner:** ⌨️ Keyboard Experience Maintainer（Keyboard Extension 候选栏 / 手势 / 无障碍）
- **Architecture / Quality:** Architecture review **Not Applicable** while work stays on the existing expand-button slot, does not change KeyboardCore candidate semantics, and calls `UIInputViewController.dismissKeyboard()` only on user tap. Quality, Performance & Release Maintainer is required after the implementation slice lands.

This Decision records the **idle dismiss-keyboard contract**. The record slice does **not** mutate Swift.

## Product Problem

候选栏右侧展开键在没有可展开内容时仍显示向下箭头，没有关闭键盘的入口。全屏聊天或笔记里点输入框外面不方便。Globe 只换输入法。系统 `dismissKeyboard()` 可以请求收起，但当前 UI 没有接到这颗键上。

## Bound Product Decisions

Human Product Owner locked:

1. **Reuse one control.** 继续用现有候选栏右侧展开键（宽度、命中 outset、诊断 overlay 槽位）。不新增第二颗键，不改候选栏高度。
2. **All layouts.** 26 键中文、九键、英文、数字、符号等本键盘所有页面都适用。候选栏本来就在 `rootStack` 里。
3. **Mode switch.**
   - **Expand mode：** 栏上有可展开内容时，图标 `chevron.down`，点按展开/收起候选面板，与现在相同。
   - **Dismiss mode：** 没有可展开内容时，图标 `chevron.down.circle`（空心圆，secondary 色，不要实心），点按调用 `dismissKeyboard()`。
4. **Expandable content includes** RIME 候选、组字/preedit 展示、上屏后联想、待选标点/颜文字。上屏后联想仍在时，右侧**继续是展开**，不是关闭。
5. **Expanded panel.** 面板打开时仍是向上箭头收起。展开态不提供关闭键盘。
6. **Swipe-down.** 仅 Expand mode 保留下滑展开。Dismiss mode 下滑不关闭键盘，只响应点按。
7. **Accessibility.** Expand：`展开更多候选词`。Dismiss：`关闭键盘`。Hint 随模式切换。
8. **Host behavior.** `dismissKeyboard()` 是请求收起。宿主可能立刻再弹出。键面不写解释文案。
9. **No KeyboardCore semantics change.** 不改候选生成、联想合同、RIME session。只改该按钮的呈现与 action。

## Non-goals

- 新的候选栏高度或第二颗关闭键
- Globe / Return 兼关闭
- 下滑关闭
- 展开面板里的关闭
- 联想存在时改成关闭
- KeyboardCore / RimeBridge 语义
- 主 App 设置开关（第一版始终按上述规则）
- commit / push / merge / TestFlight / Release
- 填满 iOS 26 系统圆角键盘顶左右外侧透出的宿主白底（light 更明显、dark 不易察觉）。Human 确认该现象在本切片之前已存在，本切片保持现状。

## Deferred follow-up (after this Assignment Closes)

Human Product Owner, `2026-09-28 Asia/Shanghai`: 键盘顶左右圆角外侧透白保持现状。完成后另开工作项处理该表面，不并进关闭键切片。

## Related Records

- Visual SoT (implementation will amend after code lands): [`UI_STYLE_GUIDE.md`](../UI_STYLE_GUIDE.md) Candidate Bar
- Continuation still owns expand while suggestions show: [`POST_COMMIT_CONTINUATION.md`](../POST_COMMIT_CONTINUATION.md)
- Playbook: [`playbooks/keyboard-ui.md`](../playbooks/keyboard-ui.md)
- Assignment: [`CANDIDATE-BAR-IDLE-DISMISS-001`](../assignments/candidate-bar-idle-dismiss-001.md)
