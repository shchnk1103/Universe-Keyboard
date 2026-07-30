# Quality Re-review: Spike-P1-3 remediation

| Field | Value |
|---|---|
| Reviewer role | 🧪 Quality, Performance & Release Maintainer（independent re-reviewer） |
| Date | 2026-07-31 Asia/Shanghai |
| Assignment | [`t9-responsive-rime-pipeline-001.md`](t9-responsive-rime-pipeline-001.md) |
| Spike design | [`t9-responsive-pipeline-001-spike-p1-3-design.md`](t9-responsive-pipeline-001-spike-p1-3-design.md) |
| Prior Quality Fail | [`t9-responsive-pipeline-001-spike-p1-3-quality-review.md`](t9-responsive-pipeline-001-spike-p1-3-quality-review.md) @ `45c426f` |
| Prior Architecture Fail | [`t9-responsive-pipeline-001-spike-p1-3-architecture-review.md`](t9-responsive-pipeline-001-spike-p1-3-architecture-review.md) @ `45c426f`（仅引用，不代审） |
| Scope | Spike-P1-3 **lifecycle / stall-proof remediation only**（相对 `45c426f` 工作区改动） |
| Bound tip | `HEAD` = `45c426f`；remediation **尚未**形成新的 immutable commit（工作区脏） |
| Verdict | **Pass with conditions** |

**P0: 0**  
**P1: 0**  
**P2: 1**  
**P3: 2**

---

## Commands re-run

Independent re-run on this machine（**不**信任 Executor 口头 green）：

```bash
cd "/Users/doubleshy0n/Dev/Universe Keyboard/Packages/KeyboardCore" && swift test --filter ThreadAffineRimeSpike
```

| Suite | Executed | Failures | Notes |
|---|---:|---:|---|
| `ThreadAffineRimeSpikeTests` | **7** | **0** | 较 Fail 点 `5` 例增加 2 个 lifecycle 测试 |
| Filter total | **7** | **0** | ~0.21s；`testMainActorAcceptsWhileOwnerEngineCallIsBlocked` ~0.19s |

覆盖用例（全部 PASS）：

1. `testMainActorAcceptsWhileOwnerEngineCallIsBlocked`
2. `testDedicatedOwnerPreservesOrderWithoutDropOrDuplicate`
3. `testOldEpochResultIsRejectedAndNewEpochRunsAfterResetBarrier`
4. `testExplicitShutdownDestroysEngineOnItsOwnerThread` ← remediation
5. `testOwnerDeinitStopsThreadAndDestroysEngineWhenShutdownIsOmitted` ← remediation
6. `testApplyGateRejectsOlderRevisionDeliveredAfterNewerRevision`
7. `testSpikeIsNotWiredAndGateOffRemainsSynchronous`

```bash
cd "/Users/doubleshy0n/Dev/Universe Keyboard/Packages/KeyboardCore" && swift test
```

| Suite | Executed | Failures |
|---|---:|---:|
| `KeyboardCoreTests` / All tests | **823** | **0** |

（Fail 点为 **821 / 821**；+2 与 Spike lifecycle 测试一致。）

---

## P1 disposition

Prior Quality Fail P1（engine/thread destruction not fail-safe）**已关闭**，证据如下。

| Required remediation | Status | Evidence |
|---|---|---|
| automatic, idempotent stop fallback | **Fixed** | `requestStop()` 经 `acceptanceState.stopped` 只入队一次；`shutdown()` 与 `deinit` 均调用 |
| omitted-shutdown thread/engine destruction test | **Fixed** | `testOwnerDeinitStopsThreadAndDestroysEngineWhenShutdownIsOmitted` PASS：`owner = nil` 后 `waitForDeinit`，`deinitThread == initThread` |
| explicit-shutdown destruction-on-owner-thread test | **Fixed** | `testExplicitShutdownDestroysEngineOnItsOwnerThread` PASS：`assertSingleOwnerThread` 校验 init/process/deinit 同线程 |
| bounded wait only; no hot-path blocking | **Fixed** | `deinit`/`requestStop`/`shutdown` 不 `wait`；`waitUntilStopped` / `waitForDeinit` 仅测试用、带 timeout |
| 150 ms stall inside Fake `processKey`（prior P2） | **Fixed** | 删除 `beforeEngineCall`；阻塞移入 `SpikeLifecycleProbeRimeEngine.processKey` |
| no production wiring / gate default off | **Held** | `isResponsiveRimePipelineEnabled = false` 默认；`testSpikeIsNotWiredAndGateOffRemainsSynchronous` PASS；Spike 源不进入 Controller/Extension/`RimeEngineImpl` 接线 |

