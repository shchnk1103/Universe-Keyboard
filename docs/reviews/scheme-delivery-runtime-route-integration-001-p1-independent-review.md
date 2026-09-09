# SCHEME-DELIVERY-RUNTIME-ROUTE-INTEGRATION-001 P1 独立复审

日期：2026-09-09 Asia/Shanghai
复审 lane：KOS Quality / Performance / Release  只读
复审基线：`/private/tmp/uk-scheme-delivery-fix`，当前未提交工作树
复审范围：本次 P1 授权涉及的 runtime-route payload、DiagnosticsJournal writer/ingress、content-free 耗时字段，以及 active-uninstall 的 fallback failure、rollback success/failure 诊断序列和 lease 证据。

本复审没有修改产品代码、Assignment 或 `docs/ACTIVE_WORK.md`；本文是本次唯一新增文件。

## 结论

结论：**Pass with conditions；P1 暂不能关闭。**

当前没有发现新的 P0。runtime-route payload 已接入编码、journal writer 的归一化复制和异步 ingress，且 Main App 已把 fallback/rollback 结果发送到 typed diagnostics。但是，P1 所需的“可用耗时证据”和“完整 active-uninstall 失败序列证据”仍不完整：当前除了 `route_before` 外，其余阶段都以默认 `elapsedMilliseconds = 0` 写入；测试没有证明所有事件共享同一 operation/lease identity，也没有覆盖 `[false, false]` 的 rollback failure 结构化序列、staging failure 的结构化序列及成功/inactive/commit 序列。

因此，当前候选可以继续修订，不能据此关闭 P1，也不能把卸载后的部署耗时问题报告为已解决。

## 已满足的 P1 证据

### Payload 与 journal writer/ingress

- `DiagnosticEvent.RuntimeRoutePhaseEvent` 的字段是 operation UUID、有限 phase/result/schema/layout/state 和有界整数耗时；构造器将耗时限制在 `0...600_000` 毫秒（`Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEvent.swift:708-736`）。
- `DiagnosticEvent` 已声明 `runtimeRoutePayload`，decoder 对 code/payload 做匹配校验，encoder 也写入该 payload（同文件 `:739-935`）。这修复了前一轮 review 发现的 payload 落盘丢失问题。
- `DiagnosticsJournalRuntime.recordRuntimeRoute` 使用现有 ingress，并没有同步等待 journal I/O（`Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournalRuntime.swift:115-135`）。
- `DiagnosticsJournalWriter.append` 的 normalized event 保留 `runtimeRoutePayload`（`Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournal.swift:280-296`）。
- `DiagnosticEventTests.testRuntimeRoutePayloadRoundTripsWithOnlyFiniteFields` 与 `DiagnosticsJournalRuntimeTests.testRuntimeRoutePayloadUsesSameBoundedAsynchronousIngress` 覆盖了 JSON round-trip 和写入后重新读取的 payload equality（对应测试文件新增段落）。从实现看，payload 不接受用户输入、路径、URL 或异常原文。

### Active-uninstall 的调用路径

- `performSchemaUninstall` 在取得 commit lease 后建立 operation ID，并在 active route mutation 后通过 `deployRimeConfig(leaseOperationID: operationID)` 执行 Luna fallback；fallback 失败会调用完整 before-state restore（`Universe Keyboard/Services/SchemaManager+Installation.swift:82-128`）。
- restore 同样在释放 lease 前执行，并把 `rollback_deploy_succeeded` 或 `rollback_deploy_failed` 写入 typed diagnostics（同文件 `:245-273`）。
- 当前 Wanxiang `[false, true]` 测试确实断言了 `before → fallback started → fallback failed → rollback started → rollback succeeded` 和一个 failure 标记（`UniverseKeyboardTests/SchemaManagerTests.swift:1260-1310`）。
- format lint 与 `git diff --check` 在本次复审中通过。

## 未关闭条件

### P1-01：耗时字段没有覆盖阶段，无法回答“为什么变慢”

`operationStartedAt` 只在 `route_before` 调用点传入（`SchemaManager+Installation.swift:93-98`）。后续 `route_after_deploy_pending`、fallback result、staging、commit 和 rollback 调用均没有传入该时间，因此 `recordActiveUninstallRoutePhase` 使用默认值 `0`（同文件 `:277-294`）。

这意味着 payload 虽然有 bounded duration schema，但当前 journal 无法比较 fallback deployment 与普通 deployment 的阶段耗时，也无法判断慢在 route mutation、RIME deploy、staging 还是 rollback。它不能作为“之前反馈的第三方 active 卸载后 Luna 部署变慢已解决”的证据。

