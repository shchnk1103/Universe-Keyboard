# Architecture Review: T9-RESPONSIVE-PIPELINE-001 R3

**Reviewer role:** 🏛️ Architecture & Knowledge Steward（独立 subagent，对抗性复审）  
**Date:** 2026-07-30 Asia/Shanghai  
**Assignment:** `T9-RESPONSIVE-PIPELINE-001`  
**Phase:** R3（default-off gate-on 行为 parity：Path/auto-anchor apply context、handle 顺序、chrome unwrap）  
**Verdict:** **Pass with conditions**  
**P0:** 0  
**P1:** 2  
**P2:** 5  
**P3:** 2

> 独立复读**当前源码**、Product 授权、Phase A freeze、R2 Arch re-review（P1-1/2 Closed，P1-3 open）、Executor evidence。  
> **不**以 Executor evidence 或 Assignment “implemented” 字样本身作为 Architecture Pass。  
> **不**声明 Product Gate、Quality Pass、ADR 0025 Accept。  
> **不**授权 R4+，**不**关闭 Arch P1-3（off-main librime）。

---

## Scope verified

| Artifact | Result |
|---|---|
| `KeyboardController.swift` — `ResponsiveKeyApplyContext`、`applyResponsivePublishedSnapshot`、`underlyingRimeEngine`、`rebuild`（everyResult） | 复读 |
| `KeyboardController+RimeRecovery.swift` — enqueue context + `scheduleProcessKey` / symbol `performOrderedNow` | 复读 |
| `SerialRimeSession.swift` — Owner / Coordinator / Bridge / `flushPending` / `performOrderedNow` | 复读 |
| `ResponsiveRimePipeline.swift` — publish policy / epoch clearPending | 复读相关段 |
| Extension `KeyboardViewController.swift`、`+Feedback.swift`、`+Bootstrap.swift` | 复读 chrome / rebuild |
| `ResponsiveRimeR2CoordinatorTests.swift` R3 cases | 全文复读 |
| PD R3 auth、Phase A freeze、R2 Arch re-review、Evidence `t9-responsive-pipeline-r3-2026-07-30.md` | 对照 |
| Gate default / `@unchecked Sendable` / dual-entry mutation | grep；default **off**；无 isolation 绕过 |
| ADR 0025 Status | 仍为 **Proposed**（本审查不 Accept） |

**R3 Product 授权边界（PD `T9-RESPONSIVE-PIPELINE-001-authorization.md`）：**

| Allowed | Forbidden |
|---|---|
| Gate-on Path / auto-anchor post-processing after deferred publish | Release default-on / user settings |
| handle 级 multi-action order 测试（如 key→delete） | Off-main librime（Arch P1-3）除非另授权 |
| Extension chrome 经 underlying 解析（非 bare bridge cast） | 扩大 T9 auto-anchor |
| 可选 symbol-page 清理；docs/evidence | `@unchecked Sendable`；ADR Accept；Product Gate self-claim |

---

## Findings

### P0

None。`isResponsiveRimePipelineEnabled` 源码默认仍为 `false`；Release 仍走 ADR 0004 同步路径。未发现默认路径被 R3 静默改写。

### P1

#### P1-1 — `responsiveKeyApplyContexts` 与 pipeline epoch / pending 生命周期未绑定

**事实：**

- Context 仅在 `scheduleProcessKey` 前 `enqueue`，在 `applyResponsivePublishedSnapshot` 里 `removeFirst()`。
- `rebuildResponsiveRimeCoordinatorIfNeeded` 会 `responsiveKeyApplyContexts.removeAll()`。
- **`abandonCompositionForVisibilityChange` → `coordinator.bumpSessionEpoch(resetEngineSession: true)` 清空 pipeline pending，但不清理 contexts。**
- 其它仅 bump epoch、不 rebuild 的路径同样会使 FIFO 与队列脱钩。

**失效模式：**

1. gate on：键入若干键 → contexts 入队、processKey 仍 pending。  
2. visibility abandon / epoch barrier → pending 丢弃，contexts 残留。  
3. 后续新键 enqueue 新 context。  
4. 下次 publish 先 `removeFirst()` 吃到**旧** `rimeKey` / `previousT9PathState` / `previousRawForTrace`。  

