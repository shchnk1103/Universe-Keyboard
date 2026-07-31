# Architecture Re-review: T9-RESPONSIVE-PIPELINE-001 R2 P1 remediation

**Reviewer role:** 🏛️ Architecture & Knowledge Steward（独立 subagent，对抗性复审）  
**Date:** 2026-07-30 Asia/Shanghai  
**Assignment:** `T9-RESPONSIVE-PIPELINE-001`  
**Phase:** R2 P1 remediation re-review（相对原始 R2 Arch review 的 P1 闭环判定）  
**Verdict:** **Pass with conditions**  
**P0:** 0  
**P1:** 1（仅原始 **P1-3** 仍开放）  
**P2:** 4  
**P3:** 2

> 独立复读**当前源码**与 evidence，不以 Executor addendum 为 Pass 本身。  
> **不**声明 Product Gate、Quality Pass、ADR 0025 Accept。  
> **不**授权 R3+。  
> **不**把 gate-on 端到端可用性或设备主观不卡当作已证明。

---

## Scope re-verified

| Artifact | Result |
|---|---|
| `SerialRimeSession.swift`（Owner / Coordinator / **ResponsiveRimeEngineBridge**） | 全文复读 |
| `KeyboardController.swift`（gate、rebuild、presentation callback、drain Task、visibility） | 复读相关段 |
| `KeyboardController+RimeRecovery.swift`（`scheduleProcessKey` / `scheduleResponsivePipelineDrain`） | 复读 gate 分支 |
| `KeyboardViewController+Bootstrap.swift`（`onResponsivePresentationNeeded` → `syncUI`） | 复读 |
| `ResponsiveRimeR2CoordinatorTests.swift` | 全文复读 |
| 原始 R2 Arch review + Executor addendum | 对照 |
| Evidence `t9-responsive-pipeline-r2-p1-remediation-2026-07-30.md` | 对照；**未**采信为 Architecture Pass 本身 |
| 生产路径 dual-entry grep（`rimeEngine` / `underlyingEngine` / `as? RimeEngineImpl`） | 已做 |
| `@unchecked Sendable` | **未用于隔离绕过**（仅 isolation honesty 注释提及禁止） |
| Release default gate | `isResponsiveRimePipelineEnabled = false` 仍成立 |

---

## Original P1 disposition

| ID | Topic | Disposition | Evidence (source, not only docs) |
|---|---|---|---|
| **P1-1** | Gate ON 时 dual-entry / 非真正 single serial owner | **Closed** | 见下「P1-1 判定」 |
| **P1-2** | 异步 publish 无 Extension effect / 重绘通道 | **Closed** | 见下「P1-2 判定」 |
| **P1-3** | Deferred MainActor drain ≠ ADR §10 off-MainActor owner | **Still open** | 见下「P1-3 判定」；设计残留，非本次未修 bug |

### P1-1 判定 — **Closed**

原始缺陷：gate ON 时 composition 键经 `scheduleProcessKey` 入队，而 Delete / select / Path / recover 等仍同步打**同一 raw** `rimeEngine`，造成 pending key 与后续 mutation 因果颠倒。

**当前事实（gate ON 且 `rebuildResponsiveRimeCoordinatorIfNeeded` 已执行）：**

1. **`ResponsiveRimeEngineBridge` 安装为 `controller.rimeEngine`**  
   `KeyboardController.rebuildResponsiveRimeCoordinatorIfNeeded` 在 gate on + 有 underlying 时：
   - 创建 `ResponsiveRimeSessionCoordinator`（owner 持 raw engine + pipeline）
   - `rimeEngine = ResponsiveRimeEngineBridge(underlyingEngine:coordinator:)`  
   生产调用点普遍经 `rimeEngine` / 局部 `engine`（来自 `rimeEngine`）进入协议方法 → **进入 bridge，而非 raw**。

2. **Bridge 覆盖 `RimeEngine` 协议 mutation / 关键读**  
   `processKey` / `deleteBackward` / `selectCandidate*` / `replaceInput` / `resetSession` / `recoverSession` / `pageUp` / `pageDown` / `suspend*` / `resume*` 均走 coordinator；`candidateWindow` **先 `flushPending()` 再读** underlying。

3. **`performOrderedNow` / `flushPending` 全队列排空**  
   ```text
   accept(work) → while drainOneStep() {} → return lastPublished
   ```
   Delete/select/Path 等在执行自身 work 前必须先 drain 完 pending `processKey`，原始 “pending n 后 sync Delete 再 drain n” 竞态在 **同 MainActor 串行** 下被关闭。

