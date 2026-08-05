# 独立 Quality 复审（修复后）：T9-RESPONSIVE-PIPELINE-001 / P3-D1-T02/T03

| 字段 | 结论 |
|---|---|
| 复审角色 | 🧪 Quality, Performance & Release Maintainer（独立、只读） |
| 复审日期 | 2026-08-03（Asia/Shanghai） |
| 复审对象 | [`P3-D1-T02/T03 Lifecycle Harness`](t9-responsive-pipeline-001-p3-d1-t02-t03-lifecycle-harness.md) |
| 前一轮复审 | [`T02/T03 Quality review`](t9-responsive-pipeline-001-p3-d1-t02-t03-quality-review.md) |
| 关联矩阵 | [`P3-D1 Runtime Lifecycle Evidence Matrix`](t9-responsive-pipeline-001-p3-d1-runtime-lifecycle-matrix.md) |
| 复审基线 | `HEAD=3585a54`；当前工作树仍含 ambient 未提交改动，本复审不归因、不覆盖、不暂存 |
| Quality disposition | **Pass with conditions（增量修复后的 bounded harness）；T02/T03 runtime 仍为 Blocked** |
| P0 / P1 / P2 / P3 | **0 / 0 / 2 / 1**（增量复审后；前一快照为 0 / 0 / 3 / 1） |
| 治理边界 | 不改生产逻辑、默认 gate、ADR 0025 状态、Product Gate、Release 或真机结论 |

本记录包含上一轮 T02/T03 复审及其后的短增量复核。增量复核重点检查：
`waitForP3D1LifecycleDiagnostic` 超时回退、T03 `returnClean` handshake、跨 epoch revision
reset validator 规则和最新回归数字；Run ID/marker 合同、
`P3D1LifecycleHarness` accessibility handshake 是否 fail-closed、宿主前置条件 Skip、
owner restart 的 lifecycle epoch stale regression，以及最新执行记录的 provenance。
本轮只新增本复审文档；没有修改代码、测试、工程设置或默认行为。

## 1. 范围与输入

已读并交叉核对：

- T02/T03 Assignment 的最新 execution record、privacy/Run ID 合同、stop/exit 边界；
- P3-D1 runtime lifecycle matrix 中 T02/T03 的当前状态；
- `KeyboardViewController.swift`、`KeyboardViewController+Bootstrap.swift`、
  `KeyboardViewController+Presentation.swift` 的 harness-only seam；
- `NativeExperienceKeyboardAutomationFeasibilityTests.swift` 中 T02/T03 host-driven XCTest；
- `ThreadAffineRimeSession.swift` 与 `ThreadAffineRimeWireTests.swift` 的 owner restart/epoch
  修复和回归；
- `P3D1LifecycleEvidenceValidator` 及其 KeyboardCore 回归测试；
- P2-D1 marker contract（`PUBLISH`/`VISIBLE`/`PAINT` 的既定语义）。

本轮没有重新执行 Xcode build、UI XCTest 或 KeyboardCore 全量；以下 Wire 10/0、validator
6/0、Core 901/0、build 和 UI result bundle 数字均标为执行器提供的 bounded snapshot。
`git diff --check` 由本轮独立
检查通过。

## 2. 最新执行记录与 provenance

执行器最新记录的 Run ID 为 `P3D1-T02-T03-SIM-20260803-001`，Simulator 为 iOS 27.0 /
iPhone 17 Pro Max / `06C5BC3E-7599-4761-A1A2-71DAEA991474`，Debug，UI scheme 为
`UniverseKeyboardUITests`；harness-on 编译旗标为
`DEBUG T9_P3_D1_LIFECYCLE_HARNESS`，UI gate 为 `P3_D1_T02_T03_RUN=1`，marker token 为
`P3_D1_T02_T03_RUN_ID=P3D1-T02-T03-SIM-20260803-001`。

