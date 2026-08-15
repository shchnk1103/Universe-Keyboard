> **Supersession (KOS 2.1 S-03):** 本文件是 Q1 `Fail`。Executor 已按 `Q-P1-01…03` 补测。本 Verdict 不得被读成当前实现的 Quality Gate。

# KEYBOARD-LAYOUT-9KEY-PUNCT-001 — Quality Review Conclusion

| Field | Value |
|---|---|
| **Date / timezone** | `2026-08-15 Asia/Shanghai` |
| **Reviewer role** | 🧪 Quality, Performance & Release Maintainer — independent of the Executor |
| **Object under review** | 当前工作区未提交实现（相对 `624193a4aff3e5377d21402d8cf507ce1ea5395d` / `main` 的 ADR 0029 落地） |
| **Evidence inputs** | [Assignment](keyboard-layout-9key-punct-001.md) · [ADR 0029](../architecture/decisions/0029-t9-pending-punctuation-palette.md) §7 · [PD](../product-decisions/KEYBOARD-LAYOUT-9KEY-PUNCT-001-authorization.md) · [R2](keyboard-layout-9key-punct-001-architecture-rereview.md) · `T9PendingPunctuationTests` 14 例 · 本 reviewer 独立复跑与源码对照 |

本 reviewer 不是 Executor，未实现该功能，不把 Assignment 标 Completed，不做 Product Gate / Release 结论。

## Verdict

**Fail**

ADR 0029 §7 的「至少」测试合同尚未闭合：L1 / provisional ahead、接受后按留下文本刷新 0017、成对删除 / 拆不干净只留 opener、stale-ahead 标点候选 fail-closed，以及 Extension 键面 / 动作接线测试均缺席。R2 要求实现时收进测试清单的 `A2-P2-02` 也没有对应用例。

KeyboardCore 全套 **1020 / 0** 与 `swift-format lint --strict` 由本 reviewer 独立复跑为绿，只能证明「已写的 14 个 Core 用例通过」，不能把实现描述为 Quality Gate 可过或可合并。

本结论：

- **不授权 Product Gate**
- **不替代真机**
- **不把 Assignment 标 Completed**
- **不把 FakeTextInputClient / Simulator 绿写成 Release 或真机证据**

## Evidence classification

| Check | Review position |
|---|---|
| `xcrun swift-format lint --strict --configuration .swift-format`（本项全部变更 `.swift`） | Quality-reverified pass |
| `swift test --package-path Packages/KeyboardCore --build-path /tmp/keyboardcore-punct-quality` | Quality-reverified pass：`1020` tests, `0` failures；`T9PendingPunctuationTests` **14 / 0**；`SWIFT_TEST_EXIT=0`（`2026-08-15 20:44:01 CST`） |
| Executor 记录的 KeyboardCore `1020 / 0`（`/tmp/keyboardcore-punct-build`） | Executor-recorded；本评审用独立 build path 复跑后与计数一致，仍只覆盖已写用例 |
| `RimeBridgeTests` xcodebuild | 未跑 |
| App + Keyboard xcodebuild（含 `UniverseKeyboardTests` / `KeyboardTests`） | 未跑。仓库里 `KeyboardTests/CandidateModelContractTests` 只加了 `punctuationCandidate.rawValue == 5`，不能替代 ADR 要求的键面 / 动作接线测试 |
| Debug / Release `build` | 未跑 |
| 真机 / Human Product Gate | 未跑；不得由本文件代签 |

## ADR 0029 §7 测试合同

