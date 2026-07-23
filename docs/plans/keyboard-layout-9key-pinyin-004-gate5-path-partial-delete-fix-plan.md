# KEYBOARD-LAYOUT-9KEY-PINYIN-004 Gate 5：Partial Commit / Delete Path Identity 修复计划

> **生命周期：** Phase 1 β-limited **review Accept/Pass** — 可请求 Human 分项 A/B/C；完整 B / Human Gate **未**宣称  
> **产品决策：** [`PD-…-PHASE1-BETA`](../product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-004-gate5-phase1-beta-authorization.md)  
> **复审：** [`phase1-beta independent review`](../assignments/keyboard-layout-9key-pinyin-004-gate5-phase1-beta-independent-review.md)  
> **任务性质：** Human Product Gate 第 5 步失败补丁  
> **发布限制：** 未获用户授权时不得 commit、push 或创建 PR

## 1. 问题陈述与 Frozen Facts

004 已具备本地音节 catalog、严格 PD letterPrefix、单一 T9 presentation snapshot，且此前 Architecture Accept、Automated Quality Pass、Bridge Spike Pass、Core 定向矩阵 126/126 Pass。但 iPhone 13 Pro + 备忘录的 Human Product Gate 第 5 步失败；第 1–4、6–8 步已通过。

### 路径 A：完整候选，Phase 0 必须确认

1. 输入 `qingweifandaowozuili` 对应数字串。
2. Path 依次选择 `qing → wei → fan → dao`。
3. 选择候选「请喂饭到」。
4. 期望：marked text 保留剩余输入，Path 立即聚焦 `wo…`，候选与 `wo…` 同步。
5. 2026-07-23 本轮真机确认：从扩展候选点选精确候选「请喂饭到」后，Path 立即显示并聚焦 `wo…`，A 为 **Pass**。RIME 学习后普通候选栏曾只显示更长的「请喂饭到我嘴里」；该完整句候选不作为 A 的替代证据。

### 路径 B：单字 Partial Commit，必现

1. 完整输入并选择 `qing → wei → fan → dao`。
2. 只选择单字「请」，包括从扩展候选选择。
3. 当前必现：Path 错位、空白或焦点错误。
4. 契约结果：仅 `qing` 对应的中文被 Partial Commit；已明确选择的 `wei/fan/dao` 仍属于未完成 composition，不得被清空。身份重基准后，Path 应继续聚焦 `wo…`，marked text、Path、候选必须属于同一 revision。

### 路径 C：误触、删除、继续输入，必现

1. 输入到 `qingweifanda`。
2. 误触 JKL 对应数字键，再按 Delete。
3. 继续输入 `owozuili`。
4. 当前必现：marked text 类似 `qing wei fan fan`；Path 回到 `qing/ping/…` 首焦点；候选出现「轻微饭饭」等错误结果。
5. 用户截图是 Frozen Evidence：可见音节重复、Path 焦点回退和候选错位同时发生。
6. 契约结果：误触键的 append 与紧随其后的 Delete 必须构成可逆槽位变化；Delete 后恢复到误触前的语义身份，继续输入不得复制 `fan`、回到首焦点或暴露数字。

### 第一性原理不变量

- `sourceDigits` 是真实九宫格按键槽位账本；RIME 的纯数字、混合字母和 apostrophe raw 只是运行时表示，不得反向取代该账本。
- 每个已确认拼音必须绑定准确的数字槽位范围；不得仅靠汉字数、显示文本长度或总字母数推断。
- Partial Commit 只消费候选实际覆盖的前缀槽位；未消费且仍匹配原数字签名的 Path 选择必须重基准保留。
- Append/Delete 先改变一个数字槽位，再用同一个纯状态转移器校验哪些 segment、focus、lock 仍然有效。
- 每次用户操作结束后，Core 在同一 `compositionRevision` 发布 Path、marked text 和候选；UIKit 不推测或修补 Path。

## 2. 非目标

