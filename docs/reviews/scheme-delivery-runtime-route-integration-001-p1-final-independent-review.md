# SCHEME-DELIVERY-RUNTIME-ROUTE-INTEGRATION-001 P1 最终独立复审

日期：2026-09-09 Asia/Shanghai
复审 lane：KOS Quality / Performance / Release
复审类型：独立、只读；本文件是本轮唯一新增的复审产物
复审基线：`/private/tmp/uk-scheme-delivery-fix`，`codex/scheme-delivery-fix`，
当前工作树 `HEAD=f9060fc55264b66c2479592885d40690000b4e14`

## 结论

**P1：Pass，建议关闭本轮 P1 条件。** 当前差异没有发现 P0 或 P1 阻断。

**Assignment：Pass with conditions，仍保持 Active。** 本复审只确认自动化 route
transaction、结构化诊断和 lease 证据达到 P1 关闭条件；它不替代完整 CI 等价门、
Extension/真实 App Group 运行证明、CS09-10-02 真机证据、部署耗时对照、Product
Gate、merge、TestFlight 或 Release。

复审期间没有修改生产代码、测试代码、Assignment 或 `docs/ACTIVE_WORK.md`。

## 本轮核查范围

- `SchemaManager+Installation` 的 active-uninstall route transaction、fallback、
  staging、commit 和 rollback 接线；
- `SchemaManager+T9Layout` 从 `RimeRuntimeSelection.resolve` 构建 snapshot，以及
  bindings → layout → legacy alias 的写入顺序；
- `DiagnosticEvent`、`DiagnosticsJournalRuntime`、journal normalized copy 和
  Main-App diagnostics adapter；
- `SchemaManagerTests` 的统一 `assertRuntimeRouteRecords` helper、七条 P1 序列和
  `StubDeploymentService` 的 lease-owner callback seam；
- 既有 pure KeyboardCore route contract 与此前 Architecture/Quality 复审提出的
  P1 条件。

## P1 序列与统一 helper

`assertRuntimeRouteRecords` 现在统一验证：

1. 完整的 phase/result 序列；
2. 所有记录共享同一个 operation UUID，并返回该 UUID供 lease 断言使用；
3. 每条 `elapsedMilliseconds` 都在 `0...600_000` 有界范围内，且序列单调不下降；
4. 失败事件的索引与 `isFailure` 标记完全一致；
5. schema、layout、runtime state 路由字段逐条匹配。

七条指定 P1 终态均使用这个 helper：

| 场景 | 测试 | 期望 phase/result | 路由字段与失败标记 |
|---|---|---|---|
| active 成功 | `testActiveUninstallAwaitsLunaDeployBeforeCommittingFiles` | `before:started → fallback_deploy:started → fallback_deploy:succeeded → staging:started → commit:succeeded` | Ice/26-key/ready 后切 Luna/26-key/ready；无失败 |
| inactive | `testNonActiveUninstallStillRemovesFilesWithoutLunaFallback` | `before:started → inactive:skipped → staging:started → commit:succeeded` | 全程 Luna/26-key/ready；没有 Luna deployment |
| reconciliation failure | `testMalformedInactiveBindingStopsBeforeStagingWithReconciliationDiagnostic` | `before:started → reconciliation:failed` | 全程 Ice/26-key/ready；索引 1 为失败 |
| fallback 失败、rollback 成功 | `testActiveWanxiangUninstallRestoresCompleteRouteStateWhenLunaDeployFails` | `before:started → fallback_deploy:started → fallback_deploy:failed → rollback_deploy:started → rollback_deploy:succeeded` | Wanxiang/26-key/fail-closed → Luna/26-key/ready → Wanxiang/26-key/fail-closed；索引 2 为失败 |
| fallback 失败、rollback 失败 | `testActiveUninstallKeepsFilesAndRestoresSchemaWhenLunaDeployFails` | `before:started → fallback_deploy:started → fallback_deploy:failed → rollback_deploy:started → rollback_deploy:failed` | Ice/26-key/ready → Luna/26-key/ready → Ice/26-key/ready；索引 2、4 为失败 |
| staging 失败、rollback 成功 | `testActiveWanxiangUninstallRestoresCompleteRouteStateWhenStagingFails` | `before:started → fallback_deploy:started → fallback_deploy:succeeded → staging:started → staging:failed → rollback_deploy:started → rollback_deploy:succeeded` | Wanxiang/26-key/fail-closed → Luna/26-key/ready → Wanxiang/26-key/fail-closed；索引 4 为失败 |
| `rollbackIncomplete` | `testIncompleteRollbackStopsWithoutRedeployingOriginalSchema` | `before:started → fallback_deploy:started → fallback_deploy:succeeded → staging:started → staging:recovery_incomplete` | Ice/26-key/ready → Luna/26-key/ready；索引 4 为失败，只部署 Luna，不 redeploy 原方案且不 commit |

