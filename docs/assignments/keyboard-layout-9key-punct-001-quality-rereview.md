# KEYBOARD-LAYOUT-9KEY-PUNCT-001 — Quality Re-review Conclusion (Q2)

| Field | Value |
|---|---|
| **Date / timezone** | `2026-08-15 Asia/Shanghai` |
| **Reviewer role** | 🧪 Quality, Performance & Release Maintainer — independent of the Executor |
| **Object under review** | 当前工作区未提交实现（相对 `624193a4aff3e5377d21402d8cf507ce1ea5395d` / `main` 的 ADR 0029 落地 + Q1 后补测） |
| **Predecessor** | [Q1](keyboard-layout-9key-punct-001-quality-review.md)（`Fail`；已有 supersession banner；本文件针对补测后状态） |
| **Evidence inputs** | [Assignment](keyboard-layout-9key-punct-001.md) · [ADR 0029](../architecture/decisions/0029-t9-pending-punctuation-palette.md) §7 · [PD](../product-decisions/KEYBOARD-LAYOUT-9KEY-PUNCT-001-authorization.md) · [R2](keyboard-layout-9key-punct-001-architecture-rereview.md) · [Q1](keyboard-layout-9key-punct-001-quality-review.md) · `T9PendingPunctuationTests` 22 例 · `KeyboardTests/T9PunctuationChromeContractTests` · `T9CommonPunctuationChrome` + `Rows.swift` · `testingForceProvisionalAhead()` · 本 reviewer 独立复跑与源码对照 |

本 reviewer 不是 Executor，未实现该功能，不把 Assignment 标 Completed，不做 Product Gate / Release 结论。本文件只判断：**Q1 的 `Q-P1-01` / `Q-P1-02` / `Q-P1-03` 在补测后是否闭合**。

## Verdict

**Pass with conditions**

Q1 三条 P1 均已有对应用例，且由本 reviewer 独立复跑为绿：

- `Q-P1-01`：**闭合**。ADR 0029 §7 在 Q1 缺席的 L1 / provisional ahead 拒键、接受后 leftover 刷新 0017、成对 Delete、stale-ahead 标点候选 fail-closed，现均有确定性 Core 用例。
- `Q-P1-02`：**闭合**。`A2-P2-02` 已覆盖「无 pending 点选」和「失权后点选」，host 文本不变、不退化成追加插入。
- `Q-P1-03`：**闭合**。`KeyboardTests` 现有键面文案与 selector 接线合同；`T9CommonPunctuationChrome` 被 `Rows.swift` 引用；轮换算术未搬进 UIKit 测试。

本结论只替代 Q1 对「当前补测后实现」的 Quality 阅读。它：

- **不授权 Product Gate**
- **不替代真机**
- **不把 Assignment 标 Completed**
- **不把 FakeTextInputClient / Simulator 绿写成 Release 或真机证据**
- **不把 `A2-P2-04` 当成已验证**

## Q1 P1 closure

| ID | Q1 要求 | 补测落点 | 本复审判断 |
|---|---|---|---|
| `Q-P1-01` | §7 必测项：L1 / provisional ahead 拒绝、接受后 leftover 刷新 0017、成对 Delete / 拆不干净只留 opener、stale-ahead 标点候选 fail-closed | `testProvisionalAheadRejectsPunctuationKeyAndKeepsComposition`（`testingForceProvisionalAhead()` 写 L1 mirror）；`testAcceptingPendingRefreshesContinuationFromLeftover`（切页接受后 leftover `，` 打开 0017）；`testPairedOpenerDeleteRemovesBothSides`；`testPairCompletionDisabledInsertsOpenerOnly`；`testStaleAheadPunctuationCandidateIsFailClosed` | **Closed**。拆除失败后的 opener-only pending 仍无独立 Fake 用例；实现此时清 pending、不猜 closer。该缺口不重开 P1，归入下方条件 / `A2-P2-04` 相邻残差。 |
| `Q-P1-02` | 无 pending 或失权后点 `.punctuationCandidate` 不得追加 `insertText` | `testPunctuationCandidateWithoutPendingDoesNotAppend`；`testPunctuationCandidateAfterLosingSpanDoesNotAppend` | **Closed**。两条都断言 `effects.isEmpty` 且 host 不变。 |
| `Q-P1-03` | Extension 测试覆盖键面 `，。？！` 与动作接线，且不复制轮换算术 | `T9CommonPunctuationChrome` + `KeyboardViewController+Rows.swift` 引用；`KeyboardTests/T9PunctuationChromeContractTests` 锁文案、`insertT9CommonPunctuation`、`.pressT9CommonPunctuation`，并禁止 `insertDirectText("，")` / ASCII `",?!"` | **Closed**。这是源码合同，不是运行时 UIKit 视图树；足以闭合 Q1 的接线缺口，不能当成真机键面证明。 |

## Evidence classification

