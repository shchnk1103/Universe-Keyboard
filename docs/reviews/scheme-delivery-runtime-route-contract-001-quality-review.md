# SCHEME-DELIVERY-RUNTIME-ROUTE-CONTRACT-001 — Independent Quality Review

## Review identity

| Field | Value |
|---|---|
| Reviewer | `quality_review` / 独立 Quality, Performance & Release reviewer |
| Date / timezone | `2026-09-08 Asia/Shanghai` |
| Assignment | [`SCHEME-DELIVERY-RUNTIME-ROUTE-CONTRACT-001`](../assignments/scheme-delivery-runtime-route-contract-001.md) |
| Review baseline | `HEAD bbb0d857daa7d40040632d4a67c8578200f23b59` (`docs: record active uninstall route proposal`) 加两个未提交的 KeyboardCore 文件；本审查不把未提交文件写成已提交实现 |
| Reviewed source | [`RimeRuntimeRouteReconciliation.swift`](../../Packages/KeyboardCore/Sources/KeyboardCore/RimeRuntimeRouteReconciliation.swift) |
| Reviewed tests | [`RimeRuntimeRouteReconciliationTests.swift`](../../Packages/KeyboardCore/Tests/KeyboardCoreTests/RimeRuntimeRouteReconciliationTests.swift) 及现有 [`LayoutBoundRimeRuntimeSelectionTests.swift`](../../Packages/KeyboardCore/Tests/KeyboardCoreTests/LayoutBoundRimeRuntimeSelectionTests.swift) |
| Working tree at review start | 目标 source/test 文件与 Assignment 文件为未跟踪文件；未修改或清理既有未跟踪文件 |
| Independence | 只读审查；未改代码、Assignment、Active Work、产品策略、ADR 或主 App；未 commit、push、PR、merge 或执行外部发布 |
| Evidence grade | 本文件记录的格式与 KeyboardCore 命令为 `Quality-reverified`；没有把历史对话或执行器口述当作当前测试证据 |

## Verdict

**Pass with conditions**。

本次纯 KeyboardCore 路由契约在当前 Luna-only、well-formed descriptor 的覆盖范围内通过：mutation 是纯值、顺序稳定，Ice/Wanxiang、26/9 键、T9 对 Ice 的逻辑依赖、无关偏好、未知未来槽位和非活动卸载均有测试证据。没有记录 P0 或 P1。

该结论不关闭 Assignment，不关闭下列条件，不证明 `SchemaManager` 事务或真实 Extension 路由已修复，也不把 CS09-10-02、Product Gate、merge、TestFlight 或 Release 标记为通过。

## Scope

本审查只评估：

- `RimeRuntimeRouteReconciliation.swift` 的纯 snapshot、fallback descriptor、failure 分类和 mutation 语义；
- `RimeRuntimeRouteReconciliationTests.swift` 与相关现有 Core 路由解析测试；
- 与上述文件直接相关的格式和 KeyboardCore package 测试证据。

方案中的主 App 持久化、部署、暂存/提交/回滚、RimeBridge/Extension 消费、结构化诊断和真机矩阵不在本次实现或审查范围内。

## Evidence matrix

| Required behavior | Evidence | Quality observation |
|---|---|---|
| 26-key Ice active route | `testRemovingActiveIceTwentySixKeyRouteClearsDependentNineKeyBinding` | 26-key binding becomes `luna_pinyin`; dependent 9-key binding is cleared; selected layout remains 26-key |
| 9-key Ice active route | `testRemovingActiveIceNineKeyRouteClearsDependenciesAndSelectsLuna` | `t9` route is treated as depending on `rime_ice`; 9-key binding is cleared and Luna 26-key route is selected |
| Wanxiang active route | `testRemovingActiveWanxiangPreservesUnrelatedNineKeyBinding` | 26-key Wanxiang becomes Luna while unrelated 9-key `t9` binding is preserved |
| Luna-only policy when selected 9-key route becomes invalid | `testRemovingIceReplacesRetainedPeerWhenItBecomesSelectedFallbackRoute` | Retained Wanxiang is not selected as fallback; 26-key Luna binding is produced and invalid 9-key route is cleared |
| Unrelated preferences | Exact mutation array in the Wanxiang test omits the unrelated 9-key binding | Omitted bindings produce no mutation; current test covers preservation for the existing 9-key slot |
| Unknown/future slot | `testUnknownSelectedSlotWithoutFallback` | A selected future descriptor referencing Ice without a fallback returns `.missingFallback` and cannot produce a mutation |
| Inactive uninstall | `testInactiveUninstallRouteStopsWithoutChangingBindings` | Removing Ice while the selected 26-key route is Wanxiang returns `.selectedRouteDoesNotReferenceRemovedSchema` |
| Deterministic mutation order | Exact ordered arrays in the active-route tests | Result follows the ordered snapshot slots; no external state is read or written |

