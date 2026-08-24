# RELEASE-2026-0801-08 — ADR 0030 Architecture Review Conclusion

| Field | Value |
|---|---|
| **Date / timezone** | `2026-08-23 Asia/Shanghai` |
| **Reviewer role** | 🏛️ Architecture & Knowledge Steward — independent of the Executor |
| **Object under review** | [`ADR 0030`](../architecture/decisions/0030-pending-kaomoji-palette.md)（Product 已标 `Accepted`；本审查是 **merge 门**，不是再授权实现）+ 对照实现（`PendingKaomoji.swift`、`KeyboardController+PendingKaomoji.swift`、`KeyboardController+PendingPunctuation.swift` 抽出的 `removeOwnedHostSpan`、`KeyboardEffect` UInt16 bit 8、候选栏 / 九键与符号页接线） |
| **Authority inputs** | [`RELEASE-2026-0801-08`](release-2026-08-01-08-kaomoji-content.md) · [`PD-RELEASE-2026-0801-08-KAOMOJI-CATALOG`](../product-decisions/RELEASE-2026-0801-08-kaomoji-catalog.md) · ADR 0030 · ADR 0029 Decision + host ownership · ADR 0002 · ADR 0007 · ADR 0017 · [`KEYBOARD_LAYOUT.md`](../KEYBOARD_LAYOUT.md) 九键 chrome / 颜表情段 · 0029 R1/R2 模板 |

## 独立性声明

本 reviewer **不是** Executor，未起草 ADR 0030，未写生产 Swift。不接受自己未审查的实现结论。Executor 记录的 KeyboardCore `1054/0`、Debug BUILD SUCCEEDED，以及 Human Product Owner 口述「26 键和九宫格没有什么问题」，在本文件中只作为外部背景：**不是 Architecture 证明，也不是 Product Gate**。本结论只判断：Accepted ADR 的 Decision 是否在冻结产品合同下可执行，以及对照实现有没有落实 Decision、有没有打开新的架构洞。

## Verdict

**Pass**

平行 `pendingKaomoji` 作为 V1 边界成立：没有把 ADR 0029 标点状态机改成泛化调色板，同键轮换 / 跨度所有权 / 组字 fail-closed 仍走 0029 路径。颜表情路径以同级 `ownsHostSpan` fail-closed 复用抽出的 `removeOwnedHostSpan`，组字入口复制「有首选则一次写入首选+默认 `^_^`；L1-ahead 拒绝」，不走 `finishActiveCompositionAsDisplayText`、不喂 RIME punctuator。互斥是接受对方（清状态、不回删已上屏文本）再执行本动作；同键 `^_^` 是 accept+新开默认，不是 compact 轮换。候选栏 preferred 按 `title == pending.text`，空格走接受后再 `insertSpace`，不会把第一项颜表情当成组字首选。

本结论是契约与边界判断。**不替代 Quality**，**不替代 Human Product Gate**，**不授权 merge**，**不把 08 Assignment 标 Closed**，**不把 ADR 0030 标 Closed**，**不擅自改 ADR Status**。

## Blocking findings

无。

## Conditional findings

