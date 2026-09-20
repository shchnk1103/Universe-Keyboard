# Product Decision: TYPO-CORRECTION-002 recall implementation preflight

> **Decision ID:** `PD-TYPO-CORRECTION-002-RECALL-REMEDIATION-IMPLEMENTATION-PREFLIGHT-BOUNDED-2026-09-20`
>
> **Decision:** `Bounded Accept — evidence may proceed to a separately authorized next step`
>
> **Assignment:** [`TYPO-CORRECTION-002-RECALL-REMEDIATION-IMPLEMENTATION-PREFLIGHT-001`](../assignments/typo-correction-002-recall-remediation-implementation-preflight-001.md)
>
> **Authorization:** [`AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-IMPLEMENTATION-PREFLIGHT-PRODUCT-DECISION-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-IMPLEMENTATION-PREFLIGHT-PRODUCT-DECISION-001.md)
>
> **Date:** `2026-09-20 Asia/Shanghai`

## Decision

Product 接受当前精确 snapshot 的纯 `Packages/KeyboardCore` preflight 作为一个**有界输入**，允许为 residual remediation 或下一阶段方案另立 Assignment/Authorization。

这不是对生产功能的接受，也不是对“我们今天去公园”真实 RIME 候选效果的接受。当前决策只回答：这份 preflight 证据是否足够进入下一次有界工程判断。答案是：**足够，但必须保留以下条件。**

## Basis

| Input | Result |
|---|---|
| Executor preflight evidence | 记录 `1129/0` baseline、`1138/0` post-change、focused `9/9`、frontier `12/16 absent`、`24→rank54`、`32/40/48/60→rank55` |
| Independent Architecture | `Pass with conditions` |
| Independent Quality | `Pass with conditions` |
| Quality verification limitation | Swift/Clang cache 权限阻止 reviewer 重跑；`1138/0` 与 `9/9` 保持为 executor-recorded，不升级为 Quality 独立执行结果 |
| Source identity | HEAD `d0df9a6342d8209b5aa7f9826541d0b430b9da04` / tree `27ae44bec1b157e391ef1e0b859db3a068e21ba8`；Product snapshot manifest `ef94c6a9fb8d00f6a7c8b37b632e6a0e1f69c7460b170e2cbbe207bd43765971` |

## Accepted residuals

1. **P1 — substitution-only 入口仍不是 fail-closed。** 当前测试显式传入 `.substitutionOnly`，但 API 默认仍可使用 `.all`。在生产接线或 publication 前必须修成安全默认或专用入口，并补测试。
2. **P1 — group identity/accounting 未完成。** `nResolvedGroups` 目前只能表示非空响应次数，不能宣称 corrected-input group 的唯一/去重接受语义。runtime scheduler 前必须补唯一 identity 或重命名指标。
3. **P2 — async contract coverage 不完整。** batch cap、resolved-group cap、session epoch mismatch 尚未分别由独立 focused case 锁定。不能把当前 `9/9` 扩大为完整异步调度合同。
4. **P2 — Quality reviewer verification limitation。** 由于 Swift/Clang cache 权限，本次 Quality reviewer 未能独立重跑测试；后续若需要更强测试结论，应在可写 cache 的环境重新验证。
5. **Contextual 7/8 仍为 `UNKNOWN`。** 当前只覆盖一个 substitution-only 双编辑 canonical benchmark。

## Explicit non-claims

本决策不接受或关闭：

- 生产 12/8 预算、生产 controller、Keyboard Extension、RIME 或 sidecar query；
- 真实候选内容、排序、可见位置、用户输入体验或端到端延迟；
- 180 ms、paired performance、QA-001、INT-003、设备/Simulator 行为；
- Product Gate、Quality Gate、Release Gate、TestFlight、Release、PR、merge；
- parent/child Assignment Close；
- 本地或云端 AI 模型方案。

## Allowed consequence

如果继续，下一步必须另立 bounded Authorization，选项按优先级为：

1. **优先：** 纯 KeyboardCore residual remediation，先修 substitution-only fail-closed 入口，并补 group identity 与独立 batch/resolved-group/epoch tests；完成后再次 Architecture/Quality review。
2. **之后才可讨论：** 生产 controller/RIME 接线；这需要新的实现 Authorization、新 source/package identity、新测试和新的 Architecture/Quality review。
3. **性能或设备证据：** 仍走 parent 的独立 Run/Authorization 流程，不能由本 Product decision 复用。

本决策不授权 commit/push。当前实现和文档仍保留在隔离 worktree 的未提交状态。
