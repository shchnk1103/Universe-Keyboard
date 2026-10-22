# Assignment: TYPO-CORRECTION-002-RUNTIME-INTEGRATION-DESIGN-001 — Controller/sidecar runtime design

Policy version: 1.0.0

## Current Status

> **Superseded for current status:** 本 Work Item 于 2026-10-22 在 [`LIFECYCLE-CLOSEOUT-BATCH-1C-001`](lifecycle-closeout-batch-1c-001.md) 下关闭，见文末 [Closeout (2026-10-22)](#closeout-2026-10-22)。
> Text below is historical narrative：其后出现的 `Reviewed` Lifecycle、Phase / Next / Residuals 与 Non-claims 的叙述均属各自日期的历史，不是当前事实；本说明与下方表格的历史叙述并存，不覆盖它们。Lifecycle 值在本改动进入 `main` 时生效。

| Field | Value |
|---|---|
| **Lifecycle** | `Closed`（2026-10-22 起，见文末 Closeout；此前为 `Reviewed`） |
| **Phase** | Revised design received independent `Conditional Accept`. Its implementation Authorization was consumed by Grok; the resulting snapshot is `Reviewed` with bounded residuals accepted. A separate hardening Assignment is now `Ready`. |
| **Non-claims** | No Swift change, runtime wiring, RIME query, device Run, QA-001, performance, publication or Gate conclusion. |
| **Next** | Current Codex task may consume the separate [`hardening Authorization`](../authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-CODEX-EXECUTION-001.md) only after verifying its pinned source snapshot. The prior Grok receipt was superseded unconsumed. Independent Architecture review of the resulting hardening snapshot is separately gated. |
| **Residuals** | [Architecture re-review](../reviews/typo-correction-002-runtime-integration-design-architecture-rereview-2026-09-21.md): F-01/F-02/F-03 resolved in design but remain implementation conditions; F-04=`tech_debt`. Runtime behavior and all observable product outcomes remain `UNKNOWN`. |

---

## Authority

- **Assignment Authority:** Human Product Owner / Product Lead。
- **Decision Source / Date:** [`runtime-preflight residual decision`](../product-decisions/TYPO-CORRECTION-002-RUNTIME-PREFLIGHT-IMPLEMENTATION-RESIDUAL-001.md)，`2026-09-21 Asia/Shanghai`。
- **Parent Assignment:** [`TYPO-CORRECTION-002-RUNTIME-PREFLIGHT-IMPLEMENTATION-001`](typo-correction-002-runtime-preflight-implementation-001.md)。
- **Input Reviews:** [`Architecture`](../reviews/typo-correction-002-runtime-preflight-implementation-architecture-review.md) · [`Quality`](../reviews/typo-correction-002-runtime-preflight-implementation-quality-review.md)。
- **Matching Authorization:** [`AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-DESIGN-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-DESIGN-001.md)。
- **Design Package:** [`controller/sidecar runtime design`](../plans/typo-correction-002-runtime-integration-design-2026-09-21.md)。
- **Architecture Review:** [`reconciled independent review`](../reviews/typo-correction-002-runtime-integration-design-architecture-review-2026-09-21.md)。
- **Revision Authorization:** [`F-01–F-03 design revision`](../authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-DESIGN-REVISION-001.md)。
- **Re-review:** [`independent Architecture re-review`](../reviews/typo-correction-002-runtime-integration-design-architecture-rereview-2026-09-21.md)。
- **Grok Handoff:** [`runtime implementation handoff`](../evidence/typo-correction-002-codex-to-grok-runtime-integration-handoff-2026-09-21.md)。
- **Superseding residual-hardening child:** [`TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-001`](typo-correction-002-runtime-integration-hardening-001.md) (`Ready`; no publication or product-evidence authority).

## Scope

1. Read the exact pure-Core checkpoint and current controller/RimeBridge paths.
2. Specify ownership for a second-stage operation, its pause, work scheduling,
   pre-call/post-result stale fences and cancellation semantics.
3. Specify bounded group/query/result lifecycle and display-only merge into the
   existing candidate path without a second composition or commit route.
4. Specify the needed sidecar accounting and privacy-safe diagnostics boundary.
5. Identify exact future code paths, required tests, real-RIME observability,
   QA-001 and paired-performance lanes, each as separate authorization needs.
6. Produce a docs-only package for independent Architecture review.

## Non-goals

- No Swift, project, schema/vendor, RimeBridge, Keyboard controller or UI change.
- No actual async scheduler, sidecar query, diagnostics emission or candidate merge.
- No Simulator/device capture, new Run ID, QA-001, INT-003, paired performance,
  `180 ms` claim, FakeCandidateProvider, old Ice, model or network evidence.
- No commit, push, PR, merge, TestFlight, Release, Gate, publication or Close.

## Assignment

- **Domain Owner:** Input Intelligence Maintainer。
- **Executor:** Current Codex task, restricted to the matching Authorization。
- **Architecture Reviewer:** Independent Architecture & Knowledge Steward。
- **Quality Reviewer:** Independent Quality, Performance & Release Maintainer。
- **Human Dependency:** Later implementation requires a separate Product decision
  and explicit implementation Authorization after design review.

## Required Inputs

- exact baseline `4d1050f4b677494e06448cb40a83ef2da46d7b27` / tree `5f864a6f6f139810ed59c7e00ab6c33caad7e500`;
- pure-Core checkpoint diff `8bb105c5381feb43fc41ec168fd239fd7c864cc0efa739cae3976beb685ebbab`;
- preceding Product residual decision and Architecture/Quality reviews;
- controller, RimeBridge correction-query and diagnostics/privacy source boundaries.

## Exit Criteria

- Design identifies a single operation owner and all await/fence boundaries.
- Bounded resource/counter and display-only merge contracts are explicit.
- Privacy-safe observability contract contains no raw composition, candidate or
  host text.
- Every implementation, real-RIME, QA and performance claim is assigned to a
  later Authorization/Run lane.
- Independent Architecture review can accept, conditionally accept or reject
  the exact docs-only design.

## Stop Conditions

- Any requirement needs a Swift change, real RIME result, device capture,
  unbounded work or a performance/product conclusion.
- The design cannot preserve a single composition/commit path or a private
  sidecar session boundary.
- Exact source/checkpoint identity cannot be reproduced.

## Handoff

- **Handoff Target:** Independent Architecture review → Product Lead。
- **Required Handoff Content:** exact source/checkpoint identities, selected
  operation owner, scheduler/fence/cancel contract, merge/privacy limits,
  future file/verification matrix and explicit non-claims.

## Closeout (2026-10-22)

- **决定来源：** Human Product Owner（Product Lead）于 2026-10-22 Asia/Shanghai 在 Coordinator 会话中批准 D1（TYPO-CORRECTION-002 子项按批收尾）与 D7，并同意先把 hardening 链四项做成批次 1c（见 [`lifecycle-closeout-batch-1c-001.md`](lifecycle-closeout-batch-1c-001.md) §Authority）；F-04 新建 tech_debt 与 D-1C-AUTH 均已由 Human 在同一会话确认（同文件 Current Status 的 “Human 确认状态” 行）。本 Close 在任务 `LIFECYCLE-CLOSEOUT-BATCH-1C-001` 下由 Executor 回到原文核实来源后写入；残项由 Executor 自己从原文枚举，Assignment 中的“残项与处置线索”表仅作线索。
- **关闭依据（Executor 核实）：** 设计经 [`independent Architecture re-review`](../reviews/typo-correction-002-runtime-integration-design-architecture-rereview-2026-09-21.md) 得到 `Conditional Accept`（`DRR L25`）；其实现 Authorization `AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-001` 为 `consumed`（`H2 L89`）；设计层 F-01/F-02/F-03 留作的“实现条件”由后继 Assignment 实现、评审并关闭（见下表）。GitHub PR [#144](https://github.com/shchnk1103/Universe-Keyboard/pull/144) 于 `2026-09-22T10:19:31Z` squash-merge 为 `e1b28aebe8f6b2f2a8587db1e525e332aa9bfe00`（`gh pr view 144`：state MERGED、headRefName `codex/typo-correction-002-runtime-hardening-blockers`；`git log -1 e1b28ae` 提交时间 `2026-09-22T18:19:30+08:00`）。
- **JSON / 活动表核实：** 本文件顶部**没有** `kos-record` JSON（`grep -n kos-record` 无结果），故无 JSON 可改；`docs/ACTIVE_WORK.md` 的 Active 表（基线第 305 行表头、第 307–315 行共 9 个数据行，编号列为 11、1、2、3、5、6、7、8、9）中**没有**本 Work Item 的行（`grep -n "RUNTIME-INTEGRATION-DESIGN-001" docs/ACTIVE_WORK.md` 只命中“Current update”叙述行，不命中表行），因此没有行可移出。
- **来源简称**（下表“来源指针”中的 `简称 L行号` 均指这些文件的行号，行号取自基线 `e828a9969f6d41414d8bb991da9f7202fe056636` 的文件内容；本 Assignment 自身在顶部插入了 S-03 说明，其引用的 `H1…H4` 行号均指基线行号）：
  - `H1` = `docs/assignments/typo-correction-002-runtime-integration-design-001.md`
  - `PLAN` = `docs/plans/typo-correction-002-runtime-integration-design-2026-09-21.md`
  - `DAR` = `docs/reviews/typo-correction-002-runtime-integration-design-architecture-review-2026-09-21.md`
  - `DRR` = `docs/reviews/typo-correction-002-runtime-integration-design-architecture-rereview-2026-09-21.md`
  - `PD-I0` = `docs/product-decisions/TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-001.md`
  - `IAR` = `docs/reviews/typo-correction-002-runtime-integration-implementation-architecture-review-2026-09-21.md`
  - `IQR` = `docs/reviews/typo-correction-002-runtime-integration-implementation-quality-review-2026-09-21.md`
  - `PD-I` = `docs/product-decisions/TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-RESIDUAL-001.md`
  - `HAR` = `docs/reviews/typo-correction-002-runtime-integration-hardening-architecture-review-2026-09-22.md`
  - `BAR` = `docs/reviews/typo-correction-002-runtime-integration-hardening-blocker-remediation-architecture-review-2026-09-22.md`
  - `PD-B` = `docs/product-decisions/TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-RESIDUAL-001.md`
  - `FSQ` = `docs/reviews/typo-correction-002-runtime-integration-hardening-blocker-remediation-pr144-final-sha-quality-review-2026-09-22.md`
  - `GATE` = `docs/product-decisions/TYPO-CORRECTION-002-PARENT-FINAL-PRODUCT-GATE-001.md`
  - `PERF` = `docs/product-decisions/TYPO-CORRECTION-002-PARENT-PERFORMANCE-SCOPE-PROPOSAL-001.md`
  - `TD` = `docs/TECH_DEBT.md`

**残项处置表**（ID | owner | 处置 | 来源指针；残项由 Executor 从 `H1 L13`、`DAR`、`DRR`、`PLAN §8` 原文枚举）：

| ID | owner | 处置 | 来源指针 |
|---|---|---|---|
| `H1-R1` F-01（yielded one-query turn 与 invalidate-first 取消；设计层已解决，留作实现条件） | Input Intelligence Maintainer（`HAR L59`） | `fix`：由 H2 实现、H3/H4 补齐并经 Architecture 关闭；H2 的 PD 命名的、当时未覆盖的入口缺口另行 `accept`（见 H2 Closeout 的 `H2-R1`、`H2-R8`） | `H1 L13`；`DAR L72`；`DRR L49–L53`、`L97`；`IAR L65`、`L215`；`PD-I L34–L38`；`HAR L45–L47`；`BAR L32`、`L38–L44`；`FSQ L77` |
| `H1-R2` F-02（controller 持有的 epoch、route-local 观察与 no-bypass 的 adapter；精确 API 与三路证明） | RimeBridge Maintainer（`HAR L61`） | `fix`：API 由 Product 钉死并实现，三路 adapter/no-bypass 经 H4 Architecture 关闭；canary/P3D1 保留 `CandidateProviderTypoCorrectionQuery` 外观另行 `accept`（`PD-B L31–L33`） | `H1 L13`；`DAR L73`；`DRR L66–L73`、`L98`、`L101`；`PD-I0 L58–L71`；`IAR L216`；`HAR L51`；`BAR L34`、`L45–L49`；`PD-B L31–L33`；`FSQ L79` |
| `H1-R3` F-03（材料交接、唯一的条件式 Core apply、stale/empty/budget-stop 为 display no-op） | Input Intelligence Maintainer（`HAR L60`） | `fix`：recall 路径唯一 join/apply 由 H2 实现；热路径第二 writer 与 empty/budget-stop 由 H3/H4 处理并经 Architecture 关闭；H2 当时未覆盖部分另行 `accept`（H2 Closeout 的 `H2-R3`） | `H1 L13`；`DAR L74`；`DRR L84–L91`、`L99`；`IAR L217`；`PD-I L42–L45`；`HAR L48–L50`；`BAR L34`、`L45–L49`；`FSQ L79` |
| `H1-R4` coverage-deficit 谓词与生产预算（`DRR L100` 标 `UNKNOWN`，需 Product/实现授权） | Product Lead / Input Intelligence Maintainer | `fix`：由 Product 决定钉死（谓词五条；预算 8/8/3/4；生产第一阶段 12/8 不变）并实现、部分测试 | `DRR L100`；`PLAN L243`；`PD-I0 L38–L43`；`H2 L128–L129`、`L186`（生产第一阶段 `12/8` 不变）；`H2 L161–L186`；`IAR L165–L181`；`IQR L138`、`L140`、`L141`（谓词与字母/中文/最短长度的合取未测，见 H2 的 `H2-R10`） |
| `H1-R5` 一次有界同步调用能否满足目标硬件的交互预算（`UNKNOWN`；不作性能声称） | Human Product Lead | `accept`：父任务已把“整体 CPU/UI/内存”未知作为有界范围接受，不声称性能 Pass | `DRR L102`；`PLAN L246–L247`；`GATE L55`、`L59`；`PERF` 末节（L24 起）。本条把“目标硬件交互预算”归入该台账的“整体性能未知”，见报告“判断点” |
| `H1-R6` operation-receipt 的 schema / 保留期 / 隐私评审（F-04） | Input Intelligence Maintainer（`HAR L64`） | `tech_debt:TYPO-CORRECTION-002-F04-OPERATION-RECEIPT-DIAGNOSTICS`（Human 2026-10-22 确认，本批次在 `docs/TECH_DEBT.md` 文末新建，当前 Open） | `H1 L13`；`DAR L75`；`DRR L103`、`L106–L111`；`PD-I0 L24–L25`；`TD`（文末 F-04 条目） |
| `H1-R7` 真实 RIME、QA-001、INT-003、paired performance、180 ms 及全部可观察产品结果保持 `UNKNOWN` | Human Product Lead | `accept`（父 Gate 台账覆盖，逐项对照见下） | `DAR L79–L81`；`DRR L104`；`H1 L13`；`GATE L42`、`L49–L55`、`L59` |

“运行时行为与全部可观察产品结果、真实 RIME、QA-001、INT-003、paired performance、180 ms 保持 `UNKNOWN`”的父 Gate 台账覆盖核对（逐项对照 `GATE` = `docs/product-decisions/TYPO-CORRECTION-002-PARENT-FINAL-PRODUCT-GATE-001.md`，父任务 `TYPO-CORRECTION-002` 已 Closed）：QA-001 → `GATE L53`（`QR-QA08-01..05` / `AR-QA08-01..04` accept，“实际selection/postselection未验证”）；INT-003 → `GATE L49–L52`（`Q-R2-03` 与 `Q-R2-04` 分别为 tech_debt `INT003-COORDINATOR-INDEPENDENT-ORACLE` / `INT003-RIME-FAILURE-BOUNDARY`，`P2-*` accept）；真实 RIME 失败边界 → `GATE L50`，native 非空查询与 observer 未知 → `GATE L51`、`L55`；paired performance / 整体性能 → `GATE L55` 与 `docs/product-decisions/TYPO-CORRECTION-002-PARENT-PERFORMANCE-SCOPE-PROPOSAL-001.md` 末节“2026-10-11：Human明确批准”（L24 起，“整体CPU/UI/内存及v2总体observer未知原样保留，不声称性能Pass”）；180 ms → `GATE L59`（“不恢复…手动<180ms通过门槛”）；最新集成包的可观察结果 → `GATE L42`（“历史QA包不等于最新集成包…不宣布最新main全部设备/schema已复测”）。该项由父 Gate 台账的整体接受一般性覆盖，不是针对本链的专门条目；Human Product Lead 于 2026-10-22 在 Coordinator 会话中明确 accept 这一映射（本批次评审后记录中另有记录）。台账逐行保持 `UNKNOWN` 或 accept 的边界，本批次不把它们改写成已验证。

**非残项的说明：** `DRR L113–L121` 的 ADR 判断（ADR 0004 无需修订；若实现改变 RIME owner/executor 等才需 ADR 评审）不是残项，仅有触发条件；`IAR L225–L231` 记录实现后 ADR 0004 / 0016 无需修订。本 Close 不引入新的 ADR 事项。

**AUTH 现状与不可重放声明**（只读核对，本批次未修改任何 `docs/authorizations/` 文件）：

- 全链共 34 份文件名含 `RUNTIME-INTEGRATION` 的 AUTH（`docs/authorizations/`）逐份核对（命令见 Executor 报告）：33 份 `status: consumed` 且 `consumption_state: consumed`；唯一例外是 `AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-001`，`status: superseded`、`consumption_state: unconsumed`。本 Assignment 正文引用的 AUTH 中，没有文件名不含 `RUNTIME-INTEGRATION` 的 AUTH。
- 本 Assignment 引用的 AUTH：`AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-DESIGN-001`、`…DESIGN-REVISION-001`、`…HARDENING-CODEX-EXECUTION-001`（`H1 L23`、`L26` 及 Next 行链接）均为 `consumed`。
- 本 Assignment 引用的 AUTH 均为 `consumed`，无需例外记录；上述 `HARDENING-001` 例外项由引用它的 Assignment `TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-001` 的 Closeout 记录，本 Close 不重复处置。仍声明：所属 Assignment 已 Closed；其引用的 AUTH 不得再被消费或重放，任何后续执行须由 Human 另行签发新的 AUTH。

**非声称：** 不是 Release / Release-ready；不声称真实 RIME、QA-001、INT-003、性能或 180 ms 的任何结论（均保持 `UNKNOWN`，其处置以父 Gate 台账为准）；不改父任务 `TYPO-CORRECTION-002`（已 Closed）；未关闭、削弱本表之外的任何残项；没有把 Human 转述的评审升级为独立复核；未关闭名单之外的任何 Assignment（含同链 publication / preparation / final-SHA-quality-publication 子 Assignment）；本 Close 先在本地提交，待 Reviewer 评审及 Human push / PR / merge 后在 `main` 生效。本 Assignment 只涉及设计包，不声称任何实现、运行时或产品行为结论。
