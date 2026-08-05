# Architecture re-review：T9-RESPONSIVE-PIPELINE-001 / P3-D1-T02/T03 修复后

| 字段 | 结论 |
|---|---|
| 复审角色 | 🏛️ Architecture & Knowledge Steward（独立、只读） |
| 复审日期 | 2026-08-03（Asia/Shanghai） |
| 复审对象 | [`P3-D1-T02/T03 Lifecycle Harness`](t9-responsive-pipeline-001-p3-d1-t02-t03-lifecycle-harness.md) |
| 前一份复审 | [`Architecture review`](t9-responsive-pipeline-001-p3-d1-t02-t03-architecture-review.md) |
| 父矩阵 | [`P3-D1 Runtime Lifecycle Evidence Matrix`](t9-responsive-pipeline-001-p3-d1-runtime-lifecycle-matrix.md) |
| 变更范围 | 仅复核 Coordinator epoch、harness marker/handshake、host Skip/Blocked 处理和当前证据；未修改生产逻辑 |
| Architecture 结论 | **Pass with conditions（修复后的实现边界成立；T02/T03 runtime 仍 Blocked）** |
| P0 / P1 / P2 / P3 | **0 / 0 / 3 / 1** |
| 治理边界 | ADR 0004 仍 Accepted；ADR 0025 仍 Proposed；不形成 Product Gate、Release 或默认开启结论 |

本复审只检查前一份 Architecture review 的 P2-01（生命周期 epoch 屏障）和 P2-02（target
handshake）修复是否达到其声明的 bounded 范围，并核对最新的编译、Core 回归和 UI
`Skipped` 证据。它不把当前 Simulator 的 host 可达性、build 结果或 Core 测试升级为实际
Keyboard Extension lifecycle 通过，也不替代独立 Quality review。

## 1. 复审输入与方法

已读并交叉核对：

- T02/T03 Assignment 的 authority、scope、actual-target boundary、content-free contract、
  stop/exit/handoff 和最新 execution record；
- P3-D1 父矩阵中 T02/T03 当前状态及本次 Run ID、Simulator、build/test 结果；
- 前一份 Architecture review 中的 P2-01/P2-02/P3 findings；
- `Keyboard/Controllers/KeyboardViewController.swift`、
  `Keyboard/Controllers/KeyboardViewController+Bootstrap.swift`、
  `Keyboard/Controllers/KeyboardViewController+Presentation.swift`；
- `Packages/KeyboardCore/Sources/KeyboardCore/ThreadAffineRimeSession.swift`、
  `ThreadAffineRimeSpike.swift` 和 `ThreadAffineRimeWireTests`；
- `UniverseKeyboardUITests/NativeExperienceKeyboardAutomationFeasibilityTests.swift` 的
  T02/T03 host-driven invocation。

本复审没有重新执行 build/test；下文的数字、日志、result bundle 和 source fingerprint 均
按 Assignment 的 content-free execution record 作为 bounded snapshot。当前工作树仍有
ambient dirty changes，本文不归因、不暂存、不覆盖它们。

## 2. 修复前 findings 的 disposition

| 前一份 finding | 当前 disposition | 依据与边界 |
|---|---|---|
| P2-01：suspend 后新 owner 可能从 epoch 1 重启，旧 snapshot 可能穿过新 lifecycle | **Closed（bounded Core/Coordinator）** | epoch 已移到 coordinator；owner 缺失时 diagnostics 仍暴露 coordinator epoch；replacement owner 在接收新 work 前 replay 该 epoch；Wire regression 在 stopped 和 replacement 两个阶段拒绝 epoch-1 snapshot。 |
| P2-02：target harness 没有可证伪 handshake，Run ID 固定，UI 仅看 surface | **实现形状修复；runtime/provenance 条件仍开放** | actual Extension 有显式 `P3D1LifecycleHarness` accessibility element、`returnClean` 字段和 `RETURN_CLEAN` marker；helper 超时现返回 nil。target host 尚未运行，且测试没有把 marker 的 `run=`/epoch 与期望 Run ID/return lifecycle 做相等校验。 |
| P2-03：source/build/artifact provenance 不完整 | **仍开放** | Assignment 记录了 source hashes、两个 build log 和 xcresult，但 `KeyboardViewController+Presentation.swift` 当前 hash 与记录不一致；也未见当前 run 的 appex/test bundle hash、resolved build-settings digest 或实际 marker export/privacy digest。 |
| P3-04：gate-off 只有 compile 证据 | **仍开放且措辞正确** | gate-off build 通过；没有 host runtime，因此只能称为 compile/static boundary，不是 ADR 0004 runtime equivalence。 |

