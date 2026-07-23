# KEYBOARD-LAYOUT-9KEY-PINYIN-004 — Codex 审查交接（完成情况详报）

**Prepared by:** Grok 4.5（Executor）  
**Handoff target:** Codex — 独立 Architecture Review + Quality Review（不得与实现结论混写）  
**Date / timezone:** `2026-07-22 Asia/Shanghai`  
**Working branch:** `codex/t9-atomic-path-snapshot`  
**Working tree:** **dirty / uncommitted** — 含 003 基线改动 + 004 增量；计划禁止在未获用户授权时 commit / push / PR / reset 覆盖 003 改动。

> 本文是实现完成情况的审查入口，不是 Architecture / Quality / Product 结论。  
> **禁止**将自动化测试或本文叙述当作 Human Product Gate 通过。  
> Codex 应从当前工作树重跑定向测试并独立出具结论。

---

## 1. 任务身份与权威链

| 项 | 路径 / 值 |
|---|---|
| Plan | [`docs/plans/keyboard-layout-9key-pinyin-004-complete-path-catalog-and-atomic-sync-plan.md`](../plans/keyboard-layout-9key-pinyin-004-complete-path-catalog-and-atomic-sync-plan.md) |
| Product Decision | [`docs/product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-004-authorization.md`](../product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-004-authorization.md) |
| ADR | [`docs/architecture/decisions/0023-t9-complete-local-path-catalog-and-atomic-presentation.md`](../architecture/decisions/0023-t9-complete-local-path-catalog-and-atomic-presentation.md) |
| Assignment | [`docs/assignments/keyboard-layout-9key-pinyin-004.md`](keyboard-layout-9key-pinyin-004.md) |
| 自动化证据摘要 | [`docs/assignments/keyboard-layout-9key-pinyin-004-implementation-evidence.md`](keyboard-layout-9key-pinyin-004-implementation-evidence.md) |
| 前驱失败记录 | [`keyboard-layout-9key-pinyin-003.md`](keyboard-layout-9key-pinyin-003.md)（Human Product Gate 失败；由 004 取代，**不得改写为通过**） |
| 被取代的 Path 源约束 | ADR 0021「多位 Path 仅来自 live comment 授权」；ADR 0022「本任务不授权静态发音源」（**仅 Path 合法性**被 ADR 0023 取代；固定前台成本 / 原子 revision / host 数字安全仍有效） |

### 角色（计划固定）

| 角色 | 指派 |
|---|---|
| Product Lead / Approver | Human Product Owner |
| Domain Owner | Input Intelligence Maintainer |
| Executor | Grok 4.5 |
| Environment Executor | Grok 4.5（仅定向本地 / Simulator） |
| Architecture Reviewer | **Codex 独立审查（本次交接）** |
| Quality Reviewer | **Codex 独立审查（本次交接；与实现者分离）** |
| Human Dependency | 用户 · iPhone 13 Pro · 备忘录 Product Gate（**未执行**） |

---

## 2. 产品目标与不可破坏契约（审查核对清单）

004 要建立 **KeyboardCore 统一发布的 T9 Composition Snapshot**，使同一次 revision 内一致：

1. RIME raw input  
2. 用户可见 marked text  
3. 当前完整 Path 集合  
4. 选中 / 暂定 Path  
5. 候选及其 raw identity  

### 必须保持