| 检查 | 执行记录 | 本轮解释 |
|---|---:|---|
| Keyboard Extension harness-on compile | Passed | 只证明指定 Debug target 可编译，不证明 target lifecycle 已运行 |
| Keyboard Extension gate-off compile | Passed | 支持显式 harness flag 未写入默认 build 条件；不等于 host runtime 等价 |
| T02 host-driven UI | Blocked / Skipped | Messages 没有暴露可证明的 Apple system keyboard activation boundary |
| T03 host-driven UI | Blocked / Skipped | 同一 host accessibility boundary；没有 target lifecycle marker sequence |
| `ThreadAffineRimeWireTests` | **10 / 0** | 包含 owner restart 后旧 epoch snapshot 被拒绝的回归；仍是 Core/bridge 证据 |
| `P3D1LifecycleEvidenceValidatorTests` | **6 / 0** | 跨 epoch revision reset、Run ID/shape/privacy/order 的纯值 validator；不能替代 target export |
| `Packages/KeyboardCore` full | **901 / 0** | 组件层 bounded regression；不能替代 Extension runtime 或真实 RIME |
| `git diff --check` | Passed | 本轮独立检查通过 |

最新 Assignment 记录的 build log/result bundle 路径为（当前复审环境均不存在，无法重新打开）：

- harness-on build：[`build_sim_2026-08-02T16-17-30-946Z_pid40269_94150708.log`](/Users/doubleshy0n/Library/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/logs/build_sim_2026-08-02T16-17-30-946Z_pid40269_94150708.log)；
- gate-off build：[`build_sim_2026-08-02T16-18-05-079Z_pid40269_f2122b35.log`](/Users/doubleshy0n/Library/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/logs/build_sim_2026-08-02T16-18-05-079Z_pid40269_f2122b35.log)；
- T02/T03 result：[`test_sim_2026-08-02T16-19-23-797Z_pid40269_b0e95931.xcresult`](/Users/doubleshy0n/Library/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-08-02T16-19-23-797Z_pid40269_b0e95931.xcresult)。

因此上述结果可以作为最新执行器快照使用；本角色没有重新打开/重跑这些 artifact，不能把
它们升级为本轮 fresh rerun 或 target runtime 证明。

### 2.1 Source fingerprint 复核

最新 Run 的 Assignment source fingerprint 与当前工作树重新计算的 SHA-256 如下：

| 文件 | Assignment 记录 | 当前工作树 | 判定 |
|---|---|---|---|
| `Keyboard/Controllers/KeyboardViewController+Bootstrap.swift` | `90904e6fca385e71c02a37e4a6739a377ae6d7df0ecd7bc273c82f6cdb71ee5c` | 同值 | 一致 |
| `Keyboard/Controllers/KeyboardViewController.swift` | `294d74878018e25bbdec59202cbb0bc62cb02ae2b2e9aa5f48bacadc719de31a` | 同值 | 一致 |
| `Keyboard/Controllers/KeyboardViewController+Presentation.swift` | `22554f0cffa54d862b684679c422561a68e399e1c914dfdcdb19f54d3eb6f9ab` | 同值 | 一致 |
| `Packages/KeyboardCore/Sources/KeyboardCore/ThreadAffineRimeSession.swift` | `00d490e91024db2b16f2e9217efa15b4760f9cebff3b5c486c36012f1d84cfb6` | 同值 | 一致 |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/ThreadAffineRimeWireTests.swift` | `4d6d31a7adb91450172a677b848e2288beaf038e0dd77f562abcfdaa6cd4ab10` | 同值 | 一致 |
| `Packages/KeyboardCore/Sources/KeyboardCore/P3D1LifecycleEvidenceValidator.swift` | `8fc6421b61650c90a4da86b295492f50c8cef852ab1a6164707989fd49dd457b` | 同值 | 一致 |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/P3D1LifecycleEvidenceValidatorTests.swift` | `b640688bdd81e98fbdf02b77c3cadca818b5edba733ddfa502bc3f25a0cf606e` | 同值 | 一致 |
| `UniverseKeyboardUITests/NativeExperienceKeyboardAutomationFeasibilityTests.swift` | `9073950761a8c836deb0888d845fb1c8351d38896607584642728d92c21905d8` | 同值 | 一致 |