- 不修改 26 键输入、候选、删除、空格或回车逻辑。
- 不重新生成或更换本地拼音 catalog。
- 不改变 PD-004、ADR 0023 或 RIME 候选排序权威。
- 不恢复 comment/window 为 Path 合法性权威。
- 不重开 003，不改写 003/004 既有历史结论。
- 不在 UIKit 根据 marked text、候选 comment 或 raw 猜测 Path。
- 不顺带重构普通 Partial、typo correction、number suffix 或 continuation。
- 不以自动化测试替代 Human Product Gate。
- 不 commit、push 或创建 PR。

## 3. 根因验证步骤

Phase 0 先取证并写失败测试，禁止直接放宽现有 guard。

1. 在 DEBUG 日志中记录 B/C 每个关键操作前后的：
   - `compositionRevision`；
   - 事件类型；
   - `sourceDigits` 长度及脱敏签名；
   - confirmed syllable 与各自槽位范围；
   - focus 起止槽位、lock、selected/provisional Path ID；
   - RIME raw 分类：digits / mixed / apostrophe-anchored；
   - Partial 解析出的 remaining raw 数字签名；
   - Path 数量、首项和候选首项；
   - 本事件 RIME 调用种类与次数。
2. 日志不得记录宿主上下文、完整用户文本或持久化个人输入；不得同步写入热路径。完成根因确认后删除临时噪声日志，只保留低频失败日志。
3. 用 FakeRimeEngine 先写 B/C 红测，并保存失败断言，证明：
   - B 在清空 Path 状态后，mixed/anchored raw 无法通过“live raw 必须纯数字”的 restore guard。
   - C 的 `lettersBudget` 回退和 append-retain 不能证明 segment 仍对应原槽位，导致 selection/focus 被错误搬移。
4. 在真机对 A/B/C 各跑一次，记录候选选择后的真实 `previousRaw/resultRaw/preedit/remainingRaw` 形态；若学习状态令目标候选不在普通栏，必须从扩展候选精确点选，不得用更长候选替代。
5. 对 **RIME 明确返回缩短 remainder** 的分支，只有当它可编码为原 `sourceDigits` 的唯一后缀时才允许对齐。对 B 真机已确认的 **raw/result/remaining 完全不缩短** 分支，必须从候选选择前的 segment→slot 账本与候选实际消费前缀进行转移；不得把 unchanged raw 当作 remaining，也不得按汉字数、candidate comment 或候选排名猜 consumed slots。
6. Architecture 三审确认：当前生产 `RimeOutput` / `RimeComposition` 没有暴露“候选实际消费范围”。pre-selection segment→slot 账本只能列出合法边界，不能单独证明本次候选消费哪一段；FakeRime 的 `rawPrefix` 私有副作用也不是生产权威。因此 unchanged-raw B 在进入 Phase 1 前仍缺一个不可伪造的 engine-native coverage 信号。

## 4. 方案选项与推荐

### 方案一：局部扩大现有 restore guard

允许 `restoreSegmentedPathIdentityAfterNestedPartial` 接受 mixed raw，并分别为 Partial、append、Delete 增加保护条件。

- 优点：改动较小。
- 缺点：继续存在三套身份恢复启发式；无法从结构上阻止 B/C 再次分叉，测试通过也可能只覆盖当前 raw 形态。
- 结论：不推荐。

### 方案二：Core 内部统一 T9 槽位身份转移器

新增内部纯值语义 `T9CompositionIdentity`，从当前 `T9PinyinPathState` 提取并校验：

- 原始 `sourceDigits`；
- 已确认 syllable 及其精确槽位范围；
- 当前 focus 范围；
- locked prefix；
- selected/provisional 语义标识。

统一处理三类事件：

- `.partialCommit(remainingSignature:)`
- `.appendDigit(_:)`
- `.deleteLastDigit`