| # | 契约 | 实现声称状态 |
|---|---|---|
| C1 | 每次九宫格按键只向 RIME 发一次数字；不枚举字母探针 | 声称满足：`28` 测例 `processKey==2` 且 Path 路径 `candidateWindow==0` |
| C2 | Path 由本地固定拼音音节索引计算；不依赖有限候选窗口 comment | 声称满足：`T9PinyinLocalPathCatalog` + 编译期目录 |
| C3 | 一次按键最多一个可见字母槽；`TUV` → 先见 `t` 不能见 `ta` | 声称保留：`T9PreeditResolver` 槽位投影；完整覆盖焦点时 provisional Path 可整段显示（如 `28→bu`） |
| C4 | `28` Path 至少 `bu/cu/a/b/c` | 声称满足：纯函数 + Controller 测例 |
| C5 | 点 `b/c` 只锁定前缀、保留后续数字槽、不确认音节 | 声称满足：多位 focus 的 `letterPrefix` lock |
| C6 | 完整音节选择可确认并推进；前缀选择不推进 | 声称满足；单键 focus 上的字母选择仍可确认推进（渐进分段兼容） |
| C7 | 未选择时 provisional 第一项驱动投影，但不记为用户选择 | 声称部分满足：`provisionalPathID` + 全覆盖时显示；否则 comment 槽位投影 |
| C8 | Path 只替换对应槽位，后缀保持 | 声称保留既有 `t9DisplayPreservingUnresolvedSuffix` |
| C9 | 候选仍由 RIME 生成排序；“匹配 Path”= 同 raw 约束 + 同 revision | 声称满足；不要求每个 Path 占首屏候选 |
| C10 | 有效 composition 期间 Path Bar 不因 comment 空 / 候选稀 / Delete / Partial 消失 | 声称满足：catalog 补齐；Delete 序列测例有更新 |
| C11 | 内部数字不得进入宿主 marked text | 声称保留 `updateInlinePreedit` 边界 + HostPreedit 测例 |
| C12 | 26 键冻结：不加载 T9 目录语义、不生成 Path、不改 marked/候选行为 | 声称满足：`usesT9InputSemantics==false` 测例 |

### 性能边界（结构预算，非毫秒）

| 动作 | 预算 | 证据 |
|---|---|---|
| 普通数字键 | Path 逻辑额外 RIME 调用 0 | `testDigit28…`：`candidateWindowCallCount==0` |
| Path / 前缀点击 | 最多 1× `replaceInput`；不得 `candidateWindow` / 逐拼写 probe | `testPrefixB…`：`replaceInput==1`, `candidateWindow==0` |
| Path 计算 | 最多查 6 位数字签名前缀 | `T9PinyinLocalPathCatalog.maximumFocusDigits = 6` |
| 禁止 | 整句笛卡尔积、热路径 YAML/JSON I/O | 编译期生成；运行时字典查询 |

---

## 3. 核心设计摘要（供 Architecture 快速对齐）

### 3.1 编译期音节目录

- **生成器：** `Scripts/generate_t9_pinyin_syllable_catalog.py`（`generatorVersion = "1"`）  
- **输入：** `Keyboard/Resources/luna_pinyin.dict.yaml`  
- **输出：** `Packages/KeyboardCore/Sources/KeyboardCore/T9PinyinSyllableCatalog.generated.swift`  
- **元数据：**

| 字段 | 值 |
|---|---|
| sourceVersion | `0.12.20120711` |
| sourceSHA256 | `971baa1f38a42d3d82f858b5bbdcad6482371f8d93a2f5d5c4ab341046419e3b` |
| syllableCount | `418`（生成器在 count 变化时 **fail closed**） |

- **运行时形态：** `[digitSignature: 有序音节数组]` + 全量有序列表  
- **许可证：** 仓库既有 RIME 词典资源；文件头记录社区来源；**未**网络拉取。审查需确认是否需要额外法律/ATTRIBUTION 文档更新。

### 3.2 Path 模型

```text
T9PinyinPathKind = completeSyllable | letterPrefix

T9PinyinPath {
  id, kind, consumedSlotCount, displayText, replacementRawInput,
  compositionRevision, focusSlotStart, focusSlotEnd
}
```

**排序（当前 focus）：**

1. 消耗槽位更多的完整音节优先  
2. 同长度：当前 RIME comment 首次出现顺序优先  
3. 其余按 catalog 稳定序  
4. 然后当前按键组前缀字母  
5. 同名完整音节与前缀去重，完整音节优先  

**单键 focus 特例：** 保持物理键组序 `m/n/o`，并对 catalog 内字母标 `completeSyllable`（如 `o`）。

### 3.3 选择语义（审查重点）

