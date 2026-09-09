# SCHEME-DELIVERY-RUNTIME-ROUTE-INTEGRATION-001 Architecture Review

日期：2026-09-09 Asia/Shanghai

审查类型：独立、只读 Architecture & Knowledge Steward review

审查基线：`/private/tmp/uk-scheme-delivery-fix`，分支
`codex/scheme-delivery-fix`。基线为当前未提交工作区；审查期间没有修改产品
代码、Assignment 或 Active Work，只新增本 review artifact。

## Scope

本审查覆盖当前主 App 集成差异：

- `Universe Keyboard/Services/SchemaManager+Installation.swift`
- `Universe Keyboard/Services/SchemaManager+T9Layout.swift`
- `UniverseKeyboardTests/SchemaManagerTests.swift` 中新增的 active-uninstall
  route 测试
- 已复审的
  `Packages/KeyboardCore/Sources/KeyboardCore/RimeRuntimeRouteReconciliation.swift`
  及其契约测试，作为接线输入

本审查重点是 resolver facts、Main App/Extension 与 deployment ownership、lease
内 route-state before/after restore、Luna-only fallback、archive staging/commit
边界和 T9 readiness fail-closed。真机、RimeBridge/Extension 运行、PR、merge、
TestFlight、Release 和 Product Gate 不在本次审查范围内。

## Applicable contracts

- `docs/assignments/scheme-delivery-runtime-route-integration-001.md`
- `docs/plans/scheme-delivery-active-uninstall-runtime-route-reconciliation-2026-09-08.md`
- ADR 0001：Main App 独占 RIME deployment
- ADR 0003/0004/0006：shared container、Extension session 和 schema
  staging/commit/rollback 边界
- ADR 0026：layout-bound binding、effective route、T9 readiness 和 fail-closed
- `Packages/KeyboardCore/Sources/KeyboardCore/RimeRuntimeSelection.swift`

## Evidence

### 已满足的边界

1. `currentRuntimeRouteSnapshot()` 在
   `Universe Keyboard/Services/SchemaManager+T9Layout.swift:185-250` 调用
   同一份 `RimeRuntimeSelection.resolve`，输入包括 persisted layout、两个
   layout bindings、readiness marker 和 shared-data fingerprint，并把
   `effectiveSchemaID`、`effectiveLayoutStyle`、T9 semantics 和 fail-closed
   状态放入 snapshot。它没有在 Extension 或 RimeBridge 中新增生产接线。
2. `performSchemaUninstall()` 在
   `Universe Keyboard/Services/SchemaManager+Installation.swift:86-151`
   先持有既有 schema-delivery commit lease，再区分 effective active route、
   inactive route 和 malformed snapshot。active route 只使用 pure reconciler
   产生的 Luna mutation；inactive route 保留既有 staging 后 request-deploy
   行为。
3. `applyRuntimeRouteState()` 只在 Main App `SchemaManager` 的 `@MainActor`
   路径执行，写入顺序为 bindings → layout → legacy alias
   （`SchemaManager+T9Layout.swift:253-273`）。部署仍通过既有
   `deployRimeConfig(leaseOperationID:)`，没有向 Extension 下放 deployment 或
   App Group 写权限。
4. fallback descriptor 仍固定为 `luna_pinyin`；当前 diff 没有新增 peer-prefer、
   fallback scheme、archive path、ownership 或删除规则。`stageSchemaUninstall`
   和 `commitSchemaUninstall` 的调用边界保持在原有 installer 中。
5. active route 的失败路径在同一个 lease 内调用
   `restoreSchemaAfterFailedUninstall(mutation.before, ...)`
   （`SchemaManager+Installation.swift:113-126`、`175-194`、`243-263`），
   restore state 包含 layout、legacy alias、全部 binding 和 effective route，
   不再只恢复一个 global active-schema key。