4. **热路径仍单入口到同一 pipeline**  
   `scheduleProcessKey` 与 bridge 的 `performOrderedNow` 共用同一 `ResponsiveRimeSessionCoordinator` / `SerialRimeSessionOwner` / `ResponsiveRimePipeline`。这是 **同一 serial owner 的两种调度形态**（deferred accept vs ordered flush），不是 dual-entry raw engine。

5. **测试**  
   `testDeleteThroughBridgeWaitsForPendingProcessKey`：schedule `n`+`i` 后 `rimeEngine?.deleteBackward()` → composition `"n"`、`processKeyCallCount == 2`。  
   `testPerformOrderedDeleteAfterKeys`、`testBridgeSelectBindsToLastPublished` 覆盖 ordered delete / bridge select。

6. **Visibility**  
   gate ON：`suspend`/`resume`/`resetRimeSessionForVisibilityChange` 经 coordinator flush + owner；`abandon` 仍 `bumpSessionEpoch`。不再依赖 “旁路 raw + 队列并行” 的旧形态。

**关闭范围（必须诚实）：**

- Closed 的是：**在 bridge 已正确安装的 gate-on 配置下，生产 `RimeEngine` 协议路径不再对 raw engine 形成 “队列外 sync mutation” dual-entry；Delete 等不能越过 pending processKey。**
- **不**等于 ADR 0025 §10 最终 off-MainActor owner（那是 P1-3）。
- **不**等于 gate-on 下 T9 Path / auto-anchor / 选择 UX 与 gate-off 行为等价（见 New findings / 原 P2 残留）。

**不把下列事项重新打开为 P1-1：**

| 项 | 为何不是 P1-1 回潮 |
|---|---|
| Pipeline / Owner 内部持 raw engine | 单一 consumer 执行点，本意即 serial owner |
| `candidateWindow` 读 underlying | 已 `flushPending`；只读窗口 |
| typo `correctionCandidates` 走 sidecar | 非 live composition session dual-entry |
| select/replace **绑定发生在 flush 前** | 可能导致 fail-closed 拒绝，**不是** raw 旁路竞态；记为 P2 |
| `as? RimeEngineImpl` chrome 路径在 gate on 时失败 | 读 selection / chrome，非 processKey 旁路；记为 P2 |

### P1-2 判定 — **Closed**

原始缺陷：`applyResponsivePublishedSnapshot` 只改 Core state，无二次 effect；Extension `syncUI` 依赖 `handle` 同步返回的 effects，故 deferred 结果落地后 marked text / candidates 可能不刷新。

**当前事实：**

1. **`applyResponsivePublishedSnapshot`**（`KeyboardController.swift`）在 apply 后构造  
   `KeyboardEffect = [.compositionChanged]`（T9 时再加 `.t9PinyinPathsChanged`），并调用  
   `onResponsivePresentationNeeded?(effects)`。

2. **Extension 接线**（`KeyboardViewController+Bootstrap.bootstrapKeyboard`）：  
   ```swift
   controller.onResponsivePresentationNeeded = { [weak self] effects in
       self?.syncUI(with: effects)
   }
   ```
   Gate 默认 off 时回调 inert；gate on 时 deferred publish 可 re-enter UI。

3. **Drain 触发**  
   `scheduleProcessKey` 后 `scheduleResponsivePipelineDrain`：`Task { @MainActor in await yield; while drainOneStep() }`；`drainOneStep` → `publishHandler` → `applyResponsivePublishedSnapshot`。

4. **测试**  
   `testControllerGateEnablesDeferredProcessKeyAndPresentationBridge`：assert  
   `presentationEffects.contains { $0.contains(.compositionChanged) }`，且 handle 返回时 engine 尚未 process。

**关闭范围：**

- Closed 的是：**publish → MainActor presentation callback → Extension `syncUI` 的架构通道存在且已接线；compositionChanged 会再发。**
- **不**证明 gate-on 下 Path 栏 / auto-anchor / reject-after-key 等与 gate-off 全合同等价（原 P2-4 类残留仍在）。
- **不**证明真实设备长句 UI 体验。

### P1-3 判定 — **Still open**

