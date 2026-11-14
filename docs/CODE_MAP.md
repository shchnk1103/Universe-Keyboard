# 代码地图（CODE_MAP）

> 用途：给 PM 和新接手者粗看设计范围与代码归属（代码在哪、入口、不变量、归哪个测试），不是实现说明；实现细节以代码与测试为准。
> 维护规则：代码类任务收尾时，如改动或摸清了某个模块的结构、入口、不变量或测试归属，就在对应小节补充或修正；没有对应小节就新建一节，并在「未覆盖」里删去同名行（条款见 `docs/kos/pm-packet-clauses.md`「知识库更新（代码类任务包用）」）。
> 不放日期状态快照与任务进度（沿用 `docs/PROJECT_CONTEXT.md` 的维护规则）；不写行号，只写文件路径与函数 / 类型名（行号会过期）。出处写在行内；推断写「推断」，查不到写 UNKNOWN。

## 总览

| 模块 | 职责（一句） | 目录 | 对应测试目录 |
|---|---|---|---|
| 主 App | SwiftUI 主程序，负责键盘设置、RIME 部署与反馈配置（出处 `docs/PROJECT_CONTEXT.md`） | `Universe Keyboard/` | `UniverseKeyboardTests/`、`UniverseKeyboardUITests/` |
| 键盘扩展 | 在其它 App 中出现的键盘，UIKit（`UIInputViewController`）实现；业务逻辑交给 KeyboardCore 的 `KeyboardController`（出处 `docs/PROJECT_CONTEXT.md`） | `Keyboard/` | `KeyboardTests/`、`KeyboardExtensionTests/`、`KeyboardLayoutIntegrationTests/` |
| KeyboardCore | 纯逻辑、可测试的本地 Swift Package；`KeyboardController` 是中心状态机，`handle` 为唯一入口（出处 `docs/PROJECT_CONTEXT.md`） | `Packages/KeyboardCore/` | `Packages/KeyboardCore/Tests/KeyboardCoreTests/` |
| RimeBridge | RIME 生产桥接代码（ObjC 封装 librime C API + Swift 会话引擎与 App 侧部署 API）（出处 `docs/PROJECT_CONTEXT.md`） | `Packages/RimeBridge/` | `Packages/RimeBridge/Tests/RimeBridgeTests/`；macOS 校验工具 `Packages/RimeBridge/TestTool/` |
| EnvironmentDigestTool | 非 shipping、只读的环境摘要工程工具（出处 `Packages/EnvironmentDigestTool/README.md`） | `Packages/EnvironmentDigestTool/` | `Packages/EnvironmentDigestTool/Tests/EnvironmentDigestTests/` |

测试 target（职责出处：前四个见 `docs/PROJECT_CONTEXT.md`，后两个见所列文件的类型注释）：

| 测试目录 | 职责（一句） |
|---|---|
| `RimeBridgeTests` 即 `Packages/RimeBridge/Tests/RimeBridgeTests/` | iOS Simulator 上的 RIME 桥接包测试 |
| `UniverseKeyboardTests/` | 由主 App 承载的主 App 单元测试 |
| `KeyboardTests/` | 不启动扩展 UI 的键盘合同 / 单元测试 |
| `UniverseKeyboardUITests/` | XCUITest 可行性探针（工具用途，本身不是产品或性能证据） |
| `KeyboardLayoutIntegrationTests/` | 用真实生产 Controller 与视图、跳过 bootstrap 的无宿主集成测试（出处 `KeyboardLayoutIntegrationTests/T9AdaptiveRowTests.swift`；推广到整个 target 为推断） |
| `KeyboardExtensionTests/` | 生产适配层 + 真实 Core 状态与 UIKit 控件的测试，不是真实扩展 Controller（出处 `KeyboardExtensionTests/T9RecoveryPresentationAdapterTests.swift`；推广到整个 target 为推断） |

## T9 拼音路径（拼音栏与「选拼音」）

**职责**：九键中文输入时，在候选栏上方显示当前焦点音节的拼音选择（compact paths）；用户可直接点选某个拼音，或按「选拼音」键在当前焦点内依次切换。状态由 KeyboardCore 持有，键盘扩展只渲染与转发动作（出处 `Packages/KeyboardCore/Sources/KeyboardCore/T9PinyinPath.swift` 类型注释、`docs/KEYBOARD_LAYOUT.md`）。

