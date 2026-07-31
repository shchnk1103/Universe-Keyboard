# Architecture Re-review: T9-RESPONSIVE-PIPELINE-001 R3 P1 remediation

**Reviewer role:** 🏛️ Architecture & Knowledge Steward（独立 subagent，对抗性复审）  
**Date:** 2026-07-30 Asia/Shanghai  
**Assignment:** `T9-RESPONSIVE-PIPELINE-001`  
**Phase:** R3 P1 remediation re-review（相对原始 R3 Arch review 的 P1-1 / P1-2 闭环判定）  
**Verdict:** **Pass with conditions**  
**P0:** 0  
**P1:** 1（仅 **Arch P1-3** off-MainActor librime 仍开放）  
**P2:** 5（原 R3 P2 携带；其中 P2-2 在 apply 路径被部分缓解）  
**P3:** 3

> 独立复读**当前源码**、原始 R3 Arch review、Executor addendum、evidence。  
> **不**以 Executor addendum 或 evidence 绿条本身作为 Architecture Pass。  
> **不**声明 Product Gate、Quality Pass、ADR 0025 Accept。  
> **不**授权 R4+。  
> **不**关闭 Arch P1-3（off-main librime）。

---

## Scope re-verified

| Artifact | Result |
|---|---|
| `KeyboardController.swift` — `applyResponsivePublishedSnapshot`、`clearResponsiveKeyApplyContexts`、`enqueue…sessionEpoch`、abandon / visibility reset、`rimeEngine` 临时 swap | 全文相关段复读 |
| `SerialRimeSession.swift` — `withPublishHandlerSuppressed`、`drainOneStep`、`pk-` / `ord-` actionID、`performOrderedNow` | 复读 |
| `KeyboardController+RimeRecovery.swift` — enqueue context + `scheduleProcessKey` | 复读 gate 分支 |
| `KeyboardController+T9PinyinPath.swift` — `retainFocused…` → `rimeEngine.replaceInput` | 复读 |
| `KeyboardController+T9ReversibleAutoAnchor.swift` — `attempt…(using:)` → `engine.replaceInput` | 复读 |
| `ResponsiveRimeR2CoordinatorTests.swift` — abandon / multi-key / ord-not-steal | 全文 R3 P1 段复读 |
| 原始 R3 Arch review + Executor addendum | 对照 |
| Evidence `docs/evidence/t9-responsive-pipeline-r3-p1-remediation-2026-07-30.md` | 对照；**未**采信为 Arch Pass 本身 |
| Gate default / `@unchecked Sendable` | 默认 **off**；无 isolation 绕过 |
| ADR 0025 Status | 仍 **Proposed**（本审查不 Accept） |

---

## Original R3 P1 disposition

| ID | Topic | Closed | Still open | Evidence (source, not only docs) |
|---|---|---|---|---|
| **P1-1** | `responsiveKeyApplyContexts` 与 pipeline epoch / pending 生命周期未绑定 | **Yes — Closed** | | 见下「P1-1 判定」 |
| **P1-2** | Publish 后处理经 Bridge 二次 mutation → 重入并偷消费 context | **Yes — Closed** | | 见下「P1-2 判定」 |
| **P1-3** | Deferred MainActor drain ≠ ADR 0025 §10 off-MainActor owner（R2 携带） | | **Yes — Still open** | 见下「P1-3 判定」 |

### P1-1 判定 — **Closed**

**原始失效模式：** abandon / epoch barrier 清空 pipeline pending，但 FIFO contexts 残留 → 后续 publish `removeFirst()` 吃到过期 `rimeKey` / Path previous / raw trace。

**当前事实：**

1. **Context 打 epoch 标签**  
   `ResponsiveKeyApplyContext.sessionEpoch`；`enqueueResponsiveKeyApplyContext` 取 `responsiveRimeCoordinator?.diagnostics.sessionEpoch ?? 1`。

2. **显式清空入口**  
   - `abandonCompositionForVisibilityChange`：`bumpSessionEpoch` **后** `clearResponsiveKeyApplyContexts()`  
   - `resetRimeSessionForVisibilityChange`：ordered reset **后** clear  
   - `rebuildResponsiveRimeCoordinatorIfNeeded`：on/off 均 `removeAll()`  

