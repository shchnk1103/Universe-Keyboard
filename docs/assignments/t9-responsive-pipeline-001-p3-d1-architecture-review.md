# 独立 Architecture 复审：T9-RESPONSIVE-PIPELINE-001 / P3-D1

复审日期：2026-08-02（Asia/Shanghai）
复审角色：Independent Architecture & Knowledge Steward（独立、只读）
复审对象：[`P3-D1 Runtime Lifecycle Evidence Matrix`](t9-responsive-pipeline-001-p3-d1-runtime-lifecycle-matrix.md)
复审边界：P2-D1 最终 bounded 结论、[`ADR 0025`](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md) Proposed 边界、[`ADR 0004`](../architecture/decisions/0004-rime-runtime-session-model.md) Accepted 生产基线，以及 P3-D1 的 target/real-RIME/device/persistence/jetsam 分层。

Architecture 结论：**Pass with conditions（仅矩阵设计与边界通过；Assignment 仍为 Active，当前高层运行证据为 Partial/NotRun）**

严重度摘要：**P0/P1/P2/P3 = 0/0/1/2**。

本复审不修改生产逻辑、测试、ADR、默认 gate、设备状态或 Product Gate。当前工作树包含其他任务的 ambient changes；本复审不把它们归因于 P3-D1，也不把静态/KeyboardCore 结果升级为 Extension、真实 librime、真机、Release、持久化或 jetsam 证据。

## 1. 复审输入与方法

已读并交叉核对：

- P3-D1 Assignment 及其 Current Preflight Record、Evidence Layers and Matrix、Run/Privacy、Entry/Exit/Stop/Handoff 条款；
- P2-D1 最终 Architecture review、Quality review 与 Marker Contract；
- P2-PERF-02 Evidence Contract；
- ADR 0025（仍为 `Proposed`，包括 §10/§11/§12 的 owner、epoch、gate 与 Spike 边界）；
- ADR 0004（`Accepted`，生产 Extension session 仍在 MainActor/thread 上串行）；
- ADR 0002（visibility abandon 合同，P3-D1 T03 引用但当前 Required Inputs 未列出）；
- Shared Container And RIME Lifecycle、Performance Baseline、Environment Capture Procedure、Test/Release、RimeBridge 与 Debug Investigator playbooks；
- P3-D1 所引用的 Core 测试源和 Executor 提供的最终测试快照。测试未在本复审中重复执行。

P2-D1 最终快照为 validator **28/0**、felt metrics **5/0**、KeyboardCore 全量
**894/0**；P3-D1 另记录 `ResponsiveRimePipelineTests` **23/0**、
`ThreadAffineRimeSpikeTests` **10/0**、`ThreadAffineRimeWireTests` **9/0**、
`ResponsiveProvisionalCompositionTests` **6/0**，以及两种 Swift 6 全源码 type-check
均 exit 0。上述数字是 bounded Core/编译证据，不是本复审的 target/device 重跑。

## 2. Assignment 完整性与授权边界

### 2.1 已满足的必填字段

P3-D1 已显式给出 Assignment Authority/Product Approver、Decision Source/Date、Domain
Owner、Executor、Environment Executor、Human Dependency、Architecture Reviewer、Quality
Reviewer、Required Inputs、Entry/Exit/Stop Conditions、Handoff Target、Lifecycle Status
和 Revalidation Trigger，没有 `UNKNOWN` responsibility。`Active — deterministic Core
preflight complete; target/runtime entry pending` 与当前证据状态一致，没有把待执行阶段写成
完成。

### 2.2 需要保留的文档条件

- T03 的 required invariant 明确引用 **ADR 0002**，但 P3-D1 Required Inputs 没有列出该
  Accepted ADR；target phase 进入 `Ready` 前必须补齐该输入或改为明确链接到同一生命周期
  Source of Truth。
- 矩阵 Exit Criteria 要求每行使用 `Passed`、`Partial`、`Blocked` 或 `NotRun`；当前
  Current state 混用 `Pass bounded`、`Not executed`、`Requires ...` 等描述。它们可读，
  但不是可机械汇总的终态枚举，后续 handoff 前应规范化并保留 bounded scope 作为附加字段。
- R02 的“Raw immutable export”必须在下一版明确为 **content-free immutable export**，或
  明确受控原始附件仅留在隐私扫描后的临时区；不能被解释成包含 raw pinyin、候选文本或宿主
  文本的仓库证据。
- Decision Source 目前指向 active Codex task 的 Product Lead 授权；本复审接受该授权，但
  target/real phase 开始前应将 source/build/device/run 的不可变 handoff 标识绑定到同一
  Assignment 或 Evidence Contract，避免只依赖聊天回溯。

上述是文档/证据契约条件，不是生产架构越界；计为 P3-A02，不阻止本次 bounded Architecture
review，但会阻止把 P3-D1 标记为高层证据完成。

## 3. 四层矩阵复核

下表将 Assignment 当前描述归一为 Exit Criteria 允许的状态。`Passed (bounded)` 只表示
当前层成立；它不会升级下一层。`Blocked` 表示入口工具/环境阻塞，`NotRun` 表示尚未开始
该层运行。

