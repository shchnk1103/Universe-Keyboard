> **Supersession (KOS 2.1 S-03):** 本文件评审的是 ADR 0029 **修订前**文本。`2026-08-15` Executor 已按本结论修订 ADR。本 Verdict 仍是那一版的独立结论，**不是**修订稿的复审，也不得被读成 ADR Accepted。

# KEYBOARD-LAYOUT-9KEY-PUNCT-001 — ADR 0029 Architecture Review Conclusion

| Field | Value |
|---|---|
| **Date / timezone** | `2026-08-15 Asia/Shanghai` |
| **Reviewer role** | 🏛️ Architecture & Knowledge Steward — independent of the Executor |
| **Object under review** | [`ADR 0029`](../architecture/decisions/0029-t9-pending-punctuation-palette.md)（`Status = Proposed`） |
| **Authority inputs** | [`PD-KEYBOARD-LAYOUT-9KEY-PUNCT-001`](../product-decisions/KEYBOARD-LAYOUT-9KEY-PUNCT-001-authorization.md) · [`Assignment`](keyboard-layout-9key-punct-001.md) · ADR 0002 · ADR 0017 · ADR 0018 · [`KEYBOARD_LAYOUT.md`](../KEYBOARD_LAYOUT.md) nine-key chrome · `CandidateItem.swift` · `KeyboardEffect.swift` · `KeyboardController+PartialCommit.swift` 成对符号段 · `CandidateBarDataSource.swift` |

本 reviewer 不是 Executor，未起草 ADR 0029，不接受自己实现的结论。本文件只审查 Proposed ADR 是否可在冻结产品合同下成为可接受的架构方向。

## Verdict

**Pass with conditions**

方向成立：九键待确认标点需要 KeyboardCore 独有的 ephemeral pending 状态和新的 `CandidateKind`，不能复用 ADR 0017 continuation、RIME 候选或 UI overlay。轮换窗与 pending 寿命分离在架构上可执行、可测。

但 ADR 在 Accepted 之前必须修订下面两条 P0。当前文本若被直接实现，会在「组字中进入 pending」和「host 手术 fail-closed」上违反已冻结产品合同，或把不可证明的 host 跨度当成可删除文本。

本结论是契约与边界判断，不授权实现，不替代 Quality，不替代 Human Product Gate，不把 ADR 0029 标为 `Accepted`。

## Blocking findings

| ID | Severity | Finding | Required disposition |
|---|---|---|---|
| `A-P0-01` | P0 | Pending 的替换 / Delete 是 host 手术，但 fail-closed 只写在 Risks，且没有「跨度所有权」协议。现有 `insertText` / `deleteBackward` / `adjustTextPosition` **兼容**，前提是 Core 仍拥有刚才写下的 span。`textDidChange`、用户点进输入框、或成对 `adjustTextPosition` 失败后，下一次 Delete/替换会按过期的 `beforeCursor`/`afterCursor` 删错字。ADR 0007 不允许为此去读 `documentContextBeforeInput`。 | `fix` — 把 fail-closed 写入 Decision，而不是 Risks：① 只有仍持有 span 所有权时才允许手术；② 非本动作引起的 document / 可见性变化 → 只接受+清状态，不回删；③ 成对夹心若无法在不猜测的前提下拆除 → 只插入 opener、只记 `beforeCursor`，禁止猜 closer。FakeTextInputClient 绿不构成 host 证明。 |
| `A-P0-02` | P0 | 「拼音进行中先走现有边界」指错了对象。产品要求**提交首选**且**不丢弃当前拼音**。字母页现行 `insertDirectText` 走 `finishActiveCompositionAsDisplayText`（上屏的是 display/preedit，不是首选），并且在 responsive L1-ahead 时会 `abandonResponsiveProvisionalL1WithoutHostCommit()`，直接丢掉拼音。符号页 `commitFirstCandidateForSymbolInput` 虽是「选 0」，但不清 `t9PinyinPathState`。ADR 若被理解成复用这两条现成路径，会留下 Path Bar，或在 stale-ahead 丢拼音。 | `fix` — Decision 必须写死进入 pending 的组字边界：L2/可提交首选 → 先 `selectCandidate(0)`（或与符号页等价的首选提交）再进 pending；L1 / provisional ahead → **fail-closed 拒绝该键**，保持 composition，不得放弃 L1 再插 `，`；成功提交后 Path 必须空，并打出 `t9PinyinPathsChanged`；pending 在 composition / 非空 preedit 期间必须保持 `nil`。 |

## Conditional findings

