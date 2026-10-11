Pass

## 基线与 digest 复现

- 工作区 `/private/tmp/universe-keyboard-delete-key-settings-001`，分支 `grok/delete-key-settings-001`，`git rev-parse HEAD` = `141bc8ebcee456cfac8f8c826da9d6ce4e9e5b4f`。
- 授权 `AUTH-DELETE-KEY-SETTINGS-001-PRODUCT-GATE-002` 仍为 active / unconsumed。本页不消费它。
- 冻结包 `docs/evidence/delete-key-settings-001-product-gate-002-packet.md`。方法：把该文件里 `Packet digest:` 后的 64 位十六进制换成 64 个 ASCII `0`，对得到的 UTF-8 做 SHA-256。
- 复现结果 `bb87845bfee9dc78950200843eb9c5ed4e2d3e637159efaa44c318b030d299bf`，与包内声明一致。
- 对照合同是当前字节的 `PD-DELETE-KEY-SETTINGS-001`。第一次 Product Gate 审查页哈希与本包一致，故未被改写；不采用该页的「符合」作为本结论。未重跑 `swift test` / `xcodebuild` / `swift-format`。Quality Pass digest `69b35d41d078a79cabdc46e4c65202a571c2098dd6b7984b80d5d67e15d9b610` 只作既有证据。本审查人没有真机安装，不是 Human Product Owner。

## 二十七格哈希

一次 `shasum -a 256` 覆盖冻结包全部 27 条路径，与包内十六进制全部一致。前 11 个产品行与本包相同，不是与更早 Quality 包或第一次 Product Gate 包对照：

