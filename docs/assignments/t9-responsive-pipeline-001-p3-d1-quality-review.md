# 独立 Quality / Performance 复审：T9-RESPONSIVE-PIPELINE-001 / P3-D1

| 字段 | 结论 |
|---|---|
| 复审角色 | 🧪 Quality, Performance & Release Maintainer（独立、只读） |
| 复审日期 | 2026-08-02（Asia/Shanghai） |
| 复审对象 | [`P3-D1 Runtime Lifecycle Evidence Matrix`](t9-responsive-pipeline-001-p3-d1-runtime-lifecycle-matrix.md) |
| 复审基线 | `HEAD=3585a54`；当前 worktree 含其他任务的 ambient 改动，本复审不归因、不覆盖、不暂存 |
| Quality verdict | **Pass with conditions（deterministic Core preflight）**；整张 P3-D1 生命周期矩阵为 **Partial**，不能标记为 runtime、Device 或 Release 完成 |
| P0 / P1 / P2 / P3 | **0 / 0 / 0 / 1** |
| 治理边界 | 不宣布 ADR 0025 Accept、Product Gate、Release default-on、真实 librime off-main、真机通过或用户可感知性能预算 |

## 1. 复审范围与证据分层

本次只读核对了 P3-D1 Assignment、P2-D1 marker contract、P2-PERF-02 Evidence Contract、
ADR 0004/ADR 0025、`PERFORMANCE_BASELINE.md`、`ENVIRONMENT_CAPTURE_PROCEDURE.md`、
Test / Release playbook，以及当前 KeyboardCore / RimeBridge 测试和诊断接线。没有修改生产
代码、测试、Xcode 工程、ADR 或 Product Gate。

证据按四层单向分级，低层结果不升级高层结论：

1. **Core / Fake**：确定性队列、epoch、owner delay、presentation coalescing、fallback 和
   marker 合同；
2. **Extension target**：实际 target scheme 的加载、生命周期 wiring 和编译 flag；
3. **真实 RIME**：真实 `RimeEngineImpl`、schema/runtime、owner-thread session 和 App Group
   运行事实；
4. **物理设备**：Human 输入、keyboard reload/进程生命周期、异步诊断导出、内存与 jetsam。

当前只有第一层形成可运行的 bounded 证据。P3-D1 Assignment 已明确记录 target、real-RIME、
device、persistence 和 jetsam 尚未执行；本复审不把静态代码、Fake 或 type-check 冒充更高层。

## 2. Assignment、隐私和停止条件核对

P3-D1 的必需 Assignment 字段已明确：Domain Owner、Executor、Environment Executor、Human
Dependency、Architecture Reviewer、Quality Reviewer 与 Product Approver 均有声明，没有看到
`UNKNOWN`。生命周期仍为 `Active — deterministic Core preflight complete; target/runtime entry pending`，
因此本复审不能将 Assignment 写成 Completed 或 Closed。

边界处理是正确的：

- 默认 responsive gate、ADR 0025、生产 `RimeEngineImpl` 接线、Lua/schema、输入事件丢弃/合并/
  重排、Release default-on、Product Gate 和 R6 都明确为 non-goal；
- 不允许 uninstall、App Group wipe、RIME/userdb reset、宿主数据删除或其它破坏性清理；
- CoreSimulatorService、device、App Group 或其它工具不可用时，记录 `Unavailable` / `Blocked`，
  不用替代设备、猜测结果或空输出推导成功；
- raw pinyin、候选文本、宿主文本、user dictionary、截图/UI hierarchy 和凭据禁止进入
  content-free 诊断；
- 任何需要产品选择（timeout budget、默认 gate、丢键、host text 或 Release acceptance）时
  停止并交回 Product Lead。

停止条件覆盖了隐私、设备/工具、破坏性操作、不安全隔离和治理越权。未发现为了让矩阵“通过”
而放宽条件的迹象。

## 3. P3-D1 生命周期矩阵判定