- R2 isolation 仍是 **MainActor single-consumer + deferred drain**（`Task` + `yield`），**不是** ADR 0025 §10 冻结的 `actor` / off-MainActor serial executor。
- 长 `process_key` 一旦进入 `processNext`/`drainOneStep`，**仍占用 MainActor**；“按键永不因 engine 尖峰卡住”仍未充分满足。
- 源码与注释正确拒绝 `@unchecked Sendable` 把非 Sendable `RimeEngine` 送进后台 actor — **隔离诚实保留**。
- Executor evidence 亦标明 “Not fixed (by design residual)”。  
**Architecture 确认：P1-3 保持开放 residual；不得据此 Accept ADR 0025。**

---

## New findings

### P0

None. Release 默认 gate off → ADR 0004 同步路径。

### P1（本 re-review 新开或仍开放）

| ID | Status | Note |
|---|---|---|
| 原始 **P1-3** | **Still open** | 见上；唯一仍计为 P1 的项 |
| 新 P1 | **None** | 绑定/ chrome cast 等降为 P2，不抬到 P1 |

### P2

1. **Bound work 在 `flushPending` 之前取样 binding**  
   `ResponsiveRimeEngineBridge.selectCandidate*` / 有 published 时的 `replaceInput` 先 `bindingIdentity()` / `lastPublished`，再 `performOrderedNow`（内部先 flush 再执行 bound work）。  
   若此时仍有 pending keys：flush 会推进 applied/published，随后 bound select/replace 易 **fail-closed**。这符合双水印防陈旧意图，但与 “先排空再绑定到最新 published 再选” 的 UX 合同不同。  
   **测试未覆盖** “pending keys + select/Path”。  
   **建议 R3：** flush → rebind to post-flush published（或要求 UI 携带用户所见 snapshot id）的显式合同。

2. **Extension `as? RimeEngineImpl` 在 bridge 下失效**  
   `viewWillAppear` / settings feedback 路径用 `controller.rimeEngine as? RimeEngineImpl` 做 `applyRealizedRuntimeSelection`。gate on 时 `rimeEngine` 是 bridge，cast 失败，可能跳过 chrome 对齐（`resume` 侧 controller 仅 `usesT9InputSemantics`）。  
   **非 dual-entry mutation**，但是 gate-on **lifecycle/chrome 接线残缺**。

3. **Deferred publish 后处理仍薄（原 R2 P2-4 类）**  
   `applyResponsivePublishedSnapshot` → `applyRimeOutput` + effect 回调；**不**跑 gate-off 热路径上的 auto-anchor 推进、focused segment retain、reject-after-key、完整 Path 重建等。  
   UI 能刷新，**行为不等价**。R3 范围，但 gate-on 不得宣传 “与现网一致”。

4. **Gate 翻转 / rebuild 纪律仍是脚枪**  
   生产目前无 gate 置 true 调用点（仅测试）；Bootstrap 在 engine 安装后 `rebuildResponsiveRimeCoordinatorIfNeeded()`。  
   若未来 **gate on 但不 rebuild**，`rimeEngine` 仍可能是 raw，P1-1 竞态会回潮。  
   `handleInsertKey` 仅在 schedule 分支 lazy rebuild；纯 Delete 等不会主动 rebuild。  
   **条件：** 任何启用 gate 的接线必须强制 rebuild；理想为属性 `didSet` 或单一 enable API。

### P3

1. **`isDraining` / `drainGeneration` 在 Coordinator 中基本未参与 drain 逻辑**（bump 时改写，drain 不读）— 易误导读者以为有 generation 取消语义；MainActor 下靠队列清空仍安全。  
2. **`ResponsiveRimePipeline` 文件头仍偏 R1 口吻**（“R2 must place real librime behind actor…”）— 与已落地 MainActor R2 + bridge 略脱节（原 P3-3）。

---

## Gate-on readiness (architecture-only)

| Check | Result |
|---|---|
| Gate ON：生产路径是否仍能在 keys pending 时打 raw engine？ | **在 bridge 已安装前提下：否（协议路径）。** Pipeline 内 raw 是唯一 consumer。未 rebuild 的错误接线除外（P2-4）。 |
| `performOrderedNow` / `flushPending` 是否在 Delete/select 前排空队列？ | **是**（全 `while drainOneStep`）。 |
| UI bridge 是否实际发出 `compositionChanged`？ | **是**（Core callback + Extension `syncUI` + 单测）。 |
| `candidateWindow` flush-before-read？ | **是**。 |
| Gate OFF 是否仍 ADR 0004？ | **是**（默认 false；off 后 rebuild 解包 underlying；同步 `engine.processKey`）。 |
| `@unchecked Sendable`？ | **未用于绕过。** |
| Off-MainActor librime？ | **否 — P1-3 open。** |
| 可宣称 “R2 端到端可用 / ADR Accept 就绪”？ | **否。** |

