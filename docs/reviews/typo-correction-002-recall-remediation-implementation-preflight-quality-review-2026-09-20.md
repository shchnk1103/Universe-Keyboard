# Quality Review: TYPO-CORRECTION-002 Recall Remediation Preflight

## Verdict

**Pass with conditions**，仅限本精确 working-tree snapshot 的纯 `Packages/KeyboardCore` preflight 证据。

本结论可以把本切片交给 Product 做 **bounded decision only**：Product 可以决定是否授权下一步有界工作；本结论不代表生产接线、真实 RIME、设备、性能、QA-001、INT-003、Release、merge 或任何 Gate 通过。

## Exact snapshot and manifest

| 项目 | 值 |
|---|---|
| Worktree | `/private/tmp/universe-keyboard-typo-correction-002-recall-preflight-001` |
| Branch | `codex/typo-correction-002-recall-preflight-001` |
| HEAD | `d0df9a6342d8209b5aa7f9826541d0b430b9da04` |
| HEAD tree | `27ae44bec1b157e391ef1e0b859db3a068e21ba8` |
| Review manifest SHA-256 | `c45e7c336093f60aa1e275d847be1779499bf11843844b36475e5c627817a8ad` |
| Manifest rule | 六份指定 artifact 按列出顺序，各行使用 `SHA-256  path`，以换行连接后再计算 SHA-256 |
| Review role | Independent Quality；未承担实现或 Architecture review |

HEAD/tree 与授权绑定一致。当前实现 source/test/doc 仍是未提交 working-tree 内容；这不是已提交 publication snapshot。Quality manifest 已独立重算，与授权值一致；本 review 文档不属于该六份 artifact，因此不改变该 manifest。

## Scope checked

实际阅读并核对了：

1. `ContextualTypoCorrection.swift`
2. `TypoCorrectionRecallPreflight.swift`
3. `TypoCorrectionRecallPreflightTests.swift`
4. preflight evidence receipt
5. implementation-preflight Assignment
6. 2026-09-20 Architecture review

静态调用点核对确认 `TypoCorrectionRecallPreflight*` 没有生产 controller、Keyboard Extension 或 RIME 调用点；生产默认 `ContextualTypoCorrectionHypothesisEngine()` 仍使用 `productionV2` 的 `12/8` 预算。预检的 `60/64` 只出现在纯内存假设生成/测试边界，`8` 是 ledger 的单批次 `maxQueryAttempts` 合同值，不是已经执行的 RIME query 数或 180 ms 目标。

## Findings by severity

### P1 — 保留 Architecture 条件：substitution-only 入口仍非 fail-closed

`ContextualTypoCorrectionSearchPlan` 的默认 `editPolicy` 仍为 `.all`；当前 focused test 是显式传入 `.substitutionOnly`。因此现状能证明本测试路径的 substitution-only 行为，不能证明未来任意调用预检入口都会自动排除 transposition、deletion、insertion。

Disposition: **保留 Architecture P1，fix before production/publication**。在任何生产接线或 publication 前，必须采用 substitution-only 专用入口/安全默认值，或要求显式 policy，并补充无显式 policy 时的 fail-closed 测试。本 Quality review 不修复它。

### P1 — 保留 Architecture 条件：`nResolvedGroups` 仍不是唯一 corrected-input group accounting

ledger 的 `finishQuery` 只接收 operation、candidate count 和 succeeded；每个非空成功响应都会增加 `nResolvedGroups`，没有 corrected-input/group identity，也没有去重。因此四个字段在存储与增量路径上是分开的，但当前字段不能被解释为 runtime 已接受且去重后的 corrected-input groups。

Disposition: **保留 Architecture P1，fix before runtime scheduler**。未来 scheduler 必须提供唯一 group identity 并定义去重/接受语义，或重命名该指标。本切片只可称为纯 Core 状态机 contract。

### P2 — 保留 Architecture 条件：batch cap、resolved-group cap、epoch mismatch 覆盖不完全独立

当前 query-cap 测试同时使用 `maximumBatchSize=8` 与 `maxQueryAttempts=8`，不能单独证明第 9 个同批 query 是被 batch cap 而非全局 query cap 拦截；当前 stale 测试改变了 `compositionRevision`，没有单独改变 `sessionEpoch`；也没有独立的 resolved-group-cap case。

Disposition: **保留 Architecture P2，fix before claiming complete async/runtime contract coverage**。当前 `9/9` 不得扩大解释为完整异步调度覆盖，也不阻止本纯字符串 frontier 的有界 non-claim。

### P2 — 本次 Quality 独立重跑受环境权限阻断

我按授权唯一运行一次：

```bash
swift test --package-path Packages/KeyboardCore
```

命令在 manifest 编译前失败，原因为本机沙箱无法写入 `/Users/doubleshy0n/.cache/clang/ModuleCache`，并报告 `Operation not permitted`；没有得到本次 reviewer 的测试执行结果。故 `1138/1138`、`9/9` 只能作为 executor evidence 中的记录，不能写成 Quality reviewer 独立重跑通过。

