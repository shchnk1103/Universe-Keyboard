# SCHEME-DELIVERY-RUNTIME-ROUTE-INTEGRATION-001 独立质量、性能与发布复审

**复审日期：** 2026-09-09（Asia/Shanghai）
**复审 lane：** KOS Quality, Performance & Release
**复审范围：** 当前工作树 `/private/tmp/uk-scheme-delivery-fix` 及其未提交候选
**基线：** `codex/scheme-delivery-fix`，`bbb0d857daa7d40040632d4a67c8578200f23b59`
**Assignment：** [SCHEME-DELIVERY-RUNTIME-ROUTE-INTEGRATION-001](../assignments/scheme-delivery-runtime-route-integration-001.md)

本复审只读检查当前候选的生产/测试差异、回滚边界、诊断可追踪性、隐私和已有命令证据。本 lane 没有修改产品代码、Assignment 或 `docs/ACTIVE_WORK.md`；本文件是唯一新增的复审产物。

## Verdict

**Request changes：当前候选不可关闭该 Assignment。** 没有发现 P0，但有 3 个未关闭的 P1；因此尚未满足 Assignment 的“无开放 P0/P1”退出条件。

### P1-01：runtime-route 结构化诊断在持久化时被丢弃

`DiagnosticsJournalRuntime.recordRuntimeRoute` 已经构造带 payload 的 `DiagnosticEvent`（`Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournalRuntime.swift:115-135`），journal writer 随后直接对 event 做 JSON 编码（`Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournal.swift:502-507`），但 `DiagnosticEvent.encode(to:)` 只编码 scheme-delivery 和 RIME-sync payload，遗漏 `runtimeRoutePayload`（`Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEvent.swift:909-925`）。因此写入诊断 journal 后，route event 只剩 `runtime_route.phase_changed` code，route-before/after、fallback、staging、commit 和 rollback 的结构化字段无法恢复。

解码器的 `runtimeRouteCodes` 集合也没有参与 code/payload 对称校验（同文件 `:809-823`、`:856-879`），所以这个丢失会静默通过，而不是让错误暴露。另一个失败分支 `reconciliation_failed` 没有映射到任何 typed phase，`runtimeRouteDiagnosticPayload` 直接返回 `nil`（`Universe Keyboard/Services/SchemaManager+Installation.swift:300-323`），调用方随后连 Logger 记录也跳过（`:281-298`）。这直接破坏了 Assignment 要求的 content-free operation trace，属于发布诊断证据缺失。

关闭条件：补齐编码、code/payload 对称校验，并为 `reconciliation_failed` 定义可查询的失败 phase；增加 `DiagnosticEvent` JSON round-trip、journal 落盘读取和 active-uninstall phase-sequence 断言，覆盖成功、fallback 失败、rollback 成功/失败、staging 失败及 inactive skipped。

### P1-02：暂存恢复不完整时没有恢复 complete before-state

`performSchemaUninstall` 捕获 `SchemaUninstallRecoveryError` 后保留 Luna fallback 与恢复文件并直接返回（`Universe Keyboard/Services/SchemaManager+Installation.swift:161-174`）。这条安全分支没有重新应用 `mutation.before`，也没有重新部署原 route。现有测试明确固定了该行为：`testIncompleteRollbackStopsWithoutRedeployingOriginalSchema`（`UniverseKeyboardTests/SchemaManagerTests.swift:1523-1542`）断言只请求 Luna、原 receipt 保留、原方案不重新部署。

保留不完整恢复文件可能比把不完整资源树重新部署更安全，但它仍不符合 Assignment 的明确约束：部署或暂存失败必须在 lease 内恢复完整 before-state（Assignment `:25-29`、`:56-61`）。在有明确的 Product/Architecture 例外、终态定义和可观测恢复凭据之前，不能把这个分支报告为已满足 rollback contract。关闭条件应是：实现可证明的完整恢复，或正式修改 Assignment/契约，将“fallback 保持运行、恢复文件保留、等待人工/后续恢复”定义为独立安全终态并补齐验证。

