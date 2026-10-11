**Pass with conditions。** 本车道独立复现的 KeyboardCore 与 App+Keyboard Debug test 均通过，且失败数为 0；这不是可合并、可 commit 或可 Release。行为覆盖仍缺模拟器里对删除键的真实点按，DKS-CLOSE-01 与 DKS-CLOSE-02 也仍在，只是披露，没有消失。

# DELETE-KEY-SCRUB-001 — 独立 Quality Review

审查日期：2026-10-07 Asia/Shanghai。审查者未实现本切片，未使用 git `/review`，未改 Swift、测试、Assignment、AUTH 的 status / consumption，也未改 Architecture 原文。授权是 [`AUTH-DELETE-KEY-SCRUB-001-QUALITY`](../authorizations/AUTH-DELETE-KEY-SCRUB-001-QUALITY.md)（active / unconsumed）。当前 Architecture 结论仍是 [`delete-key-scrub-001-architecture-close.md`](delete-key-scrub-001-architecture-close.md) 的 Pass with conditions；Round 1 原文仍是 Reject，只作历史。本页不重开 Architecture。

## Scope

隔离工作树 `/private/tmp/universe-keyboard-delete-key-scrub-001`，分支 `grok/delete-key-scrub-001`。`git rev-parse HEAD` 与 `git merge-base HEAD origin/main` 都是 `781ca45dfe53cd8d90f49f60370a2efae9d3e749`（`781ca45 docs: sync stale ACTIVE_WORK rows #3/#9/#10 (#201)`）。没有超前 commit。证据钉在这份未提交脏树，不钉在某个实现 SHA。

`git status --short`（审查结束时，不含本文件；本文件是本车道唯一新建文件）：

- 已修改：`DeleteRepeatController.swift`、`KeyboardViewController+Bootstrap.swift`、`KeyboardViewController+DeleteActions.swift`、`KeyboardViewController+KeyAccessibility.swift`、`KeyboardViewController+KeyFactory.swift`、`KeyboardViewController.swift`、`KeyboardController+TextEditing.swift`、`KeyboardController.swift`、`DeleteTests.swift`，以及 `docs/ACTIVE_WORK.md`、`docs/ENGINEERING_DASHBOARD.md`、`docs/KNOWLEDGE_INDEX.md`、`docs/READING_MAPS.md`、`docs/UI_STYLE_GUIDE.md`、Assignment 与产品合同。
- 未跟踪产品/测试：`DeleteKeyGestureSession.swift`、`DeleteTrashBubbleView.swift`、`DeleteKeyScrubContractTests.swift`、`DeleteScrubPlayhead.swift`、`DeleteScrubPlayheadTests.swift`。
- 未跟踪文档：本切片 AUTH 与既有 Architecture 审查。`Packages/RimeBridge/Vendor` 是指向主 checkout 同名目录的符号链接，不是本切片产品 diff。
- 未 `git add`。主 checkout `/Users/doubleshy0n/Dev/Universe Keyboard` 未被本审查修改。

对照 Assignment V1：按下只建会话、松手单击、已上屏播放头、预编辑左滑一次放弃、长按重复与气泡、离开 bounds / disappear 丢账本。Exit 里的「可演示」、真机 glance、Product Gate 不在本车道关闭范围内。

切片文件 SHA-256（测试前 `shasum -a 256`；测试后复测 `KeyboardViewController+DeleteActions.swift` 与 `DeleteTests.swift`，两枚摘要未变）：

