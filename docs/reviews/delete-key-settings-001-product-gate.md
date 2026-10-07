# DELETE-KEY-SETTINGS-001 Product Gate

## 1. 结论

Partial / incomplete

冻结包写明：工具调用用尽时只能记 Partial / incomplete，不能是 Pass，也不能是 Pass with conditions。本次阅读在写出本页之前已经超过 30 次。因此下面的字节对照只是阅读记录，不升成 Product Pass，也不新接受或新拒绝任何残留。

## 2. 基线

| 项 | 值 |
|---|---|
| 工作区 | `/private/tmp/universe-keyboard-delete-key-settings-001` |
| HEAD | `141bc8ebcee456cfac8f8c826da9d6ce4e9e5b4f` |
| 分支 | `grok/delete-key-settings-001` |
| 授权 | `AUTH-DELETE-KEY-SETTINGS-001-PRODUCT-GATE`，status `active`，consumption `unconsumed`。本页不消费它 |
| 冻结包 | `docs/evidence/delete-key-settings-001-product-gate-packet.md` |
| 审查人 | 独立 Grok 4.7。未实现本切片。不是 Human，未做真机安装，未看微信、Safari、密码框或 iOS 26 以下模糊 |
| Product Approver | Human Product Owner |

Packet digest 复现：把包内 `Packet digest:` 后的 64 位十六进制换成 64 个 ASCII `0`，对得到的 UTF-8 做 SHA-256，得到 `f1458883619b20b2aa2970d6b812ae2a33b27ed394b7ac8a4dddf5c4d5883b1a`，与包内记录一致。

先前证据，不是本 Gate：Quality 包按同一方法复现为 `69b35d41d078a79cabdc46e4c65202a571c2098dd6b7984b80d5d67e15d9b610`。Architecture 包复现为 `517c13ebb83545f62d8ddc976c61ea70f4feeaa0ec03c44a35381f85857d3068`。后者不覆盖滑回修补，本页不改那份审查。未跑 `swift test`、`xcodebuild` 或 `swift-format`。未使用 bundled git `/review`。

## 3. 二十四格哈希

一致。工作区当前字节的 24 个路径 SHA-256 都与本冻结包相同，没有为凑哈希改文件。

十一个产品行与本包、以及 Quality 冻结的对应行一致：

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

`docs/assignments/delete-key-settings-001.md` 现为 `dad5296b090f217a0918793664905b34d678508f1e49f8d7431c050704e13ee8`。Quality 包里的旧值 `0c589bb85b36556f1295a929a9b410fa5e0286e7074f1f9f6a1f7eadd6f8fe5e` 不同，是 Quality Pass 之后的状态回写，不因此 Fail。

## 4. 十四个问题

下列「符合」只表示读到的当前字节与合同句子对得上。预算已用尽，整体结论仍是 Partial / incomplete。

