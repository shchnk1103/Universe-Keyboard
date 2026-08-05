# 独立 Architecture 复审：T9-RESPONSIVE-PIPELINE-001 / P3-D1-T02/T03

复审日期：2026-08-02（Asia/Shanghai）  
复审角色：Independent Architecture & Knowledge Steward（独立、只读）  
复审对象：[`P3-D1-T02/T03 Lifecycle Harness`](t9-responsive-pipeline-001-p3-d1-t02-t03-lifecycle-harness.md)  
父矩阵：[`P3-D1 Runtime Lifecycle Evidence Matrix`](t9-responsive-pipeline-001-p3-d1-runtime-lifecycle-matrix.md)  
前置复审：[`P3-D1-T01 Architecture review`](t9-responsive-pipeline-001-p3-d1-t01-architecture-review.md)

Architecture 结论：**Pass with conditions（实现边界基本成立；T02/T03 仍须保持 Blocked）**  
严重度摘要：**P0/P1/P2/P3 = 0/0/2/2**。

本复审只检查 T02/T03 harness 的实际 target seam、并发隔离、生命周期顺序、编译旗标和
证据边界。没有修改生产代码、测试、Xcode 工程、ADR、默认 gate、设备状态或 Product Gate。
本复审不把 harness 编译结果或 UI host 的可达性当成 lifecycle runtime 通过。

## 1. 复审输入与方法

已读并交叉核对：

- T02/T03 Assignment 的 Authority、Scope、Technical design constraints、Implemented
  boundary、Evidence contract、Entry/Exit/Stop/Handoff 和 Execution record；
- P3-D1 父矩阵中 T01、T02、T03、R01–R06 的当前状态；
- T01 Architecture review、ADR 0002、ADR 0004、ADR 0025 和 P2-PERF-02 Evidence Contract；
- actual `Keyboard` Extension target 中的
  `KeyboardViewController.swift`、`KeyboardViewController+Bootstrap.swift`；
- `KeyboardCore` 的 `ThreadAffineRimeEngineBootstrap`、
  `ThreadAffineRimeSessionCoordinator`、`ThreadAffineRimeSpikeOwner`、bridge 和 gate；
- `UniverseKeyboardUITests/NativeExperienceKeyboardAutomationFeasibilityTests.swift` 中的
  T02/T03 host-driven invocation。

本复审没有重新执行 build/test。执行数字、Simulator、result bundle 和 source fingerprint
均按 Assignment 的 content-free execution record 作为 bounded snapshot，不声明为本轮
Architecture agent 的新鲜运行。

## 2. Assignment 完整性与当前状态

Assignment 已声明 Product Lead authority、父级/前置 Assignment、Domain Owner、Executor、
Environment Executor、Architecture/Quality reviewer、scope/non-goals、stop/exit/handoff 和
revalidation 条件，没有 `UNKNOWN`。实现完成但 host-driven runtime proof 被阻塞的生命周期
状态是准确的。

当前父矩阵也正确保留：

| 行 | 当前状态 | 复审确认 |
|---|---|---|
| P3-D1-T01 | `Partial (bounded)` | target dependency/build 和 bundle probe 已证明；不含 lifecycle。 |
| P3-D1-T02 | `Blocked (host accessibility)` | harness-on/gate-off build 可复核；没有 owner-delay marker sequence。 |
| P3-D1-T03 | `Blocked (host accessibility)` | lifecycle seam 可编译；没有 visibility/return/reload marker sequence。 |
| P3-D1-R01–R06 | `NotRun` | 不被 target harness 或 Simulator host 状态升级。 |

`Blocked (host accessibility)` 是诚实分类而不是测试失败：Messages 的可见键盘 surface
存在，但没有可点击的 Apple system keyboard switcher，故实际 `Keyboard.appex` 没有被宿主
选中并运行。执行记录没有声称 owner delay、epoch/revision 或 marked-text 结果已经发生。

## 3. Actual target seam 与 Swift 6 owner isolation

### 3.1 Actual target seam：成立，但仅限 diagnostic compile arm

T02/T03 的 seam 位于 `Keyboard` Extension target 的
`KeyboardViewController+Bootstrap.swift`，而不是 `UniverseKeyboardUITests` 的复制 test
double。`activateRimeRuntimeAfterKeyboardPresentation()` 在显式
`DEBUG && T9_P3_D1_LIFECYCLE_HARNESS` 条件下调用 `installP3D1LifecycleHarnessIfArmed()`；
该方法向 `KeyboardController` 安装 config-only bootstrap、Fake owner 和现有
`ThreadAffineRimeSessionCoordinator`，再通过 `ThreadAffineRimeEngineBridge` 进入同一套
controller path。

