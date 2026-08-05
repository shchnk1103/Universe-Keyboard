# 独立 Architecture 复审：T9-RESPONSIVE-PIPELINE-001 / P3-D1-T01

复审日期：2026-08-02（Asia/Shanghai）  
复审角色：Independent Architecture & Knowledge Steward（独立、只读）  
复审对象：[`P3-D1-T01 Test Harness Repair`](t9-responsive-pipeline-001-p3-d1-t01-test-harness-repair.md)  
关联矩阵：[`P3-D1 Runtime Lifecycle Evidence Matrix`](t9-responsive-pipeline-001-p3-d1-runtime-lifecycle-matrix.md)  
治理基线：[`ADR 0004`](../architecture/decisions/0004-rime-runtime-session-model.md)（Accepted）  
诊断边界：[`ADR 0025`](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md)（Proposed，default-off）

Architecture 结论：**Pass with conditions（最小 harness 修复在边界内；T01 仍为 Partial）**  
严重度摘要：**P0/P1/P2/P3 = 0/0/0/2**。

本复审只审查 T01 的测试 harness 修复、证据边界和归因完整性。没有修改生产逻辑、测试、
Xcode 工程、既有 ADR、默认 gate、设备状态或 Product Gate。当前工作树含有其他任务的
ambient changes；本复审不把它们归因于 T01，也不把 Core/target smoke 结果升级成真实
Extension、真实 librime、真机、Release、持久化或 jetsam 证据。

## 1. 复审输入与方法

已读并交叉核对：

- T01 Assignment 的 Authority、Boundary、Findings、Changes、Verification、Evidence
  disposition、Handoff 和 Changed-file allowlist；
- 更新后的 P3-D1 lifecycle matrix，尤其是 T01/T02/T03 与 R01–R06 的分层状态；
- P3-D1 前一轮 Architecture / Quality review；
- ADR 0004、ADR 0025、ADR 0002，以及 P2-PERF-02 Evidence Contract；
- `KeyboardExtensionTests/CandidatePrefetchUIContractTests.swift`、
  `ResponsiveProvisionalCompositionTests.swift` 的相关修复 hunk；
- `KeyboardExtensionTests` target/scheme 的记录、target dependency 说明和 Executor 提供的
  测试快照。

本复审没有重新执行测试或重新构建。Verification 数字以下按 Assignment 中记录的结果作为
bounded executor evidence，不声明为本轮 Architecture agent 的新鲜重跑。

## 2. Assignment 完整性与授权核对

T01 已明确给出 Product Lead authority、decision source/date、P3-D1 parent、ADR 0004
production baseline、ADR 0025 Proposed/default-off 边界、Executor、Verification、Handoff、
Stop 条款和 changed-file allowlist；没有发现必填责任为 `UNKNOWN`。`Completed — bounded
repair and verification; independent re-review pending` 与“修复已完成、复审尚未完成”的
生命周期语义一致，不等同于 T01 或 P3-D1 runtime 完成。

授权范围也足够窄：

- 允许的只是 Swift 6 XCTest 编译隔离修正、不可链接 appex symbol 的 smoke-probe 边界修正，
  以及测试内 scheduler-stability 修正；
- 明确禁止 production RIME rewiring、lifecycle behavior change、真实设备、Release、
  Product Gate、ADR 0025 接受和 default-on；
- 明确禁止 `@unchecked Sendable`、事件丢弃/合并/重排、破坏性清理和默认 gate 改动。

因此，T01 修复可以在本 Assignment 中进行 Architecture 复审；任何 target lifecycle、真实
RIME 或设备工作必须另建运行范围和 Run ID。

## 3. 最小修复的 Architecture 边界判断

| 修复 | 复审判断 | 原因与剩余边界 |
|---|---|---|
| `CandidatePrefetchUIContractTests` 改为 `nonisolated` XCTestCase | **允许，未越界** | 在 `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` 下，class-level `@MainActor` 会把 XCTest 声明为 nonisolated 的初始化器错误地隔离；`nonisolated` 只修复测试类入口，不改变生产 actor 隔离，也没有使用 unsafe Sendable。 |
| 移除对具体 `KeyboardViewController` appex symbol 的引用，保留 bundle-load probe | **允许，未越界** | XCTest bundle 不能把 app extension 产品当作可链接的 XCTest host。保留 `@testable import Keyboard` 和 target dependency 可验证编译/加载边界，但不声称 controller、marked text 或 lifecycle 已运行。 |
| 将固定 35 ms test sleep 改为最长 2 s 的异步轮询 | **允许，未越界** | 这是 test-only scheduler stabilization，有明确上限，仍在状态不出现时失败；它不是产品延迟、timeout budget、队列策略或用户体验结论。 |
| 生产源、Xcode project、ADR、gate、设备 artifact | **T01 不得修改** | T01 Assignment 的 allowlist 没有这些对象；本复审没有把当前工作树中其他任务的改动归因于本修复。 |