6. 新增 Wanxiang readiness fail-closed 场景
   `UniverseKeyboardTests/SchemaManagerTests.swift:1201-1249`：九键 preference
   与 `t9` binding 存在、readiness 不匹配时，实际 route 解析为 26 键 Wanxiang，
   卸载 Wanxiang 后选择 Luna、切换 26 键并保留 `t9` binding。这与 ADR 0026 的
   fail-closed 方向一致。

## Verification performed

```text
xcrun swift-format lint --strict --configuration .swift-format \
  Universe Keyboard/Services/SchemaManager+Installation.swift \
  Universe Keyboard/Services/SchemaManager+T9Layout.swift \
  UniverseKeyboardTests/SchemaManagerTests.swift
exit 0

git diff --check
exit 0
```

曾尝试运行：

```text
xcodebuild -project "Universe Keyboard.xcodeproj" \
  -scheme "Universe Keyboard" -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=6.0 \
  SWIFT_STRICT_CONCURRENCY=complete SWIFT_SUPPRESS_WARNINGS=NO \
  SWIFT_TREAT_WARNINGS_AS_ERRORS=YES \
  -derivedDataPath DerivedData-route-integration test \
  -only-testing:UniverseKeyboardTests/SchemaManagerTests
```

本次 reviewer 环境在编译前被 CoreSimulator 服务不可用及本机 Clang
ModuleCache `Operation not permitted` 阻塞；没有产生 App target 的独立通过证据。
因此下面的结论只基于静态路径、测试源码和 format/diff 检查，不能升级为 App
测试通过或运行时证明。

## Decision

结论：**Pass with conditions**。

当前候选没有发现 P0，也没有发现越过 Main App deployment ownership、Extension
session 边界或 archive ownership 的实现。它可以作为继续修订集成证据的候选，但
尚未满足 Assignment 的 integration Exit，也不能进入真机 Product decision。

## Open conditions

### P1 — rollback 必须证明 deployment result，而不只是恢复偏好值

`restoreSchemaAfterFailedUninstall()` 在
`SchemaManager+Installation.swift:251-258` 调用原方案 deployment 后直接丢弃
返回值；随后无论恢复 deployment 成功与否，都记录“已恢复原方案选择”的错误消息。
当前新增的 deployment-failure 测试
`SchemaManagerTests.swift:1251-1287` 使用一个永远返回失败的 stub，最多证明
第二次 deployment 被尝试，不能证明 Luna 失败后原 route 已重新被部署，也不能
区分“偏好值恢复”与“实际 RIME runtime 恢复”。

关闭条件：使用可控的两次调用 stub（Luna 失败、原 route 成功）证明完整
before-state、原 route smoke identity、lease 仍由同一 operation 持有，并单独覆盖
restore deployment 失败。失败结果必须进入 content-free diagnostics；只有部署结果
成功时才可以把恢复标记为完成，失败则保留明确的 recovery-incomplete 状态并停止
卸载。暂存失败路径也要保留同样的 before-state 和恢复结果断言。

### P1 — active-uninstall 阶段需要结构化、可检索的 operation diagnostics

计划要求在 operation UUID 下记录 route-before、route-after、fallback deployment
start/result、staging start/result 和 commit result。当前
`recordActiveUninstallRoutePhase()`（`SchemaManager+Installation.swift:265-280`）
只构造普通 Logger 字符串，没有调用现有的 `deliveryDiagnostics`，也没有稳定的
phase/result payload 或 rollback result。这样无法在主 App 诊断日志中可靠区分
“route mutation 已写入但部署失败”“部署成功但 staging 失败”“rollback deployment
失败”等阶段。

关闭条件：定义并测试一个 content-free、有限枚举字段的 route-operation diagnostic
payload，至少包含 operation UUID、phase、result、effective schema/layout、route
state 和必要的耗时；通过现有 `SchemaDeliveryDiagnosing`/诊断 journal 写入，禁止
用户输入、路径、URL、异常原文和文件内容进入 payload。测试应验证成功、inactive、
fallback failure、staging failure、rollback success/failure 和 commit result 的
序列。

### P2 — 多 key 写入的跨进程/crash 语义需要形成显式证明