| Check | Review position |
|---|---|
| `xcrun swift-format lint --strict --configuration .swift-format`（本项全部变更 `.swift`，含未跟踪新文件） | Quality-reverified pass；`SWIFT_FORMAT_EXIT=0`（`2026-08-15 21:02 CST`） |
| `swift test --package-path Packages/KeyboardCore --build-path /tmp/keyboardcore-punct-quality-q2b` | Quality-reverified pass：`1029` tests, `0` failures；`T9PendingPunctuationTests` **22 / 0**（`2026-08-15 21:06:16 CST`）；`CandidateKindTests` **15 / 0**，其中 `testPendingPunctuationEffectUsesRemainingUInt8Bit` **已被 XCTest 发现并通过**；`SWIFT_TEST_EXIT=0`（`2026-08-15 21:06:34 CST`）。指定 path `/tmp/keyboardcore-punct-quality-q2` 曾启动；本 reviewer 用独立 `q2b` 拿到完整可审计日志，与 Q1 的 `/tmp/keyboardcore-punct-quality` 隔离。 |
| `xcodebuild` `KeyboardTests/T9PunctuationChromeContractTests`（destination `iPhone 17 Pro,OS=26.5`；独立 `-derivedDataPath /tmp/uk-punct-quality-q2`） | Quality-reverified pass：suite **2 / 0**；`** TEST SUCCEEDED **`；`XCODEBUILD_EXIT=0`（`2026-08-15 21:06:34 CST`） |
| `RimeBridgeTests` xcodebuild | 未跑 |
| App + Keyboard 全套 xcodebuild（`UniverseKeyboardTests` / 其余 `KeyboardTests`） | 未跑。本轮只复跑 Q1 复审门要求的 chrome 合同 target 过滤。 |
| Debug / Release `build` | 未跑 |
| 真机 / Human Product Gate | 未跑；不得由本文件代签 |

## ADR 0029 §7 测试合同

| §7 条目 | 覆盖 | 缺口 | 是否阻塞 Q2 |
|---|---|---|---|
| 无 pending 单击 → host `，` + 候选表 | `testFirstPressInsertsPendingCommaAndPalette` | 无 | 否 |
| 1.0s 内同键走完四键并回绕 | `testSameKeyCyclesWithinOneSecondAndWraps` | 无 | 否 |
| 1.0s 外同键 → `，，`，pending 指向后一个 | `testSameKeyAfterTimeoutStartsNewComma` | 无 | 否 |
| 候选替换；候选后再点该键 → 接受旧标点并新开 `，` | `testCandidateReplacesPendingAndDisarmsCycle` | 无 | 否 |
| Delete 只拆仍持有的 pending | `testDeleteRemovesOnlyPendingSpan` | 无 | 否 |
| 外部 document 变化后不再按旧 span 删除 | `testExternalDocumentChangeDropsOwnershipWithoutDeleting` | 失权后再 Delete 的旧 span 手术仍靠 `pending == nil` 不可达，无单独断言 | 否 |
| 组字中先提交首选、Path 被清空，再进 pending | `testCompositionCommitsFirstCandidateThenPendingComma` | 无 RIME engine；走 FakeCandidateProvider + `commitInlinePreedit` | 否（Core 合同已覆盖；真机另论） |
| L1 / provisional ahead 拒绝该键，composition 仍在 | `testProvisionalAheadRejectsPunctuationKeyAndKeepsComposition`：`testingForceProvisionalAhead()` 经 `appendT9DigitAccept` 写 L1 mirror，随后 `isResponsiveProvisionalAhead == true`，按键 `effects.isEmpty`，composition 仍为 `ni` | 未另开一条「非 hook、真实按键推进 L1」的集成路径 | 否 |
| pending 期间 continuation 为空；接受后才按留下的文本刷新 0017 | 首按用例仍锁 pending 期间 `continuation.isEmpty`；`testAcceptingPendingRefreshesContinuationFromLeftover` 用切页接受 leftover `，` → `["呀"]` | 删除路径未再锁 0017；ADR 写的是接受后 | 否 |
| 空格 = 接受 + 插入空格，不选紧凑栏第一项 | `testSpaceAcceptsThenInsertsSpace`（host 为 `， `） | 未显式断言没选中紧凑栏第一项；结果文本已排除该路径 | 否 |
| 成对 opener 的两侧载荷替换/删除，以及拆不干净时只保留 opener | 替换：`testPairedOpenerTracksBothSidesAndReplacesCleanly`；Delete：`testPairedOpenerDeleteRemovesBothSides`；成对关闭 → opener-only：`testPairCompletionDisabledInsertsOpenerOnly` | **无**「`removeOwnedPendingSpan` 失败后仍以 opener-only 作为新 pending」用例。实现失败时清 pending、不猜 closer | 否（不重开 P1；见条件） |
| stale-ahead 时标点候选 fail-closed | `testStaleAheadPunctuationCandidateIsFailClosed`：ahead 时点 `.punctuationCandidate` → `[]` 且 host 不变 | 无 | 否 |
| Extension 测试覆盖键面文案与动作接线，不在 UIKit 里复制轮换算术 | `T9PunctuationChromeContractTests` 2 例；`Rows.swift` 引用 `T9CommonPunctuationChrome.keyTitle` / `accessibilityLabel`；`ModeActions` 发 `.pressT9CommonPunctuation` | 源码合同，不是运行时按钮树 | 否 |

