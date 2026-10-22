# Assignment: TYPO-CORRECTION-002-PARENT-REVALIDATION-002 — Four-lane evidence continuation

Policy version: 1.0.0

## Current Status

> **Superseded for current status:** 本 Work Item 于 2026-10-22 在 [`LIFECYCLE-CLOSEOUT-BATCH-1B-001`](lifecycle-closeout-batch-1b-001.md) 下关闭，见文末 [Closeout (2026-10-22)](#closeout-2026-10-22)。
> 其后出现的 Active / Phase / Next（例如 “Runtime-integration implementation Assignment is `Ready`”、 “INT-003/performance capture … remain out of scope”）等叙述均属各自日期的历史，不是当前事实。Lifecycle 值在本改动进入 `main` 时生效。

| Field | Value |
|---|---|
| **Lifecycle** | `Closed` |
| **Phase** | Sidecar lane: Architecture + Quality **bounded Pass** recorded; INT-003 AX retry 03 independently reviewed as Architecture **Conditional Accept** and Quality **Pass with conditions**, but remains inconclusive because `XCUIElement.tap()` cadence was 526.6–880.8 ms; coordinate-touch feasibility produced no fresh product key event; QA-001 revalidation 06 is invalid for the registered phrase because one extra `n` was entered; revalidation 07 proves the exact 22-letter input, real `rime_ice` sidecar activity and visible candidate UI, but the Human did not observe the target candidate; independent Architecture **bounded Pass** (evidence boundary) and Quality **Bounded Pass with conditions** (evidence completeness) retain the case as inconclusive; Product residual is accepted and a same-package retry is not authorized; no candidate selection or interaction checks ran; paired-performance revalidation 03 captured fresh baseline and treatment streams, but the treatment keyboard process changed, so the pair is invalid and no timing conclusion is available; Architecture and Quality independently reviewed that performance boundary, and Product residual disposition is accepted without upgrading the result; the diagnostic smoke and RIME Ice deployment-smoke preconditions passed; parent remains Active |
| **Non-claims** | Sidecar observability remains bounded evidence only. INT-003 attempt 01 is inconclusive and retry 02 produced no runtime evidence. No INT-003, QA-001, paired-performance, Product, Quality, Release or merge Gate is closed. Parent Assignment remains Active. |
| **Next** | QA-001 07 residual is accepted; do not same-package retry. Runtime-integration implementation Assignment is `Ready`; matching AUTH waits for Human live confirmation before Grok copies the pure-Core snapshot. INT-003/performance capture, publication, Gate and parent Close remain out of scope. |
| **Residuals** | Sidecar: SR-02 (Executor-attested setup), startup `unavailable` lifecycle. QA-001 07: Human-attested target absence and UNKNOWN reason, accepted by [`PD-TYPO-CORRECTION-002-QA001-REVALIDATION-07-RESIDUAL`](../product-decisions/TYPO-CORRECTION-002-QA001-REVALIDATION-07-PRODUCT-RESIDUAL.md). |

---

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner continuation instruction in the current Codex task, `2026-09-19 Asia/Shanghai`, after child testability/accessibility PR #140 merged as `162b09fd58ba60538a944026b1902efa405c75aa`.
- **Product Approver:** Human Product Owner acting as Product Lead
- **Parent Assignment:** [`TYPO-CORRECTION-002`](typo-correction-002.md)
- **Predecessor Authorization:** [`AUTH-TYPO-CORRECTION-002-PARENT-REVALIDATION-001`](../authorizations/AUTH-TYPO-CORRECTION-002-PARENT-REVALIDATION-001.md) is not consumed or reused by this Assignment.

## Boundary

This Assignment is a fresh evidence continuation for the still-open parent exits. It has four independently authorized lanes:

1. **Sidecar observability:** establish exact deployed `rime_ice`/schema/archive provenance and direct, content-free observability of the real-RIME sidecar query route and result boundary.
2. **INT-003:** observe cancellable stale-work behavior around the documented 180 ms pause, recording the actual stimulus cadence and preserving an inconclusive result when the cadence is not met.
3. **QA-001:** make a fresh formal attempt on the designated Device Hub iPhone 17 Pro Max / iOS 27 Simulator for the synthetic multi-error phrase, candidate visibility/selection and interaction regression.
4. **Paired performance:** collect a controlled baseline/treatment diagnostic comparison under the same build, device, schema, access state and measurement method.

The lanes share the exact execution snapshot below but receive separate Authorization records and fresh Run IDs. A lane may be stopped without converting another lane's evidence into a pass.

### Non-goals

- No production Swift or Objective-C, KeyboardCore, RimeBridge, schema, vendor archive, search-budget or production-recall change. A test-only coordinate-touch harness is permitted only under [`AUTH-TYPO-CORRECTION-002-INT003-AX-COORDINATE-FEASIBILITY-001`](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-AX-COORDINATE-FEASIBILITY-001.md).
- No `FakeCandidateProvider`, old Ice directory, synthetic RIME fixture or inferred route from candidate counts.
- No live-composition mutation, automatic commit, host injection, `typeText`, pasteboard, `documentContext` or `setMarkedText` as a substitute for keyboard input.
- No physical device substitution for the designated Simulator's QA-001 or paired-performance scope.
- No commit, push, pull request, merge, TestFlight, Release, Product Gate, Quality Gate or Assignment closure.

## Assignment

- **Domain Owner:** Input Intelligence Maintainer
- **Executor:** Input Intelligence Maintainer, acting through the current Codex task and the four bounded lane Authorizations
- **Environment Executor:** Quality, Performance & Release Maintainer for capture and artifact extraction; Human Product Owner as Device Operator for explicitly requested manual keyboard/setup actions
- **Human Dependency:** Human Product Owner / Device Operator supplies only the named Simulator setup and manual keyboard actions when automation cannot safely establish them; unavailable actions remain a blocker and are not fabricated
- **Architecture Reviewer:** Architecture & Knowledge Steward
- **Quality Reviewer:** Quality, Performance & Release Maintainer, independent of the executor capture
- **Product Approver:** Human Product Owner / Product Lead
- **Handoff Target:** Independent Architecture review and consolidated Quality review, then Product Lead for the parent decision; Program Manager receives only source-linked status synchronization

## Required Inputs

- Parent Assignment and Product Contract: [`typo-correction-002.md`](typo-correction-002.md), [`TYPO_CORRECTION.md`](../TYPO_CORRECTION.md)
- Case and contract registry: [`TYPO_BENCHMARK_REGISTRY_V2.md`](../TYPO_BENCHMARK_REGISTRY_V2.md)
- RIME/session and diagnostics boundaries: ADR 0001, 0003, 0004, 0008, 0009, 0010, 0015, 0016; [`DEBUGGING.md`](../DEBUGGING.md)
- Measurement procedure: [`PERFORMANCE_BASELINE.md`](../PERFORMANCE_BASELINE.md)
- Designated target: iPhone 17 Pro Max / iOS 27 Simulator, UDID `06C5BC3E-7599-4761-A1A2-71DAEA991474`, host Messages, synthetic conversation `+1 (888) 555-1212`
- Four lane Authorizations created with this Assignment:
  - [`AUTH-TYPO-CORRECTION-002-SIDECAR-OBSERVABILITY-REVALIDATION-001`](../authorizations/AUTH-TYPO-CORRECTION-002-SIDECAR-OBSERVABILITY-REVALIDATION-001.md)
- [`AUTH-TYPO-CORRECTION-002-INT003-REVALIDATION-001`](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-REVALIDATION-001.md)
- [`AUTH-TYPO-CORRECTION-002-INT003-AX-HARNESS-REVALIDATION-001`](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-AX-HARNESS-REVALIDATION-001.md)
- [`AUTH-TYPO-CORRECTION-002-INT003-AX-HARNESS-REVALIDATION-002`](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-AX-HARNESS-REVALIDATION-002.md)
- [`AUTH-TYPO-CORRECTION-002-INT003-AX-HARNESS-REVALIDATION-003`](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-AX-HARNESS-REVALIDATION-003.md)
- [`AUTH-TYPO-CORRECTION-002-QA001-REVALIDATION-002`](../authorizations/AUTH-TYPO-CORRECTION-002-QA001-REVALIDATION-002.md); supersedes the unconsumed source-stale `…-REVALIDATION-001`
- [`AUTH-TYPO-CORRECTION-002-PERFORMANCE-REVALIDATION-002`](../authorizations/AUTH-TYPO-CORRECTION-002-PERFORMANCE-REVALIDATION-002.md); supersedes the unconsumed source-stale `…-REVALIDATION-001`
- [`AUTH-TYPO-CORRECTION-002-QA001-REVALIDATION-003`](../authorizations/AUTH-TYPO-CORRECTION-002-QA001-REVALIDATION-003.md); fresh Run ID `TC2-SIM-20260919-195848-QA001-REVAL-04`, bound to the passed diagnostic smoke
- [`AUTH-TYPO-CORRECTION-002-PERFORMANCE-REVALIDATION-003`](../authorizations/AUTH-TYPO-CORRECTION-002-PERFORMANCE-REVALIDATION-003.md); fresh Run ID `TC2-PERF-20260919-195848-REVAL-03`, bound to the passed diagnostic smoke
- [`AUTH-TYPO-CORRECTION-002-INT003-AX-HARNESS-REVALIDATION-001`](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-AX-HARNESS-REVALIDATION-001.md)
- [`AUTH-TYPO-CORRECTION-002-INT003-AX-COORDINATE-FEASIBILITY-001`](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-AX-COORDINATE-FEASIBILITY-001.md)

### INT-003 AX-harness amendment — 2026-09-19

The original INT-003 Authorization remains unconsumed and is not reused for the AX-controlled capture. Because the exact parent snapshot predates the merged testability/accessibility child, this bounded amendment permits one local combined snapshot consisting of the parent dirty implementation plus the already-reviewed PR #140 result at `162b09fd58ba60538a944026b1902efa405c75aa`. It authorizes no new product logic and no publication. The combined snapshot receives its own package hashes and Run ID `TC2-SIM-20260919-175102-INT003-AX-REVAL-01`; the earlier sidecar Run Receipt remains bound to its original build.

Attempt 01 is recorded as inconclusive because the external batch used an incorrect key ref and lost stable Universe Keyboard identity. Retry 02 was separately authorized under [`AUTH-TYPO-CORRECTION-002-INT003-AX-HARNESS-REVALIDATION-002`](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-AX-HARNESS-REVALIDATION-002.md), with Run ID `TC2-SIM-20260919-180642-INT003-AX-REVAL-02`, but its UI-test target compile failed before runtime and produced no INT-003 evidence; see [`retry 02 compile block`](../evidence/typo-correction-002-sim-run-2026-09-19-int003-ax-reval-02-compile-blocked.md). Retry 03 is separately authorized under [`AUTH-TYPO-CORRECTION-002-INT003-AX-HARNESS-REVALIDATION-003`](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-AX-HARNESS-REVALIDATION-003.md), with a new source/build/package identity and Run ID. Its fresh receipt records 22 AX key events but 0/21 adjacent intervals below 180 ms, so INT-003 remains inconclusive.

The subsequent low-overhead external-batch attempt was separately authorized
under [`AUTH-TYPO-CORRECTION-002-INT003-AX-LOW-OVERHEAD-REVALIDATION-001`](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-AX-LOW-OVERHEAD-REVALIDATION-001.md), with Run ID `TC2-SIM-20260919-184155-INT003-AX-LOW-OVERHEAD-REVAL-01`. It is recorded as [`low-overhead attempt 01`](../evidence/typo-correction-002-sim-run-2026-09-19-int003-ax-low-overhead-reval-01-inconclusive.md): the batch used system Simplified Pinyin because `Universe Keyboard` was observed as the next keyboard, and the copied artifacts were byte-identical duplicates of retry 03. It provides no INT-003 evidence and its Authorization must not be reused.

### INT-003 coordinate-touch feasibility amendment — 2026-09-19

The Product Lead authorized one test-only implementation and one Simulator
feasibility capture under [`AUTH-TYPO-CORRECTION-002-INT003-AX-COORDINATE-FEASIBILITY-001`](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-AX-COORDINATE-FEASIBILITY-001.md), Run ID `TC2-SIM-20260919-190945-INT003-AX-COORDINATE-FEAS-01`. The permitted source boundary is `UniverseKeyboardUITests/NativeExperienceKeyboardAutomationFeasibilityTests.swift`; it may reduce XCTest action overhead but must preserve exact Universe activation, real coordinate touch delivery, content-free diagnostics and all existing non-claims. This amendment does not authorize production code or any Gate.

The resulting receipt [`coordinate-touch feasibility`](../evidence/typo-correction-002-sim-run-2026-09-19-int003-ax-coordinate-feas-01-inconclusive.md) is inconclusive: the selected XCTest method passed and the AX precondition completed, but the fresh keyboard-extension journal contained only `presentation.appeared` and no `touch.terminal` or `key_highlighted` event. The coordinate implementation therefore does not yet prove product touch delivery or provide an INT-003 cadence; its Authorization is consumed and cannot be reused.

### QA-001 / paired-performance revalidation amendment — 2026-09-19

The source-stale QA/performance Authorizations were not reused after the
coordinate-harness change. New bounded Authorizations bound the current source
identity and the same rebuilt Debug package. QA-001 revalidation 03 is recorded
as [`QA-001 receipt`](../evidence/typo-correction-002-sim-run-2026-09-19-qa001-reval-03-inconclusive.md): the fresh UI capture showed the paused raw composition, but the keyboard journal contained only `presentation.appeared`, with no input or sidecar event; the target candidate and keyboard input route were not independently established. Paired-performance revalidation 02 is recorded as [`performance receipt`](../evidence/typo-correction-002-sim-run-2026-09-19-performance-reval-02-inconclusive.md): BASELINE emitted no product timing events, so TREATMENT was not run and no pair comparison was produced. Both Authorizations are consumed; a retry requires new Authorization/Run IDs and a one-key diagnostic smoke first.

A post-capture read-only preference audit found that
`diagnostics_high_fidelity_expiration = 2026-09-19T10:29:24Z`, before both
fresh journals were created. The visible debug overlay is a separate setting,
and the persistent `rime_diag_log` is not accepted as a replacement for a
fresh process-bound journal. The evidence-grade explanation is therefore an
expired observability window, not a product or performance failure claim. The
later diagnostic smoke re-enabled the bounded window and produced a fresh
`touch.terminal` event, so a future lane can now be captured under a new
Authorization and Run ID.

QA-001 revalidation 04 is recorded as [`QA-001 revalidation 04`](../evidence/typo-correction-002-sim-run-2026-09-19-qa001-reval-04-inconclusive.md):
the fresh keyboard journal contains 46 touch events and 37 candidate
visibility events, but the human operator did not see `我们今天去公园`. No
candidate was selected and the interaction checks were not run. Its
Authorization is consumed; this remains an evidence-grade inconclusive result,
not a product-failure claim.

Paired-performance revalidation 03 is recorded as [`performance revalidation
03`](../evidence/typo-correction-002-sim-run-2026-09-19-performance-reval-03-inconclusive.md).
BASELINE produced a fresh post-cutoff product stream with contextual correction
disabled. TREATMENT produced 70 direct `real_rime_sidecar` queries with the
sidecar enabled, but it started a different keyboard-extension process. The
arms are therefore not comparable under the Authorization; the 1–6 ms values
are retained only as unpaired internal query observations, not as end-to-end or
180 ms performance evidence. The Performance Authorization is consumed and the
parent remains Active.

The same receipt then received an independent Architecture review as
[`performance Architecture review`](../reviews/typo-correction-002-sim-run-2026-09-19-performance-reval-03-architecture-review.md)
with a bounded Pass for the evidence boundary, followed by an independent
Quality review as [`performance Quality review`](../reviews/typo-correction-002-sim-run-2026-09-19-performance-reval-03-quality-review.md)
with a bounded Pass for evidence reconciliation. Both reviews accept the
process mismatch as a hard comparability break and preserve the inconclusive /
not-measurable performance disposition. No Gate or parent Close is implied.

The Product residual disposition is recorded as [`PD-TYPO-CORRECTION-002-PERFORMANCE-REVALIDATION-003-RESIDUAL`](../product-decisions/TYPO-CORRECTION-002-PERFORMANCE-REVALIDATION-003-residual.md).
It accepts PR-01 through PR-04 as bounded evidence limitations and retains PR-05
(candidate recovery, QA-001 and INT-003) as open outside this Run. It does not
authorize a new capture, code change, publication or parent closure.

### Diagnostic observability smoke amendment — 2026-09-19

The Product Owner authorized one precondition-only smoke under
[`AUTH-TYPO-CORRECTION-002-DIAGNOSTIC-SMOKE-001`](../authorizations/AUTH-TYPO-CORRECTION-002-DIAGNOSTIC-SMOKE-001.md),
Run ID `TC2-SIM-20260919-194824-DIAG-SMOKE-01`. It permits no source change,
rebuild, reinstall, schema change or formal lane capture. The operator must
enable high-fidelity diagnostics, verify a future expiration, perform exactly
one ordinary key tap, and produce a fresh process-bound journal containing a
real key event. A failure remains an observability inconclusive result; a pass
only permits requesting separate new Authorizations for QA-001 and paired
performance.

### Simulator App Group/signing reconciliation amendment — 2026-09-20

The Product Owner authorized the docs-only reconciliation under
[`AUTH-TYPO-CORRECTION-002-SIMULATOR-APP-GROUP-RECONCILIATION-001`](../authorizations/AUTH-TYPO-CORRECTION-002-SIMULATOR-APP-GROUP-RECONCILIATION-001.md).
The receipt [`Simulator App Group/signing reconciliation`](../evidence/typo-correction-002-simulator-app-group-signing-reconciliation-2026-09-20.md)
corrects one prior interpretation: the first `CODE_SIGNING_ALLOWED=NO`
package genuinely lacked the Simulator entitlement section, while the later
Simulator package contains the shared App Group in both Mach-O targets and its
runtime log reaches the shared RIME container. The normal local Simulator
`codesign` output is not sufficient to reject that package.

This amendment changes no source, signing setting, package, schema or runtime
state. It does not upgrade the old QA-001 Authorization, does not prove
`rime_ice` deployment, and does not close any Gate. The next action is a fresh
bounded RIME Ice deployment-smoke Authorization and Run ID; no new Run has yet
started. The active boundary is now [`AUTH-TYPO-CORRECTION-002-RIME-ICE-DEPLOYMENT-SMOKE-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RIME-ICE-DEPLOYMENT-SMOKE-001.md),
Run ID `TC2-SIM-20260920-RIME-ICE-SMOKE-01`; it permits one human main-app
deployment action and no Messages input.

### RIME Ice deployment-smoke amendment — 2026-09-20

The deployment-smoke Authorization above was consumed after the Human Product
Owner selected 雾凇 once and reported completion. The post-action UI showed
`雾凇拼音 / 当前使用`, `已部署` and `配置已生效 ✓`. Fresh App Group
provenance recorded `rime_ice`, artifact
`rime-ice-20260630-675d23b0`, archive SHA
`675d23b070be00e1b800f9a6db033ef98f4493cd5b568ed8aa3b3541769c46ac`,
installed-content SHA
`2e906d14853255cd0eba534e2b40791008c2cee65fa5a6e50b40bbd159cb6c26`, and
receipt ID `67A0C52E-A975-47C8-9C09-4ADA1320DF87`. An independent live-tree
check found all 70 admitted files with matching byte counts and hashes and
recomputed the same aggregate content digest. The deployment log ended with
`3 tasks ran: 3 success, 0 failure`, and the App Group preferences reported
`rime_deployed=true`, `rime_deploying=false` and
`rime_needs_deploy=false`.

This is a bounded deployment precondition pass only. It does not upgrade
sidecar observability, INT-003, QA-001 or paired performance and does not
close the parent. The receipt is now ready for independent Architecture and
Quality read-only review; later input captures must use separate fresh
Authorizations and Run IDs.

Evidence: [`RIME Ice deployment smoke receipt`](../evidence/typo-correction-002-sim-run-2026-09-20-rime-ice-deployment-smoke-01.md).

The receipt subsequently received an independent Architecture bounded Pass
and an independent Quality bounded Pass:

- [`Architecture review`](../reviews/typo-correction-002-sim-run-2026-09-20-rime-ice-deployment-smoke-01-architecture-review.md)
- [`Quality review`](../reviews/typo-correction-002-sim-run-2026-09-20-rime-ice-deployment-smoke-01-quality-review.md)

Both reviews retain the archive re-hash residual and explicitly preserve the
non-claims for sidecar behavior, INT-003, QA-001, paired performance and all
Product/Quality/Release lifecycle gates. The parent remains Active.

### QA-001 revalidation 07 independent review amendment — 2026-09-20

Exact-input QA-001 revalidation 07 is recorded as
[`QA-001 revalidation 07`](../evidence/typo-correction-002-sim-run-2026-09-20-qa001-reval-07-inconclusive.md)
under consumed
[`AUTH-TYPO-CORRECTION-002-QA001-REVALIDATION-006`](../authorizations/AUTH-TYPO-CORRECTION-002-QA001-REVALIDATION-006.md),
Run ID `TC2-SIM-20260920-224421-QA001-REVAL-07`. Independent Architecture and
Quality then consumed their dedicated Authorizations:

- [`Architecture review`](../reviews/typo-correction-002-sim-run-2026-09-20-qa001-reval-07-architecture-review.md) — bounded Pass for the evidence boundary
- [`Quality review`](../reviews/typo-correction-002-sim-run-2026-09-20-qa001-reval-07-quality-review.md) — Bounded Pass with conditions for evidence completeness

Both reviews independently re-hashed the three raw artifacts, parsed
sequences 304–516, and retained Human-attested target absence. They do not
upgrade the case to a recovery Pass or a product failure.

The Product Lead then accepted those residuals without a same-package retry:

- [`AUTH-TYPO-CORRECTION-002-QA001-REVALIDATION-07-PRODUCT-RESIDUAL-001`](../authorizations/AUTH-TYPO-CORRECTION-002-QA001-REVALIDATION-07-PRODUCT-RESIDUAL-001.md) — consumed
- [`PD-TYPO-CORRECTION-002-QA001-REVALIDATION-07-RESIDUAL`](../product-decisions/TYPO-CORRECTION-002-QA001-REVALIDATION-07-PRODUCT-RESIDUAL.md) — Accepted

The case remains inconclusive. No Gate or parent Close is implied.

## Exact Execution Snapshot

The parent sidecar worktree is intentionally dirty and is not cleaned or synchronized by this Assignment.

| Field | Bound value |
|---|---|
| Parent worktree | `/private/tmp/universe-keyboard-typo-correction-002-provenance-sidecar` |
| Branch | `codex/typo-correction-002-provenance-sidecar` |
| Worktree HEAD | `9eb83158e49218c1e8f75dbe7dd9e0390db81409` |
| `origin/main` context | `162b09fd58ba60538a944026b1902efa405c75aa` |
| Same-head claim | **Not made**; the parent worktree is behind `origin/main` and contains the parent implementation diff |
| Tracked production/test diff SHA-256 | `c9225a435b833aa1c637c21bead8f85f1465d2b6d161c30a74b5789408c523be` |
| Untracked production/test file-content SHA-256 | `f0ad8759e22deedaa3d5424280c481b2625c550c29609cc70258e3590861ec9d` |
| Snapshot rule | Any source/build/install/schema/device/restarted-capture change invalidates the lane identity and requires a new Run ID and fresh hashes. New governance documents are not treated as source changes. |

## Gates

### Entry Criteria

- [x] Parent Assignment remains Active and this continuation has no `UNKNOWN` responsibility field.
- [x] Child testability/accessibility work is recorded as a separate, merged child; it is not used as parent sidecar/INT/QA/performance evidence.
- [x] The four lane boundaries and non-goals are explicit, with one Authorization per lane.
- [ ] Before each capture: exact source/build identity, signed install identity, App Group availability, active schema, archive/version/SHA-256 and raw-artifact destination are recorded.
- [ ] Before QA-001/performance: the designated Simulator and host are current, Universe Keyboard and Full Access are human-confirmed, and no system-keyboard substitution is present.

### Exit Criteria

- Each lane has a fresh Run Receipt with its own Run ID, source/build/device/schema/provenance identity and raw-artifact SHA-256, or an explicit evidence-grade inconclusive receipt.
- Sidecar evidence directly distinguishes the real-RIME query route, outcome bounds, receipt binding and live-session identity; candidate presence alone is not accepted as route proof.
- INT-003 records the actual inter-key cadence and stale-work/cancellation boundary; below-target manual cadence remains inconclusive.
- QA-001 records candidate visibility/selection and interaction-regression observations on the designated Simulator; absence of the target candidate remains inconclusive rather than a Product failure claim.
- Paired performance reports comparable arms, sample/method limits and diagnostic-only interpretation; it does not invent a Release budget.
- Independent Architecture and Quality review consume only the fresh lane receipts. Product Lead decides any parent Gate or closure separately.

### Stop Conditions

- Any exact source/build/schema/device/provenance identity is missing, inconsistent or cannot be independently read.
- App Group or direct sidecar observability is unavailable, or the route can only be inferred from candidate counts.
- The capture would use a fallback provider, old Ice directory, host injection or live-composition mutation.
- A rebuild, reinstall, schema change, device change or restarted capture is attempted without a newly allocated Run ID.
- The designated Simulator is unavailable for QA-001 or paired performance, or a physical device is proposed as a substitute.
- The work would change production recall/search bounds, RIME schema/vendor content, code or a Product/Quality/Release decision.

## Handoff

- **First handoff:** sidecar observability receipt to Architecture & Knowledge Steward for a narrow provenance/route review.
- **Second handoff:** all completed lane receipts to the independent Quality Reviewer for a consolidated parent revalidation verdict.
- **Final handoff:** Product Lead receives the evidence matrix, explicit residuals and non-claims; no closure is inferred from green tests or a single inconclusive lane.

## Revalidation Trigger

Any source or dirty-diff change, merge/rebase, build or install restart, schema/vendor/archive change, App Group/receipt identity change, device/OS/host change, measurement-method change, production recall-bound change or review finding invalidates the applicable lane and requires a new Authorization/Run ID.

## Closeout (2026-10-22)

- **决定来源：** Human Product Owner（Product Lead）于 2026-10-22 Asia/Shanghai 在 Coordinator 会话中的处置决定，记录于 [`lifecycle-closeout-batch-1-001.md`](lifecycle-closeout-batch-1-001.md) §Remediation round 1（`SR-02`、INT-003 AX reval-03 评审残项、`PR-05` 的处置）；D1（TYPO-CORRECTION-002 子项按批收尾）；D-1B-AUTH 确认方案。本 Close 在任务 `LIFECYCLE-CLOSEOUT-BATCH-1B-001` 下由 Executor 回到原文核实来源后写入，基线 `origin/main` `cd0b850cce7f22781c03fb9e66a4590be4357100`。
- **证据指针：** 父任务 Gate `docs/product-decisions/TYPO-CORRECTION-002-PARENT-FINAL-PRODUCT-GATE-001.md`（父任务已 Closed）；`docs/product-decisions/TYPO-CORRECTION-002-QA001-REVALIDATION-07-PRODUCT-RESIDUAL.md`、`…-PERFORMANCE-REVALIDATION-003-residual.md`、`…-RIME-ICE-DEPLOYMENT-PRODUCT-RESIDUAL.md`（本文件引用或以本 Assignment 为 Parent 的三份 Product 残项决定）；sidecar / AX reval-03 / performance reval-03 / QA-001 07 / rime-ice smoke 的 Architecture 与 Quality 评审（见下表）。

**残项处置表**（ID | owner | 处置 | 来源指针）：

| ID | owner | 处置 | 来源指针 |
|---|---|---|---|
| `SR-01`（包 SHA-256 未从安装重算） | Quality | Closed for this lane（既有处置） | `docs/reviews/typo-correction-002-sim-run-2026-09-19-sidecar-reval-01-quality-review.md` 第 53 行 |
| `SR-02`（键盘选择 / Full Access / high-fidelity 设置为 Executor 自述） | Quality / Human | `accept`，指向父 Gate（Human 决定） | 同一 Quality 评审第 54、64 行；Architecture 评审第 117 行；父 Gate 第 51、55 行。注：仓库内没有一条记录点名 `SR-02` 的 Product 处置，这条对应是 Human 的决定 |
| `SR-03`、`SR-04` | Architecture / Quality | Accept（既有处置） | Quality 评审第 55、56 行 |
| startup `route=unavailable` 生命周期 | Architecture | accept（既有处置） | Architecture 评审第 120 行；Quality 评审第 58、65 行；`…PERFORMANCE-REVALIDATION-003-residual.md` 第 56 行（`PR-02`） |
| INT-003 AX reval-03 Architecture 残项（3 条：stale-work 取消仍 inconclusive；`XCUIElement.tap()` 仅证明 AX 可达；QA-001 与 paired performance 未建立） | Architecture | `accept`，指向父 Gate（Human 决定） | `docs/reviews/typo-correction-002-sim-run-2026-09-19-int003-ax-reval-03-architecture-review.md` 第 27–33 行 |
| INT-003 AX reval-03 Quality 残项（3 条：无合格 rapid stimulus 与取消标记；无 QA-001 / 性能 / 语义结论；receipt 仍为 Executor-recorded） | Quality | `accept`，指向父 Gate（Human 决定） | `…int003-ax-reval-03-quality-review.md` 第 21–30 行 |
| `PR-01…PR-04`（性能 reval-03） | Quality / Product | Product Accepted（既有处置） | `…PERFORMANCE-REVALIDATION-003-residual.md` 第 55–58 行 |
| `PR-05`（候选恢复、QA-001、INT-003 保持独立开放） | Product / Quality | `accept`，指向父 Gate（Human 决定） | 同 Product 决定第 59 行 “Retained open outside this Run”；性能 Quality 评审第 181 行 |
| QA-001 07：`AR-QA07-01/02/03`、`QR-QA07-01/02/03/04` | Architecture / Quality | Product Accepted（既有处置） | `…QA001-REVALIDATION-07-PRODUCT-RESIDUAL.md` 第 61–66 行 |
| rime-ice smoke：`QR-01` / `AR-01`（下载的归档文件未单独重算 SHA）、`QR-02`（文档 HEAD 不同于已安装包 source） | Architecture / Quality | Product Accepted（既有处置）：`QR-01 / AR-01` “Accepted for this deployment precondition”，`QR-02` “Accepted with exact package binding” | `docs/product-decisions/TYPO-CORRECTION-002-RIME-ICE-DEPLOYMENT-PRODUCT-RESIDUAL.md` 第 24、25 行；第 49 行 “closes the Product disposition of QR-01/QR-02”；评审 `…rime-ice-deployment-smoke-01-architecture-review.md` 第 66–70 行、`…-quality-review.md` 第 48–53 行 |

其余 lane（INT-003 attempt 01 / retry 02 / retry 03 / low-overhead / coordinate feasibility，QA-001 revalidation 03 / 04 / 06，performance revalidation 02，diagnostic smoke，Simulator App Group 对账）只有 “inconclusive” 回执，没有独立评审的残项表；其未建立目标由 `PR-05` 与 AX reval-03 残项的 Human 决定覆盖。

**AUTH 现状与不可重放声明**（只读核对，本批次未修改任何 `docs/authorizations/` 文件）：

- `AUTH-TYPO-CORRECTION-002-INT003-REVALIDATION-001`：`docs/authorizations/AUTH-TYPO-CORRECTION-002-INT003-REVALIDATION-001.md` 第 7 行 `Status | active — unconsumed`。
- `AUTH-TYPO-CORRECTION-002-PARENT-REVALIDATION-001`：`docs/authorizations/AUTH-TYPO-CORRECTION-002-PARENT-REVALIDATION-001.md` 第 7 行 `Status | active — bounded evidence revalidation only`，第 28 行 `"status": "active"`，第 103 行 `"consumption_state": "active"`。
- 声明：所属 Assignment 已 Closed；这两份 AUTH 不得再被消费或重放；任何后续采集或复核须由 Human 另行签发新的 AUTH。处置：`accept`（Human 2026-10-22 确认的 D-1B-AUTH）。`docs/TECH_DEBT.md` 的 `TD-014`（第 264 行）是同类问题（AUTH consumption_state 卫生）的既有登记，仅作引用，本 Close 不修改它，也不把它当作这两份 AUTH 的处置。

**非声称：** 不是 Release / Release-ready；不是 INT-003、QA-001 或 paired-performance 的 Pass 或 Gate；不改父任务 `TYPO-CORRECTION-002`（已 Closed）；未关闭、削弱本表之外的任何残项；本 Close 先在本地提交，待 Reviewer 评审及 Human push / PR / merge 后在 `main` 生效。
