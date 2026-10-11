**Pass。** 跟进差值与约定一致：气泡计时只武装一次并挂在 `RunLoop` `.common`，iOS 26 底板为 regular `UIGlassEffect`，删除发声按按下 / 单击 / 连删 / 擦除 / 进入气泡 / 清空分开。本车道 `swift-format lint --strict` 与 `DeleteKeyScrubContractTests` 3/3、0 失败。这不是 V1 重审，不是 Product Gate，不是 commit / push / merge，也不是本车道的真机作证。

# DELETE-KEY-SCRUB-001 — 跟进差值独立 Quality Review

审查日期：2026-10-07 Asia/Shanghai。审查者未实现这一小段，未使用 git `/review`。授权是 [`AUTH-DELETE-KEY-SCRUB-001-FOLLOWUP-QUALITY`](../authorizations/AUTH-DELETE-KEY-SCRUB-001-FOLLOWUP-QUALITY.md)（active / unconsumed）。本页不改该授权，不把它标成已消费，也不改 Assignment、ACTIVE_WORK、dashboard、Swift 或测试。历史审查 [`delete-key-scrub-001-quality-review.md`](delete-key-scrub-001-quality-review.md) 仍是第一段的 Pass with conditions（无真实点按，DKS-CLOSE-01/02），本页不改写它。

## Scope

隔离工作树 `/private/tmp/universe-keyboard-delete-key-scrub-001`，分支 `grok/delete-bubble-001`。只审 `git diff 1560488664f6e51450a441f14e465760c0635820..f94a8a773a2957c4fad2e96fca6980baeb019697`。不重审整段 V1 手势。

身份与冻结值一致，未因不符而 Blocked：

| 检查 | 结果 |
|---|---|
| `git rev-parse HEAD` | `f94a8a773a2957c4fad2e96fca6980baeb019697` |
| `git merge-base HEAD origin/main` | `1560488664f6e51450a441f14e465760c0635820` |
| 内容 commit | `252d72666070372b7d92b473d75aea3a156071ee`（气泡计时、玻璃、发声、合同测试与对应账本） |
| `f94a8a7` | 仅 docs SHA 回写（ACTIVE_WORK、dashboard、Knowledge Index、Assignment、FOLLOWUP-COMMIT）。无 Swift |

`git show --stat` 与上述划分一致。主 checkout `/Users/doubleshy0n/Dev/Universe Keyboard` 未改。未跟踪且未动：`Packages/RimeBridge/Vendor`（指向主 checkout 的符号链接，不是产品）、`docs/authorizations/AUTH-DELETE-KEY-SCRUB-001-IMPLEMENT-MERGE.md`、本车道 AUTH。本审查唯一新增文件是本页。

## 复现的 SHA-256

`git show HEAD:<path> | shasum -a 256` 与工作区 `shasum -a 256` 在测试前一致。测试后再哈希四个 Swift 文件与样式指南，字节未变。

| Path | SHA-256 |
|---|---|
| `Keyboard/Controllers/KeyboardViewController+DeleteActions.swift` | `860c4482d7f944cf82d706edd27b69fe310c3b234b6bbfa5118f1281c0382b6d` |
| `Keyboard/Controllers/KeyboardViewController+Feedback.swift` | `359a7f0816e8f0656bf1082535ab1ac2cfada210cb007385d9b7e85055cfc2c5` |
| `Keyboard/Views/DeleteTrashBubbleView.swift` | `dd44129744a5e60ae9099f02a1f73f928508aa7a606b74adcc6f0a065bf9765a` |
| `KeyboardTests/DeleteKeyScrubContractTests.swift` | `fa1268f53ba69778894402e0d17f37d85d609efc0858489507790ed987cee709` |
| `docs/UI_STYLE_GUIDE.md` | `b0db835491771637b1fa280509978ffcd8cc27d5bcc8ad6121266cc592624db9` |

## 证据

| 检查 | 结果 |
|---|---|
| `xcrun swift-format lint --strict --configuration .swift-format`，指定的三个文件：`KeyboardViewController+Feedback.swift`、`KeyboardViewController+DeleteActions.swift`、`DeleteKeyScrubContractTests.swift` | 退出码 0 |
| 同上 lint，附加只读：`DeleteTrashBubbleView.swift`（不在指定命令里；该文件也改了） | 退出码 0 |
| `xcodebuild` scheme `Universe Keyboard`，Debug，`-only-testing:KeyboardTests/DeleteKeyScrubContractTests`，`-parallel-testing-enabled NO`，`CODE_SIGNING_ALLOWED=NO`，`SWIFT_VERSION=6.0`，`SWIFT_STRICT_CONCURRENCY=complete`，警告当错误 | 日志 `/tmp/dks-followup-quality-contract.log`。`** TEST SUCCEEDED **`。`DeleteKeyScrubContractTests` 执行 3 项，0 失败（0 unexpected），约 0.030 秒。xcresult：`/Users/doubleshy0n/Library/Developer/Xcode/DerivedData/Universe_Keyboard-dirkeqcodnjdlsfgvagkefuqzywf/Logs/Test/Test-Universe Keyboard-2026.10.07_12-42-44-+0800.xcresult` |
| 目的地 | 已启动的 iPhone 18 Pro `405D994F-28CB-4F89-BB22-B64AD81C05A2`。未改用 iPhone 17 Pro |
| 测试后四个 Swift 文件与 `docs/UI_STYLE_GUIDE.md` | SHA-256 与上表相同 |

日志经 `tee` 写出。外壳在管道后再 `echo`，所以不能把外壳最终退出码当成 xcodebuild 的退出码。xcodebuild 的成功证据是日志中的 `** TEST SUCCEEDED **` 与 0 失败；该结果对应退出码 0。

