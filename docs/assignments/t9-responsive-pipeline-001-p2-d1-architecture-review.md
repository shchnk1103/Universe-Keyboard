# 独立 Architecture 复审：T9-RESPONSIVE-PIPELINE-001 / P2-D1

复审日期：2026-08-02（Asia/Shanghai）
复审角色：Independent Architecture reviewer（F-01/F-02/Q1 关闭后复审）
复审范围：P2-D1 marker contract、证据合同与 Proposed ADR amendment，以及
KeyboardCore 中对应的 validator、felt metrics、controller wiring 和专项测试。
结论：**Pass with conditions（有条件通过）**

严重度摘要：**P0/P1/P2/P3 = 0/0/0/1**。

本轮复审针对上一轮 F-01/F-02 与 Q1：owner completion 幂等、
duplicate-owner-publish 拒绝、engine `VISIBLE/PAINT` 顺序约束、epoch regression
fail-closed、epoch 变化时 tracker 清理，以及 explicit preflight felt marker 的
mandatory channel 修复。F-01、F-02 与 Q1 均已关闭；剩余条件是实际 runtime 的
reset/recover/late-result 生命周期和真实 runtime/设备证据边界。

本复审只覆盖诊断契约与现有显式 preflight/Spike 接线。它不接受 ADR 0025，
不宣布 Product Gate、Release 或真实设备验证通过，也不改变任何生产默认值。
本次只更新本复审文档；没有修改生产逻辑、测试或既有合同。

## 1. 证据与边界

### 1.1 已读输入

- [`P2-D1 Marker Contract`](t9-responsive-pipeline-001-p2-d1-marker-contract.md)
- [`P2-PERF-02 Evidence Contract`](t9-responsive-pipeline-001-p2-perf-02-evidence-contract.md)
- [`ADR 0025`](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md)，仅以 Proposed amendment 读取
- `Packages/KeyboardCore/Sources/KeyboardCore/T9ResponsiveEvidenceValidator.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/ResponsiveRimeFeltMetrics.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/ResponsiveRimePreflight.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/ThreadAffineRimeSession.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+RimeRecovery.swift`
- 相关测试：`T9ResponsiveEvidenceValidatorTests.swift`、
  `ResponsiveRimeFeltMetricsTests.swift`、`ResponsiveRimePreflightTests.swift`、
  `ThreadAffineRimeWireTests.swift` 与 `ThreadAffineRimeSpikeTests.swift`

### 1.2 未纳入本次判断

- 真实 `RimeEngineImpl`、真实 Lua、Extension 安装/运行、真机或 jetsam；
- App Group 原始日志的完整性、设备 Run Header、Full Access 与 Release 构建；
- P2-H-06 历史 B 证据的重算。历史证据仍应保持 `Partial`；
- 工作树中与 P2-D1 allowlist 无关的 ambient changes。它们未被覆盖、未被清理。

## 2. 契约核对矩阵

| 阶段 | 合同语义 | 当前实现/证据 | Architecture 判断 |
|---|---|---|---|
| `ACCEPT` | MainActor 接受并入队 revision | `recordAccept` 保存 epoch、revision、pending，并输出 content-free marker（`ResponsiveRimeFeltMetrics.swift:109-134`）；controller 在 `scheduleProcessKey` 后记录（`KeyboardController.swift:756-764`） | **满足**。没有把用户文本放进 marker。 |
| `PUBLISH` | serial owner 完成并交付；epoch-bound；不承载 UI timing | validator 拒绝 `lagMs/pendingAfter/coalesced`，并拒绝同一 epoch/revision 的重复 owner publish（`T9ResponsiveEvidenceValidator.swift:373-405`）；`recordOwnerCompletion` 对 tracker reset 作用域内的 revision 幂等（`ResponsiveRimeFeltMetrics.swift:180-200`） | **满足（epoch-reset scoped）**。 |
| `VISIBLE` | MainActor 实际应用可见 composition snapshot | `performResponsivePresentationApply` 在 MainActor 应用后记录 engine VISIBLE；L1 provisional 另行记录（`KeyboardController.swift:358-390`、`707-717`） | **满足**。最新 UI coalescing 不被解释为 owner publish。 |
| `PAINT` | UI presentation timing/coalescing；可 latest-only | `presentationLagMarkerLine` 已输出 `PAINT`，`recordPresentation` 记录 pending/coalesced/burst（`ResponsiveRimeFeltMetrics.swift:45-65`、`196-239`） | **满足**。专项测试覆盖 marker 形状和 burst。 |

