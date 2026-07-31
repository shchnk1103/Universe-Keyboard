# Architecture Review: T9-RESPONSIVE-PIPELINE-001 R2

**Reviewer role:** 🏛️ Architecture & Knowledge Steward（独立 subagent，对抗性复审）  
**Date:** 2026-07-30 Asia/Shanghai  
**Assignment:** `T9-RESPONSIVE-PIPELINE-001`  
**Phase:** R2（default-off serial owner + deferred key path）  
**Verdict:** **Pass with conditions**  
**P0:** 0 · **P1:** 3 · **P2:** 6 · **P3:** 3

> 独立复读仓库源码与授权文档后的结论。  
> **不**声明 Product Gate、Quality Pass、ADR 0025 Accept。  
> **不**授权 R3+。  
> **不**把 Executor evidence 当作 Architecture Pass 本身。

---

## Scope verified

| Artifact | Result |
|---|---|
| `SerialRimeSession.swift`（Owner + Coordinator） | 全文复读 |
| `ResponsiveRimePipeline.swift`（R1 bed，R2 复用） | 全文复读；双水印 / epoch / fail-closed 仍在 |
| `KeyboardController.swift`（gate / rebuild / visibility abandon） | 复读 |
| `KeyboardController+RimeRecovery.swift`（`scheduleProcessKey` 分支） | 复读 |
| 其他 `KeyboardController+*.swift` 中的 `rimeEngine.*` 旁路 | 广域 grep 复读 |
| `ResponsiveRimeR2CoordinatorTests.swift` | 全文复读 |
| ADR 0025（尤其 §10 isolation plan、§11 epoch） | 复读；Status 仍为 **Proposed** |
| PD `T9-RESPONSIVE-PIPELINE-001-authorization.md` R2 段 | 复读 |
| Assignment / Plan R2 / Evidence `t9-responsive-pipeline-r2-2026-07-30.md` | 复读 |
| Extension 是否 force-on gate | **否**（`Keyboard/` 无引用；仅测试显式 `= true`） |
| `@unchecked Sendable` 绕过 | **未使用**（仅文档注释提及禁止） |
| Release default | `isResponsiveRimePipelineEnabled = false` 源码默认成立 |

**R2 交付物边界（按 Product 授权，而非 Assignment 表里较宽的 “all session APIs” 字面）：**

- default-off gate
- `SerialRimeSessionOwner` + `ResponsiveRimeSessionCoordinator`
- 中文 composition 热路径 `processKey` → `scheduleProcessKey`（accept 后 MainActor deferred drain）
- visibility **abandon** 时 bump pipeline epoch
- R2 协调器测试
- 不 Accept ADR 0025；不改 Release default

---

## Findings

### P0

None.

Release 默认仍走 ADR 0004 同步 `rimeEngine` 路径；gate-on 缺陷不会在默认配置下自动激活。

### P1（条件项 / 架构残留；不得粉饰为已关闭）

#### P1-1 — Gate ON 时并非真正的 “single serial owner”

ADR 0025 §10.3 要求：所有 session API 进入**同一** owner，禁止 “队列在别处跑、这一处仍直接打 MainActor engine” 的逃生口。

**源码事实（gate ON）：**

- 可打印 composition 键：经 `ResponsiveRimeSessionCoordinator.scheduleProcessKey` → pipeline 队列 → 延迟 `processNext` → `engine.processKey`
- **大量其他路径仍直接** `rimeEngine.*` / `engine.*`，包括但不限于：
  - Delete（`KeyboardController+TextEditing`）
  - Candidate select / reset（`+Candidates`）
  - Path `replaceInput`（`+T9PinyinPath`）
  - Partial commit / restore（`+PartialCommit`、`+RimeRecovery.restoreRimeComposition`）
  - Auto-anchor `replaceInput` / `resetSession`（`+T9ReversibleAutoAnchor`）
  - Mode / suspend / resume / 部分 visibility（`KeyboardController`）
  - 热路径**之前**的 `engine.isComposing()`、restore、auto-anchor 拒绝检查（`handleInsertKey` 前半段）

同一 `RimeEngine` 实例被 **deferred queue** 与 **同步旁路** 同时使用。因整体仍在 `@MainActor`，这不是 Swift 6 数据竞争，而是**有序性 / 会话一致性竞争**：