成功 staging 的语义已经写入 Assignment：`staging:started` 表示进入 installer，
`commit:succeeded` 表示 `commitSchemaUninstall` 返回；这不是对内部 cleanup 或
crash/restart recovery 的声明。因此没有另造一个未定义的 `staging:succeeded`
事件，前序复审的命名条件已收敛。

## Lease identity 证据

`StubDeploymentService.deploy` 在 deployment callback 执行期间调用
`@MainActor` 的 `leaseOwnerReader`，读取 `manager.schemeDeliveryCommitLeaseOperationID`。
下列有 deployment 的场景都将 callback 观察到的 owner 与 helper 返回的同一个
operation UUID 比较：

- active 成功：`[operationID]`；
- fallback 失败、rollback 成功：`[operationID, operationID]`；
- fallback 失败、rollback 失败：`[operationID, operationID]`；
- staging 失败、rollback 成功：`[operationID, operationID]`；
- `rollbackIncomplete`：`[operationID]`。

这证明 callback 期间确实存在同一个 live lease，而不是只比较传入参数。生产路径
仍在 `defer` 中释放该 lease；`rollbackIncomplete` 测试并检查最终 lease 为 `nil`。
inactive 与 reconciliation failure 没有 deployment callback，因此 owner 列表为空，
不会伪造 lease 观察证据。

## 结构化诊断与隐私边界

`RuntimeRoutePhaseEvent` 只携带 operation UUID、有限枚举 phase/result/schema/layout/state
和有界耗时。`DiagnosticEvent` 的 encoder/decoder、`DiagnosticsJournalWriter` 的
normalized copy 与 `DiagnosticsJournalRuntime.recordRuntimeRoute` 均保留该 payload，
并对 runtime-route code/payload 做对称校验。Main-App adapter 将 `isFailure=true`
映射为 `.error` level；测试 recorder 对每条失败索引做断言。

本轮独立验证通过：

```text
git diff --check
xcrun swift-format lint --strict --configuration .swift-format <9 个受影响 Swift 文件>
swift test --package-path Packages/KeyboardCore --filter \
  'DiagnosticEventTests|DiagnosticsJournalRuntimeTests|RimeRuntimeRouteReconciliationTests'
```

聚焦 KeyboardCore 诊断/路由测试为 **36/36**；完整 KeyboardCore package 为
**1097/1097**。在 `iPhone 17 Pro`、iOS 26.0 Simulator 上，七条
`SchemaManagerTests` P1 场景的 xcresult summary 为 **7 passed, 0 failed, 0 skipped**。

这些 payload 没有用户输入、文件路径、URL、异常原文或资源内容；写入仍通过既有
异步 ingress，不把 journal I/O 等待传播到输入热路径。

## 残余条件与边界

以下事项没有升级为 P0/P1，但仍阻止把 Assignment 或用户反馈标记为完全解决：

| ID / 事项 | Owner | Disposition |
|---|---|---|
| `RTRI-01`：App Group 多 key route 写入的跨进程/崩溃原子性和 prefix invariant | Main App / Architecture | `fix` |
| `RTRI-02`：matched T9 persisted resolver、真实 after-state 读取，以及 inactive binding 在后续布局切换时的悬挂策略 | KeyboardCore / Main App | `fix` |
| `RTRI-03`：commit 内部 cleanup 的实际结果与诊断语义 | Main App / Quality | `fix` |
| `RTRI-04`：RimeBridge/Extension runtime、真实 App Group、candidate input、CS09-10-02 真机矩阵 | Human Device Operator / Quality | `fix` |
| 完整 CI 等价门：RimeBridgeTests、完整 App + Keyboard tests、Debug/Release build | Environment Executor | `fix` |

当前 `RuntimeRoutePhaseEvent` 的字段注释仍把 elapsed 称为 wall-clock；实现实际使用
`DispatchTime` 单调时钟。该文字不改变行为，也不构成 P1 阻断，后续文档卫生可将其
改为 monotonic elapsed，避免读者误解。

## 非声明

本复审不声明：

- 第三方方案 active 时卸载后的 Luna 部署耗时已经恢复到普通部署水平；
- Main-App deployment success 已等于 Extension runtime 可用或 `ni` 候选输入恢复；
- 真实 App Group 文件树、RIME session、物理设备候选行为已经验证；
- PR、merge、TestFlight、Release、Product Gate 或 ADR 0034 已被接受。

## 建议交接

建议 Coordinator 将本轮 `RTRI-05`（recovery-incomplete 语义、完整序列和 lease 证据）
标记为已满足，并保留 Assignment 为 Active；随后单独提交完整 CI 等价门和
CS09-10-02 真机授权请求。任何真机结果都必须携带本 operation trace，并另行测量
普通 Luna deployment 对照耗时。
