# Architecture Re-review: Spike-P1-3 remediation

**Review type:** Independent Architecture re-review（对抗性 / 独立）  
**Role:** 🏛️ Architecture & Knowledge Steward  
**Date:** 2026-07-31 Asia/Shanghai  
**Parent Assignment:** [`T9-RESPONSIVE-PIPELINE-001`](t9-responsive-rime-pipeline-001.md)  
**Prior Fail:** [`t9-responsive-pipeline-001-spike-p1-3-architecture-review.md`](t9-responsive-pipeline-001-spike-p1-3-architecture-review.md) @ immutable `45c426f`  
**Scope:** 当前 working tree 相对 `45c426f` 的 lifecycle P1 remediation（源码 + 测试；不以文档自述为证据）  

**Verdict:** **Pass with conditions**  
**P0:** 0  
**P1:** 0  
**P2:** 3  
**P3:** 2  

> **明确不声明：** 不 Accept ADR 0025；不声称 Product Gate；不授权 R4；不将 Spike 升为 Release default-on；不声称 real librime / device / jetsam 证明；不替代独立 Quality 复审。

---

## 复读范围（源码优先）

| Artifact | Result |
|---|---|
| `Packages/KeyboardCore/Sources/KeyboardCore/ThreadAffineRimeSpike.swift` | 全文复读 |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/ThreadAffineRimeSpikeTests.swift` | 全文复读 |
| 原 Arch Fail @ `45c426f` | 对照 required remediation 5 项 |
| 原 Quality Fail（150 ms / omitted shutdown） | 对照交叉证据 |
| `docs/assignments/t9-responsive-pipeline-001-spike-p1-3-design.md` | 对照 lifecycle 合同表述 |
| ADR 0025 | Status 仍 **Proposed**；本审查不 Accept |
| Controller / Extension / `RimeEngineImpl` 接线 | Spike 仍断开（`testSpikeIsNotWiredAndGateOffRemainsSynchronous` 仍在） |

本复审**未**将 evidence 绿条或 Executor 叙述当作 Architecture Pass；lifecycle 结论建立在当前 working-tree 源码结构与测试断言上。  
本复审**未**在本机重新执行 `swift test`（既有 evidence 写明 remediation 后测试曾因 sandbox 配额未跑通）。执行面绿条留给 Quality；结构面可独立判定。

---

## Original P1 disposition

| Original P1 | Closed / Still open | Evidence（working tree，非仅文档） |
|---|---|---|
| **P1 — omitted `shutdown()` 使 owner thread + thread-local engine 永久孤儿** | **Closed** | 见下「P1 闭环核验」 |

### P1 闭环核验（对照原 Fail 的 5 条 remediation）

| # | Required remediation | Working-tree 事实 | 判定 |
|---|---|---|---|
| 1 | 幂等、线程安全的 `requestStop()` | `private func requestStop()`：`acceptanceState` `Mutex` 上 `stopped` 只允许第一次置位并 `enqueue(.stop)`；后续调用 no-op | **Met** |
| 2 | 显式 `shutdown()` 与非阻塞 `deinit` 均调用它 | `shutdown()` → `requestStop()`；`deinit` → `requestStop()`（注释明确 deinit 不阻塞、仅 safety net） | **Met** |
| 3 | omitted-shutdown 回归 | `testOwnerDeinitStopsThreadAndDestroysEngineWhenShutdownIsOmitted`：`owner = nil` 后 `waitForDeinit()`，断言 `deinitThread == initThread` | **Met** |
| 4 | lifecycle probe：init / process / deinit 同一 owner thread | `SpikeLifecycleProbeRimeEngine` + `SpikeEngineLifecycleRecorder` + `assertSingleOwnerThread`；用于 blocked accept、epoch、explicit shutdown 等用例 | **Met** |
| 5 | 澄清 stopped barrier 做什么 / 不做什么 | 行为可从源码推出：`.stop` 为 FIFO 命令；`stopped=true` 后 `accept`/`advanceSessionEpoch` 返回 `nil`；pre-stop backlog **仍会** 被消费；in-flight `processKey` **不被** 中断；`runOwnerLoop` 返回后本地 `engine` 释放，再 `signalStopped()`。design 文档亦写明 deinit ≠ Extension visibility 政策 | **Met（结构）** |

**对抗性检查（不应重开为 P1）：**

| 场景 | 观察 | 为何不是 P1 回潮 |
|---|---|---|
| `shutdown()` 后再 `deinit` | 第二次 `requestStop()` 因 `stopped` 跳过 enqueue | 幂等；无双 stop 竞态 |
| 仅 deinit、无 `waitUntilStopped` | engine 仍在 owner 线程 `runOwnerLoop` 返回后释放；测试用 `waitForDeinit` 观测 | 销毁异步但可达；原失效是“永久孤儿” |
| stop 排在 backlog 之后 | 与原 P2 unbounded mailbox 同一形状；pre-stop work 会先执行 | 原 Fail 针对“无 stop 入口”，不是 backlog 策略 |
| in-flight 阻塞永不返回 | `waitUntilStopped` / deinit 等待会超时；engine 不释放 | Fake 可控；真实 librime hang 属 R4 风险，非 Spike lifecycle 入口缺失 |
| deinit 只是 safety net | 注释与 design 均要求未来 Extension 显式 visibility suspend/finalize | 符合原 Arch 要求；未把 deinit 伪装成生产生命周期政策 |

---

## Confirmed isolation shape

相对 `45c426f` 已确认、remediation **未破坏** 的隔离形状：

1. **无** `@unchecked Sendable` / `nonisolated(unsafe)` isolation 绕过。
2. `engineFactory` 作为 Sendable recipe 进入 dedicated `Thread`；`makeEngineOnOwnerThread()` 在 owner 上调用。
3. 非 Sendable engine 仅为 `runOwnerLoop` 局部变量；不进入 mailbox / AcceptanceState / MainActor。
4. MainActor `accept` 只分配 `(sessionEpoch, revision)` 并 enqueue Sendable envelope；**从不** 调 engine。
5. Owner 仅回传 immutable `ThreadAffineRimeSpikeResult`；`ThreadAffineRimeSpikeApplyGate` fail-closed 拒绝错 epoch / 非单调 revision。
6. Spike **未** 接入 `KeyboardController` / Extension / `RimeEngineImpl`；gate-off 仍走同步路径。
7. **新增 lifecycle：** owner 句柄消失时仍能 `requestStop` → 线程退出 → 本地 engine 在 owner 线程销毁；显式 `shutdown()` 同路径。

### Quality 交叉（非本审查关闭 Quality，仅结构观察）

原 Quality P2（150 ms 阻塞在 `beforeEngineCall`、证据措辞过强）：当前阻塞在 `SpikeLifecycleProbeRimeEngine.processKey` 内部（semaphore enter → wait → 再 `delegate.processKey`），**不再** 存在 pre-engine hook 形态。  
原 Quality P1（omitted shutdown）与 Arch P1 同源，结构上已闭环。  
50 ms 上限仍是实验性 falsification 阈值（P3 级噪声风险），**不是** Product SLO。

---

## New findings

### P0
None.

### P1
None。原 Spike lifecycle P1 在当前 working tree **结构关闭**。

### P2（原 residual 原样保留；未关闭）

1. **Sendable factory 不能证明真实 engine 新鲜/非逃逸。**  
   `ThreadAffineRimeSpikeEngineFactory` 仍是协议约定。R4 需要从 **Sendable 配置值** 出发的具体 RimeBridge bootstrap，而不是“工厂应在 owner 上新建”的惯例。

2. **MainActor 交付仍是独立 `Task { @MainActor ... }`。**  
   无单一有序 delivery channel、无 terminal callback barrier。本 Spike 靠 revision 拒绝保护窄证明；R4 需要有序交付 + 终态确认。

3. **mailbox 无界 + `removeFirst`；epoch/stop barrier 排在 backlog 后。**  
   队列/jetsam 与“不丢输入”产品规则下的可见性策略仍是 R4 阻塞项。`requestStop` 不解决 backlog 深度问题。

### P3

1. **线程身份用 `ObjectIdentifier(Thread.current).hashValue`。**  
   对短生命周期 Fake 测试足够；理论上 hash 碰撞极弱风险。R4 真探针可用更稳定的 thread id 表示（非关闭条件）。

2. **stopped 语义主要靠代码路径 + design 段落表达。**  
   `case .stop: return` 本身缺少一句“FIFO drain pre-stop / 不中断 in-flight / 不接受 post-stop work”的源码注释。不影响 P1 关闭；若写 R4 owner 合同，建议把 barrier 语义写进类型文档。

---

## Explicit non-claims

| Claim | 本审查 |
|---|---|
| ADR 0025 Accept | **否** — Status 保持 **Proposed** |
| Product Gate | **否** |
| R4 production wiring 授权 | **否** |
| Release / 用户设置 default-on | **否** |
| real `RimeEngineImpl` / librime 线程亲和 | **否** — 仅 Fake + lifecycle probe |
| Extension visibility suspend/finalize 完成 | **否** — deinit 仅为 Spike safety net |
| 完整 RimeEngine API 面（Delete / Path / page / recover…） | **否** — 仍仅 `processKey` |
| UIKit / marked text / Path / candidates 原子事务 | **否** |
| jetsam / 有界队列政策 | **否** |
| 本机 focused/full `swift test` 绿条 | **否** — 留给 Quality；结构审查不冒充执行证据 |
| 关闭 R3 路径上的 Arch **P1-3-off-main**（真实 off-main librime 生产 owner） | **否** — 本 Spike 只证明 Fake 隔离机制 + lifecycle；生产 off-main 仍是 R4 设计/接线问题 |

命名提醒（原 P3）：本 Spike residual 称 **`P1-3-off-main`**；历史 R1 epoch 映射称 **`R1-P1-3-epoch`**。二者不得混用。

---

## Recommended next

1. **独立 Quality re-review**：在当前 working tree 执行  
   - focused：`swift test --package-path Packages/KeyboardCore --filter ThreadAffineRimeSpikeTests`（预期 7 例量级：原 5 + explicit shutdown + omitted deinit）  
   - full KeyboardCore regression  
   - 扫描 `@unchecked Sendable` / production wiring  
   - 记录不可变 checkpoint SHA  
2. Quality Pass 后，由 Product/Architecture **分别**决定是否进入 **R4 设计**（不是实现接线）：  
   - 具体 RimeBridge bootstrap  
   - 全 session API 进入同一 owner  
   - 有序 MainActor 交付 + terminal barrier  
   - 有界队列 / backlog / jetsam 与 no-input-drop 政策  
   - Extension 显式 visibility/process lifecycle（deinit 不得作为唯一政策）  
3. **在 R4 设计与 real-engine/device 证据之前**：ADR 0025 保持 **Proposed**；gate 默认 **off**；不合并任何 default-on 行为。  
4. 更新 evidence：将 `docs/evidence/t9-responsive-pipeline-spike-p1-3-2026-07-30.md` 从 “remediation validation pending” 推进为带新 SHA 的 post-remediation 记录（由 Executor/Quality，非本 Arch 文件越权改写为 Pass 证据）。

---

## Verdict summary

| 项 | 结论 |
|---|---|
| 原 Arch P1（omitted shutdown orphan） | **Closed** |
| 新 P0/P1 | **无** |
| 原 P2×3 | **仍开放（R4）** |
| Spike isolation 形状 | **保持；lifecycle 补全** |
| ADR 0025 / Product Gate / R4 / Release default-on | **全部不授权** |

**Architecture re-review: Pass with conditions** — lifecycle P1 在源码与测试结构上关闭；条件为：P2 residual 诚实保留、Quality 必须补执行绿条与新 checkpoint、且不得将本 Pass 解读为 ADR Accept 或 R4 授权。