转移器只接收数字签名和 catalog 合法 syllable，不读取候选排序，不调用 RIME，不写 UI。成功后由现有 catalog 一次重建 Path；失败则明确 fail-closed。

**推荐方案：方案二。**

其满足 PD-004/ADR 0023，因为：

- catalog 仍是 Path 合法性权威；
- RIME 仍独占候选与排序；
- identity reducer 只维护用户真实按键与明确 Path 选择；
- Partial/Delete 不再通过 comment 或 probe 猜拼写；
- Core 最终仍通过单一 snapshot 原子发布 Path、marked text 和候选。

### 方案三：每次 Partial/Delete 后重新探测 RIME 拼写

通过多次 `replaceInput/candidateWindow` 尝试重建 Path。

- 违反既有 RIME 调用预算和 ADR 0023。
- 可能重新引入长串卡顿。
- 明确禁止。

## 5. 分阶段实施

### Phase 0：复现与身份形态钉死

- [x] 记录当前工作树状态，避免覆盖非本任务修改。
- [x] 将 A/B/C 写成确定性 FakeRimeEngine 场景。
- [x] 真机分别确认 A/B/C：**A Pass**（精确部分候选后聚焦 `wo…`）；**B Fail**（单字「请」后 Path 为空、候选仍为剩余「喂饭到我嘴里」）；**C Fail**（`fan fan` + 首焦点）。C 已于 2026-07-23 在 iPhone 13 Pro / iOS 27.0 完成两次同构 trace 采集。
- [x] 捕获 B 与 C 的真实 Device Bridge 轨迹。C：Delete 后 live raw 字母化为 `qing wei fan fa`，下一键为 `qing wei fan fa6`，但 `sourceDigits` 未按下一槽推进且 focus 回首段。B：选择单字「请」后 `previousRaw/resultRaw/remainingRaw` 的 class、length、shape、进程内签名均完全相同，仍是完整 anchored-mixed raw；Core 随后清空 `sourceDigits/confirmed/focus/Path`。因此 B 不能从 post-selection raw 推断 remainder。
- [x] 证明 remaining raw 经 T9 字母转数字后是原 source 的唯一后缀。
- [x] 将初次 Human Gate 第 5 步失败写入 evidence；不得将旧失败覆盖成未测试。

### Phase 1：Partial Commit + Path 身份重基准

- [ ] 引入内部纯值 `T9CompositionIdentity` 与无副作用 reducer；不新增公共 UI API。
- [ ] 从原 Path 状态建立 segment→slot 精确映射；每个 syllable 的 T9 数字签名必须与对应 source slice 完全一致。
- [ ] 候选选择前不再破坏性清空 Path 身份。
- [ ] `installPartialCommitPresentation` 先区分两类受证据支持的转移：缩短 remainder 走“严格编码 + 唯一后缀对齐”；unchanged raw 走“候选选择前语义账本 + 已验证消费前缀”。未知形态 fail-closed。
- [ ] 消费前缀后，将未消费、签名仍匹配的 `wei/fan/dao` 等 segment 重基准到新 source。
- [ ] A 中完整「请喂饭到」消费至 `dao`，新焦点为 `wo`。
- [ ] B 中单字「请」只消费 `qing`；`wei/fan/dao` 继续保留，新焦点仍为 `wo`。
- [ ] 将 Partial 前的语义身份存入内部 checkpoint；不得只保存 raw/display 后重新猜 Path。
- [ ] 一次 revision 内安装 lastRimeOutput、partial state、重建 Path、marked text 与候选。

### Phase 0.5：候选消费范围权威 Spike（Architecture blocking）

