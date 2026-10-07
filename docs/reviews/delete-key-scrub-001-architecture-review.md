# DELETE-KEY-SCRUB-001 — Independent Architecture Review

## Review identity

| Field | Value |
|---|---|
| Reviewer | 独立 Architecture reviewer（本会话；非 Executor） |
| Date / timezone | `2026-10-07 Asia/Shanghai` |
| Subject | 未提交 V1。工作区 `/private/tmp/universe-keyboard-delete-key-scrub-001`，分支 `grok/delete-key-scrub-001`，基线 `origin/main` `781ca45dfe53cd8d90f49f60370a2efae9d3e749` |
| Authority | [`AUTH-DELETE-KEY-SCRUB-001-ARCHITECTURE`](../authorizations/AUTH-DELETE-KEY-SCRUB-001-ARCHITECTURE.md)（一次审查）。本文件不改 AUTH 的 consumption 字段 |
| Contract | [`PD-DELETE-KEY-SCRUB-001`](../product-decisions/DELETE-KEY-SCRUB-001-product-contract.md) · [`DELETE-KEY-SCRUB-001`](../assignments/delete-key-scrub-001.md) |
| Method | 打开源文件判断。未用 `git diff` 当架构事实。未改 Swift、测试或产品行为。未跑测试，未 commit / push |

本审查 **不授权** Quality、Product Gate、commit、push、merge、TestFlight 或 Release。

## Verdict

**Reject。**

手势骨架（按下不删、松手单击、10pt 播放头、预编辑右滑不删、长按相位不能转擦除、看得见才出气泡、离开 bounds 结束、`touchDragExit` 不结束按住）与合同同向。但当前实现已经跨过必须停的边界，不能当成 Architecture Pass，也不能进入独立 Quality。

### 停止项

| Stop | 是否发生 | 动作 |
|---|---|---|
| 新 host 写入路径 | **是** | 停止。见 DKS-A-01。回放必须改走现有 `KeyboardController` 插入边界；禁止保留 `UIInputViewController.textDocumentProxy.insertText` 这条旁路 |
| `selectAll` | 否 | 删除全部与擦除都没有 `selectAll` |
| 账本落盘 | 否 | `restoreLedger` 只在本次按住的进程内存，结束时 `removeAll` |
| 上传上下文 / ADR 0007 | 否 | 没有把 host 文本写入日志、诊断 payload、磁盘或无障碍 identifier |
| Core 语义越界（Assignment Architecture Stop） | **是** | 停止。见 DKS-A-02。预编辑左滑不得再调用 `abandonCompositionForVisibilityChange()` |

在 DKS-A-01 与 DKS-A-02 从实现中消失之前：不得开独立 Quality，不得 Product Gate，不得 commit / push。修完需要新的 Architecture AUTH；本审查预算已用完。

## Findings

| ID | Severity | File | Why |
|---|---|---|---|
| DKS-A-01 | Blocker / Stop | `Keyboard/Controllers/KeyboardViewController+DeleteActions.swift` | 右滑回放调用系统 `textDocumentProxy.insertText`，绕过 `KeyboardController`。这是第二条 host 写入路径，并且破坏 composition-first |
| DKS-A-02 | Blocker / Stop | 同上，调用 `KeyboardController.abandonCompositionForVisibilityChange()` | 预编辑左滑复用「键盘隐藏/重现」放弃。会清掉整段 marked text（含 Partial Commit 已确认前缀）、销毁第一次 Delete restore checkpoint，并清 continuation / pending / T9 Path |
| DKS-A-03 | High | 同上 `performDeleteAllBeforeCursor` / `deleteOneCommittedGraphemeForScrub` | 两者都走 `handle(.deleteBackward)`。pending 标点/颜表情的 owned span 会先把光标移到 closer 之后再 `deleteBackward`，从而删到光标后。不是 `selectAll`，也没有读 `documentContextAfterInput` |
| DKS-A-04 | Medium | 同上 `showDeleteTrashBubbleIfNeeded` | 剩余高度不够时气泡高度仍至少 18pt，并被夹到键盘顶部，命中区可以盖住删除键。九键右上删除键无法可靠「滑回键上取消清空」 |
| DKS-A-05 | Low | `DeleteRepeatController.begin` 与 `handleDeleteRepeatTick` | 0.5s 回调已经入队后，相位若已离开 `.pressed`，`beginRepeating` 仍会再武装 0.08s。tick 看到相位不对就返回，不会把擦除改成长按删除，但会空转直到下次 `stop` |

