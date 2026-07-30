# Architecture Review: T9-RESPONSIVE-PIPELINE-001 / R4-B

**Reviewer role:** 🏛️ Architecture & Knowledge Steward（独立 subagent；对抗性结构审查）  
**Date:** `2026-07-31 Asia/Shanghai`  
**Assignment:** [`T9-RESPONSIVE-PIPELINE-001`](t9-responsive-rime-pipeline-001.md)  
**Phase:** R4-B — real librime bootstrap + Simulator/RimeBridge disconnected proof  
**Product authority:** [`PD-T9-RESPONSIVE-PIPELINE-001`](../product-decisions/T9-RESPONSIVE-PIPELINE-001-authorization.md) § R4-B  
**Design freeze:** [`t9-responsive-pipeline-001-r4-b-design.md`](t9-responsive-pipeline-001-r4-b-design.md)  
**Predecessor:** R4-Owner Architecture review（D1–D3 Closed on Fake path；P2-later-1 deferred to R4-B）  
**ADR:** [`0025`](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md) — **Status remains `Proposed`（本审查不 Accept）**  
**Bound tip (post-review checkpoint):** **`cb45f1c`**  
**Sources reviewed (working tree at review time; later bound to `cb45f1c`):**

| Artifact | Role |
|---|---|
| `Packages/RimeBridge/Sources/RimeBridge/ThreadAffineRimeEngineImplBootstrap.swift` | 真实 config-only bootstrap（权威） |
| `Packages/RimeBridge/Tests/RimeBridgeTests/ThreadAffineRimeRealEngineTests.swift` | 证据形态 / 隔离形状（绿条归 Quality） |
| `Packages/KeyboardCore/Sources/KeyboardCore/ThreadAffineRimeSpike.swift` | Owner 合同、iOS availability、QoS |
| `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController.swift`（gate 默认） | 确认 gate 仍 default-off、无 ThreadAffine 接线 |
| `scripts/run_t9_responsive_r4b.sh` | 隔离 fixture harness 形状 |
| R4-B design freeze | D1–D4 + stop conditions |
| PD R4-B 授权段 | 产品边界与 non-claims |
| R4-Owner Arch review P2-later-1 | 关闭目标 |
| `docs/evidence/t9-responsive-pipeline-r4-b-2026-07-31.md` | Executor 叙事（**不**采信为 Arch Pass） |
| ADR 0025 | Status 仍 **Proposed** |

**Verdict:** **Pass with conditions**

| Severity | Count |
|---|---|
| P0 | 0 |
| P1 | 0 |
| P2 | 2（均为 **后续阶段 residual**，不重开 R4-B D1 Fail） |
| P3 | 5 |

> **判定原则：** 只根据源码/设计结构是否兑现 R4-B design freeze 的 D1–D4 与 PD 边界；不以 Executor evidence 绿条代替结构审查；Quality 拥有 Simulator 执行与诚实证据；本文件 **不** 声称 ADR Accept、Product Gate、Extension 生产接线、Release default-on、设备主观不卡顿。

---

## 1. Scope of this review

**In scope**

- **D1：** 真实 `RimeEngineImpl` 的 config-only Sendable bootstrap；engine 仅在 owner thread 物化
- **D2：** 证据矩阵形态（M1–M5）是否可被测试/ harness **结构上**证伪；诚实 skip（非假 Pass）
- **D3：** 隔离 fixture 策略（env / copy；不把正式 App Group 当唯一可写运行时）
- **D4：** Thread-affine API 的 iOS availability（不再 macOS-only 卡死 RimeBridge iOS 证明）
- 关闭 R4-Owner **P2-later-1** 在 **proof（非 production wiring）** 范围内的 residual
- 隔离边界：无 live engine shuttle、无 Extension wire、无 `@unchecked Sendable`、无 ADR Accept 副作用、gate 保持 default-off

**Out of scope（不得借本 Pass 偷渡）**

