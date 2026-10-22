# Assignment: TYPO-CORRECTION-002-INT003-QUERY-COST-MEASUREMENT-001

## 2026-10-11 current convergence

P1 bounded convergence and Human-accepted P2 are complete as evidence stages; this child remains Active pending separately authorized lifecycle disposition. See [P1 audit](../evidence/typo-correction-002-fixed-candidate-delivery-audit-001.md), [accepted P2](../product-decisions/TYPO-CORRECTION-002-INT003-QUERY-COST-P2-LOCAL-EVIDENCE-REQUIREMENTS-001.md), and [fixed final CI](../evidence/typo-correction-002-fixed-main-validation-001.md). Historical P1/P2-pending statements below are superseded only by these named outcomes; no Gate/Close.


Policy version: 1.0.0

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "TYPO-CORRECTION-002-INT003-QUERY-COST-MEASUREMENT-001",
  "record_type": "assignment",
  "title": "Decision-ready measurement of INT-003 query count, usefulness and runtime cost",
  "lifecycle": "closed",
  "current_phase": "Closed — 2026-10-22 在 LIFECYCLE-CLOSEOUT-BATCH-1B-001 下关闭；以下为此前阶段文字（历史）：P0 complete. P1 implementation commit 6606fbe received independent Architecture Pass with conditions; the separate CI-repair AUTH was consumed for bounded fixes at fe4c935. PR #184 squash-merged at 2026-09-27T13:59:18Z as 03f4d0cc68ce22df60e1f0545afe6ae3b27d30ab. Local CI-equivalent passed at fe4c935; only documentation changed from fe4c935 through PR head a572765. Hosted run 36322160611 passed all jobs at exact head a572765. Local lightweight checks and the pinned KOS v0.9.0 validator exited successfully with pre-existing legacy warnings. Open P1 conditions are coordinator-level assertions and real same-call RimeBridge setup/get_context/schema evidence. P2 sealed-journal censoring and independent Quality remain open; P2 AUTH remains Active/unconsumed pending source/review, installed-payload and Run-manifest freeze",
  "authorization_action": "plan_int003_query_cost_measurement",
  "updated_at": "2026-10-22",
  "revalidation_triggers": [
    "p1_source_manifest_sha256_changes_from_a98a722b03e2c66de61ab41ae30f59791ccb53a3b365f55a18e96d373732b395",
    "source_or_diagnostic_schema_changes",
    "measurement_environment_or_Human_operator_changes",
    "Product_query_budget_or_parent_scope_changes",
    "request_for_Swift_capture_Gate_or_Release"
  ],
  "authorization_refs": [
    "AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-MEASUREMENT-PLAN-001",
    "AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-MEASUREMENT-PLAN-M02-001",
    "AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-P1-INSTRUMENTATION-001",
    "AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-P1-CI-REMEDIATION-001",
    "AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-P2-SIM-CAPTURE-001"
  ],
  "parent_refs": ["TYPO-CORRECTION-002"],
  "evidence_refs": [
    "docs/evidence/typo-correction-002-int003-query-cost-assessment-2026-09-26.md",
    "docs/plans/typo-correction-002-int003-query-cost-measurement-001.md",
    "docs/evidence/typo-correction-002-int003-query-cost-measurement-plan-m02-2026-09-26.md",
    "docs/evidence/typo-correction-002-int003-query-cost-p1-arch-source-freeze-r1.json",
    "docs/evidence/typo-correction-002-int003-query-cost-p1-arch-source-freeze-r2.json",
    "docs/evidence/typo-correction-002-int003-query-cost-p1-arch-source-freeze-r3.json",
    "docs/reviews/typo-correction-002-int003-query-cost-p1-architecture-review-packet-r1.md",
    "docs/reviews/typo-correction-002-int003-query-cost-p1-architecture-review-r1.md",
    "docs/evidence/typo-correction-002-int003-query-cost-p1-architecture-review-r1-usage.md",
    "docs/reviews/typo-correction-002-int003-query-cost-p1-architecture-review-r2.md",
    "docs/evidence/typo-correction-002-int003-query-cost-p1-architecture-review-r2-usage.md",
    "docs/reviews/typo-correction-002-int003-query-cost-p1-architecture-review-r3.md",
    "docs/evidence/typo-correction-002-int003-query-cost-p1-architecture-review-r3-usage.md",
    "docs/reviews/typo-correction-002-int003-query-cost-p1-architecture-review-packet-r3.md",
    "docs/reviews/typo-correction-002-int003-query-cost-p1-architecture-review-packet-r2.md",
    "docs/evidence/typo-correction-002-int003-query-cost-p1-p2-authorization-post-merge-state-sync-2026-09-27.md",
    "docs/evidence/typo-correction-002-int003-query-cost-p1-implementation-001.md",
    "docs/reviews/typo-correction-002-int003-query-cost-p1-implementation-review-001.md",
    "docs/evidence/typo-correction-002-int003-query-cost-p1-implementation-review-001-usage.md",
    "docs/evidence/typo-correction-002-int003-query-cost-p1-ci-format-remediation-001.md",
    "docs/evidence/typo-correction-002-int003-query-cost-p1-ci-remediation-001.md",
    "docs/evidence/typo-correction-002-int003-query-cost-p1-implementation-post-merge-state-sync-2026-09-27.md"
  ],
  "responsibilities": {
    "domain_owner": "Input Intelligence Maintainer",
    "executor": "Codex current task for P1 after independent review and consumption; P2 executor bound in its separate AUTH before capture",
    "environment_executor": "Codex isolated worktree for P1; Codex designated Simulator operator for P2 after exact run/payload freeze and consumption",
    "human_dependency": "Human Product Owner / Product Lead authorized separate P1/P2 scopes; any physical-device performance round requires a later Human decision and operator",
    "architecture_reviewer": "Fresh independent Architecture & Knowledge Steward lane TYPO-CORRECTION-002-INT003-QUERY-COST-P1-ARCH-001 round 3 completed with Pass with conditions; implementation conditions are recorded in the review",
    "quality_reviewer": "Independent Test / Release lane after P1/P2 evidence, before any Quality claim",
    "product_approver": "Human Product Owner / Product Lead"
  }
}
```

## Current Status

> **Superseded for current status:** 本 Work Item 于 2026-10-22 在 [`LIFECYCLE-CLOSEOUT-BATCH-1B-001`](lifecycle-closeout-batch-1b-001.md) 下关闭，见文末 [Closeout (2026-10-22)](#closeout-2026-10-22)。
> 其后出现的 Active / “child stays Active” / “P2 AUTH Active/unconsumed” / Next 等叙述均属各自日期的历史，不是当前事实；本说明与文件顶部既有的 “2026-10-11 current convergence” 以及下方既有的 S-03 说明并存。Lifecycle 值在本改动进入 `main` 时生效。

> **Superseded for current status:** see the "2026-10-11 current convergence" at the top of this file and [`ACTIVE-WORK-STALE-FACTS-SYNC-001`](active-work-stale-facts-sync-001.md) (2026-10-21).
> The state table below (for example "P2 freeze pending", "P2 AUTH Active/unconsumed", IMPL-R1/R2 "remain open") predates that convergence and is historical narrative, not current truth. Per the convergence note, P1 bounded convergence and the Human-accepted P2 are complete as evidence stages, the child stays Active pending a separately authorized lifecycle disposition, and there is no Gate or Close. This note does not change the Lifecycle value.

| Field | Value |
|---|---|
| Lifecycle | **Closed** — P1 instrumentation is merged and independently Architecture-reviewed **Pass with conditions**; local CI-equivalent and hosted checks pass. Coordinator assertions, the real RimeBridge failure/readiness matrix, P2 journal censoring and independent Quality remain open; P2 freeze pending |
| Current phase | PR [#184](https://github.com/shchnk1103/Universe-Keyboard/pull/184) squash-merged at `03f4d0cc68ce22df60e1f0545afe6ae3b27d30ab` on 2026-09-27T13:59:18Z. The independent implementation review remains bound to `6606fbe`; the bounded CI repair `fe4c935` was separately authorized and consumed. Local CI-equivalent passed at `fe4c935` (strict format, KeyboardCore 1,170, RimeBridge 105, App + Keyboard 421, Keychain 1, Release build); only docs changed through head `a572765`. Hosted run [36322160611](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/36322160611) passed all jobs at exact head `a572765`. The pinned KOS v0.9.0 lightweight check passed with pre-existing legacy warnings. IMPL-R1 coordinator stage/discard/cancel/one-event assertions and IMPL-R2 real same-call setup/get_context/schema evidence remain open. No P2 capture has run; P2 AUTH remains unconsumed until exact source/review, App/Extension payload and Run manifest are frozen. A read-only `simctl` availability query failed because CoreSimulatorService was unavailable; no boot, install, diagnostics arm or input occurred. |
| Authority | [P0 AUTH](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-MEASUREMENT-PLAN-001.md) Consumed; [P1 AUTH](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-P1-INSTRUMENTATION-001.md) Consumed for its reviewed source scope; [CI remediation AUTH](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-P1-CI-REMEDIATION-001.md) separately Consumed for the bounded CI fix and Draft PR update; [P2 AUTH](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-P2-SIM-CAPTURE-001.md) Active/unconsumed, gated on exact payload and Run freeze |
| Publication / M-02 | [PR #179](https://github.com/shchnk1103/Universe-Keyboard/pull/179) merged `9838c092672dae60c63b34e4d9be6dffafc3869f`; [PR #180](https://github.com/shchnk1103/Universe-Keyboard/pull/180) merged `c3cc229619604131d6358bbc85f74e81f2874dc6`; [PR #181](https://github.com/shchnk1103/Universe-Keyboard/pull/181) merged `2b9b15ee2d1d903b3a948109b2c2217535bd5248` with separate P1/P2 AUTH records. P1 implementation [PR #184](https://github.com/shchnk1103/Universe-Keyboard/pull/184) merged as `03f4d0cc68ce22df60e1f0545afe6ae3b27d30ab`; this trigger's single non-recursive M-02 receipt is [here](../evidence/typo-correction-002-int003-query-cost-p1-implementation-post-merge-state-sync-2026-09-27.md). |
| Non-claims | No P2 Simulator capture, independent Quality conclusion, Product query-cost acceptance, numeric budget, Product/QA-001 Gate, parent Close, TestFlight/Release, ADR Accept or `RimeRuntimeProvenance` restore |
| Next | Resolve IMPL-R1/R2 under current Assignment authority, then rebind exact P1 source/review and installed payload/Run manifest before consuming P2 AUTH. Simulator access and a complete sealed-segment censoring receipt are still required. Product cost acceptance, budget, Gate and parent Close remain separate. Parent remains [Active](typo-correction-002.md) |

## Assignment authority and inputs

- **Assignment Authority / Product Approver:** Human Product Owner / Product Lead. **Decision source:** Human 2026-09-26 Asia/Shanghai instruction authorizing a new Assignment/AUTH and KOS continuation after PR #178.
- **Required P0 inputs (historical baseline):** [query-cost assessment](../evidence/typo-correction-002-int003-query-cost-assessment-2026-09-26.md), [Product residual](../product-decisions/TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001-PRODUCT-RESIDUAL.md), [`PERFORMANCE_BASELINE`](../PERFORMANCE_BASELINE.md), [`TYPO_CORRECTION`](../TYPO_CORRECTION.md), designated Simulator and physical-device [evidence profile](../kos/universe-keyboard-human-operated-evidence-profile.md), source at GitHub `main` `7b0025a10a3079731628e63a7ffd587af57608d6` when P0 assessment began.
- **P0 scope:** Source/evidence reading, measurement method and privacy boundary design, this Assignment/AUTH, parent and status navigation mirrors, docs-only validation, one draft PR. No executable instrumentation or device operation.
- **Future stage dependency:** P1 instrument/verify and P2 capture can enter Ready only after a distinct Product Assignment decision/AUTH binds exact source, allowed files, reviewer, environment executor, run manifest and evidence question. P2 physical evidence also needs the Human-operated profile's readiness review and one-round budget. A Product performance budget or residual disposition is a further decision after evidence.

## Entry, exit and stop

| Stage | Entry | Exit / handoff |
|---|---|---|
| P0 plan (complete) | Clean isolated worktree at verified GitHub main; Human authorized new Assignment/AUTH; prior raw/evidence identity already bound | [Plan](../plans/typo-correction-002-int003-query-cost-measurement-001.md), P0 AUTH and one M-02 closeout are published and merged |
| P1 instrumentation (consumed; merged; active Assignment) | P1 AUTH was consumed at `2026-09-27T18:01:36+08:00` after independent round-3 **Pass with conditions**, bound to baseline `1160ac6f…` and the 28-file manifest `a98a722b…`. Implementation commit `6606fbe` and the separately authorized CI repair `fe4c935` are published by squash merge PR #184 at `03f4d0c`. Local CI-equivalent passed at `fe4c935`; only docs changed through PR head `a572765`, whose hosted run [36322160611](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/36322160611) passed all jobs. The independent implementation review remains bound to `6606fbe`. IMPL-R1 coordinator assertions, IMPL-R2 real same-call setup/get_context/schema evidence, P2 raw-segment censoring and independent Quality remain open | Continue the assigned residuals; before P2, bind the exact source/review and installed payload/Run manifest, then consume the separate P2 AUTH |
| P2 controlled capture (active, unconsumed) | Separate P2 AUTH remains Active/unconsumed. PR #184 merge advanced the P1 tip; bind the exact source/review plus App/Extension hashes, designated Simulator/OS, schema/access/host/diagnostics state, Run ID, archive and stimulus, then consume before any Simulator operation. Current read-only device discovery could not connect to CoreSimulatorService; no simulator was booted or modified | Bounded synthetic cold/warm capture, exact build/environment/journal hashes, query count and facade-duration distributions, censoring analysis and independent Quality handoff |

Stop on `UNKNOWN` required responsibility for the current stage, source/plan drift, inability to distinguish an empty result from unavailable sidecar, any sensitive input/candidate/host logging, synchronous hot-path persistence, wrong device, missing installed-payload identity, Human round exhaustion, or scope expansion to budget change, Gate, release or parent Close. Record a bounded limitation rather than a guessed performance conclusion.

**Handoff target:** Architecture & Knowledge Steward for the independent P1 field review; then the Input Intelligence Maintainer for implementation. Independent Test / Release reviews measurement evidence, and the Human Product Owner / Product Lead retains Product decisions. The original query-density Product residual remains open.

## Closeout (2026-10-22)

- **决定来源：** Human Product Owner（Product Lead）于 2026-10-22 Asia/Shanghai 在 Coordinator 会话中的处置决定，记录于 [`lifecycle-closeout-batch-1-001.md`](lifecycle-closeout-batch-1-001.md) §Remediation round 1（`IMPL-R1…R5` 的处置）与 [`lifecycle-closeout-batch-1b-001.md`](lifecycle-closeout-batch-1b-001.md) §Remediation round 1（原 query-density Product 残项的处置）；D1（TYPO-CORRECTION-002 子项按批收尾）；D-1B-AUTH 确认方案。本 Close 在任务 `LIFECYCLE-CLOSEOUT-BATCH-1B-001` 下由 Executor 回到原文核实来源后写入，基线 `origin/main` `cd0b850cce7f22781c03fb9e66a4590be4357100`。
- **证据指针：** P1 PR [#184](https://github.com/shchnk1103/Universe-Keyboard/pull/184) `03f4d0cc68ce22df60e1f0545afe6ae3b27d30ab`（2026-09-27T13:59:18Z，`gh pr view 184`）；`docs/reviews/typo-correction-002-int003-query-cost-p1-implementation-review-001.md` §Residuals（第 165–175 行）；`docs/evidence/typo-correction-002-fixed-candidate-delivery-audit-001.md` 与其 P1 convergence 原件；P2 Product 决定 `docs/product-decisions/TYPO-CORRECTION-002-INT003-QUERY-COST-P2-LOCAL-EVIDENCE-REQUIREMENTS-001.md`；父 Gate `docs/product-decisions/TYPO-CORRECTION-002-PARENT-FINAL-PRODUCT-GATE-001.md` §残项台账（第 44–55 行）。

**残项处置表**（ID | owner | 处置 | 来源指针）：

| ID | owner | 处置 | 来源指针 |
|---|---|---|---|
| `IMPL-R1`（coordinator 级 stage / ready-empty / post-call discard / pre-call cancel / one-event 断言） | Input Intelligence Maintainer | `tech_debt:INT003-COORDINATOR-INDEPENDENT-ORACLE`（Human 决定；该条目仍 Open） | review-001 第 169 行；`docs/TECH_DEBT.md` 第 357 行起（Status 第 359 行）；父 Gate 第 49 行（`Q-R2-03`）；`…p1-convergence-original.txt` 第 40 行 |
| `IMPL-R2`（same-call setup / get_context / schema 矩阵） | RimeBridge owner + Test/Release | `tech_debt:INT003-RIME-FAILURE-BOUNDARY`（Human 决定；该条目仍 Open） | review-001 第 170 行；`docs/TECH_DEBT.md` 第 367 行起（Status 第 369 行）；父 Gate 第 50 行（`Q-R2-04`）；`…p1-convergence-original.txt` 第 41 行 |
| `IMPL-R3`（iOS Simulator / hosted CI lanes） | Test/Release | `fix`，已完成（Human 决定） | review-001 第 171 行；本文件 Current Status 表 “Current phase” 一行（基线 `cd0b850` 中为第 79 行）“Hosted run 36322160611 passed all jobs at exact head `a572765`”（`gh run view 36322160611`：success、`pull_request`、head `a5727659cbe4622a86c620f06b9a884c4d11a04c`，与 PR #184 head 相同）；`docs/evidence/typo-correction-002-fixed-main-validation-001.md` 第 10–20 行（Simulator lanes 与 Release，Executor-recorded，自称不是 hosted CI） |
| `IMPL-R4`（冻结安装 payload / Run / raw journal，censoring 报告） | Test/Release / P2 executor | `accept`（Human 决定） | review-001 第 172 行；P2 Product 决定 §“2026-10-11：接受本轮结论限制并结束限定P2收敛”（第 60 行起）；父 Gate 第 51 行（`P2-CURRENT-OBSERVER-BOUNDARY-001` / `QPA-R2-LEGACY-SYNTHETIC-NONREUSE-001`） |
| `IMPL-R5`（query budget / Gate 的 Product 决定） | Human Product Owner | `accept`（Human 决定） | review-001 第 173 行；父 Gate 第 52 行（`P2-PRODUCT-BUDGET-001` / `QPA-R2-PRODUCT-RESIDUAL-DECISION-001`） |
| `Q-R2-02`（433 发现 / 432 结果节点差异）、`Q-R2-05`（十文件候选为组合式覆盖） | Test / Release reviewer | `accept`（既有处置） | `…p1-convergence-original.txt` 第 39、42 行；父 Gate 第 48 行 |
| `P2-ADMISSION-R1-REPORT-001` | 原 Quality lane | `fix` 已完成（既有处置） | `docs/reviews/TYPO-CORRECTION-002-INT003-QUERY-COST-P2-REVIEW-DELIVERY-001-closeout-r2.md` 第 20 行 |
| `ROUTE-REVIEW-R1-E01`（Architecture AR-01 / Quality F1） | Test / Release | `fix` 已完成并独立 closure Pass（既有处置） | `…P2-ROUTE-SCOPE-REVIEW-001-residuals-r1.md` 顶部当前状态说明；`…P2-QUALITY-REMAINDER-001-closeout-r3.md` |
| **原 query-density Product 残项**（更宽的 `query_*` fan-out；2026-09-23 Product Capture 的 `fence_discarded=0`、高 `query_*` 574/574、旧 rapid-window 归因） | Human Product Lead | **`accept`，作为受限未知接受**（Human Product Owner（Product Lead）2026-10-22 Coordinator 会话决定；**不新建 tech_debt**）。边界：**不是性能 Pass**；更宽 fan-out 是否可接受**仍未建立**；只是作为受限未知被接受，与父 Gate 对整体性能未知的接受范围（Gate 第 55 行）一致 | `…STALE-CANCEL-PRODUCT-CAPTURE-001-PRODUCT-RESIDUAL.md` 第 84–91 行；`…QUERY-DENSITY-DIAGNOSTIC-CRITERION-001.md` “Remaining boundary” 与 “Non-claims”；`typo-correction-002-int003-query-cost-assessment-001.md` 第 12 行；本文件末段 Handoff；`lifecycle-closeout-batch-1b-001.md` §Remediation round 1。同一残项也出现在 `typo-correction-002-int003-stale-cancel-product-capture-001`（A18），**A18 的同一残项由后续批次另行落实**，本 Close 不改 A18 文件 |

**AUTH 现状与不可重放声明**（只读核对，本批次未修改任何 `docs/authorizations/` 文件）：

- `AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-P2-SIM-CAPTURE-001`：`docs/authorizations/AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-P2-SIM-CAPTURE-001.md` 第 9 行 `"status": "active"`，第 38 行 `"consumption_state": "unconsumed"`，第 52 行 “P2 is **Active / unconsumed**”。
- 声明：所属 Assignment 已 Closed；该 AUTH 不得再被消费或重放；任何后续采集或复核须由 Human 另行签发新的 AUTH。处置：`accept`（Human 2026-10-22 确认的 D-1B-AUTH）。`docs/TECH_DEBT.md` 的 `TD-014`（第 264 行）是同类问题（AUTH consumption_state 卫生）的既有登记，仅作引用，本 Close 不修改它，也不把它当作该 AUTH 的处置。

**非声称：** 不是 Release / Release-ready；不是性能 Pass，也不建立更宽 query fan-out 的可接受性；不改父任务 `TYPO-CORRECTION-002`（已 Closed，见 Gate 决定）；未关闭、削弱本表之外的任何残项（两个 tech_debt 条目仍 Open）；未关闭 A18；本 Close 先在本地提交，待 Reviewer 评审及 Human push / PR / merge 后在 `main` 生效。