## R2 P2 测试收口

| ID | 要求 | 本评审判断 |
|---|---|---|
| `A2-P2-01` | 无首选组字残余态按 L1 拒绝 | **已进测试**：`testCompositionWithoutCandidatesRejectsKey`（Q1 已确认，本轮仍在 22 例中） |
| `A2-P2-02` | 无 span 的候选点选不得追加插入 | **已进测试**：无 pending、失权后点选两条均不改 host |
| `A2-P2-03` | 失权即清 pending | **已进测试**：`testExternalDocumentChangeDropsOwnershipWithoutDeleting`；失权后再点选用例也断言 `pending == nil` |
| `A2-P2-04` | 成对手术中途撕裂不在 ADR 对账 | **不得当成已验证**。没有中途撕裂用例；Core / Fake / 本轮 Simulator 过滤绿不能证明真实 `UITextDocumentProxy`。这是 Quality / Human Product Gate 残余，不是本轮 Pass 条件，也不是可以勾掉的验证项。 |

## Conditions（Pass 的边界，不是新的 P1）

| ID | Owner | Disposition | Pointer |
|---|---|---|---|
| `Q2-C-01` | Quality / Human Product Gate | `accept` — 明确 **未验证** | `A2-P2-04`：成对 `adjustTextPosition` + 连续 `deleteBackward` 中途撕裂。真实 host 与 Fake 不一致的风险仍在 ADR Risks。 |
| `Q2-C-02` | Quality / Human Product Gate | `accept` — 明确 **未验证** | 拆除失败 → opener-only pending 仍无 Fake 用例。实现 `removeOwnedPendingSpan == false` 时清 pending，不插入 opener-only 新载荷。禁止把 Fake 绿读成该策略已在真机成立。 |
| `Q2-C-03` | Quality / Human Product Gate | `tech_debt` | 本评审未跑 RimeBridge、App+Keyboard 全套、Debug/Release `build`、真机。不得用 KeyboardCore `1029/0` 或过滤后的 `KeyboardTests` 2 例代替。 |
| `Q2-C-04` | Quality / Human Product Gate | `accept` | chrome 合同是读源码字符串，不是 Simulator 上按下九键标点键的运行时证明。 |

## Residuals after P1 closure

| ID | Owner | Disposition | Pointer |
|---|---|---|---|
| `Q-P2-01` | Quality / Human Product Gate | `accept` — 明确 **未验证** | 同 `Q2-C-01` / `A2-P2-04`。 |
| `Q-P2-02` | Input Intelligence | `tech_debt` | `ownedHostMutationGeneration` 只自增，从不消费。深度守卫只能挡住同步 `textDidChange`；延迟回调是否误 `accept` 只能由真机 / 延迟 Fake 证明。本轮仍不升级为 P1。 |
| `Q-P2-03` | Executor | **Closed** | `testPendingPunctuationEffectUsesRemainingUInt8Bit` 现位于 `CandidateKindTests` 类内；独立复跑日志出现该名字并 passed；`CandidateKindTests` 现为 15 例。 |
| `Q-P2-04` | Executor | **Closed as Core contract** | `testReturnAndEnglishToggleAcceptPending` 覆盖回车 / 切英文接受。生产接线仍须真机确认，但 Q1 所说的 Core 缺口已补。 |
| `Q-P2-05` | Quality / Human Product Gate | `tech_debt` | 同 `Q2-C-03`。 |

## Implementation observations（不单独改变 Verdict）

- `testingForceProvisionalAhead()` 不是平行假开关：它调用 `provisionalCompositionMirror.appendT9DigitAccept(revision:1, epoch:1)`，使 `isResponsiveProvisionalAhead` 为真。标点键与标点候选的 fail-closed 都先走 `rejectIfResponsiveProvisionalAhead()`。
- pending 写入仍走 `textClient?.insertText` 而不是 `KeyboardController.insertText`，避开 0017 刷新边界。`testAcceptingPendingRefreshesContinuationFromLeftover` 锁住了这条选择：pending 期间 continuation 为空，接受后才按 leftover 刷新。
- `handlePunctuationCandidate` 在 `pending == nil` 或 `!canMutateHost` 时直接 `[]`，不会落到普通 `insertText`。Q-P1-02 的两条用例对上了这条守卫。
- Extension chrome 单一来源是 `T9CommonPunctuationChrome`；`Rows.swift` 只引用 key title / accessibility，`ModeActions` 只发 Core 动作。符合 ADR「不在 UIKit 里复制轮换算术」。
- 热路径未见新的无界日志或同步部署 I/O。

## What this review does not do

- 不授权 Product Gate
- 不替代真机
- 不把 Assignment 标 Completed
- 不把 `A2-P2-04` 勾成已验证
- 不声称可以合并到默认分支：本评审未跑与 CI 等价的 RimeBridge / 全套 App+Keyboard / Debug+Release `build`

下一步若进入 Human Product Gate，必须单独走真机矩阵，并显式携带 `A2-P2-04` 未验证。

`SUMMARY_DECISION=Pass with conditions`