3. **Apply 时 drop 错配 epoch**  
   ```swift
   while let head = responsiveKeyApplyContexts.first,
         head.sessionEpoch != snapshot.sessionEpoch
   {
       responsiveKeyApplyContexts.removeFirst()
   }
   ```
   即使某路径只 bump 未 clear，错配 head 也会在下一次 publish 被丢弃，不会与新 epoch 的 `pk-*` 配对。

4. **测试**  
   `testAbandonClearsResponsiveKeyApplyContexts`：pending keys → abandon → contexts empty；再输入 `w` + flush → composition `"w"`（证明不会用残留 context 污染新会话合成路径的基本可达性）。

**对抗性残留（不重开为 P1）：**

| 残留 | 为何不是 P1-1 回潮 |
|---|---|
| `coordinator.bumpSessionEpoch` **本身**不清 contexts | 生产 abandon 在调用点配对 clear；epoch tag + apply drop 为第二层。属 call-site 纪律，非原失效模式未修 |
| 仍为 FIFO，非 revision/actionID 关联 | 原 Arch 写的是「理想」；关闭条件是 epoch/pending 同生命周期，不是强制升级关联键 |
| abandon 后新键 Path 内容未断言 | 测试偏 composition；生命周期清空已证明，Path 内容属 Quality/parity 矩阵 |

**结论：** 原 P1-1 失效模式在架构上已闭合 → **Closed**。

### P1-2 判定 — **Closed**

**原始失效模式：** `applyResponsivePublishedSnapshot` 经 `rimeEngine`（Bridge）跑 Path/auto-anchor 后处理 → 嵌套 `performOrderedNow` → 再次 `publishHandler` → 对任意非空 FIFO `removeFirst()` → 偷走后续 key 的 context。

**当前事实（多层防御，满足原推荐合同）：**

| 层 | 实现 | 作用 |
|---|---|---|
| A. engine 入口 | `engineForPostProcess = underlyingRimeEngine ?? rimeEngine`；reject / restore / auto-anchor 传 underlying | mutation 不进 Bridge 队列 |
| B. `rimeEngine` 临时 swap | post-process 期间 `rimeEngine = engineForPostProcess`，`defer` 还原 Bridge | Path 内读 `self.rimeEngine` 的 `replaceInput`（如 provisional resync）也不进 Bridge |
| C. publish suppress | `coordinator.withPublishHandlerSuppressed(runPostProcess)`；`drainOneStep` 在 flag 下跳过 `publishHandler` | 即便误触 Bridge，嵌套 drain **不再** re-enter apply |
| D. 消费门闩 | **仅** `snapshot.actionID.hasPrefix("pk-")` 且 epoch 匹配才 `removeFirst()` | `ord-*`（replace/delete/reset/select）永不偷 processKey context |

`scheduleProcessKey` 固定 `pk-\(actionSequence)`；`performOrderedNow` 固定 `ord-\(actionSequence)` — 与 D 对齐。

**测试：**

| 测试 | 证明力 |
|---|---|
| `testOrdPublishDoesNotConsumeProcessKeyContext` | **强**：手动 enqueue 1 context → `performOrderedNow(.replaceInput)` → count 仍为 1 |
| `testMultiKeyDrainDoesNotStealContextsViaNestedReplace` | **弱但方向正确**：双键 drain 后 contexts empty、composition `"64"`；**未**强制触发 Path retain/`replaceInput`，**未**按键断言后处理次数。不能单独作为「嵌套 replace 1:1」的充分证明，但结合 A–D 源码合同可关闭 **架构** P1-2 |
| Gate-off 路径未改 | 默认 off；后处理 swap 仅 gate-on apply 栈内 |

**对抗性残留（不重开为 P1）：**

