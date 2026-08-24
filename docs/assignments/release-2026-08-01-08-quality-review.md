# RELEASE-2026-0801-08 — Quality Review Conclusion (Q1)

| Field | Value |
|---|---|
| **Date / timezone** | `2026-08-23 Asia/Shanghai` |
| **Reviewer role** | 🧪 Quality, Performance & Release Maintainer — independent of the Executor |
| **Object under review** | 当前工作区未提交的 ADR 0030 / pending 颜表情落地（相对 `4fd3ce70d9ac`）。**只审 08 切片**，不把 dirty worktree 里的许可证 / Schema / 06 文案改动算进本项 |
| **Evidence inputs** | [Assignment](release-2026-08-01-08-kaomoji-content.md) · [ADR 0030](../architecture/decisions/0030-pending-kaomoji-palette.md) Decision · [PD](../product-decisions/RELEASE-2026-0801-08-kaomoji-catalog.md) · [Architecture Pass](release-2026-08-01-08-architecture-review.md)（契约对照，**不是**测试覆盖证明）· Executor-recorded Core 证据（需独立复跑）· Human-reported smoke（**不得**代签 Product Gate）· `PendingKaomojiTests` · `T9PendingPunctuationTests` · `T9KaomojiChromeContractTests` · 本 reviewer 独立复跑与源码对照 |
| **Scope in** | `PendingKaomoji.swift`、`KeyboardController+PendingKaomoji.swift`、抽出的 `removeOwnedHostSpan` / 互斥入口、`KeyboardEffect` UInt16 bit 8、`KeyboardAction` / `CandidateItem` / `KeyboardState` / handle-delete-abandon、候选栏接线、九键与符号页 chrome、`PendingKaomojiTests`、`CandidateKindTests` kaomoji 位、`T9KaomojiChromeContractTests`、`CandidateModelContractTests` rawValue `6` |
| **Scope out** | `Universe Keyboard/ThirdPartyLicenses/`、`ThirdPartyLicenseDescriptor.swift`、SchemaManager / 许可证 UI、06 文案。这些文件的未测状态 **不** 构成 08 Fail |

本 reviewer **不是** Executor，未实现 ADR 0030，未写生产 Swift。不把 Assignment 标 Completed，不做 Product Gate / Release 结论，不授权 merge。Architecture Pass 与 Human 口述「没问题」在本文件中只作背景，**不得**升级为本 Quality Gate。

## Verdict

**Pass with conditions**

ADR 0030 Decision 的必测语义在 KeyboardCore 有确定性用例，且由本 reviewer 用独立 build path 复跑为绿：单击默认 `^_^`、同键 accept+新开且不 cycle、候选替换 / 点已 pending 不追加、compact 含展开表 pending、非法 token / 无 pending / 失权后不追加、Delete 只拆 owned span、外部 document 失权不回删、空格接受后再插空格、组字有首选一次写入 / 无首选与 L1-ahead 拒绝、与标点互斥且接受后标点仍能轮换、可见性 abandon 清状态不删 host、回车 / 切英文接受。`T9PendingPunctuationTests` **22 / 0**（抽出 span 助手后的位移回归）。Extension chrome 合同绿：两键共用 `.pressKaomoji`，引用 `KaomojiChrome`，不再是占位 hint。`swift-format lint --strict` 对本项 `.swift`（含未跟踪新文件）为绿。

本结论只判断：**08 颜表情切片的测试合同在已复跑范围内闭合到可带条件的 Quality 阅读**。它：

- **不授权 Product Gate**
- **不替代真机 / VoiceOver**
- **不把 Assignment 08 标 Completed / Closed**
- **不授权 merge**
- **不把 FakeTextInputClient / Simulator 绿写成 Release 或真机证据**
- **不把 Architecture Pass 当成测试覆盖证明**
- **不把 Human-reported smoke 升级为 Product Gate**

## Evidence classification