**关键文件**
- `Packages/KeyboardCore/Sources/KeyboardCore/T9PinyinPath.swift` — 拼音栏状态、可用性与窗口类型，以及从 RIME 注释提取 / 校验路径的工具。
- `Packages/KeyboardCore/Sources/KeyboardCore/T9PathViewport.swift` — 拼音栏视口偏移的纯函数 `T9PathViewport`（不依赖 UIKit；由 `Keyboard/Views/T9PinyinPathBarView.swift` 调用；测试 `Packages/KeyboardCore/Tests/KeyboardCoreTests/T9PathViewportTests.swift`）。
- `Packages/KeyboardCore/Sources/KeyboardCore/T9PinyinLocalPathCatalog.swift` — 路径值类型、展示快照类型与本地音节目录查询。
- `Packages/KeyboardCore/Sources/KeyboardCore/T9PinyinSyllableCatalog.generated.swift` — 生成的音节目录数据（生成脚本 `scripts/generate_t9_pinyin_syllable_catalog.py`）。
- `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+T9PinyinPath.swift` — 选拼音循环、直接点选、状态重建、快照恢复与回滚的控制器逻辑。
- `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardAction.swift` — 拼音栏相关动作枚举。
- `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardState.swift` — 在键盘状态里挂载拼音栏状态。

**入口函数与状态**
- 动作：`selectT9PinyinPath`、`cycleT9PinyinPath` — `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardAction.swift`；由 `handle` 分派 — `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController.swift`。
- 状态类型：`T9PinyinPathState`（字段如 `compactPaths`、`selectedPath`、`focusedSegmentIndex`、`confirmedSegmentValues`、`lockedLetterPrefix`、`retainedChoiceSourceRawInput`）、`T9PinyinPathAvailability`、`T9PinyinPathWindow`、`T9PinyinPathExtractor` — `Packages/KeyboardCore/Sources/KeyboardCore/T9PinyinPath.swift`。
- 路径与快照类型：`T9PinyinPath`、`T9PinyinPathKind`、`T9CompositionPresentationSnapshot`、`T9PinyinLocalPathCatalog` — `Packages/KeyboardCore/Sources/KeyboardCore/T9PinyinLocalPathCatalog.swift`。
- 状态挂载：`t9PinyinPathState` — `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardState.swift`。
- 选拼音循环：`handleCycleT9PinyinPath` — `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+T9PinyinPath.swift`。
- 直接点选：`handleSelectT9PinyinPath`（内部带 `autoAdvance` 参数；点选为 true，循环为 false）、`confirmFocusedT9SegmentAndAdvance` — `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+T9PinyinPath.swift`。
- 状态重建：`refreshT9PinyinPathState`、`applyT9PinyinPathStateFromNewRimeOutput`、`rebuildT9PinyinPathStateIfComposing`、`clearT9PinyinPathState` — `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+T9PinyinPath.swift`。
- 快照恢复与回滚：`restoreRetainedChoiceSnapshot`、`restoreSegmentFocusSnapshot`、`rollbackT9PinyinRefinement` — `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+T9PinyinPath.swift`。
- 删除恢复预选快照：在已选中的拼音后追加一个数字时，`T9PinyinPathState` 的 `selectedDigitUndo`（类型 `T9SelectedDigitUndo`）记下追加前的输入、拼音栏与选中项；随后的删除由 `handleT9CompositionIdentityDeleteIfNeeded` 恢复到追加前的输入与预选 — `Packages/KeyboardCore/Sources/KeyboardCore/T9PinyinPath.swift`、`Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+T9PinyinPath.swift`（测试 `testCycleSelectionAppendDigitDeleteRestoresPreview` — `Packages/KeyboardCore/Tests/KeyboardCoreTests/T9PinyinPathTests.swift`）。
- 对外查询：`t9PinyinPathAvailability`、`hasSelectableT9PinyinPaths`、`t9CompositionPresentationSnapshot`、`t9PinyinPathWindow` — `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+T9PinyinPath.swift`。

