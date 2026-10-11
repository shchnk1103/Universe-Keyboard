# Architecture Review: TYPO-CORRECTION-002 runtime-preflight implementation

## Verdict

**Conditional Accept — 仅限 exact uncommitted pure-Core snapshot。**

在绑定的 baseline、tree 与 uncommitted diff 不变的前提下，本实现已在
纯 `KeyboardCore` 预检合同内对 AR-01～AR-04 给出可审计的实现和 focused
tests，因此可以进入同一 exact snapshot 的独立 Quality review。该 verdict
不等同于 runtime implementation、production authorization 或产品行为接受；
所有 controller/RIME、性能、QA、Product/Quality/Release 与 publication
边界仍然开放。

## Independent review boundary

| Item | Value |
|---|---|
| Reviewer | Independent Architecture & Knowledge Steward；与 implementation executor 分离 |
| Assignment | [`TYPO-CORRECTION-002-RUNTIME-PREFLIGHT-IMPLEMENTATION-001`](../assignments/typo-correction-002-runtime-preflight-implementation-001.md) |
| Authorization | [`AUTH-TYPO-CORRECTION-002-RUNTIME-PREFLIGHT-IMPLEMENTATION-ARCHITECTURE-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-PREFLIGHT-IMPLEMENTATION-ARCHITECTURE-001.md) |
| Code worktree | `/Users/doubleshy0n/.codex/worktrees/typo-correction-002-runtime-preflight-implementation-001/Universe Keyboard` |
| Parent docs worktree | `/private/tmp/universe-keyboard-typo-correction-002-parent-revalidation-003` |
| Exact baseline/tree | `4d1050f4b677494e06448cb40a83ef2da46d7b27` / `5f864a6f6f139810ed59c7e00ab6c33caad7e500` |
| Exact uncommitted diff SHA-256 | `8bb105c5381feb43fc41ec168fd239fd7c864cc0efa739cae3976beb685ebbab` |
| Review time | `2026-09-21T19:53:39+08:00` |

本 review 只读取了授权、实现证据、既有 runtime design Architecture review、
三个 changed files 及相关 production controller/RimeBridge path，并在
code worktree 独立重算了 diff。没有运行 build/test、没有访问网络、没有
执行 RIME/Simulator/device 操作，也没有 commit/push/PR/merge。

## Snapshot and boundary checks

1. `git diff --binary` 的 SHA-256 与 Authorization 绑定值完全一致。
   changed-file manifest 仅为：
   - `Packages/KeyboardCore/Sources/KeyboardCore/ContextualTypoCorrection.swift`
   - `Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionRecallPreflight.swift`
   - `Packages/KeyboardCore/Tests/KeyboardCoreTests/TypoCorrectionRecallPreflightTests.swift`
2. `KeyboardController+TypoCorrection.swift`、
   `KeyboardViewController+TypoCorrection.swift`、`TypoCorrection.swift` 与
   `RimeEngineImpl+CorrectionQuery.swift` 均无 diff。production controller
   仍通过 `ContextualTypoCorrectionHypothesisEngine()` 使用既有
   `productionV2` 的 `12` first-layer states / `8` hypotheses；既有每次
   correction query 的 `limit: 3` 与最多 `4` 个 resolved groups 也未改变。
3. `ContextualTypoCorrectionSearchPlan` 才使用 `60/64` 的
   `progressiveRecallPreflight` budget，且默认 `substitutionOnly`；production
   controller 没有引用 preflight plan、selector、ledger 或 preflight budget。
   因而这些 caps 是 preflight-only，不是对生产路径的隐式放宽。
4. selector 先把输入假设转换为只含两次 substitution 的 structural signature，
   再按 edit span、neighbor replacement order、位置和 corrected-input
   tie-break 排序；它不读取 hypotheses 原始顺序。`GroupRegistry` 只在一个
   operation 内做规范化输入到 opaque GroupID 的映射，GroupID 本身不含业务
   文本，ledger counters 只接收 GroupID/计数。`TypoCorrectionSuggestion` 的
   corrected input 仍仅作为后续纯内存预检数据保留，未进入 diagnostics、
   ledger accounting 或 RIME path。
5. `TypoCorrectionRecallPreflightOperation` 将 `compositionRevision`、
   `sessionEpoch` 与 operation-private `ordinal` 一并纳入相等性；ledger 在
   query finish 与 publish fence 处检查 current operation，并对 cancelled、
   stale revision/epoch/ordinal 结果 fail closed。该代码仍是同步 state
   machine，不是 async scheduler，也没有开始任何外部 query。

## AR-01～AR-04 disposition

| ID | 本次静态结论 | Disposition |
|---|---|---|
| AR-01 | `TypoCorrectionRecallPreflightCoverageSelector` 与 explicit selected-group / `maxQueryAttempts` contracts 已存在；selector 只接受 substitution-only 两编辑假设，且 focused tests 验证 canonical structural case 在 cap 内可选。 | **Addressed within bounded pure-Core slice.** 完整 coverage matrix 与该策略是否适合 production 仍 open；不作 production authorization。 |
| AR-02 | selector 按 structural signature 排序，而不是依赖 hypothesis 全局 rank/原始数组顺序；selection cap 与 query-attempt cap 分开表示，production `12/8` 未变。 | **Addressed as a preflight contract.** 不推出 semantic recall、throughput、latency 或 `180 ms` 结论；production performance suitability 仍 open。 |
| AR-03 | ledger 具备 operation ordinal、revision/epoch fence、cancelled fence、in-flight/batch fence；测试覆盖 query 已开始后的 stale/cancelled result 不得 resolved/publish。 | **Addressed at decision-level contract only.** 实际 async scheduler、每次 sidecar call 前后检查、真实 cancellation 与 controller integration 仍 open。 |
| AR-04 | operation-private registry 对 canonical corrected input 去重并分配 opaque GroupID；同 operation duplicate、different input 与新 operation identity 的 focused tests 已存在。 | **Addressed for in-memory preflight identity only.** 与真实 sidecar accounting、diagnostics 及 runtime privacy boundary 的 binding 仍 open。 |

这些 disposition 说明本次实现已回应既有 Architecture findings 的 pure-Core
contract 要求，但不把 residual 误写成已完成的 runtime 工作。

## Explicit non-claims

本 review 不声明或批准：

- runtime wiring、controller/Keyboard UI 改动、真实 RIME query、`rime_ice`
  provenance、candidate visibility/selection 或 sidecar delivery；
- production `12/8` 以外的行为、`60/64/8` 在真实运行中的效果、任何
  latency/throughput/paired-performance 或 `180 ms` 结论；
- QA-001、INT-003、Simulator/device Run、host text、clipboard 或候选内容
  采集；
- Product、Quality、Release Gate、TestFlight、Release、publication、
  commit、push、PR、merge 或 parent/Assignment Close。

Evidence 中的格式与 KeyboardCore 测试结果仅作为已记录 receipt 被读取；本次
Architecture review 没有重跑这些命令。任何 source baseline、diff hash、scope、
review role 或 evidence 变化都使本结论需要重新审查。

## Next authorization boundary

下一步仅可在同一 exact snapshot 上进行独立 Quality review。若要把 preflight
接入 controller、sidecar/RIME、diagnostics、性能测量或设备验证，必须另行取得
对应 Authorization 并重新绑定 source/package；本 review 不扩展这些权限。