| 层级 | 行 | Architecture 判定 | 依据与边界 |
|---|---|---|---|
| Core/Fake | C01 | **Passed (bounded)** | `ResponsiveRimePipelineTests` 23/0 覆盖 gate-off accept 不调用 engine、保序/不丢；不能代表 target 或真实 RIME。 |
| Core/Fake | C02 | **Passed (bounded)** | explicit epoch bump 清空 pending、旧 snapshot fail-closed、epoch 变化后的 tracker late completion 为 `nil`；组合证据仍只覆盖 Core。 |
| Core/Fake | C03 | **Passed (bounded)** | enqueued reset 的顺序、epoch 增加、trailing work 丢弃和 stale counter 有回归；不证明真实 session reset。 |
| Core/Fake | C04 | **Partial (bounded)** | `testEnqueuedRecoverAdvancesEpoch` 证明 recovery count/epoch，但没有同一 recover 场景下旧 epoch late result 的负向断言；见 P2-A01。 |
| Core/Fake | C05 | **Passed (bounded)** | `tryApplyExternalSnapshot` 与 `testOwnerCompletionAllowsRevisionReuseAfterEpochChange` 覆盖旧 epoch 拒绝和新 epoch revision reuse；不替代真实 owner 生命周期。 |
| Core/Fake | C06 | **Passed (bounded)** | latest-only/catch-up 保留每个 owner work、允许 UI coalesce；P2-D1 validator 另覆盖 epoch-bound PUBLISH；不证明 UIKit paint。 |
| Core/Fake | C07 | **Partial (bounded)** | Spike 10/0 + Wire 9/0 证明 owner delay/线程/READY timeout 的组件语义及 gate-off 基线；没有 target-level timeout 后 PATH/NOT_READY/fallback/双 gate 清除的整链回归，见 P2-A01。 |
| Extension target | T01 | **Blocked at entry / NotRun** | CoreSimulator/Xcode target destination 尚未形成可运行证据；不创建/擦除替代设备，不把源码存在当作 target load proof。 |
| Extension target | T02–T03 | **NotRun** | 依赖具体 target scheme、build identity 和 lifecycle harness；当前没有 target test/log/compile-flag artifact。 |
| Real RIME | R01–R02 | **NotRun** | 没有真实 `RimeEngineImpl` iOS target run、PATH/READY/session identity 或 reset/recover raw content-free export。 |
| Physical device | R03–R04 | **NotRun** | 没有本 Assignment 绑定的 Run ID、Human report、设备日志或 reload/process lifecycle observation；不能引用历史手动测试替代。 |
| Persistence/suspend | R05 | **NotRun** | 没有 App Group export、async writer state、suspend/termination classification 和 digest；不能从 logger 源码推断 durable handoff。 |
| Memory/jetsam | R06 | **NotRun** | 没有 exact build/dSYM、Organizer/device log、memory trace 或 termination classification；不宣称无 jetsam。 |

因此，P3-D1 当前不是“runtime matrix passed”，而是 **Core layer bounded passed with two
Core wording/evidence conditions + higher layers NotRun**。这与 Assignment 的 Active 状态一致。

## 4. Architecture Findings

### P2-A01：C04/C07 的 Required invariant 比当前 Core evidence 更强

P3-D1 把 C04 写成“recover 后阻止旧结果发布”，但当前对应的
`testEnqueuedRecoverAdvancesEpoch` 只检查 `sessionEpoch` 与 `sessionRecoveryCount`；
`testOldEpochSnapshotCannotPublishAfterBump` 覆盖的是显式 bump，并非 enqueued recover 的
同一交互。P3-D1 把 C07 写成“NOT_READY/fallback、gate 清除、A 同步回退均可用”，而当前
Spike/Wire 证据主要覆盖 owner readiness timeout、线程亲和、组件级 gate-off；
`KeyboardViewController+Bootstrap` 的真实 target 接线仍未运行。

这不是 P0/P1，也不是要求本次修改生产逻辑的理由；但如果保持原 Required invariant，就不能
把 C04/C07 写成无条件 Pass。下一步应由 Executor/Quality 在同一 Core 层补旧 epoch after
recover 的负例与 timeout/fallback 纯组件合同，或由 Product Lead 授权后将行的 Required
invariant 窄化到当前已证明的 bounded 范围。未完成前，C04/C07 保持 `Partial`。

### P3-A02：Assignment/证据包规范化条件

补列 ADR 0002、规范化行状态枚举、将 R02 的 raw export 写成 content-free/受控附件，并在
target phase 前绑定可复核的 handoff source，是必要的文档卫生和隐私边界。它们不改变 ADR
0025/0004，也不授权任何运行或发布行为。

### P3-A03：高层运行边界尚未产生证据

T01–T03 的 target wiring、R01–R02 的真实 RIME、R03–R04 的 Human/device lifecycle、R05 的
App Group writer persistence、R06 的 memory/jetsam 全部仍是 `NotRun`（T01 的入口另有
environment blocker）。这是本 Assignment 明确保留的下一层工作，不是缺失证据可以被静态
代码、894/0 XCTest、type-check 或历史设备观察补齐的地方。