最新记录的 changed-file hashes 与当前工作树一致，修复了上一快照中
`KeyboardViewController+Presentation.swift` 的记录不一致。不过，source hash 一致仍不证明
Messages 实际加载了 harness-on appex；target Run ID ↔ marker、resolved build-settings、
appex/UI bundle hash 和 marker export/privacy digest 仍由 Q3 保留。

## 3. 已确认的正向修复

### 3.1 Run ID 与默认开关边界

- Fake owner 和 target lifecycle marker 现在读取 `P3_D1_T02_T03_RUN_ID`，缺省时为每个
  process 生成经清洗、限长的 UUID；marker 形状包含同一个 `run=` 字段，已不再是上一轮的
  固定常量。
- harness/Fake/accessibility element 都在 `#if DEBUG && T9_P3_D1_LIFECYCLE_HARNESS` 下；
  工程默认 Debug 条件只包含 `DEBUG`，没有把 harness flag 写入 project 默认或 Release。
- 没有发现本 seam 使用 `@unchecked Sendable` 或将 live engine 跨隔离传递；跨边界的仍是
  config recipe/value snapshot。

这关闭了上一轮“固定 Run ID/默认 arm”的主要实现问题，但不等于 UI test 已经验证 token。

### 3.2 Host precondition 的 Skip 归因

T02/T03 现在在以下宿主条件缺失时使用 `XCTSkip`，并保留明确的 host boundary 原因：

- 初始 keyboard surface 不可见；
- Apple system keyboard activation/switcher 不可达；
- T03 的 conversation back boundary 不可达；
- 返回后 keyboard surface 或 product-owned accessibility controls 不可见。

这项修复是正确的：宿主系统 UI 不可驱动时不会被写成 Universe Keyboard 产品失败，也不会
用 coordinate typing、数字页、候选点击或 surface-only 观察伪造 T02/T03 通过。矩阵中的
T02/T03 应继续保持 **Blocked (host accessibility)**。

### 3.3 Lifecycle epoch stale regression

`ThreadAffineRimeSessionCoordinator` 把 `lifecycleEpoch` 放在可替换 owner 之外；visibility
abandon 在 owner 停止后仍保留 coordinator epoch，replacement owner 启动时重放该 epoch。
新增的 `testVisibilityOwnerRestartPreservesEpochAndRejectsStaleSnapshot` 覆盖：

1. abandon 后 epoch 从 1 变为 2；
2. owner 缺失期间诊断仍显示 epoch 2；
3. stopped owner 期间的旧 epoch snapshot 不触发 presentation；
4. replacement owner 仍为 epoch 2，旧 snapshot 仍不触发 presentation。

结合执行器的 `ThreadAffineRimeWireTests 10/0`，这是本轮最重要的 P2-D1 生命周期 residual
修复，判定为 **Passed（bounded Core/bridge）**。它仍不是 host-driven T03 的实际 target
marker 证明。

## 4. Quality findings

### P2-T02/T03-Q1（前一快照）：accessibility handshake 的 XCTest 读取逻辑并不真正 fail-closed

`waitForP3D1LifecycleDiagnostic` 在超时后执行：如果 handshake element 存在，就返回其当前
值，即使该值没有请求的 token。T02 请求 `marker=PUBLISH`，T03 请求 `cleared=1`；因此一个
已经存在但停留在 `SURFACE_READY`、`VISIBLE_READY`、旧 marker 或其他不匹配状态的 element，
仍会使后续 `XCTAssertNotNil` 继续执行。测试也没有校验：

- `schema=v1`；
- `run=<本次预期的 P3_D1_T02_T03_RUN_ID>`；
- `marker` 是否确实是当前 T02/T03 所需阶段；
- T03 的 `marker=RETURN_CLEAN` 与当前 return epoch 的绑定。

