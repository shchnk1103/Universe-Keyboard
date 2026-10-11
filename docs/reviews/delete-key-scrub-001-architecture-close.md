# DELETE-KEY-SCRUB-001 — Architecture Close

## 结论

**Architecture Pass with conditions。**

当前整项结论是本页，不是 Round 1。Round 1 原文仍是 Reject，只作历史记录。本 Pass 不授权 Quality、Product Gate、commit、push 或 merge。未跑完整 App+Keyboard，也未跑 Release，这两项不算通过。

条件是下面两件残留。disposition：**接受，留在本切片，不挡 Quality 的开启讨论。** 它们不是未清除的停止项。

| ID | 残留 | Disposition |
|---|---|---|
| DKS-CLOSE-01 | 单击 `finishDeleteGesture`（`.pressed`）和长按 `handleDeleteRepeatTick` 仍走默认 `performDeleteBackward()` / `controller.handle(.deleteBackward)`。成对标点或颜表情仍可能一次删掉两侧，包括光标后的 closer。擦除与气泡清空走 `deleteOneGraphemeBeforeCursor()`，不在此列 | 接受，留在本切片 |
| DKS-CLOSE-02 | 预编辑左滑 `dropRemainingPreeditKeepingConfirmedPrefix()` 会重置 RIME session 并清 T9 Path。同时保留 `confirmedText` 与 checkpoint，用 marked text 换掉或清空剩余拼音而不上屏，不清 continuation / pending。Round 2 已接受 | 接受，留在本切片；不升成新停止项 |

## 如何接成

本页不重审整项手势、隐私或 Partial Commit，也不新开 DKS-A-06。当前源文件里，五项清除仍与 Round 2 / Round 3 一致：

- Round 1「Passed boundaries」仍是手势相位、播放头、隐私账本、无 `selectAll`、`touchDragExit`、按下反馈的依据。本页不重走查。
- DKS-A-01：`restoreScrubbedGrapheme` 仍是 `controller.handle(.insertDirectText)`。删除键手势文件没有 `textDocumentProxy.insertText`。
- DKS-A-02：`abandonActivePreedit` 仍只调用 `dropRemainingPreeditKeepingConfirmedPrefix()`，不调用 `abandonCompositionForVisibilityChange()`。
- DKS-A-03：擦除与 `performDeleteAllBeforeCursor` 仍传 `oneGraphemeBeforeCursor: true`。`deleteOneGraphemeBeforeCursor()` 先把 pending 置 `nil`，再 `handleDeleteBackward()`，不调用 `removeOwnedHostSpan`。
- DKS-A-04：气泡常量仍是 32 / 12 / 6 / 2。可用高度不足 12pt 不显示；否则 `min(32, 可用高度)`，并满足顶边、键上缝隙、不与键面相交。点在键面上 `deleteBubbleContains` 为 false。
- DKS-A-05：`stop()` 仍递增 `repeatGeneration`。0.5 秒回调在开始、第一次删除、再武装之前核对；0.08 秒回调在 `action()` 之前核对。`resumeRepeating` 先 `stop()` 再以新 generation 继续。

## 边界

- 授权：[`AUTH-DELETE-KEY-SCRUB-001-ARCHITECTURE-CLOSE`](../authorizations/AUTH-DELETE-KEY-SCRUB-001-ARCHITECTURE-CLOSE.md)。本页不改该 AUTH 的 status / consumption。
- 未改 Round 1 / Round 2 / Round 3 原文，未改 Swift、测试、Assignment 或其他文档。
- 未启动 Quality。
