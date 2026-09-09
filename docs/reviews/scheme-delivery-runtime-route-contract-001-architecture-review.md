# SCHEME-DELIVERY-RUNTIME-ROUTE-CONTRACT-001 Architecture Review

日期：2026-09-08 Asia/Shanghai

审查类型：独立、只读 Architecture review

审查基线：`/private/tmp/uk-scheme-delivery-fix`，分支
`codex/scheme-delivery-fix`。审查开始时，本次候选新增的
`RimeRuntimeRouteReconciliation.swift` 与
`RimeRuntimeRouteReconciliationTests.swift` 为未跟踪文件；工作区中另有任务管理方
并行创建的 Assignment 文件。Architecture reviewer 未修改、暂存或提交代码、
Assignment 或其他既有文件。

## Scope

本审查只覆盖：

- `Packages/KeyboardCore/Sources/KeyboardCore/RimeRuntimeRouteReconciliation.swift`
- `Packages/KeyboardCore/Tests/KeyboardCoreTests/RimeRuntimeRouteReconciliationTests.swift`
- 既有 `RimeRuntimeSelection`
- ADR 0026、RIME 生命周期/方案管理边界和
  `docs/plans/scheme-delivery-active-uninstall-runtime-route-reconciliation-2026-09-08.md`

本审查不包含主 App 接线、`SchemaManager` 修改、RimeBridge 修改、App Group
实际读写、部署、文件暂存/提交、真机操作、Product Gate、PR 合并或 Release。

## Ownership

- Architecture review：Architecture & Knowledge Steward review lane。
- 纯路由契约后续实现：KeyboardCore / Input Intelligence owner，需与 App & Data
  Operations、RIME Platform 和 Quality owner 协调。
- 主 App 持久化、卸载事务和部署：App & Data Operations owner；Extension session
  与 schema 选择边界由 RIME Platform / Keyboard Experience owner 接收。
- 下一合法动作：先关闭本文件列出的架构条件，再另行进行 Main App 事务接线和
  Quality review；不得把本文件当作实现授权或 ADR 接受。

## Applicable Contracts

- `docs/PROJECT_CONTEXT.md`：KeyboardCore 纯逻辑、主 App/Extension 分工和 RIME
  运行时边界。
- `docs/architecture/decisions/0001-main-app-owns-rime-deployment.md`：只有主 App
  可以执行完整 RIME deployment。
- `docs/architecture/decisions/0003-shared-container-ownership.md`：共享容器的
  reader/writer 所有权和 Extension 写入限制。
- `docs/architecture/decisions/0004-rime-runtime-session-model.md`：session 与
  deployment 分离及 Extension session 生命周期。
- `docs/architecture/decisions/0006-schema-install-transaction-model.md`：方案
  安装/卸载事务、staging、commit 和 rollback 边界。
- `docs/architecture/decisions/0026-layout-bound-rime-scheme-selection.md`：布局槽位、
  effective runtime、T9 readiness 和 fail-closed 规则。
- `docs/plans/scheme-delivery-active-uninstall-runtime-route-reconciliation-2026-09-08.md`：
  本次 proposed route-reconciliation 目标、停止条件和后续验证要求。

## Evidence

静态审查确认：

1. `RimeRuntimeRouteReconciliation.swift` 只导入 Foundation，不读取或写入
   UserDefaults/App Group，不访问文件系统，不调用 RimeBridge/librime，也不执行
   deployment、staging 或 commit。
2. `RimeRuntimeRouteReconciler` 在生成 mutation 前检查 selected slot、fallback、
   fallback capability；selected slot 没有 fallback 或 fallback 不受支持时返回
   failure，不生成部分 mutation。
3. 当前测试覆盖 Ice/Wanxiang 的 26 键和九键案例、T9 对 Ice 的依赖清理、无关九键
   绑定保留，以及 selected future-like slot 没有 fallback 时停止。
4. 既有 `RimeRuntimeSelection` 在 ADR 0026 规则下会根据九键 readiness 选择 `t9`，
   readiness 失效时 fail-closed 到 26 键 binding。当前 route snapshot 没有携带或
   复用这项 effective-route 事实。
5. 既有 Main App settings 接口按 key 逐项 `set/remove/synchronize`；当前 pure
   mutation 没有旧状态或 rollback 记录。这个事实使后续接线必须单独建立完整的
   route-state transaction。

曾尝试独立运行：

```text
swift test --package-path Packages/KeyboardCore --filter RimeRuntimeRouteReconciliationTests
```