| Check | Review position |
|---|---|
| `xcrun swift-format lint --strict --configuration .swift-format`（本项变更 `.swift`，含未跟踪 `PendingKaomoji.swift` / `KeyboardController+PendingKaomoji.swift` / `PendingKaomojiTests.swift` / `T9KaomojiChromeContractTests.swift`） | **Quality-reverified pass**；`SWIFT_FORMAT_EXIT=0`（`2026-08-23 22:44:54 CST`） |
| `swift test --package-path Packages/KeyboardCore --build-path /tmp/keyboardcore-kaomoji-quality-q1` | **Quality-reverified pass**：`1054` tests, `0` failures；`PendingKaomojiTests` **23 / 0**（`2026-08-23 22:45:26.683 CST`）；`T9PendingPunctuationTests` **22 / 0**（`2026-08-23 22:45:35.739 CST`）；`CandidateKindTests` **16 / 0**，含 `testPendingKaomojiEffectUsesWidenedBitEight`；`SWIFT_TEST_EXIT=0`（`2026-08-23 22:45:48 CST`）。与 Executor 路径隔离。 |
| Executor 记录的 KeyboardCore `1054 / 0`、过滤 `61 / 0`（`docs/evidence/release-2026-08-01-08-pending-kaomoji-core-2026-08-23.md`） | **Executor-recorded**。本评审独立复跑全套 `1054 / 0`；`23+22+16=61` 与过滤声称一致，仍只覆盖已写用例，**升级为 Quality-reverified 的是本评审自己的命令，不是 Executor 原文** |
| `xcodebuild` 过滤 `KeyboardTests/T9KaomojiChromeContractTests` + `T9PunctuationChromeContractTests` + `CandidateModelContractTests`（destination `platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0`；`-derivedDataPath /tmp/uk-kaomoji-quality-q1`；`CODE_SIGNING_ALLOWED=NO`） | **Quality-reverified pass**：Selected tests **6 / 0**（各 suite **2 / 0**）；`** TEST SUCCEEDED **`；`XCODEBUILD_EXIT=0`（`2026-08-23 22:45:52 CST`） |
| Debug `xcodebuild` `build` 同 destination、同 derivedDataPath | **Quality-reverified pass**：`** BUILD SUCCEEDED **`；`XCODEBUILD_DEBUG_BUILD_EXIT=0`（`2026-08-23 22:46:10 CST`）。在过滤测试之后增量 build，不是 Executor 产物 |
| `RimeBridgeTests` xcodebuild | **未跑** |
| App + Keyboard 全套 xcodebuild（`UniverseKeyboardTests` / 其余 `KeyboardTests`） | **未跑**。本轮只复跑 08 合同过滤 + Debug build |
| Release `build` | **未跑** |
| 与 CI 等价的 `SWIFT_VERSION=6.0` / `SWIFT_TREAT_WARNINGS_AS_ERRORS=YES` 全套门禁 | **未跑** |
| 真机 host 手术 / VoiceOver / Human Product Gate | **未跑**；Human-reported smoke 仍是 Executor-recorded 口述，**不得**由本文件代签 |

### 精确命令

1. Format（exit 0，`2026-08-23 22:44:54 CST`）

```
xcrun swift-format lint --strict --configuration .swift-format \
  Packages/KeyboardCore/Sources/KeyboardCore/PendingKaomoji.swift \
  Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+PendingKaomoji.swift \
  Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+PendingPunctuation.swift \
  Packages/KeyboardCore/Sources/KeyboardCore/KeyboardEffect.swift \
  Packages/KeyboardCore/Sources/KeyboardCore/KeyboardAction.swift \
  Packages/KeyboardCore/Sources/KeyboardCore/CandidateItem.swift \
  Packages/KeyboardCore/Sources/KeyboardCore/KeyboardState.swift \
  Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController.swift \
  Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+Candidates.swift \
  Keyboard/Controllers/KeyboardViewController+Rows.swift \
  Keyboard/Controllers/KeyboardViewController+ModeActions.swift \
  Keyboard/Controllers/KeyboardViewController+CandidateBar.swift \
  Keyboard/Controllers/KeyboardViewController+CandidateDataSource.swift \
  Keyboard/Controllers/KeyboardViewController+Presentation.swift \
  Keyboard/Controllers/KeyboardViewController+KeyAccessibility.swift \
  Keyboard/Views/CandidateBar/CandidateBarDataSource.swift \
  Packages/KeyboardCore/Tests/KeyboardCoreTests/PendingKaomojiTests.swift \
  Packages/KeyboardCore/Tests/KeyboardCoreTests/CandidateKindTests.swift \
  KeyboardTests/T9KaomojiChromeContractTests.swift \
  KeyboardTests/CandidateModelContractTests.swift
```