**已有断言守住的不变量**（测试文件 `Packages/KeyboardCore/Tests/KeyboardCoreTests/T9PinyinPathTests.swift`，除非另注）
- 选拼音按 first / next / wrap 依次选中，且不产生上屏文本：`testCycleSelectsMThenNThenOAndWrapsWhileRetainingChoices` — `Packages/KeyboardCore/Tests/KeyboardCoreTests/T9PinyinPathTests.swift`。
- 选拼音只改临时选中，不确认音节、不推进焦点：`testSelectPinyinCyclesWithoutConfirmingSegment`、`testSelectPinyinSwitchesTentativeValueWithoutAdvancingSegment` — `Packages/KeyboardCore/Tests/KeyboardCoreTests/T9PinyinPathTests.swift`。
- 连续按选拼音两轮，compact 顺序不变、选中与候选跟随：`testConsecutiveSelectPinyinKeepsCompactOrderAcrossTwoLoops` — `Packages/KeyboardCore/Tests/KeyboardCoreTests/T9PinyinPathTests.swift`。
- 直接点选完整音节且后面还有数字时，确认并推进到下一音节：`testDirectCompleteSyllableTapAdvancesWhenRemainingSlotsExist` — `Packages/KeyboardCore/Tests/KeyboardCoreTests/T9PinyinPathTests.swift`。
- 点选字母前缀只锁定、不推进：`testSelectedLetterPrefixOnMultiDigitFocusLocksWithoutAdvancing` — `Packages/KeyboardCore/Tests/KeyboardCoreTests/T9PinyinPathTests.swift`；`testPrefixBLocksWithoutAdvancingFocus` — `Packages/KeyboardCore/Tests/KeyboardCoreTests/T9PinyinCatalogTests.swift`。
- 重复点选已覆盖全部数字的路径不推进、不上屏：`testRepeatedWholePathTapDoesNotAdvanceSegmentOrCommit` — `Packages/KeyboardCore/Tests/KeyboardCoreTests/T9PinyinPathTests.swift`。
- 循环中细化失败时回滚到原选中与保留选项：`testCycleFailureRollsBackRetainedChoicesAndSelection` — `Packages/KeyboardCore/Tests/KeyboardCoreTests/T9PinyinPathTests.swift`。
- 未发出（未展示过）的路径即使兼容也被拒绝：`testCompatibleButUnissuedPathRejected` — `Packages/KeyboardCore/Tests/KeyboardCoreTests/T9PinyinPathTests.swift`；旧 revision 的点选被拒绝：`testStaleCompositionRevisionPathSelectionIsRejected` — `Packages/KeyboardCore/Tests/KeyboardCoreTests/T9PresentationSnapshotContractTests.swift`。
- 上屏、切换输入模式等生命周期事件清空拼音栏状态：`testLifecycleClearsPathState`、`testCandidateCommitClearsPathState` — `Packages/KeyboardCore/Tests/KeyboardCoreTests/T9PinyinPathTests.swift`。
- 过期窗口的扩展请求被丢弃：`testPathWindowGenerationGuardDropsStaleExtend` — `Packages/KeyboardCore/Tests/KeyboardCoreTests/T9PinyinPathTests.swift`。
- 展示快照把路径、候选、preedit 与分页绑定到同一 revision：`testSnapshotBindsPathsCandidatesPreeditAndPagingToOneRevision` — `Packages/KeyboardCore/Tests/KeyboardCoreTests/T9PresentationSnapshotContractTests.swift`。

**键盘扩展里的渲染与转发**
- `Keyboard/Views/T9PinyinPathBarView.swift` — 拼音栏视图 `T9PinyinPathBarView`（含 `T9PinyinPathBarCell`、`setPaths`）。
- `Keyboard/Controllers/KeyboardViewController+T9PinyinPath.swift` — 选拼音按键处理 `t9SelectPinyin`（发 `cycleT9PinyinPath`）、拼音栏点选 `handleT9PinyinPathButton`（发 `selectT9PinyinPath`）、`applyT9PresentationSnapshot`、`updateSelectPinyinButtonAvailability`、展开面板 `presentPinyinPathExpandedPanel`。
- `Keyboard/Controllers/KeyboardViewController+Rows.swift` — 创建「选拼音」按键并绑定 `t9SelectPinyin`。

**对应测试文件**
- `Packages/KeyboardCore/Tests/KeyboardCoreTests/T9PinyinPathTests.swift`
- `Packages/KeyboardCore/Tests/KeyboardCoreTests/T9PinyinCatalogTests.swift`
- `Packages/KeyboardCore/Tests/KeyboardCoreTests/T9PresentationSnapshotContractTests.swift`
- `KeyboardLayoutIntegrationTests/T9AdaptiveRowTests.swift`（拼音栏行的显示与收起，使用 `T9PinyinPathBarView`）
- `KeyboardExtensionTests/T9RecoveryPresentationAdapterTests.swift`（恢复期间对选拼音等控件的阻断）

**未覆盖 / UNKNOWN**
- 键盘扩展侧「选拼音」按键处理 `t9SelectPinyin` 与 `handleT9PinyinPathButton`（`Keyboard/Controllers/KeyboardViewController+T9PinyinPath.swift`）是否有直接单元测试：UNKNOWN（本次未找到直接调用它们的测试）。
- 展开面板（`presentPinyinPathExpandedPanel` — `Keyboard/Controllers/KeyboardViewController+T9PinyinPath.swift`，及加载更多）的断言归属：UNKNOWN。
- 与 Partial Commit、删除恢复、T9 身份（`T9CompositionIdentity` — `Packages/KeyboardCore/Sources/KeyboardCore/T9CompositionIdentity.swift`）的交互只在测试名层面可见，本节未展开：UNKNOWN。

## 未覆盖

- 主 App（`Universe Keyboard/`）各子系统 — TODO-after-launch
- 键盘扩展其它部分（候选栏、删除、粘贴、布局与按键） — TODO-after-launch
- KeyboardCore 其它部分（输入管线、Partial Commit、纠错、输入智能） — TODO-after-launch
- RimeBridge — TODO-after-launch
- EnvironmentDigestTool — TODO-after-launch
