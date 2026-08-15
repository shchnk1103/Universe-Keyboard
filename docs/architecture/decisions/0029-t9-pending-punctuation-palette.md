# ADR 0029: 九键待确认标点与本地候选源

## Status

Accepted; implementation pending

`2026-08-15 Asia/Shanghai`：独立 Architecture R2 [`Pass`](../../assignments/keyboard-layout-9key-punct-001-architecture-rereview.md)。Product Lead 当场接受本 ADR。方向现在有约束力，**仍不授权生产 Swift**。实现必须另一次 Product 授权，并遵守本 Decision；R2 的 4 条 P2 保持 `accept`，不挡接受。

产品意图以 [`PD-KEYBOARD-LAYOUT-9KEY-PUNCT-001`](../../product-decisions/KEYBOARD-LAYOUT-9KEY-PUNCT-001-authorization.md) 为准；任务生命周期以 [`KEYBOARD-LAYOUT-9KEY-PUNCT-001`](../../assignments/keyboard-layout-9key-punct-001.md) 为准。

`2026-08-15 Asia/Shanghai` 修订：吸收独立 Architecture Review（`Pass with conditions`）的 `A-P0-01`、`A-P0-02` 以及 `fix` 处置的 P1；Product Lead 当场确认空格与离页规则。此前一版不得再当评审对象。

## Context

中文九键字母页已有一颗常用标点键，但当前只是 chrome：键面仍是 ASCII `",?!"`，点击走 `insertDirectText("，")`。系统九键的合同不同：先上屏一个**可被替换**的 `，`，再给出常用标点选择面；短时间再点同一键则在 `，。？！` 之间轮换。

现有候选管线不能表达这件事：

- RIME 候选依赖 composition / `lastRimeOutput`。标点键的目标是结束或避开拼音，而不是开一个 RIME session。
- `continuationCandidate`（ADR 0017）是上屏后的词联想，来自 bundled 资源，点击后是**追加**提交。把它塞进标点表，会把「吗/的/了」和「。？！」混成一种状态，也无法表达替换。
- Extension 本地 `lastTap` 能做出轮换错觉，但 Delete、切页、组字中先提交首选、成对符号、responsive stale-ahead 都读不到同一份状态。
- 字母页现行 `insertDirectText` **不是**「提交首选」：它走 `finishActiveCompositionAsDisplayText`（上屏 display/preedit），并且在 responsive L1-ahead 时会放弃组字且不上屏。符号页 `commitFirstCandidateForSymbolInput` 虽选 0，但不清 `t9PinyinPathState`。本功能若复用这两条现成路径，会违反已冻结产品合同。

产品已冻结（PD，含本次确认）：

- 展示面复用现有候选栏，不做系统整页标点盘。
- 单击上屏待确认 `，`；候选点选 = 替换；1.0 秒同键轮换 `，。？！`。
- 候选点选后，再点该键 = 接受并新开逗号。
- 轮换窗和 pending 寿命分离。
- 空格：接受 pending，再插入空格。
- 离开中文九键字母页（含 `123` / `#+=` / 切英文 / 切 emoji）即接受 pending。
- 组字中有可提交首选则先提交首选；L1 / provisional ahead 拒绝该键，不丢拼音。
- V1 表：`。？！……～#：、；“”‘’（）@`。

本 ADR 决定状态放在哪、候选如何成为一等公民、host 手术的所有权，以及和 continuation / RIME / 成对符号 / 可见性放弃如何隔离。

## Decision

### 1. KeyboardCore 独有一份 ephemeral pending 状态

在 `KeyboardState` 增加独立的待确认标点状态（名称实现时确定，语义如下）。它与 `continuation`、`typoCorrection`、`partialCommit`、`t9PinyinPathState`、`lastRimeOutput` 并列，**不嵌入其中任何一个**。

Pending 至少包含：

| 字段 | 含义 |
|---|---|
| `text` | 当前待确认、已出现在 host 上的整段文本 |
| `beforeCursor` / `afterCursor` | 为替换/删除准备的光标两侧载荷。普通标点只有 `beforeCursor`；成对补全后光标夹在中间时两侧都有 |
| `ownsHostSpan` | Core 是否仍拥有刚才写下的这段 host 跨度。只有它为真时才允许替换/Delete 手术 |
| `cycleIndex` | `，。？！` 中的当前位置 |
| `lastSameKeyTap` | 最近一次**同键**点击的时钟读数 |
| `cycleArmed` | 下一次同键点击是否允许轮换。候选点选后必须为 `false` |

不变量：