Prior Quality P2（150 ms 证明措辞超实现）**已关闭**：stall 发生在 Fake engine 的 `processKey` 内，不再是 pre-engine hook。

Prior Quality P3（50 ms 断言非 Product SLO）**保留为 residual P3**，见下；不升格为 Fail。

---

## Findings

### P2-1 — remediation 尚无 immutable checkpoint（条件项）

- `HEAD` 仍为 Fail 点 `45c426f`。
- 源码/测试/部分文档为 **未提交工作区改动**。
- Quality 对 remediation **行为与测试** 可 Pass；正式交接、Architecture 复审绑定、后续证据引用应先落一颗可复现 SHA。
- **不**因此重新打开 lifecycle P1；这是发布/交接条件，不是实现缺陷。

### P3-1 — 50 ms MainActor accept 上界仍是实验 falsification，不是 Product/Release SLO

- `testMainActorAcceptsWhileOwnerEngineCallIsBlocked` 仍断言 accept 路径 `< 50 ms`，并要求 owner stall `≥ 150 ms`。
- 语义正确（semaphore 并发证明 + 宽松 wall-clock 上界），但在过载 CI 上可能噪声。
- 保持明确标注：实验阈值，**非** Product Gate / Release 策略。

### P3-2 — Spike 相关证据/设计文档状态滞后

- `docs/evidence/t9-responsive-pipeline-spike-p1-3-2026-07-30.md` 仍写 Fail 点 `5 passed` / `821` 与 “validation pending”。
- design/plan/assignment 状态仍指向 `45c426f` Fail / remediation pending。
- 不阻断代码级 Quality Pass；提交 checkpoint 时应同步刷新独立复跑计数与 disposition。

### Residual（非本复审 Fail；留给 Architecture / R4）

以下 **不是** Quality 对 Spike remediation 的新 P1，但不得在交接中抹平：

- Architecture residual：Sendable factory ≠ 真实 RimeBridge 构造证明；
- Architecture residual：`Task { @MainActor }` 交付无显式 FIFO/terminal barrier；
- Architecture residual：无界 mailbox / `removeFirst`、queue/jetsam/visibility 策略；
- Spike 仅暴露 `.processKey`；完整 RimeEngine API、真实 librime、Extension、device 均未证明。

---

## Explicit non-claims

本复审 **明确不主张**：

- **Architecture Pass**（Architecture 对 `45c426f` 的 Fail 与 residual 由独立 Architecture re-reviewer 处理）
- **ADR 0025 Accept**（保持 `Proposed`）
- **Product Gate** / Human device / R5
- **R4** 生产接线授权、真实 `RimeEngineImpl` / librime 线程亲和证明
- **Release default-on** 或 gate 默认行为变更（gate 仍 default-off）
- 输入法 UI 帧响应、marked-text 原子性、jetsam、进程死亡恢复
- 将 50 ms / 150 ms 断言升级为 Product 或 Release SLO

---

## Recommended next

1. **Executor**：将 remediation + 本复审文档打成 **immutable commit**；刷新 evidence 中独立测试计数（Spike **7/7**，全量 **823/823**）与 status。
2. **Architecture**：独立 re-review lifecycle P1 关闭情况；**保留** P2 residuals（factory / delivery / queue bounds），勿顺带 Accept ADR 0025。
3. **Product Lead**：仅在 Arch + Quality 对 **新 SHA** 均有明确 disposition 后，决定是否授权下一刀（例如 R4 设计或 real-engine fixture Spike）——**本文件不授权**。
4. 合并前保持：`ThreadAffineRimeSpike*` 不接线；`isResponsiveRimePipelineEnabled` 默认 `false`。

---

## Verdict summary

| Item | Result |
|---|---|
| Prior Quality P1 (lifecycle) | **Closed** |
| Prior Quality P2 (stall site) | **Closed** |
| Prior Quality P3 (50 ms SLO wording) | Residual P3 retained |
| Independent Spike tests | **7 / 7 PASS** |
| Independent KeyboardCore suite | **823 / 823 PASS** |
| Production wiring / gate default | **Unchanged (off)** |
| Overall | **Pass with conditions**（immutable SHA + 文档同步） |