| 场景 | 行为 |
|---|---|
| 多位 focus 上的 `letterPrefix`（如 `28` + `b`） | `replaceInput` 一次 → raw 如 `b8`；**锁定前缀**；**不**确认音节、**不**推进 focus；Path 收窄 |
| 单位 focus 上的字母（如确认 `n` 后 focus `4` 的 `g`） | 可作为分段确认；有剩余源数字时可推进（兼容 002 渐进分段） |
| `completeSyllable` 且仍有剩余源槽 | 确认 + 推进；partial / 已有 confirmed 时优先显式边界 raw（如 `qiu'53`） |
| 确认 raw 拼装 | 多字母音节 + 后续数字尾 → `prefix'syllable'tailDigits`；单字母分段 → `n'g5` 紧凑形 |

**实现位置：** `KeyboardController+T9PinyinPath.swift` 中 `handleSelectT9PinyinPath` / `canConfirmAndAdvance` / `confirmFocusedT9SegmentAndAdvance`。

### 3.4 展示与安全

- Path 构建 **不再** 为完整性调用 `candidateWindow`。  
- `applyRimeOutputWithoutPartialCommit`：**先** `applyT9PinyinPathStateFromNewRimeOutput`，**再** `t9VisiblePreedit`。  
- Provisional：未选择且第一 Path 的 `consumedSlotCount ==` 槽位数时，可用完整 provisional 拼写（`28→bu`）；否则槽位截断 comment 投影（`8/86/868`）。  
- Host 边界：`HostPreeditSource.compositionProjection` 拒绝 ASCII 数字（partial 已确认中文中的数字仍允许）。

### 3.5 Path Bar UI

- `T9PinyinPathBarView`：固定高度横向 `UICollectionView`，展示 **全部** Core Path。  
- revision 变化滚回首项；同 revision 选中项滚入可见区。  
- 扩展面板仍存在，但 **不再** 作为 Path 完整性来源（计划允许退役；当前为兼容保留 + 弱化）。  
- 审查问题：是否应在 004 内删除 dead panel 代码路径。

---

## 4. 修改文件清单（Allowlist）

### 4.1 004 新增（明确属于本任务）