### P1-03：非活动 binding 在卸载后可能悬挂到已删除方案

纯 reconciler 只检查当前 effective slot；若被卸载方案不在该 slot，便返回 `.inactiveRoute` 且不改任何 binding（`Packages/KeyboardCore/Sources/KeyboardCore/RimeRuntimeRouteReconciliation.swift:294-307`）。这符合“当前非活动卸载不触发 Luna”的即时行为，但 `RimeRuntimeSelection.resolveLayoutBound` 在 26-key 路径只按 binding 选择 schema，不检查已安装 receipt 或运行时文件是否存在（`Packages/KeyboardCore/Sources/KeyboardCore/RimeRuntimeSelection.swift:247-270`）。

可复现状态是：`layoutStyle=9_key`、`schemeBinding26=wanxiang`、`schemeBinding9=t9`、T9 readiness marker 与磁盘 fingerprint 匹配、当前 effective route 为 `t9`；卸载 `wanxiang` 会走 inactive 路径并删除其资源，之后用户切到 26-key 时 resolver 仍返回 `wanxiang`。当前 `CS05/CS06` 测试（`UniverseKeyboardTests/SchemaManagerTests.swift:1600-1668`）没有 layout-bound binding、matched readiness 和后续布局切换，因此不能证明这个跨生命周期状态安全。

关闭条件：由 Product/Architecture 明确“保留未安装 binding”之后的解析契约，并以实际安装/运行时可用性证明它不会选择已删除 schema；或者定义无副作用的失效 binding reconciliation。补充“非活动卸载 → 后续切换每个受影响 layout → `RimeRuntimeSelection`/实际 runtime route”测试。该处理不得未经授权改变 Assignment 所承诺的未受影响偏好。

## 已通过的证据

| 领域 | 当前证据 | 结论 |
|---|---|---|
| Pure KeyboardCore route contract | `swift test --package-path Packages/KeyboardCore`：1095 tests，0 failures | 通过；覆盖 26/9 slot、Ice/Wanxiang、dependency、unknown slot 和 fail-closed 纯函数行为 |
| Active Ice / Wanxiang normal path | 聚焦 `SchemaManagerTests` 83 tests，0 failures；包括 CS-07/08、CS-09/10-02 | 通过；当前 effective route 先切 Luna，再进入 staging/commit |
| Fallback deployment failure | CSF2 两方向通过；请求顺序为 Luna → 原 route，target receipt 未提交 | 通过调用顺序和设置恢复；仍缺一侧“首次失败、恢复成功”的混合注入证据 |
| Fallback deployment succeeds then staging fails | 两方向测试通过；请求顺序为 Luna → 原 route，未 commit | 通过当前测试的设置和请求证据；不覆盖 `rollbackIncomplete` 例外 |
| Fail-closed | `testActiveWanxiangUninstallUsesFailClosedTwentySixKeyRoute` 通过 | 通过未匹配 readiness 的 9-key → 26-key Luna 路径；matched marker/fingerprint 的 App 集成证据仍缺 |
| Inactive uninstall | CS05/CS06 通过且没有 Luna deployment | 通过即时 non-fallback 行为；见 P1-03 的后续 layout 悬挂风险 |
| Legacy rollback helper | `setActiveSchemaWithoutDeployment` 已恢复（`SchemaManager+Installation.swift:234-241`），download/upgrade rollback 仍从 `SchemaManager+Download.swift:900-915` 调用 | 通过；没有把旧 rollback 路径误接到 layout-bound transaction |
| Privacy / hot path | route payload 只有 operation UUID、有限 enum、layout 和 state；journal ingress 走现有非阻塞入口 | 源码审计通过；没有输入文本、路径、URL 或原始 exception 写入 route payload。未做真机诊断 UI 验证 |

## P2 残留与证据缺口

1. **P2-01，matched readiness 的集成覆盖不足。** 当前 Wanxiang fail-closed 测试没有写入真实 marker/fingerprint，而是在测试末尾手工以 `t9ReadinessMatched: false` 构造 selection（`UniverseKeyboardTests/SchemaManagerTests.swift:1201-1248`）。需要一条实际 matched T9 → active Ice dependency removal 的 SchemaManager 测试，并检查 after-state 通过同一 resolver 得到 Luna/26-key。