- Extension / `KeyboardController` 生产接线 thread-affine owner
- ADR 0025 Accept / Product Gate / Release default-on / R5 device A/B / R6
- 完整 RimeEngine API 面生产路由（Delete / Path / select / page / recover）
- Delivery 背压 / jetsam 数字 / 主观 non-stutter SLO
- 本机 `xcodebuild` / `swift test` 执行结果担保（**Quality**）
- Stretch S1/S2（T9 content / slow-key wall-time）未作为 Pass 必要条件

---

## 2. Residual disposition (from R4-Owner)

| Residual | R4-B 目标 | 源码结论 |
|---|---|---|
| **P2-later-1** 真实 `RimeEngineImpl` bootstrap | 提供 config-only bootstrap + owner 线程 create/call/teardown 证明 | **Closed as disconnected proof** — 见 §3.1；**不是**生产接线完成 |
| **P2-later-2** delivery 无界背压 | 不在 R4-B 授权内 | **Still open** — 见 §5 |
| **P2-later-3** Extension 生命周期 + 全 session API | 不在 R4-B 授权内（明确 Forbidden） | **Still open** — 见 §5 |

说明：R4-B design 标题即 “Closes residual: Arch P2-later-1 … as far as **proof**, not production wiring”。本审查按该冻结范围结案 P2-later-1 的 **proof 面**，禁止把本 Pass 读成 “off-main 生产就绪”。

---

## 3. Design freeze structural judgment

### 3.1 D1 — Config-only real bootstrap — **Closed (proof)**

**Freeze 要求：**

1. Bootstrap 为 pure `Sendable` 值类型（路径 / schema 配置 only）
2. **不得** capture live `RimeEngineImpl` / session handle
3. `makeEngineOnOwnerThread()` 仅在 owner 线程物化引擎
4. Deploy / fullCheck 在 owner start **之前**（Main-App-shaped），不在 `processKey` 热路径
5. Engine finalize/teardown 在 owner loop 释放局部 engine 时发生（同线程 ARC + deinit）
6. 禁止 MainActor 预建 live engine 再 shuttle；禁止 `@unchecked Sendable`

**源码事实：**

```text
// Packages/RimeBridge/.../ThreadAffineRimeEngineImplBootstrap.swift
public struct ThreadAffineRimeEngineImplBootstrap: ThreadAffineRimeEngineBootstrap, Sendable {
    public let sharedDataDir: String
    public let userDataDir: String
    public let preferredSchemaID: String?

    public func makeEngineOnOwnerThread() -> any RimeEngine {
        let engine = RimeEngineImpl(sharedDataDir:userDataDir:)
        // optional selectSchema on owner thread only
        return engine
    }
}
```

与 owner 合同（R4-Owner 已关，R4-B 复用）：

```text
ThreadAffineRimeSpikeOwner.init(bootstrap:)
  └─ Thread { runOwnerLoop(bootstrap:) }
       └─ let engine = bootstrap.makeEngineOnOwnerThread()  // local only
            // processKey 仅此局部 engine
            // stop → return → markOwnerLoopExited → engine 局部作用域结束
```

| 检查项 | 结果 |
|---|---|
| Bootstrap 仅含 `String` / `String?` | **Yes** |
| Bootstrap 实现 `Sendable` + `ThreadAffineRimeEngineBootstrap` | **Yes** |
| 无 stored engine / session / bridge 字段 | **Yes** |
| `RimeEngineImpl(...)` 仅在 `makeEngineOnOwnerThread` | **Yes** |
| `selectSchema` 在 owner 线程、bootstrap 方法内（仍非 MainActor 预建） | **Yes** |
| Engine 不进入 mailbox / delivery / AcceptanceState | **Yes**（mailbox 仍仅 Sendable envelope） |
| `@unchecked Sendable` 用于 engine shuttle | **No**（全仓相关路径未见） |
| 测试 / harness 中 deploy 在 owner 创建前 | **Yes**（`deployIsolatedRuntime` → 再 `ThreadAffineRimeSpikeOwner`） |

**类型系统诚实边界（不构成 Fail）：**

