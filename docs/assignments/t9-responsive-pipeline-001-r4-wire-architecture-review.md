# Architecture Review: T9-RESPONSIVE-PIPELINE-001 / R4-Wire

**Reviewer role:** 🏛️ Architecture & Knowledge Steward（独立 subagent；对抗性结构审查）  
**Date:** `2026-07-31 Asia/Shanghai`  
**Assignment:** [`T9-RESPONSIVE-PIPELINE-001`](t9-responsive-rime-pipeline-001.md)  
**Phase:** R4-Wire — dual-gate thread-affine owner 接线进 `KeyboardController`  
**Product authority:** [`PD-T9-RESPONSIVE-PIPELINE-001`](../product-decisions/T9-RESPONSIVE-PIPELINE-001-authorization.md) § R4-Wire  
**Design freeze:** [`t9-responsive-pipeline-001-r4-wire-design.md`](t9-responsive-pipeline-001-r4-wire-design.md)  
**Predecessors:** R4-Owner `768d680`；R4-B `cb45f1c`  
**ADR:** [`0025`](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md) — **Status remains `Proposed`（本审查不 Accept）**  
**Sources reviewed (working tree at review time):**

| Artifact | Role |
|---|---|
| `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController.swift` | dual gate flags / rebuild / presentation / lifecycle |
| `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+RimeRecovery.swift` | gate-on insert accept 路径 |
| `Packages/KeyboardCore/Sources/KeyboardCore/ThreadAffineRimeSession.swift` | coordinator / bridge / bootstrap type eraser |
| `Packages/KeyboardCore/Sources/KeyboardCore/ThreadAffineRimeSpike.swift` | owner / mailbox / delivery 合同（work surface） |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/ThreadAffineRimeWireTests.swift` | 结构可证伪性形态（绿条归 Quality） |
| R4-Wire design freeze | D1–D5 + non-claims |
| PD R4-Wire 授权段 | 产品边界与 Forbidden |
| `docs/evidence/t9-responsive-pipeline-r4-wire-2026-07-31.md` | Executor 叙事（**不**采信为 Arch Pass） |
| ADR 0025 | Status 仍 **Proposed** |

**Verdict:** **Pass with conditions**

| Severity | Count |
|---|---|
| P0 | 0 |
| P1 | 1（dual-gate 下 MainActor `performOrderedNow` 与 delivery 泵结构冲突） |
| P2 | 4（后续阶段 / 已知 residual；不重开 dual-gate default-off 与无 dual-entry 结论） |
| P3 | 4 |

> **判定原则：** 只根据源码结构是否兑现 R4-Wire design freeze 的 D1–D5 与 PD 边界；不以 Executor evidence 绿条代替结构审查；Quality 拥有测试执行与诚实证据；本文件 **不** 声称 ADR Accept、Product Gate、Release default-on、设备 non-stutter、Extension 生产 bootstrap 安装完成。

---

## 1. Scope of this review

**In scope**

- **D1 Dual gate：** `isResponsiveRimePipelineEnabled` + `isThreadAffineRimeOwnerEnabled` 默认 off；矩阵分支
- **Bootstrap-only：** dual-gate 路径仅通过 `AnyThreadAffineRimeEngineBootstrap` 在 owner 线程物化引擎；缺 bootstrap fail-closed
- **No dual-entry：** 同一 session 不得同时持有 live MainActor engine 与 owner engine
- **Composition accept：** gate-on dual path 经 `scheduleProcessKey`，handle 不等待 librime
- **Presentation：** ordered delivery → `applyResponsivePublishedSnapshot`（R3 context FIFO；thread-affine 无 MainActor live engine 时 presentation-only）
- **Lifecycle：** abandon/epoch、suspend/resume、gate rebuild teardown
- **Non-claims：** ADR 0025 保持 Proposed；两 gate 默认 off

**Out of scope（不得借本 Pass 偷渡）**

- ADR 0025 Accept / Product Gate / R5 device A/B / Release default-on
- 设备主观 non-stutter / jetsam SLO
- Extension 生产站点安装真实 `ThreadAffineRimeEngineImplBootstrap`（design 明确 optional）
- Delivery 队列背压（R4-Owner/R4-B **P2-later-2** 仍 open）
- 本机 `swift test` 绿条担保（**Quality**）

---

## 2. Residual disposition (from R4-B / prior)

| Residual | R4-Wire 目标 | 源码结论 |
|---|---|---|
| R4-B **P2-later-3** Extension/Controller 生产接线 | 在 dual-gate default-off 下接线 owner | **Partial closed** — controller 接线存在；Extension 默认安装 bootstrap **未**做（符合 design non-claim） |
| R4-Owner/R4-B **P2-later-2** delivery 无界背压 | 不在 R4-Wire 授权强制关闭 | **Still open** — 见 §5 |
| R3 symbol `performOrderedNow` 双重 apply | 非本刀主关闭项 | **Still open** — 见 §5 P2 |
| Spike 文档 “Not wired into KeyboardController” | 接线后应过期 | **Stale comment** — P3 |

---

## 3. Design freeze structural judgment

### 3.1 D1 — Dual gate default-off + matrix — **Closed（default / 分支形状）**

**Freeze 要求：**

```text
responsive=false → sync ADR 0004
responsive=true, threadAffine=false → R2/R3 MainActor deferred
responsive=true, threadAffine=true + bootstrap → thread-affine owner
responsive=true, threadAffine=true + no bootstrap → fail closed to MainActor R2
```

**源码事实（`KeyboardController`）：**

| 符号 | 默认 | 观察 |
|---|---|---|
| `isResponsiveRimePipelineEnabled` | `false` | 未发现生产路径默认翻 true |
| `isThreadAffineRimeOwnerEnabled` | `false` | 同上 |
| `threadAffineEngineBootstrap` | `nil` | 可选安装 |
| `threadAffineRimeCoordinator` | rebuild 前 nil | dual-gate 才安装 |

`rebuildResponsiveRimeCoordinatorIfNeeded` 分支顺序：

1. 先 teardown 既有 `threadAffineRimeCoordinator.shutdown()`
2. unwrap `ResponsiveRimeEngineBridge` / `ThreadAffineRimeEngineBridge`（防嵌套 bridge）
3. `!isResponsiveRimePipelineEnabled` → 还原 underlying（若有）、两 coordinator 清空 → **ADR 0004**
4. `isThreadAffineRimeOwnerEnabled && bootstrap != nil` → **仅** thread-affine coordinator + `ThreadAffineRimeEngineBridge`；`responsiveRimeCoordinator = nil`
5. 否则（含 threadAffine 请求但缺 bootstrap）→ 有 underlying 则 **MainActor R2**；无 engine 则 coordinator nil

| 检查项 | 结果 |
|---|---|
| 两 gate 源码默认 false | **Yes** |
| threadAffine 单独 true + responsive false → 不安装 owner | **Yes**（early return 在 responsive guard） |
| responsive only → MainActor `ResponsiveRimeEngineBridge` | **Yes** |
| dual + bootstrap → thread-affine only | **Yes** |
| dual 缺 bootstrap → fail-closed 到 MainActor R2（有 underlying 时） | **Yes**（注释写明；**无** content-free log — P3） |
| 测试形态覆盖 defaults / dual accept / flag-alone / responsive-only | **Present**（`ThreadAffineRimeWireTests` 四案） |

**结论：** D1 的 **default-off 与分支形状**结构关闭。缺 bootstrap 的“有意 fail-closed”与 design recommended 路径一致。

---

### 3.2 D2 / D3 — Bootstrap-only + single owner（no dual-entry）— **Closed（引擎隔离）**

**PD Forbidden：** live MainActor engine **与** owner engine 服务同一 session。

**源码事实：**

```text
dual-gate rebuild:
  responsiveRimeCoordinator = nil
  ThreadAffineRimeSessionCoordinator(bootstrap:)
    └─ ThreadAffineRimeSpikeOwner(bootstrap:)
         └─ owner thread: let engine = bootstrap.makeEngineOnOwnerThread()  // local only
  rimeEngine = ThreadAffineRimeEngineBridge(coordinator:)  // 无 underlying live engine