- `text == beforeCursor + afterCursor`
- `cycleIndex` **仅当**整段 `text` 恰好是 `，` / `。` / `？` / `！` 之一时有效；否则同键点击不得走四键轮换
- pending 非空期间，RIME composition / 非空 preedit 必须不存在；反过来，组字期间 pending 必须为 `nil`

不持久化。进程死亡、可见性放弃、切到英文、离开中文九键字母页后，只清状态，**不回删**已经留在 host 上的文本（视为接受）。

时钟复用 `KeyboardController.currentDate`，窗口长度 **1.0 秒**，由 Product 冻结。测试必须注入时钟，禁止在 UI 层另记一份 `Date()`。

### 2. 新的 Core 动作，而不是 UI 直接 `insertDirectText`

九键标点键只发送一个语义动作（例如 `.pressT9CommonPunctuation`）。Core 按当前 pending / 轮换窗决定：

1. 无 pending，且处于 L1 / responsive provisional ahead：  
   **fail-closed 拒绝该键**。保持当前 composition，不上屏 `，`，不放弃 L1。这不是产品上的「拼音中禁用」，只挡住无法安全提交首选的那一帧。
2. 无 pending，且存在可提交首选（L2 / 普通组字）：  
   先走与符号页等价的首选提交（`selectCandidate(0)` 或同一语义），复位 session，**清空 Path** 并打出 `t9PinyinPathsChanged`，再插入待确认 `，`。禁止复用 `finishActiveCompositionAsDisplayText`，禁止把 `，` 喂给 RIME punctuator。
3. 无 pending，且无组字：  
   插入待确认 `，`，`ownsHostSpan = true`，`cycleArmed = true`，`cycleIndex = 0`。
4. 有 pending 且 `ownsHostSpan` 且 `cycleArmed` 且距 `lastSameKeyTap` ≤ 1.0s 且 `text` 恰好是四键之一：  
   按 `， → 。 → ？ → ！ → ，` 替换，刷新 `lastSameKeyTap`。
5. 其他同键点击（超时、`cycleArmed == false`、当前 `text` 不是四键之一、或不持有 span）：  
   接受当前 pending（只清状态，不动 host），若仍可写 host 则再新开一个待确认 `，`。不持有 span 时不得尝试拆除旧文本。

候选点选走现有 `insertCandidate`，但必须带新的 `CandidateKind`（见 §3）。它只在 `ownsHostSpan` 时替换 pending，并把 `cycleArmed` 置 `false`；不把这次点选当作 `lastSameKeyTap`。

26 键不必露出此键。Core 不依赖 `KeyboardLayoutStyle` 才能执行该动作，避免 chrome 倒灌进状态机。产品范围仍只授权九键字母页入口。

### 3. 新的 `CandidateKind`，独立于 continuation

新增例如 `.punctuationCandidate`。它：

- 不进入 RIME `selectCandidate`；
- 不走 continuation 的「追加 + 再查表」；
- **不是** space-finalizable 首选。空格不得把它当成组字中的「选定」；
- 必须出现在 `rejectIfResponsiveProvisionalAhead()` 的 fail-closed 名单里，与 continuation 一样；
- 没有 RIME `CandidateSelectionReference`。展开面板 / 点击守卫不得要求 Path/RIME provenance。点选身份就是「当前 pending 仍在，且 title 属于 V1 表（或当前 pending 本身，若展开面板显示已选项）」。

`CandidateBarDataSource` 的展示优先级变为：

1. 活跃 RIME composition / 非空 preedit → 维持现状。此时 pending **必须为 nil**。
2. pending 非空 → 只展示本地标点项；**压制** continuation、typo merge、FakeCandidateProvider。
3. 否则才是 continuation，再否则才是既有 fallback。

紧凑栏从 V1 表排除当前 pending 的展示 title，且**不得**借用组字首选的反色高亮来暗示空格可选中。展开面板可以保留整表，已选态只表示「这是当前 pending」，不是 space target。

### 4. Host 手术与跨度所有权

进入 pending：用现有 `insertText` 把载荷送到 host，并置 `ownsHostSpan = true`。  
替换 / Delete-while-pending：**仅当** `ownsHostSpan == true` 时，先按 `afterCursor` / `beforeCursor` 收回刚才那一段，再插入新载荷或停止。

必须使用 Core 已有的 `insertText` / `deleteBackward` / `adjustTextPosition`，不引入第二条 host 写入路径，也不读取 `documentContextBeforeInput`（ADR 0007）。

失去跨度所有权（`ownsHostSpan = false`，然后清 pending）的条件：

- 任何非本状态机引起的 document 变化（`textDidChange`、用户点进输入框、host 自己挪光标）；
- 可见性放弃、进程死亡；
- 成对夹心手术无法在不猜测的前提下完成。