| Path | SHA-256 |
|---|---|
| `Keyboard/Controllers/DeleteKeyGestureSession.swift` | `aa849128274f3f493ec0d9927f1c4a37a33344f6d0d399b229b321c4b5ecb49d` |
| `Keyboard/Controllers/DeleteRepeatController.swift` | `a4683ca55396c34b9b15700cc20f28aa95cb1f6ee0d9871898f0bff085ccd2ac` |
| `Keyboard/Controllers/KeyboardViewController+DeleteActions.swift` | `186579a54437dbab39ac3091f4f6caa49314dff46f164c7b6dd913cecf29f2ea` |
| `Keyboard/Controllers/KeyboardViewController+KeyFactory.swift` | `071632c04eb3edb6bd7d93430241ef5ca3c32af447ea5797affd2560bdaa46e2` |
| `Keyboard/Controllers/KeyboardViewController+KeyAccessibility.swift` | `6a2742c7ba976764087dd825633baeaec7fb4dfe597db714f031a89c9ce93250` |
| `Keyboard/Controllers/KeyboardViewController+Bootstrap.swift` | `18138b23290cca1dcc2f05b794b21ef1211a8919283752710c90aa74099e5ec4` |
| `Keyboard/Controllers/KeyboardViewController.swift` | `d4121375525f7100cc6d3335a04fdc0e1db162f2fcfb1ef733e6c985975b75b9` |
| `Keyboard/Views/DeleteTrashBubbleView.swift` | `90f2d22300c25e56c04d76066d0317aa2ac042885b93df0888fc97caa3c97a2c` |
| `KeyboardTests/DeleteKeyScrubContractTests.swift` | `0e9f94f16dc930e7d8573d432bdb6a8645388174aeb2680358d15b2e4e9d6024` |
| `Packages/KeyboardCore/Sources/KeyboardCore/DeleteScrubPlayhead.swift` | `ad78ab3b427523f6a215e3e805768e46ccf23013f93861e61b034fd748ff98a2` |
| `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+TextEditing.swift` | `efcf4394ca15c2d42efd57619e648d3e468a84aa3bdf701fa212d940fa94afa8` |
| `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController.swift` | `3bfaf8bbff1a91597a3c88debd455f509a572129f180625bed88a4275c6f797a` |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/DeleteTests.swift` | `fa3ad6eea77c962930f8b8e47869c2fd25cfc0b371318b9135c353967748f892` |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/DeleteScrubPlayheadTests.swift` | `96c82c9f4176e5605a7eb5e620c443129798f1c4378abbd988dfcbd46a1e2b4f` |

这些字节再改，或首次 commit 之后，本页不能自动跟随。

## Evidence Matrix

环境（本审查实测，不是 Executor 口述）：macOS 27.0（26A428），Xcode 27.0（27A266a），Swift 6.4（swiftlang-6.4.0.34.1）。模拟器是已经启动的 iPhone 18 Pro，UDID `405D994F-28CB-4F89-BB22-B64AD81C05A2`，runtime `com.apple.CoreSimulator.SimRuntime.iOS-27-0`。`simctl list devices` 把它放在第二个 `iOS 27.0` 组，对应 runtime 列表里的 `iOS 27.0 (27.0 - 24A434)`。没有改用 iPhone 17 Pro。DerivedData：`/Users/doubleshy0n/Library/Developer/Xcode/DerivedData/Universe_Keyboard-dirkeqcodnjdlsfgvagkefuqzywf`。