underlyingRimeEngine:
  ThreadAffineRimeEngineBridge → nil   // 禁止 chrome 拿 MainActor live session
```

| 检查项 | 结果 |
|---|---|
| dual-gate 引擎仅由 bootstrap 在 owner 线程创建 | **Yes** |
| Controller 不持有 dual-gate 的 live underlying | **Yes**（`underlyingRimeEngine == nil`） |
| Bridge 将 mutation API 路由进同一 coordinator/owner | **Yes**（`performOrderedNow` / `scheduleProcessKey`） |
| Insert 热路径 `scheduleProcessKey` 与 Bridge 共用同一 owner | **Yes**（非第二引擎） |
| `@unchecked Sendable` 用于 engine shuttle | **No**（相关路径未见） |
| `AnyThreadAffineRimeEngineBootstrap` Sendable type eraser | **Yes** |

**Composition accept（design 要点 3）：**

`KeyboardController+RimeRecovery` dual 分支：

- enqueue `ResponsiveKeyApplyContext`
- `affine.scheduleProcessKey(rimeKey)` — **无** MainActor drain loop
- 立即返回 effects

对比 MainActor R2：`scheduleProcessKey` + `scheduleResponsivePipelineDrain`。  
对比 dual：依赖 owner 线程执行 + delivery 回 MainActor — **handle 不等待 librime** 结构成立。

**结论：** **无 dual-entry（双 live engine）** 结构关闭；bootstrap-only 形状关闭。

---

### 3.3 D4 — Presentation / post-process residual — **Closed as designed（presentation-only residual 明确）**

`applyResponsivePublishedSnapshot`：

- 仍要求 `isResponsiveRimePipelineEnabled`
- `pk-*` FIFO context + epoch 过滤（R3）
- `engineForPostProcess = underlyingRimeEngine`；thread-affine 下为 **nil** → `applyRimeOutput` + local Path refresh + presentation notify  
- **不**在 MainActor 上对 live librime 做 auto-anchor engine mutation（design D4 residual：**suppressed**）

`setPublishHandler` 接到 `applyResponsivePublishedSnapshot` — 与 R3 呈现路径汇合。

**结论：** D4 在 R4-Wire minimum（presentation + local Path；engine-mutating auto-anchor 抑制）**结构兑现**。完整 Path/auto-anchor parity 不在本刀关闭范围。

---

### 3.4 D5 — Lifecycle — **Mostly closed；ordered-wait 路径见 P1**

| Event | 实现 | 判定 |
|---|---|---|
| abandon / epoch | `affine.bumpSessionEpoch` + `clearResponsiveKeyApplyContexts` | **OK** |
| suspend visibility | `affine.suspendForVisibilityChange` → flush mailbox + owner shutdown + `owner = nil` | **OK**（显式 stop，非 deinit-only） |
| resume | `resumeAfterVisibilityChange` → `startOwner()` if nil | **OK**（rebootstrap from held bootstrap） |
| disable / rebuild | teardown coordinator shutdown；unwrap bridge | **OK** |
| reset via controller | `performOrderedNow(.resetSession)` | **受 P1 影响**（返回值/等待） |
| deinit safety net | owner `deinit` → `requestStop` | **仍是 safety net only**（符合 design） |

---

## 4. Findings

### P0

None。

- 两 gate 默认仍为 `false`；未见 Release/生产默认翻 gate。
- 未见 dual-gate 同时安装 MainActor live session 与 owner live session。
- 未见 `@unchecked Sendable` 绕过隔离。
- ADR 0025 源码/文档侧 **未**被本刀 Accept。

---

### P1

#### P1-1 — Dual-gate 下 MainActor `performOrderedNow` / `waitForRevision` 与 MainActor-only delivery 泵结构冲突

**事实：**

1. Owner 完成 work 后只 `delivery.enqueue`；`ThreadAffineRimeDeliveryChannel.schedulePump` 为：

   ```swift
   Task { @MainActor in self.pump() }
   ```

2. `pump` 调用 `resultHandler` → `ThreadAffineDeliverySink.handle` 才写入 `lastPublished`（并可选 `NotificationCenter` → `publishHandler`）。

3. `ThreadAffineRimeSessionCoordinator.performOrderedNow`：

   ```text
   accept(work) → sink.waitForRevision(revision)  // Thread.sleep 自旋
   ```

4. `KeyboardController` 与 Bridge 在 **MainActor** 上调用 `performOrderedNow`（Delete / select / page / reset / recover / symbol `replaceInput` / Bridge `processKey`）。

5. MainActor 上 `Thread.sleep` **不会**推进同 actor 上排队的 `Task { @MainActor in pump() }` → `lastPublished` 在等待期间不可更新 → 直至超时（5s）或返回陈旧快照。

**对比 R2：** `ResponsiveRimeSessionCoordinator.performOrderedNow` 在同一 MainActor 上 `flushPending`/`processNext`，`lastPublished` 同步更新 — 无跨线程 delivery 依赖。

**失效模式（dual-gate 启用时）：**

| 调用 | 结构后果 |
|---|---|
| `handle` 符号续写 `affine.performOrderedNow(.replaceInput…)` | MainActor 可能空转至超时；随后显式 `applyResponsivePublishedSnapshot` 可能拿到 nil/旧快照；delivery 稍后才真正 apply |
| `rimeEngine.deleteBackward()` / select / page / reset / recover | Bridge 经 `performOrderedNow`；返回空/旧 `RimeOutput`；会话顺序意图破坏 |
| `candidateWindow` → `flushPending` 后读 `lastPublished` | `flushPending` 只等 mailbox depth，**不等** MainActor delivery 泵；同 actor 上仍可能读到旧 candidates |

**为何不是 P0 / 为何不单独因 default-off 忽略：**

- 默认 dual-gate off → 生产 ADR 0004 不受影响 → **非 P0**。
- 但 R4-Wire design D2/类型表明确要求 `performOrderedNow` 与 Bridge 全 mutation 进 owner；PD 意图是接线后 gate-on 实验可用。  
- Wire 测试只证伪 `scheduleProcessKey`/`handle` 热路径，**未**结构覆盖 Delete/select/replace ordered 返回。  
- 这是 **接线合同缺口**，不是“后续产品 polish”。

**与 dual-entry 的关系：** 本 finding **不是**双 live engine；是 **单 owner 的同步返回路径与 delivery 隔离模型不兼容**。

**Remediation（结构方向，任选其一或等价）：**

1. **拆分 sink 更新与 UI 泵：** owner 完成时在非 MainActor 路径原子写入 `lastPublished`/`revision`（Sendable 快照），`waitForRevision` 只等该侧信道；MainActor 泵仅负责 `publishHandler` / presentation。  
2. **`performOrderedNow` 专用回传：** accept 后用 owner 完成信号（semaphore/AsyncStream）带回 `ResponsiveRimeSnapshot`，presentation 仍走单一有序 delivery（注意与 publish 去重，避免双重 apply）。  
3. **禁止在 MainActor 上 `Thread.sleep` 等 delivery：** 任何同步 wait 必须不依赖“尚未调度的 MainActor Task”。

**关闭条件（下一刀 / 同刀 remediation）：**

- dual-gate 下 `performOrderedNow(.processKey)` / `.deleteBackward` 在 MainActor 测试中于合理时限内返回匹配 revision 的 snapshot；  
- 不等待超时；  
- 有序：pending `scheduleProcessKey` 之后的 Delete 不得越过未执行 key（与 R2 ordered 合同同构）；  
- 不引入第二 live engine 或 `@unchecked Sendable`。

---

### P2

#### P2-1 — NotificationCenter 全局名 + `object: nil` 观察者 → 多实例串扰风险

`threadAffineRimeSnapshotPublished` 以 snapshot 为 `object` 广播；coordinator 以 `object: nil` 订阅。多 `KeyboardController`/测试并行时，A 的 publish 可触发 B 的 `publishHandler`。单 Extension 实例下风险低；接线形态不稳健。

**Remediation：** 以 coordinator token / 专用 delivery sink 直接调 handler；或 `object` 绑定唯一 publisher 身份。

#### P2-2 — Symbol / ordered 路径双重 apply（R3 residual 延续）

若 P1 修复后 `performOrderedNow` 经 delivery 已触发 `publishHandler` → `applyResponsivePublishedSnapshot`，insert 路径仍显式再 `applyResponsivePublishedSnapshot(snapshot)`（R3 P2-3 类问题）。thread-affine 同样存在该形状。

**Remediation：** ordered 路径 suppress publish 或取消显式二次 apply（二选一，保持 1:1）。

#### P2-3 — Delivery 无界背压（R4-Owner/R4-B P2-later-2）

work mailbox 有界；delivery 在 MainActor 泵滞后时仍可堆积。R4-Wire 未关闭。

#### P2-4 — Dual-gate chrome / runtimeSelection / 全 session 产品面未闭合

- Bridge `chromeEngineHint` 默认 nil → `runtimeSelection` / diagnostics 空；`applyRealizedSelectionFromEngine` 在 dual-gate 下基本无效。  
- auto-anchor engine mutation 在 presentation 路径被 design 抑制。  
- Extension 未安装真实 bootstrap（允许的 non-claim）。  

这些不否定 default-off 接线，但阻止“dual-gate 可当完整输入路径实验”的隐含结论。

---

### P3

1. **缺 bootstrap fail-closed 无 content-free log** — design 文案要求 log；源码仅注释 + 回落 R2。  
2. **`ThreadAffineRimeSpikeOwner` 文件头仍写 “Not wired into KeyboardController”** — 文档漂移。  
3. **`KeyboardController` 若干 R4-Wire 属性/方法异常缩进**（`isThreadAffine…`、`threadAffineEngineBootstrap`、`threadAffineRimeCoordinator`、`threadAffineCoordinatorIfAvailable`）— 可读性。  
4. **缺 “dual-gate + threadAffine true + bootstrap nil → MainActor R2” 的专用 wire 测试形态** — 行为在 rebuild 中存在，测试矩阵未钉死。

---

## 5. Explicit non-claims checklist（本审查确认）

| Non-claim | 结构确认 |
|---|---|
| 任一 gate **非** default-on | **Held** |
| ADR 0025 **不** Accept | **Held**（仍 Proposed；本文件不 Accept） |
| Product Gate / R5 | **Not claimed** |
| 设备 non-stutter | **Not claimed** |
| Extension 生产 dual-gate enable + bootstrap 安装完成 | **Not claimed**（bootstrap 属性 optional） |
| 完整 auto-anchor / Path engine parity under thread-affine | **Not claimed**（D4 residual） |
| P1-1 ordered-wait 已可用于实验 | **Not held** — 见 P1；**不得**用本 Pass 暗示 Delete/select/replace 已接线正确 |

---

## 6. Verdict summary

| Freeze / PD 项 | 结构结论 |
|---|---|
| D1 Dual gate default-off + 分支矩阵 | **Closed** |
| D1 缺 bootstrap fail-closed（→ MainActor R2） | **Closed**（缺 log = P3） |
| D2/D3 Bootstrap-only + 无 dual-entry live engines | **Closed** |
| Composition `scheduleProcessKey` 不等待 librime | **Closed** |
| D4 Presentation 汇合 R3；affine 无 underlying post-process | **Closed as designed** |
| D5 显式 suspend/epoch/rebuild teardown | **Closed**（ordered reset 受 P1） |
| Bridge / `performOrderedNow` 全 mutation 同步返回可用 | **Not closed** — **P1-1** |
| ADR / Product Gate / default-on / device non-stutter | **Non-claims held** |

**Verdict: Pass with conditions**

### Conditions before any dual-gate enablement experiment beyond deferred `processKey` smoke

1. **必须关闭 P1-1**（MainActor 同步 wait 与 delivery 泵隔离兼容；含 Delete/select/replace/reset 的结构证明或等价 API 合同重写并写入 design）。  
2. 保持两 gate **default-off**；不得借 remediation 翻默认。  
3. 保持无 dual-entry：禁止为“修 wait”而把 live `RimeEngineImpl` 再挂回 MainActor 与 owner 并行。  
4. 不 Accept ADR 0025；不声称 Product Gate / 设备 non-stutter。  
5. P2-1/P2-2 建议在启用多 mutation 实验前处理；P2-3/P2-4 可留后续阶段但必须诚实标注。

### Allowed residual after this Pass

- Delivery 背压（P2-3）  
- Extension 真实 bootstrap 安装与 chrome runtimeSelection（P2-4）  
- engine-mutating auto-anchor under thread-affine（design D4 residual）  
- 文档/缩进/log 类 P3  

---

## 7. Handoff

| Receiver | Action |
|---|---|
| **Quality** | 独立审查；至少验证 gate defaults、dual `handle` 不阻塞、responsive-only / flag-alone；**应**增加或要求 P1-1 相关负向/有序用例（若 Executor 未修则如实 Fail/条件） |
| **Executor** | 优先修 P1-1；可选 P2-1/P2-2；补 fail-closed 测试形态与 content-free log |
| **Product** | 在 P1-1 关闭前，**不要**授权 dual-gate 作为完整 session 实验路径；deferred processKey smoke 与 default-off 接线审查可继续 |
| **Architecture** | P1-1 修复后可做 targeted re-review；**不**在本刀 Accept ADR 0025 |

---

## 8. One-line conclusion

R4-Wire 在 working-tree 中兑现了 **dual-gate default-off、bootstrap-only、无 dual-entry live engine、composition accept 不阻塞、presentation/lifecycle 主形状与 ADR 非 Accept**；但 dual-gate 下 **MainActor `performOrderedNow` 依赖 MainActor delivery 泵更新快照** 构成结构性 P1，故 **Pass with conditions**，不得解读为 dual-gate 全 session API 已可安全启用。
