# DELETE-KEY-SETTINGS-001 Quality 审查

## 结论

Pass

本结论只覆盖本工作区当前字节上的这一次独立 Quality。不授权 Product Gate、commit、push、merge、TestFlight 或 Release。Architecture 的 Conditional Accept 不是本结论。Architecture 旧冻结 digest `517c13ebb83545f62d8ddc976c61ea70f4feeaa0ec03c44a35381f85857d3068` 与本包不同，不因此 Fail。

审查人未实现本切片。未改 Swift、测试、Assignment、AUTH、冻结包或 Architecture 审查页。未使用 bundled git `/review`。未使用 `swift-format --in-place`。

## 基线

| 项 | 值 |
|---|---|
| 工作区 | `/private/tmp/universe-keyboard-delete-key-settings-001` |
| HEAD | `141bc8ebcee456cfac8f8c826da9d6ce4e9e5b4f` |
| 分支 | `grok/delete-key-settings-001` |
| 授权 | `AUTH-DELETE-KEY-SETTINGS-001-QUALITY`（未改 status / consumption） |
| 冻结包 | `docs/evidence/delete-key-settings-001-quality-packet.md` |
| 模拟器 | 已启动的 iPhone 18 Pro `405D994F-28CB-4F89-BB22-B64AD81C05A2`。未换机型 |

## Packet digest

方法：把包内 Packet digest 的十六进制换成 64 个 ASCII `0`，对得到的 UTF-8 做 SHA-256。

| 结果 | 值 |
|---|---|
| 复现 digest | `69b35d41d078a79cabdc46e4c65202a571c2098dd6b7984b80d5d67e15d9b610` |
| 期望 digest | `69b35d41d078a79cabdc46e4c65202a571c2098dd6b7984b80d5d67e15d9b610` |
| 一致 | 是 |

## 十五个文件哈希

测试前与三条命令之后各算一次 SHA-256。后值与前值、与冻结包全部相同。变化数：0。

