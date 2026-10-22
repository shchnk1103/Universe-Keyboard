# Assignment: TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-001 — Controller/sidecar runtime integration

Policy version: 1.0.0

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-001",
  "record_type": "assignment",
  "title": "Controller and sidecar second-stage recall runtime integration",
  "lifecycle": "closed",
  "current_phase": "Closed — 2026-10-22 在 LIFECYCLE-CLOSEOUT-BATCH-1C-001 下关闭；以下为此前阶段文字（历史）：Product accepted bounded residuals of the uncommitted snapshot; publication and Close remain unauthorized",
  "authorization_action": "implement_controller_sidecar_second_stage_recall_runtime",
  "updated_at": "2026-10-22",
  "revalidation_triggers": [
    "source_or_checkpoint_identity_changed",
    "coverage_predicate_or_budget_changed",
    "adapter_api_or_owner_boundary_changed",
    "allowed_path_or_test_scope_changed",
    "diagnostics_or_privacy_scope_changed",
    "authorization_not_confirmed_live",
    "authority_revoked"
  ],
  "authorization_refs": [
    "AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-001",
    "AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-ARCHITECTURE-001",
    "AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-QUALITY-001",
    "AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-PRODUCT-RESIDUAL-001"
  ],
  "parent_refs": [
    "TYPO-CORRECTION-002",
    "TYPO-CORRECTION-002-RUNTIME-INTEGRATION-DESIGN-001",
    "PD-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-001",
    "PD-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-RESIDUAL-001"
  ],
  "responsibilities": {
    "domain_owner": "Input Intelligence Maintainer",
    "executor": "Grok",
    "environment_executor": "Grok for new implementation worktree copy, local Swift format, KeyboardCore, RimeBridgeTests and App+Keyboard tests; no device, RIME deploy or capture",
    "human_dependency": "Human Product Owner confirms AUTH is live before implementation; later independent Architecture and Quality reviews",
    "architecture_reviewer": "Independent Architecture and Knowledge Steward",
    "quality_reviewer": "Independent Quality, Performance and Release Maintainer",
    "product_approver": "Human Product Owner acting as Product Lead"
  }
}
```

## Current Status

> **Superseded for current status:** 本 Work Item 于 2026-10-22 在 [`LIFECYCLE-CLOSEOUT-BATCH-1C-001`](lifecycle-closeout-batch-1c-001.md) 下关闭，见文末 [Closeout (2026-10-22)](#closeout-2026-10-22)。
> Text below is historical narrative：其后出现的 `Reviewed` Lifecycle、Phase / Next / Residuals 与 Non-claims 的叙述均属各自日期的历史，不是当前事实；本说明与下方既有的 S-03 说明并存，不覆盖它们。Lifecycle 值在本改动进入 `main` 时生效。

> **Superseded for current status:** see [`ACTIVE-WORK-STALE-FACTS-SYNC-001`](active-work-stale-facts-sync-001.md) (2026-10-21).
> GitHub PR [#144](https://github.com/shchnk1103/Universe-Keyboard/pull/144) was squash-merged as `e1b28aebe8f6b2f2a8587db1e525e332aa9bfe00` on `2026-09-22T10:19:31Z` (181 files; read-only `gh pr view 144`). Text below such as "frozen uncommitted snapshot", "No ... commit, push, PR, merge" and "Publication ... remain separately unauthorized" is historical narrative as of 2026-09-21, not current truth.
> PR #144 adds product files for the components listed under "What landed" in the [evidence](../evidence/typo-correction-002-runtime-integration-implementation-001.md) (for example `TypoCorrectionRecallCoordinator.swift`, `TypoCorrectionSidecarOwner.swift`). Whether the merged tree contains the frozen snapshot byte-for-byte is **UNKNOWN**: that snapshot was never committed (its recorded base `4d1050f` is the earlier `main` commit from PR #143), and its checkpoint diff SHA-256 `8bb105c5…` is not comparable with PR #144's cumulative diff. Lifecycle `Reviewed` and all residuals are not changed or closed by this note.

| Field | Value |
|---|---|
| **Lifecycle** | `Closed`（2026-10-22 起，见文末 Closeout；此前为 `Reviewed`） |
| **Phase** | Product accepted Architecture Conditional Accept, Quality Pass with conditions, and named bounded residuals of the frozen uncommitted snapshot. |
| **Non-claims** | No Quality/Product/Release Gate, commit, push, PR, merge, capture, QA-001, INT-003, paired performance, parent Close or this Assignment Close. |
| **Next** | Codex receives [`Grok→Codex handoff`](../evidence/typo-correction-002-grok-to-codex-runtime-integration-handoff-2026-09-21.md). Publication and further source work remain separately unauthorized. |
| **Residuals** | Accepted by [`PD residual`](../product-decisions/TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-RESIDUAL-001.md). F-01/F-02/F-03 gaps, Q-01, identity-recipe and F-04 remain named conditions. Real RIME / QA-001 remain `UNKNOWN`. |

---

## Authority

- **Assignment Authority:** Human Product Owner / Product Lead.
- **Decision Source / Date:** [`PD-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-001`](../product-decisions/TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-001.md), `2026-09-21 Asia/Shanghai`.
- **Product Approver:** Human Product Owner / Product Lead.
- **Parent Assignment:** [`TYPO-CORRECTION-002`](typo-correction-002.md).
- **Predecessor:** [`TYPO-CORRECTION-002-RUNTIME-INTEGRATION-DESIGN-001`](typo-correction-002-runtime-integration-design-001.md) (`Reviewed`, Conditional Accept).
- **Reviewed design:** [`runtime integration design`](../plans/typo-correction-002-runtime-integration-design-2026-09-21.md), SHA-256 `b91e11cf327f9ad3e5974ff0e5b4a53fe755920356927efffed12cfe9c28a848`.
- **Architecture re-review:** [`re-review`](../reviews/typo-correction-002-runtime-integration-design-architecture-rereview-2026-09-21.md).
- **Handoff:** [`Codex to Grok handoff`](../evidence/typo-correction-002-codex-to-grok-runtime-integration-handoff-2026-09-21.md).
- **Matching Authorization:** [`AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-001.md).