## 审查问题

### 1. 手势相位 — 通过，附 DKS-A-04 / DKS-A-05

对照源文件，不是对照测试里的字符串包含关系。

- **按下不删。** `deleteKeyTouchDown` 只 `keyTouchDown`（按下色、缩放、按键音/震动）并 `DeleteRepeatController.begin`。不调用 `performDeleteBackward`。
- **松手单击。** `finishDeleteGesture` 仅在相位仍是 `.pressed` 时删一次。`DeleteRepeatController.initialDelay` 是 0.5s，到点才进入 `.repeating` 并删第一下，不补「单击那一个」。
- **水平 10pt 播放头。** `DeleteScrubPlayhead.horizontalLockPoints` 与 `unitWidthPoints` 都是 10。`targetUnits` 只看相对按下点的左向距离，`Int` 截断，有 `ledgerCap` 64。没有速度项。手指不动就没有新的 move，播放头停。无预编辑时左右过 10pt 都进入 `.scrubCommitted`；右于原点时目标单位为 0，只回放、不额外删。
- **预编辑左滑一次、右滑不删。** 有预编辑时左向锁定才 `abandonActivePreedit`，相位 `.composingCleared`，之后 move 不再处理。右向锁定只进 `.lockedWithoutDelete` 并停掉重复计时；松手不删。预编辑相位不出气泡。
- **长按 0.5s / 0.08s 不能转擦除。** `.repeating` 的 move 只更新气泡悬停。`handleDeleteRepeatStarted` 要求相位仍是 `.pressed`。进入擦除时会 `deleteRepeatController.stop()`。反向成立：重复开始后不会回到播放头。DKS-A-05 是空转，不是相位被改写。
- **气泡条件。** `canShowDeleteTrashBubble` 要求没有预编辑，且 `documentContextBeforeInput` 非空。密码框、光标在开头、空框读不到光标前文字时不出气泡。符号是 template `trash`，无 `UIButton.Configuration`。长按开始后再 0.15s。擦除相位不调度气泡。重复删完预编辑后，若已能看见光标前文字，同一次按住可以再出气泡。
- **离开键盘 bounds。** move 里 `view.bounds.contains` 失败则 `endDeleteGestureSession(.leftKeyboardBounds)`，账本丢弃、已删不回滚。`viewWillDisappear` 路径上的 `cleanupTransientKeyboardState` 调用 `endDeleteGestureSession(.disappeared)`。
- **`touchDragExit` 不结束会话。** `makeDeleteButton` 去掉了会恢复外观并结束按键的 `keyTouchUp`，把 `.touchDragInside/.touchDragOutside/.touchDragExit` 都绑到 `deleteKeyTouchDrag`。`KeyboardTouchCellControl.continueTracking` 离开填缝格时只 `sendActions(.touchDragExit)`，不会 `touchUp`。26 键、九键、数字/符号页的删除键都走 `makeDeleteButton()`。

### 2. 擦除账本没有混进 Partial Commit 的第一次 restore — 通过；checkpoint 是被丢掉的

`DeleteKeyGestureSession.restoreLedger` 是 `[String]`，只在 `deleteOneCommittedGraphemeForScrub` 记录到可见字素时 append。`DeleteScrubPlayhead` 不含文本。回放不调用 `restorePartialCommitCheckpoint`。账本也不写入 `state.partialCommit`。

有 `partialCommit` 时 `hasActivePreedit` 为真，根本不会进入 `.scrubCommitted`，所以擦除循环不会在同一次 `handle(.deleteBackward)` 里先走 checkpoint restore 再把恢复出来的字记进账本。

冲突在另一边：预编辑左滑直接 abandon，把 `partialCommit` 置 `nil`。第一次 Delete restore **不会发生**，也没有和账本混合。见 DKS-A-02。

