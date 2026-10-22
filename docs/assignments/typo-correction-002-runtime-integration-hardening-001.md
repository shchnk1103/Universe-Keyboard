# Assignment: TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-001 — Controller/sidecar residual hardening

Policy version: 1.0.0

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-001",
  "record_type": "assignment",
  "title": "Controller and sidecar runtime-integration residual hardening",
  "lifecycle": "closed",
  "current_phase": "Closed — 2026-10-22 在 LIFECYCLE-CLOSEOUT-BATCH-1C-001 下关闭；以下为此前阶段文字（历史）：Independent Architecture review returned Blocker; new bounded remediation or explicit Product residual disposition is required before Quality review",
  "authorization_action": "remediate_bounded_controller_sidecar_runtime_integration_residuals",
  "updated_at": "2026-10-22",
  "revalidation_triggers": [
    "source_snapshot_or_checkpoint_identity_changed",
    "accepted_residual_or_allowed_path_changed",
    "adapter_owner_or_recall_lifecycle_changed",
    "test_scope_or_result_changed",
    "runtime_capture_or_publication_requested",
    "authority_revoked"
  ],
  "authorization_refs": [
    "AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-001",
    "AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-CODEX-EXECUTION-001",
    "AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-F01-ENTRYPOINT-001",
    "AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-LOCAL-TEST-ENVIRONMENT-001",
    "AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-EXECUTOR-REASSIGNMENT-001",
    "AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-ARCHITECTURE-001"
  ],
  "parent_refs": [
    "TYPO-CORRECTION-002",
    "TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-001",
    "PD-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-RESIDUAL-001"
  ],
  "responsibilities": {
    "domain_owner": "Input Intelligence Maintainer",
    "executor": "Current Codex task",
    "environment_executor": "Current Codex task, new isolated local worktree and local test toolchain only; no device or RIME environment operation",
    "human_dependency": "Not Applicable — this Assignment is active from the current Human Product Owner authorization; Codex must still verify the pinned source identity before consuming its receipt",
    "architecture_reviewer": "Independent Architecture and Knowledge Steward",
    "quality_reviewer": "Independent Quality, Performance and Release Maintainer",
    "product_approver": "Human Product Owner / Product Lead"
  }
}
```

## Current Status

> **Superseded for current status:** 本 Work Item 于 2026-10-22 在 [`LIFECYCLE-CLOSEOUT-BATCH-1C-001`](lifecycle-closeout-batch-1c-001.md) 下关闭，见文末 [Closeout (2026-10-22)](#closeout-2026-10-22)。
> Text below is historical narrative：其后出现的 `Active` Lifecycle、Phase / Next / Residuals 与 Non-claims 的叙述均属各自日期的历史，不是当前事实；本说明与下方既有的 S-03 说明并存，不覆盖它们。Lifecycle 值在本改动进入 `main` 时生效。

> **Superseded for current status:** see [`TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-001`](typo-correction-002-runtime-integration-hardening-blocker-remediation-001.md) and [`ACTIVE-WORK-STALE-FACTS-SYNC-001`](active-work-stale-facts-sync-001.md) (2026-10-21).
> The Architecture `Blocker` and "new bounded remediation or an explicit Product residual disposition is required" below are historical as of 2026-09-22. The remediation Assignment ran; its Current Status records Architecture F-01/F-02/F-03 Closed, Quality `Pass with conditions` and a Product-accepted bounded residual decision, and GitHub PR [#144](https://github.com/shchnk1103/Universe-Keyboard/pull/144) was squash-merged as `e1b28aebe8f6b2f2a8587db1e525e332aa9bfe00` (2026-09-22T10:19:31Z). This file's Lifecycle `Active` is not changed here and needs a separate Human decision; F-04 (`tech_debt`) and every other residual named below are not closed by this note.

| Field | Value |
|---|---|
| **Lifecycle** | `Closed`（2026-10-22 起，见文末 Closeout；此前为 `Active`） |
| **Phase** | Codex hardening has an independently reproduced identity, but Architecture returned `Blocker`. New bounded remediation or an explicit Product residual disposition is required before Quality review. |
| **Non-claims** | No runtime capture, real RIME result, QA-001, INT-003, paired performance, commit, push, PR, merge, Gate, Release or Assignment Close. |
| **Next** | Product Lead must choose a new bounded remediation slice or explicitly accept the three Architecture blockers. Quality review is not authorized. |
| **Residuals** | F-01 canary/P3D1 order and yielded-callback ownership, F-03 fallback unique-writer proof, and three-route adapter/no-bypass proof are `fix` unless Product accepts them. F-04 remains `tech_debt`; product outcomes remain `UNKNOWN`. |

---

## Authority

- **Assignment Authority:** Human Product Owner / Product Lead.
- **Decision Source / Date:** current task instruction `授权按照你的建议继续进行下一步`, `2026-09-22 Asia/Shanghai`.
- **Product Approver:** Human Product Owner / Product Lead.
- **Parent Assignment:** [`TYPO-CORRECTION-002`](typo-correction-002.md).
- **Predecessor:** [`runtime-integration implementation`](typo-correction-002-runtime-integration-implementation-001.md) (`Reviewed`; bounded residuals accepted, not published).
- **Residual decision:** [`PD-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-RESIDUAL-001`](../product-decisions/TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-RESIDUAL-001.md).
- **Superseded Grok Authorization:** [`AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-001.md) (`superseded` / `unconsumed`; never consumed).
- **Executor reassignment:** [`AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-EXECUTOR-REASSIGNMENT-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-EXECUTOR-REASSIGNMENT-001.md) (`consumed`; docs-only).
- **Execution Authorization:** [`AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-CODEX-EXECUTION-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-CODEX-EXECUTION-001.md) (`consumed`; Current Codex task only).
- **F-01 entrypoint supplement:** [`AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-F01-ENTRYPOINT-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-F01-ENTRYPOINT-001.md) (`consumed`; single additional UI entrypoint path only).
- **Test-only dependency receipt:** [`AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-LOCAL-TEST-ENVIRONMENT-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-LOCAL-TEST-ENVIRONMENT-001.md) (`consumed`; ignored local Vendor link only).
- **Executor handoff:** [`Grok → Codex runtime-integration handoff`](../evidence/typo-correction-002-grok-to-codex-runtime-integration-handoff-2026-09-21.md).