## KOS v0.8.0 optional-contract selection

| Contract | Selection | Boundary and owner source |
|---|---|---|
| E-01 claim-bound observation | Not applicable | This slice produces implementation and local test evidence, not a human-operated observation claim. |
| A-01 / B-01 authorization chain and briefing | Adopted | Current slice is AUTH-live confirmation then bounded implementation. Next gated slices are independent Architecture review, Quality review, real-RIME Run, QA-001, paired performance and publication. |
| P-01 publication facts | Not applicable | No commit, push, PR or hosted publication. |
| D-01 final-documentation receipt | Not applicable | No final documentation handoff in this slice. |

### Authorization frontier (A-01 / B-01)

| Slice | Status | Action / target / boundary | Authority source |
|---|---|---|---|
| Current authorized slice | Consumed | Bounded implementation snapshot recorded; AUTH consumed | [`AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-001.md) |
| Architecture review slice | Consumed | Independent Architecture Conditional Accept of the uncommitted snapshot | [`AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-ARCHITECTURE-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-ARCHITECTURE-001.md) |
| Quality review slice | Consumed | Independent Quality Pass with conditions of the same snapshot | [`AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-QUALITY-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-QUALITY-001.md) |
| Next independently gated slice | Not authorized | Product Lead residual decision; publication / Gate / Close remain excluded | New Product Authorization |
| Environment or external slice | Not applicable | No device, RIME deploy, Simulator capture or new Run ID | Product Decision exclusions |

## Boundary

### Scope

After AUTH is confirmed live, Grok may:

1. Create a new implementation worktree from baseline
   `4d1050f4b677494e06448cb40a83ef2da46d7b27` / tree
   `5f864a6f6f139810ed59c7e00ab6c33caad7e500`. Copy the exact uncommitted
   pure-Core snapshot whose diff SHA-256 is
   `8bb105c5381feb43fc41ec168fd239fd7c864cc0efa739cae3976beb685ebbab`. Leave
   the original preflight worktree untouched.
2. Implement one MainActor recall-operation lifecycle owned by
   `KeyboardViewController`: pending debounce, operation token, `recallEpoch`,
   cancellation, yielded one-query turns, fences and candidate-bar refresh.
3. Implement one `TypoCorrectionSidecarOwner` adapter over the already-installed
   query facade for default `RimeEngineImpl`, MainActor-responsive and
   thread-affine routes.
4. Implement stage-one / stage-two in-memory material under one operation
   identity, the pinned coverage-deficit predicate, the pinned 8/8/3/4 budgets,
   and exactly one conditional Core apply that joins, deduplicates, suppresses,
   ranks and writes `state.typoCorrection` once.
5. Add focused KeyboardCore, RimeBridge and App/Keyboard tests proving
   invalidate-first hooks, yielded turns, pre-query and post-return fences,
   adapter no-bypass, display no-op on stale/empty/budget-stop, and the
   coverage-deficit abstain path.
6. Run strict Swift formatting on changed Swift files and the CI-equivalent
   suite required by the actual changed paths. Record implementation evidence
   for independent Architecture review.

### Non-goals

- Do not reset, clean, overwrite or commit the original pure-Core checkpoint.
- Do not change production first-stage `12/8`, and do not make `60/64` the
  always-on first-stage path.
- Do not add an operation receipt, change diagnostic retention, or reuse the
  DEBUG decision trace.
- Do not call `TextInputClient`, `insertText`, `setMarkedText`, pasteboard,
  live RIME candidate selection or direct candidate-bar mutation.
- Do not use `Task.detached`, a second RIME session, a raw-engine cast, a
  parallel query lane, `FakeCandidateProvider`, an old Ice directory, host
  text or a model/network substitute.
- Do not run Simulator/device capture, create a new Run ID, retry QA-001,
  run INT-003, or claim paired performance / `180 ms`.
- Do not commit, push, open a PR, merge, TestFlight, Release, close a Gate or
  close this or the parent Assignment.

### Required Inputs

- Reviewed design SHA-256 `b91e11cf327f9ad3e5974ff0e5b4a53fe755920356927efffed12cfe9c28a848`.
- Architecture re-review Conditional Accept and F-01/F-02/F-03 implementation conditions.
- Exact pure-Core checkpoint identities above, re-verified immediately before the copy.
- [`PD-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-001`](../product-decisions/TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-001.md).
- ADR 0004, ADR 0016, `TYPO_CORRECTION.md`, input-pipeline / marked-text architecture.

## Assignment

- **Domain Owner:** Input Intelligence Maintainer.
- **Executor:** Grok.
- **Environment Executor:** Grok — new implementation worktree copy and local Swift/KeyboardCore/RimeBridge/App+Keyboard toolchain only; no device or RIME environment operations.
- **Human Dependency:** Human Product Owner confirms AUTH is live before implementation starts; later independent Architecture and Quality reviews are separate Human-authorized slices.
- **Architecture Reviewer:** Independent Architecture & Knowledge Steward.
- **Quality Reviewer:** Independent Quality, Performance & Release Maintainer.
- **Product Approver:** Human Product Owner / Product Lead.
- **Handoff Target:** Independent Architecture review of the exact implementation snapshot, then Independent Quality review.

## Pinned contract

### Coverage-deficit predicate

Stage two may start only when all of the following hold:

1. The existing letter / Chinese / minimum-length eligibility still holds.
2. The same recall operation remains current after stage one.
3. Stage one produced zero accepted display-eligible corrections.
4. The structural selector returns at least one group not already accounted
   for by stage one.
5. Remaining started-query-attempt budget is greater than zero.

Otherwise the coordinator abstains from sidecar queries and uses the same
conditional-apply boundary for stage-one material only.

### Budgets

| Budget | Production value for this slice |
|---|---|
| Selected groups | `8` |
| Started query attempts | `8` |
| Per-query candidate limit | `3` |
| Accepted display results | `4` |

These are this lane's runtime caps. They do not change production `12/8`.

### Runtime fences

Preserve the reviewed design contract:

1. `KeyboardViewController` owns one MainActor recall-operation lifecycle.
2. Increment `recallEpoch` before composition mutation, page/mode change,
   visibility teardown, engine rebind/recovery or correction disable.
3. One synchronous sidecar query occupies one scheduler turn. After return,
   schedule at most one later attempt with
   `RunLoop.main.perform(inModes: [.default])`.
4. Fence before each query, after each return, before final Core apply and
   before candidate-bar refresh. Stale, cancelled, empty or budget-stop
   outcomes are display no-ops and must not start a later query.
5. Sidecar results are display-only. Existing user selection through Core
   remains the sole host-commit path.

## Gates

### Entry Criteria

- This Assignment has no `UNKNOWN` field.
- Human Product Owner has confirmed the matching Authorization is live.
- The original pure-Core checkpoint identities still match.
- A new implementation worktree can be created without modifying the original
  checkpoint worktree.

### Exit Criteria

- The copied snapshot identities match before and after the copy.
- Changed Swift files pass `swift-format lint --strict`.
- Focused and path-required KeyboardCore, RimeBridgeTests and App+Keyboard
  tests pass, or failures are retained as failures.
- Evidence names the adapter, fences, material apply, predicate, budgets and
  explicit non-claims.
- Independent Architecture can review the exact snapshot. This Assignment
  does not itself close that review.

### Stop Conditions

- AUTH is not confirmed live, is revoked, or the checkpoint identity drifts.
- A required change exceeds allowed paths or needs a second composition,
  commit, raw-engine, detached or parallel query path.
- Diagnostics/privacy scope, `60/64` always-on first-stage wiring, real-RIME
  capture, QA-001, INT-003, performance claims, commit or publication become
  necessary to continue.
- Tests require a live RIME result, FakeCandidateProvider-as-real-RIME, or
  host/clipboard content.

### Revalidation Trigger

Checkpoint identity, predicate, budgets, adapter API, allowed paths,
diagnostics scope, AUTH liveness, reviewer independence or Product Decision
revocation.

## Handoff

- **Required Handoff Content:** new worktree path, verified checkpoint
  identities, changed-file inventory, adapter/fence/apply evidence, test and
  format results, residual dispositions and non-claims.
- **Handoff Target:** Independent Architecture review, then Independent
  Quality review, then Product Lead.

## Closeout (2026-10-22)

- **决定来源：** Human Product Owner（Product Lead）于 2026-10-22 Asia/Shanghai 在 Coordinator 会话中批准 D1（TYPO-CORRECTION-002 子项按批收尾）与 D7，并同意先把 hardening 链四项做成批次 1c（见 [`lifecycle-closeout-batch-1c-001.md`](lifecycle-closeout-batch-1c-001.md) §Authority）；F-04 新建 tech_debt 与 D-1C-AUTH 均已由 Human 在同一会话确认（同文件 Current Status 的 “Human 确认状态” 行）。本 Close 在任务 `LIFECYCLE-CLOSEOUT-BATCH-1C-001` 下由 Executor 回到原文核实来源后写入；残项由 Executor 自己从原文枚举，Assignment 中的“残项与处置线索”表仅作线索。
- **关闭依据（Executor 核实）：** Product 决定 [`PD-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-RESIDUAL-001`](../product-decisions/TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-RESIDUAL-001.md) 接受有界残项（`PD-I L32–L53`）；GitHub PR [#144](https://github.com/shchnk1103/Universe-Keyboard/pull/144) 于 `2026-09-22T10:19:31Z` squash-merge 为 `e1b28aebe8f6b2f2a8587db1e525e332aa9bfe00`（`gh pr view 144`：state MERGED、headRefName `codex/typo-correction-002-runtime-hardening-blockers`；`git log -1 e1b28ae` 提交时间 `2026-09-22T18:19:30+08:00`）；其后继 H3/H4 修补并关闭了其中的多数缺口（见下表）。
- **来源简称**（下表“来源指针”中的 `简称 L行号` 均指这些文件的行号，行号取自基线 `e828a9969f6d41414d8bb991da9f7202fe056636` 的文件内容；本 Assignment 自身在顶部插入了 S-03 说明，其引用的 `H1…H4` 行号均指基线行号）：
  - `H2` = `docs/assignments/typo-correction-002-runtime-integration-implementation-001.md`
  - `PD-I0` = `docs/product-decisions/TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-001.md`
  - `DRR` = `docs/reviews/typo-correction-002-runtime-integration-design-architecture-rereview-2026-09-21.md`
  - `IAR` = `docs/reviews/typo-correction-002-runtime-integration-implementation-architecture-review-2026-09-21.md`
  - `IQR` = `docs/reviews/typo-correction-002-runtime-integration-implementation-quality-review-2026-09-21.md`
  - `PD-I` = `docs/product-decisions/TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-RESIDUAL-001.md`
  - `HAR` = `docs/reviews/typo-correction-002-runtime-integration-hardening-architecture-review-2026-09-22.md`
  - `HEV` = `docs/evidence/typo-correction-002-runtime-integration-hardening-001.md`
  - `BAR` = `docs/reviews/typo-correction-002-runtime-integration-hardening-blocker-remediation-architecture-review-2026-09-22.md`
  - `BQR` = `docs/reviews/typo-correction-002-runtime-integration-hardening-blocker-remediation-quality-review-2026-09-22.md`
  - `BEV` = `docs/evidence/typo-correction-002-runtime-integration-hardening-blocker-remediation-001.md`
  - `PD-B` = `docs/product-decisions/TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-RESIDUAL-001.md`
  - `FSQ` = `docs/reviews/typo-correction-002-runtime-integration-hardening-blocker-remediation-pr144-final-sha-quality-review-2026-09-22.md`
  - `GATE` = `docs/product-decisions/TYPO-CORRECTION-002-PARENT-FINAL-PRODUCT-GATE-001.md`
  - `PERF` = `docs/product-decisions/TYPO-CORRECTION-002-PARENT-PERFORMANCE-SCOPE-PROPOSAL-001.md`
  - `TD` = `docs/TECH_DEBT.md`

**残项处置表**（ID | owner | 处置 | 来源指针）。残项由 Executor 从 `H2 L60`、`IAR L211–L223`、`IQR L124–L146`、`PD-I L32–L53` 原文枚举：`H2-R1…R7` 是 Product 决定命名的六条（第 6 条拆为 F-04 与 UNKNOWN 两行），`H2-R8…R13` 是评审表中 Product 决定未逐条点名、但评审给出了处置的行，`H2-N1`、`H2-N2` 是评审里的说明性语句：

| ID | owner | 处置 | 来源指针 |
|---|---|---|---|
| `H2-R1` F-01 invalidate-first 缺口：`handleTogglePage`、字母热路径 `refreshTypoCorrectionSuggestions`、canary/P3D1 安装、空 composition 的模式切换未先 bump `recallEpoch`；page 变化靠 fence 比较 fail-closed；`RunLoop.main.perform(inModes: [.default])` 未测 | Input Intelligence Maintainer / Keyboard UI | `accept`（Product 决定）；其后 page 切换、空 composition 模式切换、canary/P3D1 已由 H3/H4 修复并经 Architecture 关闭；`RunLoop.main.perform` 调度本身仍无测试（无来源记录补测，保持接受） | `PD-I L34–L38`；`IAR L72–L98`、`L215`；`IQR L126–L131`；`HEV L87–L88`；`HAR L45–L46`；`BAR L32`、`L38–L40`；`FSQ L77` |
| `H2-R2` F-02 三路 adapter：default wrap 且 epoch 为 `nil` 被接受；MainActor-responsive / thread-affine no-bypass 未证；dual-gate / canary / P3D1 仍装 `CandidateProviderTypoCorrectionQuery`；default 安装后 responsive rebuild 不更新 `typoCorrectionCandidateQuery`；`makeTypoCorrectionSidecarOwner()` 未被 Bootstrap 调用 | RimeBridge Maintainer | `accept`（Product 决定）；其后三路 adapter/no-bypass 经 H4 Architecture 在源码层 Closed；`CandidateProviderTypoCorrectionQuery` 外观由 H4 的 PD 另行 `accept`，不重分类为真实 RIME | `PD-I L39–L41`；`IAR L100–L131`、`L216`；`IQR L132–L134`；`HAR L51`、`L61`；`BAR L34`、`L45–L49`；`PD-B L31–L33`；`FSQ L79` |
| `H2-R3` F-03 第二个 Core writer 与 empty/budget-stop：recall 路径 `applyTypoCorrectionRecallMaterial` 被接受；热路径 `refreshTypoCorrectionSuggestions` 仍写 `state.typoCorrection`；empty/budget-stop 不是已证明的 display no-op | Input Intelligence Maintainer | `accept`（Product 决定）；其后 H3 使 empty/budget-stop 成为源码层结构性 no-op（Architecture 标 Pass with conditions，测试当时未由其重跑），H4 关闭热路径唯一 writer 证明（Architecture Closed） | `PD-I L42–L45`；`IAR L133–L161`、`L217`；`IQR L136–L137`；`HEV L84–L86`、`L89–L91`；`HAR L48–L50`；`BAR L34`、`L45–L49`；`FSQ L79` |
| `H2-R4` Q-01：`TypoCorrectionRecallCoordinator.swift:132` 的 `#ActorIsolatedCall` 警告；本地 TEST SUCCEEDED 不证明 hosted CI 同样放行 | Input Intelligence Maintainer / Quality | `accept`（Product 决定）。最终状态见下方“Q-01 最终状态” | `PD-I L46–L48`；`IQR L114–L120`；`HEV L82–L83`、`L97–L98`；`HAR L44`；`BQR L63–L65`；`PD-B L34–L36`；`FSQ L37` |
| `H2-R5` identity-recipe：AUTH 全内容哈希 `3cf0d23c…` 未复现，独立拼接为 `4b701835…`；HEAD / tree / tracked diff 为约束性身份 | Architecture and Knowledge Steward | `accept`（Product 决定）；`3cf0d23c…` 至今未复现（`UNKNOWN`），后继 H3 的 Architecture 复核用新的 `diff -u` 配方复现了 hardening-delta 并记 “no identity-recipe residual” | `PD-I L49–L51`；`IAR L39`、`L47–L52`、`L221`；`IQR L72`、`L75`、`L145`；`HAR L35–L38` |
| `H2-R6` F-04 diagnostics（operation-receipt 与 DEBUG decision trace 仍在 `applyRankedTypoCorrection`） | Input Intelligence Maintainer（`HAR L64`） | `tech_debt:TYPO-CORRECTION-002-F04-OPERATION-RECEIPT-DIAGNOSTICS`（Human 2026-10-22 确认，本批次新建，当前 Open） | `PD-I L52`；`IAR L183–L191`、`L220`；`IQR L144`；`PD-I0 L24–L25`；`TD`（文末 F-04 条目） |
| `H2-R7` 真实 RIME、QA-001、INT-003、paired performance、180 ms 保持 `UNKNOWN` | Human Product Lead | `accept`（父 Gate 台账覆盖，逐项对照见下） | `PD-I L52–L53`；`IAR L223`；`IQR L146`；`GATE L42`、`L49–L55`、`L59` |
| `H2-R8` F-01 correction-disable 无独立关闭挂钩（实验 edits 来自 settings，不 bump epoch）与空 composition 切模式 | Input Intelligence Maintainer | `accept`：Quality 写明“未覆盖但可接受为 bounded residual”，Product 决定接受该 Quality 结论；该缺口后来是否被修复**无来源记录**（`UNKNOWN`），保持接受 | `IAR L88`、`L215`；`IQR L130`；`PD-I L13–L15`、`L25`。本条不在 `PD-I L34–L37` 的点名列表中，见报告“判断点” |
| `H2-R9` F-01 visibility / default engine / dual-gate rebind：源码挂钩存在，入口无 UIKit 级测试 | Keyboard UI | `accept`：Quality “源码挂钩存在；测试未覆盖入口。不阻断本结论” | `IAR L84–L86`；`IQR L131`；`PD-I L13–L15`、`L25` |
| `H2-R10` coverage-deficit 谓词与字母/中文/最短长度的合取未测 | Input Intelligence Maintainer | `accept`：Quality “未覆盖但可接受为 bounded residual” | `IAR L165–L172`；`IQR L140`；`PD-I L13–L15`、`L25` |
| `H2-R11` KeyboardTests 仅有 8/8/3/4 常量断言，不构成 F-01 入口合同 | Quality | `accept`：Quality “未覆盖 F-01；可接受为 bounded residual” | `IQR L141–L142`；`PD-I L13–L15`、`L25` |
| `H2-R12` Stage one 不计入 8 次 started-query-attempt（只受 accepted-display 4 与假设队列约束）；stage one 在最终 apply 前多次 yielded query 拉长 debounce 后的可见延迟（不作性能结论） | Input Intelligence Maintainer | `accept`：stage one 保持生产 `12/8` 是 Product 钉死的设计（`PD-I0 L38`、`H2 L125–L126`）；延迟影响归入父 Gate 的“整体性能未知” | `IAR L159–L162`、`L174–L178`、`L218`；`PD-I0 L38`；`H2 L125–L126`；`GATE L55` |
| `H2-R13` 生产 12/8 与 60/64 非 always-on 第一阶段的语义效果未由 Quality 重测 | Quality | `accept`：Quality “源码与既有 preflight 测试仍在…不声明 runtime 效果” | `IAR L219`；`IQR L143`；`PD-I L13–L15`、`L25` |
| `H2-N1`（说明性语句）`refreshContextualTypoCorrectionSuggestions` 仍保留紧循环，既有测试仍走该入口：Architecture 自述“这是回归面，不是新合同的证明” | — | 无处置列。Executor 把它归为说明性语句，不是独立残项；其后热路径唯一 writer 由 H4 Architecture 关闭（`H2-R3`）。见报告“判断点” | `IAR L208–L209`；`BAR L34`、`L45–L49` |
| `H2-N2`（说明性语句）Executor 未记录 Q-01 警告，Quality 以独立编译日志为准 | — | 说明性语句，已由 `H2-R4` 承载 | `IQR L161` |

**Q-01 最终状态（原文）：** `HEV L82–L83` 记 hardening 把 yielded RunLoop continuation 改为“re-enters `MainActor` through `Task` rather than calling an actor-isolated method directly”；`HEV L97–L98` 记 RimeBridgeTests 与 App + Keyboard 在 “Swift 6 strict / warnings-as-errors” 下 Pass（Executor 记录）；`HAR L44` 记 `Pass with conditions`，并要求 “Quality must independently prove warnings-as-errors compilation; no compiler-success claim here”；`BQR L61–L65` 把严格格式/测试与首次 App 编译的 Sendable 失败→修复→通过全部归为 Executor-recorded（Quality 未重跑）；`PD-B L34–L36` 接受这些为 Executor-recorded 本地证据；`FSQ L37` 记 PR #144 终态 head `b3011fee57d6681baafe27bb16c5df2c6444b691` 上 hosted CI run `35703145156` 全部 job 成功（含 `test-app-keyboard`、`build-release`）。**不声称：** 终态树上 `#ActorIsolatedCall` 警告已消失（仓库内没有该树的编译警告日志，`UNKNOWN`）；`IQR L120` 已记本地在 warnings-as-errors 下仍 TEST SUCCEEDED，因此 strict Pass 本身不能证明警告不存在。

“运行时行为与全部可观察产品结果、真实 RIME、QA-001、INT-003、paired performance、180 ms 保持 `UNKNOWN`”的父 Gate 台账覆盖核对（逐项对照 `GATE` = `docs/product-decisions/TYPO-CORRECTION-002-PARENT-FINAL-PRODUCT-GATE-001.md`，父任务 `TYPO-CORRECTION-002` 已 Closed）：QA-001 → `GATE L53`（`QR-QA08-01..05` / `AR-QA08-01..04` accept，“实际selection/postselection未验证”）；INT-003 → `GATE L49–L52`（`Q-R2-03` 与 `Q-R2-04` 分别为 tech_debt `INT003-COORDINATOR-INDEPENDENT-ORACLE` / `INT003-RIME-FAILURE-BOUNDARY`，`P2-*` accept）；真实 RIME 失败边界 → `GATE L50`，native 非空查询与 observer 未知 → `GATE L51`、`L55`；paired performance / 整体性能 → `GATE L55` 与 `docs/product-decisions/TYPO-CORRECTION-002-PARENT-PERFORMANCE-SCOPE-PROPOSAL-001.md` 末节“2026-10-11：Human明确批准”（L24 起，“整体CPU/UI/内存及v2总体observer未知原样保留，不声称性能Pass”）；180 ms → `GATE L59`（“不恢复…手动<180ms通过门槛”）；最新集成包的可观察结果 → `GATE L42`（“历史QA包不等于最新集成包…不宣布最新main全部设备/schema已复测”）。台账逐行保持 `UNKNOWN` 或 accept 的边界，本批次不把它们改写成已验证。

**AUTH 现状与不可重放声明**（只读核对，本批次未修改任何 `docs/authorizations/` 文件）：

- 全链共 34 份文件名含 `RUNTIME-INTEGRATION` 的 AUTH（`docs/authorizations/`）逐份核对（命令见 Executor 报告）：33 份 `status: consumed` 且 `consumption_state: consumed`；唯一例外是 `AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-001`，`status: superseded`、`consumption_state: unconsumed`。本 Assignment 正文引用的 AUTH 中，没有文件名不含 `RUNTIME-INTEGRATION` 的 AUTH。
- 本 Assignment 引用的 AUTH：`AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-001`、`…IMPLEMENTATION-ARCHITECTURE-001`、`…IMPLEMENTATION-QUALITY-001`、`…IMPLEMENTATION-PRODUCT-RESIDUAL-001`（`H2 L25–L28`）均为 `consumed`。
- 本 Assignment 引用的 AUTH 均为 `consumed`，无需例外记录；上述 `HARDENING-001` 例外项由引用它的 Assignment `TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-001` 的 Closeout 记录，本 Close 不重复处置。仍声明：所属 Assignment 已 Closed；其引用的 AUTH 不得再被消费或重放，任何后续执行须由 Human 另行签发新的 AUTH。

**非声称：** 不是 Release / Release-ready；不声称真实 RIME、QA-001、INT-003、性能或 180 ms 的任何结论（均保持 `UNKNOWN`，其处置以父 Gate 台账为准）；不改父任务 `TYPO-CORRECTION-002`（已 Closed）；未关闭、削弱本表之外的任何残项；没有把 Human 转述的评审升级为独立复核；未关闭名单之外的任何 Assignment（含同链 publication / preparation / final-SHA-quality-publication 子 Assignment）；本 Close 先在本地提交，待 Reviewer 评审及 Human push / PR / merge 后在 `main` 生效。**已合并树是否逐字节包含冻结快照：`UNKNOWN`**——该快照从未提交（其记录的 base `4d1050f` 是 PR #143 的 `main` 提交），其 checkpoint diff SHA-256 `8bb105c5…` 与 PR #144 的累计 diff 不可比，PR #144 是 squash（`H2 L51–L52`）。本 Close 没有核对过，也不把它写成一致。