2. KeyboardCore（exit 0，`2026-08-23 22:45:48 CST`）

```
swift test --package-path Packages/KeyboardCore --build-path /tmp/keyboardcore-kaomoji-quality-q1
```

3. KeyboardTests 过滤（exit 0，`2026-08-23 22:45:52 CST`）

```
xcodebuild -project "Universe Keyboard.xcodeproj" \
  -scheme "Universe Keyboard" -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0' \
  CODE_SIGNING_ALLOWED=NO \
  -derivedDataPath /tmp/uk-kaomoji-quality-q1 \
  -only-testing:KeyboardTests/T9KaomojiChromeContractTests \
  -only-testing:KeyboardTests/T9PunctuationChromeContractTests \
  -only-testing:KeyboardTests/CandidateModelContractTests \
  test
```

4. Debug build（exit 0，`2026-08-23 22:46:10 CST`）

```
xcodebuild -project "Universe Keyboard.xcodeproj" \
  -scheme "Universe Keyboard" -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0' \
  CODE_SIGNING_ALLOWED=NO \
  -derivedDataPath /tmp/uk-kaomoji-quality-q1 \
  build
```

## 测试合同对照（ADR 0030 Decision + Architecture Confirmed boundaries）

| 条目 | 覆盖 | 缺口 | 是否阻塞 Q1 |
|---|---|---|---|
| 单击 → host `^_^` + 紧凑栏含 pending 且 `^_^` 第一 | `testFirstPressInsertsDefaultPendingAndIncludesItInCompact` | 无 | 否 |
| 同键再点 → accept + 新开默认，host `^_^^_^`，**不** cycle | `testSameKeyAcceptsThenStartsNewDefaultWithoutCycling` | 无 | 否 |
| 候选替换；点已 pending 项不追加 | `testCandidateReplacesPendingAndKeepsOwnership`；`testTappingAlreadyPendingItemDoesNotAppend` | 无 | 否 |
| compact 包含仅在展开表里的 pending（`:)`） | `testCompactIncludesExpandedOnlyPending` | 无 | 否 |
| 非法 token / 无 pending / 失权后点选不得追加 | `testUnknownKaomojiCandidateDoesNotAppend`；`testKaomojiCandidateWithoutPendingDoesNotAppend`；`testKaomojiCandidateAfterLosingSpanDoesNotAppend` | 无 | 否 |
| Delete 只拆 owned span | `testDeleteRemovesOnlyPendingSpan` | 无 | 否 |
| 外部 document change 失权不回删 | `testExternalDocumentChangeDropsOwnershipWithoutDeleting` | 失权后再 Delete 旧 span 靠 `pending == nil` 不可达，无单独断言 | 否 |
| 空格 = 接受 + 插入空格（不是点选第一项） | `testSpaceAcceptsThenInsertsSpace`（host `^_^ `） | 未显式断言没选中紧凑栏第一项；结果文本已排除该路径 | 否 |
| 组字有首选 → 一次写入首选+`^_^`；无首选 / L1-ahead 拒绝 | `testCompositionCommitsFirstCandidateThenDefaultKaomoji`；`testCompositionWithoutCandidatesRejectsKey`；`testProvisionalAheadRejectsKaomojiKeyAndKeepsComposition` | 无真实 RIME engine；ahead 走 `testingForceProvisionalAhead()` | 否（Core 合同已覆盖；真机另论） |
| 与标点互斥；接受颜表情后标点仍能轮换 | `testKaomojiAndPunctuationAreMutuallyExclusive`；`testPunctuationCycleStillWorksAfterKaomojiAccept`（`^_^。`，`cycleIndex == 1`） | 无 | 否 |
| 可见性 abandon 清状态不删 host | `testVisibilityAbandonClearsKaomojiStateWithoutDeletingHost` | 无 | 否 |
| 回车 / 切英文接受 | `testReturnAndEnglishToggleAcceptPending` | 生产接线仍须真机 | 否（Core 合同已覆盖） |
| Extension chrome：两键共用 `.pressKaomoji`，引用 `KaomojiChrome`，不再是占位 hint | `T9KaomojiChromeContractTests` **2 / 0**；`Rows.swift` 九键与符号页均 `#selector(insertKaomoji(_:))` + `KaomojiChrome.keyTitle`；`ModeActions` `handle(.pressKaomoji)`；断言不含「打开颜表情入口（占位）」 | 源码合同，不是运行时按钮树；`showKaomojiCandidatesPlaceholder` 仍作为兼容转发残留 | 否 |
| Architecture `A30-P2-08`：26 键字母页没有 `^_^` 键 | **源码成立**：`makeLetterThirdRow` 仍是 `z…m`，`insertKaomoji` 只出现在九键右列与中文符号页 | **合同测试缺**：chrome 用例未断言 26 键字母页不含 `KaomojiChrome` / `insertKaomoji` | **否**（P2 / 条件，不 Fail） |
| Architecture `A30-P2-06`：VoiceOver `.selected` / 「已选中」 | 未落地。`isPreferredCandidate` 对 `.kaomojiCandidate` 用 `title == pending.text` 走反色；`CandidateCollectionCell` 只有 `.button`，accessibilityLabel 无「已选中」。0029 标点同样没有 | **未验证**；禁止为补 `.selected` 把空格接到第一项 | **否**（必须写入残差，不因此 Fail） |
| `T9PendingPunctuationTests` 位移回归 | 本复跑 **22 / 0** | Fake 绿 ≠ 真机 host | 否 |
| stale-ahead 颜表情候选 fail-closed | `testStaleAheadKaomojiCandidateIsFailClosed` | 无 | 否 |
| pending 期间 continuation 空；接受后 leftover 刷新 0017 | `testAcceptingPendingRefreshesContinuationFromLeftover` | 删除路径未再锁 0017 | 否 |
| `CandidateKind.kaomojiCandidate.rawValue == 6`；effect bit 8 | `CandidateModelContractTests`；`CandidateKindTests.testPendingKaomojiEffectUsesWidenedBitEight` | 无 | 否 |