该命令在 manifest 编译阶段被本机 `/Users/doubleshy0n/.cache/clang/ModuleCache`
权限错误阻塞，未形成本次 Architecture review 的测试通过证据。审查没有把执行器
此前报告的测试结果升级为 Quality-reverified 证据。

## Decision

结论：**Pass with conditions**。

这两个 KeyboardCore 文件可以作为无副作用的路由决策 seam 保留；它们没有违反
Main App/Extension、App Group 或 deployment 的现有边界。但是，以下条件是接入
`SchemaManager` 前的阻塞条件。它们尚未关闭，也不代表 Product、Quality、ADR、
merge、TestFlight 或 Release 通过。

### P1 — 活动路由必须绑定到 ADR 0026 的 effective route

`RimeRuntimeRouteSnapshot` 只保存 `selectedLayoutStyle` 和 slots，reconciler
也只按 persisted layout 找 selected slot。ADR 0026 和
`RimeRuntimeSelection` 则规定：九键 preference 在 T9 readiness 不匹配时，实际
effective route 是 26 键 binding。

例如：layout preference 是九键、九键 binding 是 `t9`、readiness 失效、26 键
binding 是 `wanxiang`。实际运行路由是 Wanxiang 26 键；移除 Wanxiang 时，当前
reconciler 只看九键 slot，可能返回
`selectedRouteDoesNotReferenceRemovedSchema`，让 Extension 在目标文件已删除后
仍请求失效的 Wanxiang route。

接线前必须明确并测试以下设计之一：

- snapshot 携带已经由 `RimeRuntimeSelection` 得出的 effective schema/layout；或
- reconciler 接收 readiness/install facts，并与 `RimeRuntimeSelection` 共用同一
  route resolution。

至少需要覆盖 readiness 失效时 26 键 peer 为 effective route、T9 readiness 成功
时九键 route 生效，以及 legacy bindings 尚未迁移的场景。mutation 应用后的持久化
状态还必须再次通过同一 resolver 验证为 Luna。

Owner area：KeyboardCore + RIME Platform + App & Data Operations。Disposition：
`fix`，接线前未关闭。

### P1 — route mutation 必须纳入原子应用和精确 rollback

当前 `RimeRuntimeRouteMutation` 只表达目标状态。其注释要求调用方原子应用后再
部署，但现有 settings store 没有多 key transaction；而现有卸载失败恢复只恢复
`activeSchemaID`，不足以恢复 layout、26 键 binding、九键 binding 和可能被触及的
T9 readiness marker。

如果 Luna deployment 或 schema staging 失败，事务必须在释放 commit lease 前恢复
完整旧 route；如果 staging/commit 成功，Extension 才能看到完整的新 route。不能
依赖 `synchronize()` 把多个独立 key 写入视为一个原子事务，也不能只恢复
`rime_active_schema`。

接线必须提供 route-state snapshot/transaction ledger，覆盖所有 touched keys，
并加入 deployment failure、staging failure 和 rollback failure 的测试。否则会
出现文件仍是旧方案、设置却已部分切到 Luna 的跨进程状态。

Owner area：App & Data Operations；Disposition：`fix`，接线前未关闭。

### P1/P2 — inactive uninstall 与 invalid-input failure 必须分离

`.selectedRouteDoesNotReferenceRemovedSchema` 目前既可能代表“目标方案不是当前
effective route”，也可能由空的 removed/fallback schema ID 等非法输入触发。

后续调用方若把所有 failure 都当成“停止整个卸载”，会破坏既有 inactive-uninstall
策略：保留当前 peer、不要强制 Luna，但继续普通卸载。若把该 failure 当成安全跳过
路由处理，非法 snapshot 又可能绕过安全检查。

建议新增明确的 inactive outcome 与 invalid snapshot/input outcome，或规定只有已由
同一 effective resolver 确认 active 的 route 才能进入 reconciler。CS05/CS06 的
inactive-uninstall 行为必须在 Main App 接线测试中保持。

Owner area：App & Data Operations + KeyboardCore。Disposition：`fix`，接线前未关闭。

### P2 — fallback descriptor 和 slot registry 需要 fail-closed 校验

当前实现按 preference key 找 fallback slot，并检查 schema 是否在
`supportedSchemaIDs` 中，但没有校验：

- fallback route 的 layout 与 fallback slot layout 一致；
- layout 和 preference key 唯一；
- descriptor 的 preference key/schema ID 非空；
- fallback schema 的 canonical identity 和实际可用资源一致。