- [x] **保持 Phase 1 未开始**；Product Lead 已写入 Phase 0.5 allowlist；检查 librime `sel_start/sel_end` 透传丢失点。
- [x] 真实 RIME Bridge Spike 覆盖 B：选择单字后 **raw 不缩短**；pre-select `sel=0..26` **不能**表示 `qing` 槽 `0..<4`。
- [x] 覆盖 A 多字/多音节候选（冷 userdb 下为 7 字整句提交）、shortened remainder、digits raw、window 只读、page-down；证明 pre-select sel 为 menu-scoped。
- [x] 只读元数据透传已落地（`selStart`/`selEnd` → `selectionStart`/`selectionEnd`）；**未**接入 reducer；因 range **不可靠**，**未**给 Fake 加 coverage 权威字段。
- [x] Parser fail-closed：缺失 → `nil`；越界原样保留、由消费者拒绝（不 clamp）。
- [x] 结论 `UNRELIABLE_MENU_SCOPED_ONLY`；coverage 输入标记 `UNKNOWN`；**Stop**，交独立 Architecture/Product Lead。**不得进入 Phase 1。**
- [x] 独立 Architecture + Quality 复审完成；Product Lead 关闭 Phase 0.5。

### Phase 0.6：替代 coverage / selection-delta Spike（Product Lead 授权）

- [x] **保持 Phase 1 未开始。**
- [x] 透传 caretPos / composition.length / commitPreviewLen + highlight API；系统记录选择前后差分。
- [x] B：unchanged raw + 单字；raw/caret delta=0；compLen delta=2 **不在** legal cuts `{4,7,10,13}`。
- [x] A：冷 fixture 为 textLen=7 整句提交（非「请喂饭到」）；不得冒充精确 A。
- [x] shortened remainder + digits 对照；window pool；highlight 0..8。
- [x] 观测驱动 verdict：`UNRELIABLE_NO_ALLOWED_SLOT_MAP`；coverage 仍 `UNKNOWN`。
- [x] **未**接 reducer；**未**宣称 Human Gate。
- [x] 独立 Architecture + Quality 复审完成（Accept 否定；Phase 1 No for full B）。
- [x] Product Lead：β-limited Phase 1 授权；α closed；B 验收不收窄。

### Phase 1 β-limited：C + shortened + fail-closed（Product Lead 授权）