### 3. 删除全部 — 无 `selectAll`；普通光标后文字删不到；owned span 可以删到光标后

`performDeleteAllBeforeCursor` 最多 256 次 `performDeleteBackward()` → `controller.handle(.deleteBackward)`。源文件中没有 `selectAll`，没有读取 `documentContextAfterInput`，也没有把光标往前扫再删。

光标在开头、字在后面：`documentContextBeforeInput` 为空时气泡条件失败。若仍进入循环，`hasText == true` 会试一次 `deleteBackward`；host 在插入点之前无字时这一下是空操作，`observed == false` 且前后上下文不变就 `break`。这条路径不会把光标后的正文删掉。

DKS-A-03：`handle(.deleteBackward)` 先处理 `deleteOwnedPendingPunctuationIfNeeded` / `deleteOwnedPendingKaomojiIfNeeded`。`removeOwnedHostSpan` 对 `afterCursor` 先 `adjustTextPosition` 再 `deleteBackward`。真实 host 上 `textClientHasCharactersBeforeCursor` 只判断客户端存在，不对账上下文。气泡要求光标前可读且非空，但不排除光标后还有本键盘拥有的 closer。清空的第一下因此可能删掉光标后的成对标点或颜表情，然后才继续删光标前。擦除的第一格也是同一次 `handle`，账本却只记下 `documentContextBeforeInput` 的最后一个 `Character`，右滑会按错误粒度插回去。

这还不构成「用 selectAll / 读完整文档才能声称删除全部」。它是光标后误伤，必须在下一次实现里关掉或由 Product 单独接受为既有 pending-span 语义。在 DKS-A-01/02 修好之前，不要把它写成已接受残差。

### 4. host 文本没有进日志、磁盘或无障碍 identifier — 通过

- 删除会话没有 `Logger`，也没有把 `documentContextBeforeInput` 或账本 token 拼进诊断字符串。`endDeleteGestureSession` 丢弃 `reason`。
- 气泡 `accessibilityLabel` 固定为「删除光标前文字」。没有把 host 文本写入 `accessibilityIdentifier`。播放头类型不含上下文字段。
- 账本在 lift / cancel / bounds / disappear / 新一次 `touchDown`（`.superseded`）时 `discardLedger()`。不写 App Group、不进 `TypingStatisticsStore`。回放旁路也没有走到 `onCommittedText`（该回调才会把 **计数** 交给统计 writer；当前旁路连这个都没走）。统计 writer 本身不存原文，但本切片也没有调用它。
- `documentContextBeforeInput` 只留在栈上，用来决定气泡、比较删前删后、以及取一个字素放进内存账本。`applyAutoCapitalization` 只在英文模式改 shift，不记录原文。
- 系统 proxy 的 `insertText` 不经过 `UITextDocumentProxyAdapter`，因此也不会写入只含 operation/phase、不含正文的 v6 text-proxy marker。没有上传。

内存账本持有已删字素是合同允许的进程内回放，不是 ADR 0007 出境，也不是落盘。

### 5. 回放 `insertText` 绕过 `KeyboardController` — 不通过（DKS-A-01）

`restoreScrubbedGrapheme` 使用 `KeyboardViewController` 继承的系统 `textDocumentProxy.insertText`。现有插入边界是 `KeyboardController.insertText` / `handleInsertDirectText`：先结束活跃组合，再 `textClient.insertText`，然后 `didCommitText`。`textClient` 在 `viewDidLoad` 里才是 `UITextDocumentProxyAdapter`。

旁路的后果：

- Assignment 非目标「不新开第二条 host 写入路径」以及本审查 Stop 已经触发。产品合同里的「insertText 回放」是行为，不是授权绕过 Core。
- `handleInsertDirectText` 在组合仍在时会先按 display/raw 规则收掉组合。系统 `insertText` 不会。擦除入口虽然要求当时没有预编辑，回放本身不再检查 marked text。marked range 还在时，系统插入可能把预编辑上屏或写进 marked range，直接违反 input pipeline 的 composition-first（Delete / 直接文本都必须先让组合拥有这一下）。
- 不发 `didCommitText`，续写状态与 exactly-once commit 观察都看不到这次回放。擦除删除本身会在落到 host `deleteBackward` 时 `clearContinuation()`，回放不会把续写补回来。这是边界漂移，主停止原因仍是新写入路径。