| 文件 | 作用 |
|---|---|
| `Scripts/generate_t9_pinyin_syllable_catalog.py` | 目录生成器 |
| `Packages/KeyboardCore/Sources/KeyboardCore/T9PinyinSyllableCatalog.generated.swift` | 编译期数据 |
| `Packages/KeyboardCore/Sources/KeyboardCore/T9PinyinLocalPathCatalog.swift` | Path 类型扩展 + 本地目录构建 + Snapshot 结构 |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/T9PinyinCatalogTests.swift` | 目录元数据 / 排序 / 调用次数 / 26 键隔离 |
| `docs/product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-004-authorization.md` | PD |
| `docs/architecture/decisions/0023-t9-complete-local-path-catalog-and-atomic-presentation.md` | ADR |
| `docs/assignments/keyboard-layout-9key-pinyin-004.md` | Assignment |
| `docs/assignments/keyboard-layout-9key-pinyin-004-implementation-evidence.md` | 自动化证据 |
| `docs/assignments/keyboard-layout-9key-pinyin-004-codex-review-handoff.md` | **本文** |
| `docs/plans/keyboard-layout-9key-pinyin-004-complete-path-catalog-and-atomic-sync-plan.md` | 执行计划（既有） |

### 4.2 004 主要改动（在 003 工作树之上）

| 文件 | 004 相关变更要点 |
|---|---|
| `Packages/KeyboardCore/Sources/KeyboardCore/T9PinyinPath.swift` | Path state 增字段；`replacementForProgressiveSyllable` 撇号规则 |
| `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+T9PinyinPath.swift` | catalog 刷新；前缀锁；选择/推进；去掉 Path 用 candidateWindow 发现 |
| `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+PartialCommit.swift` | nested remainder 用 catalog；preedit 先 Path 后投影 |
| `Packages/KeyboardCore/Sources/KeyboardCore/T9PreeditResolver.swift` | provisional 全覆盖投影 |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/T9PinyinPathTests.swift` | 适配 catalog 语义 |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/FakeRimeEngine.swift` | `resetCallCounts()` |
| `Keyboard/Views/T9PinyinPathBarView.swift` | UICollectionView 全量 Path |
| `Keyboard/Controllers/KeyboardViewController+T9PinyinPath.swift` | revision / 授权刷新 |
| `docs/assignments/keyboard-layout-9key-pinyin-003.md` | 失败 + 被 004 取代状态 |
| `docs/KNOWLEDGE_INDEX.md` | 004 导航 |

### 4.3 同分支上的 003 及相关脏文件（审查时必须区分）

工作树仍包含 **003 时代** 的改动与文档，**不是** 004 从干净 `main` 单独长出的 diff：

- `KeyboardController+RimeRecovery/TextEditing/Candidates`、`KeyboardState`、`FakeTextInputClient`、`T9HostPreeditSafetyTests`  
- RimeBridge `RimeSessionManager` 头/源与 `RimeT9PinyinSelectionSpikeTests`  
- `CHANGELOG.md`、`KEYBOARD_LAYOUT.md`、`ARCHITECTURE_TIMELINE.md` 的部分修改  
- 003 PD / ADR 0022 / Stage A evidence 等  

**审查要求：**

1. 不要把 003 的自动化 pass 当成 004 接受证据。  
2. 评估 004 是否在 003 原子 revision / host 安全基线上正确扩展。  
3. 若要求干净 PR，需另做分支切分策略（用户未授权则不要执行）。

---

## 5. 关键代码入口（建议阅读顺序）

1. Plan + PD-004 + ADR 0023（权威）  
2. `T9PinyinLocalPathCatalog.swift`（类型 + 排序 + 构建）  
3. `T9PinyinSyllableCatalog.generated.swift`（前 80 行元数据即可）  
4. `KeyboardController+T9PinyinPath.swift`  
   - `refreshT9PinyinPathState`  
   - `buildProgressiveCompactPaths`  
   - `handleSelectT9PinyinPath`  
   - `canConfirmAndAdvance` / `confirmFocusedT9SegmentAndAdvance`  
5. `KeyboardController+PartialCommit.swift`：`t9VisiblePreedit`、`installPartialCommitPresentation`、`restoreSegmentedPathIdentityAfterNestedPartial`  
6. `T9PreeditResolver.swift`  
7. `T9PinyinPathBarView.swift` + `KeyboardViewController+T9PinyinPath.swift`  
8. 测试：`T9PinyinCatalogTests.swift`、`T9PinyinPathTests.swift` 中 ADR 0023 相关断言  

---

## 6. 定向测试证据（Executor 已跑；Codex 须复跑）

**工作目录：** `Packages/KeyboardCore`

```bash
swift test --filter 'T9PinyinCatalogTests|T9PinyinCatalogControllerTests|T9HostPreeditSafetyTests|T9PinyinPathTests|KeyboardLayoutAndT9RuntimeTests|PartialCommitControllerTests'
```

### 6.1 Executor 结果（2026-07-22）

| Suite | 结果 |
|---|---|
| `T9PinyinCatalogTests` | **7/7 PASS** |
| `T9PinyinCatalogControllerTests` | **3/3 PASS** |
| `T9HostPreeditSafetyTests` | **6/6 PASS** |
| `T9PinyinPathTests` | **49/49 PASS** |
| `KeyboardLayoutAndT9RuntimeTests` | **14/14 PASS** |
| `PartialCommitControllerTests` | **38/39 PASS，1 FAIL** |

**合计定向：** 118 执行量级；**4 个 assertion 失败集中在 1 个非 T9 Path 用例**（见下）。

### 6.2 关键通过测例（004 契约）

| 测例 | 覆盖 |
|---|---|
| `testCatalogMetadataMatchesGeneratedLunaPinyinBaseline` | 版本 / hash / 418 |
| `testFocus28PathsAreBuCuAAndLetterPrefixes` | `bu/cu/a/b/c` 与 replacement |
| `testFocus94KeepsXiYiZiEvenWithoutCommentHints` | comment 稀疏仍完整 |
| `testLockedPrefixBOn28NarrowsToBuAndB` | 前缀锁 |
| `testDigit28PublishesFullLocalCatalogWithoutExtraCandidateWindow` | 调用次数 + provisional `bu` |
| `testPrefixBLocksWithoutAdvancingFocus` | 不推进 + 无 candidateWindow |
| `testUsesT9FalseDoesNotLoadCatalogPaths` | 26 键隔离 |
| 更新后的 `T9PinyinPathTests` 长输入 / 分段 / rollback / host 安全相关 | catalog 语义下的回归 |

### 6.3 残留失败（必须在 Quality 报告中显式处理）

**用例：** `PartialCommitControllerTests.testCandidatePagingDuringTypoCorrectionPartialCommitDoesNotInvalidateCheckpoint`

| 项 | 内容 |
|---|---|
| 现象 | 翻页后 remaining 变成 `anpa`，Delete 恢复不到 `nihapanpai`；checkpoint 丢失 |
| 领域 | **非九宫格 Path 目录主路径**（typo-correction partial + candidate paging） |
| Executor 判断 | 可能与 003 工作树其他改动相关；**未在 004 范围内根因关闭** |
| 建议 | Codex Quality：判定是否为 004 回归 / 003 既有 / 测试脆弱；是否阻断 004 自动化 Quality Pass |

### 6.4 明确未跑

| 项 | 原因 |
|---|---|
| KeyboardCore 全量套件 | 计划限制：仅定向 |
| RimeBridge 真机 / pinned t9 runtime Spike（`28/b8/cu/94→zi/qiu'53/qiul`） | 本会话未执行 Bridge 设备级 Spike |
| Keyboard UIKit / 主 App UI 测试 | 未跑 |
| iOS Simulator / Device 整包构建 | 未跑 |
| Human Product Gate | 依赖用户真机 |

