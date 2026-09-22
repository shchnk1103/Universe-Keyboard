# Product Decision: TYPO-CORRECTION-002 bounded second-stage recall runtime design

> **Decision ID:** `PD-TYPO-CORRECTION-002-SECOND-STAGE-RECALL-RUNTIME-DESIGN-001`
>
> **Decision:** `Accepted — Option B: bounded runtime design / contract-preflight only`
>
> **Date:** `2026-09-20 Asia/Shanghai`

## Decision

Human Product Owner 选择了
[`second-stage recall runtime decision request`](../plans/typo-correction-002-second-stage-recall-runtime-decision-request-2026-09-20.md)
的 **B**：先进行有界的 runtime 设计与静态 contract-preflight，随后才决定是否存在值得授权的 runtime 实现切片。

这个决定授权建立一个仅限文档和静态源代码分析的独立 Assignment；它不授权修改
Swift、测试、生产 controller、Keyboard Extension、RIME、schema/vendor 或任何设备状态。

## Basis

| Input | Disposition |
|---|---|
| QA-001 revalidation 07 | 精确输入、真实 sidecar 与候选栏已建立；目标未被 Human 观察，case 仍为 `inconclusive`，且不重跑同包同短语 |
| Recall frontier | production `12/8` 不包含 canonical pinyin；expanded substitution-only search 在 rank `55` 观察到它 |
| Pure Core remediation | fail-closed substitution-only、opaque ledger dedup 和独立 batch/resolved-group/epoch coverage 已获 bounded acceptance |
| Open boundary | runtime canonical group mapping、接受/provenance 语义、真实 RIME 返回、候选可见性和性能仍未证明 |

## Authorized consequence

建立 [`TYPO-CORRECTION-002-SECOND-STAGE-RECALL-RUNTIME-DESIGN-001`](../assignments/typo-correction-002-second-stage-recall-runtime-design-001.md)
及其 matching Authorization。该 Assignment 的唯一产出是一个可审查的 runtime design package：

1. 定义不含原始输入内容的 canonical group identity 与接受语义；
2. 定义 deterministic coverage-deficit trigger、第二阶段预算候选、`maxQueryAttempts`、batch/resolved-group/candidate limits；
3. 定义 cancellation、revision/epoch 与 stale-publish fence；
4. 列出 production wiring、真实 RIME 和新的 QA-001/paired-performance 所需的后续独立证据。

它必须保持首阶段 `12/8`、`60/64/8` default-off、substitution-only、双编辑 display-only、sidecar isolation 与 local-only privacy boundary 不变。

## Explicit non-claims

本决定不是：

- 对第二阶段 runtime、真实 RIME 候选、候选排序、用户可见位置或句子恢复的接受；
- 将 `60/64/8` 接入生产或批准任何搜索预算变化；
- QA-001、INT-003、paired performance、180 ms、Product/Quality/Release Gate、TestFlight 或 Release 结论；
- 对代码、测试、capture、commit、push、PR、merge 或 Assignment Close 的授权。

## Next authorization frontier

[`AUTH-TYPO-CORRECTION-002-SECOND-STAGE-RECALL-RUNTIME-DESIGN-001`](../authorizations/AUTH-TYPO-CORRECTION-002-SECOND-STAGE-RECALL-RUNTIME-DESIGN-001.md)
现为 `active`，但尚未消费。其范围仅是 docs-only 设计与静态分析。
任何 Swift 改动、真实 RIME 查询、Simulator/真机 Run、publication 或 runtime wiring
都需要新的、分别命名的 Authorization。