### 2.1 `PUBLISH` 与 coalescing 的关系

`applyResponsivePublishedSnapshot` 在 latest-only 判断之前记录 owner completion（
`KeyboardController.swift:247-274`），因此中间 revision 即使没有 `VISIBLE/PAINT`，
也仍有机会保留 owner `PUBLISH`。`ResponsiveRimeFeltMetricsTracker` 以
`completedOwnerRevisions` 做 reset 作用域内的一次性去重；重复 notification 不再产生
第二行 owner marker。epoch barrier 清理该去重窗口后，新的 epoch 可以复用 revision；
对应的 `testOwnerCompletionAllowsRevisionReuseAfterEpochChange` 回归已覆盖这一边界。
`performResponsivePresentationApply` 只输出 `PAINT` 和 `VISIBLE`，没有再输出带 UI
字段的第二种 `PUBLISH`。

## 3. 逐项审查结果

### 3.1 sync A 不要求响应式链：满足

`T9ResponsiveEvidenceExpectation` 以 arm 默认 `requireResponsiveFeltMarkers`；
sync 默认关闭该要求。validator 只有在该开关开启时才加入
`publish-marker-missing`、`accept-revisions-not-complete` 和 epoch-bound publish
检查（`T9ResponsiveEvidenceValidator.swift:498-519`）。现有
`testSyncArmDoesNotRequireResponsiveFeltMarkers` 也明确验证了 sync fixture 没有
`ACCEPT/PUBLISH` 仍可完成。

这只证明诊断 validator 的 arm 语义；它不证明任何真实设备 A 运行结果。

### 3.2 thread-affine B 的 epoch/revision：基本满足

- `ACCEPT` 必须有正 epoch/revision、非负 pending，并绑定 fixture；
- `PUBLISH` 必须有正 epoch/revision、匹配 accepted epoch，且不能携带 UI 字段；
- thread-affine 需要每个 accepted revision 的 epoch-bound publish；
- `PAINT`/`VISIBLE` 只能引用已 accepted revision。
- validator 的 `lastPublishedEpoch` 单调检查与 metrics tracker 的 epoch-change
  reset/revision-reuse 回归，覆盖了 epoch regression 的诊断合同。

这些检查由 `T9ResponsiveEvidenceValidator` 的 marker 分支实现，专项 fixture 覆盖
缺一个 epoch-bound publish、PAINT 不能替代 PUBLISH、重复 owner PUBLISH，以及 UI
字段污染 PUBLISH。新增的 engine `VISIBLE/PAINT` 顺序回归确认：provisional VISIBLE
可以先于 owner completion，但 engine VISIBLE/PAINT 必须在 PUBLISH 之后。

### 3.3 privacy：满足（有范围限制）

`containsPrivacySensitiveContent` 将 `candidates=` 单独解析，只接受 token 中的非负
数字（允许日志常见的 `,`/`;` 结尾），candidate text 和 malformed value 仍 fail
closed（`T9ResponsiveEvidenceValidator.swift:787-819`）。专项测试覆盖 count、文本和
`12ms` malformed 三种情况。

该规则是 content-free 日志规则，不是候选内容脱敏证明；真实 App Group 日志仍需独立
检查来源和导出完整性。

### 3.4 Swift 6 隔离与默认 gate：满足当前边界

- `ThreadAffineRimeSession` 以 Sendable bootstrap 传递 recipe；live engine 在 owner
  thread 创建、使用和释放；跨边界的是 immutable `ResponsiveRimeSnapshot`，没有发现
  `@unchecked Sendable`；
- owner 结果经单一 delivery channel 回到 MainActor；felt tracker 本身是
  `@MainActor`；