1. `scheduleProcessKey("n")` 入队但 drain 未跑  
2. 用户 Delete → 同步 `engine.deleteBackward()`  
3. 随后 drain 执行 `processKey("n")` → engine 状态与用户因果顺序相反  

Executor evidence 已诚实承认 non-key 路径仍 sync 于同一 engine（R3 residual）。  
**Architecture 判定：** 在 gate ON 语义下，**不得**声称 “single serial owner 已实现”。Owner 类型存在，但生产接线只覆盖 processKey 热路径子集。  
**条件：** R3 前必须把 dual-entry 列为开放 Architecture residual；任何 “all session APIs serialized” 的宣传句式都应撤回或降级为 “key path only”。

#### P1-2 — 异步 publish 没有到达 Extension 的 effect / 重绘通道

`scheduleProcessKey` 回调调用 `applyResponsivePublishedSnapshot` → `applyRimeOutput`，**只改 Core state**。

`handleInsertKey` 在 gate 分支立即返回的 effects **通常不含** 因 RIME 结果产生的 `.compositionChanged`（注释写 “compositionChanged may fire again when the snapshot arrives”，但到达时**没有**再次向 UI 层返回 / 推送 `KeyboardEffect`）。

Extension 侧 `syncUI(with:)` 依赖 `handle` 同步返回的 effects（见 `KeyboardViewController+Presentation.syncUI`）。因此 gate ON 时：

- `handle` 可在 librime 前返回（测试覆盖的点）  
- 延迟 snapshot 落地后，**marked text / candidates / Path 栏未必刷新**

这直接削弱 Product 方向 “结果可稍后出现” 的闭环。R2 授权的是 wiring + deferred key path，不是完整 UI 合同；但作为架构审查，**publish→UI 通道缺失是真实缺口**，不能当作 “已可 Debug 验证主观不卡”。  
**条件：** R3/后续接线必须定义 MainActor 上的二次 effect 通知或等价观察点；在关闭前不得把 gate-on 路径描述为端到端可用。

#### P1-3 — Deferred MainActor drain 与 ADR 0025 §10 “off-MainActor serial owner” 目标仍不对齐

ADR §10.2 冻结的生产 owner 形态是：

1. `actor`，或  
2. single-consumer serial executor  

且表意是：enqueue 在 MainActor，**执行 session 在 RIME owner**，MainActor 热路径不等待 librime。

R2 实现是：**单消费者但整条链路仍 `@MainActor`**，用 `DispatchQueue.main.async` 把 `processNext` 推迟到下一 turn。Product 授权与 evidence 对此 isolation honesty 写得很清楚，且正确拒绝了 `@unchecked Sendable` 把非 Sendable `RimeEngine` 送进后台 actor。

**残留效果：**

- `handle` 对**当前**键可先返回（accept 不同步执行 engine）— 与 R1 bed 一致  
- 一旦 drain turn 开始执行长 `process_key`，**MainActor 仍被占用**；后续 touch/`handle` 仍会排在该次 librime 之后  
- 多键 burst 可在 drain 开始前批量 accept，并在 key 与 key 之间 yield 一次 async turn，但**单次尖峰仍冻结 UI 线程**

因此 R2 是 **“热路径返回时机”** 的改善，**不是** Product 问题陈述中的 “按键永不因 engine 尖峰卡住” 的充分解。  
**条件：** 保持为 Architecture 开放 residual；不得把 R2 写成 ADR 0025 Accept 就绪；真正 off-main 需要后续 Architecture 批准的 thread-confined 设计（仍禁止 `@unchecked Sendable` 穿梭）。

### P2

1. **`performOrderedNow(.replaceInput…)` 在 gate ON 的符号页续写路径上仍同步执行 engine**  
   `handleInsertKey` 在 responsive 分支对 symbol continuation 走 `performOrderedNow`（accept + 立即 `processNext`），与 “key path deferred” 不一致；该子集仍阻塞 `handle`。

