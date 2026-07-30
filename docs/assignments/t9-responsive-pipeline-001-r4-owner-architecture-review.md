# Architecture Review: T9-RESPONSIVE-PIPELINE-001 / R4-Owner

**Reviewer role:** 🏛️ Architecture & Knowledge Steward（独立 subagent；对抗性结构审查）  
**Date:** `2026-07-31 Asia/Shanghai`  
**Assignment:** [`T9-RESPONSIVE-PIPELINE-001`](t9-responsive-rime-pipeline-001.md)  
**Phase:** R4-Owner — design freeze + disconnected owner implementation  
**Product authority:** [`PD-T9-RESPONSIVE-PIPELINE-001`](../product-decisions/T9-RESPONSIVE-PIPELINE-001-authorization.md) § R4-Owner  
**Design freeze:** [`t9-responsive-pipeline-001-r4-owner-design.md`](t9-responsive-pipeline-001-r4-owner-design.md)  
**ADR:** [`0025`](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md) — **Status remains `Proposed`（本审查不 Accept）**  
**Predecessor residuals:** Spike-P1-3 Architecture re-review P2-1 / P2-2 / P2-3  
**Sources reviewed (working tree, not only docs):**

| Artifact | Role |
|---|---|
| `Packages/KeyboardCore/Sources/KeyboardCore/ThreadAffineRimeSpike.swift` | R4-Owner 实现（权威） |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/ThreadAffineRimeSpikeTests.swift` | 结构可证伪性（测试形态；绿条归 Quality） |
| R4-Owner design freeze | D1 / D2 / D3 合同 |
| PD R4-Owner 授权段 | 产品边界与 non-claims |
| Spike Arch re-review P2 段 | 关闭目标 |
| `docs/evidence/t9-responsive-pipeline-r4-owner-2026-07-31.md` | Executor 叙事（**不**采信为 Arch Pass） |
| `KeyboardController` gate / coordinator 引用 | 确认未接线 |

**Verdict:** **Pass with conditions**

| Severity | Count |
|---|---|
| P0 | 0 |
| P1 | 0 |
| P2 | 3（均为 **后续阶段 residual**，不重开 R4-Owner D1–D3 Fail） |
| P3 | 4 |

> **判定原则：** 只根据源码结构是否兑现 design freeze 的 D1–D3；不以 Executor evidence 绿条代替结构审查；Quality 拥有测试执行与诚实证据；本文件 **不** 声称 ADR Accept、Product Gate、R4-B real librime、Release default-on。

---

## 1. Scope of this review

**In scope**

- D1：config-only Sendable bootstrap；engine 仅在 owner thread 物化
- D2：单一有序 MainActor delivery + terminal acknowledgement
- D3：有界 work mailbox、refuse-at-bound、control-priority stop/epoch、不丢已 accept 的 process-key FIFO
- 与 Spike-P1-3 三个 Arch P2 residual 的关闭关系
- 隔离边界：无 production wiring、无 `@unchecked Sendable`、无 ADR Accept 副作用

**Out of scope（不得借本 Pass 偷渡）**

- R4-B 真实 `RimeEngineImpl` / librime Simulator 矩阵
- Extension 可见性生产生命周期（deinit 仍只是 safety net）
- ADR 0025 Accept / Product Gate / Release default-on
- 完整 RimeEngine API 面生产路由（Delete / Path / select / page / recover）
- 本机 `swift test` 执行与绿条证明（**Quality**）
- 设备 jetsam 数字 / Product SLO 数值

---

## 2. Spike P2 residual disposition

| Spike residual | R4-Owner 目标 | 源码结论 |
|---|---|---|
| **P2-1** factory 可走私 live engine | D1 config-only bootstrap | **Closed（R4-Owner 合同范围）** — 见 §3.1 |
| **P2-2** 无序 `Task { @MainActor }` fan-out | D2 单一有序 delivery + terminal | **Closed** — 见 §3.2 |
| **P2-3** 无界 mailbox；stop/epoch 埋在 backlog 后 | D3 有界 + control priority + refuse | **Closed** — 见 §3.3 |

说明：Spike 原文中 “concrete RimeBridge bootstrap” 被 Product 拆成 **R4-Owner（合同）** 与 **R4-B（真实 librime）**。R4-Owner design 明确：D1 以 Fake bootstrap + 类型/文档不变量关闭；真实 bridge bootstrap 属 R4-B。本审查按该冻结范围结案 P2-1，不把 R4-B 证据缺失升格为 R4-Owner Fail。

---

## 3. D1 / D2 / D3 结构判定

### 3.1 D1 — Bootstrap is config-only — **Closed for R4-Owner**

**Freeze 要求：**

1. Bootstrap 为 `Sendable` 值/不可变包装  
2. 不得持有 live `RimeEngine` / session handle  
3. `makeEngineOnOwnerThread()` 仅在 owner loop 起点调用一次  
4. Fake bootstrap 允许（创建仍必须在 owner 上）  
5. 引擎不得进入 mailbox / MainActor / bootstrap 存储

**源码事实（`ThreadAffineRimeSpike.swift`）：**

```text
ThreadAffineRimeEngineBootstrap: Sendable
  └─ makeEngineOnOwnerThread() -> any RimeEngine

