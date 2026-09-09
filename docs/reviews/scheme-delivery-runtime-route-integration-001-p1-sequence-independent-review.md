# SCHEME-DELIVERY-RUNTIME-ROUTE-INTEGRATION-001 P1 诊断序列独立复审

日期：2026-09-09 Asia/Shanghai
复审 lane：KOS Quality / Performance / Release，只读
复审基线：`/private/tmp/uk-scheme-delivery-fix`，当前未提交工作树
复审范围：本次 P1 补充的 runtime-route 完整诊断序列、累计耗时、lease 生命周期证据，以及 `rollbackIncomplete` 终态契约。

本复审没有修改产品代码、Assignment 或 `docs/ACTIVE_WORK.md`；本文是本次唯一新增文件。

## 结论

结论：**Pass with conditions；P1 仍不能关闭。**

当前结构化 payload 已能编码、写入 journal 并从 journal 读回；operation 的阶段记录也使用同一个 `operationStartedAt` 计算累计耗时。新增测试覆盖了成功、inactive、reconciliation failure、fallback 失败后 rollback 成功以及 `rollbackIncomplete` 的部分序列。

但“完整诊断序列”仍没有形成可独立审计的闭环：部分终态只断言序列后缀，staging failure 没有断言完整 typed sequence，所有分支都没有断言全序列使用同一个 operation UUID 或在 deploy callback 执行期间持有同一个 lease；`rollbackIncomplete` 仍明确跳过 before-state 恢复，而 Assignment 将暂存失败定义为必须恢复 complete before-state。因此当前不能关闭 P1，也不能把该证据解释成第三方 active 卸载变慢已被解决。

## 已满足的证据

### Payload 与 journal

- `DiagnosticEvent.RuntimeRoutePhaseEvent` 仅包含 operation UUID、有限 phase/result/schema/layout/state 和有界 `elapsedMilliseconds`；构造器限制在 `0...600_000` 毫秒（`Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEvent.swift:366-405,706-736`）。
- `DiagnosticEvent` 的 decoder、encoder 和 `DiagnosticsJournalWriter` normalized copy 均保留 `runtimeRoutePayload`（`DiagnosticEvent.swift:826-935`、`DiagnosticsJournal.swift:280-296`）。
- `DiagnosticEventTests.testRuntimeRoutePayloadRoundTripsWithOnlyFiniteFields` 与 `DiagnosticsJournalRuntimeTests.testRuntimeRoutePayloadUsesSameBoundedAsynchronousIngress` 覆盖 JSON 往返及异步 journal 读取。
- 主 App 通过 `SchemaDeliveryDiagnosing.recordRuntimeRoute` 进入既有 journal runtime；没有把路径、URL、用户输入或异常原文写入该 payload（`Universe Keyboard/Services/SchemaDeliveryDiagnostics.swift:1-39`）。

### 当前序列实现

`performSchemaUninstall` 在取得 lease 后建立唯一 operation ID，route-before、fallback deploy、staging、commit 和 rollback 都通过 `recordActiveUninstallRoutePhase` 记录；后续阶段以同一个 `operationStartedAt` 计算累计耗时（`Universe Keyboard/Services/SchemaManager+Installation.swift:76-221,245-340`）。

当前测试实际覆盖到的序列包括：

| 终态 | 当前测试证据 | 复审判断 |
|---|---|---|
| fallback 成功、staging/commit 完成 | `testActiveUninstallAwaitsLunaDeployBeforeCommittingFiles`：before → fallback started/succeeded → staging started → commit succeeded | 有序列，但没有 staging succeeded，也没有 UUID/elapsed 断言 |
| inactive uninstall | `testNonActiveUninstallStillRemovesFilesWithoutLunaFallback`：before → inactive skipped → staging started → commit succeeded | 有序列，但没有 staging succeeded，也没有 UUID/elapsed 断言 |
| reconciliation failure | `testMalformedInactiveBindingStopsBeforeStagingWithReconciliationDiagnostic`：before → reconciliation failed | 有序列；仅对 failure count 断言 |
| fallback 失败、rollback 成功 | `testActiveWanxiangUninstallRestoresCompleteRouteStateWhenLunaDeployFails`：before → fallback started/failed → rollback started/succeeded | 主路径覆盖，且检查累计耗时单调递增 |
| fallback 失败、rollback 失败 | `testActiveUninstallKeepsFilesAndRestoresSchemaWhenLunaDeployFails` 只检查最后两个 rollback phase；另一个 Wanxiang 测试使用 `[false,true]` | 没有一条测试断言完整 `[false,false]` 序列 |
| fallback 成功、staging 普通失败 | `testActiveWanxiangUninstallRestoresCompleteRouteStateWhenStagingFails` 检查部署请求与 preference 恢复，但未注入/断言 diagnostics | typed 完整序列证据缺失 |
| `rollbackIncomplete` | `testIncompleteRollbackStopsWithoutRedeployingOriginalSchema` 断言 before → fallback started/succeeded → staging started/failed | 诊断有序列，但终态不满足 Assignment 的 before-state 恢复契约 |

## 未关闭条件

### P1-01：完整 sequence coverage 仍不完整

