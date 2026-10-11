# Evidence: TYPO-CORRECTION-002 recall remediation core contract

> **Evidence ID:** `TC2-RECALL-CORE-CONTRACT-20260920-01`
>
> **Status:** `Executor-recorded — residual remediation complete; independent Architecture/Quality review pending`
>
> **Collected:** `2026-09-20 Asia/Shanghai`
>
> **Assignment:** [`TYPO-CORRECTION-002-RECALL-REMEDIATION-CORE-CONTRACT-001`](../assignments/typo-correction-002-recall-remediation-core-contract-001.md)
>
> **Authorization:** [`AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-CORE-CONTRACT-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-CORE-CONTRACT-001.md)

本回执记录三个 Architecture residual 在纯 `Packages/KeyboardCore` 层的 remediation，以及
使用可写临时 Swift/Clang cache 的本地验证。没有新的 Simulator/真机 Run，因此没有创建 Run ID；
没有接入生产 controller、Keyboard Extension、RIME 或 sidecar query，也没有 commit、push、PR、
merge 或 Release。

## Provenance

| 项目 | 值 |
|---|---|
| Worktree | `/private/tmp/universe-keyboard-typo-correction-002-recall-preflight-001` |
| Branch | `codex/typo-correction-002-recall-preflight-001` |
| Source HEAD before remediation | `d0df9a6342d8209b5aa7f9826541d0b430b9da04` |
| Source tree before remediation | `27ae44bec1b157e391ef1e0b859db3a068e21ba8` |
| `Packages/KeyboardCore/Package.swift` Git blob identity | `1a06a522f12089f3dbb2ad774d13fe9f56193d04` |
| `Packages/KeyboardCore/Package.swift` actual SHA-256 | `9ebf33313b560b83634a074dd675211aee9cec13b1d879e9cd4f35fbb94aa764` |
| Authorization consumption | `2026-09-20T10:36:00+08:00`, before remediation code change |
| Remediation source SHA-256 | `9fb3fdc9c4cb809cf08b098bd882226e74a1a74eef23a043bba261d017216b57` |
| Remediation ledger SHA-256 | `e05488596a044e199b30fb3f262f72877ff31b172ba98638091b44ce7b030c9d` |
| Remediation tests SHA-256 | `9147004b425c19f2326292358f13e6db90c4d3969f2e4fb758841119991f3fd6` |

## Remediation result

| Architecture residual | 处置 | 证据边界 |
|---|---|---|
| P1 substitution-only default | `fixed in pure preflight contract` | `ContextualTypoCorrectionSearchPlan` 默认 `editPolicy=.substitutionOnly`；生产 engine/controller 的 `.all` / `12/8` 未改 |
| P1 group identity/accounting | `fixed in pure ledger contract` | 新增不含原始输入的 `TypoCorrectionRecallPreflightGroupID`；相同 group 去重后才增加 `nResolvedGroups`；尚无 runtime scheduler 接线 |
| P2 batch/resolved-group/epoch coverage | `fixed in focused pure-Core coverage` | 增加独立 batch cap、resolved-group cap、session epoch mismatch 测试；不宣称完整异步 runtime coverage |

## Code boundary

1. `ContextualTypoCorrectionSearchPlan` 的 preflight 默认改为 fail-closed substitution-only；若要测量 `.all`，调用方仍必须显式传入。
2. `TypoCorrectionRecallPreflightLedger.finishQuery` 需要稳定 group identity；成功响应的候选数仍独立计入 `nCandidatesReturned`，重复 identity 不重复计入 `nResolvedGroups`。
3. operation 变化时清理 group identity 集合；旧 composition revision 或 session epoch 的结果仍不能 resolve/publish。

生产 `ContextualTypoCorrectionHypothesisEngine()` 的默认 `productionV2`、生产 controller、
RIME query 和 host-text 路径均未修改。

## Verification

所有测试使用以下可写临时 cache：

```text
CLANG_MODULE_CACHE_PATH=/private/tmp/universe-keyboard-recall-remediation-clang-cache
SWIFT_MODULECACHE_PATH=/private/tmp/universe-keyboard-recall-remediation-swift-cache
```

| Check | Result | Boundary |
|---|---|---|
| `swift-format format --in-place` on three changed Swift files | PASS | formatting only |
| `swift-format lint --strict` on three changed Swift files | PASS | strict format gate |
| Focused `swift test --package-path Packages/KeyboardCore --filter TypoCorrectionRecallPreflightTests` | PASS — `14/14` | includes the original 9 plus 5 remediation cases |
| Full `swift test --package-path Packages/KeyboardCore` | PASS — `1143/1143` | 0 failures; +5 tests from prior 1138 baseline |
| `git diff --check` | PASS | current worktree |

Focused remediation coverage includes：

- default preflight policy is substitution-only;
- stable group identity deduplication;
- batch cap independent from global query-attempt cap;
- resolved-group cap independent from query-attempt cap;
- session epoch mismatch independently rejects stale results;
- prior cancellation, composition revision, candidate-limit and display-only contracts remain green。

完整测试仍报告仓库既有的无关 warning：
`Packages/KeyboardCore/Tests/KeyboardCoreTests/T9PinyinPathTests.swift:1429:37`
的 optional interpolation。它不属于本次 remediation，未被修改。

## Residuals and non-claims

- 这些修复仍是纯 Core contract；没有 runtime scheduler、真实 RIME group identity 或 sidecar query 接线。
- `contextual 7/8` 仍为 `UNKNOWN`；本回执没有扩展 benchmark 范围。
- 不证明真实 RIME 候选内容、排序、可见位置、设备行为、端到端延迟、180 ms、paired performance、QA-001 或 INT-003。
- 不代表 Product/Quality/Release Gate、生产可发布性、PR、merge、TestFlight、Release 或 parent/child Close。
- 下一步必须由独立 Architecture 和 Quality reviewer 对这个新的 remediation snapshot 复核；reviewer 若需要更强测试结论，应绑定本回执的可写 cache 输出而不是复用旧 review。