结果：Path retain、auto-anchor advance、reject-after-key 等后处理在错误上下文上运行——恰恰破坏 R3 宣称的 parity 合同。

**架构要求：** context FIFO 必须与 serial owner 的 **epoch / pending / rebuild** 同生命周期（至少：`bumpSessionEpoch`、abandon、gate off rebuild 时同步 `removeAll`；理想为 revision/actionID 关联而非裸 FIFO）。

#### P1-2 — Publish 后处理经 `rimeEngine`（Bridge）二次 mutation → pipeline 可重入并偷消费 context

**事实：**

`applyResponsivePublishedSnapshot` 在已从 `drainOneStep` → `publishHandler` 进入时，仍取：

```swift
guard let engine = rimeEngine else { ... }
```

gate on 时 `rimeEngine` 是 `ResponsiveRimeEngineBridge`。后处理会同步调用：

| 路径 | Bridge 行为 |
|---|---|
| `rejectUnusable…` → `abandon…` → `resetSession` | `performOrderedNow` → flush + publish |
| 空 composition 恢复 → `restoreRimeComposition` → `recover/reset/replace/processKey` | 同上（可多次） |
| `retainFocusedT9SegmentAfterAppendingDigit` → `rimeEngine.replaceInput` | 同上 |
| `attemptReversibleT9AutoAnchorIfNeeded` → `replaceInput` | 同上 |

`drainOneStep` 对**任意** work（含 replace/delete/reset）在 `processNext` 后都调用 `publishHandler`，而 apply 侧只要 contexts 非空就 `removeFirst()`——**context 并未与 “仅 deferred processKey” 绑定**。

**失效模式（示意）：**

- 待处理 `[pk "6", pk "4"]`，contexts `[c6, c4]`。  
- drain `"6"` → apply 用 `c6` → retain/resync 触发 `replaceInput` → 嵌套 `performOrderedNow` → 再一次 publish → **偷走 `c4`**。  
- 随后 drain `"4"` → apply 时 ctx 为空 → 跳过 key 级 Path/auto-anchor 后处理。

gate-off 热路径上同类后处理打的是 **raw engine**，不会再进 pipeline、不会二次 publish、不会偷 context。R3 为“parity”复用了后处理函数，却把 engine 入口换成了 Bridge，**合同不等价**。

**架构要求（择一，需显式合同）：**

1. **推荐：** publish 后处理中的 session mutation 走 **underlying serial-owned engine**（仍在 MainActor single-consumer 栈内、processKey 已 applied 之后），并禁止嵌套 `performOrderedNow`/`publishHandler`；或  
2. 后处理 mutation 作为**同 action 的非 publish 续体**（owner 内 reentrancy flag / “apply-side raw” API）；或  
3. 仅当 work kind == deferred processKey 时消费 context，且嵌套 publish 永不 `removeFirst`。

在关闭前，不得把 gate-on 描述为 “Path/auto-anchor 与 gate-off 行为等价”。

### P2

#### P2-1 — handle Delete 在 `engine.deleteBackward()` 前捕获的 Path previous 与 pending flush 时序错位

`handleDeleteBackward` 在调用 `engine.deleteBackward()` **之前**取样 `previousT9PathState` / `previousRawForTrace`。gate on 且存在 pending processKey 时，Bridge `deleteBackward` → `performOrderedNow` 会先 `flushPending`（完整跑各键的 `applyResponsivePublishedSnapshot`），**再**执行 delete。

因此 `restoreFocusedT9SegmentAfterDeletion(previous:)` 拿到的 previous 可能是 **flush 之前** 的 Path，而非 “最后一键已 apply 之后、delete 之前” 的 gate-off 语义。

R3 测试 `testHandleKeyThenDeleteThroughBridgePreservesOrder` 只断言 `engine.sessionComposition == "n"`，**未**覆盖 Path focus / retain 合同。

#### P2-2 — Bridge `isComposing` 含 `hasPendingWork`，扭曲 apply 内恢复分支