- 协议仍无法在编译期禁止“恶意 Sendable 工厂包装 live engine”；真实 bootstrap **本身**是值类型路径配置，恶意绕过仍靠审查纪律（与 R4-Owner 同边界）。
- `selectSchema` 使用 `_ = engine.bridge.selectSchema(...)`，失败被吞掉；对 **M1 亲和性证明**足够，对 schema 内容正确性 **不**构成产品保证（见 P3）。

**Stop conditions vs working tree：**

| Design stop | Triggered? |
|---|---|
| 需要 `@unchecked Sendable` 持有 off-main `RimeEngineImpl` | **No** |
| 必须 MainActor 构造再 shuttle | **No** |
| Harness 以正式 App Group 为唯一可写运行时 | **No**（copy 到 `docs/evidence/r4b-runtime/.../runtime`） |
| 绿测副作用 flip gate default-on | **No** |

**结论：** D1 在 R4-B **disconnected proof** 范围内 **结构关闭**。

---

### 3.2 D2 — Evidence matrix shape — **Closed (structure)**

| Case | Design | 结构结论 |
|---|---|---|
| **M1** create/call off main + same creation thread | 断言 `engineCreatedOffMainThread` / `engineCallStayedOnCreationThread` 全 true；≥3 keys | **Present** — 4 keys `rk0…rk3`，`allSatisfy` 两亲和性布尔 |
| **M2** FIFO actionID | 交付序 = accept 序 | **Present** — `actionOrder == ["rk0"…"rk3"]` |
| **M3** shutdown / no hang | `shutdown` + `waitUntilStopped` + `waitUntilDeliveryDrained` + terminal | **Present** |
| **M4** missing fixture → skip | `XCTSkip`，不得伪 Pass | **Present** — env 缺失 / 目录不存在 / schema 文件缺失均 skip |
| **M5** gate default off | `isResponsiveRimePipelineEnabled == false`；coordinator nil | **Present** — 独立 test case |

Harness（`scripts/run_t9_responsive_r4b.sh`）形状：

- 从 source shared **rsync 复制**到隔离 `SHARED_DIR` / 新建 `USER_DIR`
- 导出 `UK_RIME_T9_SPIKE_*` / `TEST_RUNNER_*` / `SIMCTL_CHILD_*` / `UK_RIME_R4B_*`
- 仅跑 `ThreadAffineRimeRealEngineTests`
- 无 fixture 路径可报告 `SKIPPED_NO_FIXTURE`；通过条件要求 machine line 或显式 test pass（**诚实 skip 路径存在**）

**Architecture 不担保** Executor 某次 `TEST SUCCEEDED` 或 SHA；只确认矩阵 **可证伪** 且 skip 路径诚实。绿条与 log 解析归 **Quality**。

Stretch S1/S2：**未实现为 Pass 门槛** — 符合 design “Optional stretch”。当前证明序列为 `n/i/h/a` + 优先 `rime_ice`（26-key 基线），**不是** T9 长句内容证明。

---

### 3.3 D3 — Fixture policy — **Closed (structure)**

| 要求 | 结果 |
|---|---|
| Env 族 `UK_RIME_T9_SPIKE_*` + runner 变体 | **Yes** |
| 或 scripted copy 到 temp/isolated tree | **Yes**（harness rsync → `docs/evidence/r4b-runtime/...`） |
| 不得 claim Pass when only skip | Design + evidence non-claims 明确；harness 对 pure skip 非 PASSED |
| Deploy 隔离、不写用户正式 App Group 为唯一 runtime | **Yes** — source 只读 rsync；user 为隔离 `installation.yaml` |

**P3 注意：** harness 默认 `SOURCE_SHARED` 硬编码本机 Simulator App Group 路径（开发机指纹）；有 `UK_R4B_SOURCE_SHARED` 覆盖。可移植性弱，但 **隔离写入** 合同成立。

---

### 3.4 D4 — Availability — **Closed**

