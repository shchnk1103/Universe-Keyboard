# Product Decision: TYPO-CORRECTION-002 recall remediation publication preflight

> **Decision ID:** `PD-TYPO-CORRECTION-002-RECALL-REMEDIATION-PUBLICATION-PREFLIGHT-BOUNDED-2026-09-20`
>
> **Decision:** `Bounded Accept with conditions — proceed only to separately authorized publication preparation`
>
> **Assignment:** [`TYPO-CORRECTION-002-RECALL-REMEDIATION-PUBLICATION-PREFLIGHT-001`](../assignments/typo-correction-002-recall-remediation-publication-preflight-001.md)
>
> **Authorization:** [`AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-PUBLICATION-PREFLIGHT-PRODUCT-DECISION-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-PUBLICATION-PREFLIGHT-PRODUCT-DECISION-001.md)
>
> **Date:** `2026-09-20 Asia/Shanghai`

## Decision

Product 接受当前 exact snapshot 作为一个**有界的 publication-preparation 输入**，允许下一步另立 Authorization 来整理最终提交身份和发布范围。

这不是对生产功能、真实 RIME 候选、用户体验或 Release 的接受，也不是 Product Gate、Quality Gate 或 Release Gate。当前决定只回答：经过 provenance reconciliation、独立 Architecture 和独立 Quality 复核后，是否可以继续做下一阶段的发布准备。答案是：**可以，但必须保持以下条件。**

## Basis

| Input | Result |
|---|---|
| Canonical manifest | 五行 UTF-8/LF manifest，SHA-256 `709370f83f819a885f95b6224a763d59712eeac93f164939c03ae31627a9f207` |
| Local preflight | KeyboardCore `1143 passed / 0 failed`；RimeBridgeTests `105 total / 85 passed / 20 skipped / 0 failed`；App + Keyboard `388 total / 379 passed / 9 skipped / 0 failed`；Release `BUILD SUCCEEDED` |
| Independent Architecture | `Pass with conditions`；无阻止 Quality handoff 的 Architecture finding |
| Independent Quality | `Pass with conditions`；仅限 bounded local CI-equivalent preflight |
| Governance | validators `12/12`、final-gate pass、KOS trigger paths pass |
| Snapshot | HEAD `d0df9a6342d8209b5aa7f9826541d0b430b9da04` / tree `27ae44bec1b157e391ef1e0b859db3a068e21ba8`；working tree 仍未提交 |

## Accepted residuals and conditions

Product 接受以下 residual 作为当前 bounded preparation 的已知条件，不把它们改写为通过：

1. **9 skipped tests。** 这些测试仍是未覆盖条件，不能从其余通过项推导完整 runtime/fixture 覆盖。
2. **107 条 `CODE_SIGNING_ALLOWED=NO` entitlement warnings。** 它们是测试环境 residual，不授权修改 checked-in entitlements，也不等价于生产 App Group 成功或失败。
3. **AppIntents metadata warning。** Release build 虽成功，warning 仍保留。
4. **Working tree snapshot 尚未成为提交或发布 artifact。** 当前 manifest 绑定的是 working-tree source snapshot；任何后续 commit/push/PR 都必须重新绑定最终 commit、tree、文件范围和 manifest。
5. **Pure-Core 与 runtime 的边界。** `12/8` production contract、`60/64` substitution-only preflight、ledger cancellation/stale fences 和 test-only fixture 边界均保持；这不证明 production controller、async scheduler、canonical GroupID mapping 或真实 RIME 接线。
6. **未完成的运行与产品证据。** contextual `7/8`、真机/Simulator behavior、INT-003、QA-001、paired performance、180 ms 均继续保持 `UNKNOWN` 或未授权。
7. **历史 digest。** `bcbabcb7…` 仅作为 `superseded_not_reproducible` 历史记录，不得重新用作当前 provenance。

## Required conditions for any later publication lane

如果要继续到 commit/push/PR，下一份 publication Authorization 至少必须：

1. 明确最终要提交的文件集合，避免把当前 mixed dirty worktree 的无关变更带入提交。
2. 重新绑定最终 HEAD、tree、每个 source/package 文件 hash 和 canonical manifest。
3. 若 Swift/source 文件相对目标分支发生变化，重新执行适用的 Swift 格式硬门槛和本地 CI 门禁；不能直接把 working-tree preflight 当成新 commit 的门禁证明。
4. 把 9 skipped、107 warnings、AppIntents warning 和所有 runtime/device/performance non-claims 带入下一份 receipt。
5. 将 commit、push、PR、merge 分别作为独立权限处理；本 Product decision 不授予其中任何一项。

## Explicit non-claims

本决定不接受或关闭：

- 生产 12/8 之外的 runtime wiring、Keyboard Extension、RIME 或 sidecar behavior；
- 真实候选内容、排序、可见位置、自动改写或端到端输入体验；
- INT-003、QA-001、paired performance、180 ms、真机或 Simulator acceptance；
- Quality Gate、Product Gate、Release Gate、TestFlight、Release；
- commit、push、PR、merge 或 parent/child Assignment close；
- 本地或云端 AI 模型方案。

## Allowed consequence

下一步可以建立一份**新的 bounded publication Authorization**，专门核对最终提交范围和最终 identity。只有该 Authorization 明确允许时，才可进行 commit、push 或 PR；merge 仍需单独检查和授权。

本 Product decision 不修改源码、不重跑测试、不产生新 Run ID，也不改变 parent `TYPO-CORRECTION-002` 的 Active 状态。