2. **P2-02，route diagnostics 尚未被受影响 target 断言。** `RecordingDeliveryDiagnostics` 已保存 route payload（`UniverseKeyboardTests/SchemaManagerTests.swift:2816-2834`），但当前搜索没有找到 `recordedRuntimeRoutePayloads()` 的 route 用例。active success、deploy failure、staging failure、rollback 和 inactive 的 phase 顺序及同一 operation UUID 都没有测试证据；P1-01 修复后应补上。

3. **P2-03，active Ice 的“fallback 失败、恢复成功”混合结果未覆盖。** Wanxiang 已有 `[false, true]` 注入（`SchemaManagerTests.swift:1251-1287`），Ice 目前主要是全失败请求序列（`:998-1029`、`:1461-1489`）。应补对称用例，且断言 persisted route 和 typed diagnostics，而不只断言 deployment request。

4. **P2-04，commit 诊断可能乐观。** `commitSchemaUninstall` 内部对 staging root cleanup 使用 `try?` 且不返回结果（`Universe Keyboard/Services/SchemaArchiveInstaller.swift:269-274`），管理器随后无条件记录 `commit_succeeded`（`SchemaManager+Installation.swift:197-208`）。若“commit result”是契约字段，应让事件反映实际结果，或把事件名称/语义收窄为 commit invoked/target moved。

5. **P2-05，多 key preference 写入只有安全前缀顺序，没有跨进程原子性。** 当前顺序为 bindings → layout → legacy alias，并在最后 `synchronize()`（`SchemaManager+T9Layout.swift:253-272`）；这已避免先暴露将被删除的 schema，但 App Group preferences 仍可能在进程中断时留下部分前缀。该候选没有 recovery receipt 或启动修复机制，属于已知残留，不应在发布报告中宣称事务原子性。

## 可复现实证与未声明范围

已执行：

```text
git diff --check
xcrun swift-format lint --strict --configuration .swift-format \
  'Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEvent.swift' \
  'Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournalRuntime.swift' \
  'Universe Keyboard/Services/SchemaDeliveryDiagnostics.swift' \
  'Universe Keyboard/Services/SchemaManager+Installation.swift' \
  'Universe Keyboard/Services/SchemaManager+T9Layout.swift' \
  'UniverseKeyboardTests/SchemaManagerTests.swift'
swift test --package-path Packages/KeyboardCore
xcodebuild -project "Universe Keyboard.xcodeproj" -scheme "Universe Keyboard" \
  -configuration Debug \
  -destination 'id=8C2943AC-AC97-432F-ACEE-BE3DA2B9ACB2' \
  CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=6.0 SWIFT_STRICT_CONCURRENCY=complete \
  SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES \
  -derivedDataPath /private/tmp/uk-scheme-delivery-fix-derived-data-quality \
  -only-testing:UniverseKeyboardTests/SchemaManagerTests test
```

结果为：KeyboardCore 1095/1095 通过；`SchemaManagerTests` 83/83 通过；strict format 和 diff check 通过。xcodebuild 输出包含模拟器 App Group entitlement 与 IOHID plugin warning，但没有测试失败。

未执行或不能由本复审替代：完整 App + Keyboard 测试、RimeBridgeTests、Debug/Release 全量 build、真实 App Group/文件树证明、Extension runtime、物理设备 CS09-10-02、Product/merge/Release Gate。因 P1 未关闭，本 artifact 不构成 merge、device、TestFlight 或 Release 批准。

## 交接结论

当前候选已经证明纯 Core 合约、主要 active fallback 调用顺序、常规 staging failure 恢复和 inactive immediate non-fallback 行为；它尚未证明“诊断可持久化且完整”、`rollbackIncomplete` 的 Assignment 终态、以及非活动 layout binding 在资源删除后的后续解析安全性。先处理 P1-01 至 P1-03 并补齐对应证据，再重新进入独立质量复审。