`applyRuntimeRouteState()` 的注释已承认 App Group settings 没有 multi-key
transaction；实际实现是多个 `set/remove` 后一次 `synchronize()`。绑定先写的
顺序对“文件尚未 staging 前不暴露被删方案”是有帮助的，但 `synchronize()` 不构成
跨进程原子提交，当前也没有观察 Extension 读取每个 prefix 的测试或 recovery
ledger。进程可能在中间状态退出，剩下的是安全 prefix 还是部分 route state，当前
没有可验证证据。

关闭条件：二选一并写入接线契约：

- 提供真正的单事务/版本化 route record，并让 Extension 只消费完整版本；或
- 保留 bindings → layout → alias 的安全顺序，同时给出逐步 prefix invariant 和
  可执行测试，证明任何中断点都只能得到仍指向现有资源或 Luna 的 route，并且
  下一次主 App 启动会完成/回滚未完成的 route operation。

这项条件不要求 Extension 生产逻辑改动，但要求跨进程可见性和恢复语义不能只靠
注释推断。

### P2 — Main App 测试仍缺少 matched-readiness 与真实 persisted resolver 路径

新增 fail-closed 测试使用缺失 readiness marker；它验证了“不 ready 时九键 preference
回退到 26 键”的一个方向，但没有用匹配的 marker + fingerprint 验证同一个 snapshot
builder 在有效 T9 route 下卸载 Ice，也没有验证 matched T9 route 的 inactive
Wanxiang uninstall。post-state 检查直接用
`RimeRuntimeSelection(... t9ReadinessMatched: false, ...)` 构造 resolver，不能证明
App Group persisted state 经 `RimeRuntimeSelection.resolve(defaults:onDiskFingerprint:)`
在 Extension 侧的实际读取结果。

关闭条件：增加至少一组 matched marker/fingerprint 的 Ice active-nine-key 测试、
一组 unmatched/fail-closed 测试，并从持久化值与 fingerprint 重新 resolve after-state；
断言 effective schema、layout 和 `usesT9InputSemantics`。测试仍可使用临时目录与
测试 settings，不需要真实用户 App Group。

### P2 — inactive layout slot 中残留已卸载 schema 的策略需要明确

reconciler 只在 effective slot 引用 removed schema 时生成 mutation。若当前有效 route
是 ready 的九键 `t9`，而不活跃的 26 键 binding 仍为 Wanxiang，卸载 Wanxiang 会走
`inactiveRoute`，因此 `keyboard_layout_scheme_26=wanxiang` 会被保留。当前九键运行
仍然可用，但下一次切换到 26 键会解析到已删除的方案。

这不应被悄悄改成 peer fallback。关闭条件是明确产品/架构语义并补测试：要么 inactive
uninstall 允许清除受影响的 inactive binding、保持当前 effective route 且不部署
Luna；要么明确由后续 layout reconcile 自动修复，并证明切换布局不会选择已删除 schema。
“unaffected bindings stay unchanged”不能代替对这个受影响 binding 的决策。

## Boundary confirmation

- Main App 仍是 snapshot 构造、route-state 写入、deployment、staging 和 commit 的
  owner。
- Extension/RimeBridge 代码没有被本候选修改；它们只能在之后的独立 target/设备
  验证中证明实际消费 persisted after-state。
- fallback 仍是 Luna-only，没有 peer-prefer 或新资源所有权策略。
- `rime_ice` 的 readiness invalidation 仍在 staging 成功后、commit 前执行；失败的
  deployment/staging 路径不会主动清除 readiness marker。
- 本文不接受 ADR 0026/0034，不关闭真机、Product、merge、TestFlight 或 Release
  gates。

## Required handoff

在交给 Quality review 或请求 Human 决定 CS09-10-02 真机矩阵前，需提供：