上述情况一律 **接受 + 清状态，不回删**。不得拿过期的 `beforeCursor`/`afterCursor` 继续动刀。FakeTextInputClient 变绿不构成真实 host 证明。

成对符号复用 `paired_symbol_completion_enabled` 与现有 opener → closer 表（`（`→`）`、`“`→`”` 等）：

- V1 表按 token 拆开：`。` `？` `！` `……` `～` `#` `：` `、` `；` `“` `”` `‘` `’` `（` `）` `@`。`……` 是一个 token。
- 点选 opener 且成对补全开启时，host 上实际插入 opener+closer，光标夹在中间；pending 记录两侧载荷，且必须满足 `text == beforeCursor + afterCursor`。
- 成对补全关闭，或现行表没有该 opener（例如 `‘`）：只插入点选 token，pending 只有 `beforeCursor`。
- 若夹心拆除需要猜测 closer 是否仍在光标后：fail-closed 为只插入 opener、只记 `beforeCursor`，禁止猜 closer。
- 替换一对仍持有的夹心符号时，必须先移过 closer、删 closer、再删 opener，然后插入新载荷。

Pending 载荷按 Swift `Character` 计数与现有 pair/offset API 对齐；禁止在 UI 里假设「待确认永远是 1 个标量」。

### 5. 与 continuation、组字、离页、可见性的边界

- **对 ADR 0017 的有范围时序修订：** pending 相关的插入 / 轮换 / 替换 **不是** 0017 的 continuation 刷新边界。pending 存活期间不刷新、不展示 continuation。下一次 0017 更新只发生在接受或删除 pending 之后，且只根据**最终留下**的文本。不改 0017 的状态机、资源、隐私或 candidate kind。
- 字母键 / T9 数字：先接受 pending（清状态，保留 host 文本），再执行该动作。
- 空格：先接受 pending，再插入空格。结果是「当前标点 + 空格」，不是选中紧凑栏第一项。
- 回车：先接受 pending，再执行回车。
- Delete：若 pending 非空且仍持有 span，只拆除 pending 载荷并清状态，不得再连锁删除前一个字符。若不持有 span，按普通 Delete 处理（pending 应已在失权时被清掉）。
- 离开中文九键字母页即接受：`123`、`#+=`、切英文、切 emoji 与任何把 `currentPage` 带离 `.letters` 或把 `inputMode` 带离中文的动作，都只清状态、保留 host 文本。
- 可见性放弃（ADR 0002）：composition 仍放弃；pending 只接受+清除。键盘收起不得把已上屏的 `，` 偷走。
- 不改 RIME 方案、`punctuator`、Extension 部署边界。

### 6. Effect 与 UI 刷新

`KeyboardEffect` 增加独立位（例如 `.pendingPunctuationChanged`）。`syncUI` 必须把它当成候选栏刷新，且不得映射成 continuation 语义。

`KeyboardEffect.rawValue` 现为 `UInt8`，bit 0…6 已占用。本决策允许使用 bit 7；这是最后一个 `UInt8` 位（Architecture Review `A-P2-01` accept）。下一个新 effect 必须另开 ADR 扩宽底层类型。本项不得 silently 复用 `continuationChanged`。

### 7. 测试合同

KeyboardCore 用注入时钟覆盖至少：

- 无 pending 单击 → host `，` + 候选表；
- 1.0s 内同键走完四键并回绕；
- 1.0s 外同键 → `，，`，pending 指向后一个；
- 候选替换；候选后再点该键 → 接受旧标点并新开 `，`；
- Delete 只拆仍持有的 pending；
- 外部 document 变化后不再按旧 span 删除；
- 组字中先提交首选、Path 被清空，再进 pending；
- L1 / provisional ahead 拒绝该键，composition 仍在；
- pending 期间 continuation 为空；接受后才按留下的文本刷新 0017；
- 空格 = 接受 + 插入空格，不选紧凑栏第一项；
- 成对 opener 的两侧载荷替换/删除，以及拆不干净时只保留 opener；
- stale-ahead 时标点候选 fail-closed。

Extension 测试覆盖键面文案与动作接线，不在 UIKit 里复制轮换算术。

## Alternatives Considered