## 5. P2-D1 / ADR 0025 / ADR 0004 边界判断

### 5.1 ADR 0004 Accepted 生产基线

P3-D1 没有声称修改 ADR 0004：当前生产 Extension session 仍 process-local、librime 操作
串行并位于 MainActor/thread；部署仍由 Main App 所有；process death 丢失内存 composition。
P3-D1 的 R04 “新 process/session clean、unfinished composition 不恢复”与 shared lifecycle
一致。任何真实 B run 都必须证明它是显式 diagnostic arm，而不是把 ADR 0004 的生产路径
静默改成 off-main。

### 5.2 ADR 0025 Proposed 边界

P3-D1 只把 ADR 0025 当作 Proposed architecture/evidence boundary，保留双 gate
default-off、无 `@unchecked Sendable`、单一 owner、Sendable snapshot、保序且不丢事件的
合同；没有宣布 ADR Accepted、R2/R4 production wiring、Release default-on 或 Product Gate。
R01 的 real-RIME 条件只有在已授权的 diagnostic target harness、prepared runtime 和明确
build flags 存在时才能进入；若需要跨未审查 isolation boundary 接生产 `RimeEngineImpl`，
应触发 Assignment Stop Condition。

### 5.3 Persistence / device / jetsam boundary

P3-D1 遵守 P2-PERF-02 的 Run ID、content-free、privacy scan、all-category export、Human
manual input 和 restore contract 方向。R05 没有把异步 writer 误写成耐久保证；R06 要求
Organizer/device evidence 与 exact build/dSYM，也没有用“没有看到崩溃”推断无 jetsam。手动
Reminders/software keyboard/九宫格方式与 Performance Baseline 一致，不引入坐标自动化、
Path/candidate 点击或数字键注入。

## 6. 已证明与未证明

### 已证明（bounded）

- P3-D1 Assignment 的职责、范围、入口、退出、停止和交接字段基本齐全，且明确保持 Active；
- 四层证据模型和“低层不升级高层”原则清楚；Core/Fake 的 accept、顺序、epoch、reset、
  latest-only、owner readiness 与 gate-off 组件合同有对应 XCTest 快照；
- P2-D1 的 28/0、5/0、894/0、Swift 6 type-check 结果仍只作为 Core/编译层输入，没有被
  当成 target/device/runtime 结果；
- ADR 0004 生产基线、ADR 0025 Proposed/default-off、无 unsafe isolation、无 drop/merge/
  reorder、无 destructive cleanup、无 invented SLO 的边界未被 P3-D1 越过；
- Run ID、content-free fields、unavailable/contradicted、Human manual input、restore、
  privacy scan、App Group/jetsam 不作虚假通过的规则已写入矩阵或其上游合同。

### 未证明

- C04 enqueued recover 后真实旧 epoch late-result fail-closed 的完整 Core 负例；
- C07 timeout → PATH/NOT_READY/fallback → 双 gate 清除 → ADR 0004 sync fallback 的整链 target
  行为；
- Extension target scheme/load/lifecycle、真实 `RimeEngineImpl`/Lua、owner-thread native
  session identity、real reset/recover/reload 与 host marked-text integrity；
- iPhone 13 Pro Human A/B、process lifecycle、App Group async writer persistence、memory
  trend、jetsam/crash classification、Release/signing/dSYM、Simulator 或 Product Gate；
- 任何“主观不卡顿”或 numeric performance budget。P3-D1 只能记录观察与分布。

## 7. Final disposition、停止点与后续授权建议

**Architecture disposition：Pass with conditions（review complete for the matrix design）**。

P3-D1 的分层、隐私、设备方法、stop conditions 和 ADR/default-off 边界可继续作为后续
Evidence Matrix 使用；但 Assignment 当前应保持 **Active**，其高层 rows 保持 `NotRun`，
C04/C07 保持 `Partial`，不能写成 Runtime/Release/Product 完成。

建议的后续顺序：

1. 由 Product Lead 单独授权一个 bounded deterministic closure/documentation addendum，
   处理 C04 recover-late-result 与 C07 timeout/fallback 的证据范围，并补 ADR 0002、状态
   枚举和 content-free export wording；不改默认 gate、不接真实生产 engine。
2. 确认具体 Extension target scheme、build flags、source/build fingerprint 与非替代的
   tool/device entry 后，单独交 Quality 做 T01–T03 target review；工具不可用时保留
   `Blocked/NotRun`，不创建或擦除设备。
3. 另行取得 Product authorization 后，按 R01–R06 分开的 Run ID 执行真实 RIME、Human
   device、persistence/suspend 和 memory/jetsam evidence；每一层重新交独立 Quality 与
   Architecture/Release 复核。

本复审停止于 Architecture 边界。不得据此接受 ADR 0025、修改 ADR 0004、接线 Release
default-on、宣布 Product Gate、发布真实 off-main 收益或把历史 B evidence 改写为 Complete。