## KOS v0.8.0 optional-contract selection

| Contract | Selection | Boundary and owner source |
|---|---|---|
| E-01 claim-bound observation | Not applicable | This lane has no device or product-observation claim. |
| A-01 / B-01 authorization chain and briefing | Adopted | This Assignment is the next source-changing slice; the exact input snapshot and Grok-only execution receipt are pinned. |
| P-01 publication facts | Not applicable | Commit, push, PR and merge are excluded. |
| D-01 final-documentation receipt | Not applicable | Independent reviews, not final documentation closure, are the required handoff. |

### Authorization frontier (A-01 / B-01)

| Slice | Status | Action / target / boundary | Authority source |
|---|---|---|---|
| Prior implementation | Consumed | Frozen uncommitted controller/sidecar snapshot | [`implementation AUTH`](../authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-001.md) |
| Superseded hardening | Superseded | Grok-only receipt remained unconsumed | [`Grok AUTH`](../authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-001.md) |
| Current hardening | Consumed | Codex-only residual remediation after identity verification | [`Codex AUTH`](../authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-CODEX-EXECUTION-001.md) |
| F-01 entrypoint supplement | Consumed | One discovered UI entrypoint file; invalidate before existing page/mode actions | [`F-01 supplement`](../authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-F01-ENTRYPOINT-001.md) |
| Local test environment | Consumed | Ignored link to the preserved, already verified Vendor only for xcodebuild resolution | [`test dependency AUTH`](../authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-LOCAL-TEST-ENVIRONMENT-001.md) |
| Independent Architecture review | Consumed / Blocker | [`Architecture review`](../reviews/typo-correction-002-runtime-integration-hardening-architecture-review-2026-09-22.md) identifies three source-level blockers | Remediation or Product residual decision required |
| Independent Quality review | Blocked | Review/re-run only a newly Architecture-acceptable snapshot | New Authorization required after blocker disposition |
| Publication or product evidence | Not authorized | Commit/push/PR/merge and real-RIME/QA/performance are separate future decisions | Product decision required |

