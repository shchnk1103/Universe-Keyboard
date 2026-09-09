# SCHEME-DELIVERY-RUNTIME-ROUTE-INTEGRATION-001 P1 closure 独立复审

日期：2026-09-09 Asia/Shanghai
复审 lane：KOS Quality / Performance / Release，只读
复审基线：`/private/tmp/uk-scheme-delivery-fix`，当前未提交工作树

本复审只新增本文，没有修改产品代码、Assignment 或
`docs/ACTIVE_WORK.md`。复审对象是本轮已授权的 recovery-incomplete 契约收敛、完整
Luna route-state 断言，以及此前 P1 的 typed journal、累计耗时和 active-uninstall
序列。

## 结论

结论：**Pass with conditions；P1 不能关闭。**

本轮已经消除了 recovery-incomplete 语义冲突，并且对应测试确实断言了 Luna
fallback 的 layout、26 键 binding、9 键 binding、legacy active-schema alias、
`activeSchemaID`、保留安装标记和“不重新部署原方案”。但是，P1 的可审计闭环仍缺少
完整的分支序列与 lease identity 证据；本机独立测试还受到环境权限错误影响。因此不能
把 P1 标记为关闭，也不能把第三方方案 active 时卸载后的 Luna 部署变慢判定为已解决。

## 已满足的 P1 条件

### Recovery-incomplete tuple 与 route-state

Assignment 的 Failure Recovery Contract 已把该终态固定为：`phase=staging`、
`result=recovery_incomplete`、`isFailure=true`，并明确保留已部署 Luna、恢复文件和
安装元数据，跳过原方案 redeploy，在 commit 前停止
（`docs/assignments/scheme-delivery-runtime-route-integration-001.md:67-90`）。

主 App 的 `runtimeRouteDiagnosticPayload` 将内部阶段
`staging_rollback_incomplete` 映射为 typed payload 的 `.staging` /
`.recoveryIncomplete`；调用点传入 `isFailure: true`，且复用同一 uninstall
`operationID`（`Universe Keyboard/Services/SchemaManager+Installation.swift:86-89,170-184,320-356`）。
这在结构化字段层面符合 Assignment 要求。

`testIncompleteRollbackStopsWithoutRedeployingOriginalSchema` 已断言：只请求
Luna、没有 commit、安装标记仍在、layout 为 26 键、26 键 binding 为 Luna、9 键
binding 被清除、legacy alias 与 `activeSchemaID` 均为 Luna、lease 在返回后释放，
并断言完整的 `before → fallback started/succeeded → staging started/recovery_incomplete`
序列（`UniverseKeyboardTests/SchemaManagerTests.swift:1558-1596`）。这一部分的
route-state 证据可以接受。

### Typed payload 与累计耗时接线

`RuntimeRoutePhaseEvent` 仍只包含有限枚举、operation UUID、route-state 和有界
`elapsedMilliseconds`；journal encoder、normalized writer copy 和 async ingress
保留该 payload。主 App 也从同一 `operationStartedAt` 为各阶段计算累计耗时
（`Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEvent.swift`、
`DiagnosticsJournal.swift`、`DiagnosticsJournalRuntime.swift`，以及
`SchemaManager+Installation.swift:86-97,291-356`）。这是结构化诊断设计上的有效进展。

## 未关闭的 P1 条件

### P1-01：分支的完整 typed sequence 仍不完整

当前 phase/result 枚举支持 staging 的 started/failed/recovery-incomplete，但成功
路径在 `staging_started` 后直接记录 `commit_succeeded`，没有 `staging:succeeded`。
如果契约规定“staging started 后由 commit result 代表 staging 完成”，该语义尚未写入
Assignment 或测试；如果要求 staging start/result，则成功事件缺失。

测试证据也不完整：

- 成功路径只断言 `before → fallback → staging:started → commit:succeeded`，没有
  staging 成功语义、operation UUID、route fields 或 elapsed 断言
  (`SchemaManagerTests.swift:966-1006`)。
- fallback 失败后 rollback 失败的测试只断言最后两个 rollback phase；没有断言整个
  `[false,false]` sequence 属于同一 operation
  (`SchemaManagerTests.swift:1007-1047`)。