| 残留 | 分级 |
|---|---|
| multi-key 测试未真触发 nested replace | **P2 测试薄**（见下） |
| `pk-` 字符串前缀合同脆弱 | **P3** — actionID 方案变更会静默破坏门闩 |
| post-process 期间 `rimeEngine` 全局可见为 underlying；`notifyResponsivePresentation` → Extension `syncUI` 同步回调若再入 session API，会绕过 Bridge | **P3 风险面** — 当前 Bootstrap 仅 `syncUI`，未见再入 mutation；MainActor 同步栈可接受，但模式脆弱 |
| Bridge `isComposing()` 仍含 `hasPendingWork` | **原 P2-2**；apply 内已改读 underlying，**非 apply 的 handle 路径仍可能扭曲** |

**结论：** 原 P1-2「后处理经 Bridge 重入偷 context」在架构上已闭合（推荐方案 1 + 方案 3 + suppress 安全网）→ **Closed**。  
**不得**据此宣称 gate-on 与 gate-off 在 Path/auto-anchor 上完整行为等价（原 P2 / 测试薄仍在）。

### P1-3 判定 — **Still open**

- 仍为 MainActor deferred `drainOneStep` + `Task.yield`；长 `process_key` 仍占 UI 线程 drain turn。  
- 无 off-MainActor owner；无 `@unchecked Sendable` 绕过（正确）。  
- R3 与 P1 remediation **均未授权、未实现** off-main。  
- **Architecture 确认：P1-3 保持开放 residual；不得据此 Accept ADR 0025。**

---

## Disposition table (required)

| ID | Closed | Still open | Evidence |
|---|---|---|---|
| **R3 P1-1** context FIFO / epoch lifecycle | **Yes** | | `sessionEpoch` on context；abandon/reset/rebuild clear；apply drop mismatch；`testAbandonClearsResponsiveKeyApplyContexts` |
| **R3 P1-2** publish post-process reentrancy | **Yes** | | underlying + `rimeEngine` swap；`withPublishHandlerSuppressed`；`pk-*` only consume；`testOrdPublishDoesNotConsumeProcessKeyContext`（multi-key 测偏弱，不挡 Closed） |
| **Arch P1-3** off-MainActor librime | | **Yes** | `SerialRimeSession` 仍 MainActor single-consumer；ADR 0025 §10 未满足 |
| R2 P1-1 dual-entry / R2 P1-2 presentation | **Yes**（保持） | | 本审查未发现回潮；swap 在 apply 内临时露出 underlying **不是**协议热路径 dual-entry 回潮（production mutation 仍经 Bridge，除 post-process 故意 raw） |
| Gate default-off | **Yes** | | `isResponsiveRimePipelineEnabled = false` |

---

## New findings

### P0

None。

### P1

**无新增 P1。** 仅 **P1-3** 仍计为开放 P1（R2 携带，非本 remediation 回归）。

### P2（携带 + 本轮 sharpened）

| ID | 状态 | 说明 |
|---|---|---|
| **P2-1** Delete previous 在 flush 前取样 | **Still open** | 与 P1 remediation 无关；handle Delete Path previous 时序仍错位风险 |
| **P2-2** Bridge `isComposing` 含 `hasPendingWork` | **Partially mitigated / Still open** | apply 内已用 underlying `isComposing`；handle 入口 / Bridge 协议仍扭曲「队列语义 composing」 |
| **P2-3** Symbol replace 双重 apply | **Still open** | `performOrderedNow` 已 publish apply，随后显式再 `applyResponsivePublishedSnapshot`；`ord-*` 不再偷 context，但重复 `applyRimeOutput` / notify 仍在 |
| **P2-4** bound-select / gate-rebuild 纪律 / handle 全矩阵 | **Still open** | R2/R3 携带 |
| **P2-5** 测试证明力 | **Still open（部分收紧）** | abandon / ord-not-steal **新增强**；multi-key **仍弱**（未强制 nested replace、无 per-key path 断言）；Delete×Path / select 交错仍缺 |

### P3

1. **`pk-` 前缀门闩**依赖 actionID 命名约定，无类型化 work-kind。  
2. **`rimeEngine` 临时 swap** 是有效但脆弱的全局可变合同；长期应收敛为「apply-side raw engine 参数贯穿」或 owner 内 non-publishing mutation API，减少 property 抖动。  
3. **`isDraining` / `drainGeneration`** 仍基本未参与 drain 逻辑（R2/R3 携带）。

---

## Gate-on readiness (architecture-only)