| 检查 | 命令 / 读取 | 结果 |
|---|---|---|
| KeyboardCore 全套 | `cd /private/tmp/universe-keyboard-delete-key-scrub-001 && swift test --package-path Packages/KeyboardCore` | 退出码 0。XCTest：`Executed 1201 tests, with 0 failures`，2026-10-07 11:13:09–11:13:28 +0800。日志末尾另有 Swift Testing「0 tests」；那是没有 Swift Testing 套件，不是 1201 个用例失败。日志：`/tmp/dks-delete-key-scrub-001-quality-keyboardcore.log` |
| App + Keyboard Debug test | 指定 destination id 的完整 `xcodebuild ... test`，无 `-only-testing`。参数含 `CODE_SIGNING_ALLOWED=NO`、`SWIFT_VERSION=6.0`、`SWIFT_STRICT_CONCURRENCY=complete`、`SWIFT_SUPPRESS_WARNINGS=NO`、`SWIFT_TREAT_WARNINGS_AS_ERRORS=YES` | `** TEST SUCCEEDED **`，脚本记录 `EXIT:0`。2026-10-07 11:14:07–11:14:55 +0800。UniverseKeyboardTests 413 个，其中 10 个 skip、0 failure；KeyboardTests 44 个，0 failure。Testing started 耗时 40.893 秒。日志：`/tmp/dks-delete-key-scrub-001-quality-app-keyboard.log`。xcresult：`.../Logs/Test/Test-Universe Keyboard-2026.10.07_11-14-10-+0800.xcresult` |
| 播放头单测 | `DeleteScrubPlayheadTests` 三条 | 通过。10pt 锁定、左移按 10pt 计单位且右移为 0、`ledgerCap` 64 |
| 单字素 / 预编辑前缀单测 | `DeleteTests` 中新增四条，以及原有删除用例 | 通过。见下方残留：成对标点的默认删除仍删两侧 |
| 扩展源码字符串合同 | `DeleteKeyScrubContractTests` 三条 | 通过。这是读源码字符串，不是点击键盘 |
| 真实点按删除键 | 未做 | 覆盖缺口，见 Skipped |
| Release build | 未做 | 未授权 |
| 真机 Notes / 微信 / Safari / 密码框 | 未做 | Human glance，未编造 |

源码阅读（用来判断合同落点，不代替上面的命令）：

- 单击：`finishDeleteGesture` 在 `.pressed` 调用默认 `performDeleteBackward()`，也就是 `controller.handle(.deleteBackward)`。长按节拍 `handleDeleteRepeatTick` 同样走这条默认路径。
- 擦除 `deleteOneCommittedGraphemeForScrub()` 与气泡清空 `performDeleteAllBeforeCursor()` 传 `oneGraphemeBeforeCursor: true`，进入 `deleteOneGraphemeBeforeCursor()`。该函数先把 pending 标点 / 颜表情置 `nil`，再 `handleDeleteBackward()`，源码不调用 `removeOwnedHostSpan`。
- 预编辑左滑调用 `dropRemainingPreeditKeepingConfirmedPrefix()`。实现会 `resetSession()` 或 `bumpSessionEpoch(resetEngineSession: true)`，并 `clearT9PinyinPathStateReturningEffect()`；保留 `confirmedText` 与 checkpoint，continuation 不在该函数里清空。单测只覆盖无引擎的前缀 / checkpoint / marked text，没有断言真实 RIME session。
- `makeDeleteButton()` 把 `.touchDragInside/.touchDragOutside/.touchDragExit` 接到拖动，不接到结束按住的 `keyTouchUp`。`DeleteRepeatController.stop()` 递增 `repeatGeneration`。`cleanupTransientKeyboardState` 会 `endDeleteGestureSession`。
- 气泡常量 32 / 12 / 6 / 2；键面 `keyFrame.contains` 时 `deleteBubbleContains` 为 false。气泡是 template `trash`，标签「删除光标前文字」。删除键仍是 `.keyboardKey`，标签「删除」。
- `makeDeleteButton()` 被九键 chrome、字母第三行、中文数字第三行、中文符号第三行、英文数字/符号的功能包裹行，以及底行 `includeDelete` 使用。这是接线，不是各页点按证据。
- 删除会话路径没有 `selectAll`，回放走 `insertDirectText`。账本是进程内 `restoreLedger`，结束会话时 `discardLedger()`。本审查没有看到这条路径把正文写入日志或磁盘；也没有做热路径日志审计之外的磁盘取证。

`KeyboardController+TextEditing.swift` 的 diff 除新函数外，抽查到的其余改动是缩进折行，不是另一套删除语义。既有 `DeleteTests` 在这次全套里通过。

## Passed