| Path | 测试前 SHA-256 | 测试后 SHA-256 |
|---|---|---|
| `Packages/KeyboardCore/Sources/KeyboardCore/DeleteKeyHoldSettings.swift` | `963e6742816cb49c429d1f2a434ade865fdf592d02c103654f07d06c11f25916` | 相同 |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/DeleteKeyHoldSettingsTests.swift` | `988fb98f5d95234abfcb5c772b17acb7caf56bde19c501b49255cb4e2c1a18aa` | 相同 |
| `Universe Keyboard/Views/Settings/DeleteKeySettingsView.swift` | `327349176516b06c65b1997112be3ace23e99754a78a4e8592e6953abf79609d` | 相同 |
| `Keyboard/Controllers/DeleteKeyGestureSession.swift` | `faa3227fd489f36ad0800221d60e9f401a0211fa1f3f3b40fbcc84b323c02dfb` | 相同 |
| `Keyboard/Controllers/KeyboardViewController+DeleteActions.swift` | `c8a3d88f4495508274875f8b59262b1a26b12d21ab4efd232e786aca5d8868e4` | 相同 |
| `KeyboardTests/DeleteKeyScrubContractTests.swift` | `977e1882cd5a34931449890ddd7be296fd2bcc5250f4ed7e17b8f65b760882de` | 相同 |
| `Universe Keyboard/Models/SettingsSearchCatalog.swift` | `ea7a3f366d77e088a89822feea7461b28df1c93934a56e90aa4b1579d2461973` | 相同 |
| `Universe Keyboard/Views/Search/SearchTab.swift` | `df32810907f9fc4fc7cee30e84a00941ae7c8a489dda38c19335a2cf13c4d655` | 相同 |
| `Universe Keyboard/Views/Settings/SettingsTab.swift` | `19651c5fc32654fa71463c77e01ef7bbf1b72cbf433124c730cb172e18c5f884` | 相同 |
| `CHANGELOG.md` | `0428337c214c74e5a357821127f51611427f7ec165b11be9c7c018e49ec9d055` | 相同 |
| `docs/product-decisions/DELETE-KEY-SETTINGS-001-product-contract.md` | `24044947b1243c597b142cc9f3d6542cccab7bb70b48be30b40decc78043315a` | 相同 |
| `docs/assignments/delete-key-settings-001.md` | `0c589bb85b36556f1295a929a9b410fa5e0286e7074f1f9f6a1f7eadd6f8fe5e` | 相同 |
| `docs/reviews/delete-key-settings-001-architecture-review.md` | `76ae46050e980146bb0b849949a4f500c738655c5a8dcff5f871287f90f03656` | 相同 |
| `docs/authorizations/AUTH-DELETE-KEY-SETTINGS-001-ARCHITECTURE.md` | `0f0cd0ead5ec46354484ca31f42b71aced01f8e4b80edcbc1aac62fe3e8356a9` | 相同 |
| `docs/evidence/delete-key-settings-001-architecture-packet.md` | `93de4f017eb1c6d6d1ea42ca15dc6a955c65006db203795b4174c726dd7bd3b9` | 相同 |

## 命令

均在本工作区实际执行。计数来自本次命令输出，不采用执行者报告。

1. `xcrun swift-format lint --strict --configuration .swift-format`，对象为哈希表中的 9 个 Swift 文件。退出码 0。标准输出无诊断。
2. `swift test --package-path Packages/KeyboardCore`。退出码 0。输出：`Executed 1207 tests, with 0 failures (0 unexpected)`。其中 `DeleteKeyHoldSettingsTests` 为 `Executed 6 tests, with 0 failures`，包含 `testReturnToKeyBlocksAnotherClearOnTheSamePress`。
3. 指定的 `xcodebuild ... -only-testing:KeyboardTests/DeleteKeyScrubContractTests test`，destination 为 `platform=iOS Simulator,id=405D994F-28CB-4F89-BB22-B64AD81C05A2`。退出码 0。输出含 `** TEST SUCCEEDED **`。`DeleteKeyScrubContractTests` 为 `Executed 3 tests, with 0 failures (0 unexpected)`：`testDeleteButtonKeepsDragExitInsideTheHold`、`testPlayheadDoesNotStoreHostText`、`testTrashBubbleStaysATemplateSymbol` 均 passed。

未跑 Release，未跑整份 App + Keyboard。

## 滑回终态（当前源码）

已读当前字节，不是执行者声明。滑动关、垃圾桶开、气泡已出现时，终态在源码里。

- 滑回键面：`handleScrubDisabledFingerMove` 在 `phase == .leftKeyPending` 且点落在键面时，设置 `session.returnedToDeleteKey = true`，停止重复删除，并 `hideDeleteTrashBubble()`。收起会把 `bubbleVisible` 和 `fingerInBubble` 清掉，并移除气泡视图。见 `Keyboard/Controllers/KeyboardViewController+DeleteActions.swift` 与 `DeleteKeyGestureSession.returnedToDeleteKey`。
- 同一次按住再进气泡不会重新武装清空：`DeleteKeyHoldPolicy.outsideKeyIntent` 在 `returnedToKey == true` 时直接返回 `.stopWithoutResume`，不再返回 `.seekBubble`。控制器对该分支只停重复、收起气泡，并把 phase 留在 `.leftKeyPending`，不把 `fingerInBubble` 设为 true。`showDeleteTrashBubbleIfNeeded` 只在 `.repeating` 时显示气泡，因此这次按住不会把气泡再装回来。松手清空还要求 `bubbleVisible`，并且 `fingerInBubble` 或点在气泡内；气泡已收起时两者都不成立。
- 尚未滑回键面时，缝仍可进气泡并在松手时清空：气泡仍可见且 `returnedToKey == false` 时，缝是 `.seekBubble(inBubble: false)`，气泡内是 `.seekBubble(inBubble: true)`。这条路径不收起气泡；进入气泡才把 `fingerInBubble` 设为 true。`finishDeleteGesture` 在 `.leftKeyPending`、气泡仍可见且手指在气泡内时调用 `performDeleteAllBeforeCursor()`。

因此，滑回之后的同一次按住不能第二次武装清空。这不是 Fail 条件。

`KeyboardTests` 这 3 个用例只检查源码字符串是否包含 `returnedToDeleteKey` 等记号，不模拟手指轨迹。策略分支由已通过的 `testReturnToKeyBlocksAnotherClearOnTheSamePress` 覆盖；控制器终态以本次阅读的当前源码为准。这不构成未关闭残留。

## 用法

- 一次 pass。写完本页即停止，没有第二轮。
- 停止原因：digest 与 15 个文件哈希一致；三条命令退出码均为 0；测试后哈希未变；滑回终态已在当前源码确认。预算未用尽。
- 大约工具调用次数：21（含写入本审查页）。上限 30。

本结论不授权 Product Gate、commit、push、merge、TestFlight 或 Release。