三项修复均属于“让已有测试目标可编译、可执行、可重复”的最小边界，没有把测试 workaround
写进生产路径，没有改变 MainActor/owner-thread 合同，也没有把 diagnostic B 变成 Release
默认行为。

### 3.1 归因与 dirty worktree 条件

当前 worktree 中，`ResponsiveProvisionalCompositionTests.swift` 相对 `HEAD` 的整体 diff
为 **399 insertions / 12 deletions**，其中包含此前任务的 ambient 修改；T01 只声明
`testCoalesceBacklogStillPaintsL1` 的固定 sleep → bounded polling hunk。`Universe Keyboard.xcodeproj/project.pbxproj`
也存在 **129 insertions / 0 deletions** 的 ambient diff，而 T01 明确没有改 Xcode project。

因此，T01 的最小性只能按具体 hunk 和 Assignment allowlist 判断，不能按整个文件或当前
dirty worktree 的文件级 diff 判断。后续若要把 T01 作为可复核的审计输入，应在 handoff
中提供冻结提交、hunk 级 diff 或等价的 source fingerprint，并明确排除 ambient hunks。
这是 P3 级证据/文档条件，不是生产架构缺陷。

## 4. Executor Verification 的分层复核

以下结果来自 T01 Assignment 的记录；本复审接受其作为 bounded snapshot，但不扩展其含义：

| 检查 | 记录结果 | Architecture 可接受的含义 |
|---|---:|---|
| focused `KeyboardExtensionTests/CandidatePrefetchUIContractTests` | **1/0** | XCTest bundle probe 可执行；不能证明 Extension lifecycle。 |
| full `KeyboardExtensionTests` | **1/0** | 当前 test target 全量 smoke 通过；target dependency/build 边界可复核，不能证明 installed appex runtime。 |
| `RimeBridgeTests` | **54/0，20 skipped** | Bridge/test-target 证据；skip 仍是环境门控真实 RIME/T9 场景，不得升级为 real-RIME pass。 |
| focused `testCoalesceBacklogStillPaintsL1` | **1/0** | bounded wait 的测试稳定性回归通过；不提供产品性能 SLO。 |
| full `Packages/KeyboardCore` | **894/0** | Core 回归快照通过；不覆盖 target lifecycle 或 native librime。 |
| `git diff --check` | **pass** | 当前文本 diff 无 whitespace 错误；不证明归因或运行正确性。 |

使用的 target/环境记录包括已发现的 iOS 27.0 iPhone 17 Pro Max Simulator
`06C5BC3E-7599-4761-A1A2-71DAEA991474` 和 `KeyboardExtensionTests` scheme。没有创建、擦除、
替换设备，也没有把 Simulator smoke 作为物理设备证据。

## 5. T01 的最终分类

T01 的 required invariant 包含“target 可以加载”和“lifecycle boundary 调用同一套
reset/recover/epoch cleanup”。当前修复只覆盖前一项的一部分：target dependency/build 和
XCTest bundle probe 已有证据；后者没有 lifecycle harness、controller invocation 或 marked
text observation。因此 T01 **只能保持 `Partial (bounded)`**，不能改写为 `Passed`、`Complete`
或 `Runtime verified`。

| T01 子事实 | 状态 | 证据边界 |
|---|---|---|
| Test target / appex dependency 可编译 | **Passed (bounded)** | full target result 1/0 及 target/scheme 记录；未证明安装后的 Extension。 |
| XCTest bundle probe 可执行 | **Passed (bounded)** | bundle identifier probe 1/0；没有访问具体 appex symbol。 |
| `KeyboardViewController`/marked text lifecycle | **NotRun** | 当前 probe 有意不链接/调用 controller。 |
| reset/recover/visibility/epoch cleanup 的 target 接线 | **NotRun** | 需独立 T02/T03 lifecycle harness。 |
| PATH/READY、真实 `RimeEngineImpl`、owner session | **NotRun** | RimeBridge skip 和 Core/Fake 结果不足以证明。 |
| 真机、App Group persistence、memory/jetsam、Release/Product Gate | **NotRun** | 不在 T01 授权范围。 |

## 6. Architecture Findings

### P3-T01-01：共享 dirty 文件导致 T01 hunk 归因需要冻结证明

T01 已在 Assignment 中文字声明 ambient hunks 不归因于修复，但当前
`ResponsiveProvisionalCompositionTests.swift` 的文件级 diff 和 Xcode project 的 ambient diff
仍会让后续读者难以只凭工作树重建 T01 的实际改动。若没有 hunk 级 fingerprint，容易把既有
P2/P3 测试扩展误报为 T01 harness repair。

