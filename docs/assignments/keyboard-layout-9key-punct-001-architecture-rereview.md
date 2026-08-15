# KEYBOARD-LAYOUT-9KEY-PUNCT-001 — ADR 0029 Architecture Re-review Conclusion

| Field | Value |
|---|---|
| **Date / timezone** | `2026-08-15 Asia/Shanghai` |
| **Reviewer role** | 🏛️ Architecture & Knowledge Steward — independent of the Executor |
| **Object under review** | [`ADR 0029`](../architecture/decisions/0029-t9-pending-punctuation-palette.md) **修订稿**（`Status = Proposed`） |
| **Predecessor** | [`R1`](keyboard-layout-9key-punct-001-architecture-review.md)（针对修订前文本；`Pass with conditions`；已有 supersession banner） |
| **Authority inputs** | [`PD-KEYBOARD-LAYOUT-9KEY-PUNCT-001`](../product-decisions/KEYBOARD-LAYOUT-9KEY-PUNCT-001-authorization.md) · [`Assignment`](keyboard-layout-9key-punct-001.md) · ADR 0002 · ADR 0007 · ADR 0017 · ADR 0018 · [`KEYBOARD_LAYOUT.md`](../KEYBOARD_LAYOUT.md) nine-key chrome · `CandidateItem.swift` · `KeyboardEffect.swift` · `KeyboardController+PartialCommit.swift` 成对符号段 · `CandidateBarDataSource.swift` |

本 reviewer 不是 Executor，未起草 ADR 0029 初稿或修订稿，不接受自己实现的结论。本文件只审查：**R1 的 P0 与 `fix` P1 是否已经写进 Decision**，以及修订有没有引入新的架构洞。Assignment Residuals 表是 Executor 的处置声明，不是本结论。

## Verdict

**Pass**

R1 要求写回 Decision 的两项 P0 和全部 `fix` P1 均已进入正文，而不只是 Risks / Context。Product Lead 已书面确认的空格与离页规则，本复审不再打成「需要 Product」。修订稿仍保持 `Proposed`，没有把字段名、动作名或 chrome 写成已 Accepted 合同。

方向与 R1 一致：九键待确认标点需要 KeyboardCore 独有的 ephemeral pending 状态和新的 `CandidateKind`；host 手术以跨度所有权 fail-closed；组字入口不得走 `insertDirectText`。修订没有打开新的 P0 / P1 架构洞。

本结论是契约与边界判断，**不授权实现**，不替代 Quality，不替代 Human Product Gate，**不把 ADR 0029 标为 `Accepted`**。Product Lead 可以据此考虑接受本 ADR；接受本身仍是 Product Lead 的动作。

## R1 closure

| ID | R1 disposition | 修订稿落点 | 复审判断 |
|---|---|---|---|
| `A-P0-01` | `fix` — 跨度所有权 / 失权不回删 / pair fail-closed 必须进 Decision | Decision §1 `ownsHostSpan`；§4 整节：只有持有 span 才允许替换/Delete；非本状态机的 document / 可见性变化 → 接受+清状态、不回删、不用过期两侧载荷；夹心拆不干净 → 只插 opener、只记 `beforeCursor`，禁止猜 closer；禁止读 `documentContextBeforeInput`；FakeTextInputClient 绿 ≠ host 证明 | **Closed**。协议在 Decision，不再只写在 Risks。 |
| `A-P0-02` | `fix` — 组字入口不得指向 `insertDirectText`；L1-ahead fail-closed 拒绝；Path 必须清空 | Decision §2.1 L1 / provisional ahead **拒绝该键**，保持 composition，不放弃 L1；§2.2 L2 / 可提交首选走 `selectCandidate(0)`（或同一语义），清空 Path 并打出 `t9PinyinPathsChanged`，禁止 `finishActiveCompositionAsDisplayText`，禁止喂 RIME punctuator；§1 不变量：组字 / 非空 preedit 期间 pending 必须为 `nil` | **Closed**。入口对象已改对。 |
| `A-P1-01` | `fix` — 点名对 ADR 0017 的时序修订 | Decision §5 首条标题即为「对 ADR 0017 的有范围时序修订」：pending 插入/轮换/替换不是 0017 刷新边界；接受或删除之后才按**最终留下**的文本更新；不改 0017 状态机、资源、隐私或 candidate kind | **Closed**。 |
| `A-P1-02` | R1：`需要 Product`；其后 Product 确认空格 = 接受后再插入空格 | PD §6；ADR Context / Decision §5 | **Closed — 不再需要 Product**。本复审不重开。 |
| `A-P1-03` | `fix` — 标点项非 space-finalizable，不得借用组字首选高亮 | Decision §3：不是 space-finalizable 首选；空格不得当「选定」；紧凑栏不得借用组字首选反色高亮；展开已选态只表示当前 pending；标点项必须进入 `rejectIfResponsiveProvisionalAhead()`；§6 `syncUI` 不得映射成 continuation | **Closed**。 |
| `A-P2-01` | `accept` — bit 7 可用，不得 silently 复用 bit 5 | Decision §6 | **Closed（保持 accept）**。 |
| `A-P2-02` | R1：`需要 Product`；其后 Product 确认离开字母页即接受，含 emoji | PD §6；ADR Context / Decision §5 | **Closed — 不再需要 Product**。本复审不重开。 |
| `A-P2-03` | `fix` — `text == beforeCursor + afterCursor` | Decision §1 不变量；§4 成对夹心再次重申；`cycleIndex` 仅当整段 `text` 恰好是 `，。？！` 之一时有效 | **Closed**。 |