重复 layout/key 会让 `first(where:)` 依赖数组顺序，并可能产生同一 key 的多个
mutation；fallback style 不一致则可能写入 26 键 Luna 却持久化九键 layout。

需要增加 malformed/duplicate descriptor 的负向测试，并明确 Main App 以稳定顺序
构造 registry。未来槽位的 capability 和 fallback 不能靠卸载代码增加条件分支。

Owner area：KeyboardCore + App & Data Operations。Disposition：`fix`，接线前未关闭。

### P2 — capability、canonicalization 和 installed/readiness 事实必须有单一来源

`supportedSchemaIDs`/`dependencySchemaIDs` 是调用方传入的裸字符串，当前没有直接
绑定既有 `RimeSchemeCapabilityMatrix` 或 `RimeRuntimeSelection` 的 canonicalization。
这允许 reconciler 认为某 schema 可用，而 Extension resolver 实际不支持，或把能力
事实与 installed/readiness 事实混淆。

Main App 构造 snapshot 时必须使用既有 catalog/capability source；`t9` 与
`rime_ice` 等 identity 规则必须统一。Luna 是当前 approved built-in fallback，
其资源/receipt 仍须在 Main App deployment boundary 验证；不能把 capability list
单独当成 installed proof。

Owner area：RIME Platform + App & Data Operations。Disposition：`fix`，接线前未关闭。

### P3 — optional 和空值语义需要收紧

`boundSchemaID` 声明为 optional，但初始化时把 nil 归一化为空字符串；这与“如果有
绑定”的文档语义不一致，也会让 snapshot equality 和 invalid input 判断含混。建议
保留 nil，并把空 preference/schema ID 作为显式 invalid snapshot。

Owner area：KeyboardCore。Disposition：`fix`，可在下一次纯契约修订中关闭。

## Boundary Confirmation

- **KeyboardCore/UI：** 当前文件没有 UIKit 或 UI 状态；纯 mutation 不应由 View 或
  按键热路径调用。
- **Main App/Extension：** Main App 是 snapshot 构造、mutation 应用、deployment、
  staging 和 commit 的唯一 owner；Extension 只能读取完整持久化 route，创建 session
  并选择 schema。Extension 不得调用 reconciler 或执行 deployment/repair。
- **App Group：** KeyboardCore 不直接触碰 App Group；Main App 后续写入必须有明确
  key owner、transaction/rollback 和跨进程可见性证据。
- **Rime deployment/session：** pure route reconciliation 不等于 deployment 成功，
  deployment 与 Extension session 仍需分别验证。

## Future-slot Stop Semantics

对当前 selected descriptor，缺少 fallback 或 fallback 不支持 approved Luna 时，
代码在生成 binding mutations 前返回 failure，因此这条未来槽位停止语义是成立的。

但这还不是完整的 future-slot 安全证明：当前测试使用现有 `KeyboardLayoutStyle`
case 构造 future-like descriptor，没有覆盖真正新增 layout case、duplicate registry、
fallback style mismatch、effective route 与 persisted layout 不同的情况。上述 P1/P2
条件关闭前，不得声称未来槽位整体安全。

## Required Verification And Handoff

接收方必须提供：

1. KeyboardCore focused tests：effective route/readiness、legacy migration、post-
   mutation `RimeRuntimeSelection` 结果、invalid/duplicate/fallback mismatch 和
   future-slot stop。
2. Main App `SchemaManager` transaction tests：Ice/Wanxiang 双向 active uninstall、
   inactive uninstall、Luna deploy failure、staging failure、route rollback 和 lease
   内顺序。
3. RimeBridge/Extension target test：持久化 reconcile 后实际请求 Luna，而不是已删除
   schema；保持 Extension 无 deployment。
4. 严格格式检查及适用的 KeyboardCore、RimeBridge、App + Keyboard CI 等价门禁。
5. 按原计划重新执行 CS09-10-02 双向物理设备矩阵，记录 content-free operation
   trace 和真实 candidate input 结果。

这些验证完成前，Architecture review 只保留本文件的条件结论；Quality review、
Product Gate、ADR 0034 Accept、PR undraft/merge、TestFlight 和 Release 均未发生。

## Documentation Impact

本文件是本次独立审查的唯一 review artifact。ADR 0026 仍是 layout-bound runtime
的权威来源；本文件不改变其 Decision，也不接受 Proposed route plan 或 ADR 0034。