| 问题 | 架构结论 |
|---|---|
| R3 P1-1 / P1-2 是否阻塞 parity plumbing？ | **不再阻塞** — 可称 R3 **parity plumbing Architecture Pass（P1-1/2 Closed）** |
| 是否可 Release default-on？ | **否** |
| 是否可宣传 gate-on ≈ gate-off Path/auto-anchor？ | **否** — P2 与测试矩阵未闭合 |
| 是否可 Accept ADR 0025？ | **否** — 至少 P1-3 + 多项 gate-on 完备性残留 |
| 是否可开 R4+？ | **否** — 需单独 Product 授权；本文件不授权 |
| 实验性 default-off gate-on 骨架？ | **架构上允许继续保持 default-off 实验代码**；设备/Quality 另议 |

---

## Explicit non-claims

- **Not** Product Gate  
- **Not** Quality Pass / Quality re-Pass（本审查**未**复跑 `swift test`；不采信 evidence「38 Responsive green」为 Arch 结论）  
- **Not** ADR 0025 Accepted  
- **Not** R4 / R5 / R6 授权  
- **Not** Release default-on  
- **Not** Arch P1-3（off-main librime）Closed  
- **Not** gate-on 与 gate-off 在 Path / auto-anchor / Delete / recover 上的完整行为等价已证明  
- **Not** multi-key nested-replace 1:1 已被单测充分证明（源码合同 Closed；测试证据弱）  
- **Not** 真实设备九宫格长句主观不卡已证明  
- **Not** bound-select flush-then-bind 合同已完成  

---

## Recommended next steps

1. **导航状态句（建议）：**  
   `R3 P1 remediation Arch re-review: P1-1/P1-2 Closed; P1-3 off-main still open; Pass with conditions; keep gate default-off; not ADR Accept / not Product Gate`。

2. **独立 Quality re-review**（本文件不替代）：可针对 abandon/epoch、ord-not-steal、multi-key 补强断言（强制 Path retain 触发 + per-key post-process 计数）。

3. **可选 R3 收尾（非本文件授权范围扩张）：**  
   - P2-1 Delete previous 取样点；  
   - P2-2 apply 外 `isComposing` 读 underlying session；  
   - P2-3 去掉 symbol 双重 apply；  
   - 强化 multi-key×replace 单测。

4. **P1-3** 保持开放；任何 off-main 设计需另开 Architecture + Product 授权。

5. **不得**把 Executor addendum 中的 “Remediated” 单独当作最终 Arch Closed；本文件为独立 Closed 判定来源。

---

## Evidence binding (reviewer)

| Source | Path |
|---|---|
| Apply / clear / enqueue / abandon / swap / suppress call | `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController.swift` |
| Enqueue + scheduleProcessKey | `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+RimeRecovery.swift` |
| suppress / drain / pk-ord IDs / Bridge | `Packages/KeyboardCore/Sources/KeyboardCore/SerialRimeSession.swift` |
| Path retain → `rimeEngine.replaceInput` | `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+T9PinyinPath.swift` |
| Auto-anchor → `engine.replaceInput` | `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+T9ReversibleAutoAnchor.swift` |
| Tests | `Packages/KeyboardCore/Tests/KeyboardCoreTests/ResponsiveRimeR2CoordinatorTests.swift` |
| Original R3 Arch + addendum | `docs/assignments/t9-responsive-pipeline-001-r3-architecture-review.md` |
| Executor evidence | `docs/evidence/t9-responsive-pipeline-r3-p1-remediation-2026-07-30.md` |

**方法：** 对抗性源码复读 + 原失效模式推演 + 多层防御合同核对；**未**复跑测试；**未**设备验证；**拒绝** rubber-stamp Executor addendum。

---

## Summary table (handoff)

| Review question | Answer |
|---|---|
| R3 P1-1 Closed？ | **Yes** |
| R3 P1-2 Closed？ | **Yes** |
| Arch P1-3 Closed？ | **No — Still open** |
| Verdict | **Pass with conditions** |
| P0 / P1 / P2 / P3 | **0 / 1 / 5 / 3** |
| Product Gate / Quality Pass / ADR Accept？ | **全部 Not claimed** |