1. 符合。`SettingsTab.inputBehaviorSection` 的标题是「输入体验」。导航顺序是「键盘布局」「键盘反馈」「删除键」，删除键的 destination 是 `DeleteKeySettingsView()`。`title: "App 设置"` 在另一组。`SettingsSearchCatalog` 的 `id: "deleteKey"`、`Destination.deleteKey` 由 `SearchTab.destinationView` 的 `case .deleteKey` 打开同一个 `DeleteKeySettingsView()`。
2. 符合。`DeleteKeySettingsView` 只有三个 `Toggle`：「长按垃圾桶」「滑动擦除」「组字时左滑」。开/关 footer 与合同表相同，例如开着的垃圾桶是「按住后出现垃圾桶。移进去松手，清空光标前能看见的文字。」关着是「按住后不出现垃圾桶。」没有长按开关。页内注释写「点按和长按重复始终可用，不在本页出现」，正文不解释长按。
3. 符合。`DeleteKeyHoldFlags.isEnabled` 先看 `object(forKey:) == nil`，缺键返回 `true`，然后才 `bool(forKey:)`。`load(from:)` 在 defaults 为 nil 时返回 `allEnabled`。`deleteKeyTouchDown` 里 `DeleteKeyHoldFlags.load(from: sharedDefaults)` 只读一次，存进 `holdFlags`。`@AppStorage` 的缺省也是 `true`。套件是 `universeAppGroupID` / `KeyboardViewController.appGroupID`，二者都是 `group.com.DoubleShy0N.Universe-Keyboard`。
4. 符合。`deleteKeyTouchDown` 总是 `deleteRepeatController.begin`。`finishDeleteGesture` 在相位仍是 `.pressed` 且不是松手清空时调用 `performDeleteBackward`。`DeleteRepeatController` 仍是 `initialDelay = 0.5`、`repeatInterval = 0.08`、`bubbleDelayAfterRepeatStart = 0.15`。该文件不在本次未提交差异里。
5. 符合。`scrubEnabled` 为真时不进 `handleScrubDisabledFingerMove`，仍走 `.scrubCommitted` 与 `applyCommittedScrub`。`DeleteScrubPlayhead.horizontalLockPoints` 是 `10`。`DeleteTrashBubbleView.gapAboveKey` 是 `6`。这两个文件不在本次未提交差异里。滑动开着时，`.repeating` 只调用 `updateDeleteBubbleHover`，朝气泡离开键面不走停止分支。
6. 符合。垃圾桶关时 `outsideKeyIntent` 的 `guard` 失败，返回 `.stopWithoutResume`。`handleScrubDisabledFingerMove` 停重复、藏气泡，相位改为 `.leftKeyPending`。不回放已删字素。松手只有 `.pressed` 才补点按删除。未松手回到键上时只把 `returnedToDeleteKey` 设为真，不恢复重复。
7. 符合。垃圾桶开且 `bubbleVisible` 时，`deleteOffKeyZone` 把键与气泡之间的矩形标成 `.crossingGap`，策略返回 `seekBubble(inBubble: false)`。走进气泡是 `seekBubble(inBubble: true)`，松手时 `liftClearsBeforeCursor` 要求 `fingerInBubble` 或 `deleteBubbleContains`，然后 `performDeleteAllBeforeCursor()`。停在缝里、`.elsewhere`、或 `.leftKeyPending` 时滑回键上，都停重复并且不清空。滑回会把 `returnedToDeleteKey` 设为真；之后 `outsideKeyIntent` 直接 `.stopWithoutResume`，同一次按住不能再武装清空。气泡还没出现时 `bubbleVisible` 为假，离开键面就是停止。
8. 符合。`canShowDeleteTrashBubble` 在 `hasActivePreedit` 时为假。组字左滑开着且相位仍是 `.pressed` 时，越过 `isLeftwardLocked` 会 `abandonActivePreedit()`（`dropRemainingPreeditKeepingConfirmedPrefix()`），相位 `.composingCleared`，并停重复。组字左滑关、滑动也关时走离开即停。组字左滑关但滑动开、且仍有预编辑时，水平锁定只进入 `.lockedWithoutDelete`，不放弃拼音，也不 `applyCommittedScrub`。
9. 符合。滑动关着且手指仍在 `keyFrame` 内时，`handleScrubDisabledFingerMove` 直接返回；`.repeating` 只更新气泡悬停，不因此停长按。组字左滑开着时的提前返回是第 8 条的放弃路径，不是滑动关闭本身把键面上的水平移动当成离开。
10. 符合。删除页没有发声或触感开关；「键盘反馈」仍指向 `FeedbackSettingsView()`。`endDeleteGestureSession` 与 `.stopWithoutResume` 不调用发声。取消走 `deleteKeyTouchCancel`。松手停止不再补 `performDeleteBackward`。设置文案没有 256 或读不到上下文。行为仍在：`DeleteScrubPlayhead.clearAllCap = 256`，`canShowDeleteTrashBubble` 在光标前文字为空时不显示气泡。进入气泡的 `playDeleteBubbleArmedFeedback()` 是原有武装反馈，不是取消或停止时另加一声。
11. 符合。26 键 `makeLetterThirdRow`、九键 `makeT9NineKeyChrome`、中文数字 `makeChineseNumbersThirdRow`、英文数字/符号 `makeEnglishNumbersThirdRow` / `makeEnglishSymbolsThirdRow`、中文符号 `makeChineseSymbolsThirdRow`，以及 `makeBottomRow(includeDelete:)`，都调用同一个 `makeDeleteButton()`。它绑定同一个 `deleteKeyTouchDown`。三个标志没有按布局分叉。这些行文件不在本次未提交差异里。
12. 符合。`CHANGELOG.md` 相对 HEAD 是未提交的 `+8`。顶部条目「2026-10-07 — 删除键可滑动擦除并清空光标前文字」里有「设置 → 输入体验 → 删除键：长按垃圾桶、滑动擦除、组字时左滑，默认都开。点按和长按重复不能关。」与本切片同在工作区未提交字节里。
13. 符合。`docs/product-decisions/DELETE-KEY-SCRUB-001-product-contract.md` 不在未提交差异里，本切片合同写明不修改那份合同。本 Gate 不新声称微信、Safari、密码框或 iOS 26 以下模糊已在真机看过。`CHANGELOG` 里「更低版本用随外观变化的模糊」是行为描述，不是本审查人的真机观察。
14. 符合。本切片合同的 Non-claims 是「不是 Product Gate、TestFlight 或 Release」。Assignment 仍是 Lifecycle `Active`，并写「Product Gate、commit、push、PR、merge 仍未授权」，Non-goals 含不重写已 Closed 切片的 Close，且不授权 commit、push、merge、TestFlight 或 Release。本页也不把本次审查写成 Close。