## Scope

Current Codex task may only perform the following in a **new** isolated hardening worktree:

1. Resolve the `#ActorIsolatedCall` warning in
   `TypoCorrectionRecallCoordinator.swift` without weakening Swift concurrency
   diagnostics.
2. Make empty and budget-stop recall outcomes structural display no-ops:
   no candidate-bar refresh and no observable display mutation merely because
   the result set is empty.
3. Apply invalidate-first `recallEpoch` behavior at the named page toggle,
   canary/P3D1 install and empty-composition mode-toggle entry points.
4. Prevent the legacy hot path from independently writing
   `state.typoCorrection` while the controller-owned recall operation is
   current.
5. Add focused tests for those four contracts. Existing adapter-route tests
   may be strengthened only where the lifecycle change needs no-bypass proof;
   no adapter redesign is in scope.

## Non-goals

- Do not modify the preserved implementation worktree at
  `/private/tmp/universe-keyboard-typo-correction-002-runtime-integration-implementation-001`.
- Do not modify the original pure-Core checkpoint at
  `/Users/doubleshy0n/.codex/worktrees/typo-correction-002-runtime-preflight-implementation-001/Universe Keyboard`.
- Do not change first-stage `12/8`, make `60/64` always-on, add a second
  composition/commit/RIME session/query lane, or change diagnostic retention.
- Do not use `FakeCandidateProvider`, old Ice content, host text, clipboard,
  a model or network substitute as real-RIME evidence.
- Do not run a Simulator/device capture, deploy RIME, issue a Run ID, retry
  same-package same-phrase QA-001, run INT-003 or claim paired performance.
- Do not commit, push, open a PR, merge, TestFlight, Release, close a Gate or
  close this or the parent Assignment.

## Required Inputs

- source snapshot: HEAD `4d1050f4b677494e06448cb40a83ef2da46d7b27`, tree
  `5f864a6f6f139810ed59c7e00ab6c33caad7e500`, tracked diff SHA-256
  `d1366181e0436242211aa496934792e90a6ab1b0454608f0e1c3dd5a17ef4c1b`;
- independent changed-file manifest SHA-256
  `4b701835f070e2c337fd2d3b76b67813e7e5722bdaa7db1b82faa7e00d2c891e`;
- preserved pure-Core checkpoint diff SHA-256
  `8bb105c5381feb43fc41ec168fd239fd7c864cc0efa739cae3976beb685ebbab`;
- the predecessor Architecture Conditional Accept and Quality Pass with
  conditions, plus the accepted residual Product Decision;
- the Grok handoff listed above and the existing controller/RimeBridge
  ownership, marked-text and privacy contracts.

## Assignment

- **Domain Owner:** Input Intelligence Maintainer.
- **Executor:** Current Codex task.
- **Environment Executor:** Current Codex task — isolated local worktree and local test
  toolchain only; no device, deployment or capture operation.
- **Human Dependency:** Not Applicable — current Product authorization created
  the active receipt; identity verification remains Codex's Entry Criterion.
- **Architecture Reviewer:** Independent Architecture & Knowledge Steward.
- **Quality Reviewer:** Independent Quality, Performance & Release Maintainer.
- **Product Approver:** Human Product Owner / Product Lead.
- **Handoff Target:** independent Architecture review, then independent Quality
  review, then Product Lead.

## Gates

### Entry Criteria

- The Codex hardening Authorization is `consumed` by the named Codex consumer.
- All five pinned source identities match before the copy.
- The two preservation worktrees remain unchanged.
- A separate hardening worktree can be created without reusing or cleaning any
  preserved worktree.