2. **Visibility 覆盖不完整**  
   - `abandonCompositionForVisibilityChange`：gate ON 时 `coordinator.bumpSessionEpoch(resetEngineSession: true)` — 对齐 §11 caller bump  
   - `resetRimeSessionForVisibilityChange`：仍直接 `engine.resetSession()`，**不** bump epoch  
   - `suspendRimeForVisibilityChange` / `resumeRimeAfterVisibilityChange`：直接 `rimeEngine`，不经 owner  
   - Extension 实际顺序是 **先 suspend、再 abandon**（`suspendKeyboardRuntime`）。同 MainActor 串行下通常安全，但 gate ON 时 lifecycle 并未统一进 serial owner API 表。

3. **`rimeEngine` 替换不触发 coordinator 重建**  
   `rimeEngine` 是普通存储属性；Extension bootstrap 赋值 `controller.rimeEngine = engine` **不**调用 `rebuildResponsiveRimeCoordinatorIfNeeded()`。`handleInsertKey` 仅在 `coordinator == nil` 时 lazy rebuild。gate ON 且已有旧 coordinator 时可能绑死旧 engine 引用。

4. **Async 路径丢失同步路径后处理**  
   `applyResponsivePublishedSnapshot` 不做 auto-anchor 推进、focused segment retain、reject-after-key 等；`refreshT9PinyinPathsAfterResponsivePublish` 实质为空操作。gate ON 的 T9 Path / auto-anchor 行为与 gate OFF 不等价（R3 范围，但架构上是 dual-path 漂移源）。

5. **生产选择路径未绑定 revision / 未调用 `validateSelection`**  
   Owner/pipeline 的双水印与 fail-closed API **存在**；Candidates / Path 生产处理仍直接 `engine.selectCandidate` / `replaceInput`，不携带 `(epoch, revision)`。不得声称 “生产 fail-closed 选择合同已接线”。

6. **R2 测试未覆盖 dual-entry 竞态**  
   覆盖了 default-off、schedule 不阻塞、有序多键、controller gate deferred、epoch bump、performOrdered delete、owner 级 stale selection。  
   **未**覆盖：gate ON 下 `scheduleProcessKey` 未 drain 完成时同步 Delete/select/Path；未覆盖 publish→UI effect；未覆盖 visibility suspend 与 pending drain 交错。

### P3

1. **`completedPublishCount` 命名易误导** — `drainLoop` 在每次 `processNext() == true` 时递增，含 stale skip / coalesce 未 publish 的情况，不是 “成功 UI publish 次数”。  
2. **pending 队列无界** — R1 起即存在；Extension 长卡时 jetsam 风险仍在 ADR Consequences 中，R2 未加策略（需度量后由 Product 定，与 Assignment 一致）。  
3. **`ResponsiveRimePipeline` 文件头注释仍偏 R1 口吻**（“R2 must place real librime behind actor…”）— 与已落地的 MainActor R2 略脱节，易误导后续读者；应在 R3 文档整理时对齐 isolation honesty。

---

## Contract alignment

| 问题 | 判定 |
|---|---|
| 1. R2 是否落在 Product 授权内（default-off、不 Accept ADR、无 `@unchecked Sendable`）？ | **是。** gate 默认 `false`；ADR 仍 Proposed；无隔离绕过；无 Extension force-on。 |
| 2. Gate ON 时 “single serial owner” 是否为真？ | **否（子集）。** Owner/Coordinator 存在，但生产仅 key 热路径入队；其余仍 sync 打同一 `rimeEngine`。 |
| 3. Deferred MainActor drain vs ADR §10 off-MainActor owner？ | **有意偏离 + 已记录 residual。** 符合 Swift 6 禁 `@unchecked Sendable` 的务实 R2；**未**满足 §10 最终形态。 |
| 4. 双水印 / fail-closed / epoch 是否仍成立？ | **在 pipeline/owner 内：是。** `lastApplied` vs `lastPublished`、`validateSelection`、epoch bump（含 abandon）保持。**在生产 UI 接线：否（未接）。** |
| 5. `scheduleProcessKey` 与 sync `rimeEngine` 竞态？ | **Gate ON 时存在逻辑竞态（P1-1）。** 非跨线程 data race；是因果顺序缺陷。 |
| 6. Visibility bump 完整性？ | **仅 abandon 完整。** suspend/resume/`resetRimeSessionForVisibilityChange` 未统一进 owner / epoch 表。 |
| ADR 0004 默认路径 | **Gate OFF 保持同步 MainActor session（Release）。** |
| 有序输入、不丢键（pipeline 内） | **Coordinator/pipeline 内保持。** dual-entry 可破坏全局用户因果。 |
| Content-free 诊断边界 | R2 未引入 raw input 日志；fixture ID 路径可接受。 |