## Architecture P2 收口（`A30-P2-01…08`）

| ID | Architecture 要求 | 本 Quality 判断 |
|---|---|---|
| `A30-P2-01` | `KeyboardEffect` UInt16 bit 8 = `.pendingKaomojiChanged`；不得复用 bit 5 / 7 | **已进测试**：`testPendingKaomojiEffectUsesWidenedBitEight` 锁 `rawValue == 1 << 8` 且 `refreshesCandidatePresentation`。`Presentation.swift` 已改读该属性。 |
| `A30-P2-02` | `acceptingPendingPunctuationIfNeeded` 先接受颜表情再标点再 body；名称滞后 | **生产接线成立**（先 `acceptPendingKaomoji`）。名称不是测试合同。残差：调用点不得被读成「只清标点」。 |
| `A30-P2-03` | 组字入口 `commitInlinePreedit(首选 + "^_^")`；真机 unmark 光标仍归 Product Gate | **Core 已测**一次写入 `你^_^`。真机光标 **未验证**。 |
| `A30-P2-04` | 抽出 `removeOwnedHostSpan`；0029 测试仍绿；真机成对撕裂仍是 0029 残余 | **位移回归已测**（`T9PendingPunctuationTests` 22/0）。**不得当成真机 host 证明**。 |
| `A30-P2-05` | 抄录表近形重复按字面保留 | **不在本轮测试合同**。Product / Human 校正残差。 |
| `A30-P2-06` | PD 写 VoiceOver `.selected` / 「已选中」；实现未落地 | **未落地、未验证**。与 0029 标点相同缺口。写入 Exit / 无障碍残差，**不 Fail**。 |
| `A30-P2-07` | init 不阻止双 pending；生产入口互斥；失权后点选不得追加 | **互斥与不追加已测**。init 守卫未测；不升 P1。 |
| `A30-P2-08` | 26 键字母页不加 `^_^`；chrome 测试未断言 | **源码成立，合同测试缺**。条件 / P2，不构成 Q1 Fail。 |

## Blocking findings

无。

## Conditions / Residuals（Pass 的边界，不是新的 P1）