- 两条授权命令退出码都是 0，没有属于本切片的失败用例。
- 播放头数学、单字素不吞掉光标后 closer、不把已拥有的「……」一次删完、默认 `deleteBackward` 仍会删掉成对两侧，都有 KeyboardCore 单测，并且这次跑过。
- 预编辑保留 confirmed prefix 与 checkpoint、剩余拼音不上屏（假客户端 marked text），有单测，并且这次跑过。
- 源码字符串合同与本次工作树一致：拖动含 `touchDragExit`、一代重复计时器、单字素路径、template 气泡、播放头文件本身不含 `insertText` / `documentContext`。
- App 启动日志里有 CoreAudio/插件 `failed to create instance`。测试结果仍是 `TEST SUCCEEDED`，不把它当成用例失败。

## Failed/Blocked

无。没有失败用例，没有本切片编译或断言失败，本审查也没有改代码。

## Skipped With Reason

- Release `build`：本 AUTH 明确不跑。未执行，不能写成 Release 通过。
- 真机 Notes、微信、Safari、密码框、光标在中间、空框：Assignment 写明是 Human glance。本审查没有设备，没有编造结果。
- 模拟器里真实点按删除键，走完单击、左右擦除、气泡清空、滑出键盘 bounds：没有做。`DeleteKeyScrubContractTests` 不能代替这次点击。九键 / 26 键 / 数字 / 符号页同一套逻辑也只看到共同的 `makeDeleteButton()`，没有逐页演示。
- `swift-format lint --strict`：不在本 AUTH 的命令里，没有跑。因此不声称格式已绿。以后若另授 commit，仓库的 Swift 格式门槛仍然适用。
- UniverseKeyboardTests 的 10 个 skip 是既有夹具或真机条件，不是本切片用例：Rime Ice pin archive、Keychain entitlement、方案共存的 Ice/Wanxiang 树、TD-012 真机模型。命令仍然 `TEST SUCCEEDED`。它们不证明那些夹具车道通过。

## Release Decision

**Pass with conditions。** 条件的 disposition 如下。它们不把本页写成可合并或可 Release。commit、push、merge、TestFlight、Product Gate 都未授权。

| ID | 条件 | Disposition |
|---|---|---|
| DKS-CLOSE-01 | 单击与长按仍走 `handle(.deleteBackward)`。成对标点或颜表情仍可能一次删掉两侧，包括光标后的 closer。擦除和气泡清空走 `deleteOneGraphemeBeforeCursor()`。单测 `testOwnedPairDeleteStillRemovesBothSides` 把默认路径的两侧删除保持为通过，而不是把残留修掉 | 接受并披露。不是本次 Quality 失败。留在本切片。不要写成已经消失 |
| DKS-CLOSE-02 | 预编辑左滑 `dropRemainingPreeditKeepingConfirmedPrefix()` 重置 RIME session 并清 T9 Path，保留 confirmedText 与 checkpoint，剩余拼音不上屏 | 接受并披露。不是本次 Quality 失败。单测没有真实引擎，session 重置是源码事实加 Architecture 已接受残留，不是这次新跑出来的引擎证据 |
| DKS-Q-COV-01 | 没有在已启动的 iPhone 18 Pro 里打开键盘，点按删除键走完单击、擦除、气泡清空和离开 bounds。源码合同与 KeyboardCore 单测不能填这个洞 | 接受为本车道条件，不因此 Reject。Assignment Exit 的「可演示」仍未完成，交给 Human glance / Product Gate。本页不要求先改断言或补一次未授权的 UI 测试 |

结论只对上表 SHA 的脏工作树有效。`HEAD` 仍是 `781ca45dfe53cd8d90f49f60370a2efae9d3e749`。

## Owner Handoffs

- Product：Human glance 与 Product Gate 仍开。本页不是 Gate。若要关闭 Exit 的可演示与真机项，需要另一次观察，不能引用本文件。
- Keyboard Experience：本审查没有要求改代码。DKS-CLOSE-01 / 02 保持 Architecture 已接受的留在本切片。
- 以后的 commit 车道：未授权。开授权前仍须单独满足 Swift 格式门槛；本页没有那次 lint。
- Architecture：不重开。Round 1 Reject 保持历史。
- 发布：无 TestFlight、无 Release、无分支清理。