```swift
// ResponsiveRimeEngineBridge
public func isComposing() -> Bool {
    coordinator.hasPendingWork || coordinator.sessionOwner.isComposing()
}
```

`applyResponsivePublishedSnapshot` 用 `!engine.isComposing()` 决定是否走 ignored-key 恢复。多键 pending 时即便本 key 输出为空、raw session 未 composing，也会因队列非空而 **跳过** gate-off 会走的恢复逻辑。与 P1-2 同源：apply 阶段应观察 **已 applied 的 underlying session**，而非 “队列语义上的 composing”。

#### P2-3 — Symbol-page replace 双重 apply（R2 残留 + R3 未收口）

`handleInsertKey` gate 分支：

```swift
let snapshot = coordinator.performOrderedNow(.replaceInput(...))
applyResponsivePublishedSnapshot(snapshot)
```

`performOrderedNow` 已在 `flushPending`/`drainOneStep` 中通过 `publishHandler` 调用过 `applyResponsivePublishedSnapshot`。显式二次 apply 可能重复 `applyRimeOutput`、重复 presentation notify；若仍有 contexts，还有错配风险。PD 允许可选 cleanup，但当前 **未**完成。

#### P2-4 — R2 携带残留仍开放（非 R3 关闭项，但影响 gate-on 完备性）

| 残留 | 状态 |
|---|---|
| Bound select/replace **flush 前**取样 binding → 易 fail-closed | **Still open**（R2 Arch re-review P2-1） |
| Gate enable 未与 rebuild 原子化（属性无 `didSet`） | **Still open** |
| Arch **P1-3** off-MainActor librime | **Still open**（R3 禁止扩大；见下） |
| handle 级矩阵仅 key→delete；无 select/Path/candidate/visibility 交错 | **Still open**（测试薄） |

#### P2-5 — R3 测试对 parity / 生命周期证明力不足

| 测试 | 覆盖 | 缺口 |
|---|---|---|
| `testHandleKeyThenDeleteThroughBridgePreservesOrder` | handle insert×2 + delete；async + 可能 `flushPending`；composition `"n"` | 无 Path；依赖 `DispatchQueue.main.async`；未证明 delete 与 deferred drain 的 Path previous；注释仍写 “or empty if delete raced” |
| `testResponsiveApplyRunsPathRefreshContext` | T9 + 一键 + `pathEffects` + contexts empty | 未断言 Path 内容；`asyncAfter(0.05)`；无 multi-key FIFO；无 epoch 后 context 清空；无 auto-anchor gate 交叉 |
| `testGateOffAfterOnRestoresUnderlyingEngine` | unwrap 指针 | chrome 集成未测 |

证据文件声称 `35` Responsive / `813` 全量 green——**本 Architecture 审查未复跑** `swift test`（交 Quality）。

### P3

1. **`rebuild` 强制 `latestOnly → everyResult`**  
   为 context 1:1 合理，但静默取消调用方/ADR 文案中的 UI coalesce 选项。应在注释与 plan 中写清：**R3 生产 rebuild 固定 everyResult；coalesce 仅在无 context 配对需求时再评估**。非缺陷，属诚实性。

2. **`isDraining` / `drainGeneration` 仍基本未参与 drain 逻辑**（R2 P3 携带）— 易误导“有 generation 取消语义”。

---

## Contract alignment

### 1. 是否落在 Product 授权内？

**是（范围合规）。**

- 默认 gate off；无 Release default-on；无 ADR Accept / Product Gate 自宣。  
- 未做 off-main librime（P1-3 仍开放，符合 Forbidden）。  
- 未扩大 auto-anchor 产品默认；仅在 deferred apply 路径**复用**既有后处理（设计意图对齐 R3 “parity”）。  
- Extension chrome 改为 `underlyingRimeEngine as? RimeEngineImpl`（`viewWillAppear` / feedback）。  
- 文档/evidence 存在；Assignment/Plan 状态句未在本审查中当作 Pass。

### 2. Path/auto-anchor post-processing 架构是否健全？

**方向正确，闭环不健全 → 条件通过，不得宣传等价。**