仓库虽然新增了 `P3D1LifecycleEvidenceValidator` 和对应 KeyboardCore 测试，但 UI XCTest
没有调用该 validator，也没有把 UI 读到的 value 导出给 validator。另一个问题是
`p3d1LifecycleLastCleared` 使用 sticky OR；一旦之前的 disappear/clear 把它置为 1，后续任意
marker 都会继续显示 `cleared=1`，所以 T03 的 `containing: "cleared=1"` 不能证明本次
visibility return 刚刚完成清理。

这会造成 bounded harness 证据的 false-positive 风险，故列为 P2；不改变当前 host run 已
被 Skip 的事实。

**前一快照的关闭条件：** helper 在超时或 value 不匹配时必须返回 `nil`；T02/T03 至少校验 schema、
准确 run ID、精确 marker/阶段和相应 epoch/revision 水位。`cleared` 应绑定到当前
`RETURN_CLEAN`/lifecycle generation，而不是进程级 sticky 状态；UI 或导出的 marker stream
应经过同一 fail-closed validator。

### P2-T02/T03-Q2：P3LIFE 的 `PUBLISH` 与既定 owner/UI marker 语义冲突

P2-D1 已冻结：`PUBLISH` 是 serial owner 完成并交付 revision，`VISIBLE` 是 MainActor 应用可见
snapshot，`PAINT` 是可被 coalesce 的 UI timing。当前 `KeyboardViewController+Bootstrap.swift`
却在 `onResponsivePresentationNeeded` 回调中先 `syncUI(with:)`，再发出
`P3LIFE marker=PUBLISH`；这条回调是 UI presentation bridge，不是 owner completion 边界。
因此同一个名字在 `T9RESP`/P2-D1 和 `P3LIFE` 中表示了两个不同事件。

同时，P3LIFE 的 `applied=` 是 UI callback 次数，而不是 applied revision watermark；
`discard=` 读取的是 `rejectedAtBoundCount`（入队边界拒绝），不是 late/stale snapshot discard。
UI T02 只检查 `accepted=`/`applied=` 字段存在，也没有检查 revision 对齐、owner begin/end、
accepted→owner completion 的顺序或无丢失/乱序。这样即使以后 host 可达，`marker=PUBLISH`
也不能单独证明 Assignment 所写的 owner-completion 合同。

**关闭条件：**P3LIFE 应使用不与 P2-D1 冲突的 UI 名称（例如 `APPLIED`/`VISIBLE`），或直接
复用 owner completion 的 `T9RESP marker=PUBLISH` 并单独记录 UI `VISIBLE`/`PAINT`；字段
 语义要区分 accepted/applied/stale/discard 水位，且 T02 断言必须验证同一 run、epoch、revision
 关系，而非只做字符串字段存在性检查。

### P2-T02/T03-Q3（前一快照）：执行快照尚未与当前 source/artifact 完整绑定

前一快照中 `KeyboardViewController+Presentation.swift` 的 SHA-256 与 Assignment 记录不一致，
且本复审环境无法打开当时的 XcodeBuildMCP build logs/result bundle。该问题是 evidence
integrity residual，不是已观察到的产品行为失败；最新 Run 已重新记录 changed-file hashes，
其当前 disposition 见 §7.1 Q3。

**关闭条件：**下一次 target rerun 使用新 opaque Run ID，同时重新生成六个 changed-file hash、
resolved build settings/compile flags、Keyboard.appex/UI bundle hash、build log/result bundle
hash 和 content-free marker export/privacy digest；旧 Run ID 必须标记为 superseded 或明确
仅作历史 blocked snapshot。

> **增量复核说明：**上面的 Q1 是修复前快照。后续修改已让 helper 在超时后返回 `nil`，
> T03 改为等待 `returnClean=1`，并在 P3LIFE 行中增加 `returnClean` 字段；因此“超时返回
> 任意旧 value”的 P2 条件在 bounded XCTest 读取层关闭。`returnClean` 仍是 target 进程内的
> sticky diagnostic 状态，且当前 host 没有激活 target，所以当前 Run ID/生命周期 generation
> 绑定仍归入 Q3，而不是宣称 T03 runtime 已通过。