| §7 条目 | 覆盖 | 缺口 | 是否阻塞 |
|---|---|---|---|
| 无 pending 单击 → host `，` + 候选表 | `testFirstPressInsertsPendingCommaAndPalette` | 无 | 否 |
| 1.0s 内同键走完四键并回绕 | `testSameKeyCyclesWithinOneSecondAndWraps` | 无 | 否 |
| 1.0s 外同键 → `，，`，pending 指向后一个 | `testSameKeyAfterTimeoutStartsNewComma` | 无 | 否 |
| 候选替换；候选后再点该键 → 接受旧标点并新开 `，` | `testCandidateReplacesPendingAndDisarmsCycle` | 无 | 否 |
| Delete 只拆仍持有的 pending | `testDeleteRemovesOnlyPendingSpan` | 无 | 否 |
| 外部 document 变化后不再按旧 span 删除 | `testExternalDocumentChangeDropsOwnershipWithoutDeleting` 证明失权且不回删 | 未再断言失权后 Delete 不会走旧 span 手术；`pending == nil` 已使该路径不可达 | 否（单独不挡） |
| 组字中先提交首选、Path 被清空，再进 pending | `testCompositionCommitsFirstCandidateThenPendingComma` | 无 RIME engine；走的是 FakeCandidateProvider + `commitInlinePreedit` | 否（Core 合同已覆盖；真机另论） |
| L1 / provisional ahead 拒绝该键，composition 仍在 | 实现上 `handlePressT9CommonPunctuation` 入口调用 `rejectIfResponsiveProvisionalAhead()` | **无用例**把 mirror 置为 ahead 并断言拒绝 / composition 仍在 | **是** |
| pending 期间 continuation 为空；接受后才按留下的文本刷新 0017 | 首按用例断言 pending 期间 `continuation.isEmpty` | **无用例**断言接受 / 删除后按 leftover 刷新 0017 | **是** |
| 空格 = 接受 + 插入空格，不选紧凑栏第一项 | `testSpaceAcceptsThenInsertsSpace`（host 为 `， `） | 未显式断言没选中紧凑栏第一项；结果文本已排除该路径 | 否 |
| 成对 opener 两侧载荷替换 / 删除，以及拆不干净只留 opener | `testPairedOpenerTracksBothSidesAndReplacesCleanly` 覆盖夹心替换 | **无**成对 Delete；**无**拆除失败 → opener-only | **是** |
| stale-ahead 时标点候选 fail-closed | `handleInsertCandidate` 对所有 kind 先 `rejectIfResponsiveProvisionalAhead()` | **无用例**在 ahead 时点 `.punctuationCandidate` 必须 `[]` 且不改 host | **是** |
| Extension 测试覆盖键面文案与动作接线，不在 UIKit 里复制轮换算术 | 生产接线存在：`，。？！` + `.pressT9CommonPunctuation` | **无**键面文案 / selector 接线测试；`KeyboardTests` 只锁 rawValue `5` | **是** |

## R2 P2 测试收口

| ID | 要求 | 本评审判断 |
|---|---|---|
| `A2-P2-01` | 无首选组字残余态按 L1 拒绝 | **已进测试**：`testCompositionWithoutCandidatesRejectsKey` |
| `A2-P2-02` | 无 span 的候选点选不得追加插入 | **未进测试**。`testUnknownPunctuationCandidateDoesNotAppend` 测的是非法 token `吗`，不是「无 pending / 不持有 span」。实现 `handlePunctuationCandidate` 在 `!canMutateHost` 时返回 `[]`，但合同要求的用例不存在 |
| `A2-P2-03` | 失权即清 pending | **已进测试**：`testExternalDocumentChangeDropsOwnershipWithoutDeleting`；可见性放弃路径也会 `pending = nil` |
| `A2-P2-04` | 成对手术中途撕裂不在 ADR 对账 | **不得当成已验证**。没有中途撕裂用例，Core / Fake 绿不能证明真实 `UITextDocumentProxy`。这是 Quality / Human Product Gate 残余，不是本轮 Pass 条件 |

## Blocking findings