因此，编译边界满足 Assignment 要求：被测代码确实在 actual Extension target 内；没有通过
`KeyboardExtensionTests` 直接链接 `KeyboardViewController` appex symbol，也没有把生产
lifecycle 复制到测试 bundle。`UniverseKeyboardUITests` 只负责宿主选择/visibility stimulus。

### 3.2 Swift 6 隔离：当前形状可接受

- `P3D1LifecycleHarnessBootstrap` 只携带 `delayNanoseconds`，以
  `ThreadAffineRimeEngineBootstrap: Sendable` 传递 recipe；
- `P3D1LifecycleHarnessRimeEngine` 声明为 `nonisolated`，在 owner thread 内创建、调用和
  释放；MainActor 没有持有 live Fake/RIME engine；
- 跨边界的是 `ResponsiveRimeSnapshot`、diagnostic value snapshot 和其它 Sendable value，
  没有发现 `@unchecked Sendable`、engine handle shuttle 或不安全 isolation cast；
- `ThreadAffineRimeSpikeOwner` 的 mailbox 只接收 Sendable work descriptor，结果通过现有
  ordered delivery channel 回到 MainActor。

这证明的是 controlled Fake/Spike 的隔离形状，不是真实 `RimeEngineImpl`/librime/Lua 的
线程亲和性证明。

## 4. Compile flag、default-off 与 gate-off 边界

### 4.1 Compile flag default-off：成立

T02/T03 seam、Fake engine 和 lifecycle marker 均被
`#if DEBUG && T9_P3_D1_LIFECYCLE_HARNESS` 包围；工程 Debug/Release 配置没有把该 flag
写入默认设置，执行记录显示该 flag 只在指定 `build_sim` invocation 注入。UI test 另由
`P3_D1_T02_T03_RUN=1` 显式门控，普通 CI/Release-like invocation 会 skip。

`installP3D1LifecycleHarnessIfArmed()` 的 owner reuse 现在也检查 `coordinator.isOwnerReady`：
resume 后 owner 不 ready 时记录 `VISIBLE_NOT_READY` 并返回 false，不把存在 coordinator
误报成 ready。APPEAR_BEGIN 在 `resumePersistenceForExtensionLifecycle()` 之后，
SUSPEND_RELEASE 在 `suspendPersistenceForExtensionLifecycle()` 之前，避免生命周期 marker
被前后 persistence barrier 丢弃；这两项顺序修正符合证据意图。

### 4.2 Gate-off/ADR 0004：静态边界保持，但运行等价尚未证明

没有 harness flag 时，新增 seam 不编译；`KeyboardController` 的
`isResponsiveRimePipelineEnabled` 和 `isThreadAffineRimeOwnerEnabled` 默认仍为 `false`，
Responsive/ThreadAffine owner 不会从用户设置或 Release 配置启动。Gate-off 路径仍落回
ADR 0004 的同步 `rimeEngine` 调用，未发现 T02/T03 直接改动该路径。

但 execution record 只有 harness-on/gate-off **build** 通过，没有在 host 上完成两种运行的
行为等价观察。因此“gate-off remains behavior-equivalent”可以作为编译/静态边界结论，不能
作为 T02 已通过的 runtime 结论。

## 5. T02/T03 host boundary 复核

### 5.1 T02 stimulus 与断言边界

T02 的 UI method 在明确环境变量后启动 Messages，尝试通过 exact system keyboard switcher
选择 `Universe Keyboard`，再连续 tap 三个产品-owned key。若 switcher 属于 system UI/XCTest
不可达，它以 `XCTSkip` 记录 host boundary；没有把 skip 变成失败或 pass。

若未来 host 可达，当前断言只检查产品 surface 仍可见、应用仍在 foreground，并没有读取或
验证：

- 每个 accept 的 revision、action ID、pending depth 和 owner completion 数量；
- owner 真实创建/调用线程布尔值；
- ordered/no-drop/no-reorder 的完整序列；
- epoch mismatch/stale-result rejection；
- actual harness flag/build identity。

所以 T02 目前是 `Blocked`，即使 host 以后可达，也不能只凭“surface 仍在”把 required
invariant 全部标为 Passed。

### 5.2 T03 stimulus 与断言边界

T03 选择 Universe Keyboard 后输入一次，再离开 Messages conversation、重新打开并检查
product-owned surface。它没有把 process death、jetsam、App Group durability 或 raw host text
写入证据，符合 non-goal。

但是，当前 UI assertion 没有验证 `RETURN_CLEAN`、`CLEAR`、`SUSPEND_RELEASE` marker 的实际
顺序，也没有验证 old snapshot 被新 lifecycle epoch 拒绝。因此 T03 只能保持 Blocked；
surface labels 不是 lifecycle cleanup 证明。

## 6. Architecture Findings

