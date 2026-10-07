# DELETE-KEY-SCRUB-001 — Architecture Review Round 2

## Review identity

| Field | Value |
|---|---|
| Reviewer | 同一条独立 Architecture 车道（非 Executor） |
| Date / timezone | `2026-10-07 Asia/Shanghai` |
| Authority | [`AUTH-DELETE-KEY-SCRUB-001-ARCHITECTURE-R2`](../authorizations/AUTH-DELETE-KEY-SCRUB-001-ARCHITECTURE-R2.md) |
| Prior record | [`delete-key-scrub-001-architecture-review.md`](delete-key-scrub-001-architecture-review.md) 保持 Round 1 **Reject** 原文。本轮不改写它 |
| Scope | 只判断 DKS-A-01 与 DKS-A-02 是否已从当前源文件消失 |
| Method | 打开当前源文件。未改 Swift、测试或产品行为。未 commit / push。未重跑测试 |

本轮 **不是** 整项 Architecture Pass。不授权 Quality、Product Gate、commit、push 或 merge。

## Verdict

**两项停止项已清除。**

DKS-A-03、DKS-A-04、DKS-A-05 本轮不重开，也不标成已接受。它们仍然开放。不得据此开独立 Quality 或 commit。

## DKS-A-01 — 已清除

`Keyboard/Controllers/KeyboardViewController+DeleteActions.swift` 的 `restoreScrubbedGrapheme` 现在是：

- 空 token 或仍有预编辑时直接返回，不写 host。
- 否则 `controller.handle(.insertDirectText(token))`，再 `syncUI`。

该文件里已经没有 `textDocumentProxy.insertText`，也没有别的 `UIInputViewController` proxy 插入。

`handle(.insertDirectText)` 仍进现有边界：`acceptingPendingPunctuationIfNeeded` → `handleInsertDirectText` → `KeyboardController.insertText`（`textClient.insertText` + `didCommitText`）。有活跃 `currentComposition` 时先收组合再插入。这是 composition-first 的原插入路径，不是 Round 1 那条系统 proxy 旁路。

`abandonCompositionForVisibilityChange()` 仍留在可见性生命周期（Bootstrap / ModeActions）。删除键手势文件不再调用它。

## DKS-A-02 — 已清除

`abandonActivePreedit` 只调用 `controller.dropRemainingPreeditKeepingConfirmedPrefix()`。删除键手势文件不再调用 `abandonCompositionForVisibilityChange()`。

`KeyboardController.dropRemainingPreeditKeepingConfirmedPrefix()` 对照三项要求：

- **不上屏剩余拼音。** 有确认前缀时 `updateInlinePreedit(confirmed)`，只把 marked text 换成确认前缀，没有 `unmarkText`，也没有把剩余拼音交给 `insertText`。没有 Partial Commit 时 `deleteInlinePreedit()`（空 `setMarkedText`），丢弃 marked text 而不是确认它。
- **保留 `confirmedText` 与 checkpoint。** `partialCommit` 非空时写回同一个 `confirmedText`、原来的 `checkpoint` 和 `source`。`remainingRawInput` / `remainingPreeditText` 清空，`displayText` 改为确认前缀。checkpoint 没有被置 `nil`。
- **不清空 continuation 和 pending。** 函数不写 `state.continuation`、`state.pendingPunctuation`、`state.pendingKaomoji`。

它仍会 reset / bump RIME session、清空 `currentComposition` 与 `lastRimeOutput`、清 typo 建议，并清 T9 Path。这是丢掉剩余预编辑的会话重置，不是可见性 abandon 那种把 checkpoint、continuation、pending 一起清掉。本轮授权只核上面三项；不把 Path 清零升成新 finding。

## 明确不包含

- Round 1 全文仍是 Reject。本文件只说明两项停止项已从当前实现消失。
- DKS-A-03（删除全部 / 擦除可能经 pending owned span 删到光标后）、DKS-A-04（气泡可能盖住删除键）、DKS-A-05（重复计时器空转）状态不变，未接受。
- 未做整项手势、隐私、Partial Commit 交互的再审。
- 不得开 Quality，不得 commit / push / merge。