| 要求 | 结果 |
|---|---|
| Thread-affine API 可用于 **iOS**（项目 floor 26.x）与 macOS 15+ | **Yes** — 全面 `@available(iOS 18.0, macOS 15.0, *)` |
| 不得留下 owner API macOS-only 而 RimeBridge iOS-only | **Yes** |
| Bootstrap / 测试 availability 对齐 | Bootstrap `iOS 18.0, macOS 15.0`；测试 `@available(iOS 18.0, *)`（RimeBridge iOS 目标合理） |

**QoS：** owner thread 设为 `userInitiated`（注释说明避免相对 librime helper 的 UI-class 优先级反转）。属运维/观测调优，不改变隔离合同；真机 jetsam 仍未证。

---

### 3.5 No live engine shuttle — **Pass**

跨隔离域流动的仅有：

| 方向 | 载荷 | Sendable? |
|---|---|---|
| MainActor → owner | bootstrap（路径字符串）+ work envelope | **Yes** |
| Owner → MainActor | `ThreadAffineRimeSpikeResult` / `ResponsiveRimeSnapshot` | **Yes**（既有 R4-Owner 合同） |
| Live `RimeEngineImpl` | **仅** owner 闭包局部变量 | 不跨域 |

未见：MainActor 上 `RimeEngineImpl(...)` 再传入 owner；未见 engine 进 mailbox；未见 `@unchecked Sendable` wrapper。

---

### 3.6 No Extension / production wire — **Pass**

全仓 `ThreadAffineRimeSpikeOwner` / `ThreadAffineRimeEngineImplBootstrap` 引用点：

| 位置 | 角色 |
|---|---|
| `ThreadAffineRimeSpike.swift` | 定义 |
| `ThreadAffineRimeSpikeTests.swift` | Fake 合同测试 |
| `ThreadAffineRimeEngineImplBootstrap.swift` | 真实 bootstrap 定义 |
| `ThreadAffineRimeRealEngineTests.swift` | R4-B 真实证明 |

**无** `KeyboardController` / Extension `KeyboardViewController` / bootstrap 路径实例化 ThreadAffine owner。  
`isResponsiveRimePipelineEnabled` 生产默认仍为 **`false`**（仅测试内显式 `= true`）。  
R2/R3 MainActor deferred 路径仍是实验天花板；R4-B **不**替换它。

---

### 3.7 ADR 0025 — **remains Proposed**

- 文件头 Status：**Proposed**
- R4-B design §4：只 **prove** 可行性；**不** Accept
- 本审查：**不** Accept、**不** 修订 ADR 0004 生产条款

全局 residual 名 **`P1-3-off-main`（生产 off-main owner）仍开放**。R4-B 仅把 “真实 librime 能否在 thread-affine 合同下 bootstrap” 从未知变为 **disconnected 可证**；不等于 ADR §10 生产 owner 完成。

---

## 4. Alignment with Product R4-B authorization

| PD Allowed | Working tree |
|---|---|
| Design freeze real-librime bootstrap + matrix | Design 存在且与实现一致 |
| Sendable config-only bootstrap | `ThreadAffineRimeEngineImplBootstrap` |
| Dedicated-thread create / processKey / destroy | Owner + real tests |
| Short ordered sequence proof | 4 keys FIFO |
| Gate-off baseline | Default false + M5 test |
| Isolated runtime harness | Script + env + XCTSkip |
| Independent Arch review | **本文件** |

| PD Forbidden | Working tree |
|---|---|
| Extension / KeyboardController production wire | **Absent** |
| Release default-on / user settings | **Unchanged** |
| ADR 0025 Accept / Product Gate / R5 / R6 | **Not claimed** |
| Full session API production routing | processKey-first only |
| Expand T9 auto-anchor | **No** |
| Claim device subjective non-stutter | Evidence non-claims 明确 |

---

## 5. Findings

### P0

None。

### P1

None。R4-B D1–D4 在冻结范围内无结构级阻塞缺陷；stop conditions 均未触发。

### P2 — later-phase residuals（不构成 R4-B Fail）