### 对 Review questions 的直接回答

1. **授权边界：** 通过（Pass 条件的前提）。  
2. **Single serial owner：** 类型层有、接线层**不完整** → P1-1。  
3. **§10 对齐：** 务实 R2 + 明确 residual → P1-3；**非** Accept 就绪。  
4. **双水印 / fail-closed / epoch：** 状态机内持有；生产选择未接线 → 合同半持有。  
5. **Race：** 确认存在（gate ON）→ P1-1 / P2-6。  
6. **Visibility：** abandon 有 bump；全表未齐 → P2-2。

---

## Conditions (if any)

在 **不授权 R3+** 的前提下，本审查 **Pass with conditions** 要求：

1. **不得**在导航、Plan、Assignment 状态句中声称 “R2 已实现全部 session API 串行化 / single serial owner 完成”。应写为：**default-off deferred processKey path + MainActor single-consumer owner 类型；full API coverage = R3 residual**。  
2. **P1-1 / P1-2 / P1-3** 保持为 Architecture 开放项；进入 R3 设计时必须显式处理：  
   - 全 session API 入同一 owner（或 gate ON 时禁止 sync 旁路）  
   - publish → UI effect / 观察通道  
   - off-MainActor 或证明 MainActor deferred 满足（不满足则不得 Accept ADR）  
3. **不得**把本文件当作 ADR 0025 Accept、Quality Pass 或 Product Gate。  
4. gate ON 的端到端可用性、Delete/select/Path/recover 合同、设备主观不卡 — **全部未在本审查中证明**。  
5. 独立 Quality 审查仍应单独进行（本文件不替代测试充分性 / 全量 suite 结论）。Executor 声称 `swift test` 808 绿 — **未在本 Architecture 审查中复跑**，不采信为 Quality Pass。

---

## Explicit non-claims

- **Not** Product Gate  
- **Not** Quality Pass  
- **Not** ADR 0025 Accepted  
- **Not** R3+ authorization  
- **Not** Release default-on  
- **Not** 证明真实设备九宫格长句主观不卡  
- **Not** 证明 gate ON 下 Delete / candidate / Path / recover 合同正确  
- **Not** 证明 Extension 在 deferred publish 后 UI 必然刷新  
- **Not** 关闭 off-MainActor librime Architecture residual  

---

## Evidence binding (reviewer)

| Source | Path |
|---|---|
| Owner / Coordinator | `Packages/KeyboardCore/Sources/KeyboardCore/SerialRimeSession.swift` |
| R1 bed (watermarks) | `Packages/KeyboardCore/Sources/KeyboardCore/ResponsiveRimePipeline.swift` |
| Gate / abandon | `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController.swift` |
| Deferred key branch | `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+RimeRecovery.swift` |
| R2 tests | `Packages/KeyboardCore/Tests/KeyboardCoreTests/ResponsiveRimeR2CoordinatorTests.swift` |
| ADR | `docs/architecture/decisions/0025-responsive-rime-serial-input-pipeline.md` |
| Product Decision | `docs/product-decisions/T9-RESPONSIVE-PIPELINE-001-authorization.md` |
| Executor evidence | `docs/evidence/t9-responsive-pipeline-r2-2026-07-30.md` |

**方法：** 对抗性源码复读 + 授权/ADR 对照；**未**复跑 `swift test`；**未**设备验证。

---

## Executor P1 remediation addendum (2026-07-30)

| ID | Status after remediation |
|---|---|
| P1-1 dual-entry | **Remediated (gate on):** `ResponsiveRimeEngineBridge` installs as `rimeEngine`; `performOrderedNow`/`flushPending` drain full queue; Delete after pending keys tested |
| P1-2 publish→UI | **Remediated:** `onResponsivePresentationNeeded` + Extension `syncUI` wiring; controller test asserts `.compositionChanged` |
| P1-3 off-MainActor | **Still open** (Swift 6 / no `@unchecked Sendable`); deferred MainActor drain residual remains |

This addendum is **not** an independent Architecture re-Pass.