## 5. 分层判定（前一快照）

| 证据层 | Quality 判定 |
|---|---|
| Run ID 生成/marker 字段静态形状 | **Partial positive**：源码已注入 per-run token，但 UI 没有校验预期 token |
| Accessibility handshake | **Partial positive**：超时不再返回旧 value；实际 target marker/run 仍未在 host 中观察 |
| Host precondition handling | **Passed（bounded）**：缺失条件统一 `XCTSkip`/Blocked；不误报产品失败 |
| Lifecycle epoch/restart stale rejection | **Passed（bounded Core/bridge）**：Wire 10/0 + 专项旧 epoch negative regression |
| Harness-on/gate-off compile | **Passed（latest executor snapshot）**：新 Run ID 的 logs 未在本环境重新打开；不等于 runtime |
| T02 owner responsiveness target runtime | **Blocked / Not proven**：host activation 前 Skip，无 owner marker sequence |
| T03 visibility/return target runtime | **Blocked / Not proven**：host activation 前 Skip，无 lifecycle marker sequence |
| Real RIME/Lua/schema、physical device、persistence、jetsam | **NotRun** |
| ADR 0025 / Product Gate / Release default-on | **未授权且未宣布** |

## 6. Handoff 与停止点

### 本轮确认

- run token 从固定常量修复为外部注入或 per-process sanitized UUID；harness 仍是明确
  DEBUG compile arm，默认 gate-off 边界未被打开；
- host UI 前置缺失现在正确走 Skip；当前 T02/T03 仍应写作 **Blocked (host accessibility)**；
- coordinator-owned lifecycle epoch 和 replacement-owner replay 已有 Core/bridge stale
  negative regression，最新执行记录为 Wire **10/0**、P3D1 validator **6/0**、KeyboardCore
  full **901/0**；
- 没有发现本次 seam 使用 `@unchecked Sendable`、写入 raw input/candidate/host text，或把
  harness 接入 Release 默认路径。

### 仍未证明

- 目标 Extension 实际加载本次 harness-on appex，并在一个 Run ID 下产生完整 owner/lifecycle
  marker stream；
- accessibility handshake 对错误 run、旧 marker、sticky `returnClean` 与 target generation
  的完整 fail-closed 行为；超时返回旧 value 的 helper 缺陷已由 bounded 修复关闭；
- owner completion 与 UI presentation 的 PUBLISH/VISIBLE/PAINT 语义分离；
- T02 的真实 MainActor accept→owner delay→ordered result，T03 的实际 disappearance/return/
  reload marker sequence；
- source/build/result provenance 与当前 source 完整绑定；
- real `RimeEngineImpl`/librime/Lua/schema、真机、App Group persistence、jetsam、Release 或
  Product Gate。

### 建议

1. 保持 Q2 的 marker naming/field semantics residual，并补齐 Q3 的 target Run ID ↔ appex
   marker/artifact provenance；不要用 surface 仍在前台替代 marker contract。
2. 在 host boundary 仍不可达时，保持 Skip/Blocked，不改写为失败或通过；任何 target rerun
   必须继续使用新 Run ID 和完整 source/build/result fingerprint。
3. 修复后再次交给独立 Architecture 与 Quality 复审；在此之前不关闭 T02/T03，不接受
   ADR 0025，不启用 Release default-on，不宣布 Product Gate/Release 或真实 off-main RIME
   完成。

## 7. 短增量复审（后续修复）

本节 supersede 上述 Q1 的修复前状态，只复核本次授权列出的四项变更；最新执行 Run ID 为
`P3D1-T02-T03-SIM-20260803-001`；没有修改任何生产
代码、默认设置或测试逻辑。