### P2-T02/T03-01：suspend 后重建 owner 可能复用 epoch，旧通知缺少生命周期屏障

当前 actual lifecycle 顺序为：

1. `suspendKeyboardRuntime` 先调用 `controller.suspendRimeForVisibilityChange()`；
2. `ThreadAffineRimeSessionCoordinator.suspendForVisibilityChange()` flush/停止 owner，
   owner 进入 stopped 状态并被置空；
3. 随后 `cleanupTransientKeyboardState(..., abandonsComposition: true)` 调用
   `controller.abandonCompositionForVisibilityChange()`；
4. ThreadAffine 分支再调用 `affine.bumpSessionEpoch()`，但此时 owner 已 stopped，
   `advanceSessionEpoch()` 会返回 `nil`；
5. visibility return 时 `resumeAfterVisibilityChange()` 新建 owner，新 owner 从 epoch `1`
   开始。

Owner 结果通过 NotificationCenter 先投递到 MainActor。停止 owner 不会撤回已经排入主队列的
旧 snapshot；`sink.clearLastPublished()` 只清理 sink 状态，不取消已经排队的通知。若旧
epoch `1` 的通知在新 owner 建立/新的 epoch bump 之前交付，当前 presentation live-check
可能看到同样的 epoch `1`，从而把旧 snapshot 送入新的 controller presentation path。

这是由静态 lifecycle 顺序推出的 fail-closed 缺口，当前 host 被阻塞所以没有被运行证据确认。
它只影响显式 dual-gate diagnostic path；gate-off ADR 0004 同步路径没有异步 owner notification，
不能因此宣称 gate-off 已被破坏。但它会阻止 T03 的“old session/result 不泄漏到新 lifecycle”
合同通过。

**必须修复/证明：**在下一次 T03 运行前，必须让 visibility barrier 先获得不可复用的
session/lifecycle identity，或让 queued delivery 带 generation/token 并在新 lifecycle
fail-closed；至少补一个 owner 被 150 ms 阻塞、随后 hide/return、旧 result 延迟交付的
negative regression。修复不得打开默认 gate、改变 ADR 0004 同步路径或使用 unsafe isolation。

### P2-T02/T03-02：target harness flag、owner isolation 和 Run ID 没有可证伪 handshake

UI test 只检查 `P3_D1_T02_T03_RUN=1`。它没有确认宿主当前安装的 `Keyboard.appex` 由
`T9_P3_D1_LIFECYCLE_HARNESS` 编译，也没有要求日志中出现带实际 Run ID 的 harness-ready
marker。`activateUniverseKeyboard` 主要依赖 product-owned accessibility labels；一旦
host 可达，错误的 stale install 或 gate-off Extension 也可能通过 surface-only 断言。

此外，当前 `P3LIFE` lines 的 `run=P3D1-T02-T03` 是固定字符串，并非 execution record 的
`P3D1-T02-T03-SIM-20260802-232552`；`ownerThread=background`、`delayMs=150` 和 `slots`
由 Fake log 直接写出，未把 owner 实际创建/调用线程布尔值、accepted/applied/stale/
discarded counters 和 compile/build identity 绑定到同一 immutable Run ID。即使日志出现，
也不足以独立验证 T02 所要求的 ordered/no-drop/epoch-check 合同。

**必须修复/证明：**下一次 target run 必须有显式 handshake：target seam 产生带实际 Run ID、
source/build/flags fingerprint 的 content-free ready marker；marker 或受控导出必须携带
实际 owner-thread assertions、accepted/applied/published/stale/discarded watermarks 以及
lifecycle generation；UI test 必须在没有该 handshake 时保持 Blocked/Skipped，不能仅凭 surface
labels 通过。Run ID 不能硬编码为一个跨 run 常量。

### P3-T02/T03-03：changed-file 与 artifact provenance 仍不完整

Assignment 记录了三个当前 worktree source hash、build log 路径和 result bundle，但没有一个
独立的 T02/T03 changed-file allowlist，也没有在 execution record 中列出 Keyboard.appex/
UITest bundle hash、flag-resolved build settings、marker export hash 和 privacy-scan digest。
当前 dirty worktree 含多个其他任务的改动；若不补充 allowlist，后续复审不能只凭工作树
区分 harness seam 与 ambient changes。

**条件：**在任何 target evidence 被引用前，补齐冻结 source/build/flags/target/device
fingerprint、artifact hashes、content-free export/privacy scan 和 teardown/restore 状态。
这属于 P3 证据卫生，不把 host blocker 改写成产品失败。

### P3-T02/T03-04：gate-off 只有 compile 证据