| ID | Severity | Finding | Required disposition |
|---|---|---|---|
| `A30-P2-01` | P2 | `KeyboardEffect.rawValue` 已按 ADR 0029 `A-P2-01` 扩到 `UInt16`，bit 8 = `.pendingKaomojiChanged`；bit 0–7 原值未改，`refreshesCandidatePresentation` 把它当候选栏刷新而不是 continuation。ADR 0030 Decision 正文没有点名这次扩宽。 | `accept` — 实现落点正确。不阻塞 Pass。若后续修订 ADR，补一句 UInt16 / bit 8 即可；禁止 silently 复用 bit 5 或 bit 7。 |
| `A30-P2-02` | P2 | `acceptingPendingPunctuationIfNeeded` 现在先接受颜表情再接受标点再执行 body。语义正确，名称滞后。 | `accept` — 不要求为本审查改名。后续清理不得把「只清标点」的读法写回调用点。 |
| `A30-P2-03` | P2 | 组字入口仍走 `commitInlinePreedit(as: 首选 + "^_^")`。该路径会经 `didCommitText` 触及 ADR 0017 刷新；pending 存活期间候选栏仍只展示颜表情。这与已交付的 0029 组字入口同构，不是新洞。 | `accept` — 展示合同成立。真机 unmark 光标位置仍归 Quality / Human Product Gate（0029 已记录的 host 残余）。 |
| `A30-P2-04` | P2 | 抽出 `removeOwnedHostSpan` 供标点与颜表情共用。`T9PendingPunctuationTests` 仍覆盖轮换 / 替换 / 成对夹心 / 空格 / 失权不回删。测试绿 ≠ 真机 host 证明；成对手术中途撕裂仍是 0029 `A2-P2-04`。 | `accept` — 抽出没有把标点改成第二条写入路径，也没有读 `documentContextBeforeInput`。残余仍归 Quality / 真机。 |
| `A30-P2-05` | P2 | PD 抄录表把两枚看起来相同的 `＾_＾`、两枚 `(＾＾)` 当可能的近形重复保留。实现按字面保留。`isPreferredCandidate` 按 title 相等，重复 title 会一起高亮。 | `accept` — Product 已声明 Human 可校正。Architecture 只要求 ASCII `^_^` 与全角 `＾_＾` 分 token（实现如此）。不得为去重改排序算法或引入磁盘/网络目录。 |
| `A30-P2-06` | P2 | PD 写 pending 使用「现有 preferred + VoiceOver `.selected` / 「已选中」」。实现：颜表情按 `title == pending.text` 走反色高亮；`CandidateCell` **没有** `.selected` trait，也没有「已选中」文案（组字首选同样没有；Path Bar 才有）。 | `accept` — 状态机身份正确，且空格不读 index 0。无障碍完整性交 Quality / 08 Exit，禁止为补 `.selected` 把空格接到第一项颜表情。 |
| `A30-P2-07` | P2 | `KeyboardState` 注释写互斥，init 不阻止两份 pending 同时非空。生产入口（开颜表情先接受标点，反之亦然）不会写入双活。 | `accept` — 不阻塞。实现不得把无 pending / 失权后的 `.kaomojiCandidate` 点选退化成追加 `insertText`（已有测试）。 |
| `A30-P2-08` | P2 | `T9KaomojiChromeContractTests` 断言九键与符号页共用 `.pressKaomoji`，未断言 26 键字母页没有 `^_^` 键。源码审查：`insertKaomoji` 只出现在九键右列和中文符号页。 | `accept` — 产品禁止「本次加 26 键字母页键」已落实。合同测试缺口交 Quality，不构成架构位移。 |

## Confirmed boundaries

1. **平行 `pendingKaomoji` vs 泛化 0029：V1 边界成立。** 独立 struct、独立 `CandidateKind.kaomojiCandidate`、独立 effect bit、**没有** `cycleIndex` / `lastSameKeyTap` / `cycleArmed`。标点状态机仍按 0029 四键轮换；颜表情同键是接受再新开。互斥入口插在 `handlePressT9CommonPunctuation` 与 `handlePressKaomoji` 顶部，没有把 0029 改成「cycle optional」泛型。测试 `testPunctuationCycleStillWorksAfterKaomojiAccept` 证明接受颜表情后标点仍能 `， → 。`。

2. **Host 跨度所有权与 ADR 0007：与 0029 同级 fail-closed。** `canMutateHost` = `ownsHostSpan && text == beforeCursor + afterCursor && !text.isEmpty`。替换 / Delete 只在可手术时调用 `removeOwnedHostSpan`；失败则清 pending、不猜 closer。`noteExternalDocumentChange` 在非 `isPerformingOwnedHostMutation` 时接受颜表情与标点、不回删。手术路径用已有 `insertText` / `deleteBackward` / `adjustTextPosition`，不读 `documentContextBeforeInput` 对 span。FakeTextInputClient 绿仍不是真机 host 证明。

3. **组字入口复制 0029。** `rejectIfResponsiveProvisionalAhead`；无首选 / L1-ahead → 拒绝该键、保持 composition。有首选 → `selectCandidate(0)` + **一次** `commitInlinePreedit(首选 + "^_^")`，清空 Path 并打出 `t9PinyinPathsChanged`。PendingKaomoji / PendingPunctuation 源码均不含 `finishActiveCompositionAsDisplayText`，也不把颜表情喂给 RIME punctuator。

4. **互斥：开一方接受另一方，不清已上屏文本。** `，` 后点 `^_^` → host `，^_^`，标点 pending nil；再点标点键 → `，^_^，`，颜表情 pending nil。Delete 仍只拆当前仍持有的那一段。

5. **同键无轮换。** 再点 `^_^` → host `^_^^_^`，pending 仍是默认 ASCII，不在 compact 上 cycle。点已 pending 的候选项只打 `.pendingKaomojiChanged`，不追加第二份。

6. **候选栏优先级与 preferred。** `CandidateBarDataSource`：pending 标点 **或** pending 颜表情（检查顺序标点先于颜表情，依赖互斥）→ 否则 RIME / continuation。ADR 0030 写 composition 优先，实现与 0029 一样靠「组字期间 pending 必须为 nil」。`isPreferredCandidate`：**仅** `.kaomojiCandidate` 用 `title == pending.text`；标点仍不进组字首选高亮（保持 0029 A-P1-03）。空格 / 回车走 `acceptingPendingPunctuationIfNeeded` → `handleInsertSpace` / `handleInsertReturn`，不 `insertCandidate` 第一项。Core 测试：`^_^` + 空格 → `"^_^ "`。