**要求：**下一次 handoff/提交前保留冻结提交、hunk allowlist 或等价 source fingerprint，且
把 project diff 明确标为 T01 外部变更。无需修改生产代码或重新归因历史改动。

### P3-T01-02：bundle-load probe 不能承担 lifecycle 证明

从 Architecture 上，去除 appex symbol 是正确的链接边界；但该 probe 的成功只表示 XCTest
bundle 可加载、其 target dependency 可构建。它不能证明 Extension 进程中的
`KeyboardViewController`、marked text、reset/recover/visibility barrier、PATH/READY 或
真实 session 的执行。矩阵已正确把 T02/T03 及 R01–R06 分离为 `NotRun`。

**要求：**保留 T01 为 `Partial (bounded)`，下一步单独授权 target-level T02/T03 controlled
Fake/Spike lifecycle harness；真实 RIME、真机、持久化和 jetsam 继续使用独立 Assignment/Run
ID。不得为了把 T01 标成 Pass 而把 smoke probe 扩展成未经审查的生产接线。

两个 findings 都是 P3 级证据边界，未发现 P0/P1/P2 生产架构问题。

## 7. ADR、默认 gate 与 Product Gate 边界

### 7.1 ADR 0004（Accepted）

T01 没有改变 ADR 0004 的生产基线：Extension session 的现有 MainActor/thread 串行模型、
process-local 生命周期和主 App 部署边界继续有效。测试类 `nonisolated` 不应被解释为生产
RIME 跨隔离迁移。

### 7.2 ADR 0025（Proposed）

T01 只为诊断/验证目标修复 harness，未接受 ADR 0025、未接线真实
`RimeEngineImpl` 到 off-main owner、未改变双 gate、未扩大 auto-anchor，也未使用
`@unchecked Sendable`。ADR 0025 仍是 Proposed，responsive/ThreadAffine gate 仍
default-off；测试通过不产生 Release default-on 授权。

### 7.3 Product Gate / Release / physical boundary

T01 的 1/0、54/0、894/0 和 type/build 记录不构成 Product Gate、Release acceptance、真机
通过或用户主观不卡顿结论。真机、持久化、memory/jetsam 和 Release 仍需新的授权、immutable
Run ID、content-free export 和独立复审。

## 8. 已证明与未证明

### 已证明（bounded）

- Swift 6 XCTest initializer isolation 的测试入口问题已用局部 `nonisolated` 修复，未绕过
  生产隔离；
- app extension 不可链接为 XCTest host 的边界已被 bundle-only probe 正确表达；
- 测试 scheduler wait 有 2 s 上限，状态不出现仍失败，且没有产品侧时序修改；
- `KeyboardExtensionTests` focused/full probe、KeyboardCore focused/full 快照可执行且记录
  为 1/0、1/0、1/0、894/0；RimeBridge 54/0 与 20 skip 仍保持分层；
- T01 没有将 ambient 生产/工程改动纳入授权，也没有变更 ADR、gate、设备或 Product Gate。

### 未证明

- `KeyboardViewController` 实际 Extension 进程加载、marked text/UI lifecycle 和
  reset/recover/visibility/epoch 清理接线；
- target-level explicit B 接受时 MainActor 是否在 owner block 期间继续返回，及其顺序/过期
  revision 行为；这些属于 T02/T03；
- 真实 librime/Lua/schema、PATH/READY、owner-thread native session、真实 reset/recover、
  App Group writer durability；
- iPhone 13 Pro Human 输入、keyboard reload/process death、memory trend、jetsam、Release
  signing/dSYM、Product Gate 或任何 numeric/user-facing latency SLO。

## 9. Final disposition、停止点与下一步建议

**Architecture disposition：Pass with conditions（T01 bounded repair review complete）**。

结论明确如下：

1. 三项最小 harness 修复在 T01 授权边界内，没有越界到生产逻辑；
2. T01 只能标为 **`Partial (bounded)`**，因为当前证据只有 target dependency/build 和
   bundle-load smoke，不包含 lifecycle harness；
3. P3-D1 Assignment 保持 **Active**；T02/T03 与 R01–R06 保持 `NotRun`；C04/C07 的既有
   `Partial` 不被本次 T01 修复升级；
4. ADR 0004 继续 Accepted，ADR 0025 继续 Proposed/default-off；不宣布 Product Gate、
   Release default-on 或生产 off-main RIME 已完成。

若 Product Lead 后续授权，建议另建 bounded T02/T03 target-level lifecycle harness，先绑定
冻结 source/build/flags 和 explicit diagnostic switch，再由独立 Quality 与 Architecture
分别复审。真实 librime 与物理设备阶段仍需独立 Run ID/证据合同。

本复审至此停止。除本文件外没有产生代码、测试、ADR、默认 gate、设备或发布变更。
