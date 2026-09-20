# Architecture Review: TYPO-CORRECTION-002 recall remediation publication preflight manifest 002

## Verdict

**Pass with conditions — no blocking Architecture finding for the next independent Quality review.**

本 review 独立绑定 `TC2-RECALL-PREFLIGHT-20260920-002`、HEAD
`d0df9a6342d8209b5aa7f9826541d0b430b9da04`、HEAD tree
`27ae44bec1b157e391ef1e0b859db3a068e21ba8`、Package.swift SHA-256
`9ebf33313b560b83634a074dd675211aee9cec13b1d879e9cd4f35fbb94aa764`，以及 canonical
source manifest `709370f83f819a885f95b6224a763d59712eeac93f164939c03ae31627a9f207`。
前一轮 `bcbabcb7…` 不可复算的 Architecture finding 已由 docs-only reconciliation
以明确字节序列修正；本轮没有发现阻止下一步独立 Quality review 的架构缺陷。

该 Verdict 不是 Quality、Product 或 Release 结论，不授权 publication、commit、push、PR、
merge、TestFlight、Release、runtime 接线或设备验收。

## Evidence / Boundary

### Exact identity and manifest

| 项目 | 独立观察 | 结论 |
|---|---|---|
| Worktree / branch | `/private/tmp/universe-keyboard-typo-correction-002-recall-preflight-001` / `codex/typo-correction-002-recall-preflight-001` | 与本轮 Authorization 一致 |
| HEAD / tree | `d0df9a6342d8209b5aa7f9826541d0b430b9da04` / `27ae44bec1b157e391ef1e0b859db3a068e21ba8` | 一致 |
| Package.swift | `9ebf33313b560b83634a074dd675211aee9cec13b1d879e9cd4f35fbb94aa764` | 一致 |
| canonical manifest | 652 bytes、5 行；ASCII 是 UTF-8 子集；行按 path 排序 | 通过 |
| 行/字节边界 | 每行 LF、无 CR、无空行、无 code fence、最后一个字节为 `0a` | 通过 |
| canonical manifest SHA-256 | `709370f83f819a885f95b6224a763d59712eeac93f164939c03ae31627a9f207` | 通过 |

五个 manifest entry 的当前文件 SHA-256 逐一重算并全部匹配：