- `KeyboardController` 的 `isResponsiveRimePipelineEnabled` 与
  `isThreadAffineRimeOwnerEnabled` 默认均为 `false`，gate-off 测试仍要求同步路径；
- explicit preflight 下 ACCEPT、VISIBLE、PAINT、BURST 与 owner PUBLISH 统一走
  `recordResponsiveFeltMarker` → `devicePreflightPerformance` mandatory channel；
  普通构建仍走 `performance`，没有扩大普通用户的 persistence side effect；
- Swift 6 全源码 typecheck 在普通配置与 `-D T9_AUTO_ANCHOR_DEVICE_PREFLIGHT`
  配置下均 exit 0；这证明当前隔离/宏组合可编译，不等价于 Release 或真实 runtime
  证明；
- ADR 0025 与 P2 evidence contract 仍标记为 Proposed。

这不是对真实 librime 的线程亲和性证明，也不是对 Release 编译宏组合的最终证明。

## 4. 修复复核与残余条件

### 4.1 F-01：已关闭 — owner completion 幂等与重复拒绝

`ResponsiveRimeFeltMetricsTracker.recordOwnerCompletion` 现在在匹配 accepted
epoch/revision 后写入 `completedOwnerRevisions`，同一 tracker reset 作用域内的第二次
delivery 返回 `nil`（`ResponsiveRimeFeltMetrics.swift:180-200`）。这覆盖了
ordered-now 返回 snapshot 与 NotificationCenter 再投递同一 snapshot 的交互。

Validator 同时维护 epoch-bound owner revisions，重复 revision 会加入
`duplicate-owner-publish`，最终为 `Partial`；对应的
`testDuplicateOwnerPublishIsPartial` 与 tracker 幂等断言已补入专项测试。F-01 的
“重复 owner PUBLISH 可能静默通过”问题已关闭。

边界：去重集合是 **epoch-reset scoped**，不是无限期历史 ledger。当前 Q1 回归已证明
epoch barrier 清理 tracker 后可以安全复用新 epoch 的 revision；这关闭了 bounded
诊断合同缺口，但不替代真实 runtime 生命周期验证。

### 4.2 F-02：已关闭 — engine presentation 顺序

Validator 现在在 engine `VISIBLE` 或 `PAINT` 引用已 accepted revision、但尚未观察到
相同 revision 的 owner `PUBLISH` 时记录 `engine-presentation-before-publish`；
provisional VISIBLE 仍允许先于 PUBLISH（`T9ResponsiveEvidenceValidator.swift:345-428`）。
`testEngineVisibleAndPaintMustFollowOwnerCompletion` 覆盖了负向顺序，且现有完整
fixture 保持合法顺序。F-02 的证据顺序缺口已关闭。

### 4.3 Q1：已关闭 — epoch regression 与 tracker revision reuse

validator 的 `lastPublishedEpoch` 单调检查与
`testEpochRegressionIsPartial` 已覆盖 epoch 回退时的 fail-closed 诊断；metrics
tracker 在 epoch barrier 后清空 `completedOwnerRevisions`，
`testOwnerCompletionAllowsRevisionReuseAfterEpochChange` 已证明新 epoch 可以复用
旧 revision 而不会被旧的去重窗口挡住。因此，原 R-01 中“revision reuse 未覆盖”的
bounded 缺口已关闭；本次复审覆盖最终 tip 在 epoch 变化时清空 `accepts`、paint 与
`lastVisible`，并覆盖旧 epoch late completion 返回 `nil`，但真实 runtime 生命周期
仍未证明。

### R-01 / P3：真实 runtime 与环境证据仍未覆盖

Q1 的 validator 与 tracker 回归已证明 epoch regression 的 bounded 合同，但还没有
证明真实 owner 在 `resetSession`/`recoverSession` 后清理 tracker、丢弃旧 epoch
late result 并正确处理新 revision。以下证据也仍未执行：真实 `RimeEngineImpl`/librime
与 Lua、Simulator/Extension 集成、真机、Release 构建、Extension suspend/jetsam、
队列上限、App Group 日志持久化时序，以及主观不卡顿。`devicePreflightPerformance`
虽绕过 category filter，仍经异步 writer；单元测试不能替代 suspend 前 durable handoff
和 run-bound 导出完整性检查。这些属于后续 R4/R5/Release 授权边界，不改变本复审结论。

