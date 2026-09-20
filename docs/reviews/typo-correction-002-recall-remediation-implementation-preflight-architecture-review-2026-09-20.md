# Architecture Review: TYPO-CORRECTION-002 Recall Remediation Preflight

## Verdict

**Pass with conditions**。

本结论仅适用于下列精确 working-tree review snapshot 的纯 `KeyboardCore` preflight。它不授权生产接线、RIME、设备/Simulator、性能、Product、Quality、Release 或 parent Assignment 关闭。

## Exact snapshot

| 项目 | 值 |
|---|---|
| Worktree | `/private/tmp/universe-keyboard-typo-correction-002-recall-preflight-001` |
| Branch | `codex/typo-correction-002-recall-preflight-001` |
| HEAD | `d0df9a6342d8209b5aa7f9826541d0b430b9da04` |
| HEAD tree | `27ae44bec1b157e391ef1e0b859db3a068e21ba8` |
| Review manifest SHA-256 | `f0352d7856195ddda97f7b8b03e82fc0b7cd635844fc3d243109abebea5f77a0` |
| Review input | 两个生产源文件、一个 focused test 文件、evidence、Assignment；均按已消费 Architecture Authorization 绑定 |

复核时 worktree 保留实现者已有的未提交 source/test/doc changes。本次只新增本 review 文档；未修改 Swift、测试、Assignment、Authorization 或其他生产文件。

## 关键依据

1. **生产默认保持 12/8，preflight 未接入。** `ContextualTypoCorrectionSearchBudget.productionV2` 仍为 `12/8`（`ContextualTypoCorrection.swift:270-284`），生产 controller 仍以默认 `ContextualTypoCorrectionHypothesisEngine()` 调用（`KeyboardController+TypoCorrection.swift:33-40`）。`TypoCorrectionRecallPreflightLedger` 没有生产 controller 或 Keyboard Extension 调用点；扩大搜索仅出现在 preflight/test 路径。

2. **substitution-only 和双编辑 display-only 有明确 Core 证据。** `TypoCorrectionEditPolicy.substitutionOnly` 只允许 `.substitution`（`TypoCorrectionRecallPreflight.swift:3-23`），focused test 验证 canonical 双编辑结果的每个 edit 均为 substitution（`TypoCorrectionRecallPreflightTests.swift:10-26`）。`TypoCorrectionAssessment.multiEditAssessment` 保持 `isDisplayEligible == true`、`isPromotionEligible == false`，测试也直接锁定该合同（`TypoCorrection.swift:570-591`；focused test `:186-200`）。

3. **四个计数器在状态上分离，cap 和基本 stale/cancel fence 成立。** `nGenerated`、`nQueryAttempts`、`nResolvedGroups`、`nCandidatesReturned` 是独立字段和记录路径（`TypoCorrectionRecallPreflight.swift:66-87`）；query attempt、batch、candidate 和 resolved-group 的上限均有代码检查（`:128-195`）。取消后结果不能成为 resolved group 或 publish，revision/epoch operation 不匹配时 stale result 不能 publish（`:159-234`；tests `:112-169`）。

4. **provenance 与 non-claims 基本准确。** evidence 绑定相同 worktree/branch/HEAD/tree，并明确记录 `60/64` 只是内存生成 frontier，不是 RIME query、180 ms、候选质量或产品成功率（`docs/evidence/typo-correction-002-recall-remediation-implementation-preflight-001.md:18-29,49-74`）。Assignment 明确保留 contextual `7/8` 为 `UNKNOWN`，并排除 RIME、设备、性能和 Gate 结论（`docs/assignments/typo-correction-002-recall-remediation-implementation-preflight-001.md:5-13,36-43`）。

## Findings by severity

### P1 — preflight 入口默认仍可放宽到 `.all`