| 行 | 层级 | Quality 判定 | 复审依据 |
|---|---|---|---|
| C01 | Core / sync A | **Pass bounded** | `ResponsiveRimePipelineTests` 23/0；accept 不调用 engine，顺序、无丢失/重复、gate-off 同步路径均有回归 |
| C02 | Core / visibility barrier | **Pass bounded** | epoch bump 清空 pending，旧 snapshot 不可 publish，新 epoch 可从新 revision 空间继续 |
| C03 | Core / enqueued reset | **Pass bounded** | `testEnqueuedResetAdvancesEpochAndInvalidatesTrailingPending` 覆盖 reset 顺序、epoch bump 和旧尾部丢弃 |
| C04 | Core / enqueued recover | **Pass bounded** | `testEnqueuedRecoverAdvancesEpoch` 覆盖 recovery epoch；仅为 Fake/组件层 |
| C05 | Core / late snapshot | **Pass bounded** | `testOldEpochSnapshotCannotPublishAfterBump`、Spike reset barrier 和最终 tip 的 tracker late-completion nil 回归 |
| C06 | Core / latest-only | **Pass bounded** | latest-only/catch-up、owner ordered delivery、coalesced presentation 与每事件执行回归；不证明真实 UI runtime |
| C07 | Core / owner readiness | **Pass bounded** | Spike 10/0 + Wire 9/0；150ms+ Fake owner block、NOT_READY 和 gate-off fallback 语义有测试 |
| T01 | Extension target | **Unavailable / NotRun** | `xcrun simctl list devices available` 因 CoreSimulatorService 不可用；无 target-level Xcode test result，也未创建/擦除替代 Simulator |
| T02 | Extension target / explicit B | **NotRun** | 没有实际 Extension target 安装、controlled Fake/Spike owner 日志或 compile-flag 运行报告 |
| T03 | Extension lifecycle | **NotRun** | 没有 visibility abandon/return、keyboard reload 或 target-level marked-text 生命周期报告 |
| R01 | Real `RimeEngineImpl` | **NotRun** | 未执行 iOS target/runtime 的 PATH/READY、真实 session identity、publish/fallback 或 artifact hash capture |
| R02 | Real RIME reset/recover | **NotRun** | 未执行真实 pending work 中的 reset/recover、old-epoch 丢弃和 host integrity export |
| R03 | Physical Human input | **NotRun** | 没有本次 Run ID、设备安装、Human report 或 App Diagnostics export；不能把历史手动观察移植到本矩阵 |
| R04 | Physical lifecycle | **NotRun** | 没有 hide/show、reload、process termination/return 的设备 marker 与手动观察 |
| R05 | Persistence/suspend | **NotRun** | 没有 App Group export、writer state、suspend/termination 分类或 durable handoff artifact |
| R06 | Memory/jetsam | **NotRun** | 没有 exact build/dSYM、Organizer/device log、memory trace 或 termination classification |

因此，P3-D1 的矩阵状态是 **Partial**：C01–C07 可接受为 deterministic bounded preflight，
T01–T03 为 target entry 未满足，R01–R02 与 R03–R06 保持 NotRun。它不是行为失败，也不是
真实运行时通过。

## 4. XCTest、type-check 与组件覆盖

### 4.1 Focused XCTest

以下 focused 结果已由当前 P3 Assignment 记录，并由本复审以隔离的 SwiftPM cache/scratch
重跑确认：

| 命令范围 | 结果 | 覆盖 |
|---|---:|---|
| `swift test --package-path Packages/KeyboardCore --filter ResponsiveRimePipelineTests` | **23 / 0** | Core A、epoch、reset/recover、latest-only、selection binding、无丢失/重复 |
| `swift test --package-path Packages/KeyboardCore --filter ThreadAffineRimeSpikeTests` | **10 / 0** | MainActor 非等待、owner 单线程顺序、150ms+ block、epoch barrier、shutdown、bound refusal、gate-off |
| `swift test --package-path Packages/KeyboardCore --filter ThreadAffineRimeWireTests` | **9 / 0** | dual-gate wiring、NOT_READY、coalescing、abandon、默认 gate-off 与同步回退 |
| `swift test --package-path Packages/KeyboardCore --filter ResponsiveProvisionalCompositionTests` | **6 / 0** | provisional marker、dot presentation、stable prefix、tracker source/duplicate 语义 |

另外，当前最终 preflight snapshot 记录 `swift test --package-path Packages/KeyboardCore` 为
**894 / 0**；该结果是 KeyboardCore 全量 XCTest 证据，包含 focused 以外的 lifecycle/UI-core
回归。既存 `T9PinyinPathTests.swift` optional-interpolation warning 仍存在，但没有记录为本
次 P3 新失败。独立重跑 full suite 不是本复审的新增计数来源，避免把不同 scratch 或中断的
执行误写成新的全量证据。

P2-D1 的 validator **28 / 0**、felt metrics **5 / 0** 作为同一 final tip 的 marker-contract
前置证据保留，但不能代替 P3 target/runtime 运行。

### 4.2 Swift 6 与 RimeBridge 边界

普通条件及 `T9_AUTO_ANCHOR_DEVICE_PREFLIGHT` 条件下的 Swift 6 全源码 type-check 均由当前
preflight snapshot 记录 **exit 0**。这只证明编译/隔离组合可通过，不证明 iOS Extension
加载、真实 librime 线程亲和或 Release 产物。

`ThreadAffineRimeRealEngineTests` 的真实引擎测试要求显式 runtime directory/schema 环境；
缺 fixture 时按 `XCTSkip`，不能把 skip 当作 real-RIME Pass。本次没有可审计的真实 iOS
target/runtime run，因此 R01/R02 继续 NotRun。

## 5. Privacy、Run ID 和 unavailable/blocked 处理

P3-D1 正确继承 P2-PERF-02 的 Run Contract：每个 arm 必须独立 opaque `runID`，A/B 共享
`pairID` 但不能共用 runID，并绑定 source/dirty fingerprint、build/flags、bundle hashes、
device/OS、schema/readiness、Full Access、fixture digest、time window、artifact hashes、
human report 和 restore identity。字段不可取得时写 `unavailable` 与原因，不能从另一臂或旧
run 继承。

