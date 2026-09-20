# Architecture Review: TYPO-CORRECTION-002 recall remediation core contract

## Verdict

**Pass with conditions**。

本 verdict 仅适用于下列精确 working-tree snapshot 的纯 `Packages/KeyboardCore` residual-remediation。三个本次复核目标均已在 Core contract 层得到代码/测试处置；仍保留 runtime scheduler、真实 RIME、设备、性能、publication 与 Gate 边界。因此本结论不等于生产接线批准，也不等于 Product/Quality/Release Gate。

## Exact snapshot

| 项目 | 值 |
|---|---|
| Worktree | `/private/tmp/universe-keyboard-typo-correction-002-recall-preflight-001` |
| Branch | `codex/typo-correction-002-recall-preflight-001` |
| HEAD | `d0df9a6342d8209b5aa7f9826541d0b430b9da04` |
| HEAD tree | `27ae44bec1b157e391ef1e0b859db3a068e21ba8` |
| Remediation manifest SHA-256 | `d1cad034c09af7af96549bab184e7151b186d0f212d1a2f9b347941e011df4e5` |
| Manifest rule | 八个授权 artifact 按列出顺序生成 `shasum -a 256` 行，以换行连接后再计算 SHA-256 |
| Worktree state | remediation source/test/evidence/docs 为未提交 working-tree 内容；本 review 只新增本文档 |

Manifest 覆盖：`ContextualTypoCorrection.swift`、`TypoCorrectionRecallPreflight.swift`、focused test、core evidence、core Assignment、此前 bounded Product decision、此前 Architecture review、此前 Quality review。HEAD/tree 是变更前来源身份；review 结论绑定上述八个当前 artifact，而不是只绑定 HEAD。

## Scope and sources read

实际阅读了授权列出的三个实现/测试文件、core evidence、core Assignment、matching Architecture Authorization，以及此前的 bounded Product decision、implementation-preflight Architecture review 和 Quality review；同时核对了 ADR 0015/0016、`TYPO_CORRECTION.md`、生产 controller 调用点与相关 assessment contract。

本次没有运行测试、构建、Simulator、设备或 RIME；测试结果仅作为 executor evidence 记录，不升级为本 reviewer 的执行结果。

## Contract findings

### P1 — runtime group identity 仍有边界条件，但不阻塞本次纯 Core verdict

`TypoCorrectionRecallPreflightGroupID` 是不含原始输入的 `UInt64` identity，ledger 通过 `Set` 对相同 identity 去重；相同 group 不增加 `nResolvedGroups`，新的 accepted group 才增加。该层满足稳定 token 的去重 contract，并且没有 raw input logging 或 persistence。

但 identity 的生成/映射仍由未来 scheduler 提供；当前 Core 类型本身不从 corrected input 推导 canonical identity。因此本复核只能关闭“ledger 接受稳定 token 并去重”的 residual，不能关闭“runtime scheduler 对 corrected-input group 的唯一映射与接受语义”。该边界应在 runtime implementation Authorization 前继续保留。

### P2 — 四计数器与 candidate response 语义保持分离

`nGenerated`、`nQueryAttempts`、`nResolvedGroups`、`nCandidatesReturned` 是独立状态与增量路径。成功响应的 candidate count 可以计入 `nCandidatesReturned`；stale/cancelled response 不得成为 resolved group 或 publish，但其已启动 query 与 returned candidate data 的计数语义由 contract 明确保留。focused tests 覆盖了 `64/2/1/3`、重复 group 和 stale response 情形。

本设计没有把 candidate response 数量伪装成 corrected-input group 数量，也没有把纯内存 hypothesis 数量伪装成 RIME query 数量。

### P2 — batch cap 与 resolved-group cap 已独立

`maximumBatchSize` 在 `beginQuery` 单独限制当前 batch；`maxQueryAttempts` 单独限制全局 query attempts；`maximumResolvedGroups` 在 batch/query 入口及 accepted result 路径独立限制 resolved groups。focused tests 使用 `2 < 8` 验证 batch cap 允许后续 batch，使用 `1 < 8` 验证 resolved-group cap 不依赖 query-attempt cap。

### P2 — revision/epoch stale publish fence 已分别覆盖