The focused route suite independently executed **6/6** tests. The existing
`LayoutBoundRimeRuntimeSelectionTests` confirms the related runtime resolver
still treats nine-key `t9` as the nine-key route when ready and preserves the
26-key Wanxiang binding independently.

## Passed

The source keeps reconciliation in KeyboardCore and does not access
`UserDefaults`, App Group files, deployment, staging or RIME. It distinguishes
active-route references from inactive uninstall, clears a route's declared
logical dependency, preserves bindings with no reference to the removed schema,
and returns a failure before any mutation when the selected route lacks a
fallback or the selected route does not reference the removed schema.

The current tests assert the complete binding mutation arrays rather than only
the active schema field. This catches the intended Luna transition, the 9-key
dependency clear and the retained unrelated binding in the covered fixtures.

## Open conditions

The following conditions remain open. This review does not fix or close them.

| ID | Severity | Owner handoff | Condition |
|---|---|---|---|
| Q-RTR-P2-01 | P2 | Input Intelligence Maintainer | The fallback validation at [`RimeRuntimeRouteReconciliation.swift:148`](../../Packages/KeyboardCore/Sources/KeyboardCore/RimeRuntimeRouteReconciliation.swift#L148) looks up a slot by `preferenceKey` and checks `supportedSchemaIDs`, but does not verify that the slot's `layoutStyle` matches `RimeRuntimeRouteFallback.layoutStyle`. A malformed future descriptor could write the 26-key binding while returning a 9-key selected layout. Add the identity guard and a negative test before wiring this seam. |
| Q-RTR-P2-02 | P2 | Input Intelligence Maintainer with Architecture review | The proposal lists installed/readiness facts as route inputs, but the snapshot currently carries capabilities only (`supportedSchemaIDs`), not actual installed/readiness state. The default built-in Luna path may rely on an external caller guarantee; a custom or future fallback cannot be considered installed/ready from this type alone. Make the availability proof explicit or constrain the API before adding another fallback. |
| Q-RTR-P2-03 | P2 | Input Intelligence Maintainer | `fallbackSchemaID` is publicly configurable, but the reconciler does not reject `fallbackSchemaID == removedSchemaID`. Such an input can return a successful mutation pointing at the schema whose resources are being removed. Fail closed or remove the unnecessary custom fallback surface, and add a regression test. |
| Q-RTR-P3-01 | P3 / follow-up gate | Main App, RimeBridge and Keyboard Experience owners | No test applies the returned mutation to persisted layout bindings and then invokes the actual `RimeRuntimeSelection` path. The pure result therefore does not prove that Extension startup will select Luna after an uninstall. The required `SchemaManager` transaction and RimeBridge/Extension verification remains open and must be performed in a separately authorized integration slice. |
| Q-RTR-P3-02 | P3 / test completeness | Input Intelligence Maintainer | The current tests cover a future descriptor without a fallback, but do not separately exercise an unsupported fallback, a fallback key/layout mismatch, or duplicate descriptor identities. These negative cases are required to make the future-slot and descriptor-completeness stop conditions executable. |

The open conditions are consistent with the Assignment exit criteria that a
fallback must validate slot/layout/schema identity and that malformed snapshot
outcomes must be distinct. No condition is accepted as resolved by the green
package test run.

## Actual verification evidence

The reviewer independently ran these commands against the review worktree on
`2026-09-08 Asia/Shanghai`:

```bash
xcrun swift-format lint --strict --configuration .swift-format \
  Packages/KeyboardCore/Sources/KeyboardCore/RimeRuntimeRouteReconciliation.swift \
  Packages/KeyboardCore/Tests/KeyboardCoreTests/RimeRuntimeRouteReconciliationTests.swift
```

Result: exit code `0` (`Quality-reverified`).

```bash
swift test --package-path Packages/KeyboardCore
```

Result: exit code `0`; `KeyboardCoreTests.xctest` executed **1082 tests with 0
failures**, and the `All tests` suite also reported **1082 tests with 0
failures** (`Quality-reverified`).

The same command was first attempted in the default sandbox and stopped before
manifest compilation because the environment could not open
`/Users/doubleshy0n/.cache/clang/ModuleCache` (`Operation not permitted`). The
exact command was then rerun with the permitted host execution boundary and
completed successfully. This is an execution-environment limitation, not a
test failure; the evidence does not claim that the default sandbox alone can
run SwiftPM here.

The focused command was also independently run:

```bash
swift test --package-path Packages/KeyboardCore \
  --filter RimeRuntimeRouteReconciliationTests
```

Result: exit code `0`; the new route suite executed **6 tests with 0 failures**
(`Quality-reverified`).

## Not verified / skipped

The following were intentionally not run because they are outside the
authorized pure KeyboardCore review scope:

- `RimeBridgeTests` and the App + Keyboard Xcode targets;
- `SchemaManager` active-uninstall transaction tests and App Group persistence;
- actual deploy, stage/commit/rollback or operation diagnostics;
- simulator keyboard behavior or physical-device CS09-10-02 input evidence;
- RIME artifact, Lua/OpenCC, signing, TestFlight, Release and Product Gate checks.

The green package result must not be expanded into any of those claims.

## Non-authorized actions and documentation impact

This review did not authorize or perform code remediation, Main-App接线,
App Group/UserDefaults writes, deployment, file staging, PR publication,
undraft/merge, TestFlight, App Release, Product Gate closure, or ADR 0026/0034
acceptance. It also did not modify the Assignment, Active Work, plan or
CHANGELOG. The route proposal remains Proposed; any remediation and later
cross-layer work require their separately bounded authorization.

Only this review artifact is being added for the requested handoff.

## Handoff

1. Input Intelligence Maintainer: address Q-RTR-P2-01 through Q-RTR-P2-03 and
   Q-RTR-P3-02 in a separately authorized pure KeyboardCore revision; preserve
   the Luna-only policy and rerun strict format plus the full package suite.
2. Independent Architecture and Quality reviewers: re-review the revised
   descriptor/availability contract and its negative tests. Conditions remain
   open until that review records current evidence.
3. Human Product Owner: decide whether to authorize a distinct Main App
   integration Assignment after the pure contract conditions are resolved.
4. Main App/RimeBridge/Keyboard Experience owners: only after that authorization,
   prove persisted post-reconcile route selection, lease/stage ordering,
   rollback, and the fresh CS09-10-02 device matrix.

This artifact is a Quality review record only. It is not a merge, release,
device, Product or Architecture acceptance receipt.

---

## Post-implementation Quality re-review — 2026-09-09

### Re-review identity and freeze

| Field | Value |
|---|---|
| Reviewer | `quality_review` / 同一独立 Quality, Performance & Release review lane |
| Review date / timezone | `2026-09-09 Asia/Shanghai` |
| Assignment | [`SCHEME-DELIVERY-RUNTIME-ROUTE-CONTRACT-001`](../assignments/scheme-delivery-runtime-route-contract-001.md) |
| Reviewed baseline | `HEAD bbb0d857daa7d40040632d4a67c8578200f23b59` remains unchanged; the two KeyboardCore source/test files are still untracked worktree files under review |
| Worktree boundary | Review开始时 `docs/ACTIVE_WORK.md` 已有修改；source、test、Assignment、Architecture review 和本 Quality review 为未跟踪文件。Quality 没有修改或清理这些既有状态 |
| Review scope | 仅 post-implementation pure KeyboardCore route contract/test snapshot；不包含主 App 接线或发布决策 |
| Evidence grade | 本节格式、focused test 和 full package test 均为 `Quality-reverified` |

### Verdict

**Pass with conditions（pure KeyboardCore slice；无新的 P0/P1 阻断）**。

当前实现已经回应上一轮 Q-RTR 条件的纯 Core 部分：effective route 已进入
snapshot，rollback state 保存了完整的 route 前态，failure input/snapshot/inactive
分类已分离，fallback slot 的 key/layout/schema/availability 校验已存在，且
post-mutation `RimeRuntimeSelection` 有测试。当前没有理由阻止该纯 slice 进入
Architecture/Quality 的正式 handoff。

这不是对 Assignment lifecycle 的自动关闭。跨进程持久化、部署顺序、rollback 实际
写入、RimeBridge/Extension 消费和 CS09-10-02 真机结果仍然是开放的后续门。

### Previous conditions disposition

以下是本次复审对上一轮条件的证据判断；不修改 Assignment 或 Active Work 中的
lifecycle 字段，也不把 review 判断当作 Human Gate closure：

| Previous finding | Current evidence | Re-review disposition |
|---|---|---|
| Q-RTR-P2-01 fallback slot/layout identity | `fallbackSlot.layoutStyle == routeFallback.layoutStyle`、Luna 26-key guard，以及 `testFallbackLayoutMustMatchTargetSlot` | Pure-slice condition addressed; formal lifecycle closure remains with Assignment owners |
| Q-RTR-P2-02 fallback availability | `RimeRuntimeRouteFallback.Availability`、unavailable failure 和 `testUnavailableFallbackFailsClosed` | Pure seam now requires an explicit availability fact; actual installed/deployed proof remains a caller/integration responsibility |
| Q-RTR-P2-03 fallback cannot equal removed route | canonical comparison through `RimeSchemeCapabilityMatrix` and `testFallbackCannotBeTheRemovedSchema` | Addressed in the reviewed pure implementation; no custom peer fallback is admitted because Luna-only policy is enforced |
| Q-RTR-P3-01 post-mutation effective route | complete `before`/`after` state and `testAfterStateResolvesToLunaTwentySixKeyRoute` | Pure Core portion addressed; persisted App Group and Extension startup proof remains open |
| Q-RTR-P3-02 malformed/future descriptor coverage | empty descriptor, duplicate key/layout, unsupported fallback, layout mismatch and unavailable fallback tests | Addressed for the exercised descriptor cases; future layout integration remains unverified |

### Boundary and failure-semantics review

The current focused suite executes **19 tests with 0 failures**. It covers:

- Ice active on both 26-key and effective 9-key routes, including the declared
  `t9 → rime_ice` dependency;
- Wanxiang active on 26-key and the readiness-fail-closed case where persisted
  layout is nine-key but the effective route is 26-key;
- inactive Ice removal while Wanxiang is the effective route;
- Luna-only fallback, unrelated binding retention, complete before-state capture,
  and post-mutation Luna resolution;
- empty input, unsupported fallback, unavailable fallback, empty descriptor,
  duplicate preference key, duplicate layout descriptor, fallback key/layout
  mismatch, unsupported target schema and missing future-slot fallback.

The failure taxonomy is now fail-closed and distinguishable: empty/unsupported
request inputs use `invalidInput`, malformed route facts use `invalidSnapshot`, and
a valid snapshot whose effective route does not reference the removed resource uses
`inactiveRoute`. No failure path returns a partial mutation. Successful output
contains both complete `before` and `after` route state plus the changed binding
list, so a later Main-App transaction has a pure rollback description.

One non-blocking contract boundary remains explicit: `RimeRuntimeEffectiveRoute`
is supplied by the caller. The reconciler validates its schema, layout, supported
slot and binding identity, but it does not itself invoke `RimeRuntimeSelection` or
validate every possible consistency relation between `state` and
`usesT9InputSemantics`. The Main-App snapshot builder must therefore use the same
resolver facts and preserve the actual installed/readiness evidence when this seam
is integrated. This is an integration handoff condition, not a reason to fail the
current pure slice.

### Independently rerun verification

The reviewer ran these exact commands against the current worktree on
`2026-09-09 Asia/Shanghai`:

```bash
xcrun swift-format lint --strict --configuration .swift-format \
  Packages/KeyboardCore/Sources/KeyboardCore/RimeRuntimeRouteReconciliation.swift \
  Packages/KeyboardCore/Tests/KeyboardCoreTests/RimeRuntimeRouteReconciliationTests.swift
```

Result: exit code `0` (`Quality-reverified`).

```bash
swift test --package-path Packages/KeyboardCore \
  --filter RimeRuntimeRouteReconciliationTests
```

Result: exit code `0`; focused route suite executed **19 tests with 0 failures**
(`Quality-reverified`).

```bash
swift test --package-path Packages/KeyboardCore
```

Result: exit code `0`; `KeyboardCoreTests.xctest` and `All tests` each reported
**1095 tests with 0 failures** (`Quality-reverified`). The command initially waited
for the package build lock held by the immediately preceding focused run and then
completed normally. SwiftPM was executed through the permitted host boundary because
the default sandbox cannot open the local Clang ModuleCache; this is an environment
constraint and not a test failure.

### Not verified in this re-review

The following remain outside the Assignment boundary and were not run:

- `SchemaManager` transaction or App Group/UserDefaults persistence tests;
- actual Luna deployment, stage/commit/rollback and operation diagnostics;
- RimeBridge or App + Keyboard Xcode target tests;
- simulator/physical-device runtime input, CS09-10-02 candidate evidence or
  content-free device trace;
- commit, push, PR, merge, TestFlight, Release, Product Gate or ADR acceptance.

The package green result therefore cannot be promoted to an integration or device
claim. The worktree also remains an uncommitted candidate; no publication action was
performed.

### Post-implementation handoff

1. Input Intelligence Maintainer: preserve the current pure contract and provide
   the Main-App snapshot builder with effective-route, availability and canonical
   identity facts from the existing resolver/capability sources.
2. Architecture and Quality owners: record any formal closure only after the frozen
   candidate diff and this post-implementation evidence are accepted under the
   Assignment; this review itself does not alter lifecycle fields.
3. Human Product Owner: authorize a separate Main-App integration Assignment only
   after the pure slice handoff is accepted.
4. Main App/RimeBridge/Keyboard Experience owners: prove atomic persisted route
   application, lease-scoped Luna deployment, full rollback and the fresh bilateral
   CS09-10-02 device matrix in that later scope.

This post-implementation section is an independent Quality re-review record. It
does not close the Assignment, authorize integration, or grant merge/release/device
approval.