| ID | Severity | Finding | Required disposition |
|---|---|---|---|
| `Q-P1-01` | P1 | ADR 0029 §7 必测项未齐：L1 / provisional ahead 拒绝、接受后按 leftover 刷新 0017、成对 Delete / 拆不干净只留 opener、stale-ahead 标点候选 fail-closed。 | `fix` — 用可注入时钟 / Fake client 补确定性用例后再复审。 |
| `Q-P1-02` | P1 | R2 `A2-P2-02` 未进入测试清单：无 pending 或 `ownsHostSpan == false` 时点 `.punctuationCandidate` 不得退化成追加 `insertText`。 | `fix` — 至少覆盖「失权后点选」和「无 pending 点选」两条，host 文本不变。 |
| `Q-P1-03` | P1 | ADR §7 要求 Extension 测试覆盖键面 `，。？！` 与动作接线。仓库没有这类测试；`CandidateKind.rawValue == 5` 不够。 | `fix` — 在会跑到 `KeyboardTests` / App+Keyboard 的 target 加键面与 selector 合同，且不把轮换算术搬进 UIKit 测试。 |

## Residuals allowed only after P1 fixes

| ID | Owner | Disposition | Pointer |
|---|---|---|---|
| `Q-P2-01` | Quality / Human Product Gate | `accept` — 明确 **未验证** | `A2-P2-04`：成对 `adjustTextPosition` + 连续 `deleteBackward` 中途撕裂。真实 host 与 Fake 不一致的风险仍在 ADR Risks。 |
| `Q-P2-02` | Input Intelligence | `tech_debt` | `ownedHostMutationGeneration` 只自增，从不消费。深度守卫只能挡住同步 `textDidChange`；延迟回调是否误 `accept` 只能由真机 / 延迟 Fake 证明，本轮不升级为已确认 P1。 |
| `Q-P2-03` | Executor | `fix`（不挡本轮 Fail 主因） | `CandidateKindTests.swift` 类外自由函数 `testPendingPunctuationEffectUsesRemainingUInt8Bit` **不会被 XCTest 发现**。独立复跑日志里没有该名字。bit 7 未在可执行测试中锁死。 |
| `Q-P2-04` | Executor | `tech_debt` | Assignment Exit 的回车 / 切英文接受有生产接线（`acceptingPendingPunctuationIfNeeded`），但 Core 未覆盖。 |
| `Q-P2-05` | Quality / Human Product Gate | `tech_debt` | 本评审未跑 RimeBridge、App+Keyboard xcodebuild、Debug/Release `build`、真机。不得用 KeyboardCore 绿代替。 |

## Implementation observations（不单独改变 Verdict）

- pending 写入走 `textClient?.insertText` 而不是 `KeyboardController.insertText`，目的是避开 0017 刷新边界。这与 ADR §5 一致，但字面上偏离 §4「用现有 `insertText`」。补测 0017 时序时必须锁住这条选择，禁止 silently 改回会刷新 continuation 的路径。
- `CandidateBarDataSource.candidateItems` 只取 compact 表；展开态由 `resetCandidateSnapshotFromController(expanded:)` 补。没有 Extension 测试锁这个分叉。
- `KEYBOARD_LAYOUT.md` / `CHANGELOG.md` 已写 chrome 与交互。文档更新不是 Quality Pass，更不是 Product Gate。
- 热路径未见新的无界日志或同步部署 I/O。`onCommittedText` 仍会打到既有打字统计；与旧 `insertDirectText` 同类，不升格为本项 P1。

## Re-review gate

先修全部 `Q-P1-*`，再独立复跑：

1. `xcrun swift-format lint --strict --configuration .swift-format`（变更 `.swift`）
2. `swift test --package-path Packages/KeyboardCore`（独立 `--build-path`）
3. 新增 Extension 接线测试所在 target 的 xcodebuild（不得只跑 KeyboardCore 就声称 §7 已闭合）

然后请求新的独立 Quality review。残差表 **不授权 Product Gate、不替代真机、不 Completed**。

`SUMMARY_DECISION=Fail`