| Path | SHA-256 |
|---|---|
| `Packages/KeyboardCore/Sources/KeyboardCore/DeleteKeyHoldSettings.swift` | `963e6742816cb49c429d1f2a434ade865fdf592d02c103654f07d06c11f25916` |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/DeleteKeyHoldSettingsTests.swift` | `988fb98f5d95234abfcb5c772b17acb7caf56bde19c501b49255cb4e2c1a18aa` |
| `Universe Keyboard/Views/Settings/DeleteKeySettingsView.swift` | `327349176516b06c65b1997112be3ace23e99754a78a4e8592e6953abf79609d` |
| `Keyboard/Controllers/DeleteKeyGestureSession.swift` | `faa3227fd489f36ad0800221d60e9f401a0211fa1f3f3b40fbcc84b323c02dfb` |
| `Keyboard/Controllers/KeyboardViewController+DeleteActions.swift` | `c8a3d88f4495508274875f8b59262b1a26b12d21ab4efd232e786aca5d8868e4` |
| `KeyboardTests/DeleteKeyScrubContractTests.swift` | `977e1882cd5a34931449890ddd7be296fd2bcc5250f4ed7e17b8f65b760882de` |
| `Universe Keyboard/Models/SettingsSearchCatalog.swift` | `ea7a3f366d77e088a89822feea7461b28df1c93934a56e90aa4b1579d2461973` |
| `Universe Keyboard/Views/Search/SearchTab.swift` | `df32810907f9fc4fc7cee30e84a00941ae7c8a489dda38c19335a2cf13c4d655` |
| `Universe Keyboard/Views/Settings/SettingsTab.swift` | `19651c5fc32654fa71463c77e01ef7bbf1b72cbf433124c730cb172e18c5f884` |
| `CHANGELOG.md` | `0428337c214c74e5a357821127f51611427f7ec165b11be9c7c018e49ec9d055` |
| `docs/product-decisions/DELETE-KEY-SETTINGS-001-product-contract.md` | `24044947b1243c597b142cc9f3d6542cccab7bb70b48be30b40decc78043315a` |

其余 16 条（Assignment、ACTIVE_WORK、dashboard、索引、阅读地图、三份既有审查、四份既有 AUTH、三份既有冻结包、本授权）也与本包一致。导航与 Assignment 哈希不同于更早冻结包，按本包不因此判 Fail。

## 十四问

1. 符合。`SettingsTab.inputBehaviorSection` 标题「输入体验」，顺序是「键盘布局」→「键盘反馈」→「删除键」→「智能纠错」。`DeleteKeySettingsView` 只出现在这一项；`SettingsTab` 没有把它放进 App 设置、键盘布局或 `FeedbackSettingsView`。`SettingsSearchCatalog` 的 `id: "deleteKey"` / `destination: .deleteKey` 排在「键盘反馈」之后；`SearchTab.destinationView` 的 `.deleteKey` 打开同一个 `DeleteKeySettingsView()`。
2. 符合。页面只有三个 `Toggle`：「长按垃圾桶」「滑动擦除」「组字时左滑」。开/关 footer 与合同表逐句一致，例如开着的垃圾桶是「按住后出现垃圾桶。移进去松手，清空光标前能看见的文字。」关着的滑动擦除是「手指离开删除键就停止这一次删除。」没有长按重复开关。用户可见文案不解释长按存在；文件头注释不是设置文案。
3. 符合。`DeleteKeyHoldFlags.isEnabled` 先看 `object(forKey:)`，缺键返回 `true`，之后才 `bool(forKey:)`。`defaults == nil` 时 `load` 返回 `.allEnabled`。设置页 `@AppStorage` 缺省也是 `true`，suite 为 `universeAppGroupID`（`group.com.DoubleShy0N.Universe-Keyboard`）。键盘只在 `deleteKeyTouchDown` 调用 `DeleteKeyHoldFlags.load(from: sharedDefaults)`，写入 `DeleteKeyGestureSession.holdFlags`（`let`）。同一次按住不再读。
4. 符合。`deleteKeyTouchDown` 始终 `deleteRepeatController.begin`。松手时相位仍是 `.pressed` 才 `performDeleteBackward`。`DeleteRepeatController.initialDelay` = 0.5，`repeatInterval` = 0.08，`bubbleDelayAfterRepeatStart` = 0.15。这三个数不在设置文案里，也没有被开关关掉。
5. 符合。`scrubEnabled` 为真时不走 `handleScrubDisabledFingerMove`。`.repeating` 仍只 `updateDeleteBubbleHover`，朝气泡离开键面不把本次收成停止。`DeleteTrashBubbleView.gapAboveKey` = 6，铺气泡时用它留缝。`DeleteScrubPlayhead.horizontalLockPoints` = 10，`isHorizontallyLocked` / `isLeftwardLocked` 仍用这个阈值。
6. 符合。滑动擦除关时进入 `handleScrubDisabledFingerMove`。垃圾桶关或气泡不可见时，`DeleteKeyHoldPolicy.outsideKeyIntent` 返回 `.stopWithoutResume`：停重复、藏气泡、相位 `.leftKeyPending`。已删字没有回放账本可撤。`finishDeleteGesture` 只在相位仍是 `.pressed` 时补点按；`.leftKeyPending` 的注释写明松手不点按删除。不松手再进键面只把 `returnedToDeleteKey` 设为真并 `stop()`，不 `resumeRepeating`。
7. 符合。滑动擦除关、垃圾桶开、气泡已出现时，缝是 `deleteOffKeyZone` 的 `.crossingGap`，意图是 `seekBubble(inBubble: false)`，重复已停，松手在缝里不满足 `fingerInBubble` 或 `deleteBubbleContains`，不清空。走进气泡再松手：相位 `.leftKeyPending` 且 `fingerInBubble`，`performDeleteAllBeforeCursor`。移到别处是 `.stopWithoutResume`，保留已删、不再重复、也不清空。滑回键面设置 `returnedToDeleteKey`；之后 `outsideKeyIntent` 因 `returnedToKey` 不再 `seekBubble`，同一次按住不能再武装清空。
8. 符合。`canShowDeleteTrashBubble` 在 `hasActivePreedit` 时为假，组字不出气泡。组字左滑开且仍是 `.pressed`、向左达到 `isLeftwardLocked`：停重复，`abandonActivePreedit()` → `dropRemainingPreeditKeepingConfirmedPrefix()`（清空剩余拼音、保留 `confirmedText`），相位 `.composingCleared`，不进入已上屏擦除。组字左滑关且滑动擦除关：离开键面走停止这一次，不调用放弃。组字左滑关且滑动擦除开：有预编辑时水平锁定只进入 `.lockedWithoutDelete`，不放弃、不 `applyCommittedScrub`。
9. 符合。滑动擦除关且点仍在 `keyFrame` 内：`.pressed` 直接返回，不 `stop()`；`.repeating` 只更新气泡悬停。`deleteBubbleContains` 在键面内返回假，所以键面上的水平移动不结束长按。
10. 符合。`FeedbackSettingsView` 仍有「按键音」和「触感反馈」。删除页文案没有发声、触感、256、缝或水平锁定。停止/取消走 `stopWithoutResume`、`deleteKeyTouchCancel` 或 `endDeleteGestureSession`，这些路径不额外播放。按下仍是 `keyTouchDown`；点按松手删除用 `shouldEmitFeedback: false`。`DeleteScrubPlayhead.clearAllCap` = 256，仍由 `performDeleteAllBeforeCursor` 使用。读不到光标前文字时 `canShowDeleteTrashBubble` 要求 `documentContextBeforeInput` 非空，否则不出气泡；密码框不可读走 `DeleteScrubStep.blind`，不进设置文案。
11. 符合。唯一工厂是 `makeDeleteButton()`，它绑定 `deleteKeyTouchDown`。`addKeyboardRows`：九键 `makeT9NineKeyChrome`；26 键中文/英文 `.letters` 的非九键路径 `makeLetterThirdRow`；中文/英文数字第三行；中文/英文符号第三行。这些调用点都走到同一个 `makeDeleteButton()`，因此共用同一次按下读到的三个旗标。
12. 符合。`CHANGELOG.md` 相对 HEAD 是未提交修改（`8` 行新增），与本切片其余未提交字节在同一工作区。顶部 `2026-10-07` 有「设置 → 输入体验 → 删除键：长按垃圾桶、滑动擦除、组字时左滑，默认都开。点按和长按重复不能关。」
13. 符合。`docs/product-decisions/DELETE-KEY-SCRUB-001-product-contract.md` 不在本工作区脏文件里；相对已合并的 `cee4f914be03d45c6d8deae8af5427ff1587d5c1` 无 diff。最后改动仍是 `1560488`。本切片没有重写该冻结合同。四条残留仍写在已 Closed 的删除键记录里，见下方，本 Gate 不新声称它们消失。
14. 符合。本页不是 Close、commit、push、PR、merge、TestFlight 或 Release。第一次 Product Gate 文件哈希未变，其 Partial / incomplete 不被改写成 Pass。Product Approver 仍是 Human Product Owner。

## 残留

无新的开放残留。下列四条只保持已有披露，disposition 仍是 Closed 切片里的 `accept`。本审查人没有真机，不新声称微信、Safari、密码框或 iOS 26 以下模糊已经看过。

| ID | 当前字节 | 处置 |
|---|---|---|
| DKS-CLOSE-01 | 点按松手和长按重复仍走 `performDeleteBackward()` / `controller.handle(.deleteBackward)`。擦除与清空走 `deleteOneGraphemeBeforeCursor()` | 保持披露。不新声称消失 |
| DKS-CLOSE-02 | `abandonActivePreedit()` 仍调用 `dropRemainingPreeditKeepingConfirmedPrefix()`，会重置 RIME session 并清 T9 Path | 保持披露。不新声称消失 |
| DKS-GATE-HOST-01 | 微信、Safari、密码框 | 未测。本 Gate 不新声称已看过 |
| DKS-GATE-BLUR-01 | iOS 26 以下自适应模糊 | 本审查人没有真机观察 |

披露位置仍包括 `docs/product-decisions/DELETE-KEY-SCRUB-001-product-gate.md` 与 `docs/evidence/delete-key-scrub-001-close-2026-10-07.md`。不另开修复项。

## 非声明

本结论不是 Assignment Close，不是 commit、push、PR、merge、TestFlight 或 Release。未消费 `AUTH-DELETE-KEY-SETTINGS-001-PRODUCT-GATE-002`。未改 Swift、测试、Assignment、AUTH、冻结包、Architecture 审查、Quality 审查、第一次 Product Gate 审查、产品合同、CHANGELOG、ACTIVE_WORK 或 dashboard。第一次 Product Gate 的 Partial / incomplete 保持原样，不是本页的 Pass。跳过的测试重跑按冻结包不是 Fail。

## 用法

一次 pass。工具调用大约 35 次（含本页写入）。十四条都符合，预算未用尽，因此停止，不开始第二轮。