#### P2-later-2 — Delivery channel 无界（继承 R4-Owner）

**事实：** work mailbox 有界；owner 完成 `delivery.enqueue` 后 work 槽释放；MainActor 泵滞后时 delivery 队列仍可增长。  
**为何不是 Fail：** R4-B 未授权 delivery 背压设计；D2 只要求有序 + terminal + M1–M3 形态。  
**Remediation：** 生产接线前单独设计 delivery 深度诊断 / 联合背压 / UI publish coalesce（仍禁止丢已 accept 的输入执行）。

#### P2-later-3 — Extension 生命周期与全 session API（继承 + R4-B 明确 Forbidden）

**事实：** ThreadAffine owner 仍断开；deinit 仅为 safety net；Delete/Path/select/page/recover/runtime-selection 未进 owner；生产 session 仍受 ADR 0004 + R2/R3 gate 路径约束。  
**为何不是 Fail：** PD R4-B Forbidden 明文禁止本刀接线。  
**Remediation：** 未来 Product 命名的迁移刀：visibility finalize、全 mutation API 同 owner、runtime-selection 仅 Sendable 快照经 delivery；并走 ADR 0025 Accept 路径。

### P3

1. **`selectSchema` 失败静默：** `_ = engine.bridge.selectSchema` 不校验 `currentSchemaID`；亲和性仍可过。接线前应失败可观测（至少 content-free counter）。  
2. **证明 schema 为 `rime_ice` 优先：** 符合 “26-key 基线不被 R4-B 破坏” 叙事；**不**等于 T9 九宫格长句真实内容证明（S1 未做）。  
3. **命名债务：** 公开 API 仍大量 `ThreadAffineRimeSpike*`；bootstrap 已更名 `*EngineImplBootstrap`，owner 未 rename。接线前建议稳定 `ThreadAffineRimeOwner` 或 typealias。  
4. **Harness 本机绝对路径默认 source：** 可移植性弱；依赖 env 覆盖。证据目录下 `DerivedData` 体积巨大 — 必须保持 **不入库** / `.gitignore` 纪律（Architecture 提醒，不审 git 状态）。  
5. **QoS / Thread Performance Checker：** evidence 日志曾出现 priority-inversion 类警告；代码已调至 `userInitiated`。属观测残留，非隔离失败；不升格 P1。  
6. **Executor evidence 含 “manual correction” 叙事：** harness 解析与人工改写状态的诚实性由 **Quality** 核对；Architecture 不采信该文件为 Pass 证明。

---

## 6. Conditions of Pass

本 **Pass with conditions** 绑定以下条件；违反任一条则不得把本审查当作 R4-B 完成或后续阶段授权：

1. **Quality 独立复跑**  
   - `scripts/run_t9_responsive_r4b.sh`（或等价 isolated fixture + RimeBridgeTests filter）  
   - `swift test --package-path Packages/KeyboardCore --filter ThreadAffineRimeSpikeTests`（及按 Quality playbook 的 full suite 策略）  
   - 核对：真实 PASS vs SKIPPED_NO_FIXTURE 不得被写成假 Pass；machine line / affinity 断言  
   - Architecture **不**声称本机绿条  

2. **解释边界（强制 non-claims）** — 见 §7；任何把本文件写成 ADR Accept / Product Gate / Extension 接线 / Release default-on / 设备不卡顿 的叙述均属越权。  

3. **P2-later-1 关闭范围：** 仅 **disconnected real-engine bootstrap proof**。不得假设 “R4-B Pass = off-main 生产 owner / `P1-3-off-main` Closed”。  

4. **P2-later-2 / P2-later-3** 必须在生产接线前单独设计或接受。  

5. Working tree 若在审查后改动 D1 语义（bootstrap 持有 live engine、MainActor 预建 shuttle、引入 `@unchecked Sendable`、接入 Extension、gate 默认 true），本 Pass **作废**，需 re-review。

---

## 7. Explicit non-claims