7. **`KeyboardEffect` UInt16 bit 8 必要且未破坏 bit 0–7。** 0029 已用尽 UInt8。`syncUI` 经 `refreshesCandidatePresentation` 刷新候选栏。组字已提交后 `shouldPublishAtomicT9Presentation` 为 false，不会把 kaomoji effect 误当成 T9 atomic snapshot。

8. **抽出 `removeOwnedHostSpan` 可接受。** 0029 测试清单仍在；抽出是同一套 Character 计数拆除。新撕裂风险没有超过 0029 已 `accept` 的成对中途失败残余。

9. **目录是第一方字面量。** `PendingKaomojiState.compactCatalog` / `catalogTokens` 在 Core 内。无网络、无磁盘用户目录、无排序/学习。ASCII `^_^` 永远第一；全角 `＾_＾` / `＾＿＾` 是不同 token。缺席的 pending 追加到表尾，不把 `^_^` 挤出首位。

10. **26 键字母页没有加 `^_^` 键。** 产品授权的是中文九键字母页右列 + 中文符号页（两键同一 `.pressKaomoji`）。`makeLetterThirdRow` 仍是 `z…m`。中文符号页 `^_^` 是既有 chrome 从占位改接到产品路径，不是 26 键字母页新键。

11. **可见性 abandon / 外部 document change：已上屏文本留下，只丢替换身份。** `abandonCompositionForVisibilityChange` 对 composition 仍 `deleteInlinePreedit`（ADR 0002）；对 pending 只 `nil` 状态。`noteExternalDocumentChange` 同样不回删。测试：host 仍为 `^_^`，pending nil；失权后再点颜表情候选不得追加。

12. **ADR 0030 在独立 review 之前被标 Accepted：契约时序与 0029 倒置，但不构成 Decision 内容错误。** 0029 是 Proposed → 独立 review → Product 接受。0030 Status 写明：独立 review 是 merge 门，**不是**开始 KeyboardCore 的前置条件。Assignment 08 Non-claims 与此一致。本审查 **不改 ADR Status**，也不把 Accepted 读成「已过 merge / Product Gate / 08 Exit」。见下节 governance observation。

### Governance observation（不改 Verdict，不改 ADR Status）

Product Lead 在独立 Architecture review 之前接受 ADR 并授权实现，是 **时序倒置**，不是把本文件变成第二次授权。处置：merge 仍必须拿本 Pass；Quality、无障碍、真机 Product Gate、05 文案交接仍未发生。审查者不得把 Status 改回 Proposed，也不得标 Closed。

## ADR / 实现不得被误读为已关闭 08 或已过 Product Gate

- ADR 0030 `Accepted` 只约束方向与已授权的实现形状；**不是** 08 Exit Criteria。
- 本 Pass **不是** merge 许可，不是 Quality 结论，不是 Human Product Gate。
- Executor 证据 [`docs/evidence/release-2026-08-01-08-pending-kaomoji-core-2026-08-23.md`](../evidence/release-2026-08-01-08-pending-kaomoji-core-2026-08-23.md) 可引用为「Core 测试被声称跑过」，不可当作本审查的证明。
- Human 口述真机「没有什么问题」是 Human-reported smoke，本审查 **不得** 因此给出 Pass；Pass 来自 Decision ↔ 实现对照。
- 目录近形重复、无障碍 `.selected`、真机 host 手术仍是 08 未关残留。
- `KEYBOARD_LAYOUT.md` 颜表情段描述的是 ADR 0030 合同，不是「已过 Product Gate 的完成功能」；App Store 文案在 08 Exit 前不得把 `^_^` 写成已交付卖点（PD Explicit non-authorization）。

## Re-review gate

无 blocking。不需要为 Architecture 再开一刀才能维持本 Pass。下列变化会 **触发重新审查**，而不是本文件的修补清单：

- 把颜表情嵌进 0029 泛型调色板，或改动标点轮换 / `cycleArmed` 语义；
- 为对 span 读取 host 上下文（违反 ADR 0007）；
- 组字入口改回 `finishActiveCompositionAsDisplayText` / L1-ahead 放弃拼音 / 喂 RIME punctuator；
- 空格改为点选紧凑栏第一项，或颜表情 preferred 改回 `index == 0` 且不核对 pending.text；
- 给 26 键字母页加 `^_^` 键；
- 引入网络 / 磁盘用户目录 / 排序。

本文件写完后：

- 不改生产 Swift
- 不替代 Quality reviewer
- 不替代 Human Product Gate
- 不修改 ADR 0030 Status
- 不把 ADR 标 Closed
- 不关闭 Assignment 08
- 不更新 `docs/ACTIVE_WORK.md`
- 不授权 merge

`SUMMARY_DECISION=Pass`

### Non-claims

- 不替代 Quality 全套 xcodebuild / KeyboardTests / 无障碍
- 不替代 Human Product Gate
- 不授权 merge
- 不关闭 Assignment 08