- [x] 引入内部 `T9CompositionIdentity`；**禁止**用禁止信号猜 B 槽。
- [x] **Shortened remainder：** 唯一后缀对齐；Path 重基准。
- [x] **Unchanged-raw B：** fail-closed 自动化。
- [x] **C selected-segment：** typo Delete/continue 自动化绿。
- [x] Partial 首 Delete checkpoint 恢复（含 Path identity 字段）。
- [x] 定向 145 tests / 1 skip / 0 fail。
- [x] 独立 Architecture/Quality（Accept + Pass-with-findings）。
- [x] Human H5 residual A/B/C Pass + Product disposition（post-β）。
- [x] Residual-B Path-ledger **cursor**（单字/多字；soft-select 继承用户 Path 点选；`wo` 不伪造选中）— Human device Pass + PR [#28](https://github.com/shchnk1103/Universe-Keyboard/pull/28) MERGED（`f84a00d`）。权威：[`PD-…-GATE5-RESIDUAL-B-PATH-LEDGER-PEEL`](../product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-004-gate5-residual-b-path-ledger-peel.md)。
- [x] Doc wording A1 closed — dual full-cover policy（short unconfirmed = first；confirmed+remaining = unique）；见 remediation §31。
- [x] Provisional-only mixed-raw C continue closed — ledger peel/append + host resync；`XCTSkip` removed；见 remediation §32。

### Phase 2：Delete / Append identity（并入 Phase 1 β-limited）

- [ ] 用同一 reducer 取代 `retainFocusedT9SegmentAfterAppendingDigit` 和 `restoreFocusedT9SegmentAfterDeletion` 中依赖字母数预算的身份判断。
- [ ] Append 仅向 source 追加一个数字槽位；旧 segment 只有在其完整槽位范围未改变且签名仍匹配时才能保留。
- [ ] Delete 仅删除最后一个真实数字槽位；与删除槽位相交的 selected/lock/focus 必须失效并由 catalog 重建。
- [ ] C 的“误触→Delete”完成后，语义身份必须等价于误触前状态，revision 可不同。
- [ ] 继续输入 `owozuili` 时不得复用已失效的 selected Path，不得产生第二个 `fan`。
- [ ] Partial 后首次 Delete 仍恢复 Partial checkpoint；第二次 Delete 才删除恢复后 composition 的最后一个槽位，保持既有 `球 → Delete → qiule → Delete → qiul` 行为。
- [ ] 任意恢复失败均保持上一个一致状态或清空 composition，绝不向宿主写内部数字。

### Phase 3：定向自动化与独立复审

- [ ] 先运行新增 B/C 单测。
- [ ] 运行 Partial、T9 Path、snapshot、host digit safety、26 键隔离定向矩阵。
- [ ] 核对 FakeRimeEngine 调用计数与 revision 断言。
- [ ] 独立 Architecture 审查 reducer 是否成为唯一身份算法。
- [ ] 独立 Quality 审查失败路径、瞬时 marked-text 历史及调用预算。
- [ ] 自动化通过后只宣布“可重新进行 Human Gate”，不得宣布产品通过。

### Phase 4：真机 Gate 复测

- [ ] iPhone 13 Pro、备忘录、与原失败相同构建复测 A/B/C。
- [ ] 完整复跑 Human matrix 第 1–8 步。
- [ ] 用户填写第 5 步及最终 Human Product Gate 结果。
- [ ] Executor/Reviewer 不得代填或推断 Human Pass。

## 6. 文件 allowlist

### Phase 1 β-limited（Product Lead `2026-07-23` — **Active**）

见 Assignment Phase 1 β-limited allowlist 与 `PD-…-GATE5-PHASE1-BETA`。摘要：

- Core：`T9CompositionIdentity.swift` + Partial/T9/TextEditing/RimeRecovery/PartialCommitState + DEBUG trace  
- Tests：PartialCommit / T9PinyinPath / Snapshot / FakeRime  
- Docs：plan / Assignment / evidence / gate status / PD  
- **禁止：** RimeBridge 新语义、UIKit、catalog、26 键、用禁止信号猜 B 槽  

### Phase 0.5 / 0.6（历史；已关闭）

Bridge 只读透传与 Spike 测试已完成；β-limited **不得**再改 RimeBridge 生产语义。

## 7. 定向测试清单

### `PartialCommitControllerTests`

新增：

- `testGate5AFullCandidateRebasesPathToWo`
- `testGate5BSingleCharacterPartialKeepsRemainingSelectedSegmentsAndFocusesWo`
- `testGate5BSingleCharacterPartialHandlesAnchoredMixedRaw`
- `testGate5BExpandedCandidateUsesSamePartialIdentityTransition`
- `testGate5BFirstDeleteRestoresExactT9SemanticCheckpoint`
- `testGate5PartialTransitionPublishesSingleCoherentRevision`

断言至少包括：

- source digit identity；
- confirmed syllables 与 focus；
- Path 非空且包含正确 `wo` 分支；
- candidates 与 remaining composition 匹配；
- marked text 无数字；
- snapshot paths/candidates/visiblePreedit 属于同一 revision。

### `T9PinyinPathTests`

新增：

- `testGate5CTypoAppendThenDeleteRestoresSemanticIdentity`
- `testGate5CContinueTypingAfterDeleteDoesNotDuplicateFan`
- `testDeleteInvalidatesOnlySegmentIntersectingDeletedSlot`
- `testAppendDeleteRoundTripPreservesConfirmedSegmentRanges`
- `testMixedRawIdentityUsesT9SignatureNotLetterBudget`

C 必须同时覆盖：

- 已明确选择 `qing/wei/fan` 后的误触；
- 没有 selected Path、仅 provisional Path 的误触；
- 删除后继续输入；
- Path 不回首焦点；
- marked-text 全历史无数字；
- 候选不得出现由重复 `fan` 导致的结果。

### `T9PresentationSnapshotContractTests`

新增：

- Partial 后 Path/候选/marked text 单 revision。
- Delete 后 Path/候选/marked text 单 revision。
- 延迟旧 candidate snapshot 在 Partial/Delete revision 变化后失效。

### 既有定向矩阵

```bash
cd Packages/KeyboardCore
swift test --filter 'T9PresentationSnapshotContractTests|T9PinyinCatalogTests|T9PinyinCatalogControllerTests|T9HostPreeditSafetyTests|T9PinyinPathTests|KeyboardLayoutAndT9RuntimeTests|PartialCommitControllerTests'
```

不要求运行全量测试；若定向矩阵外测试因公共模型编译变更失败，必须修复编译，但不得顺带扩大功能范围。

## 8. RIME 调用预算

- Partial candidate：仅允许既有 candidate selection 调用；身份重基准不得新增 `replaceInput`、`candidateWindow` 或拼写 probe。
- 普通九宫格 append：每键最多一次既有 `processKey`；symbol continuation 保留既有一次 `replaceInput`。
- B/C 的 digit-backed Delete：最多一次既有 `deleteBackward`；不得增加候选窗口或逐拼写尝试。
- Partial checkpoint 恢复：最多一次精确恢复调用；失败只允许一次恢复原一致状态，不得循环。
- 既有 visible-letter Delete 可保留“一次精确 replace + 最多一次 rollback”的上限，但本补丁不得扩大。
- 新增测试必须断言 B/C 的 `candidateWindowCallCount`、probe count 均不增加。
- 不允许同步日志、磁盘写入或 catalog 全量扫描进入按键热路径。

## 9. 回归矩阵

真机复测：

1. 单次九宫按键只显示一个字母。
2. `28` 显示完整 `bu/cu/a/b/c`，候选匹配。
3. 选择 `b` 后 Path、候选、marked text 同步收窄。
4. 长串 `deizhaoyishengwenyixia` 中 `yi` 仍可找到 `zi`。
5. A/B/C 全部通过。
6. `toutoumaiqiule → 偷偷买 → qiu → 球 → Delete → Delete` 仍为 `qiule → qiul`，Path 不消失。
7. 全过程宿主输入框无内部数字，包括瞬时更新。
8. 26 键输入、候选、删除、空格、回车不变。

自动化回归：

- 既有 004 catalog、严格 letterPrefix、完整 Path、分页/checkpoint、snapshot、host digit safety 全部通过。
- FakeRimeEngine 纯数字 remainder、完整 raw、mixed raw、apostrophe raw 均覆盖。
- 26 键 `usesT9InputSemantics == false` 不创建 T9 identity 或 Path。

## 10. Stop Conditions

出现以下任一情况立即停止，不得猜修：

- B/C 无法在测试或真机复现，且没有可解释的构建差异。
- 缩短的 remaining raw 转换为 T9 数字签名后，不能唯一对齐原 source 后缀；或 unchanged raw 分支无法由候选选择前的精确 segment→slot 身份证明消费边界。
- 修复需要按汉字数、candidate comment 或候选排名推断 consumed slots。
- 真实 Bridge 输出出现未被既有 Spike 覆盖、且 Core 无法确定解释的新 raw 形态。
- 需要新增 RIME probe 循环、修改候选排序或修改 catalog 权威。
- 需要在 UIKit 猜 Path 或分别刷新三组 UI 状态。
- 需要改动 26 键、PD-004、ADR 0023 或 Assignment。
- unchanged-raw Partial 缺少 engine-native candidate coverage，或修复需要改动当前 allowlist 外的 RimeBridge/RimeOutput：保持 Phase 1 blocked，先由 Product Lead 明确授权 Phase 0.5 Spike/allowlist；不得以 Fake 私有 `rawPrefix` 作为生产证据。
- 单字「请」之后是否允许 Path 暂时清空出现产品契约争议：标记 `UNKNOWN`，交 Product Lead；不得自行放宽。
- 自动化出现内部数字瞬时写入、revision 分裂或 C 的非确定性结果。
- allowlist 文件与用户未提交修改冲突且无法安全隔离。

A 如果由 Pass 变为 Fail，但仍能由相同槽位身份根因解释，则纳入本补丁；若属于不同 RIME/候选契约，Stop 并单独分级。

## 11. 成功标准 / Exit Criteria

### 机器可检查

- A/B/C 新增测试全部通过。
- 既有 004 定向矩阵全部通过。
- B/C 不新增 RIME probe 或 candidate window 调用。
- Append→Delete 后语义 identity 与 append 前等价。
- Partial/Delete 每个操作只发布一个最终 composition revision。
- `markedTextHistory` 全过程不含内部数字。
- 26 键隔离测试通过。
- Architecture 独立审查确认不存在多套冲突身份恢复算法。
- Quality 独立审查 Pass。

### 人类检查

- iPhone 13 Pro + 备忘录中 A/B/C 均通过。
- Human matrix 第 1–8 步完整复跑。
- 第 5 步由用户亲自填写 Pass。
- 未经用户填写，不得宣布 KEYBOARD-LAYOUT-9KEY-PINYIN-004 Human Product Gate 通过或任务 Closed。

## 12. 给 Executor 的执行顺序

- [x] 阅读 AGENTS、PD-004、ADR 0023、004 Assignment、原计划及本补丁计划。
- [x] 检查工作树并建立 allowlist，不覆盖环境改动。
- [x] Phase 0 写 B/C 红测和脱敏诊断日志。
- [x] 用安全的 DEBUG-only、仅内存结构化诊断捕获 B/C Device Bridge 形态，并由用户完成 A/B/C UI 复测；不得以 FakeRime stand-in 冒充真机证据。A 精确部分候选 Pass；B unchanged raw + Path 空；C mixed raw + stale source/focus。
- [x] 将 Gate 第 5 步历史失败写入 evidence。
- [ ] 先完成 Phase 0.5 engine-native candidate coverage Spike，并取得 Architecture 重新 Accept；当前 **不得** 实现 `T9CompositionIdentity` reducer。
- [ ] 接入 Partial rebase，先让 A/B 测试通过。
- [ ] 接入 append/delete，确保 C 与第 6 步通过。
- [ ] 补 snapshot、数字安全、调用预算测试。
- [ ] 运行指定定向矩阵。
- [ ] 写 remediation evidence 与测试命令/结果。
- [ ] 交 Codex 做独立 Architecture + Quality 复审。
- [ ] 复审通过后交用户真机复测。
- [ ] 不 commit、push、PR，不代填 Human Gate。

## 13. 交付物与 Gate 记录

新增：

- `docs/assignments/keyboard-layout-9key-pinyin-004-gate5-remediation-evidence.md`

该文档必须记录：

- Frozen Facts A/B/C；
- 修复前红测与真机 raw 分类；
- 已验证根因；
- reducer 不变量；
- 新增测试及逐项结果；
- RIME 调用计数；
- 独立 Architecture/Quality 结论；
- 未执行项目与残余风险；
- Human Gate 复测占位，默认 `PENDING`。

更新：

- `keyboard-layout-9key-pinyin-004-implementation-evidence.md`：保留首次 Gate 5 Fail 历史，增加 remediation 与复测栏，不覆盖旧事实。
- `keyboard-layout-9key-pinyin-004-gate-entry-status.md`：实现期间改为“Human Gate step 5 failed / remediation pending”；自动化通过后只能改为“ready for human retest”。
- `CHANGELOG.md`、架构时间线和最终 Gate 状态仅在用户明确填写 Human Pass 后更新。

最终禁止：

- 自动化通过即声称 Human Product Gate 通过；
- Executor 或 Reviewer 替用户勾选第 5 步；
- commit、push、PR。