## 5. 测试证据

### 5.1 静态专项覆盖

可见 fixture 已覆盖 sync-positive、thread-affine missing-publish、owner-completion/
paint separation、coalescing、privacy count/text/malformed、默认 gate off、duplicate
owner publish、engine-before-publish、epoch regression/revision reuse，以及 explicit
preflight marker channel。新增的 `testDuplicateOwnerPublishIsPartial`、
`testEpochRegressionIsPartial`、`testOwnerCompletionAllowsRevisionReuseAfterEpochChange`、
tracker 幂等断言和 `testEngineVisibleAndPaintMustFollowOwnerCompletion` 与本轮修复一一
对应。

### 5.2 本轮独立执行状态

本轮采用 Executor 提供的最终 KeyboardCore XCTest 与 Swift 6 typecheck 结果：

```text
P2-D1 focused validator: 28 passed / 0 failed
ResponsiveRimeFeltMetrics focused: 5 passed / 0 failed
KeyboardCore full suite: 894 passed / 0 failed
Swift 6 whole-source typecheck (ordinary): exit 0
Swift 6 whole-source typecheck (-D T9_AUTO_ANCHOR_DEVICE_PREFLIGHT): exit 0
```

上述结果是本轮审计使用的最终测试证据；本 sub-agent 未在受限 sandbox 中重复执行，
此前独立重跑曾遇到共享 SwiftPM/module-cache 权限阻塞。测试与 typecheck 结果不扩展
为真实 runtime、真机或 Release 证明。

## 6. 已证明与未证明

### 已证明（代码/合同层）

- 四类 marker 的字段职责已拆开：UI timing 使用 `PAINT`，owner completion 使用
  epoch-bound `PUBLISH`；
- sync arm 不再被强制要求 `ACCEPT/PUBLISH`；
- thread-affine validator 具备 accepted→epoch-bound publish 的完整性检查，并拒绝
  duplicate owner publish 与 engine presentation-before-publish；
- tracker 对 ordered-now/notification 双投递在 reset 作用域内幂等；
- epoch regression 的 validator fail-closed、epoch barrier 清理 tracker，以及
  新 epoch revision reuse 已有专项回归覆盖；
- privacy validator 对 numeric candidate count 与 candidate text/malformed 做了不同处理；
- explicit preflight 的 ACCEPT/VISIBLE/PAINT/BURST/owner PUBLISH 走 mandatory
  `devicePreflightPerformance` channel，普通构建仍保留常规 `performance` 路径；
- MainActor、owner thread、Sendable snapshot 与默认 gate 边界没有被 P2-D1 改动为
  Release 默认开启。

### 未证明

- 真实 librime 调用是否始终只发生在 owner thread；
- Extension 真机/Release 下的 marker 顺序、日志持久化、jetsam、队列上限和主观不卡顿；
- 真实 runtime 的 reset/recover/late-result 生命周期是否与上述 bounded 合同一致；
- 最终测试结果之外的设备/Release 证据是否完整；
- P2-H-06 历史 B 证据是否因新合同而自动变为完整（不会自动变更）。

## 7. Architecture disposition 与停止点

**Bounded result：Pass with conditions（review complete）。**核心 D1 语义拆分、
arm-aware sync 规则、privacy count 规则、F-01/F-02/Q1 修复、Swift 6/默认 gate 边界，
以及最终 28/0、5/0、894/0 测试结果和两种 Swift 6 全源码 typecheck exit 0 均可接受；
仍需保留 R-01 的真实 runtime reset/recover/late-result、librime/Simulator/真机、
Release、jetsam 与持久化证据边界。

本复审到此停止，交由 Coordinator 汇总独立 Quality 结果，并由 Product Lead 决定是否
另行授权真实 runtime/设备矩阵。除非另有授权，不得据此接受 ADR 0025、开启 Release
默认 gate、重跑 R4/R5 真机或宣布 Product Gate。