当前没有 target/real/device run package、`pair-manifest.json`、run headers、content-free
runtime exports、SHA-256 manifest、privacy scan、human report 或 restore record。因此：

- 没有 Run ID 可判为 Complete；
- 没有 A/B 同源、同设备、同 schema、同 Full Access 的可比性证明；
- 没有 PATH/READY/session/geometry 缺失项的运行期观察可补值；
- `T9DEVICE gate=off` 不被误解为 responsive B gate off，geometry 也不被误解为自动化输入授权；
- 未执行项目保持 `NotRun`/`Unavailable`/`Blocked` 原态，不被转换成失败或成功。

手动物理输入约束也得到保留：只允许 Human 在空 Reminders 标题中选择 software keyboard 和
Universe 中文九宫格，按声明 fixture 手动输入；禁止 coordinate-driven XCTest、Computer Use
typing、猜坐标、数字页、Path、候选、空格或 commit 点击。若未来物理阶段需要执行，Human
输入必须与 App Diagnostics content-free export 分离记录；本复审不把任何旧真机观察迁移为
P3-D1 证据。

## 6. Quality finding

### P3-D1-Q1 — 运行时生命周期层仍未证明（P3 residual）

Core rows C01–C07 的 Fake/组件测试已经证明：接受不等待受控 owner、事件可保序交付、epoch
barrier 拒绝旧结果、reset/recover 改变 epoch、latest-only 可 coalesce、owner readiness
timeout 可显式 NOT_READY，且 gate-off 仍保持同步路径。

但这些结果不能证明：

- Extension target 实际加载和 lifecycle wiring 是否与 Core harness 相同；
- 真实 `RimeEngineImpl`/librime/Lua 是否在 owner 线程创建、调用、释放并正确报告 PATH/READY；
- 真实 reset/recover 后的 late-result、App Group 异步 writer、keyboard reload、suspend、
  process death、memory trend、jetsam 和 host marked text 完整性；
- Human 的 39-key 输入是否无漏键/重复/候选消失/键盘退出，以及是否主观不卡顿；
- Release/iOS 26.0 RC、签名 archive/dSYM、TestFlight/App Store 或 Product Gate 证据。

这是 P3 级证据边界，不是 Core 行为失败；它使整张矩阵保持 Partial，并是本复审唯一 residual
finding。不存在 P0/P1/P2 finding。

## 7. 已证明、未证明与后续授权建议

### 已证明

- C01–C07 deterministic Core lifecycle contracts 按当前 focused/full XCTest 分层通过；
- `ACCEPT`/owner completion/epoch/late-result/latest-only/fallback 的 bounded 状态机可回归；
- Swift 6 普通/preflight type-check 通过，未发现为此任务使用 `@unchecked Sendable`；
- default gate remains off；Fake/Spike 结果没有接线成 Release 默认行为；
- P3-D1 privacy、Run ID、manual-only input、Unavailable/Blocked/NotRun 和 stop-condition
  contract 已写入矩阵，且没有把缺失环境冒充成功。

### 未证明

- target-level Extension wiring、真实 iOS target test result；
- real RIME/librime/schema/Lua 的 owner-thread、PATH/READY、session identity 与 reset/recover；
- 真机 Human input、App Diagnostics persistence/export、keyboard lifecycle、memory/jetsam；
- run-bound artifact hashes、A/B pair manifest、Full Access/restore identity；
- Release/iOS 26.0 RC/Product Gate 或任何主观性能预算。

### 下一步授权建议

1. 由 Product Lead 另行授权 target preflight；Environment Executor 先获得可发现的 concrete
   Simulator/device destination 与 scheme，不创建或擦除替代设备；
2. 只执行 target-level protocol/lifecycle tests，保持 no-coordinate/no-Computer-Use input、
   explicit diagnostic flags 和默认 gate-off；
3. 真实 RIME 与物理设备阶段分别建立新的 Run ID、Pair Manifest、content-free export 和
   restore proof；缺任一 required field 就保持 Partial/Blocked；
4. target/real/device evidence 完成后，再交独立 Architecture 与 Quality 复审；在此之前不
   接受 ADR 0025、不改 Product Gate、不改 Release default-on，也不宣布 P3-D1 Complete。

## 8. 交接与停止点

**Quality disposition：Pass with conditions（Core preflight）；P3-D1 matrix Partial。**
本复审已完成对最终 P3-D1 文档、focused/full XCTest snapshot、分层边界、隐私/Run ID、人工
输入禁令、Unavailable/Blocked 和停止条件的独立核对。

本复审到此停止，交由独立 Architecture reviewer 复核边界，再由 Product Lead 决定是否授权
target/runtime/device evidence。未修改生产逻辑、测试、ADR、Product Gate、设备状态或任何
默认开关。