## 3. 生命周期 epoch 屏障复核

### 3.1 Coordinator-owned epoch 的静态推理

当前 `ThreadAffineRimeSessionCoordinator` 的 `lifecycleEpoch` 不再属于可替换的 owner：

1. owner 存在时，`bumpSessionEpoch()` 让 owner 取得新 epoch，并将 coordinator watermark
   保持在至少该值；
2. owner 已停止或暂时不存在时，`bumpSessionEpoch()` 仍直接递增 coordinator watermark；
3. `diagnostics` 在 owner 缺失期间返回带 coordinator epoch 的 value snapshot，而不是回到
   默认 epoch 1；
4. `startOwner()` 等待 owner readiness 后，把 coordinator epoch replay 到新 owner；
5. MainActor presentation 的 live check 读取 coordinator diagnostics，故 epoch-1 snapshot
   在停止间隙和 replacement owner ready 后都应 fail closed。

这组形状关闭了前一份复审指出的“owner 重建复用 epoch”风险。`max(ownerEpoch,
coordinatorEpoch)` 是诊断读取的防御性上界；它没有把 live engine 跨隔离带回 MainActor。

### 3.2 Regression 证据

新增 `testVisibilityOwnerRestartPreservesEpochAndRejectsStaleSnapshot` 覆盖：

- abandon boundary 后 coordinator epoch 为 2；
- owner 停止且被置空时 diagnostics 仍为 epoch 2；
- epoch-1 snapshot 在 owner stopped 阶段不触发 presentation；
- replacement owner 启动后 replay 为 epoch 2；
- 同一 epoch-1 snapshot 在 replacement 阶段仍不触发 presentation。

Assignment 最新记录的专项 `ThreadAffineRimeWireTests` 为 **10/0**，validator 为 **6/0**，
full `KeyboardCore` 为 **901/0**。这足以将 P2-01 关闭在当前 Core/Coordinator fixture 层，但不是宿主驱动的
实际 Extension race 证明：测试仍是受控 notification injection，尚未观察真实 host
hide/return 中 owner delayed result 的 marker sequence。

### 3.3 生命周期顺序的保留边界

当前 Extension 仍由 MainActor 同步执行 suspend、transient cleanup 和 abandon；因此在当前
调用链中 epoch bump 完成后，MainActor 才有机会交付排队通知。若未来把 suspend/cleanup
拆成可让 MainActor 交错的异步步骤，必须重新验证“先取得不可复用 identity，再停止 owner”
这一屏障，不应仅依赖本次 regression 的同步调用顺序。

## 4. Target harness、Run ID 与 marker 复核

### 4.1 Actual target seam 与 default-off：成立

- Fake bootstrap/owner 和 lifecycle marker 位于 actual `Keyboard` Extension source root，
  不是 XCTest bundle 的 controller copy；
- seam 由 `DEBUG && T9_P3_D1_LIFECYCLE_HARNESS` 保护，工程默认/Release 没有写入该 flag；
- owner 只接收 Sendable recipe，在专用线程创建、调用和释放 engine；未发现
  `@unchecked Sendable`、live engine shuttle 或 unsafe isolation；
- UI test 另由 `P3_D1_T02_T03_RUN=1` 明确 gate，普通 CI/Release-like invocation 不会
  自动运行该 harness；
- `P3D1LifecycleHarness` accessibility element 只在显式 harness 编译臂安装，marker
  value 仅含 schema、run、epoch/revision/counter、readiness、terminal、clear 和 bounded
  reason，不应含 raw pinyin、candidate、marked text 或 committed text。

### 4.2 Marker 字段：存在，但语义/证据仍需收紧

当前 `P3LIFE` line 已包含：

`schema`、`marker`、`run`、`gate`、`epoch`、`rev`、`pending`、`accepted`、`applied`、
`stale`、`discard`、`terminal`、`ownerReady`、`cleared`、`returnClean` 和 bounded `reason`。

这比修复前的单一 `rev`/surface 观察明显完整，且 `PUBLISH` 回调会更新 harness 的 applied
计数。需要保留两个精确定义：

- `accepted` 当前是最近一次 accept receipt 的 revision 水位；
- `applied` 当前是 Extension presentation callback 的计数，不是 owner 线程每个结果的
  revision watermark。owner completion 与 latest-only UI coalescing 不能仅凭这个计数推导
  出“每个 accepted revision 都已 paint”。