| ID | Severity | Finding | Required disposition |
|---|---|---|---|
| `A-P1-01` | P1 | ADR 0017 规定每次最终 host commit 都在同一 finalization 边界更新 continuation。Pending 的插入/轮换/替换也是 unmarked host 文本。0029 要求 pending 存活期间不刷新、不展示 continuation，这是对 0017 **时序**的有范围修订，正文没有点名。 | `fix` — Decision 写明：pending 相关 host 变异不是 0017 的 continuation 刷新边界；下一次 0017 更新只发生在接受或删除 pending 之后，且只根据**最终留下**的文本。不改 0017 的状态机、资源、隐私或 candidate kind。 |
| `A-P1-02` | P1 | 空格「接受 pending、不选紧凑栏第一项」**已经冻结**（PD §6、Assignment Exit）。这不是未冻结缺口。缺口是：PD 只说空格**结束** pending，ADR Decision 写成「先接受再执行该动作」（因而会插入空格）。这是合理架构解释，但还不是产品合同。 | `需要 Product` — 书面确认「接受后插入空格」。在此之前，不得把该句当成已接受产品合同。真机若证明系统九键空格会点选第一枚标点，走 PD Revalidation，禁止实现里改。 |
| `A-P1-03` | P1 | 展示优先级「composition > pending > continuation」不会破坏 Path Bar，只要 `A-P0-02` 成立。残留风险在 UI 语义：紧凑栏第一项今天会走 preferred-candidate 高亮；T9 空格在组字中是「选定」。pending 期间若复用这套语言，用户会以为空格上屏 `。`。 | `fix` — Decision 规定：标点项不是 space-finalizable 首选；紧凑栏不得借用组字首选高亮来暗示空格可选中；展开面板的已选态只表示当前 pending。标点候选必须进入 `rejectIfResponsiveProvisionalAhead()` 的 fail-closed 名单（ADR 已写，须保持）。`syncUI` 必须把新 effect 当成候选栏刷新，且不得映射成 continuation 语义。 |
| `A-P2-01` | P2 | `KeyboardEffect.rawValue` 现为 `UInt8`，bit 0…6 已占用。使用 bit 7 可接受，也优于盗用 `continuationChanged`。 | `accept` — 记下这是最后一个 `UInt8` 位；下一个新 effect 必须另开 ADR 扩宽底层类型。本项不得 silently 复用 bit 5。 |
| `A-P2-02` | P2 | PD 的结束集合是字母 / 空格 / 回车 / `123` / `#+=` / 切英文 / Delete。ADR 额外写了切 emoji。与切页同类，但是产品范围扩张。 | `需要 Product` — 要么补进 PD，要么从 Decision 拿掉，直到产品点名。 |
| `A-P2-03` | P2 | `text` 与 `beforeCursor`/`afterCursor` 没有不变量。成对夹心时，若 `text` 只记 opener 而 host 上还有 closer，轮换判定和删除范围会分叉。 | `fix` — Decision 增加：`text == beforeCursor + afterCursor`；`cycleIndex` 仅当整段 `text` 恰好是 `，。？！` 之一时有效。 |

## Confirmed boundaries

- **需要新状态 + 新 `CandidateKind`。** Continuation 是追加词联想；RIME 候选依赖 composition；`placeholder` 不可点。产品已禁止把 pending 并进这三者。独立 Core 状态是第一性选择：同一份 pending 必须同时服务轮换窗、Delete、切页、组字提交、成对手术和 stale-ahead 守卫。
- **轮换窗 vs pending 寿命可执行、可测。** `lastSameKeyTap` + `cycleArmed` + 注入的 `KeyboardController.currentDate` + `≤ 1.0s` 足够表达 PD。1.0 秒只约束同键轮换，不拆除 pending。候选点选后 `cycleArmed = false` 且不把该次点击当作轮换时钟，能避免把 `……` 吃进四键环。测试必须注入时钟，禁止 UI 另记 `Date()`。
- **成对符号可复用现有 opener→closer 表和 Character 计数的 `insertText` / `deleteBackward` / `adjustTextPosition`。** V1 表拆成 token（`……` 为一个 token；`“”‘’（）` 拆开）与「载荷不是单字符」一致。现行表没有 `‘`→`’`，关闭成对补全时只插点选 token。这不是新的 host 写入路径。
- **展示优先级不会压过 Path Bar / composition。** 活跃 RIME composition / 非空 preedit 维持现状，且 pending 必须为 `nil`。Path Bar 只属于 composition；pending 不是 marked text，不进 RIME session。条件是 `A-P0-02` 先成立。
- **不与 ADR 0002 / 0017 / 0018 冲突，只要修订被吸收。** 0002：可见性放弃的是未完成 composition，不是已上屏文本；pending 只接受+清除，不把已上屏的 `，` 偷走，这比「当成 composition 回删」更贴 0002。0017：状态、资源、追加点选保持独立；0029 只推迟刷新时序（`A-P1-01`）。0018 / 0026：不改 scheme、readiness、部署边界。
- **`KEYBOARD_LAYOUT.md` 的 `[,?!]` chrome 图仍是 Closed UI-001 事实。** ADR 正确禁止在 Accepted / 实现授权前假装 chrome 已交付。
- **空格不选紧凑栏第一项不是架构缺口。** 它是已冻结产品语义。ADR 把它写成风险并要求真机冲突回 Product，方向对；插入空格本身见 `A-P1-02`。

## ADR 不得被误读为已接受合同

- `Status = Proposed` 成立，且已声明在独立 Architecture Review + Product Lead 接受之前不具约束力。
- 字段名、`.pressT9CommonPunctuation`、`.punctuationCandidate`、`.pendingPunctuationChanged` 是 Proposed 决策的合法形状，不是实现授权。
- Decision 里「空格先接受再插入空格」「切 emoji 也接受」目前仍是架构提案，不是 PD 原文。
- 本审查不把上述细节升级为 Accepted。

## Re-review gate

只有 `A-P0-01`、`A-P0-02` 以及列入 `fix` 的 P1 被写回 ADR 0029 正文后，才可以再次请求独立 Architecture Review，或由 Product Lead 考虑 `Accepted`。`A-P2-01` 可 `accept` 并保留。`需要 Product` 项不阻塞架构方向，但阻塞把对应句子写成已冻结产品合同。

本文件写完后：

- 不授权生产 Swift
- 不替代 Quality reviewer
- 不替代 Human Product Gate
- 不修改 ADR 0029 Status
- 不更新 `docs/ACTIVE_WORK.md`

`SUMMARY_DECISION=Pass with conditions`