Disposition: **记录为 reviewer verification limitation，不判为源代码失败**。在任何需要更强测试结论、publication 或 runtime Authorization 前，应在允许 Swift/Clang 缓存写入的等价环境重新运行并绑定新鲜输出；本次不重跑、不申请构建或安装权限。

## Test and evidence reconciliation

### `1138/1138` 与 `9/9`

- evidence 记录 preflight 后完整 `swift test --package-path Packages/KeyboardCore` 为 `1138/1138`，变更前为 `1129/1129`；增量为 9，与 focused test 文件中静态可见的 9 个 `test...` 方法一致。
- evidence 同时记录 focused `TypoCorrectionRecallPreflightTests` 为 `9/9`。
- 测试文件覆盖 substitution-only、canonical target、四计数器分离、query-attempt cap、取消、revision/epoch stale discard、candidate limit fail-closed 与双编辑 display-only。
- 这些记录与源码和测试结构相互一致，但由于本次唯一重跑受环境权限阻断，Quality 不把它们升级为本 reviewer 新执行的 green result。

### Frontier

canonical case 为 `wimenjintianquhongyuan → womenjintianqugongyuan`。focused test 对首层档位 `[12, 16, 24, 32, 40, 48, 60]` 逐项计算目标在最终假设列表中的首个 rank；evidence 记录为：

| `maximumFirstLayerStates` | canonical target |
|---:|---|
| 12 | absent |
| 16 | absent |
| 24 | rank 54 |
| 32 | rank 55 |
| 40 | rank 55 |
| 48 | rank 55 |
| 60 | rank 55 |

这组数字在测试断言、evidence 表和 Assignment history 中一致。正确限定是：它是一个 substitution-only、双编辑、纯内存字符串生成 benchmark 的 reachability frontier；`24` 是该 case 首个观察到目标的档位，`60/64` 下观察 rank 为 `55`。它不是生产 12/8 实际 controller 路径的完整行为证明，不是 RIME 候选返回/排序、用户可见位置、端到端延迟、性能或产品成功率。

### 四个计数器与预算

`nGenerated`、`nQueryAttempts`、`nResolvedGroups`、`nCandidatesReturned` 是独立字段，focused tests 也分别断言了 `64/2/1/3` 等示例值。`maximumBatchSize=8`、`candidateLimit=3`、`maximumResolvedGroups=4`、`maxQueryAttempts=8` 的语义被 evidence 正确写成 pure Core contract；其中 `8` 没有被伪装成已经执行的 query 数。group identity 的 P1 residual 和独立 cap coverage 的 P2 residual 仍限制其解释范围。

### `contextual 7/8`

Assignment、evidence 和 Architecture review 均保留 `contextual 7/8 = UNKNOWN`。本切片只证明 canonical 22-character substitution-only case 的 bounded reachability；没有把短输入、legacy single-edit case 或 registry 行扩大成 contextual 7/8 结论。该边界应继续保留。

## Architecture residual disposition

Architecture verdict **Pass with conditions** 应原样保留，不应被 Quality 改写为 unconditional Pass：

| Residual | Quality disposition |
|---|---|
| substitution-only 默认入口 | `fix` before production/publication |
| corrected-input group identity/accounting | `fix` before runtime scheduler |
| 独立 batch/resolved-group/epoch focused coverage | `fix` before complete async/runtime contract claim |
| contextual 7/8 | `accept as UNKNOWN`；本 review 不关闭 |
| RIME、设备、性能、QA-001、INT-003 | `accept as explicit non-claims`；本 review 不测量 |

上述 residual 不阻止把当前切片交 Product 做有界的“是否继续”判断；它们阻止的是生产接线、publication、runtime contract 完整性或任何更宽的质量结论。

## Explicit non-claims

本 Quality review 不声称：

- 生产质量、生产可发布性或生产默认预算已通过；
- 真实 RIME schema/sidecar query、候选内容、候选排序或用户可见位置；
- 设备或 Simulator 行为、180 ms、paired performance、性能回归；
- QA-001、INT-003、RIME、安装、部署、隐私/host-text 边界的运行时证据；
- Product Gate、Quality Gate、Release Gate、TestFlight、Release、merge、PR 或 parent/child Close；
- `1138/1138` 或 `9/9` 是本 reviewer 本次独立执行得到的通过结果。

## Product bounded-decision handoff

**建议交 Product，但仅作 bounded decision。** Product 可基于本 review 决定是否另立、另授权下一步纯 Core 或生产前置工作；若决定触及 production controller、RIME、设备、性能、publication 或更宽质量合同，必须重新建立对应 Assignment/Authorization，并针对变化后的 exact snapshot 重新做 Architecture/Quality review。

本 review 只新增本文件；没有修改 Swift、测试、Assignment、Architecture review、Authorization 或其他生产文件，也没有创建新的 Run ID。