| ID | Owner | Disposition | Pointer |
|---|---|---|---|
| `Q1-C-01` | Quality / Human Product Gate | `tech_debt` | 未跑 `RimeBridgeTests`、App+Keyboard 全套、Release `build`、CI 等价 `SWIFT_TREAT_WARNINGS_AS_ERRORS`。Debug build 与过滤 6 例 **不得**读成可合并。 |
| `Q1-C-02` | Quality / Human Product Gate | `accept` — 明确 **未验证** | 真机 `UITextDocumentProxy` host 手术（与 0029 `A2-P2-04` / `A30-P2-04` 同类）。Fake / Simulator 绿不是真机证据。 |
| `Q1-C-03` | Quality / Human Product Gate / 08 Exit | `accept` — 明确 **未验证** | `A30-P2-06`：pending 颜表情无障碍 `.selected` / 「已选中」未落地。视觉 preferred 存在；VoiceOver 未测。禁止用空格点选第一项来「补」无障碍。 |
| `Q1-C-04` | Executor（可选补测） | `tech_debt` | `A30-P2-08`：可在 `T9KaomojiChromeContractTests` 锁 26 键字母页源码不含 `insertKaomoji` / `KaomojiChrome`。不挡本 Q1。 |
| `Q1-C-05` | Quality / Human Product Gate | `accept` | chrome 合同是读源码字符串，不是 Simulator 上按下 `^_^` 的运行时证明。 |
| `Q1-C-06` | Product Lead / task 05 / Human | `accept` | Assignment Exit 仍要求：无障碍/设备检查、license/copy 交接 05、Human Product Gate。`A30-P2-05` 近形重复仍可由 Human 校正。本文件 **不是** 这些门。 |
| `Q1-C-07` | Quality / Human Product Gate | `accept` | Human-reported smoke（`docs/evidence/release-2026-08-01-08-human-device-smoke-2026-08-23.md`）无设备型号 / iOS / build SHA / 场景矩阵，**不是** Product Gate。 |

## Implementation observations（不单独改变 Verdict）

- 平行 `pendingKaomoji` 无 `cycleIndex` / `lastSameKeyTap` / `cycleArmed`；同键走 accept 再 `insertFreshPendingKaomoji`。
- 组字路径不含 `finishActiveCompositionAsDisplayText`，不把颜表情喂 RIME punctuator。
- `CandidateBarDataSource`：pending 标点先于颜表情（依赖互斥）；`isPreferredCandidate` 对颜表情按 title，标点仍不进组字首选高亮。
- `showKaomojiCandidatesPlaceholder` 仍转发到 `insertKaomoji`。chrome 合同已排除旧占位 hint 文案。
- 热路径未见新的无界日志或同步部署 I/O。
- dirty worktree 的许可证 / Schema 改动不在本切片；其测试状态不进入 08 Fail。

## Skipped With Reason

| Check | Reason |
|---|---|
| `RimeBridgeTests` | Q1 未强制；颜表情不碰 RIME punctuator / 部署边界 |
| App+Keyboard 全套 | Q1 只要求 chrome / candidate-kind 过滤 |
| Release `build` | 时间允许时优先 Debug；Release 未跑 |
| CI 全套 `SWIFT_TREAT_WARNINGS_AS_ERRORS` | 与「可合并」门禁对齐的步骤未齐，故 **不得**写可合并 |
| 真机 / VoiceOver | Human Product Gate；本角色不代签 |

## What this review does not do

- 不替代 Human Product Gate
- 不把 Fake / Simulator 绿写成真机证据
- 不授权 merge 到默认分支
- 不关闭 Assignment 08
- 不改 ADR 0030 Status
- 不更新 `docs/ACTIVE_WORK.md`
- 不把 Architecture Pass 或 Executor 声称的测试绿写成 Quality 证明（本文件的绿来自独立复跑）

下一步若进入 Human Product Gate，必须单独走真机矩阵，并显式携带 `A30-P2-04` / `A30-P2-06` 未验证。

`SUMMARY_DECISION=Pass with conditions`

### Non-claims

- 不替代 Human Product Gate
- 不授权 merge
- 不关闭 Assignment 08
- 不把 FakeTextInputClient / Simulator 绿写成真机证据