如果后续修订改变 effective-route、fallback、跨进程 persistence 或 rollback 契约，
必须先更新相应的 architecture/plan Source of Truth，再重新进行 Architecture 与
Quality review。当前不更新 CHANGELOG，不修改 Assignment、Active Work 或任何 ADR。

## Non-claims

- 没有实现或批准 Main App 接线。
- 没有证明部署成功可被 Extension 真实消费。
- 没有物理设备、TestFlight、Product Gate、Release 或 merge 证据。
- 没有接受 ADR 0034，也没有关闭本文件列出的条件。

## Post-implementation Architecture re-review

日期：2026-09-09 Asia/Shanghai

复审基线：同一隔离 worktree `/private/tmp/uk-scheme-delivery-fix`、分支
`codex/scheme-delivery-fix`，当前实现仍未提交；复审对象为当前未跟踪的纯
KeyboardCore source/test 文件。复审只读进行；本节没有修改产品代码、Assignment、
Active Work 或 ADR。

### 当前 verdict

结论：**Pass with conditions**。在本次授权的纯 KeyboardCore 范围内，没有新的 P0
或 P1 阻断项。先前的 P1 要求已经在契约层得到对应结构和测试证据：effective
route 不再由 persisted layout 单独推断，mutation 同时携带完整 before/after route
state，inactive uninstall 与 invalid input/snapshot 也已经分型。

这个 verdict 只表示纯值契约可以交给后续接线评审；它不表示 `SchemaManager` 已应用
mutation，不表示部署、暂存/提交、rollback、Extension 消费或 CS09-10-02 已修复。

### P1 disposition

