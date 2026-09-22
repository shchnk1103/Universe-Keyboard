# Architecture review: TYPO-CORRECTION-002 runtime-integration implementation

## Verdict

**Conditional Accept** — 仅限本 worktree 当前 uncommitted 快照，且不得把
Executor evidence、测试叙述或 Quality/Product Gate 写成已通过。

本实现在 controller 侧建立了单一 MainActor recall 生命周期、查询返回后的
`.default` yield、以及一条带 operation token 的条件 Core apply。它还没有把
设计 F-01 的 invalidate-first 枚举、F-02 的三路线 adapter 证明、以及 F-03
的「唯一 writer / budget-stop display no-op」做成架构上闭合的合同。下一步只
能是同一 exact snapshot 的独立 Quality review；不得据此授权 publication、
真实 RIME、QA-001 或 parent Close。

## Review identity

| Field | Value |
|---|---|
| Reviewer | Independent Architecture & Knowledge Steward；不是实现 Executor |
| Assignment | [`TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-001`](../assignments/typo-correction-002-runtime-integration-implementation-001.md) |
| Authorization | [`AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-ARCHITECTURE-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-ARCHITECTURE-001.md)，本审查消费 |
| Design contract | [`runtime integration design`](../plans/typo-correction-002-runtime-integration-design-2026-09-21.md) |
| Design SHA-256 | `b91e11cf327f9ad3e5974ff0e5b4a53fe755920356927efffed12cfe9c28a848`（独立重算一致） |
| Design re-review | [`rereview`](typo-correction-002-runtime-integration-design-architecture-rereview-2026-09-21.md) |
| Implementation worktree | `/private/tmp/universe-keyboard-typo-correction-002-runtime-integration-implementation-001` |
| Review time | `2026-09-21T22:26:37+08:00 Asia/Shanghai` |
| Method | 只读源码与身份重算。未跑 test/build，未执行 RIME/设备，未 commit/push |

Executor [`evidence`](../evidence/typo-correction-002-runtime-integration-implementation-001.md)
只作路径索引。下列结论均指向当前 worktree 源码行为。

## Independent identity recomputation

| Item | AUTH 绑定值 | 本审查独立重算 | 结果 |
|---|---|---|---|
| HEAD | `4d1050f4b677494e06448cb40a83ef2da46d7b27` | 同左 | 一致 |
| Tree | `5f864a6f6f139810ed59c7e00ab6c33caad7e500` | 同左 | 一致 |
| Tracked `git diff HEAD` SHA-256 | `d1366181e0436242211aa496934792e90a6ab1b0454608f0e1c3dd5a17ef4c1b` | 同左（38182 bytes） | 一致 |
| 全部变更文件内容 SHA-256（含 untracked） | `3cf0d23cda23a5f0a6a87264333cb1b31d91fad3b36c9c8784c9dbaea51e660d` | porcelain `-uall` 路径排序后拼接文件字节：`4b701835f070e2c337fd2d3b76b67813e7e5722bdaa7db1b82faa7e00d2c891e` | **未复现 AUTH 配方值** |
| 原纯 Core checkpoint `git diff HEAD` | `8bb105c5381feb43fc41ec168fd239fd7c864cc0efa739cae3976beb685ebbab` | 原 worktree 仍为该值；仍仅 3 个 tracked 改动文件 | 一致、未被改 |

当前 porcelain 变更集（15 个路径，按字典序）：

- tracked：`KeyboardViewController+Bootstrap.swift`、`KeyboardViewController+TypoCorrection.swift`、`KeyboardViewController.swift`、`ContextualTypoCorrection.swift`、`KeyboardController+TypoCorrection.swift`、`TypoCorrectionRecallPreflight.swift`、`TypoCorrectionRecallPreflightTests.swift`
- untracked：`TypoCorrectionRecallCoordinator.swift`、`TypoCorrectionRecallRuntimeTests.swift`、`TypoCorrectionRecallMaterial.swift`、`TypoCorrectionSidecarOwner.swift`、`TypoCorrectionRuntimeIntegrationTests.swift`、`TypoCorrectionSidecarOwnerAdapters.swift`、`TypoCorrectionSidecarOwnerAdapterTests.swift`、`docs/evidence/typo-correction-002-runtime-integration-implementation-001.md`

**身份处置：** HEAD / tree / tracked diff / 原 checkpoint 足以把本审查钉在该
worktree 的 tracked 实现上。AUTH 的「全部变更文件内容」哈希未能用路径排序拼接
复现（含 `git add -A` 后的 cached diff、untracked-only、swift-only 子集均不是
`3cf0d23c…`）。本审查把当前 15 文件拼接值 `4b701835…` 记为独立观测，并把 AUTH
值标为 **identity-recipe residual**，不把它当成第二份已核验快照。后续 Quality
必须同时重算两套哈希；任一漂移即重审。

## F-01 — yielded one-query turns and invalidate-first cancellation

**分项：Pass with conditions。**

### 查询调度

`TypoCorrectionRecallCoordinator.performQuery` 在同步
`correctionCandidates` 返回后只调用 `scheduleYieldedTurn()`，使用
`RunLoop.main.perform(inModes: [.default])`，不在返回栈上再取下一次 query。
`TypoCorrectionRecallDriver.finishQuery` 把 `awaitingYield = true`；
`nextEvent` 在 yield 未确认时只返回 `.waitForYield`。这满足「一次同步 sidecar
query 占用一个 scheduler turn」。`.default` 延迟时 driver 停在 yield，不回退成
同步循环，fail-safe 成立。

Coverage assessment 与随后的第一次 stage-two query 可以共享同一次 yielded
turn（`completeCoverageAssessment` → `nextEvent` → `.query` → `performQuery`）。
这不是 query 返回栈上的循环，但仍是「一 turn 内 assessment + 一次 query」。

### Invalidate-first 入口枚举

设计要求 composition / page / mode / visibility / engine-rebind /
correction-disable **先** `recallEpoch++` 并取消 token。实现把 epoch 递增集中在
`TypoCorrectionRecallCoordinator.invalidateTypoCorrectionRecall()`。实际挂钩：

| 入口 | 源码位置 | invalidate-first？ |
|---|---|---|
| Composition 多数提交/清空/T9 分支 | `clearTypoCorrectionSuggestions()` → owner `recallInvalidation` | **间接成立**，但发生在既有 mutation 之后；同栈返回前仍先于下一次 yield |
| 字母热路径普通纠错刷新 | `KeyboardController+PartialCommit.swift` 非 commit 分支调用 `refreshTypoCorrectionSuggestions()` | **否**：不 bump epoch，且仍在按键栈上同步循环 sidecar query |
| Keyboard page | `handleTogglePage()` | **否**：改 `state.currentPage` 且不 `clear`。依赖 fence 的 `page` 字段在下一 turn 失败 |
| Input mode | `handleToggleInputMode()` | **部分**：abandon / `finishActiveCompositionAsDisplayText` 会 `clear`；空 composition 切模式不 bump |
| Visibility teardown | `viewWillDisappear` 在 `suspendKeyboardRuntime` 之前 invalidate | **是** |
| Default engine install | `activateRimeRuntimeAfterKeyboardPresentation` 在构造 `RimeEngineImpl` 前 invalidate | **是** |
| Dual-gate rebind | `installResponsiveDualGatePreflightIfArmed` 在改 gate / bootstrap 前 invalidate | **是** |
| Canary / P3D1 安装 | `KeyboardViewController+Bootstrap.swift` 约 560、996 行 | **否**：只 `installTypoCorrectionSidecarOwner`，无先行 invalidate |
| Correction-disable | 无独立关闭挂钩 | **缺口**：实验 edits 来自 settings，不 bump epoch；实际停用依赖 page/mode/eligibility |

Fence 本身包含 `normalizedComposition` / `page` / `inputMode` / `recallEpoch` /
可选 `routeLocalOwnerEpoch`。因此 page 切换即使未 bump epoch，下一 pre-query /
post-return 比较仍会丢弃。这是 fail-closed 观察，**不是** 设计要求的
invalidate-first。字母热路径的 `refreshTypoCorrectionSuggestions` 仍是紧循环
query + 写 `state.typoCorrection`，与 coordinator 并行存在。

Debounce 入口已从
`KeyboardViewController+TypoCorrection.scheduleContextualTypoCorrectionRefresh`
迁到 coordinator；`syncUI` 仍只在 candidate presentation 刷新后调度它。

## F-02 — TypoCorrectionSidecarOwner, epoch, no bypass

**分项：Pass with conditions。**

存在单一 `InstalledTypoCorrectionSidecarOwner`，包装已传入的
`TypoCorrectionCandidateQuerying`，`correctionCandidates` 只转发。默认
`TypoCorrectionSidecarOwnerAdapters.wrapping` 与无 coordinator 时的
`routeLocalOwnerEpochProvider` 返回 `nil`，没有为 `RimeEngineImpl` 伪造 native
epoch。`recallEpoch` 与 route-local 是不同字段；route-local 只能让
`currentFence == token` 失败。

新代码没有 `Task.detached`、没有第二 RIME session、没有把 sidecar 指向 raw
engine cast。`as? TypoCorrectionSidecarOwner` 是已安装 query 的协议转换，用于
invalidation 与读 epoch。既有 `underlyingRimeEngine as? RimeEngineImpl` 仍在
Feedback / view 诊断路径，不在本 slice 的 correction query 入口。

**未闭合的路线证明：**

1. Default 安装把 `RimeEngineImpl` 本身包进 adapter，然后
   `rebuildResponsiveRimeCoordinatorIfNeeded()` **不** 更新
   `typoCorrectionCandidateQuery`。若随后装上 `ResponsiveRimeEngineBridge`，
   sidecar 仍持有底层 `RimeEngineImpl`，可绕过 serial owner facade。这是原
   bootstrap 结构的延续，本 slice 未修。
2. Dual-gate / canary / P3D1 仍安装
   `CandidateProviderTypoCorrectionQuery`，不是 thread-affine
   `correctionCandidates` facade。注释写明避免第二 live session，因此
   thread-affine 路线的 sidecar **不是** 该 owner 的 query facade。
3. `RimeEngineImpl.makeTypoCorrectionSidecarOwner()` 未被 Bootstrap 调用。
4. 自动化合同只证明 default wrap + `nil` epoch
   （`TypoCorrectionSidecarOwnerAdapterTests`、
   `testInstalledSidecarOwnerForwardsToTheFacadeAndNeverInventDefaultEpoch`）。
   MainActor-responsive / thread-affine no-bypass **没有** 架构可见测试。

## F-03 — material identity, one conditional apply, commit boundary

**分项：Pass with conditions。**

Stage one / two 材料带同一 `TypoCorrectionRecallFenceSnapshot`（epoch、
revision、ordinal、normalized composition）。Driver 不写
`state.typoCorrection`。`applyTypoCorrectionRecallMaterial` 做
`material.joined`（按 `correctedInput` 去重）后调用一次
`applyRankedTypoCorrection`（normal-top suppression + ranking）。Coordinator
在 apply 前与 `refreshCandidateBar` 前再次 fence。Sidecar 结果只进入
`TypoCorrectionState`；coordinator 不调用 `insertText` / `setMarkedText` /
pasteboard / live RIME select。用户选择仍走既有
`handleInsertCorrectionCandidate`。

条件：

1. `refreshTypoCorrectionSuggestions` 仍是第二条 Core 写路径，并在热路径上
   同步循环 query。Debounce 上下文路径不再调用它，但字母输入、部分
   PartialCommit / TextEditing / RimeRecovery 仍调用。设计「recall 路径唯一
   writer」只在 coordinator → `applyTypoCorrectionRecallMaterial` 上成立，
   不是整个 `TypoCorrectionState` 合同。
2. Stale composition：apply 比较 `material.originalInput`，测试
   `testConditionalApplyWritesOnceAndIsDisplayNoOpWhenCompositionChanged`
   覆盖了这一点。Empty / budget-stop：driver 仍 `finishApply` 并可能把
   ranked 空结果写成 `nil` 或刷新候选栏；**没有** 把 budget-stop 做成
   display no-op 的结构或测试。
3. Stage one 在最终 apply 前可对 12/8 + 单编辑假设做多次 yielded query，
   中间不写 state。这与「材料阶段不写」一致，但拉长了 debounce 后可见延迟
   （不作性能结论）。

## Coverage-deficit predicate, 8/8/3/4, 12/8, 60/64

**分项：Pass with conditions。**

`typoCorrectionRecallHasCoverageDeficit` 实现 Product 钉死的三条结构条件：
stage one accepted display count == 0、selector 仍有未计入 group、剩余
started-query-attempt > 0。字母 / 中文 / 最短长度在 coordinator
`isEligible`（page letters、mode chinese、去空白长度 ≥ 8）与
`isEligibleForTypoCorrectionRefresh` 中另行执行；「同一 operation 仍 current」
由 fence 执行。谓词函数本身不是五款合取，但运行时拼在一起。

`TypoCorrectionRecallRuntimeBudget` 钉死 8/8/3/4。Stage two ledger 使用该
query-attempt cap。Stage one **不** 计入该 8 次 attempt，只受 accepted-display
4 与假设队列约束。这与「不改变生产 12/8 第一阶段」一致，但「整次 operation
的 started-query-attempt = 8」并未套在 stage one 上。

生产第一阶段仍是 `ContextualTypoCorrectionHypothesisEngine` 默认
`productionV2` 12/8。`ContextualTypoCorrectionSearchPlan` 默认 60/64 只作为
stage-two selector 输入，不是 always-on 第一阶段 query 路径。

## Diagnostics / privacy

**分项：Pass（F-04 仍为 tech_debt）。**

本 slice 未新增 operation receipt，也未把 DEBUG decision trace 改成例行
telemetry。`applyRankedTypoCorrection` 在 `#if DEBUG` 下仍走既有
`TypoCorrectionDecisionTrace`（内容向、预存调试用途）。Coordinator 不把
composition/candidate 原文写入 journal。Fence 在内存中持有
`normalizedComposition`，符合设计「只为相等与 query，不记录」。

## Tests as architecture-visible contract

只读测试源码，未重跑。

| 合同 | 测试 | 缺口 |
|---|---|---|
| Coverage-deficit 8/8/3/4 语义 | `testCoverageDeficitRequiresEmptyStageOneAndRemainingBudget`；KeyboardTests 钉死 budget 常量 | 未测 letter/Chinese/min-length 与 predicate 合取 |
| Yield，不在返回栈上下一次 query | `testDriverYieldsAfterEachQueryAndDoesNotStartTheNextOnTheReturnStack` | 测的是 driver，不是 `RunLoop.main.perform(inModes: [.default])` |
| Post-return stale | `testStaleFenceAfterReturnDiscardsAndDoesNotApply` | 无 UIKit 级 composition/page/mode/visibility/rebind 入口测试 |
| Stage-two abstain | `testStageTwoAbstainsWhenStageOneAlreadyHasAcceptedDisplayResults` | 有 |
| Conditional apply / composition no-op | `testConditionalApplyWritesOnceAndIsDisplayNoOpWhenCompositionChanged` | empty / budget-stop no-op 未测 |
| Adapter default no epoch | Core + RimeBridge 各一条 | MainActor-responsive / thread-affine 未测 |
| Clear → invalidate | `testClearingCorrectionInvalidatesThroughTheInstalledOwner` | 依赖 query 已是 `TypoCorrectionSidecarOwner`；page toggle 不走 clear |
| KeyboardTests | 同步 root group，新文件会被编译 | 仅常量断言，不构成 F-01 入口合同 |

`refreshContextualTypoCorrectionSuggestions` 仍保留并仍做紧循环；既有
`TypoCorrectionTests` 仍走该入口。这是回归面，不是新合同的证明。

## Finding and residual disposition

| ID | Disposition |
|---|---|
| F-01 | **Pass with conditions.** Yield + pre/post fence + `.default` fail-safe 成立。Invalidate-first 未覆盖 `handleTogglePage`、字母热路径 refresh、canary/P3D1。 |
| F-02 | **Pass with conditions.** 单一 wrapper、default `nil` epoch、无新 detached/第二 session。三路线 no-bypass 未证明；dual-gate 仍是 CandidateProvider。 |
| F-03 | **Pass with conditions.** Recall 路径一次 join/rank/apply，无第二 commit。`refreshTypoCorrectionSuggestions` 仍是第二 writer；empty/budget-stop 非 display no-op。 |
| 8/8/3/4 与 coverage-deficit | 已钉死并部分测试；stage one 不受 8-attempt 约束 |
| 生产 12/8 | 仍在；60/64 仅 selector 输入 |
| F-04 / diagnostics | 保持 `tech_debt`；本 slice 未扩 scope |
| AUTH 全量内容哈希 | **identity-recipe residual**：独立拼接 `4b701835…` ≠ 绑定 `3cf0d23c…` |
| 原纯 Core checkpoint | 未改 |
| Real RIME / QA-001 / INT-003 / 180 ms | 仍 `UNKNOWN`，本审查不碰 |

## ADR judgment

**ADR 0004 / ADR 0016 无需因本 slice 修订。** Coordinator 仍走已安装同步
facade；未授权 detached 或第二 session。ADR 0016 的 60/64 计划未被接成
always-on 第一阶段。若后续把 sidecar 接到 thread-affine owner 或让
`RimeEngineImpl` 在 responsive bridge 下直接 query，需要新的 RIME-architecture
决定。

Marked-text：本 slice 未引入第二 `setMarkedText` / `insertText` 路径；候选栏
刷新仍在 fence 之后调用既有 `refreshCandidateBar()`。

## Non-claims

本审查不声明或批准：

- Quality / Product / Release Gate，test 或 build 结果（未重跑）
- 真实 RIME query/deploy、Simulator/device capture、新 Run ID
- QA-001、INT-003、paired performance 或 `180 ms`
- commit、push、PR、merge、TestFlight、Release、parent 或本 Assignment Close
- 三路线 runtime 已无 bypass、page/mode 已全部 invalidate-first、budget-stop
  已是 display no-op
- AUTH `3cf0d23c…` 与当前 15 文件字节拼接相等