### 6. `abandonCompositionForVisibilityChange` 用于预编辑左滑 — 过宽（DKS-A-02）

该函数的合同是键盘隐藏或再次出现：bump/reset session epoch、`setMarkedText("")`、清空 `currentComposition`、`lastRimeOutput`、`partialCommit`、typo、continuation、pending 标点/颜表情身份、T9 Path。注释写明它不是普通 Delete。

左滑产品语义是：一次丢掉剩余拼音，不上屏，已上屏字不动，右滑不能恢复。Delete 优先级仍是：Partial Commit checkpoint restore → number suffix → RIME composing delete → fallback composition → 最后才 host `deleteBackward`。并且「活跃组合拥有这一下时，不得删掉已提交的 host 文本」。

左滑现在：

- **没有**把剩余拼音 `unmarkText` 上屏。`clearInlinePreedit` 是空 marked text，替换掉而不是确认。停止项「预编辑左滑上屏了剩余拼音」**没有**发生。
- **会**在 Partial Commit 下删掉用户已经看见的确认汉字。确认汉字和剩余拼音在同一段 marked range 里（`partial-commit` / input pipeline）。`setMarkedText("")` 整段消失，而不是只丢掉剩余拼音、留下确认前缀。
- **会**把 checkpoint 置 `nil`，使下一次正常 Delete 的第一次 restore 永久消失。这比「本手势不 restore」更宽：组合状态没了。
- **会**清掉与这次预编辑无关的 continuation 和 pending 身份。pending 正文还在 host 上，但键盘不再拥有这段 span，随后的删除全部/单击会按普通退格处理。
- 对「只有一段未上屏拼音、没有 Partial Commit」的简单情况，丢掉 marked text 且不上屏，方向是对的。实现没有这条窄路径，两条都走 visibility API。

正确的窄操作应只结束剩余组合且不上屏，并保留已确认前缀；不要调用 visibility abandon，也不要走第一次 checkpoint restore（restore 会把 partial 之前的原始输入请回来，和「一次丢掉剩余预编辑」相反）。这个冲突必须在实现里显式处理，不能靠更宽的 API 同时满足。

## Passed boundaries（停止项之外）

- 播放头数学在 KeyboardCore，且不含 host 文本；上限 64 / 清空 256 是有界的。
- 账本不进 Partial Commit 状态，不落盘，不上传。
- 无 `selectAll`。普通「光标在开头」不会靠读后文把后面的字删掉。
- 隐私读取停在进程内比较和内存账本。无障碍文案不含文档内容。
- 删除键页面入口都是 `makeDeleteButton()`。`touchDragExit` 保持按住。
- 按下反馈在删字之前，空框也会响。重复只有观察到删字才 `playRepeatFeedback`；删空后停表、收气泡。

## Evidence boundary

- 事实来自上述 Swift 与 Delete / Partial Commit / ADR 0007 文档，不是 `git diff` 摘要。
- `KeyboardTests/DeleteKeyScrubContractTests.swift` 只断言源码包含/不包含某些字符串。本审查不把它当作行为证据，也没有重跑 KeyboardCore 或 App+Keyboard。
- 未观察真机 Notes / 微信 / Safari / 密码框。那是 Human glance，不是本 Architecture 预算。
- 校验绿、本地测试绿都不是 Quality、Product Gate、merge 或 Release。

## Handoff

- 交给 Executor 的只有两件停止项：去掉系统 proxy `insertText` 旁路；预编辑左滑改成窄 abandon，不得再调用 `abandonCompositionForVisibilityChange()`。DKS-A-03 的光标后 owned span 必须同一轮处理或单独交 Product，不能静默保留。
- 独立 Quality：**不要开始**。当前 AUTH 的 Architecture 结论是 Reject，不是 Pass with conditions。
- 本审查人未改 Swift，未改测试，未 commit / push。
