# Quality Review: TYPO-CORRECTION-002 runtime-preflight implementation

## Bounded Quality verdict

**Pass with conditions**，仅限以下 exact uncommitted 三文件 pure-Core
snapshot 的 bounded Quality review。

本 verdict 说明当前 evidence、静态 scope 和 Architecture Conditional Accept
在授权范围内相互一致，可以交给 Product Lead 作下一步 bounded decision。
它不是 Quality Gate，也不是 runtime、production、Product、Release 或
publication 通过。

## Review boundary

| 项目 | 值 |
|---|---|
| Code worktree | `/Users/doubleshy0n/.codex/worktrees/typo-correction-002-runtime-preflight-implementation-001/Universe Keyboard` |
| Parent docs worktree | `/private/tmp/universe-keyboard-typo-correction-002-parent-revalidation-003` |
| Baseline commit / tree | `4d1050f4b677494e06448cb40a83ef2da46d7b27` / `5f864a6f6f139810ed59c7e00ab6c33caad7e500` |
| Independent uncommitted diff SHA-256 | `8bb105c5381feb43fc41ec168fd239fd7c864cc0efa739cae3976beb685ebbab` |
| Review manifest SHA-256 | `35c2f06896dd263d7ec079fdef4e07e6fcb44215e8045c694689c5b4922b1130` |
| Reviewer | Independent Quality；不是 implementation executor，也不是 Architecture reviewer |
| Review time | `2026-09-21T20:12:17+08:00` |

本 review 只读取 code worktree 与 parent docs 中的指定 evidence、
Assignment、Architecture review 和相关 Core/controller/RimeBridge 路径。
没有运行任何 test、build 或 lint；没有网络、RIME、Simulator/device、
commit、push、PR 或 merge 操作。

## Independent changed-file manifest

独立重算的 git diff --name-status 只有以下三项；内容 SHA-256 也与
executor receipt 中的 post-change hashes 一致：

| 状态 | Path | Post-change SHA-256 |
|---|---|---|
| M | Packages/KeyboardCore/Sources/KeyboardCore/ContextualTypoCorrection.swift | 08745e149975b5feb844107a570428cd9a51e1a754ede2f0368ae3177667c949 |
| M | Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionRecallPreflight.swift | f7ba8bec024f71e39b073eb0cef767960fd81dc538923a975d8de267b7136a6a |
| M | Packages/KeyboardCore/Tests/KeyboardCoreTests/TypoCorrectionRecallPreflightTests.swift | edbf636f9b66c336189c213769d84fdb4425d440a4ac7b169a0e5cde47315780 |

manifest SHA-256 按上述 receipt 顺序，以每行 SHA-256  path 的换行内容
重新计算得到 35c2f06896dd263d7ec079fdef4e07e6fcb44215e8045c694689c5b4922b1130。
code worktree 当前仍是 detached baseline 加上这三项未提交修改。

## Static production-scope reconciliation

静态 diff 和引用检查得到以下边界：

1. ContextualTypoCorrectionSearchBudget.productionV2 仍为
   maximumFirstLayerStates: 12、maximumHypotheses: 8；本次只在
   pure-Core SearchPlan 增加 selected-group 入口，没有修改该 production
   budget。
2. Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+TypoCorrection.swift
   未变更，仍通过默认的 ContextualTypoCorrectionHypothesisEngine()
   进入既有 production 路径；其中既有 candidate query limit: 3 和
   resolved.count >= 4 约束也未变更。
3. Keyboard/Controllers/KeyboardViewController+TypoCorrection.swift、
   Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrection.swift 以及
   整个 Packages/RimeBridge 均无 diff。controller、Keyboard UI 和
   RimeBridge 中没有新增 TypoCorrectionRecallPreflight、
   selectedGroups 或 progressiveRecallPreflight 引用。
4. preflight 的 60/64 hypothesis budget、selected-group cap 和
   maxQueryAttempts 只存在于本次 pure-Core 内存合同；它们没有被接到
   controller、RimeBridge 或实际 RIME 查询。

因此 changed-file scope、production 12/8、controller 和 RimeBridge
边界均与 Authorization、executor evidence 和 Architecture review 一致。

## Executor receipt reconciliation

| Receipt | 本次 Quality 核对 |
|---|---|
| strict Swift format/lint | receipt 明确列出三个 changed Swift files；当前 manifest 正好包含两个 Core source 与一个 Core test，目标适配。未重跑。 |
| focused TypoCorrectionRecallPreflightTests | receipt 为 18/0；当前测试文件静态包含 18 个 test methods，且新增 selector、registry、ordinal fence 测试均在该文件。未重跑。 |
| full swift test --package-path Packages/KeyboardCore | receipt 为 1143/0；三个 changed files 均属于该 package 的 KeyboardCore source/test targets，target 适配。未重跑。 |
| receipt 中的 pre-existing warning | T9PinyinPathTests.swift warning 属于本次 manifest 之外的历史文件；本 review 不把它升级或归因给本次 diff。 |

这些是 executor-recorded results 的 scope/结构一致性核对，不是
reviewer 本次执行得到的 green result。按本 Authorization 明确禁止 test、
build、lint，Quality 不重新运行这些命令。

## Architecture residual AR-01～AR-04

| Residual | Bounded Quality disposition |
|---|---|
| AR-01 | **在 pure-Core preflight contract 内 addressed。** selector 使用 substitution-only structural signature，并把 selected-group cap 与 query-attempt cap 分开表示。selector/cap 是否适合 production、完整 coverage matrix 仍 open。 |
| AR-02 | **作为 preflight contract addressed。** 反转 hypothesis array 后仍按 structural order 得到相同选择；不推出 semantic recall、throughput、latency 或 180 ms 结论。 |
| AR-03 | **仅在 decision-level ledger contract 内 addressed。** operation ordinal、revision/epoch 和 cancelled/stale fence 有对应静态实现与 focused receipt；实际 async scheduler、真实 cancellation、每次 sidecar call 前后检查和 controller integration 仍 open。 |
| AR-04 | **仅在 operation-private pure-memory identity 内 addressed。** canonicalized corrected input 到 opaque GroupID 的 registry contract 有对应测试；与真实 sidecar accounting、diagnostics 或 runtime privacy boundary 的 binding 仍 open。 |

Quality 不把任何一项 residual 改写为 runtime 完成，也不把
Architecture 的 Conditional Accept 改写为无条件生产接受。

## Conditions and explicit non-claims

本 bounded verdict 只有在 exact baseline/tree、三文件 manifest、diff SHA、
executor receipt 和 Architecture scope 不变化时成立。任一 source、test、
package、scope 或 evidence 变化都需要重新绑定并重新 review。

本 review 明确不声称：

- runtime wiring、controller/Keyboard UI 变更、真实 RIME query、
  rime_ice provenance、candidate visibility/selection 或 sidecar delivery；
- production 12/8 之外的行为、60/64/8 在真实运行中的效果，或任何
  latency/throughput/paired-performance/180 ms 结果；
- QA-001、INT-003、Simulator/device Run、host text、clipboard 或候选内容
  采集；
- Product decision 之外的 Product authority、Quality Gate、Release Gate、
  TestFlight、Release、publication、commit、push、PR、merge 或 Assignment
  close。

Assignment 生命周期按用户要求保持 In Review。本 review 仅消费
Quality Authorization 并记录 bounded Quality verdict；没有关闭
Assignment，也没有授予任何后续 runtime、publication 或 Release 权限。