1. 上述 P1/P2 条件的修订 diff 和 route before/after/rollback 表；
2. 可证明 restore deployment success/failure 的主 App 测试结果；
3. 结构化、content-free operation diagnostics 的 payload 和测试序列；
4. matched/unmatched T9 readiness 与 persisted `RimeRuntimeSelection` 结果；
5. App + Keyboard/RimeBridge 适用门禁结果，明确列出未执行项；
6. 继续保留不修改 RimeBridge/Extension 生产边界、Luna-only 策略和 archive
   ownership 的非声明。

## Non-claims

- 没有证明当前集成候选的 App target 测试通过；本次 xcodebuild 被环境权限/模拟器
  服务阻塞。
- 没有证明真实 App Group、RIME deployment、Extension session 或 candidate input
  已恢复。
- 没有进行真机 CS09-10-02、PR、merge、TestFlight、Release、Product Gate 或 ADR
  接受。

## Post-remediation Architecture re-review — 2026-09-09

本轮以当前工作树为唯一基线，只读复核了候选新增的三项修正：结构化
`runtime-route` journal payload、rollback deployment result 记录，以及可控的两次
deployment stub。没有修改产品代码、Assignment 或 Active Work；本节只补充本次
增量结论。

### 修正处置

| 修正 | 当前证据 | 结论 |
| --- | --- | --- |
| rollback redeploy result | `SchemaManager+Installation.swift:257-263` 保存 `deployRimeConfig` 返回值，并分别记录 `rollback_deploy_succeeded` / `rollback_deploy_failed`；`SchemaManagerTests.swift:1264,1273-1287` 使用 `[false, true]` 验证 Luna 失败后按原 route 再部署，且完整偏好值未被遗失 | 实现路径已补上；测试仍未断言结构化诊断序列、同一 lease 的持有证据，亦未覆盖 restore deployment 本身失败，因此只能视为部分关闭 |
| structured runtime-route journal | `DiagnosticsJournalRuntime.recordRuntimeRoute()`（`DiagnosticsJournalRuntime.swift:115-135`）和 Main-App adapter 已接线；`DiagnosticEvent` 已能 decode `runtimeRoutePayload`（`DiagnosticEvent.swift:848-850`） | **未关闭**：`DiagnosticEvent.encode(to:)`（`DiagnosticEvent.swift:909-925`）只编码 scheme-delivery 与 RIME-sync payload，遗漏 `runtimeRoutePayload`。因此该 payload 进入 journal 后会在序列化时丢失，重新读取的 route event 只有 generic code/fields。`runtimeRouteCodes` 也未参与对 code/payload 对称性的校验。当前没有 runtime-route round-trip 或 journal ingress 测试 |
| route-state safe write order | `SchemaManager+T9Layout.swift:253-273` 仍为 bindings → layout → alias，部署边界与 lease 未变 | 既有 P2 仍开放；顺序是降低风险的前缀策略，不构成跨进程/崩溃原子性证明 |

### 增量 verdict

结论仍为 **Pass with conditions**。本轮没有发现新的 P0，也没有发现越过 Main App
deployment ownership、Extension session 边界、Luna-only fallback 或 archive
ownership 的实现。rollback 结果处理已明显改善，但结构化诊断的关键持久化缺口使
Assignment 要求的可检索 operation evidence 仍未成立；因此当前候选不能关闭原有
P1，也不能据此进入真机或 Product decision。

### 仍未关闭的条件

#### P1 — runtime-route payload 必须真正 round-trip 到 journal

`recordRuntimeRoute()` 当前只证明了内存中的 `DiagnosticEvent` 被送入异步 ingress。
由于 `encode(to:)` 没有写入 `runtimeRoutePayload`，落盘 JSONL 重新 decode 时
`runtimeRoutePayload` 会是 `nil`；而 decoder 的现有 guard 允许
`.runtimeRoutePhaseChanged` 在没有 payload 时通过。这会把 route-before、fallback
结果、staging、commit 和 rollback 结果重新降级为无法关联的裸 code，正好失去本轮
修正要解决的证据。

关闭条件：

1. 在 `DiagnosticEvent.encode(to:)` 对称编码 `runtimeRoutePayload`，并让 decoder
   对 `.runtimeRoutePhaseChanged` 要求 payload 存在、对其他 code 拒绝错误 payload；