1. `RimeRuntimeRouteSnapshot` 现在携带 `RimeRuntimeEffectiveRoute`，reconciler 按
   effective route 的 layout 找 slot，而不是按 persisted `selectedLayoutStyle` 找
   active slot。`RimeRuntimeEffectiveRoute.State.failClosed` 明确保留了 ADR 0026
   的 26-key fallback 事实。对应实现见
   [`RimeRuntimeRouteReconciliation.swift:77`](../../Packages/KeyboardCore/Sources/KeyboardCore/RimeRuntimeRouteReconciliation.swift#L77)、
   [`RimeRuntimeRouteReconciliation.swift:294`](../../Packages/KeyboardCore/Sources/KeyboardCore/RimeRuntimeRouteReconciliation.swift#L294)，
   测试见
   [`RimeRuntimeRouteReconciliationTests.swift:68`](../../Packages/KeyboardCore/Tests/KeyboardCoreTests/RimeRuntimeRouteReconciliationTests.swift#L68)。
   这覆盖了“九键 preference、T9 readiness fail-closed、实际 Wanxiang 26-key”移除
   Wanxiang，以及此时移除 Ice 仍为 inactive 的关键判断。

2. `RimeRuntimeRouteMutation` 的 `before`/`after` 均保存 selected layout、effective
   route、legacy `activeSchemaID` 和所有 ordered bindings；binding mutation 只保留
   实际变化。对应实现见
   [`RimeRuntimeRouteReconciliation.swift:154`](../../Packages/KeyboardCore/Sources/KeyboardCore/RimeRuntimeRouteReconciliation.swift#L154)、
   [`RimeRuntimeRouteReconciliation.swift:372`](../../Packages/KeyboardCore/Sources/KeyboardCore/RimeRuntimeRouteReconciliation.swift#L372)，
   rollback 输入覆盖证据见
   [`RimeRuntimeRouteReconciliationTests.swift:168`](../../Packages/KeyboardCore/Tests/KeyboardCoreTests/RimeRuntimeRouteReconciliationTests.swift#L168)。
   这关闭了纯契约中“只有目标值、无法恢复完整 route”的缺口；跨进程原子写入和失败
   rollback 仍属于未授权的 Main App 接线。

3. 空 removed ID 进入 `invalidInput`，malformed/duplicate descriptor 进入
   `invalidSnapshot`，不引用 effective route 的卸载进入 `inactiveRoute`。测试覆盖
   [`RimeRuntimeRouteReconciliationTests.swift:153`](../../Packages/KeyboardCore/Tests/KeyboardCoreTests/RimeRuntimeRouteReconciliationTests.swift#L153)、
   [`RimeRuntimeRouteReconciliationTests.swift:255`](../../Packages/KeyboardCore/Tests/KeyboardCoreTests/RimeRuntimeRouteReconciliationTests.swift#L255)。

### P2 disposition and residual conditions

- fallback descriptor 现在在产生 mutation 前检查 availability、approved schema、
  target preference key、target layout、target capability；registry 也拒绝空 key、
  空 schema、重复 key 和重复 layout。对应实现见
  [`RimeRuntimeRouteReconciliation.swift:310`](../../Packages/KeyboardCore/Sources/KeyboardCore/RimeRuntimeRouteReconciliation.swift#L310)、
  [`RimeRuntimeRouteReconciliation.swift:422`](../../Packages/KeyboardCore/Sources/KeyboardCore/RimeRuntimeRouteReconciliation.swift#L422)，
  负向测试见
  [`RimeRuntimeRouteReconciliationTests.swift:308`](../../Packages/KeyboardCore/Tests/KeyboardCoreTests/RimeRuntimeRouteReconciliationTests.swift#L308)。
  这关闭了初审中 Q-RTR-P2-01、Q-RTR-P3-02 所指的 layout/capability/duplicate
  descriptor 缺口。
- `fallbackSchemaID` 的 removed-schema 比较使用现有
  `RimeSchemeCapabilityMatrix.normalizeSchemaID`，因此 `t9` 与 `rime_ice` 的逻辑
  identity 不会被当作两个可同时存在的 fallback。这个 canonicalization 目前明确
  覆盖 input fallback guard；Main App 构造 `supportedSchemaIDs`、
  `dependencySchemaIDs` 以及 removed resource ID 时仍必须使用同一 canonical source。
- `Availability` 已成为 descriptor 的显式事实，但 `.available` 仍是调用方提供的
  capability/installation/readiness 断言；它不是安装 receipt 或 readiness marker 的
  证明。该边界符合本 Assignment 的 pure slice，但在接线前必须由 App/RIME owner
  绑定到真实 Source of Truth，不能由这个 enum 单独宣称资源可用。
- 当前契约把 effective route 当作与 `RimeRuntimeSelection` 同源的已解析输入，未在
  Core 内复制 resolver。这个设计保留了单一解析来源，但当前测试没有通过一个共享
  adapter 直接从 `RimeRuntimeSelection` 生成 fail-closed snapshot；因此接线时必须
  增加该契约测试，证明 `effectiveRoute`、`supportedSchemaIDs` 和 dependency
  closure 使用同一组 readiness/capability facts。
- `usesT9InputSemantics` 与 effective layout/state 的一致性目前依赖调用方，契约校验
  尚未拒绝“26-key + T9 semantics”或“nine-key + 非 T9 semantics”的 malformed
  effective route。它不是当前已覆盖路径的 P1，但在引入新的 layout/fallback 前应补
  invariant guard 与负向测试。

### Verification evidence

独立执行：

```text
xcrun swift-format lint --strict --configuration .swift-format \
  Packages/KeyboardCore/Sources/KeyboardCore/RimeRuntimeRouteReconciliation.swift \
  Packages/KeyboardCore/Tests/KeyboardCoreTests/RimeRuntimeRouteReconciliationTests.swift
```

结果：exit code `0`。

```text
env CLANG_MODULE_CACHE_PATH=/private/tmp/uk-scheme-delivery-fix/.build/module-cache \
  SWIFT_MODULECACHE_PATH=/private/tmp/uk-scheme-delivery-fix/.build/module-cache \
  swift test --package-path Packages/KeyboardCore \
  --cache-path /private/tmp/uk-scheme-delivery-fix/.build/swiftpm-cache \
  --filter RimeRuntimeRouteReconciliationTests
```

结果：`19` tests，`0` failures。

同样的隔离 cache 配置运行完整 `swift test --package-path Packages/KeyboardCore`
结果为 `1095` tests，`0` failures。默认 sandbox 首次运行仍在 manifest 阶段受本机
Swift clang module cache 权限限制；使用隔离 worktree cache 的只读 host execution
完成了相同测试。没有把该环境差异记录成产品失败。

### Handoff and non-claims

Architecture 复审允许把当前纯 Core 契约交给 Quality 复审和后续独立的 Main App
Assignment，但不替代任何人类或产品 Gate。Quality artifact 需要基于当前 19/19、
1095/1095 证据重新记录，不能沿用初始 6/6、1082/1082 的旧基线。

下一阶段仍必须单独证明：同一 resolver facts 生成 snapshot、主 App route-state
transaction 的原子应用、Luna deployment/staging failure rollback、RimeBridge/
Extension 实际选择 Luna，以及双向 CS09-10-02 真机结果。当前没有执行这些工作，
也没有授权 merge、PR、TestFlight、Release、Product Gate 或 ADR 0034 接受。