| Claim | 本审查 |
|---|---|
| ADR 0025 **Accept** | **否** — 保持 **Proposed** |
| Product Gate | **否** |
| Release / 用户设置 default-on | **否** |
| `KeyboardController` / Extension 生产接线 ThreadAffine owner | **否** — 未接线 |
| 关闭全局 **`P1-3-off-main`**（生产 off-main owner） | **否** — 仅关闭 P2-later-1 的 **proof** 面 |
| 完整 RimeEngine API 面 on owner | **否** — processKey-first |
| T9 长句 / 主观 non-stutter / R5 A/B | **否** |
| Delivery 背压 / jetsam SLO 数字 | **否** |
| 本机 test 绿条 / SHA / 17.8s | **否** — Executor 叙事不采信；**Quality** 拥有 |
| 本审查授权下一步实现（接线 / Accept） | **否** — 仅结构判定；接线需 Product 另授 |

---

## 8. Evidence honesty note

`docs/evidence/t9-responsive-pipeline-r4-b-2026-07-31.md` 报告：

- RimeBridge real-engine **2 passed**；machine line `offMain=true sameThread=true`
- KeyboardCore ThreadAffine **10/0**；full **826/0**
- Proven / Not proven 列表与 PD 边界大体对齐

Architecture **已读**该文件以核对声称范围与 non-claims 语言，但：

- **不**把该文件当作本 Pass 的证明；
- **不**复述或担保 xcodebuild 输出 / SHA；
- 注意到 `r4b-result.md` 含 “manual correction” 与 harness 解析历史 — **Quality** 必须独立重跑并判定证据链是否干净。

---

## 9. Recommended next

1. **🧪 Quality independent review**  
   - 复跑 R4-B harness + KeyboardCore focused（按 playbook）  
   - 扫描 `@unchecked Sendable`、production wiring、gate default  
   - 区分 PASSED vs SKIPPED_NO_FIXTURE；拒绝 “skip = green”  
   - 核对 evidence non-claims 与源码一致  

2. Dual Pass 后，**Product Lead** 决定是否授权 **接线刀**（名称待定；**不是**本审查自动授权）：  
   - 仍需单独处理 P2-later-2（delivery 背压）与 P2-later-3（Extension + 全 API）  
   - ADR 0025 保持 Proposed 直至独立 **acceptance** 审查 + 授权实现 + 证据链  

3. 可选文档卫生：  
   - Assignment / plan 链到本 review  
   - 明确 P2-later-1 = **proof Closed**；`P1-3-off-main` 生产面仍 open  
   - **不要**把 R4-B 写成 off-main 生产完成  

---

## 10. Verdict summary

| 项 | 结论 |
|---|---|
| D1 config-only real bootstrap | **Closed (proof)** |
| D2 evidence matrix shape (M1–M5) | **Closed (structure)** |
| D3 isolated fixture policy | **Closed (structure)** |
| D4 iOS availability | **Closed** |
| No live engine shuttle | **Pass** |
| No Extension / production wire | **Pass** |
| Gate default-off | **Pass** |
| R4-Owner P2-later-1 (real bootstrap) | **Closed as proof only** |
| P2-later-2 delivery backpressure | **Still open** |
| P2-later-3 Extension / full API | **Still open** |
| P0 / P1 | **0** |
| P3 | **5**（schema 静默、rime_ice 范围、命名、harness 路径、QoS/证据卫生） |
| ADR 0025 / Gate / Extension wire / Release default-on | **全部不授权、不声称** |

### Final verdict

**Architecture review: Pass with conditions**

R4-B design freeze 在 working-tree 源码中结构兑现：真实 `RimeEngineImpl` 仅从 Sendable 路径配置在 owner 线程物化；无 live engine shuttle；无 Extension 生产接线；gate 保持 default-off；ADR 0025 保持 **Proposed**。R4-Owner **P2-later-1** 在 **disconnected proof** 范围内关闭。条件见 §6；delivery 背压、Extension 全 API 接线与 ADR Accept **不得**由本 Pass 暗示完成。
