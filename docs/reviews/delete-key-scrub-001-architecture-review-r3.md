# DELETE-KEY-SCRUB-001 — Architecture Review Round 3

## 结论

**三项停止项已清除。**

这仍不是整项 Architecture Pass。不授权 Quality、Product Gate、commit、push 或 merge。Round 1 保持 Reject 原文。Round 2 不改写。DKS-A-01 / DKS-A-02 本轮不重开：删除键手势仍是 `handle(.insertDirectText)` 与 `dropRemainingPreeditKeepingConfirmedPrefix()`，没有退回系统 proxy `insertText` 或 visibility abandon。

## Review identity

| Field | Value |
|---|---|
| Reviewer | 同一条独立 Architecture 车道（非 Executor） |
| Date / timezone | `2026-10-07 Asia/Shanghai` |
| Authority | [`AUTH-DELETE-KEY-SCRUB-001-ARCHITECTURE-R3`](../authorizations/AUTH-DELETE-KEY-SCRUB-001-ARCHITECTURE-R3.md)。本审查不改该 AUTH 的 status / consumption |
| Worktree | `/private/tmp/universe-keyboard-delete-key-scrub-001`，分支 `grok/delete-key-scrub-001` |
| Scope | 只判断 DKS-A-03、DKS-A-04、DKS-A-05 是否按约定边界从当前源文件消失 |
| Method | 打开当前源文件。未把 Executor 口头说明或测试结果当成架构事实。未重跑测试。未改 Swift、测试或产品文档 |

Executor 提到的 swift-format、KeyboardCore 7 项和 `DeleteKeyScrubContractTests` 3/3（`Test-Universe Keyboard-2026.10.07_10-48-32-+0800.xcresult`）只作背景。本结论不依赖它们，也不把未跑的完整 App+Keyboard 或 Release 补成通过。

## DKS-A-03 — 已清除

擦除与气泡清空不再走会拆 owned span 的 `handle(.deleteBackward)`。

- `deleteOneCommittedGraphemeForScrub` 的可见字素分支和读不到上下文的 blind 分支都是 `performDeleteBackward(..., oneGraphemeBeforeCursor: true)`。
- `performDeleteAllBeforeCursor` 循环里同为 `oneGraphemeBeforeCursor: true`。
- `performDeleteBackward` 在该标志为真时调用 `controller.deleteOneGraphemeBeforeCursor()`，不调用 `controller.handle(.deleteBackward)`。
- `deleteOneGraphemeBeforeCursor()` 先把 `pendingPunctuation` 和 `pendingKaomoji` 置 `nil`，再 `handleDeleteBackward()`。函数体不调用 `removeOwnedHostSpan`。光标后的 closer 不会被先移到光标上再删掉。整段都在光标前的 owned span 只随这一次 `handleDeleteBackward()` 删一个字素，不会整段吞掉。
- 账本仍走原来的擦除记录：观察到删除后，记下删除前 `documentContextBeforeInput` 的最后一个字素。blind 不记文本。本轮不把「先记后删」收成新停止项。

本轮范围外的观察，不构成未清除，也不升成新停止项：单击 `finishDeleteGesture` 在 `.pressed` 时，以及长按 `handleDeleteRepeatTick`，仍调用默认的 `performDeleteBackward()`，即 `controller.handle(.deleteBackward)`。那条路径仍可能一次删掉成对标点或颜表情，包括光标后的 closer。这是约定留下的。

## DKS-A-04 — 已清除

`DeleteTrashBubbleView` 常量是 `preferredHeight` 32、`minimumHeight` 12、`gapAboveKey` 6、`topInset` 2。气泡仍 `addSubview` 在键盘 view 上、删除键上方，可以盖住候选或 Path。没有改键高或候选栏高度。

`showDeleteTrashBubbleIfNeeded` 把可用高度算成 `keyFrame.minY - gapAboveKey - topInset`。不足 `minimumHeight`（12）则这次按住不显示气泡，清空因此不可用。否则高度是 `min(32, 可用高度)`。框的底边在键面之上至少 `gapAboveKey`，顶边不低于 `topInset`；不满足或与键面 `intersects` 则不显示。水平只做左右夹紧，不改变这三条竖直约束。

`deleteBubbleContains` 在点落在删除键面上时直接返回 `false`，再才测气泡框。滑回键面不算进气泡，松手不会因键面与气泡几何重叠而清空。

## DKS-A-05 — 已清除

`DeleteRepeatController.stop()` 先把 `repeatGeneration` 加一，再作废当前 `Timer`。

0.5 秒回调里的 `Task` 在 `onRepeatStarted`、第一次 `repeatAction()`、`beginRepeating` 之前各自核对 `repeatGeneration == generation`。0.08 秒重复 `Timer` 的 `Task` 在 `action()` 之前核对同一 generation。`stop()` 之后已经入队的回调不再开始重复删除，也不会再武装下一段 0.08 秒。

`resumeRepeating` 先 `stop()` 再 `beginRepeating`，用新 generation 继续 0.08 秒。这是约定行为，不是漏洞。

## 明确不包含

- 不是整项 Architecture Pass。Round 1 的其余手势、隐私和 Partial Commit 叙述没有在本轮重审。
- DKS-A-01、DKS-A-02 不重开。
- 单击 / 长按仍可能删掉光标后 closer。这是范围外观察，不是本轮失败。
- 不得开 Quality，不得 commit / push / merge。
