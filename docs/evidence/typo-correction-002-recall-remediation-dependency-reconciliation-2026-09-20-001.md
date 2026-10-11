# TYPO-CORRECTION-002 Recall Remediation Dependency Reconciliation 001

- Authorization：[`AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-DEPENDENCY-RECONCILIATION-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-DEPENDENCY-RECONCILIATION-001.md)
- Trigger Run：[`TC2-RECALL-QUALITY-20260920-001`](typo-correction-002-recall-remediation-quality-run-2026-09-20-001.md)
- Staging base：`origin/main=162b09fd58ba60538a944026b1902efa405c75aa`
- Parent checkpoint reference：`84978748d89d329a7d2c6e89400c1ff556cfd9b5`
- Parent checkpoint parent：`9eb83158e49218c1e8f75dbe7dd9e0390db81409`
- Canonical source manifest：`709370f83f819a885f95b6224a763d59712eeac93f164939c03ae31627a9f207`

## 结论

Quality Run 001 的 App + Keyboard 编译阻塞是一个真实的 provenance/scope 闭包问题：`UniverseKeyboardTests/RimeSettingsStoreTests.swift` 的当前 diff 使用了 parent checkpoint 中新增的 `RimeDeploymentResult.librimeVersion` contract，但 staging base `origin/main` 没有这项 production API。不能用旧 parent worktree 的“可编译”状态替代 clean base 证据，也不能只把旧 parent commit 的一部分偷偷带入 recall publication。

## 证据链

1. `origin/main` 的 `Packages/RimeBridge/Sources/RimeBridge/RimeDeploymentService.swift:33-52` 定义的 `RimeDeploymentResult` initializer 接受 `succeeded`、`diagnosticMessage`、`runtimeSmokePassed`、`luaRuntimeSmokePassed`，没有 `librimeVersion`。
2. Parent checkpoint commit `84978748d89d329a7d2c6e89400c1ff556cfd9b5` 相对其 parent `9eb8315` 增加了 `librimeVersion: String?` 字段和 initializer 参数，并把真实部署版本传递到 result。
3. 当前 manifest 中的 `UniverseKeyboardTests/RimeSettingsStoreTests.swift` diff 同时传入 `librimeVersion` 和 `runtimeSmokePassed`，因此在 clean base 编译器于 line 1362 报 `extra argument 'librimeVersion' in call`。
4. Recall-owned 的三个 KeyboardCore 文件只引用 `ContextualTypoCorrection` / `TypoCorrectionRecallPreflight` 类型，不引用 `RimeDeploymentResult`、`RimeDeploymentServicing` 或 `librimeVersion`；`KeyboardCore` `1139/0` 通过与此一致。
5. 旧 parent checkpoint 的 production contract 改动来自一个包含大量 parent sidecar、诊断和治理文件的混合 commit；它不是当前 clean `origin/main` 的已发布基线，不能自动作为 recall slice 的隐式依赖。

## 文件分类

| 文件/范围 | 分类 | 处置 |
|---|---|---|
| `Packages/KeyboardCore/Sources/KeyboardCore/ContextualTypoCorrection.swift` | recall-owned | 保留在 recall manifest |
| `Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionRecallPreflight.swift` | recall-owned | 保留在 recall manifest |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/TypoCorrectionRecallPreflightTests.swift` | recall-owned | 保留在 recall manifest |
| `UniverseKeyboardTests/RimeSettingsStoreTests.swift` 的 fixture diff | test-fixture candidate | 需要与 clean base contract 对齐；当前不能 publication |
| `Packages/RimeBridge/Sources/RimeBridge/RimeDeploymentService.swift` 的 `librimeVersion` contract | parent-contract-owned | 不应在本次 recall slice 中隐式引入；若纳入须单独扩展范围和审查 |
| 整个 `8497874` parent checkpoint | parent-lane / mixed | 不得作为临时 base 或批量复制源 |

## 最小闭包与决策前沿

### 方案 A：保持 recall 为纯 KeyboardCore（推荐）

在新的 code-fix Authorization 下，将 `RimeSettingsStoreTests.swift` fixture 改为只使用 clean base 已有的 `runtimeSmokePassed` contract，移除对 `librimeVersion` 的 test-only 依赖；随后重新生成 test file hash、manifest 和新的 Quality Run ID，重跑 App Debug 与 Release，并按门禁要求复核全部受影响 target。

这保持本 Assignment 的 pure-Core 边界，不引入 parent sidecar production contract。它不是本只读 Authorization 的实施结果。

### 方案 B：纳入 parent production contract

把 `RimeDeploymentService.swift` 及其 provenance 变更作为 parent-lane scope 正式纳入，并重新定义 base、manifest、Architecture/Quality/Product 边界。不能只复制一个文件后声称 parent contract 已完整发布；至少需要证明该 contract 的所有生产依赖和 parent 版本身份。

### 方案 C：以旧 parent checkpoint 作为新 base

不推荐。`8497874` 同时携带大量 sidecar、诊断、部署和 docs 变化，无法作为 recall-only publication base，且会重新打开已对账的混合树身份问题。

## Non-claims

- 本对账没有修改 Swift/测试/manifest，没有重跑，没有 commit/push/PR/merge。
- 本对账不关闭 Quality Run 001 的 App compile blocker，也不授予 publication。
- 方案 A 是与现有 pure-Core Product bounded decision 一致的建议，不是未经 Product 接受的最终 scope 变更。