- Wanxiang staging failure 测试没有注入 `RecordingDeliveryDiagnostics`，因此只验证
  deployment request 和 preference restore，没有 typed sequence 证据
  (`SchemaManagerTests.swift:1324-1363`)。
- inactive 路径虽有 `before → inactive → staging → commit` 的 phase 断言，但没有
  固定 operation UUID、failure level 和 elapsed bounded 证据
  (`SchemaManagerTests.swift:1598-1636`)。

关闭条件：为 success、inactive、reconciliation failure、fallback failure + rollback
success、fallback failure + rollback failure、staging failure + rollback success 和
recovery-incomplete 各建立完整 sequence assertion；明确 staging success 的契约；
每组断言所有 payload 使用同一个 operation UUID、失败事件为 error、route fields
一致且 elapsed 在边界内。

### P1-02：同一 operation UUID 已在生产代码传递，但 lease identity 没有运行时证据

生产路径在取得 lease 后生成 operation ID，fallback 与 restore 都把它传给
`deployRimeConfig(leaseOperationID:)`，最后由 `defer` 释放
（`SchemaManager+Installation.swift:86-89,116,125-130,193-199,256-279`）。
这证明了接线意图，但 `StubDeploymentService` 只记录 smoke schema 和结果，未在
deployment callback 执行期间读取 `manager.schemeDeliveryCommitLeaseOperationID`。
现有测试只在 operation 返回后断言 lease 为 nil，无法证明 fallback 与 rollback 两次
副作用发生在同一个 live lease 内，也无法证明 rollback failure 分支保持该 lease。

关闭条件：加入可控 deployment seam，在 fallback 和 restore callback 内记录 lease owner；
对成功、rollback success、rollback failure 至少断言每次 owner 都等于同一个 uninstall
operation ID，并在 operation 完成后断言 lease 已释放。

### P1-03：独立测试未能形成新的通过证据

本次尝试执行：

```text
swift test --package-path Packages/KeyboardCore --filter 'DiagnosticEventTests|DiagnosticsJournalRuntimeTests'
xcodebuild -project 'Universe Keyboard.xcodeproj' -scheme 'Universe Keyboard' -configuration Debug \
  -destination 'id=8C2943AC-AC97-432F-ACEE-BE3DA2B9ACB2' CODE_SIGNING_ALLOWED=NO \
  SWIFT_VERSION=6.0 SWIFT_STRICT_CONCURRENCY=complete SWIFT_SUPPRESS_WARNINGS=NO \
  SWIFT_TREAT_WARNINGS_AS_ERRORS=YES -only-testing:UniverseKeyboardTests/SchemaManagerTests test
```

两者均未进入测试执行：SwiftPM/Xcode 在解析 KeyboardCore 时无法打开本机
`~/.cache/clang/ModuleCache`，报 `Operation not permitted`；xcodebuild 同时报告
CoreSimulatorService connection invalid。该环境失败不应被改写为测试通过。`git diff --check`
通过；工作树中此前留下的 DerivedData 也不构成本次独立复审的通过证据。

## P2 与本 P1 的边界

下列事项仍属于后续 P2 或独立设备门禁，不阻塞本次 P1 closure 判断，但不能被 P1
通过替代：

- App Group 多 key 写入的 crash/跨进程原子性；
- matched T9 persisted resolver、inactive binding 悬挂策略和 commit cleanup 实际结果；
- Extension runtime、真实 App Group、候选输入行为以及普通 Luna deploy 对照；
- CS09-10-02 物理设备耗时矩阵、Product Gate、PR、merge、TestFlight 和 Release。

P1 关闭后最多证明自动化 route transaction 与 structured diagnostic contract 成立；
它仍不能证明用户反馈的 Luna fallback 部署时延已恢复到普通部署水平。

## 交接

请先补齐 P1-01 的完整 sequence/UUID 断言和 P1-02 的 live lease 观察，再在可用的
测试环境重新执行受影响 target，随后请求下一轮独立 Architecture / Quality 复审。