---

## 7. RIME 调用次数与 26 键隔离（可复现）

### 调用次数

- `2` + `8`：`processKeyCallCount == 2`，`candidateWindowCallCount == 0`  
- 选前缀 `b`：`replaceInputCallCount == 1`，`candidateWindowCallCount == 0`  

### 26 键

- `usesT9InputSemantics = false` 时 compactPaths 为空、无 segmentSourceDigits  
- `KeyboardLayoutAndT9RuntimeTests` 14/14  

---

## 8. 已知设计张力 / 风险（请 Architecture 明确表态）

1. **单键字母 vs 多位前缀**  
   - 多位：`letterPrefix` 只锁不推进  
   - 单位 focus：字母仍可确认推进（兼容 002 分段）  
   - 是否与 PD 文字「前缀选择不会推进」完全一致？建议书面接受该边界条件。

2. **Provisional 全覆盖显示**  
   - `28→bu` 直接显示完整 provisional 音节  
   - 与「每键最多一字母」在多位合法完整音节时如何并存：实现选择「槽位全覆盖时允许完整 provisional」  
   - 请确认产品可接受。

3. **Path 完整性 vs 候选窗口发现退役**  
   - Core 已不依赖 window 补 Path  
   - UI 扩展面板代码仍在；是否必须删除。

4. **工作树混合 003+004**  
   - 审查 diff 噪音大；质量结论应绑定「当前树」而非理想干净提交。

5. **生成物入仓**  
   - `.generated.swift` 入库 vs CI 生成：当前入库；count 漂移 fail closed。

6. **`replacementForProgressiveSyllable` 撇号规则**  
   - 多字母：`qing'wei'326…`  
   - 单字母：`n'g5`  
   - 与真实 librime 接受面是否一致：**需要 Bridge Spike 补证**。

7. **残留 PartialCommit 失败**  
   - 是否阻断 004 Quality Pass 由 Quality 独立决定。

---

## 9. Architecture Review 问题清单

请 Codex（Architecture）逐项给出 **PASS / FAIL / NEEDS-INFO**，并引用文件：

1. ADR 0023 是否正确取代 0021/0022 的 Path **合法性**来源，且未错误废弃原子 revision / 固定前台成本 / host 数字安全？  
2. 编译期目录的来源、hash、418 基线、许可证是否可接受？  
3. 热路径是否仍无 YAML/JSON I/O、无整句笛卡尔积、无 Path 用拼写 probe？  
4. 前缀锁 / 完整音节推进 / 单位分段字母推进 的边界是否与 PD 一致且可测试？  
5. UIKit 是否仍只渲染 + 转发，不拼接 replacement raw、不用 accessibility 作业务载荷？  
6. 26 键隔离是否在架构上封闭？  
7. 扩展 Path 面板残留是否可接受？  
8. 与 Partial Commit / Delete / recovery 的 revision 一致性是否仍成立？  
9. 是否存在 Swift 6 / Sendable / 主线程热路径违规？  
10. 是否触发 Stop Condition（来源不明音节表、需第二引擎、扩展部署等）？