ledger 以完整 `TypoCorrectionRecallPreflightOperation`（`compositionRevision + sessionEpoch`）与 `currentOperation` 做 equality fence。revision 不变而 epoch 改变的 focused case 证明旧 query result 不会 resolve/publish；operation 变化也清理旧 group identity 集合。cancel、in-flight、open-batch 和 contract violation 进一步阻止 publish。

## Required boundary checks

### Preflight default fail-closed

通过。`ContextualTypoCorrectionSearchPlan(input:)` 的默认 `editPolicy` 为 `.substitutionOnly`，默认 preflight 不生成 transposition、deletion 或 insertion；扩大 edit set 必须显式传入。生产 `ContextualTypoCorrectionHypothesisEngine` 的默认 policy 仍为 `.all`，二者边界清楚。

### Production 12/8、controller/RIME/隐私边界

通过。`ContextualTypoCorrectionSearchBudget.productionV2` 仍为 `12/8`；生产 controller 仍调用默认 hypothesis engine。新 ledger/preflight 类型没有生产 controller、Keyboard Extension、RimeBridge、RIME query、host-text、marked-text、持久化或网络调用点。`60/64` 仍是纯内存 preflight 搜索预算，`8` 是 ledger 的 bounded batch/query contract，不是生产调度值或 180 ms 结论。

### Candidate response 与 display/promotion

通过。双编辑 assessment 保持 `isDisplayEligible == true`、`isPromotionEligible == false`；preflight 不改变 candidate response 的最终显示/提交语义，也没有把 recall reachability 写成 candidate quality 或用户可见位置。

## Findings by severity

| 严重度 | Finding | Disposition |
|---|---|---|
| P1 residual boundary | runtime scheduler 尚未定义 corrected-input 到 `GroupID` 的 canonical 生成/映射 | 保留；runtime 接线前必须另立 Authorization 并重新做 Architecture/Quality review |
| P2 residual boundary | 当前 focused coverage 是同步纯 Core ledger coverage，不是异步 scheduler、真实 RIME 或端到端 publish coverage | 保留为 non-claim；不阻塞本次 Core review，但不得升级为 runtime contract complete |
| — | 未发现生产 12/8、controller/RIME、candidate response separation 或 privacy boundary 的越界变更 | 通过 |

## Residual disposition

| Residual | 本次处置 | 后续边界 |
|---|---|---|
| substitution-only fail-closed default | `closed for pure preflight Core contract` | production/publication 前仍需重审 exact snapshot |
| group identity/accounting | `closed for opaque-token dedup ledger; runtime mapping remains open` | scheduler 必须定义 canonical identity、接受语义及 provenance |
| batch cap / resolved-group cap / epoch fence | `closed for focused pure-Core coverage` | 不等于异步 runtime 或真实 RIME coverage |
| `contextual 7/8` | `UNKNOWN`，未改变 | 需独立 benchmark/evidence，不由本 review 推断 |
| Quality cache limitation / executor test results | 保留证据边界 | 本 reviewer 未执行测试；Quality reviewer 必须独立复核当前 manifest |
| production wiring / RIME / device / performance | 未授权、未关闭 | 需新的 Assignment/Authorization 与新 snapshot |

## Evidence and non-claims

当前 evidence 对 source/package identity、纯 Core 变更、focused/full test 的 executor provenance 及 non-claims 记录基本诚实。`1143/1143`、focused `14/14`、strict format 与 `git diff --check` 均不作为本 reviewer 新执行结果；本次没有创建新的 Run ID。

本 review 不声称：

- 真实 RIME 候选内容、排序、可见位置、sidecar query 或 scheduler 交付；
- 生产 12/8 之外的可用预算、端到端延迟、180 ms、paired performance 或产品成功率；
- 设备/Simulator、QA-001、INT-003、隐私运行时行为或安装/部署证据；
- Product Gate、Quality Gate、Release Gate、PR、merge、TestFlight、Release 或 parent/child Close；
- `contextual 7/8` 已被证明，或纯 Core group token 已等同于 runtime corrected-input identity。

## Recommendation for independent Quality review

**建议进入独立 Quality review，结论范围仅限本精确 manifest 的纯 KeyboardCore/preflight snapshot。** Quality review 应独立重核八个 artifact 的 manifest、focused/full evidence 与上述 P1/P2 residual；不得把本 Architecture verdict 扩展为生产、RIME、设备、性能或 Release 结论。

本次仅新增本文档；未修改 Swift、测试、Assignment、Authorization 或其他生产文件，未运行设备/Simulator/RIME，未 commit/push。