- No source path outside the Authorization allow-list is needed.

### Exit Criteria

- Execution evidence records the verified input identities, source-copy method,
  changed-file inventory and preservation-worktree checks.
- Every changed Swift file passes strict `swift-format` lint.
- Focused negative tests prove the four scoped contracts; path-required
  KeyboardCore, RimeBridge and App+Keyboard checks report actual results.
- Q-01's strict-concurrency warning outcome is explicit, not inferred from a
  successful local test process.
- Independent Architecture can review the exact resulting snapshot. This
  Assignment does not itself close that review or quality lane.

### Stop Conditions

- Source or preservation-worktree identity changes or cannot be verified.
- A required fix needs an unlisted path, weakens concurrency checks, or creates
  another input/commit/query path.
- Real RIME, capture, QA-001, INT-003, performance, publication or a Gate
  conclusion becomes necessary.
- A test failure reveals a residual beyond this bounded scope.

### Revalidation Trigger

Any source identity, accepted residual, allowed path, ownership boundary,
verification result, executor identity or Product authority change.

## Handoff

- **Required Handoff Content:** new worktree path; verified bindings before the
  copy; preservation-worktree proof; changed-file manifest; each residual's
  concrete disposition; format/test results; remaining residuals; and explicit
  non-claims.
- **Handoff Target:** Independent Architecture review → Independent Quality
  review → Human Product Owner / Product Lead.

## Closeout (2026-10-22)