此外，当前 `P3LIFE marker=PUBLISH` 是在 `onResponsivePresentationNeeded` 的 UI bridge
回调中记录的；它不是 owner completion 的天然边界。既有 P2-D1 合同中的 owner `PUBLISH`、
MainActor `VISIBLE`/`PAINT` 与该 harness marker 的名称/语义因此尚未统一。

因此 marker 形状可作为 content-free diagnostics handshake，但只有在 target run 中补充
明确的 owner-completion/applied-revision 解释、顺序/数量 validator，并消除
`PUBLISH` 语义冲突后，才可用来关闭 T02 的 ordered/no-drop/no-reorder contract。当前 UI
T02 只检查 marker 存在及若干字段存在，没有断言三次 tap 对应的 accepted/applied/order
关系；这是本复审保留的 **P2-ARCH-01**。

### 4.3 Run ID 绑定：当前未闭合（P2-ARCH-01）

代码会尝试从 `ProcessInfo.processInfo.environment["P3_D1_T02_T03_RUN_ID"]` 读取并清洗
token，否则生成 per-process UUID。这保证 marker 不是固定常量，也不会泄露用户内容；但当前
T02/T03 XCTest 只读取 `P3_D1_T02_T03_RUN` gate，没有把期望的
`P3_D1_T02_T03_RUN_ID` 设置到 host/appex 可确认的环境，也没有断言返回 marker 的
`run=` 等于 execution record 的 Run ID。

特别是测试通过 `XCUIApplication(bundleIdentifier: Messages)` 驱动系统 host 时，XCTest
runner 的环境变量是否进入 Messages/Keyboard.appex 不能从当前源码假定成立。若 appex 走
UUID fallback，当前 UI helper 仍可能接受该 marker，而 execution record 的 opaque Run ID
并未得到绑定证明。

**关闭条件：**下一次 target run 必须让测试/受控导出记录“期望 Run ID → target marker
run”的相等关系，或记录并验证 target 生成的 token 后再将其绑定到该 Run ID；缺少绑定时
必须继续 `Blocked/Skipped`，不得把某条同 schema marker 当成该 run 的证据。

### 4.4 Accessibility helper 与 return-clean 绑定

`waitForP3D1LifecycleDiagnostic` 现在在 value 不匹配或超时后返回 `nil`，关闭了前一轮
helper 的旧 marker 假通过路径。`RETURN_CLEAN` 也已在实际 target 的返回分支发出，并以
`returnClean=1` value 字段供 T03 查找。

但 `p3d1LifecycleLastCleared` 与 `p3d1LifecycleLastReturnClean` 仍是进程级 sticky OR；
T03 的 `returnClean=1` 仍可能来自同一进程较早的 lifecycle，而非本次 return epoch。它
仍属于 **P2-ARCH-02** 的 target provenance residual，而不是本次 host Skip 的产品失败。

**状态：**helper 在 value 不匹配或超时后返回 `nil` 的条件已满足；后续 target assertion 必须
校验 schema、精确 Run ID、当前 `RETURN_CLEAN` 阶段的 marker 和 epoch/revision，并对当前
marker stream 调用同一 fail-closed validator。helper 的 nil 修复已满足第一项；target
run/epoch 绑定仍未证明。

## 5. Host precondition 与当前运行状态

T02/T03 的 host 前置现在按环境边界 fail-closed：

- 没有 keyboard surface：`XCTSkip`；
- 没有可点击的 Apple system keyboard switcher 或 exact Universe activation：`XCTSkip`；
- T03 没有 conversation return boundary / 返回 surface / product-owned controls：`XCTSkip`；
- 只有进入 target 且拿到 `P3D1LifecycleHarness` value 后，才会尝试 owner/lifecycle 断言；
  helper 对“存在但过期/不匹配 value”现返回 `nil`；target run/epoch 绑定仍需独立证据。

因此本次 `Blocked / Skipped` 处理正确，不能把它解释成产品失败，也不能把 skipped host
run 解释成 target pass。父矩阵保留：

| 行 | 当前状态 | Architecture 复核 |
|---|---|---|
| T02 | `Blocked (host accessibility)` | harness-on/gate-off build 与 Core regression 有 bounded evidence；无 target owner-delay marker sequence。 |
| T03 | `Blocked (host accessibility)` | epoch/stale Core regression 已证明；无实际 disappearance/return/reload marker sequence。 |
| R01–R06 | `NotRun` | 不被 T02/T03 seam 或 Simulator host skip 升级。 |

## 6. 最新 bounded evidence 与 provenance