## 5. 残留

本 Gate 预算用尽，不新接受、不新拒绝残留，也不发 Pass with conditions。

已 Closed 的 `DELETE-KEY-SCRUB-001` 继续披露，不重开，也不写成这次有人在真机看过：

| 编号 | 本页读到的现状 | 处置 |
|---|---|---|
| DKS-CLOSE-01 | 点按松手和长按重复仍走 `performDeleteBackward()` / `controller.handle(.deleteBackward)`。擦除与清空走 `deleteOneGraphemeBeforeCursor()` | 保持已 Closed 切片里的披露。本 Gate 不新声称它消失 |
| DKS-CLOSE-02 | `abandonActivePreedit()` 仍调用 `dropRemainingPreeditKeepingConfirmedPrefix()` | 同上 |
| DKS-GATE-HOST-01 | 微信、Safari、密码框 | 未测。本 Gate 不新声称已看过 |
| DKS-GATE-BLUR-01 | iOS 26 以下自适应模糊 | 本审查人没有真机观察 |

`R-DELETE-KEY-SETTINGS-001-ARCH-1` 的滑回路径现在能在源码里看见：`returnedToDeleteKey` 与 `outsideKeyIntent` 的 `guard !returnedToKey`。Architecture 审查不改写。这不构成新的开放残留编号，也不被本页接受成 Pass 条件。

## 6. 非声明

本页不是 Close，不是 commit，不是 push，不是 PR，不是 merge，不是 TestFlight，也不是 Release。未消费 `AUTH-DELETE-KEY-SETTINGS-001-PRODUCT-GATE`。Product Approver 仍是 Human Product Owner。

## 7. 用法

一次 pass。审查读取约 33 次，加上写出本页这一次，超过冻结包最多 30 次的预算。停止原因：预算用尽。未做第二轮。未改 Swift、测试、Assignment、AUTH、冻结包、Architecture 审查、Quality 审查、产品合同、CHANGELOG、ACTIVE_WORK 或 dashboard。