- **决定来源：** Human Product Owner（Product Lead）于 2026-10-22 Asia/Shanghai 在 Coordinator 会话中批准 D1（TYPO-CORRECTION-002 子项按批收尾）与 D7，并同意先把 hardening 链四项做成批次 1c（见 [`lifecycle-closeout-batch-1c-001.md`](lifecycle-closeout-batch-1c-001.md) §Authority）；F-04 新建 tech_debt 与 D-1C-AUTH 均已由 Human 在同一会话确认（同文件 Current Status 的 “Human 确认状态” 行）。本 Close 在任务 `LIFECYCLE-CLOSEOUT-BATCH-1C-001` 下由 Executor 回到原文核实来源后写入；残项由 Executor 自己从原文枚举，Assignment 中的“残项与处置线索”表仅作线索。
- **关闭依据（Executor 核实）：** 本 Assignment 的 Architecture `Blocker`（`HAR L5`）已被 [`TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-001`](typo-correction-002-runtime-integration-hardening-blocker-remediation-001.md) 取代：Product 决定 `PD-B0 L11–L15` 把该 Blocker 接受为工程约束并指令一个补救切片，H4 的 Architecture 复核记 F-01/F-02/F-03 在源码层 Closed（`BAR L26–L34`），Quality `Pass with conditions`（`BQR L105–L118`），Product 接受有界残项（`PD-B L9–L36`）。GitHub PR [#144](https://github.com/shchnk1103/Universe-Keyboard/pull/144) 于 `2026-09-22T10:19:31Z` squash-merge 为 `e1b28aebe8f6b2f2a8587db1e525e332aa9bfe00`（`gh pr view 144`：state MERGED、headRefName `codex/typo-correction-002-runtime-hardening-blockers`；`git log -1 e1b28ae` 提交时间 `2026-09-22T18:19:30+08:00`）。
- **来源简称**（下表“来源指针”中的 `简称 L行号` 均指这些文件的行号，行号取自基线 `e828a9969f6d41414d8bb991da9f7202fe056636` 的文件内容；本 Assignment 自身在顶部插入了 S-03 说明，其引用的 `H1…H4` 行号均指基线行号）：
  - `H3` = `docs/assignments/typo-correction-002-runtime-integration-hardening-001.md`
  - `HAR` = `docs/reviews/typo-correction-002-runtime-integration-hardening-architecture-review-2026-09-22.md`
  - `HEV` = `docs/evidence/typo-correction-002-runtime-integration-hardening-001.md`
  - `PD-B0` = `docs/product-decisions/TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-001.md`
  - `BAR` = `docs/reviews/typo-correction-002-runtime-integration-hardening-blocker-remediation-architecture-review-2026-09-22.md`
  - `BQR` = `docs/reviews/typo-correction-002-runtime-integration-hardening-blocker-remediation-quality-review-2026-09-22.md`
  - `BEV` = `docs/evidence/typo-correction-002-runtime-integration-hardening-blocker-remediation-001.md`
  - `PD-B` = `docs/product-decisions/TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-RESIDUAL-001.md`
  - `PREP-E` = `docs/evidence/typo-correction-002-runtime-integration-hardening-blocker-remediation-publication-preparation-001.md`
  - `FSQ` = `docs/reviews/typo-correction-002-runtime-integration-hardening-blocker-remediation-pr144-final-sha-quality-review-2026-09-22.md`
  - `GATE` = `docs/product-decisions/TYPO-CORRECTION-002-PARENT-FINAL-PRODUCT-GATE-001.md`
  - `PERF` = `docs/product-decisions/TYPO-CORRECTION-002-PARENT-PERFORMANCE-SCOPE-PROPOSAL-001.md`
  - `TD` = `docs/TECH_DEBT.md`

**残项处置表**（ID | owner | 处置 | 来源指针）。残项由 Executor 从 `H3 L59`、`HAR L42–L64`、`HEV L110–L119`、`H3 L104–L106`、`L180–L181` 原文枚举（`HAR` 的 F-01/F-02/F-03 与 H4 评审的 F-01/F-02/F-03 编号**含义不同**：此处按各自原文的内容映射）：

| ID | owner | 处置 | 来源指针 |
|---|---|---|---|
| `H3-R1` F-01 canary/P3D1 先 invalidate 再改 responsive/thread-affine 标志与 bootstrap（Blocker） | Input Intelligence Maintainer / Keyboard UI | `fix`，已完成：H4 Architecture 记 “Canary, P3D1 and dual-gate arming invalidate the controller-owned recall before changing responsive/thread-affine flags”，Closed；dual-gate 失败回滚缺第二次相邻 invalidate 另行 `accept`（`H4-R2`） | `H3 L59`；`HAR L46`、`L59`；`BAR L32`、`L38–L40`；`FSQ L77` |
| `H3-R2` F-01 yielded callback 所有权：RunLoop continuation 无 operation token / 可取消句柄（Blocker） | Input Intelligence Maintainer / Keyboard UI | `fix`，已完成：H4 Architecture 记 callback 携带含 recall epoch、composition revision、operation ordinal 的 `Sendable` token，mismatch 即返回；无 `@unchecked Sendable`、`Task.detached`；Closed（其严格编译结果仍为 Executor 证据） | `H3 L59`；`HAR L47`、`L59`；`BAR L33`、`L41–L44`；`BEV L61–L62`；`FSQ L78` |
| `H3-R3` F-03 fallback 唯一 `state.typoCorrection` writer / recall lifetime（Blocker / UNKNOWN） | Input Intelligence Maintainer | `fix`，已完成：H4 Architecture 记 “Recall cannot start before a `TypoCorrectionSidecarOwner` is installed. The Core hot path observes active owner lifetime”，Closed | `H3 L59`；`HAR L49`、`L60`；`BAR L34`、`L45–L49`；`FSQ L79` |
| `H3-R4` 三路 default / MainActor-responsive / thread-affine adapter 与 no-bypass 证明；canary/P3D1 仍用 `CandidateProviderTypoCorrectionQuery` | RimeBridge Maintainer | `fix`，已完成：H4 Architecture 记 “adapter coverage enumerates the three façade routes”，Closed；`CandidateProviderTypoCorrectionQuery` 外观由 Product 另行 `accept`，“不重分类为真实 RIME，也不是第二个 live RIME session” | `H3 L59`；`HAR L51`、`L61`；`BAR L34`、`L45–L49`、`L61–L63`；`PD-B L31–L33`；`FSQ L79` |
| `H3-R5` Q-01：yielded 回调的 strict-concurrency 警告结果须显式记录，Quality 须独立证明 warnings-as-errors 编译 | Input Intelligence Maintainer / Quality | `accept`：Product 接受严格格式/测试为 Executor-recorded 本地证据（`PD-B L34–L36`）；终态 head 的 hosted CI 成功（`FSQ L37`）。最终状态原文见 H2 Closeout 的“Q-01 最终状态”；终态树上该警告是否消失 `UNKNOWN` | `H3 L104–L106`、`L180–L181`；`HAR L44`；`HEV L82–L83`、`L97–L98`；`BQR L63–L65`、`L127`；`PD-B L34–L36`；`FSQ L37` |
| `H3-R6` F-03 empty / budget-stop 为结构性 display no-op（Pass with conditions；其测试未由 Architecture 重跑） | Input Intelligence Maintainer | `accept`：Architecture “源码可见”；本地测试结果由 H4 Executor 记录并被 Product 接受为 Executor-recorded（`PD-B L34–L36`） | `HAR L48`；`BEV L57–L62`；`BQR L59–L67`；`PD-B L34–L36` |
| `H3-R7` F-03 fences / lifetime：Pass with conditions，“Cannot close while stale callback and fallback-owner blockers remain” | Input Intelligence Maintainer | `fix`，已完成：所述两项 Blocker（`H3-R2`、`H3-R3`）已由 H4 Architecture Closed | `HAR L50`；`BAR L33–L34` |
| `H3-R8` 对变更后的精确快照做 Architecture 重审（hardening 评审：“required after fix”） | Independent Architecture & Knowledge Steward | `fix`，已完成：H4 Architecture 复核 `Pass with conditions`（独立复现身份与 delta） | `HAR L62`；`BAR L1–L34` |
| `H3-R9` Quality review 在 Architecture Blocker 关闭前被阻断 | Independent Quality, Performance & Release Maintainer | `fix`，已完成：`QUALITY-002` 给出 bounded `Pass with conditions`；PR #144 终态 head 另有 final-SHA Quality `Pass with conditions` | `HAR L63`；`BQR L105–L118`；`FSQ L119–L129` |
| `H3-R10` F-04 diagnostics | Input Intelligence Maintainer（`HAR L64`） | `tech_debt:TYPO-CORRECTION-002-F04-OPERATION-RECEIPT-DIAGNOSTICS`（Human 2026-10-22 确认，本批次新建，当前 Open） | `H3 L59`；`HAR L53`、`L64`；`TD`（文末 F-04 条目） |
| `H3-R11` 运行时行为与全部可观察产品结果、真实 RIME、QA-001、INT-003、paired performance、180 ms 保持 `UNKNOWN` | Human Product Lead | `accept`（父 Gate 台账覆盖，逐项对照见下） | `H3 L57`、`L59`；`HAR L66–L72`；`HEV L115–L117`；`GATE L42`、`L49–L55`、`L59` |
| `H3-N1`（说明性语句）F-01 page/mode/owner、marked-text/host-commit、privacy 为 Pass，无残项 | — | 无残项 | `HAR L45`、`L52`、`L53` |

“运行时行为与全部可观察产品结果、真实 RIME、QA-001、INT-003、paired performance、180 ms 保持 `UNKNOWN`”的父 Gate 台账覆盖核对（逐项对照 `GATE` = `docs/product-decisions/TYPO-CORRECTION-002-PARENT-FINAL-PRODUCT-GATE-001.md`，父任务 `TYPO-CORRECTION-002` 已 Closed）：QA-001 → `GATE L53`（`QR-QA08-01..05` / `AR-QA08-01..04` accept，“实际selection/postselection未验证”）；INT-003 → `GATE L49–L52`（`Q-R2-03` 与 `Q-R2-04` 分别为 tech_debt `INT003-COORDINATOR-INDEPENDENT-ORACLE` / `INT003-RIME-FAILURE-BOUNDARY`，`P2-*` accept）；真实 RIME 失败边界 → `GATE L50`，native 非空查询与 observer 未知 → `GATE L51`、`L55`；paired performance / 整体性能 → `GATE L55` 与 `docs/product-decisions/TYPO-CORRECTION-002-PARENT-PERFORMANCE-SCOPE-PROPOSAL-001.md` 末节“2026-10-11：Human明确批准”（L24 起，“整体CPU/UI/内存及v2总体observer未知原样保留，不声称性能Pass”）；180 ms → `GATE L59`（“不恢复…手动<180ms通过门槛”）；最新集成包的可观察结果 → `GATE L42`（“历史QA包不等于最新集成包…不宣布最新main全部设备/schema已复测”）。台账逐行保持 `UNKNOWN` 或 accept 的边界，本批次不把它们改写成已验证。

**AUTH 现状与不可重放声明**（只读核对，本批次未修改任何 `docs/authorizations/` 文件）：

- 全链共 34 份文件名含 `RUNTIME-INTEGRATION` 的 AUTH（`docs/authorizations/`）逐份核对（命令见 Executor 报告）：33 份 `status: consumed` 且 `consumption_state: consumed`；唯一例外是 `AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-001`，`status: superseded`、`consumption_state: unconsumed`。本 Assignment 正文引用的 AUTH 中，没有文件名不含 `RUNTIME-INTEGRATION` 的 AUTH。
- 本 Assignment 引用的 AUTH：`AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-001`（superseded / unconsumed，见下）、`…HARDENING-CODEX-EXECUTION-001`、`…HARDENING-F01-ENTRYPOINT-001`、`…HARDENING-LOCAL-TEST-ENVIRONMENT-001`、`…HARDENING-EXECUTOR-REASSIGNMENT-001`、`…HARDENING-ARCHITECTURE-001`、`…IMPLEMENTATION-001`（`H3 L24–L29`、`L33`）；除 `HARDENING-001` 外均为 `consumed`。
- **例外项：** `docs/authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-001.md` 第 20 行 `"status": "superseded"`，第 107 行 `"consumption_state": "unconsumed"`，第 7 行表格 “`superseded` / `unconsumed` — executor reassigned before any source action; do not reuse”，第 115 行 “This unconsumed receipt was superseded before source action.”；本 Assignment 第 71 行亦记为 “`superseded` / `unconsumed`; never consumed”。
- 声明：所属 Assignment 已 Closed；该 AUTH 已被取代（superseded），不得再被消费或重放；任何后续执行须由 Human 另行签发新的 AUTH。处置：`accept`（Human 2026-10-22 确认的 D-1C-AUTH，沿用 D-1B-AUTH）。`docs/TECH_DEBT.md` 的 `TD-014`（第 264 行）是同类问题（AUTH consumption_state 卫生）的既有登记，仅作引用，本 Close 不修改它，也不把它当作该 AUTH 的处置。

**非声称：** 不是 Release / Release-ready；不声称真实 RIME、QA-001、INT-003、性能或 180 ms 的任何结论（均保持 `UNKNOWN`，其处置以父 Gate 台账为准）；不改父任务 `TYPO-CORRECTION-002`（已 Closed）；未关闭、削弱本表之外的任何残项；没有把 Human 转述的评审升级为独立复核；未关闭名单之外的任何 Assignment（含同链 publication / preparation / final-SHA-quality-publication 子 Assignment）；本 Close 先在本地提交，待 Reviewer 评审及 Human push / PR / merge 后在 `main` 生效。本 Assignment 的 Lifecycle `Active` 在文件顶部既有 S-03 说明里已标明“needs a separate Human decision”，该决定即上述 D1 与批次 1c；其 Architecture `Blocker` 与“Product 须选择补救或接受三项 Blocker”的叙述（`H3 L56–L59`）是 2026-09-22 的历史。**已合并树是否逐字节包含 hardening 冻结快照：`UNKNOWN`**——该快照与 H2 的快照一样从未提交，PR #144 是 squash；本 Close 没有核对过，也不把它写成一致。
