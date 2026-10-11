# Product Decision: TYPO-CORRECTION-002 recall core contract remediation

> **Decision ID:** `PD-TYPO-CORRECTION-002-RECALL-REMEDIATION-CORE-CONTRACT-BOUNDED-2026-09-20`
>
> **Decision:** `Bounded Accept — pure Core remediation accepted; runtime mapping remains open`
>
> **Assignment:** [`TYPO-CORRECTION-002-RECALL-REMEDIATION-CORE-CONTRACT-001`](../assignments/typo-correction-002-recall-remediation-core-contract-001.md)
>
> **Authorization:** [`AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-CORE-CONTRACT-PRODUCT-DECISION-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-CORE-CONTRACT-PRODUCT-DECISION-001.md)
>
> **Date:** `2026-09-20 Asia/Shanghai`

## Decision

Product 接受本次 pure `Packages/KeyboardCore` residual remediation 作为有界工程结果：

- preflight 默认已 fail-closed 为 substitution-only；
- opaque group identity 的 ledger 去重合同已补齐；
- batch、resolved-group、session epoch 的 focused pure-Core coverage 已补齐；
- focused `14/14` 与完整 `1143/1143` 已在可写临时 cache 环境由 Executor 记录。

这个 Accept 只表示“本次 Core contract remediation 可以进入下一次有界工程判断”，不表示
runtime scheduler 或产品功能已经接受。

## Open residual

仍开放一个 P1：未来 runtime scheduler 如何从 corrected-input 生成 canonical group identity、
如何定义 group acceptance/provenance，以及如何把 opaque token 绑定到真实 sidecar query。
当前 Core ledger 只消费 scheduler 提供的 token；没有自行推导或证明 runtime mapping。

另保留以下边界：Quality reviewer 的独立重跑被 sandbox 权限阻断；`14/14`、`1143/1143`
和 strict lint 仍按 executor evidence 处理。`contextual 7/8` 继续为 `UNKNOWN`。

## Explicit non-claims

本决策不接受或关闭：

- 生产 controller、Keyboard Extension、RIME/schema/vendor、sidecar query 或 runtime scheduler；
- 真实候选内容、排序、可见位置、用户体验、设备行为或安装/部署；
- 180 ms、paired performance、QA-001、INT-003 或任何性能结论；
- Product Gate、Quality Gate、Release Gate、TestFlight、Release、PR、merge；
- parent/child Assignment Close；
- 本地或云端 AI 模型方案。

## Next authorization frontier

下一步只能二选一，并分别建立新的 Authorization：

1. **Publication lane（当前更稳妥）：** 仅发布这批 pure Core contract remediation，先做本地 CI 等价质量门，再决定 commit/push/PR；不接 runtime。
2. **Runtime lane：** 另立 bounded runtime scheduler Assignment，定义 canonical group mapping、真实 RIME provenance 和异步 publish 语义；这会产生新的 source/package snapshot，并必须重新做 Architecture/Quality review。

在没有新的 publication 或 runtime Authorization 之前，不得 commit/push，也不得把当前 worktree
当成可合并 PR。