| 设计点 | 评价 |
|---|---|
| Accept 时捕获 `previousT9PathState` / `rimeKey` / `previousRawForTrace` | 正确：deferred 后 apply 需要 accept 时刻快照 |
| FIFO + rebuild 强制 `everyResult` 追求 1:1 | 合理配对策略 |
| apply 内复用 gate-off 后处理序列（reject → restore → applyRimeOutput → retain → advance → auto-anchor → refresh Path） | 意图对齐 parity |
| Context 与 epoch/pending 不同步 | **P1-1 否决“健全闭环”** |
| 后处理经 Bridge 重入 publish | **P1-2 否决“与 gate-off 等价”** |
| Delete previous 捕获时序 | **P2-1** |

### 3. `underlyingRimeEngine` 是否正确修复 chrome dual-type 且不重开 dual-entry？

**是（本项可关闭 R2 chrome cast 类残留）。**

```swift
public var underlyingRimeEngine: RimeEngine? {
    if let bridge = rimeEngine as? ResponsiveRimeEngineBridge {
        return bridge.underlyingEngine
    }
    return rimeEngine
}
```

- Extension 两处生产 chrome 路径已改用 `underlyingRimeEngine`，gate on 时仍可 `as? RimeEngineImpl` 做 `applyRealizedRuntimeSelection`。  
- 用途是 **读 realized selection / chrome 对齐**，不是 composition mutation 旁路。  
- 生产 mutation 仍应经 `rimeEngine`（Bridge）或 owner；**未发现** Extension 用 underlying 调 `processKey`/`deleteBackward`。  
- **不**重开 R2 P1-1 dual-entry（协议热路径）。  
- 注意：P1-2 讨论的是 Core **publish 后处理**误用 Bridge，与 chrome unwrap 是不同问题。

### 4. 相对 R2 P1-3 与剩余 P2 的残留

| 项 | R3 后 |
|---|---|
| Arch P1-3 off-MainActor | **Still open**（R3 未授权、未实现、不得声称关闭） |
| R2 P1-1 dual-entry / P1-2 presentation | **保持 Closed**（本审查未发现回潮；chrome 改 underlying 不构成 dual-entry） |
| Path/auto-anchor parity | **部分落地骨架**；P1-1/P1-2 阻止 “parity done” |
| Bound select flush-then-bind | **Still open** |
| handle 全矩阵 | **Still open** |
| Symbol replace sync-drain / double apply | **Still open**（P2-3） |
| 长 `process_key` 仍占 MainActor | **Still open**（P1-3 根因） |

### 5. 与 ADR 0025 的关系

- Status 仍 **Proposed**。  
- R3 未推进 §10 最终 off-main owner。  
- 强制 everyResult 与 §3 “UI 可 coalesce” 不冲突（coalesce 是发布策略可选项），但 production rebuild 实际取消 latestOnly 入口，需文档诚实。  
- **本审查明确不 Accept ADR 0025。**

---

## Conditions

在声称 “R3 Architecture Pass（无条件）” 或进入更宽 gate-on 实验宣传之前，至少：

1. **关闭 P1-1：** epoch bump / abandon / 任何 clearPending 路径与 `responsiveKeyApplyContexts` 同步失效；测试：pending keys + abandon + 新键 → 后处理使用新 context。  
2. **关闭 P1-2：** publish 后处理禁止经 Bridge 嵌套 `performOrderedNow` 偷 context；明确 underlying / reentrancy 合同；测试：multi-key + 触发 replaceInput 的 Path/auto-anchor 路径后 contexts 与后处理仍 1:1。  
3. **处理或降级记录 P2-1/P2-2：** Delete previous 取样点与 bridge flush 语义；apply 内 `isComposing` 读 underlying。  
4. **不得**把 R3 写成 ADR Accept / Product Gate / Release default-on / P1-3 Closed。  
5. **不得**授权 R4+ 作为本文件副作用；R4 需单独 Product 授权。

满足条件 1–2 后，R3 骨架可视为 Architecture **parity plumbing Pass**；完整产品合同仍依赖 Quality、设备证据与后续矩阵。

---

## Explicit non-claims

