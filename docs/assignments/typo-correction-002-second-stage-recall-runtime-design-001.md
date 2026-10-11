# Assignment: TYPO-CORRECTION-002-SECOND-STAGE-RECALL-RUNTIME-DESIGN-001 — Bounded runtime design and contract-preflight

Policy version: 1.0.0

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Active` |
| **Phase** | 独立 Architecture `Conditional Accept` 已记录；AR-01～AR-04 阻止 runtime implementation。 |
| **Non-claims** | 不改 Swift、不接生产、不查询 RIME、不 capture、不发布；不是 QA-001、INT-003、性能或任何 Gate。 |
| **Next** | [`runtime-preflight implementation Assignment`](typo-correction-002-runtime-preflight-implementation-001.md) 已 Ready；它只可在新的 clean baseline worktree 中处理 pure-Core contracts。 |
| **Residuals** | AR-01 selector/caps、AR-02 rank-55 scheduling、AR-03 cancellation/publish fence、AR-04 runtime GroupID mapping 均为 `fix`；真实 RIME、candidate visibility、性能与 `contextual 7/8` 仍未解决。 |

---

## Authority

- **Assignment Authority:** Human Product Owner / Product Lead。
- **Decision Source / Date:** [`PD-TYPO-CORRECTION-002-SECOND-STAGE-RECALL-RUNTIME-DESIGN-001`](../product-decisions/TYPO-CORRECTION-002-SECOND-STAGE-RECALL-RUNTIME-DESIGN-001.md)，`2026-09-20 Asia/Shanghai`。
- **Product Approver:** Human Product Owner / Product Lead。
- **Parent Assignment:** [`TYPO-CORRECTION-002-PARENT-REVALIDATION-002`](typo-correction-002-parent-revalidation-002.md)。
- **Matching Authorization:** [`AUTH-TYPO-CORRECTION-002-SECOND-STAGE-RECALL-RUNTIME-DESIGN-001`](../authorizations/AUTH-TYPO-CORRECTION-002-SECOND-STAGE-RECALL-RUNTIME-DESIGN-001.md)。

## Scope

1. 在一个从 `origin/main` commit `4d1050f4b677494e06448cb40a83ef2da46d7b27` 建立的干净隔离 worktree 中，只读核对 production `12/8`、default-off `60/64/8` preflight、现有 Core contract 和 runtime controller 边界。
2. 写一份 docs-only runtime design package，给出 canonical group mapping、接受/provenance 语义、coverage-deficit trigger、可审查的 cap-selection method、`maxQueryAttempts`、取消与 stale-publish fence 的候选合同。
3. 为任何未来 runtime implementation 拆分必须独立授权的代码、真实 RIME、QA-001、paired-performance 与 publication evidence；不得将它们纳入本 Assignment。
4. 形成交独立 Architecture review 的 source links、unknowns、alternatives 与 stop conditions。

## Non-goals

- 不修改任何 Swift、测试、Xcode project、RIME/schema/vendor 或设置；不运行会改写 source 的 formatter。
- 不接 production controller、不改变 production `12/8`、不把 `60/64/8` 作为生产路径、也不实现 runtime scheduler。
- 不启动 sidecar query、Simulator/真机 capture、安装、部署、QA-001、INT-003 或性能测试；不创建 Run ID。
- 不读取 host text、clipboard、候选文本或 content-free journal 之外的数据；不使用 FakeCandidateProvider、旧 Ice、网络、本地/云端模型。
- 不执行 commit、push、PR、merge、TestFlight、Release、Product/Quality/Release Gate 或任何 Assignment Close。

## Assignment

- **Domain Owner:** Input Intelligence Maintainer。
- **Executor:** Current Codex task，限 matching docs-only Authorization。
- **Environment Executor:** Not Applicable；本阶段不操作 build、device 或 RIME environment。
- **Human Dependency:** Human Product Owner 已选择 B；任何 future runtime/code/capture scope 都需新决定。
- **Architecture Reviewer:** Independent Architecture & Knowledge Steward。
- **Quality Reviewer:** Not Applicable for this docs-only design slice；未来实现或可执行 evidence 另设 independent Quality review。

## Required Inputs

- [`second-stage decision request`](../plans/typo-correction-002-second-stage-recall-runtime-decision-request-2026-09-20.md)；
- [`ADR 0016`](../architecture/decisions/0016-progressive-contextual-recall-preflight.md)；
- [`recall remediation design`](../plans/typo-correction-002-recall-remediation-design-2026-09-19.md)；
- [`core contract Product decision`](../product-decisions/TYPO-CORRECTION-002-RECALL-REMEDIATION-CORE-CONTRACT-BOUNDED-DECISION-2026-09-20.md)；
- [`QA-001 07 residual decision`](../product-decisions/TYPO-CORRECTION-002-QA001-REVALIDATION-07-PRODUCT-RESIDUAL.md)；
- exact source baseline `4d1050f4b677494e06448cb40a83ef2da46d7b27`。

## Entry Criteria

- 上述 Product Decision 未被撤销；matching Authorization 为 `active` 且尚未消费。
- Executor 在消费前确认干净隔离 worktree、baseline commit 和不含 Swift 改动的范围。
- 所有未知项均以 unknown 记录，不可被假设为 RIME 或性能结论。

## Exit Criteria

- 设计包将 runtime group mapping、接受/provenance、trigger、cap-selection、cancellation 和 stale-publish fence 分开定义。
- 设计包明确指出哪些数值尚需 future evidence，不将 `60/64/8` 伪装成 production 决定。
- 独立 Architecture review 对 docs-only package 的边界、隐私与授权前沿作出结论。
- parent status mirror 仅在 authoritative Assignment/decision 可追溯时同步；无新 Run、无代码或 Gate 结论。

## Stop Conditions

- 需要修改 source、运行 RIME/设备、创建 Run ID、读取用户/候选内容，或触及 production runtime。
- source baseline、角色、Authorization scope 或 Product Decision 不一致。
- 设计只能通过无界搜索、FakeCandidateProvider、旧 Ice、host text、网络或模型才能成立。

## Handoff

- **Handoff Target:** Independent Architecture & Knowledge Steward。
- **Required Handoff Content:** exact baseline/worktree、设计包、每一项未知和待选 cap、隐私/取消边界、future authorization frontier、明确 non-claims。
- **Revalidation Trigger:** `origin/main` baseline、Product decision、runtime contract、privacy boundary、Authorization scope 或任何 future code/capture requirement 改变。