2. 增加 `DiagnosticEvent` runtime-route JSON round-trip 测试，并在
   `DiagnosticsJournalRuntime` ingress/落盘测试中断言 operation UUID、phase、result、
   schema、layout、state 保持不变；
3. 在 Main-App active-uninstall 测试中读取 `RecordingDeliveryDiagnostics` 的现有
   `recordedRuntimeRoutePayloads()`，覆盖成功、fallback failure + rollback success、
   staging failure、inactive 和 commit 序列，并确认失败结果使用 failure level。这样
   才能把“调用了 recorder”提升为“主 App 诊断日志确实有可检索证据”。

#### P1（残余证据）— rollback 成功/失败必须和 lease 与诊断序列一起证明

`[false, true]` stub 已关闭“原代码丢弃部署返回值、无法证明恢复部署被尝试”的直接
缺口，但当前测试只检查两次 smoke schema request 和 settings 最终值。它没有证明
第二次调用仍在同一个 schema-delivery commit lease 内，也没有断言
`route_after_deploy_pending → fallback_deploy_failed → route_restored_deploy_pending
→ rollback_deploy_succeeded` 的结构化序列，更没有单独的 `[false, false]` restore
failure 断言。保留原有 failure-stop 语义的可观察性仍是 integration Exit 的必要条件。

关闭条件：补充上述成功恢复和恢复失败两条测试；测试应断言 lease operation identity
传递到 deployment stub、before-state 的全部 route 字段恢复、失败时保留
`rollback_deploy_failed`/recovery-incomplete 状态，并且不 stage/commit。

### 既有 P2 条件继续有效

- `applyRuntimeRouteState()` 的多 key 写入仍没有跨进程 transaction、prefix invariant
  或启动恢复证明；bindings → layout → alias 只能作为安全顺序假设。
- 当前 Main-App 测试仍以缺失 readiness marker 为主，且 post-state resolver 是直接
  构造，尚未证明 matched T9 marker/fingerprint 与 persisted resolver 的完整路径。
- inactive slot 中残留已卸载 schema 的产品/架构策略仍未明确，也没有证明后续布局切换
  不会解析到已删除方案。
- `runtimeRouteDiagnosticPayload()` 对未知 schema ID 直接返回 `nil`
  （`SchemaManager+Installation.swift:300-305`）；若 catalog 增加新 schema，route
  operation 会静默失去结构化诊断。应在扩展有限枚举时同步更新映射，或为未知值提供
  明确、仍不含内容的可观测结果。

### 本轮验证

```text
xcrun swift-format lint --strict --configuration .swift-format \\
  Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEvent.swift \\
  Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournalRuntime.swift \\
  Universe Keyboard/Services/SchemaDeliveryDiagnostics.swift \\
  Universe Keyboard/Services/SchemaManager+Installation.swift \\
  Universe Keyboard/Services/SchemaManager+T9Layout.swift \\
  UniverseKeyboardTests/SchemaManagerTests.swift
exit 0

git diff --check
exit 0
```

尝试运行 KeyboardCore 的诊断测试时，SwiftPM 在编译前被本机 sandbox
`Operation not permitted`/manifest 环境阻塞；没有产生独立的 package-test 通过证据。
之前记录的 App target xcodebuild 仍受 CoreSimulator 服务和 Clang ModuleCache 权限
阻塞，本轮没有把静态检查升级为 App、Extension 或 RimeBridge 运行时通过。

### Post-remediation handoff

当前最小下一步是先修复并测试 `runtimeRoutePayload` 的编码/解码对称性，再补上
Main-App diagnostics 序列与 rollback lease/failure 证据；在这些条件关闭前，继续保留
P2 的跨进程 route-state、matched T9 persisted resolver 和 inactive binding 策略条件。
Luna-only fallback、Main App deployment owner、Extension/RimeBridge 生产边界和 archive
ownership 本轮继续保持不变。