当前 phase enum 只有 `staging`，成功路径用 `staging_started` 后直接记录 `commit_succeeded`；没有 staging succeeded 事件。对于 fallback 失败 + rollback 失败，测试只对 Ice 测试的 `.suffix(2)` 做断言（`UniverseKeyboardTests/SchemaManagerTests.swift:1040-1046`），无法证明此前的 route-before、fallback start/failure 属于同一 operation。对于普通 staging failure，Wanxiang 测试未传入 `RecordingDeliveryDiagnostics`，因此没有任何 typed phase 序列断言（同文件 `:1324-1363`）。

关闭条件：为每个结果分支建立完整序列断言，至少包括 success、inactive、reconciliation failure、fallback failure + rollback success、fallback failure + rollback failure、staging failure + rollback success，以及 `rollbackIncomplete`。若产品语义不需要 staging succeeded，应将 phase/result 契约明确写成“staging started 后以 commit result 表示完成”，并用稳定字段名和测试固定该语义；否则应增加 staging succeeded。每条记录都应断言同一 operation UUID、route fields、failure level 和 bounded elapsed。

### P1-02：lease identity 只有生产接线，没有运行时测试证据

生产路径将同一个 `operationID` 传给 fallback 与 restore 的 `deployRimeConfig(leaseOperationID:)`，并在 `defer` 中释放 lease（`SchemaManager+Installation.swift:80-89,113-128,245-273`）。现有测试仅在 operation 返回后断言 `schemeDeliveryCommitLeaseOperationID == nil`（`SchemaManagerTests.swift:1576-1578`），而 `StubDeploymentService` 只记录 `RimeDeploymentRequest` 的 smoke schema，不观察 deploy callback 执行期间的 lease owner。因此测试无法证明 fallback 和 rollback 的两个副作用确实都发生在同一 lease 内，也无法区分“调用参数相同”和“manager 实际持有该 lease”。

关闭条件：增加可控 deployment seam，在 fallback 与 restore 调用执行期间读取并记录 Main App 的 lease owner；断言两次 owner 都等于 uninstall operation ID，并在最终返回后断言 lease 释放。该断言应同时覆盖 rollback success 和 rollback failure。

### P1-03：`rollbackIncomplete` 仍违反当前 Assignment 的失败恢复契约

捕获 `SchemaUninstallRecoveryError` 后，当前实现保留 Luna route、保留恢复文件并直接返回（`SchemaManager+Installation.swift:158-178`）。测试也明确断言只请求 Luna、原 route 不重新部署（`SchemaManagerTests.swift:1558-1585`）。这可能是资源树不完整时的安全终态，但当前 Assignment 的 Exit Criteria 明确要求“部署/暂存失败在 lease 内恢复 complete before-state”，且当前诊断只记录 `staging:failed`，没有 typed recovery-incomplete result 或恢复凭据。

关闭条件二选一：

1. 在该分支完成并测试 before-state 的完整恢复和原 route redeploy；或
2. 由 Product/Architecture 明确把“Luna 保持运行、恢复文件保留、原 route 不重新部署、等待后续恢复”定义为独立终态，并同步修改 Assignment/契约、诊断枚举和测试，使其不再声称 complete before-state 已恢复。

在上述决定完成前，不应把 `rollbackIncomplete` 作为 P1 已关闭的失败路径。

## 仍属于后续门禁的事项

- 当前耗时使用 `Date` wall clock；虽然同一 operation 起点且测试检查了一个主路径的单调递增，但真实时延判断仍需要普通 Luna deployment 对照和 CS09-10-02 真机 evidence。
- 多 key App Group preference 写入的 crash/跨进程原子性、matched T9 persisted resolver、inactive binding 悬挂策略、commit cleanup 实际结果，以及 Extension runtime/candidate input 不属于本次 P1 sequence 复审的关闭证据。
- 本复审不替代 RimeBridgeTests、完整 App + Keyboard tests、Debug/Release build、真实 App Group、物理设备、Product Gate、PR、merge、TestFlight 或 Release。

## 本次验证

已执行并通过：

```text
git diff --check
xcrun swift-format lint --strict --configuration .swift-format \
  'Universe Keyboard/Services/SchemaManager+Installation.swift' \
  'Universe Keyboard/Services/SchemaManager+T9Layout.swift' \
  UniverseKeyboardTests/SchemaManagerTests.swift \
  Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEvent.swift \
  Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournal.swift \
  Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournalRuntime.swift \
  Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticEventTests.swift \
  Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticsJournalRuntimeTests.swift
```

尝试执行受影响的 `UniverseKeyboardTests/SchemaManagerTests` 和 KeyboardCore 诊断测试，但本机 CoreSimulator/SwiftPM 环境在测试前失败：CoreSimulatorService connection invalid，Swift/Clang ModuleCache 报 `Operation not permitted`；这次复审不把该失败改写为测试通过。工作树中已有的先前测试结果不作为本次独立复审的新通过证据。

## 交接

请先补齐 P1-01 至 P1-03，再请求下一轮独立复审。P1 关闭后最多证明自动化诊断和 route transaction 契约成立；它仍不能证明用户反馈的 Luna fallback 实际部署耗时已经恢复到普通部署水平。