跳过，因为本 AUTH 只覆盖这一小段：完整 App+Keyboard 套件、KeyboardCore `swift test`、Release build。未跑，不能当成已绿。

## 本差值里通过的行为

对照 `1560488..f94a8a7` 的源码，不是整段 V1 重读。

- 气泡计时：`scheduleDeleteTrashBubble` 在 `deleteBubbleTimer == nil` 且气泡尚未可见时才创建。0.08 秒重复 tick 再进来会直接返回，不再 `invalidate` 后重装 0.15 秒计时器。计时器只加入 `RunLoop.main` 的 `.common`。触发后的 `Task { @MainActor }` 在同一次主 actor 周转里先把 `deleteBubbleTimer` 置 `nil`，再 `showDeleteTrashBubbleIfNeeded()`；置空到 `bubbleVisible = true` 之间没有挂起点，重复 tick 不能在这一窗再武装一次。
- 玻璃：iOS 26 且未开减弱透明度时，底板是 `UIGlassEffect(style: .regular)`。手指在内时玻璃 `tintColor` 为带 alpha 的 `systemRed`，符号为 `systemRed`。减弱透明度走实色（`secondarySystemBackground` / `systemRed`），不用玻璃。文件中没有 `traitCollectionDidChange`。低于 iOS 26 且未减弱透明度时仍是 `UIBlurEffect`，样式指南只把 iOS 26 写成 regular Liquid Glass，与这段分支一致。
- 发声：本差值没有改按下路径。`deleteKeyTouchDown` 仍调用 `keyTouchDown`，后者仍调用 `emitKeyPressFeedback`（点按一声）。单击松手在 `.pressed` 调用 `performDeleteBackward(shouldEmitFeedback: false)`，不再补第二声。`playRepeatFeedback` 每次调用都 `playKeyClick()`，只在计数为 4 的倍数时 `playHaptic`；函数体内已没有 `effectiveDeleteCount == 1`。擦除在观察到删除时才把 `shouldEmitFeedback: true` 交给 `performDeleteBackward`，播放仍要 `observed`。进入气泡沿（`inside && !fingerInBubble`）调用一次 `playDeleteBubbleArmedFeedback()`：一声点击加触觉强度 1.0。清空循环每次都是 `shouldEmitFeedback: false`，原来的 `feedbackArmed` 已删。`restoreScrubbedGrapheme`、取消、滑出键盘 bounds 的结束路径本差值都没有加发声。`playKeyClick` / `playHaptic` 仍分别由 `cachedKeyClickEnabled` / `cachedHapticEnabled` 把关；新的两处发声都走这两个函数。
- 删除语义：本差值没有引入 `selectAll`、`textDocumentProxy.insertText` 或 `abandonCompositionForVisibilityChange()`。单击与长按重复仍走默认 `performDeleteBackward()` / `handle(.deleteBackward)`。擦除与清空仍走 `oneGraphemeBeforeCursor: true`。预编辑放弃仍是 `dropRemainingPreeditKeepingConfirmedPrefix()`。播放头文件不在本差值里。

合同测试是读源码字符串，不是模拟器里的真实点按，也不是发声或玻璃的运行时断言。`testDeleteButtonKeepsDragExitInsideTheHold` 断言动作文件含有 `performDeleteBackward(shouldEmitFeedback: false)` 与 `playDeleteBubbleArmedFeedback()`，并断言反馈文件不含 `effectiveDeleteCount == 1`。`shouldEmitFeedback: false` 同时出现在单击松手和清空循环，这条子串不能单独钉死是哪一处调用。单击那一处是本审查读 diff 确认的。`testTrashBubbleStaysATemplateSymbol` 只断言源码含有 `UIGlassEffect`、`setFingerInside` 和辅助功能文案。

## 残留

DKS-CLOSE-01 与 DKS-CLOSE-02 未改路径，也没有被本差值修掉或宣布消失。

| ID | 状态 |
|---|---|
| DKS-CLOSE-01 | 单击（`.pressed` 松手）和长按重复仍走默认 `performDeleteBackward()` / `controller.handle(.deleteBackward)`。成对标点或颜表情仍可能一次删掉两侧，包括光标后的 closer。擦除和气泡清空仍走 `deleteOneGraphemeBeforeCursor()`。本差值只改了这些调用的发声开关 |
| DKS-CLOSE-02 | 预编辑左滑仍调用 `dropRemainingPreeditKeepingConfirmedPrefix()`。本差值没有改这个函数 |

离开气泡后再进入会再调用一次 `playDeleteBubbleArmedFeedback()`。这是进入沿，不是整段手势只响一次的闩锁。约定写的是进入时一次确认，与进入沿一致，不单列成失败。

减弱透明度只在 `applyChrome` 当次读取。气泡已显示时如果系统开关变化，要等下一次手指内外切换才重绘。约定只要求有实色回退，回退在这次读取时存在。

## 非声明

- 不是对 V1 手势的重审，也不取代历史 Quality 页。
- 不是 Product Gate，不是 commit、push、PR、merge、TestFlight 或 Release。
- 不是本车道的真机作证。没有设备日志。合同测试没有在模拟器里点删除键。
- 跳过的全套测试和 Release 不能写成已通过。

Human 说已把这个 build 装到 iPhone 13 Pro `00008110-000A08440198801E`，并认为气泡、玻璃和发声可以接受。这是本车道之外的 Human 观察。本审查没有看到该设备的日志，不把它当成上面任一命令的结果，也不把它升级成设备侧通过。