本次 Executor 更新快照绑定 Run ID：`P3D1-T02-T03-SIM-20260803-001`；Simulator 仍为 iOS 27.0 /
iPhone 17 Pro Max / `06C5BC3E-7599-4761-A1A2-71DAEA991474`，Debug，harness flag 为
`DEBUG T9_P3_D1_LIFECYCLE_HARNESS`，UI gate 为 `P3_D1_T02_T03_RUN=1`。本复审未重跑这些
命令，只复核记录与当前源代码。

| 检查 | Assignment 记录 | 本复审解释 |
|---|---|---|
| Harness-on Keyboard build | **Passed**；log [`build_sim_2026-08-02T16-17-30-946Z_pid40269_94150708.log`](/Users/doubleshy0n/Library/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/logs/build_sim_2026-08-02T16-17-30-946Z_pid40269_94150708.log) | 证明新 Run ID 对应 target seam 可编译；不证明 lifecycle 执行。 |
| Gate-off Keyboard build | **Passed**；log [`build_sim_2026-08-02T16-18-05-079Z_pid40269_f2122b35.log`](/Users/doubleshy0n/Library/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/logs/build_sim_2026-08-02T16-18-05-079Z_pid40269_f2122b35.log) | 支持 default-off compile boundary；不证明同步运行等价。 |
| T02/T03 host UI | **Blocked / Skipped**；result bundle [`test_sim_2026-08-02T16-19-23-797Z_pid40269_b0e95931.xcresult`](/Users/doubleshy0n/Library/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-08-02T16-19-23-797Z_pid40269_b0e95931.xcresult) | Messages 没有完整 Apple keyboard activation boundary；未进入 target owner/lifecycle 分支。 |
| `ThreadAffineRimeWireTests` | **10/0** | 包含 owner restart old-epoch regression；bounded Core/bridge evidence。 |
| `P3D1LifecycleEvidenceValidatorTests` | **6/0** | schema/run/owner-order/privacy 与跨 epoch revision reset bounded evidence。 |
| `KeyboardCore` full | **901/0** | 组件全量回归；不能替代 Extension host runtime。 |
| `git diff --check` | **Passed** | 文本卫生；不证明 marker provenance。 |

当前记录的 source fingerprint：

- `Keyboard/Controllers/KeyboardViewController+Bootstrap.swift`: **当前** `90904e6fca385e71c02a37e4a6739a377ae6d7df0ecd7bc273c82f6cdb71ee5c`；
- `Keyboard/Controllers/KeyboardViewController.swift`: **当前** `294d74878018e25bbdec59202cbb0bc62cb02ae2b2e9aa5f48bacadc719de31a`；
- `Keyboard/Controllers/KeyboardViewController+Presentation.swift`: **当前** `22554f0cffa54d862b684679c422561a68e399e1c914dfdcdb19f54d3eb6f9ab`；
- `Packages/KeyboardCore/Sources/KeyboardCore/ThreadAffineRimeSession.swift`: `00d490e91024db2b16f2e9217efa15b4760f9cebff3b5c486c36012f1d84cfb6`；
- `Packages/KeyboardCore/Tests/KeyboardCoreTests/ThreadAffineRimeWireTests.swift`: `4d6d31a7adb91450172a677b848e2288beaf038e0dd77f562abcfdaa6cd4ab10`；
- `Packages/KeyboardCore/Sources/KeyboardCore/P3D1LifecycleEvidenceValidator.swift`: **当前** `8fc6421b61650c90a4da86b295492f50c8cef852ab1a6164707989fd49dd457b`；
- `Packages/KeyboardCore/Tests/KeyboardCoreTests/P3D1LifecycleEvidenceValidatorTests.swift`: **当前** `b640688bdd81e98fbdf02b77c3cadca818b5edba733ddfa502bc3f25a0cf606e`；
- `UniverseKeyboardUITests/NativeExperienceKeyboardAutomationFeasibilityTests.swift`: **当前** `9073950761a8c836deb0888d845fb1c8351d38896607584642728d92c21905d8`。

这些是当前 ambient dirty worktree 的 source snapshot，不是提交 SHA。Executor 已将本次
evidence 绑定到 Run ID `P3D1-T02-T03-SIM-20260803-001`，并报告 Wire **10/0**、validator
**6/0** 和 KeyboardCore full **901/0**；本复审未重跑。构建/result bundle 路径已记录，
但 actual appex/test bundle hash、resolved flags digest、marker export/privacy scan 和
teardown 状态仍未形成 target runtime provenance；旧 Run ID 不得自动代表新源码。

## 7. 已证明、未证明与残余风险

### 已证明（bounded）

- lifecycle epoch 已从 replaceable owner 提升为 coordinator-owned barrier；owner 缺失 fallback、
  replacement replay 和 epoch-1 rejection 有 `ThreadAffineRimeWireTests` 回归；