- **只改键面文案，继续 `insertDirectText("，")`：** 拒绝。无法替换、无法轮换、候选栏不会出现标点。
- **复用 ADR 0017 continuation：** 拒绝。联想是追加词，标点是替换一段已上屏文本；数据源、寿命、点选副作用都不同。
- **UI 本地 overlay，不进 Core：** 拒绝。Delete、组字提交、成对符号、responsive guard、展开面板守卫都会分叉，无法单测状态机。
- **把 `，` 交给 RIME punctuator / 假 composition：** 拒绝。会污染 marked text、Path Bar 和 session reset 合同；产品要的也不是拼音候选。
- **复用字母页 `insertDirectText` 或符号页提交路径原样进入 pending：** 拒绝。前者会上屏 preedit 或丢掉 L1，后者会留下 Path Bar。
- **超时或失权后仍按旧 span 回删：** 拒绝。会在用户点进输入框后删错字，且不能靠读取 host 上下文来「对一下」。
- **系统整页标点盘 / 键区顶栏：** 产品已拒绝。本 ADR 不预留第二套 chrome。
- **候选点选后仍沿四键轮换：** 产品已拒绝。非四键 pending（如 `……`）没有自然的「下一个」。
- **超时即拆除 pending：** 拒绝。1.0 秒只约束同键轮换；候选栏替换必须能在用户看清之后仍然可用。
- **V1 不做新 `CandidateKind`，用 placeholder 可点：** 拒绝。`placeholder` 的现有合同是不可点提示。重载它会破坏类型穷尽性。
- **空格选中紧凑栏第一项：** 产品已拒绝。空格接受当前 pending 再插入空格。

## Consequences

- KeyboardCore 多一个与 continuation 同级的 ephemeral 状态和一个候选 kind。
- 九键标点键从「直接插逗号」变成状态机入口。
- 候选栏在无拼音时可能显示标点而不是联想；这是产品要求，不是回归。
- ADR 0017 的刷新时序在 pending 存活期间被推迟；0017 的其余合同不变。
- `KEYBOARD_LAYOUT.md` 的 `[,?!]` chrome 图在实现授权后必须改成 `，。？！` 并引用本 ADR；在 Accepted 之前不得假装 chrome 已交付。
- 成对补全的光标夹心成为 pending 替换的一等场景，而不是符号页私货；拆不干净时退回 opener-only。

## Risks

- 真实 `UITextDocumentProxy` 对 `adjustTextPosition` + 连续 `deleteBackward` 的表现仍可能不一致。Decision 已要求 fail-closed；Core 单测不能替代真机 Product Gate。
- `KeyboardEffect` 用尽 `UInt8` 最后一位，后续 effect 需要扩类型。
- L1-ahead 拒绝该键，手感上会像「点了没反应」。必须保持 composition 不变，不得偷偷丢掉拼音。若真机证明拒绝范围过宽，回 Product，不得改成放弃 L1。
- 1.0 秒窗口在不同帧率/反馈延迟下的手感需要真机确认，但数值本身已经冻结；改数值要改 PD，不是改 ADR 私货。

## Follow-up Work

- 独立 Architecture R2 已 Pass；Product Lead 已接受。下一缺口是 **实现授权**，不是再改 ADR。
- R2 四条 P2（`A2-P2-01`…`04`）保持 `accept`：实现测试清单收口前三条；成对手术中途撕裂归 Quality / 真机门。
- 实现授权后：更新 `KEYBOARD_LAYOUT.md`、`CandidateKind` 测试、`KEYBOARD-LAYOUT-9KEY-PUNCT-001` 实现与 Human Product Gate。
- 颜表情候选仍是独立未来 Assignment，不得搭车本 ADR。
- 若要把同一状态机开到 26 键或符号页，另开 Product Decision。

## Related Documents

- [`PD-KEYBOARD-LAYOUT-9KEY-PUNCT-001`](../../product-decisions/KEYBOARD-LAYOUT-9KEY-PUNCT-001-authorization.md)
- [`KEYBOARD-LAYOUT-9KEY-PUNCT-001`](../../assignments/keyboard-layout-9key-punct-001.md)
- [`keyboard-layout-9key-punct-001-architecture-review.md`](../../assignments/keyboard-layout-9key-punct-001-architecture-review.md)（针对修订前文本；`Pass with conditions`）
- [`KEYBOARD_LAYOUT.md`](../../KEYBOARD_LAYOUT.md)
- [`POST_COMMIT_CONTINUATION.md`](../../POST_COMMIT_CONTINUATION.md)
- ADR 0002 可见性放弃 composition
- ADR 0007 Full Access / 隐私（禁止为对 span 去读 host 上下文）
- ADR 0017 ephemeral continuation（本 ADR 只推迟刷新时序）
- ADR 0018 / 0026 九键 runtime（本 ADR 不改 scheme / readiness）
- `architecture/input-pipeline-and-marked-text.md`
- `UI_STYLE_GUIDE.md` 候选栏几何（本 ADR 不改冻结几何）