| 变更 | Quality 判定 | 边界 |
|---|---|---|
| `waitForP3D1LifecycleDiagnostic` 超时返回 `nil` | **Closed（bounded）** | 不再把存在但不匹配的旧 accessibility value 当作成功；仍需实际 target host 才能证明 marker 来源 |
| T03 等待 `returnClean=1`，P3LIFE 增加 `returnClean` | **Closed（bounded assertion shape）** | 已不再只查 sticky `cleared=1`；target 进程 sticky state 与实际 host Run ID/generation 的绑定仍由 Q3 保留 |
| validator 允许 epoch 变化时 revision reset | **Closed（纯值层）** | `(epoch=1, rev=3) → (epoch=2, rev=1)` 正例已加入；不等于 target marker export 已接入 validator |
| 最新回归 | **Executor snapshot positive** | Wire **10/0**、P3D1 validator **6/0**、KeyboardCore full **901/0**；本轮未重复执行 |

最新 target artifact 路径已记录在 Assignment，并在本复审文档 §2 同步：harness-on
[`build_sim_2026-08-02T16-17-30-946Z_pid40269_94150708.log`](/Users/doubleshy0n/Library/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/logs/build_sim_2026-08-02T16-17-30-946Z_pid40269_94150708.log)、
gate-off [`build_sim_2026-08-02T16-18-05-079Z_pid40269_f2122b35.log`](/Users/doubleshy0n/Library/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/logs/build_sim_2026-08-02T16-18-05-079Z_pid40269_f2122b35.log)、
T02/T03 UI [`test_sim_2026-08-02T16-19-23-797Z_pid40269_b0e95931.xcresult`](/Users/doubleshy0n/Library/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-08-02T16-19-23-797Z_pid40269_b0e95931.xcresult)。
本复审环境无法打开这些绝对路径，故仍按 executor snapshot 处理。

### 7.1 保留的残余

1. **P2-T02/T03-Q2：`PUBLISH` 语义冲突仍开放。** `P3LIFE marker=PUBLISH` 仍在
   `onResponsivePresentationNeeded` 的 UI presentation callback 中发出；它不是 owner completion
   的独立边界。`applied` 仍是 UI callback 计数而非 owner applied revision watermark，
   `discard` 仍非 late/stale result discard。必须保留此 residual，不能用 validator 6/0
   或 host surface 观察关闭。
2. **P2-T02/T03-Q3：target host provenance 仍开放。** 执行器已记录最新 harness-on、
   gate-off build 和 UI artifact 路径，且 source fingerprints 与当前工作树一致；但本轮无法
   打开这些 logs/xcresult，Messages 仍没有 target activation/marker sequence，也没有证据把
   target `run=`/epoch 与 Run ID/return generation 做相等绑定。因而 T02/T03 继续
   `Blocked (host accessibility)`。
3. `returnClean=1` 的存在改善了断言的阶段特异性，但它仍是进程级 sticky return epoch/
   diagnostic 状态，不提供 target generation、owner completion、ordered/no-drop/no-reorder
   或真实 visibility return 证明；这些仍属于 Q3/host runtime residual。

### 7.2 增量后的分层结论

| 证据层 | 增量后判定 |
|---|---|
| Handshake timeout fail-closed | **Closed（bounded XCTest helper）** |
| `returnClean` marker shape | **Closed（bounded marker/test contract）**；target run binding 仍属 Q3 |
| Cross-epoch revision reset validator | **Closed（pure-value/fixture）** |
| Owner/UI `PUBLISH` semantics | **Open P2 residual** |
| Target host provenance / Run ID ↔ appex marker | **Open P2 residual** |
| Lifecycle epoch stale regression | **Passed（bounded Core/bridge；Wire 10/0）** |
| KeyboardCore full | **901/0 executor snapshot** |
| T02/T03 target runtime | **Blocked / Not proven** |
| Product Gate / ADR 0025 / Release default-on | **未授权且未宣布** |

**增量后的最终 Quality disposition：Pass with conditions（仅 bounded harness implementation）；
P2 保留 Q2/Q3，T02/T03 runtime evidence 继续 Blocked。** 本复审不宣布 Spike/ADR/Product
Gate/Release 通过，交回 Parent/Executor 补齐 target host provenance 后再复审。