- actual Extension seam、Fake owner 的线程亲和形状、DEBUG+harness 编译边界和 gate-off
  compile 边界成立；没有发现 `@unchecked Sendable` 或 Release 默认接线；
- marker/accessibility handshake 的结构和 content-free 方向成立；helper 的过期/不匹配
  value 现 fail-closed；host 前置失败会 `Skip/Blocked`，不伪造产品失败；returnClean 的
  target epoch/run 绑定仍未成立；
- 当前 execution record 的 build、Core regression、source snapshot 和 host blocker 归因
  可作为 bounded evidence。

### 未证明

- Messages 实际加载本次 harness-on `Keyboard.appex`，以及 target marker `run=` 与 execution
  Run ID 的绑定；
- MainActor 在真实 target Fake owner 阻塞期间的 accept/enqueue、ordered/no-drop/no-reorder
  和 owner completion marker sequence；
- 实际 host disappearance/return/reload 的 clear 顺序、旧 snapshot 丢弃和新 epoch 可用；
- real `RimeEngineImpl`、librime/Lua/schema、物理设备、App Group durability、jetsam、Release
  或 Product Gate。

### P2 / P3 残余

- **P2-ARCH-01：** target Run ID 绑定、marker 水位语义以及 owner `PUBLISH` 与 UI
  `VISIBLE`/`PAINT` 的语义分离尚未被真实 host run 证伪；T02 当前不能凭 marker 存在升级为
  Passed。
- **P2-ARCH-02：** helper 的 timeout 旧 value fallback 已关闭，但 sticky `cleared=1` /
  `returnClean=1` 仍可能误绑定到较早 lifecycle；当前 target host 未证明该字段来自本次
  return epoch。
- **P2-ARCH-03：** Assignment execution record 已更新 source hashes、build logs、UI result
  bundle 和新 Run ID，但 actual appex/test artifact hash、resolved flags digest、marker
  export/privacy digest 和 teardown/restore 仍未冻结；因此 source/build 路径已绑定，完整
  target provenance 仍开放。
- **P3-ARCH-04：** gate-off 仅有 build/静态证据；没有宿主 runtime 等价观察，且当前 host
  blocker 不允许为此扩大范围。

未发现 P0/P1。P2-ARCH-01/02/03 是关闭 T02/T03 runtime disposition 前的必要证据条件；
P3 项是证据卫生/validator 细化，不是本次授权下修改生产逻辑的理由。

## 8. ADR、Product Gate 与 Quality handoff

- ADR 0004 的同步 gate-off 路径没有被本 harness 接线替换；本复审不改变 Accepted 状态。
- ADR 0025 仍为 Proposed；没有真实 `RimeEngineImpl` off-main 生产接线，没有扩大 auto-anchor，
  没有使用 unsafe isolation。
- T02/T03 继续 `Blocked (host accessibility)`；P3-D1 parent 继续 `Active`；R01–R06 继续
  `NotRun`。不形成 Release、Product Gate、主观不卡顿或真机结论。
- 建议独立 Quality 复审继续进行，重点核对：Run ID 是否与 target marker 相等、helper 是否
  对旧 value fail-closed、marker schema/sequence validator、`accepted/applied` 与
  owner/UI `PUBLISH` 语义、privacy scan 和当前 source fingerprint 是否与重新构建的
  artifact 绑定。Quality 不应把 host Skip 升级成产品失败。

## 9. Final disposition 与停止点

**Architecture disposition：Pass with conditions（修复后的 lifecycle/target seam 形状基本成立；
runtime proof blocked）。**

1. 前一份 P2-01 的 coordinator epoch/replacement-owner stale 风险在 bounded Core/Coordinator
   范围内关闭；`ThreadAffineRimeWireTests 10/0` 支持该窄结论。
2. target-only harness、harness accessibility handshake、content-free marker 和 host
   `Skip/Blocked` 分类满足边界方向，但没有实际 target lifecycle marker sequence。
3. P2-ARCH-01/02/03（Run ID/marker 语义、helper fail-closed、source/artifact provenance）
   在下一次 host run 前仍需由 Executor/Quality 明确关闭或接受为 residual；在此之前 T02/T03
   不得标为 Passed。
4. 保持 ADR 0025 Proposed、双 gate default-off、Product Gate/Release/真机边界不变。

本角色到此停止，不修改生产逻辑；将文档交给独立 Quality 复审，再由 Product Lead 决定是否
授权新的 host/target driver 或后续 runtime 取证。