- **Not** Product Gate  
- **Not** Quality Pass（未在本审查复跑 `swift test`；不采信 evidence 绿条为 Arch 结论）  
- **Not** ADR 0025 Accepted  
- **Not** R4 / R5 / R6 授权  
- **Not** Release default-on  
- **Not** Arch P1-3（off-main librime）Closed  
- **Not** gate-on 与 gate-off 在 Path / auto-anchor / Delete / recover 上的完整行为等价已证明  
- **Not** 真实设备九宫格长句主观不卡已证明  
- **Not** bound-select flush-then-bind 合同已完成  

---

## Recommended next (architecture)

1. **R3 补丁（仍 default-off，建议仍算 R3 remediation，不自动升 R4）：**  
   - epoch/abandon 清理 contexts；  
   - apply 后处理 engine 入口改为 underlying 或 owner 内 non-publishing mutation API；  
   - Delete previous 在 flush-after-pending 语义下重取样或先 `flushPending` 再进入 handle Delete Path 逻辑；  
   - symbol replace 去掉双重 apply；  
   - 补测：epoch×context、multi-key×retain/replace、handle delete×Path。  
2. **独立 Quality review** 仍应单独进行（本文件不替代）。  
3. **P1-3** 保持开放；任何 off-main 设计需另开 Architecture + Product 授权。  
4. 导航状态句建议：  
   `R3 implemented (default-off); Arch review Pass with conditions (P1 context lifecycle + publish reentrancy open); P1-3 off-main still open; not ADR Accept / not Product Gate`。

---

## Evidence binding (reviewer)

| Source | Path |
|---|---|
| Context / apply / underlying / rebuild | `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController.swift` |
| Enqueue + scheduleProcessKey | `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+RimeRecovery.swift` |
| Bridge / flush / ordered | `Packages/KeyboardCore/Sources/KeyboardCore/SerialRimeSession.swift` |
| Delete previous capture | `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+TextEditing.swift` |
| Path retain → replaceInput | `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+T9PinyinPath.swift` |
| Auto-anchor → replaceInput | `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+T9ReversibleAutoAnchor.swift` |
| Extension chrome | `Keyboard/Controllers/KeyboardViewController.swift`, `+Feedback.swift`, `+Bootstrap.swift` |
| R3 tests | `Packages/KeyboardCore/Tests/KeyboardCoreTests/ResponsiveRimeR2CoordinatorTests.swift` |
| PD / Freeze / R2 re-review / Evidence | `docs/product-decisions/T9-RESPONSIVE-PIPELINE-001-authorization.md`, `docs/assignments/t9-responsive-pipeline-001-phase-a-freeze-2026-07-30.md`, `docs/assignments/t9-responsive-pipeline-001-r2-architecture-rereview.md`, `docs/evidence/t9-responsive-pipeline-r3-2026-07-30.md` |

**方法：** 对抗性源码复读 + 授权边界核对 + dual-entry/reentrancy/context 生命周期推演；**未**复跑测试；**未**设备验证。

---

## Executor P1 remediation addendum (2026-07-30)

| ID | Status |
|---|---|
| P1-1 context/epoch | **Remediated:** `clearResponsiveKeyApplyContexts` on abandon/reset; context tagged with `sessionEpoch`; apply drops mismatched epochs |
| P1-2 reentrancy | **Remediated:** post-process uses `underlyingRimeEngine` + temporary `rimeEngine` swap; only `pk-*` consumes FIFO; `withPublishHandlerSuppressed` safety net |
| P1-3 off-main | **Still open** |

Not an independent Architecture re-Pass.

---

## Summary table (handoff)

| Review question | Answer |
|---|---|
| 1. 在 Product 授权内？ | **Yes**（default-off parity 骨架；无 ADR Accept / Gate / off-main） |
| 2. Path/auto-anchor 架构健全？ | **Partially** — FIFO+everyResult 方向对；P1-1/P1-2 阻止闭环 |
| 3. underlyingRimeEngine chrome？ | **Yes** — 修复 dual-type；不重开 mutation dual-entry |
| 4. vs R2 P1-3 / P2s？ | P1-3 **open**；parity 新开 P1；多项 P2 携带 |
| Verdict | **Pass with conditions** |
| P0 / P1 / P2 / P3 | **0 / 2 / 5 / 2** |