---

## 10. Quality Review 问题清单

请 Codex（Quality）逐项给出 **PASS / FAIL / WAIVE+理由**：

1. 复跑第 6 节 filter，记录实际命令输出。  
2. 核对 catalog 元数据测例与磁盘 `luna_pinyin.dict.yaml` hash 一致。  
3. 核对 `28` / `94` / 前缀 `b` / 调用次数测例。  
4. 核对 host marked-text history 无内部数字（T9 相关测例）。  
5. 核对 26 键隔离测例。  
6. 判定 `testCandidatePagingDuringTypoCorrectionPartialCommitDoesNotInvalidateCheckpoint`：回归？既有？是否阻断 004 自动化 Quality？  
7. 列出未跑项与风险（Bridge Spike、真机、全量套件）。  
8. 明确：**自动化 Quality Pass ≠ Product Gate**。

---

## 11. Human Product Gate（仍待用户；审查不得代填）

设备：iPhone 13 Pro · 备忘录

| # | 步骤 | 结果 |
|---|---|---|
| 1 | 单击九宫格 → 仅一个可见字母 | ☐ |
| 2 | `28` → Path `bu/cu/a/b/c`；候选兼容 | ☐ |
| 3 | 点 `b` → Path/候选/输入框同步收窄 | ☐ |
| 4 | 长串 `deizhaoyishengwenyixia`；`yi` 处可横滑到 `zi` | ☐ |
| 5 | `qingweifandaowozuili` 选 qing/wei/fan/dao → 请喂饭到 → Path 切剩余 | ☐ |
| 6 | `toutoumaiqiule` → 偷偷买 → qiu → 球 → Delete×2；Path 不消失 | ☐ |
| 7 | 全程无内部数字 | ☐ |
| 8 | 26 键输入/候选/删/空格/回车无变化 | ☐ |

---

## 12. Executor 完成标准自检

| 交付项 | 状态 |
|---|---|
| PD / ADR / Assignment / 证据文档 | 已写 |
| 修改 allowlist | 本文第 4 节 |
| 音节来源 / 版本 / hash / 生成命令 / 许可证说明 | 已写 |
| 定向测试命令与结果 | 已写（须复跑） |
| RIME 调用次数证据 | 已写 |
| 26 键隔离证据 | 已写 |
| 未跑测试及原因 | 已写 |
| 人工 Gate 步骤模板 | 已写（结果空） |
| 是否更新 CHANGELOG / KEYBOARD_LAYOUT / 管线文档 | **建议 Gate 后再更**；当前树可能有 003 文档噪音 |
| 声称 Human Product Gate | **否** |
| commit / push / PR | **否** |

---

## 13. 建议 Codex 输出格式

请 Codex 在审查结束后另写一份结论文档（建议路径）：

`docs/assignments/keyboard-layout-9key-pinyin-004-codex-review-conclusions.md`

建议结构：

1. **Architecture conclusion：** Accept / Accept-with-findings / Reject  
2. **Quality conclusion：** Automated Pass / Pass-with-waivers / Fail  
3. Findings 列表：`Severity` · `File` · `Evidence` · `Required action`  
4. 复跑命令与原始结果摘要  
5. 对残留 PartialCommit 失败的明确处置  
6. 是否允许进入 Human Product Gate  
7. **不得**自行宣布 Product Gate 通过  

---

## 14. 一句话给 Codex

004 在 003 脏工作树之上，用 **编译期 luna 音节目录** 取代 comment/window 作为 Path 合法性来源，并保持 RIME 候选权威、原子 revision 与 host 数字安全；定向 Core 测例大体绿，**1 个非 T9 Path 的 PartialCommit 翻页用例仍红**，Bridge 真机 Spike 与 Human Product Gate **均未完成**。请独立复跑、区分 003/004 边界、给出 Architecture 与 Quality 结论，**不要**把自动化当产品接受。