**Architecture-only gate-on  readiness：**  
**Debug/实验可接线的骨架已齐（serial bridge + deferred key + publish→UI），但非 Accept/默认-on 就绪。**  
仍阻塞 Accept 的架构项至少包括：**P1-3**、bound-select 合同、Path/auto-anchor 等价、Extension chrome cast、启用 gate 的强制 rebuild 纪律，以及独立 Quality/设备证据（本文件不声称）。

---

## Explicit non-claims

- **Not** Product Gate  
- **Not** Quality Pass（evidence 中 `swift test` **未在本 Architecture 审查中复跑**）  
- **Not** ADR 0025 Accepted  
- **Not** R3+ authorization  
- **Not** Release default-on  
- **Not** 证明真实设备九宫格长句主观不卡  
- **Not** 证明 gate ON 下 Delete / candidate / Path / recover 的**完整产品合同**（仅 dual-entry 有序性与 presentation 通道）  
- **Not** 关闭 off-MainActor librime residual（P1-3）  
- **Not** 关闭原 R2 全部 P2/P3  

---

## Recommended next steps (architecture view)

1. **导航与状态句：** 可将原始 Arch **P1-1 / P1-2** 标为 **Closed（R2 P1 remediation + 独立 re-review）**；**P1-3** 保持 **Still open**。勿写 “single serial owner 已满足 ADR §10 最终形态”。  
2. **R3 设计必须显式包含：**  
   - P1-3：thread-confined / actor owner 方案（仍禁 `@unchecked Sendable` 穿梭）或证明 MainActor deferred 满足产品不卡合同（当前证据不足）  
   - flush-then-bind 或 UI-carried snapshot 选择合同  
   - deferred publish 后 Path / auto-anchor 等价策略  
   - Extension 经 bridge/`runtimeSelection` 对齐 chrome（去掉脆弱 `as? RimeEngineImpl`）  
   - gate enable 与 rebuild 原子化  
3. **独立 Quality review** 仍应单独进行（含 dual-entry 竞态、presentation、gate off 回归）；本文件不替代。  
4. **不得**以本 re-review 推进 ADR 0025 Accept 或 Release default-on。

---

## Evidence binding (reviewer)

| Source | Path |
|---|---|
| Owner / Coordinator / Bridge | `Packages/KeyboardCore/Sources/KeyboardCore/SerialRimeSession.swift` |
| Gate / rebuild / presentation / drain | `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController.swift` |
| Deferred key branch | `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+RimeRecovery.swift` |
| Extension presentation wire | `Keyboard/Controllers/KeyboardViewController+Bootstrap.swift` |
| R2 + remediation tests | `Packages/KeyboardCore/Tests/KeyboardCoreTests/ResponsiveRimeR2CoordinatorTests.swift` |
| Original R2 Arch review | `docs/assignments/t9-responsive-pipeline-001-r2-architecture-review.md` |
| Executor remediation evidence | `docs/evidence/t9-responsive-pipeline-r2-p1-remediation-2026-07-30.md` |
| ADR 0025 | `docs/architecture/decisions/0025-responsive-rime-serial-input-pipeline.md`（Status 仍 **Proposed**） |

**方法：** 对抗性源码复读 + 原始 finding 逐条对照 + dual-entry / presentation / gate-off grep；**未**复跑 `swift test`；**未**设备验证。

---

## Summary table (for handoff)

| Original P1 | Closed | Still open | Partially closed | Evidence |
|---|---|---|---|---|
| P1-1 dual-entry | **Yes** | | | Bridge as `rimeEngine`；`performOrderedNow`/`flushPending` 全排空；Delete 单测；生产协议路径无 raw 旁路（正确 rebuild 前提下） |
| P1-2 publish→UI | **Yes** | | | `onResponsivePresentationNeeded` + Bootstrap `syncUI`；`applyResponsivePublishedSnapshot` 发 `.compositionChanged`；controller 单测 |
| P1-3 off-MainActor | | **Yes** | | 仍 MainActor deferred drain；无 `@unchecked Sendable` 绕过；ADR §10 未满足 |
