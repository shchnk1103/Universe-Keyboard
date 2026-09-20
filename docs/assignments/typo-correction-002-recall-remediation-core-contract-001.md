# Assignment: TYPO-CORRECTION-002-RECALL-REMEDIATION-CORE-CONTRACT-001

Policy version: 1.0.0

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Active` |
| **Phase** | 纯 KeyboardCore 契约修复已完成；Architecture/Quality 均为 Pass with conditions，Product bounded Accept 已记录；runtime mapping 仍开放。 |
| **Non-claims** | 不代表生产接线、真实 RIME、设备 Run、180 ms、QA-001、INT-003、Product/Quality/Release Gate 或 parent Close。 |
| **Next** | 选择并另立 publication 或 runtime lane Authorization；当前不 commit/push，不进入生产接线。 |
| **Residuals** | runtime canonical group mapping/accounting 仍为 P1；focused pure-Core coverage 不等于 async runtime coverage；Quality cache limitation 与 contextual 7/8 `UNKNOWN` 继续保留。 |

## Authority

- **Assignment Authority:** Human Product Owner / Product Lead, current Codex task, `2026-09-20 Asia/Shanghai`。
- **Decision Source / Date:** [`core contract bounded Product decision`](../product-decisions/TYPO-CORRECTION-002-RECALL-REMEDIATION-CORE-CONTRACT-BOUNDED-DECISION-2026-09-20.md)。
- **Parent Assignment:** [`TYPO-CORRECTION-002-RECALL-REMEDIATION-IMPLEMENTATION-PREFLIGHT-001`](typo-correction-002-recall-remediation-implementation-preflight-001.md)。
- **Matching Authorization:** [`AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-CORE-CONTRACT-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-CORE-CONTRACT-001.md)。

## Boundary

### Scope

1. 将 `ContextualTypoCorrectionSearchPlan` 的 preflight 默认入口改为 fail-closed 的 substitution-only；生产 `ContextualTypoCorrectionHypothesisEngine` 的 `productionV2` 与 controller 不变。
2. 为 `TypoCorrectionRecallPreflightLedger` 引入不含原始输入的稳定 group identity，并让 `nResolvedGroups` 只统计新的、被接受的 group；重复 group 不重复计数。
3. 补充独立的 batch cap、resolved-group cap、session epoch mismatch 与默认 policy focused tests。
4. 仅运行 strict Swift formatting、纯 `swift test --package-path Packages/KeyboardCore`，并将 cache 指向可写临时目录；记录新的 docs-only remediation evidence。

### Non-goals

- 不修改 `Keyboard/`、Main App、Keyboard Extension controller、RimeBridge、RIME schema/vendor 或 host-text/marked-text 路径。
- 不改变生产 `12/8` 搜索预算，不把 `60/64/8` 接入生产，不引入本地/云端模型。
- 不部署、查询或伪造 RIME；不使用 FakeCandidateProvider、旧 Ice 目录、clipboard、网络或合成 fixture。
- 不做 Simulator/真机 capture，不创建 Run ID，不做 QA-001、INT-003、paired performance 或 180 ms 结论。
- 不执行 commit、push、PR、merge、TestFlight、Release 或关闭 parent/既有 preflight Assignment。

## Required tests and evidence

- 默认 preflight plan 只生成 substitution edit；生产 engine 的 `.all` 默认行为保持原样并由既有测试覆盖。
- 同一 group identity 的重复成功 query 不增加 `nResolvedGroups`，新 group 才增加；candidate response 计数仍独立。
- `maximumBatchSize` 小于 `maxQueryAttempts` 时，batch cap 单独阻止同批下一次 query，并允许后续 batch 继续。
- `maximumResolvedGroups` 单独阻止新 group；session epoch 单独变化时旧 query 结果不得 resolve/publish。
- 可写 cache 环境下完整 KeyboardCore 测试、focused tests、strict lint 和 `git diff --check` 结果均写入 evidence。

## Gates and handoff

- **Entry:** source/package identity 与本 Authorization 一致；首次代码变更前消费 Authorization。
- **Exit:** 三个 Architecture 条件有 focused code/test/evidence 处置；Quality cache limitation 有新鲜可复核结果或明确保留；没有生产路径变更。
- **Handoff:** Independent Architecture review → Independent Quality review；之后再决定是否申请 publication 或 production implementation Authorization。
- **Stop:** 需要触及生产 controller/RIME/设备/性能、无法保持 group identity privacy boundary、测试失败、或 source/package identity 漂移。

## History

- `2026-09-20 Asia/Shanghai`：Product bounded Accept 后建立本 residual-remediation Assignment；尚未开始代码变更。
- `2026-09-20 Asia/Shanghai`：在 `d0df9a6342d8209b5aa7f9826541d0b430b9da04` / tree `27ae44bec1b157e391ef1e0b859db3a068e21ba8` / Package.swift SHA-256 `9ebf33313b560b83634a074dd675211aee9cec13b1d879e9cd4f35fbb94aa764` 上消费 residual-remediation Authorization；开始纯 Core 契约修复。
- `2026-09-20 Asia/Shanghai`：完成 remediation；focused `14/14`、完整 KeyboardCore `1143/1143`，记录于 [`core contract evidence`](../evidence/typo-correction-002-recall-remediation-core-contract-001.md)；等待新的独立 Architecture/Quality review。
- `2026-09-20 Asia/Shanghai`：新的 Architecture 与 Quality 均完成 `Pass with conditions`；Product bounded Accept 记录于 [`core contract decision`](../product-decisions/TYPO-CORRECTION-002-RECALL-REMEDIATION-CORE-CONTRACT-BOUNDED-DECISION-2026-09-20.md)。runtime canonical group mapping 仍为开放 P1。