## Blocking findings

无。

## Non-blocking observations

| ID | Severity | Finding | Required disposition |
|---|---|---|---|
| `A2-P2-01` | P2 | §2 的 1/2/3 看起来像穷尽表，但「有组字、非 L1、又没有可提交首选」没有单独一行。§1 不变量已经禁止这时进入 pending。 | `accept` — 不阻塞 Pass。实现必须把该残余态落成与 §2.1 相同的 fail-closed 拒绝，不得滑进 §2.3。若 Product Lead 接受前想收紧措辞，可补一行默认拒绝；不是新的架构方向问题。 |
| `A2-P2-02` | P2 | 点选标点候选「只在 `ownsHostSpan` 时替换」。失权已清 pending，成功路径之外的 else 未点名。 | `accept` — 与 §4「不持有 span 不得手术」一致。实现不得把无 pending / 不持有 span 的点选退化成追加 `insertText`。 |
| `A2-P2-03` | P2 | §4 写「`ownsHostSpan = false`，然后清 pending」，但未写成返回后不变量 `pending ≠ nil ⇒ ownsHostSpan`。 | `accept` — 语义已足够：失权后不存在「看得见标点候选但动不了 host」的幽灵态。 |
| `A2-P2-04` | P2 | 成对手术若在 `adjustTextPosition` / 连续 `deleteBackward` 中途失败，host 可能撕裂。Decision 禁止读 host 上下文补偿。 | `accept` — 这是 Risks 已记录的真机残余，归 Quality / Human Product Gate，不在 ADR 里发明第二套对账路径。 |

这些观察不是新的 P0 / P1，也不把修订稿打回 `Pass with conditions`。

## Confirmed boundaries

- **R1 的 Decision 缺口已补上。** 跨度所有权、组字入口、0017 时序、非 space-finalizable、载荷不变量都在 Decision 正文。Risks 只保留真机不一致和手感残余，不再充当 fail-closed 合同。
- **修订没有引入新的状态归属。** pending 仍与 continuation / typo / partialCommit / Path / `lastRimeOutput` 并列；轮换窗与 pending 寿命仍然分离；1.0 秒只约束同键轮换。
- **现有 host API 仍够用，且没有新开写入路径。** 成对表现行只有 `（`→`）`、`“`→`”` 等，没有 `‘`→`’`。修订把「表上没有就只插 token」和「拆不干净就 opener-only」写进 Decision，与代码事实一致。
- **空格与离页已是产品合同，不是架构私货。** 空格 = 接受后再插入空格；离开中文九键字母页（含 `123` / `#+=` / 切英文 / 切 emoji）即接受。本复审确认 ADR 与 PD 对齐，不再要求 Product。
- **`textDidChange` 失权只适用于非本状态机。** 自己的 `insertText` / `deleteBackward` / `adjustTextPosition` 回调不得立刻丢掉 `ownsHostSpan`。这是 §4「非本状态机」的应有读法，不是新合同。
- **字段名仍是 Proposed 形状。** `.pressT9CommonPunctuation`、`.punctuationCandidate`、`.pendingPunctuationChanged` 以及 bit 7 都带着「例如 / 允许使用」，且全文声明在复审通过并由 Product Lead 接受之前不具约束力。这不是已交付 API。
- **`KEYBOARD_LAYOUT.md` 的 `[,?!]` chrome 图仍是 Closed UI-001 事实。** 修订正确禁止在 Accepted / 实现授权前假装 chrome 已交付。
- **不与 ADR 0002 / 0007 / 0017 / 0018 冲突。** 0002：可见性放弃的是未完成 composition；pending 已是 unmarked host 文本，只接受+清除。0007：不为对 span 去读 host 上下文。0017：只推迟刷新时序。0018 / 0026：不改 scheme / readiness / 部署边界。

## ADR 不得被误读为已接受合同

- `Status = Proposed` 仍然成立。本 Pass 允许 Product Lead **考虑**接受，审查者本人不改 Status。
- 修订说明写了吸收 R1，不等于实现授权，也不等于 Quality 或 Human Product Gate 通过。
- 具体 Swift 符号名、session reset 的调用形状、bit 7 的落地，仍要等实现授权后由领域 Maintainer 在不突破本 Decision 的前提下确定。
- 本审查不把上述细节升级为 Accepted。

## What this review does not do

写完本文件后：

- 不授权生产 Swift
- 不替代 Quality reviewer
- 不替代 Human Product Gate
- 不修改 ADR 0029 Status
- 不覆盖 R1
- 不更新 `docs/ACTIVE_WORK.md`
- 不把 Assignment 推进到 `Ready` / `Active`

`SUMMARY_DECISION=Pass`