`ContextualTypoCorrectionSearchPlan` 的默认参数是 `progressiveRecallPreflight` 与 `.all`（`ContextualTypoCorrection.swift:291-304`）；只有当前 focused test 显式传入 `.substitutionOnly`。因此“首个 preflight slice 必须 substitution-only”是调用约定，不是 API 默认的 fail-closed 约束。当前没有生产接线，所以不构成当前生产回归；但未来调用 `ContextualTypoCorrectionSearchPlan(input:)` 会静默重新启用 transposition/deletion/insertion。

**条件：** 任何生产或 publication 前，应改为 substitution-only 的专用入口/默认值，或让 edit policy 成为显式且不可省略的参数，并补充无显式 policy 时不会生成其他 edit kind 的测试。

### P1 — `nResolvedGroups` 未表达或去重 corrected-input group identity

`finishQuery` 只接收 operation、candidate count 和 succeeded，不接收 corrected input 或 group token；每个非空成功 query 都直接 `recordResolvedGroup()`（`TypoCorrectionRecallPreflight.swift:165-195`）。因此当前计数实际是“非空 query response 次数”，不一定是 B1 所定义的“被接受的 corrected-input groups”；重复查询同一 corrected input 可被重复计数。`nCandidatesReturned` 也记录 raw successful response 数，没有模拟候选去重/最终接受边界。

**条件：** 未来 runtime scheduler 必须提供唯一 group identity 并明确去重/接受语义，或重新命名该 ledger 指标；在此之前只能把它视为纯状态机计数，不得宣称已完成 runtime group accounting。

### P2 — batch cap 与 epoch fence 的 focused coverage 不足

当前 query-cap 测试同时使用 `maximumBatchSize=8` 与 `maxQueryAttempts=8`（`TypoCorrectionRecallPreflightTests.swift:83-110`），不能独立证明“batch cap”而非全局 query cap 阻止第 9 个同批 query；也没有单独改变 `sessionEpoch` 的 stale-result 测试。代码的 equality fence 同时包含 revision/epoch，但 evidence 对这两项的证明仍主要来自一次 revision 变化。

**条件：** Quality review 或后续 runtime Authorization 前，补充独立 batch-cap、resolved-group-cap 和 epoch-mismatch focused cases；不得把当前 `9/9` 结果扩大解释为完整异步调度覆盖。

## Residual and disposition

| Residual | 当前处置 | 边界 |
|---|---|---|
| P1 substitution-only 默认入口 | `fix` before production/publication | 当前未接线，保留为架构条件 |
| P1 group identity/accounting | `fix` before runtime scheduler | 当前 ledger 仅为纯 Core contract |
| P2 batch/epoch focused coverage | `fix` before claiming complete contract coverage | 不影响当前纯字符串 frontier 的 non-claim |
| contextual 7/8 | `accept` as `UNKNOWN` | 本 review 不关闭该 residual |
| RIME、设备、性能、QA-001、INT-003、Product/Quality/Release | `accept` as explicit non-claims | 需要独立 Assignment/Authorization 和证据 |

## Evidence boundary and non-claims

本 review 没有执行测试、Simulator、设备、RIME、部署或性能采集；验证依据是实际 source/test 阅读、当前 evidence/Assignment 和静态调用点核对。`1138/1138`、focused `9/9`、frontier `12/16/24/32/40/48/60` 等数字是 executor evidence 中的记录，不是本 reviewer 新执行的结果。

因此本 review 不声称：真实 RIME 候选返回或排序、用户可见位置、端到端延迟、180 ms、设备行为、QA-001、INT-003、Quality/Product/Release Gate、生产可发布性或 parent Close。

## Quality review recommendation

**建议进入独立 Quality review，但仅限本精确 snapshot 的纯 KeyboardCore/preflight 证据。** Quality review 应保留以上三个条件和全部 non-claims；在任何生产接线、RIME query、设备/Simulator、性能或 publication 之前，必须重新取得相应 Authorization，并重新复核变更后的 exact snapshot。