当前 gate-off invocation 证明 flag 未导致编译失败，但没有 host runtime 的 A-path 行为观察。
在目标仍 Blocked 的前提下，这可以保持为未执行项；不得把“Debug gate-off build passed”
写成 ADR 0004 runtime equivalence 或性能结论。下一次 target run 应把 gate-off 和 harness-on
分开 Run ID，并明确两者的 build settings。

上述 findings 中没有发现 P0/P1；P2-01/P2-02 是关闭 T02/T03 runtime disposition 前的
必要条件，P3-03/P3-04 是证据交接条件。

## 7. 已证明与未证明

### 已证明（bounded）

- T02/T03 seam 确实位于 actual `Keyboard` Extension target，不是 XCTest bundle 的复制
  lifecycle double；host UI test 只提供 stimulus；
- config-only Sendable bootstrap、owner-thread 创建/使用/释放形状符合 Swift 6 约束，未发现
  `@unchecked Sendable` 或 live engine 跨隔离传递；
- lifecycle Fake 的 150 ms delay 位于 owner engine `processKey` 内，而不是 MainActor pre-hook；
- `DEBUG && T9_P3_D1_LIFECYCLE_HARNESS` 与显式 UI environment gate 保持 default-off；
  owner reuse readiness、APPEAR_BEGIN persistence 顺序、SUSPEND_RELEASE persistence 顺序
  的小修正方向正确；
- harness-on/gate-off `Keyboard` build 记录通过；KeyboardCore 相关 regression 记录
  `ThreadAffineRimeWireTests 9/0`、full `KeyboardCore 894/0`；这些仍是 bounded build/Core
  evidence；
- Messages switcher 不可达时 T02/T03 记录为 `Blocked / Skipped`，没有伪造 target lifecycle
  success。

### 未证明

- host 实际加载本次带 harness flag 的 `Keyboard.appex`，以及 target marker 与 immutable Run
  ID 的绑定；
- MainActor accept 在真实 target owner block 期间不等待、三次工作保序且不丢/不乱序；
- actual owner 创建/调用线程、epoch/revision late-result rejection 和 marker order；
- visibility abandon/return/reload 后的 stale snapshot fail-closed、marked-text 清理和
  controller state cleanup；
- real `RimeEngineImpl`/librime/Lua/schema、R01/R02、iPhone 13 Pro、persistence、memory/
  jetsam、Release 或 Product Gate。

## 8. ADR 与治理边界

### ADR 0004（Accepted）

本实现没有把 diagnostic Fake 接入 Release 或用户设置；没有改变 gate-off 的同步
`rimeEngine` path、MainActor UI/text-proxy ownership 或主 App deployment boundary。上面的
P2-01 是显式 dual-gate lifecycle contract 的缺口，不应被解释为 ADR 0004 已被修改或已被
证明安全。

### ADR 0025（Proposed）

T02/T03 只提供 controlled target evidence seam，未接受 ADR 0025，未把真实
`RimeEngineImpl` 接到 off-main owner，未扩大 auto-anchor，未使用 unsafe isolation；ADR 0025
仍为 Proposed，双 gate 仍 default-off。

### Product Gate / Release

当前结果不能形成 Product Gate、Release default-on、真实 off-main RIME、主观不卡顿、真机
通过或持久化/jetsam 结论。T02/T03 的 Blocked 运行状态必须原样交给 Quality/Product Lead。

## 9. Final disposition、Quality handoff 与停止点

**Architecture disposition：Pass with conditions（implementation shape review complete;
runtime proof blocked）**。

最终判定：

1. actual target seam、Swift 6 owner isolation、无 `@unchecked Sendable`、compile flag
   default-off 和 parent matrix 的 host `Blocked` 分类均成立；
2. T02/T03 **不得**由当前 build 结果升级为 Passed/Partial runtime；当前保持
   `Blocked (host accessibility)`；
3. P2-T02/T03-01（生命周期 epoch/generation barrier）和 P2-T02/T03-02（可证伪 target
   handshake/Run ID/owner assertions）必须在下一次 target run 前修复或由 Product Lead 明确
   接受为未闭合 residual；
4. P3-D1 继续 Active，T01 仍 Partial，R01–R06 仍 NotRun；不接受 ADR 0025，不宣布 Product
   Gate、Release default-on 或 physical success。

**Quality 复审建议：建议继续，但限定为独立的 blocked/implementation-quality 复审。** Quality
可以现在核对 changed-file、privacy、Run ID、skip/Blocked 处理和 build/Core regression；
不能把当前结果写成 T02/T03 Pass。若 Quality 的 exit 要求必须先消除 Architecture P2，则应把
P2-01/P2-02 作为其前置条件，并在 host 可达、handshake 可验证后重新执行 T02/T03。

本 Architecture 复审至此停止。除本文件外没有产生代码、测试、ADR、默认 gate、设备或发布
变更。