ThreadAffineRimeSpikeOwner.init
  └─ Thread { runOwnerLoop(bootstrap:) }
       └─ let engine = bootstrap.makeEngineOnOwnerThread()  // local only
            // engine 从不写入 mailbox / delivery / AcceptanceState
```

- 公开协议 `ThreadAffineRimeEngineBootstrap` + 文档 invariant（config/recipe only）。
- `ThreadAffineRimeSpikeEngineFactory` 保留为 **typealias**（符合 freeze 的迁移兼容）。
- Preferred API：`init(bootstrap:configuration:resultHandler:)`。
- Owner loop 内 `let engine = …` 为线程闭包局部变量；mailbox 仅含 `Sendable` envelope/control。
- 未见 `@unchecked Sendable`。

**类型系统诚实边界（不构成 Fail）：**

- 协议无法在编译期禁止“Sendably 包装的邪恶工厂”；靠 `Sendable` + 文档 + 审查纪律。
- 无生产 `RimeEngineImpl` 路径/schema/App Group 的 bootstrap 实现 — **按 design 属 R4-B**，记入 §5 P2-later-1。

**测试形态（结构）：**  
`SpikeFakeRimeEngineFactory` / `SpikeLifecycleProbeEngineFactory` 在 `makeEngineOnOwnerThread` 内 `init` probe；lifecycle 测试要求 init/process/deinit 同线程。足以证伪“MainActor 预建 engine 再塞进 owner”的错误形状。

**结论：** D1 在 R4-Owner 冻结范围内 **结构关闭**。

---

### 3.2 D2 — Single ordered delivery + terminal barrier — **Closed**

**Freeze 要求：**

1. 单一有序 channel；禁止 per-result 无汇合点的 `Task` fan-out  
2. 交付顺序 = owner 执行完成顺序  
3. ApplyGate 拒绝仍消耗 delivery slot  
4. Owner 退出后 terminal；可 `waitUntilDeliveryDrained` / `isTerminal`  
5. Hot-path `accept` 永不等待 drain  
6. 允许 coalesced 单泵 `Task { @MainActor in pump() }`

**源码事实：**

- `ThreadAffineRimeDeliveryChannel`：单一 `queue: [ThreadAffineRimeSpikeResult]` + `Mutex`。
- `enqueue` 仅在 `!pumpScheduled` 时 `schedulePump()` → 一个 coalesced MainActor 泵。
- `pump()` 在 MainActor 上 FIFO `removeFirst` 后调用 **同一个** `handler`，再 `deliveredCount &+= 1`。  
  → ApplyGate 拒绝发生在 handler 内时，**仍递增 deliveredCount**（满足 “consume a delivery slot”）。
- `markOwnerLoopExited()`：queue 空则立即 terminal；否则泵排空后 terminal。
- `waitUntilDeliveryDrained` / diagnostics `isDeliveryTerminal` 暴露终态。
- Owner 线程：`processKey` → `delivery.enqueue` → 串行；无 per-result 独立交付 Task。
- `accept` 路径无 drain 等待。

**Shutdown 序列对照 design §D2.4：**

| Step | 实现 |
|---|---|
| 1 `requestStop` 幂等 → control stop | `stopped` 门闩 + `enqueueControl(.stop)` |
| 2 owner 按 D3 处理 stop | control 优先；`abandonAllWork` |
| 3 释放 local engine | 闭包结束释放 `engine` |
| 4 mailbox stopped | `signalStopped()` |
| 5 delivery terminal | `markOwnerLoopExited()` 后泵排空 |

**结论：** Spike P2-2 的“无序 fan-out / 无 terminal”失效模式 **结构关闭**。  
**非 Fail 残留：** delivery 队列本身无界 — 见 §5 P2-later-2（生产 backpressure；非 D2 关闭条件回退）。

---

### 3.3 D3 — Bounded mailbox + control priority + refuse-at-bound — **Closed**

**Freeze 要求：**

| 规则 | 源码 |
|---|---|
| Work / Control 双车道 | `State.work` + `State.control` |
| Control 优先于 Work | `next()` 先 `control.removeFirst` |
| `pendingWorkDepth` 只计 work | `work.count` |
| `maxPendingWorkDepth` 可配置 | `ThreadAffineRimeOwnerConfiguration`（默认 64，`precondition > 0`） |
| 超界 **refuse**（`nil`，计数，不入队，不丢已入队） | `tryEnqueueWork` / `accept` → `rejectedAtBoundCount` |
| stop / epoch **不受** work bound | `enqueueControl` 无 bound 检查 |
| epoch：owner 先 reset + 更新 `ownerEpoch`；错 epoch 不执行 | `.advanceEpoch` → `engine.resetSession()` + `ownerEpoch = epoch`；work 路径 `guard envelope.sessionEpoch == ownerEpoch` |
| 允许 purge 已入队 stale work | MainActor `advanceSessionEpoch` + owner 上二次 `purgeWork`；计入 `skippedStaleEpochCount` |
| stop 不中断 in-flight；不排空历史 backlog；`abandonedAtStopCount` | in-flight 跑完再 `next()`；stop 后 `abandonAllWork` + `return` |

**与产品“已 accept 的 process-key 不 drop/merge/reorder”对齐：**

- 已入队 work 不会为腾位子被删除（仅 refuse 新 accept；或 **epoch 失效** / **stop 生命周期 abandon** — 二者在 freeze 中明确定义为 discard/lifecycle，非 live composition 输入丢弃）。
- Work 车道严格 FIFO；Control 不重排 work-to-work 顺序。

**测试形态（结构）：**

| 测试 | 对应 freeze 证明点 |
|---|---|
| `testRefuseAtBoundDoesNotDropAcceptedWork` | refuse-at-bound；已 accept 仍交付 |
| `testOrderedDeliveryAndTerminalBarrierAfterStop` | 有序交付 + terminal |
| `testControlPriorityStopIsNotBuriedBehindWorkBacklog` | stop 不被 backlog 活埋；`abandonedAtStopCount > 0`；仅 in-flight 执行 |
| 保留 Spike accept-during-stall / FIFO / epoch / lifecycle / gate-off | 回归不变量 |

**结论：** Spike P2-3 **结构关闭**。Jetsam **政策钩子与计数器**存在；设备数字 **不** 声称（符合 freeze §Jetsam note）。

---

## 4. Isolation / boundary checks

| Check | Result |
|---|---|
| `@unchecked Sendable` in owner source | **None** |
| Engine 出现在 mailbox / delivery / MainActor 存储 | **No** — 仅 owner 局部 `let engine` |
| `KeyboardController` / Extension 接线 | **No** — 测试 `testSpikeIsNotWiredAndGateOffRemainsSynchronous` 断言 gate off 同步路径；`isResponsiveRimePipelineEnabled` 默认 false；coordinator 仍为 R2/R3 MainActor 路径 |
| 公开面 processKey-first | **Yes** — `ThreadAffineRimeSpikeWork` 仅 `.processKey`；类型文档写明其余 API 延后 |
| ADR 0004 生产默认 | **Unchanged** — 本刀未改 Release 默认 |
| deinit | **Safety net only** — `requestStop()`；显式 `shutdown()` 仍是正确生命周期入口 |

---

## 5. Findings

### P0

None.

### P1

None。R4-Owner D1–D3 在冻结范围内无结构级阻塞缺陷。

### P2 — later-phase residuals（不构成 R4-Owner Fail）

#### P2-later-1 — 真实 RimeBridge / `RimeEngineImpl` bootstrap 仍未实现

**事实：** D1 以协议 + Fake/probe bootstrap 关闭合同；无 paths/schema/App Group 的生产 bootstrap。  
**为何不是 Fail：** design §7 / PD R4-Owner 明确真实 bootstrap 属 **R4-B**。  
**Remediation（R4-B 授权后）：** 提供仅含配置的 bootstrap，在 owner 线程构建 bridge session；证明无 MainActor 预建 live engine。

#### P2-later-2 — Delivery channel 无界（MainActor 停滞时的背压）

**事实：** Work mailbox 有界，但 owner 完成并 `delivery.enqueue` 后 work 槽释放；若 MainActor 泵不及时，**delivery 队列可增长**，而 accept 仍可能继续。  
**为何不是 Fail：** D2/D3 freeze 要求的是 work 有界 + 有序交付 + terminal，未要求 delivery 有界。  
**生产风险：** jetsam / 内存压力从 work 队列部分转移到 delivery 快照队列。  
**Remediation（接线前设计）：** delivery 深度诊断、与 accept 的联合背压、或 snapshot coalesce 策略（仍遵守“不丢已 accept 的 **输入执行**”；UI publish coalesce 是另一层产品合同）。

#### P2-later-3 — Extension 生命周期与全 session API 入口仍未产品化

**事实：** deinit safety net 保留；Delete/Path/select/page/recover/runtime-selection 未进入 owner；R2/R3 gate 路径仍为默认生产实验面。  
**为何不是 Fail：** R4-Owner 授权与 design §5 明确 processKey-first + 仅 **命名** 后续入口规则。  
**Remediation：** 未来 Product 授权的接线阶段（R4-B+ / 迁移刀）必须：显式 visibility suspend/finalize；全 mutation API 进同一 owner；runtime-selection 仅 Sendable 快照经 delivery。

### P3

1. **命名债务：** 公开类型仍大量 `ThreadAffineRimeSpike*`；design 首选 `ThreadAffineRimeOwner`。Freeze 允许 “names may vary / typealias 迁移”。建议在接线前完成 rename 或稳定 typealias，避免 Spike/R4 语义混淆。  
2. **`Array.removeFirst` O(n)：** work/control/delivery 均用数组头删；有界后可接受；高深度时可改为 deque。非正确性。  
3. **线程身份探针：** 仍用 `ObjectIdentifier(Thread.current)` / `hashValue`；Fake 足够；真机探针可换稳定 thread id（继承 Spike P3）。  
4. **`waitUntilStopped` 单次 `stoppedSignal`：** 二次等待可能超时除非已停止语义另查；测试 API 边界，非热路径。

---

## 6. Conditions of Pass

本 **Pass with conditions** 绑定以下条件；违反任一条则不得把本审查当作 R4-Owner 完成或后续阶段授权：

1. **Quality 独立复跑** focused `ThreadAffineRimeSpikeTests` + full KeyboardCore，并出具自己的 Pass/Fail 与证据；Architecture **不** 声称本机绿条。  
2. **解释边界（强制 non-claims）** — 见 §7；任何把本文件写成 ADR Accept / Product Gate / R4-B / Release default-on 的叙述均属越权。  
3. **P2-later-\*** 必须在 **生产接线 / R4-B** 前被单独设计或接受，不得假设“R4-Owner Pass = off-main 生产就绪”。  
4. Working tree 若在审查后改动 D1–D3 语义（尤其是 silent drop accepted work、去掉 terminal、取消 control priority、引入 `@unchecked Sendable`、接入 Extension），本 Pass **作废**，需 re-review。

---

## 7. Explicit non-claims

| Claim | 本审查 |
|---|---|
| ADR 0025 **Accept** | **否** — 保持 **Proposed** |
| Product Gate | **否** |
| R4-B real librime / Simulator 矩阵 | **否** |
| Release / 用户设置 default-on | **否** |
| `KeyboardController` / Extension / `RimeEngineImpl` 生产接线 | **否** — 未接线 |
| 关闭全局 **`P1-3-off-main`**（真实 off-main 生产 owner） | **否** — 仅关闭 Owner **合同** residual；生产 off-main 仍待 R4-B+ 与 ADR Accept 路径 |
| 完整 RimeEngine API 面 | **否** — processKey-first |
| UIKit / marked text / Path / candidates 原子事务 | **否** |
| 设备 jetsam / 延迟 SLO 数字 | **否** — 仅有 policy hooks + counters |
| 本机 test 绿条 / 826 passed | **否** — Executor 叙事不采信；**Quality** 拥有 |
| 本审查授权下一步实现 | **否** — 仅结构判定；R4-B 需 Product 另授 |

---

## 8. Evidence honesty note

`docs/evidence/t9-responsive-pipeline-r4-owner-2026-07-31.md` 报告 focused 10 / full 826 绿条。  
Architecture **已读**该文件以了解 Executor 声称范围，但：

- **不**把该文件当作本 Pass 的证明；
- **不**复述或担保命令输出；
- 独立 Quality 必须重跑并核对 non-claims 是否与源码一致。

---

## 9. Recommended next

1. **🧪 Quality independent review**  
   - `swift test --package-path Packages/KeyboardCore --filter ThreadAffineRimeSpikeTests`  
   - full KeyboardCore  
   - 扫描 `@unchecked Sendable`、production wiring、gate default  
   - 核对 evidence non-claims 与 delivered/abandoned/rejected 计数语义  
2. Dual Pass（或 Quality 条件与本文件不冲突）后，**Product Lead** 决定是否授权 **R4-B**（真实 librime / Simulator），并单列 P2-later-1/2/3。  
3. **ADR 0025** 保持 Proposed，直至独立 Architecture **acceptance** 审查 + 授权实现 + 证据链完整。  
4. 可选文档：在 ADR 0025 / Assignment 中链到本 review；**不要**把 R4-Owner 写成 off-main 生产完成。

---

## 10. Verdict summary

| 项 | 结论 |
|---|---|
| D1 bootstrap（R4-Owner 合同） | **Closed** |
| D2 ordered delivery + terminal | **Closed** |
| D3 bounded mailbox + control priority + refuse | **Closed** |
| Spike Arch P2-1 / P2-2 / P2-3 | **Closed within R4-Owner scope** |
| P0 / P1 | **0** |
| P2 later-phase | **3**（bootstrap 真实化、delivery 背压、Extension/API 接线） |
| P3 | **4** |
| ADR 0025 / Gate / R4-B / Release default-on | **全部不授权、不声称** |

### Final verdict

**Architecture review: Pass with conditions**

R4-Owner design freeze 的 D1–D3 在 working-tree 源码中结构兑现；Spike 三个 Arch P2 residual 在 **Owner 合同范围**内关闭。条件见 §6；后续真实 librime、delivery 背压与 Extension 接线不得由本 Pass 暗示完成。