关闭条件：让同一 operation 的每个阶段使用统一的 operation start 或单调时钟计算 elapsed，并在测试中断言值存在、非负且不超过上限；同时保留普通 Luna deployment 的对照耗时需要另行由真机证据确认。

### P1-02：active-uninstall 诊断序列覆盖不足

当前仅 Wanxiang 的 fallback failure + rollback success 测试检查完整 typed phase 序列。Ice 的失败测试只检查 `rollback_deploy` 的最后两个 phase，并没有断言 `route_before`、fallback start/failure、route schema/layout、operation UUID 或耗时。现有代码也没有看到以下序列的 Main App diagnostics 断言：

- fallback success → staging started → commit succeeded；
- fallback failure → rollback deployment failure（`[false, false]`）；
- fallback success → staging failure → rollback success；
- inactive uninstall → inactive skipped；
- staging rollback incomplete / reconciliation failure 的 failure payload。

此外，`runtimeRouteDiagnosticPayload` 对 `reconciliation_failed` 直接落入 `default: return nil`（`SchemaManager+Installation.swift:306-330`），所以该 active-uninstall failure 分支不会生成结构化诊断。P1 需要每个失败终态都能从 operation UUID 还原原因和结果。

关闭条件：使用可控 deployment stub 覆盖上述成功、fallback failure + rollback success、fallback failure + rollback failure、staging failure 和 inactive 分支；每组断言完整序列、同一 operation UUID、失败事件的 `.error` 级别、route fields 和 bounded elapsed。

### P1-03：lease identity 只有静态接线，没有测试证据

生产路径把 `operationID` 传给 `deployRimeConfig(leaseOperationID:)`，并在函数退出时释放 lease（`SchemaManager+Installation.swift:88-89,115,259`）。这说明实现意图正确，但 `RimeDeploymentRequest` 本身不带 lease identity，当前 `StubDeploymentService` 只记录 smoke schema 和结果；没有测试在 deployment callback 执行期间观察 `manager.schemeDeliveryCommitLeaseOperationID == operationID`，也没有断言 fallback 与 rollback 两次调用都发生在同一 lease 内。

关闭条件：增加一个可控 stub/同步点，在 fallback 和 restore deployment 调用期间记录 lease owner，并断言两次 owner 相同且等于该 uninstall operation；同时断言 lease 在最终返回后释放。仅凭调用参数和函数注释不足以完成该 P1 证据。

### P1-04：`rollbackIncomplete` 分支仍不满足完整 before-state contract

当 `stageSchemaUninstall` 抛出 `SchemaUninstallRecoveryError.rollbackIncomplete` 时，当前代码保留 Luna route、保留恢复文件并直接返回（`SchemaManager+Installation.swift:163-176`）。现有测试也固定了只请求 Luna、`activeSchemaID` 保持 Luna 的行为（`UniverseKeyboardTests/SchemaManagerTests.swift:1547-1565`）。这可以是一个需要人工恢复的安全终态，但它不是 Assignment 所写的“部署/暂存失败在 lease 内恢复 complete before-state”。该分支目前只有普通 Logger 和 `staging_rollback_incomplete` 诊断，没有 recovery-incomplete 的完整 route/lease 断言。

关闭条件：要么在该分支能够证明 complete before-state 恢复和原 route redeploy，要么由 Product/Architecture 明确把“fallback 保持运行、恢复文件保留、后续恢复”定义为独立终态，并在 typed diagnostics 与测试中明确其语义。当前 P1 不能把它算作已关闭。

## 不在本 P1 关闭范围内的遗留项

以下项目仍按前一轮 Architecture/Quality review 保留为 P2 或后续设备门禁：App Group 多 key 写入的 crash/跨进程原子性、matched T9 persisted resolver、inactive layout binding 悬挂策略、commit cleanup 的实际结果，以及真实 Extension runtime 和 CS09-10-02 真机耗时对照。

## 本次验证

本复审执行：

```text
git diff --check                         exit 0
xcrun swift-format lint --strict ...     exit 0
```

本次尝试执行：

```text
swift test --package-path Packages/KeyboardCore \
  --filter DiagnosticEventTests --filter DiagnosticsJournalRuntimeTests
```

该命令在 manifest 编译前因本机 Swift/Clang ModuleCache `Operation not permitted` 失败，未把该次尝试计为独立测试通过。当前工作树中已有的 KeyboardCore 及 App 聚焦通过记录仍需由协调者在最终交付报告中单独列出；本复审不把环境失败改写为通过。

## 交接

请先补齐 P1-01 至 P1-04，再请求一次独立复审。P1 关闭后仍只能说明自动化与诊断契约成立；它不能替代普通 Luna deployment 对照、真实 App Group、Extension candidate input 或物理设备耗时矩阵。