| Path | SHA-256 |
|---|---|
| `Packages/KeyboardCore/Package.swift` | `9ebf33313b560b83634a074dd675211aee9cec13b1d879e9cd4f35fbb94aa764` |
| `Packages/KeyboardCore/Sources/KeyboardCore/ContextualTypoCorrection.swift` | `9fb3fdc9c4cb809cf08b098bd882226e74a1a74eef23a043bba261d017216b57` |
| `Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionRecallPreflight.swift` | `e05488596a044e199b30fb3f262f72877ff31b172ba98638091b44ce7b030c9d` |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/TypoCorrectionRecallPreflightTests.swift` | `9147004b425c19f2326292358f13e6db90c4d3969f2e4fb758841119991f3fd6` |
| `UniverseKeyboardTests/RimeSettingsStoreTests.swift` | `788d6fd0fc814a034a61873cda6ba67432e21042f7953c8849212f350e8066f9` |

Authorization、Assignment、原始 preflight evidence、reconciliation evidence 与 vendor
materialization evidence 对 HEAD/tree/Package/vendor archive/vendor tree/simulator 的记录
相互一致：

- vendor archive: `d17aab9a8b08b5901ab583c143b0a8a03994e36fe092309fd14c5bee31399dd9`；
- materialized vendor tree: `d446b0a4cdd40d42f53359ba8a7677d625ac8461c60ecfe92f90ca73e8df14fd`；
- simulator: `iPhone 17 Pro / iOS 26.0 / 8C2943AC-AC97-432F-ACEE-BE3DA2B9ACB2`。

这些 vendor/simulator 值是跨记录 provenance 一致性观察；本 review 未运行 vendor verification、
build、test、install、deploy 或新的 Simulator/device Run。

### Historical digest boundary

旧 `bcbabcb7c7870b90691422ab7fd65f028f348921e64fc39ebaf5db94038d2e3e` 仍保留在旧
Authorization、原始 preflight evidence 和 Assignment 的历史 snapshot 字段；当前 Assignment
Status 与 reconciliation evidence 明确将其标记为 `superseded` / `superseded_not_reproducible`。
新的 `709370…` 只出现在 reconciliation 后的 canonical binding 中，未静默改写旧 receipt。

### Architecture boundary

静态阅读确认：

- `ContextualTypoCorrectionSearchBudget.productionV2` 保持纯 Core 生产搜索预算 `12/8`；
  `progressiveRecallPreflight` 为独立的 `60/64` 预检预算。预检 plan 默认
  `substitutionOnly`，扩大 edit policy 需要显式传入。
- `ContextualTypoCorrectionSearchPlan` 与 `TypoCorrectionRecallPreflightLedger` 只在
  KeyboardCore 内生成/管理内存状态；未发现其被生产 controller、Keyboard Extension 或
  RimeBridge 接线，也未发现 RIME、持久化、网络或 UI 依赖进入该纯 Core 预检路径。
- ledger 保持 `nGenerated`、`nQueryAttempts`、`nResolvedGroups`、`nCandidatesReturned`
  分离，并保留 batch/query cap、resolved-group 去重、取消 fence、composition revision 与
  session epoch stale-result fence；打开 batch、in-flight query、取消、stale operation 或
  contract violation 均不能 publish。
- `UniverseKeyboardTests/RimeSettingsStoreTests.swift` 的 `StoreDeploymentService` 是
  test-only actor fixture：成功返回非空 fixture provenance 与 `runtimeSmokePassed=true`，
  failed/cancelled path 保留 `nil`；没有修改生产 deployment/RIME/entitlement 代码，生产
  缺失 provenance 的 fail-closed guard 仍存在。

### Count and warning boundary

原始 preflight receipt 的 accounting 被正确限定：App + Keyboard 的 authoritative total 是
`388 total / 379 passed / 9 skipped / 0 failed`；`389 discovered` 只保留为外层 wrapper
observation；`107` 条 `CODE_SIGNING_ALLOWED=NO` entitlement warning 是测试环境 residual，
不是 checked-in entitlement 变更或 runtime 成功证据。

## Findings

### A-001 — canonical manifest reconciliation is independently reproducible

**状态：通过；不阻止 Quality。**

当前五行 UTF-8/LF manifest 的字节、顺序、末尾 LF 和 SHA-256 均可独立复算，五个 entry
hash 也与当前文件一致。因此前一轮针对 `bcbabcb7…` 的 provenance blocker 已被精确修正，
但旧 Blocked review 仍是不可变历史记录，不能被倒写为当时已通过。

### A-002 — opaque GroupID mapping and async scheduler remain outside this slice

**状态：已知 residual；不阻止本轮 Architecture → Quality handoff。**

当前 ledger 只验证未来 scheduler 所需的稳定 `GroupID`、计数和 stale/cancellation fences，
不证明 corrected-input 到 canonical `GroupID` 的实际映射、异步 scheduler 接受、真实 RIME
候选或 runtime wiring。这是 Assignment 已声明的 P1/未来 runtime boundary，必须作为 Quality
review 的 non-claim 保留，不能被 pure-Core 结果扩大解释。

### A-003 — test-only provenance fixture preserves production fail-closed semantics

**状态：通过；不阻止 Quality。**

fixture 仅补齐成功测试所需的非空 provenance 字段；失败和取消仍不伪造 provenance。生产
deployment 的缺失 binary identity guard 未被此 test-only 变更绕过。

## Residuals

| Residual | Owner / next boundary | Status |
|---|---|---|
| corrected-input → canonical `GroupID` mapping、真实 async scheduler 与 RIME acceptance | 未来独立 runtime Assignment/Authorization | open；超出本 preflight |
| contextual `7/8`、真实设备/运行时行为、性能与 180 ms | 独立 Quality/Product/环境证据 | `UNKNOWN` / 未授权 |
| App + Keyboard `9 skipped` 与 `107` signing-disabled warnings | Quality 复核时继续按原始 receipt 解释 | open；非本轮架构 blocker |
| vendor archive/tree 与 simulator identity 的重新实体验证 | 专门 environment/Quality scope | 本 review 仅确认记录一致，未复验 |

## Non-claims

本 review 不声称：

- 重新执行或独立通过 KeyboardCore、RimeBridgeTests、App + Keyboard tests、Release build、
  hosted CI 或 vendor verification；
- 真实 RIME deployment、production scheduler/controller 接线、sidecar 行为、candidate ranking
  或 candidate visibility；
- 设备验收、Simulator/device Run、INT-003、QA-001、paired performance、180 ms 或
  contextual `7/8`；
- Quality、Product、Release Gate、publication、commit、push、PR、merge、TestFlight、Release
  或 parent/child Close；
- 任何超出五个 canonical manifest entry 的源码、测试、Xcode、vendor、schema 或 runtime 变更。

## Handoff

下一步可建立并执行一份**独立 Quality review**，但必须绑定同一精确 snapshot 与 canonical
manifest `709370f83f819a885f95b6224a763d59712eeac93f164939c03ae31627a9f207`，并将
`bcbabcb7…` 仅作为 `superseded_not_reproducible` 历史记录。Quality review 应保留上述
runtime、设备、性能、9 skipped、107 warnings、389 wrapper observation 和 `UNKNOWN` 边界；
本 Architecture review 不提供 publication 或其他后续外部动作权限。

本轮 reviewer 仅创建了本文件；未修改 Authorization、Assignment、`ACTIVE_WORK.md`、Swift、
测试、Xcode、vendor 或 schema，也未提交、推送、创建 PR 或消费 Authorization。
