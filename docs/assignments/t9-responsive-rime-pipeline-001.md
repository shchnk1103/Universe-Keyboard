# Assignment: T9-RESPONSIVE-PIPELINE-001 — 九宫格响应式 RIME 输入管线

**Policy version:** `1.0.0`  
**Lifecycle status:** `Active — ADR 0025 Accepted; ALL-LAYOUTS-001 Completed; RESPONSIVE-DEFAULT-ON-001 Product Gate dual-gate Release default-on Active (2026-08-06); CANARY Stop/Retain history retained; no SLO claim`
**Task ID:** `T9-RESPONSIVE-PIPELINE-001`  
**Repository change types (authorized through R1):** `Documentation`,
`Implementation` (KeyboardCore pure pipeline only), `Tests`  
**Repository change types (later, per-phase Product authorization):**
`Implementation` (RimeBridge / Extension wiring), `Diagnostic Evidence`  
**Product Decision:**
[`PD-T9-RESPONSIVE-PIPELINE-001`](../product-decisions/T9-RESPONSIVE-PIPELINE-001-authorization.md)  
**Plan:**
[`t9-responsive-rime-pipeline-plan.md`](../plans/t9-responsive-rime-pipeline-plan.md)  
**Architecture (Proposed):**
[`ADR 0025`](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md)  
**Predecessor (Hold/harvest, not closed):**
[`T9-AUTO-ANCHOR-001`](t9-auto-anchor-001.md)

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:**
  [`PD-T9-RESPONSIVE-PIPELINE-001`](../product-decisions/T9-RESPONSIVE-PIPELINE-001-authorization.md);
  Human Product Owner design-phase instruction
  “开始 T9-RESPONSIVE-PIPELINE-001 第一阶段（仅 KOS 建档与架构设计）”,
  `2026-07-30 Asia/Shanghai`; R1 implementation authorized by Human Product
  Owner / Product Lead on `2026-07-30 Asia/Shanghai` (Fake RIME state machine
  and regression tests only; no real session migration; no Release default
  change); decision lineage includes Codex task
  `019f9dac-ff8d-7872-a913-d5dd3f930dc1`
- **Product Approver:** Human Product Owner acting as Product Lead

## Assignment

- **Domain Owner:** 🧠 Input Intelligence Maintainer
- **Executor:** Current Grok session for R0 design/docs and authorized R1
  KeyboardCore pipeline + tests; later phases require a fresh Product-named
  Executor acknowledgement after phase authorization
- **Environment Executor:** Current Grok session for local `swift test` on
  KeyboardCore; Human Product Owner remains the physical-device input operator
  for third-party keyboard evidence (R5+)
- **Human Dependency:** Human Product Owner for per-phase implementation
  authorization, physical-device Reminders A/B, Product Gate and any SLO lock
- **Architecture Reviewer:** 🏛️ Architecture & Knowledge Steward
- **Quality Reviewer:** 🧪 Quality, Performance & Release Maintainer
- **Handoff Target (R1 exit):** Independent Architecture and Quality review of
  R1 deliverables; then Human Product Owner for optional R2 authorization

### Spike-P1-3 reassignment / acknowledgement

- **Decision Source / Date:** Human Product Owner / Product Lead authorization
  in the active Codex task, `2026-07-30 Asia/Shanghai`.
- **Executor:** Current Codex task as the Product-designated subsequent
  Executor, limited to Spike-P1-3 design, disconnected Fake proof, tests and
  evidence.
- **Environment Executor:** Current Codex task for local KeyboardCore tests.
- **Handoff Target:** Role-isolated Architecture and Quality reviewers; after
  in-scope findings are remediated/re-reviewed, Human Product Owner for the
  next Product decision.
- **Acknowledgement:** accepted with explicit exclusions: no real librime
  wiring, R4/R5/R6, ADR Accept, Product Gate or Release default-on.

### R4-Owner reassignment / acknowledgement

- **Decision Source / Date:** Human Product Owner authorization in the active
  Grok session, `2026-07-31 Asia/Shanghai` — “先进行设计，然后执行，然后审查”,
  with KOS 2.0 role switching.
- **Domain Owner:** 🧠 Input Intelligence Maintainer
- **Executor:** Current Grok session for R4-Owner design handoff consumption,
  KeyboardCore owner-contract implementation and focused/full tests only.
- **Environment Executor:** Current Grok session for local `swift test` on
  KeyboardCore.
- **Architecture Reviewer:** 🏛️ Architecture & Knowledge Steward (design freeze
  author + independent design/implementation review; implementation self-review
  is not independent Architecture Pass).
- **Quality Reviewer:** 🧪 Quality, Performance & Release Maintainer (independent).
- **Handoff Target:** Independent Architecture and Quality reviewers; then Human
  Product Owner for optional R4-B authorization.
- **Acknowledgement exclusions:** no Extension/`RimeEngineImpl` production wire;
  no R4-B Simulator real-librime matrix; no R5/R6; no ADR 0025 Accept; no Product
  Gate; no Release default-on; no auto-anchor expansion.

### R4-B reassignment / acknowledgement

- **Decision Source / Date:** Human Product Owner authorization in the active
  Grok session, `2026-07-31 Asia/Shanghai` — complete R4-B under KOS 2.0.
- **Domain Owner (primary):** 🔧 RIME Platform Maintainer (real `RimeEngineImpl`
  bootstrap + RimeBridge tests)
- **Secondary domain:** 🧠 Input Intelligence Maintainer (thread-affine owner
  contract / iOS availability only as required)
- **Executor:** Current Grok session for R4-B design consumption, RimeBridge
  bootstrap + tests, optional harness script, KeyboardCore availability fix if
  required for iOS Simulator, and evidence.
- **Environment Executor:** Current Grok session for local/simulator
  `xcodebuild test` / package tests; Human remains physical-device operator (R5).
- **Architecture / Quality Reviewers:** independent Steward / Quality roles.
- **Handoff Target:** Independent Arch + Quality; then Human Product Owner for
  optional wiring / R5 authorization.
- **Acknowledgement exclusions:** no Extension production wire of thread-affine
  owner; no Release default-on; no ADR 0025 Accept; no Product Gate; no R5/R6;
  no auto-anchor expansion.

### P1-D2 Amendment B reassignment / acknowledgement

- **Decision Source / Date:** Human Product Owner / Product Lead selected option B
  in the active Codex task, `2026-08-01 Asia/Shanghai`.
- **Domain Owner:** 🧠 Input Intelligence Maintainer.
- **Executor:** Current Codex task, limited to the Proposed Amendment/design,
  KeyboardCore visual-shadow presentation, fail-closed guards and focused
  regression tests.
- **Environment Executor:** Current Codex task for local KeyboardCore focused
  and full package tests.
- **Human Dependency:** Human Product Owner is not required for local tests;
  any device, Release, Product Gate or risk-acceptance step remains a separate
  dependency and is out of this Assignment slice.
- **Architecture Reviewer:** 🏛️ Architecture & Knowledge Steward, independent
  of the Executor implementation.
- **Quality Reviewer:** 🧪 Quality, Performance & Release Maintainer,
  independent of the Executor implementation.
- **Handoff Target:** Independent Architecture and Quality re-review, then
  Human Product Owner for disposition; no automatic R6 or Release promotion.
- **Acknowledgement exclusions:** no real RIME/Extension wiring, no default-on,
  no ADR 0025 Accept, no Product Gate, no R6, no auto-anchor expansion.

## Acknowledgement And Activation

- **Product Assignment Decision:** `2026-07-30 Asia/Shanghai` — responsive
  pipeline product direction recorded; R0 design authorized; no required field
  is `UNKNOWN`.
- **Executor acknowledgement (R0):** `2026-07-30 Asia/Shanghai` — Scope limited to
  KOS governance + design; no production code; stop after R0 deliverables.
- **Executor acknowledgement (R1):** `2026-07-30 Asia/Shanghai` — Fake RIME
  responsive state machine + regression tests only; no `RimeEngineImpl`
  migration; no `KeyboardController` default-path change; no Release default
  change; stop after R1 evidence for independent review.
- **Entry Criteria status (R0):** **Met.**
- **Entry Criteria status (R1):** **Met** after Human Product Owner design
  acceptance and explicit R1 authorization.
- **Product lifecycle decision:** `Active` under R1 scope. R2+ remains
  unauthorized until a later explicit Product instruction.

## Boundary

### Scope (R0 — authorized now)

1. Record Product Decision, Assignment, plan and Proposed ADR 0025.
2. Audit current MainActor-synchronous RIME path against ADR 0004, input
   pipeline, shared-container lifecycle and Swift 6 ownership docs.
3. Define state/event model: pending input queue, `revision`, `sessionEpoch`,
   atomic UI snapshot publish, fail-closed stale selection.
4. Define automated and Human device acceptance matrices for later phases.
5. Link predecessor auto-anchor Hold/harvest without rewriting its history.
6. Update navigation mirrors (`KNOWLEDGE_INDEX`, optional Dashboard note).

### Scope (R1 — authorized and implemented)

1. Add pure `ResponsiveRimePipeline` in KeyboardCore (accept / ordered queue /
   `revision` / `sessionEpoch` / publish policy / fail-closed selection).
2. Controllable Fake RIME delay via `SleepingResponsiveRimeClock` (including a
   150 ms experiment case).
3. Regression tests for accept-without-wait, order, stale revision, epoch bump,
   latest-only publish, Delete / candidate / Path / reset, and controller
   default-path isolation.
4. **Do not** wire into production `KeyboardController` or `RimeEngineImpl`.
5. **Do not** change Release default behavior.

### Scope (later — not authorized until Product says so)

| Phase | Work |
|---|---|
| R1 | Controllable Fake RIME (e.g. 150 ms/key) + responsive state machine tests in KeyboardCore — **done 2026-07-30** |
| R2 | Dedicated serial RIME owner; all session APIs serialized; Release default off |
| R3 | Delete / candidate / Path / recover / visibility contracts on the versioned model |
| R4 | Simulator + real librime integration evidence |
| R5 | Human Reminders A/B with content-free App logs |
| R6 | Independent Architecture, Quality and Product Gate |

### Non-goals

- Expanding auto-anchor attempt count or enabling auto-anchor by default
- Renaming this work as auto-anchor S2.4 / S3
- Merging or dropping RIME input events in v1 to improve throughput
- Weakening digit-host safety, Path authority, Partial Commit or 26-key contracts
- `@unchecked Sendable` or isolation bypass to “make it compile”
- Formal numeric product SLO invention without baseline evidence
- Coordinate-driven XCTest / Computer Use typing into third-party keyboards
  for device performance claims
- Commit/push/PR as part of R0 authorization
- Executor self-declaring Architecture / Quality / Product Gate pass

### Required Inputs

- `AGENTS.md`, `ASSIGNMENT_POLICY.md`, `DOCUMENTATION_GOVERNANCE.md`
- `PROJECT_CONTEXT.md`, `PERFORMANCE_BASELINE.md`, `DEBUGGING.md`, `TECH_DEBT.md`
- `architecture/input-pipeline-and-marked-text.md`
- `architecture/shared-container-and-rime-lifecycle.md`
- `architecture/swift6-migration.md`
- ADR 0004, 0010, 0018, 0020–0024
- Predecessor plan/assignment/decision/evidence:
  [`t9-long-composition-process-key-latency-plan.md`](../plans/t9-long-composition-process-key-latency-plan.md),
  [`t9-auto-anchor-001.md`](t9-auto-anchor-001.md),
  [`T9-AUTO-ANCHOR-001-authorization.md`](../product-decisions/T9-AUTO-ANCHOR-001-authorization.md),
  [`t9-auto-anchor-s23-b3b3e-2026-07-30.md`](../evidence/t9-auto-anchor-s23-b3b3e-2026-07-30.md),
  [`t9-long-composition-process-key-latency-2026-07-26.md`](../evidence/t9-long-composition-process-key-latency-2026-07-26.md)
- Playbooks: coordinator, debug-investigator, keyboard-core, rime-bridge,
  keyboard-ui, test-release
- Baseline branch/commit for design start: `codex/t9-auto-anchor-s5-checkpoint`
  @ `dddbe61`

## Gates

### Entry Criteria — R0

- [x] Product direction stops auto-anchor expansion and names responsive pipeline
- [x] No required Assignment field is `UNKNOWN`
- [x] Executor acknowledged design-only scope
- [x] Predecessor evidence remains readable and is not rewritten as success

### Exit Criteria — R0

- [x] Product Decision recorded
- [x] Assignment complete (no `UNKNOWN`)
- [x] Plan with R0–R6 and acceptance matrix recorded
- [x] Proposed ADR 0025 describes serial owner, revision/sessionEpoch, atomic
  publish and relationship to ADR 0004
- [x] Predecessor plan/assignment carry successor links only
- [x] Explicit statement: production code unchanged in R0
- [x] Human Product Owner design acceptance + R1 authorization
  (`2026-07-30 Asia/Shanghai`)

### Exit Criteria — R1

- [x] Fake RIME can delay each engine call by a controllable amount (including
  150 ms experiment case).
- [x] Main pipeline `accept` receives the full frozen sequence without calling
  RIME before `drain`.
- [x] No dropped, duplicated or reordered keys under delayed Fake RIME.
- [x] Stale revision results cannot overwrite newer state.
- [x] `sessionEpoch` bump invalidates pending work and starts a new revision
  space.
- [x] UI snapshot publish may coalesce to latest only (`.latestOnly`).
- [x] Content-free diagnostics: fixture ID, revision, queue depth, timings.
- [x] Focused `ResponsiveRimePipelineTests` pass; controller default RIME path
  remains synchronous.
- [x] Independent Architecture review of R1 — **Pass with conditions**
  ([review](t9-responsive-pipeline-001-r1-architecture-review.md); 0 P0, 3 P1)
- [x] Architecture P1 remediation + **re-review Pass** (2026-07-30) —
  ([rereview](t9-responsive-pipeline-001-r1-architecture-rereview.md); P1-1/2/3
  **Closed**; 0 P0, 0 P1). ADR 0025 remains **Proposed**. Does **not**
  authorize R2 or claim Product Gate
- [x] Independent Quality review of R1 — **Pass with conditions**
  ([review](t9-responsive-pipeline-001-r1-quality-review.md); 0 P0, 0 P1)
- [x] R2 authorization — **granted 2026-07-30**; default-off serial owner +
  deferred key path implemented
- [x] Independent Architecture review of R2 — **Pass with conditions**
  ([review](t9-responsive-pipeline-001-r2-architecture-review.md); 0 P0, 3 P1)
- [x] Independent Quality review of R2 — **Pass with conditions**
  ([review](t9-responsive-pipeline-001-r2-quality-review.md); 0 P0, 1 P1)
- [x] R2 P1 remediation (2026-07-30) — bridge + presentation
  ([evidence](../evidence/t9-responsive-pipeline-r2-p1-remediation-2026-07-30.md))
- [x] Independent Architecture **re-review** of R2 P1 — **Pass with conditions**
  ([rereview](t9-responsive-pipeline-001-r2-architecture-rereview.md):
  P1-1 dual-entry **Closed**, P1-2 publish→UI **Closed**, P1-3 off-main
  **Still open**). Not ADR Accept / not full §10 final form.
- [x] Independent Quality **re-review** of R2 P1 — **Pass with conditions**
  ([rereview](t9-responsive-pipeline-001-r2-quality-rereview.md): Quality P1
  presentation bridge **Closed**; re-ran 33/811 green). Keep gate default off;
  not wide Debug/device enablement confidence.
- [x] Phase A freeze (2026-07-30) —
  ([freeze](t9-responsive-pipeline-001-phase-a-freeze-2026-07-30.md)); PR #34
  not urgent to merge
- [x] R3 authorization — **granted 2026-07-30** (Product: 先A后B，B授权实现)
- [x] R3 implementation (Executor) — Path/auto-anchor context; chrome unwrap;
  handle key→delete tests; default-off
- [x] Independent Architecture review of R3 — **Pass with conditions**
  ([review](t9-responsive-pipeline-001-r3-architecture-review.md); 0 P0, 2 P1)
- [x] Independent Quality review of R3 — **Pass with conditions**
  ([review](t9-responsive-pipeline-001-r3-quality-review.md); 0 P0, 1 P1)
- [x] R3 P1 remediation (2026-07-30) — context/epoch + reentrancy
  ([evidence](../evidence/t9-responsive-pipeline-r3-p1-remediation-2026-07-30.md))
- [x] Independent Architecture **re-review** of R3 P1 — **Pass with conditions**
  ([rereview](t9-responsive-pipeline-001-r3-architecture-rereview.md):
  R3 P1-1/P1-2 **Closed**; Arch **P1-3 off-main Still open**). Not ADR Accept.
- [x] Independent Quality **re-review** of R3 P1 — **Pass with conditions**
  ([rereview](t9-responsive-pipeline-001-r3-quality-rereview.md): Quality P1 +
  reentrancy **Closed**; re-ran 38/816 green). Keep gate default off.
- [ ] Product Gate — **not claimed**
- [x] Spike-P1-3 design + falsifiable Fake proof — **granted 2026-07-30**
- [x] Spike-P1-3 independent Architecture / Quality review at `45c426f` —
  **Fail**, shared lifecycle P1
- [x] Spike-P1-3 lifecycle P1 remediation + independent Architecture /
  Quality **re-review Pass with conditions** (2026-07-31) —
  focused 7/7, full 823/823; residual Arch P2 factory/delivery/mailbox for R4
  ([arch rereview](t9-responsive-pipeline-001-spike-p1-3-architecture-rereview.md),
  [quality rereview](t9-responsive-pipeline-001-spike-p1-3-quality-rereview.md),
  [evidence](../evidence/t9-responsive-pipeline-spike-p1-3-2026-07-30.md))
- [x] R4-Owner (Arch P2 owner contract) — **granted 2026-07-31** Human Product
  Owner; design → implement → dual independent review; disconnected; gate off
- [x] R4-Owner independent Architecture / Quality — **Pass with conditions**
  (2026-07-31); focused 10/10, full 826/826; D1–D3 Closed in scope
  ([arch](t9-responsive-pipeline-001-r4-owner-architecture-review.md),
  [quality](t9-responsive-pipeline-001-r4-owner-quality-review.md),
  [evidence](../evidence/t9-responsive-pipeline-r4-owner-2026-07-31.md))
- [x] R4-B real librime bootstrap + Simulator evidence — **granted 2026-07-31**
  Human Product Owner; design → implement → dual review; default-off;
  **no** Extension production wire / ADR Accept / Product Gate
- [x] R4-B independent Architecture / Quality — **Pass with conditions**
  (2026-07-31); Simulator real-engine 2/2 + machine line; KeyboardCore 10/826
  ([arch](t9-responsive-pipeline-001-r4-b-architecture-review.md),
  [quality](t9-responsive-pipeline-001-r4-b-quality-review.md),
  [evidence](../evidence/t9-responsive-pipeline-r4-b-2026-07-31.md))
- [x] R4-Wire thread-affine controller wire — **granted 2026-07-31** Human Product
  Owner; dual gate default-off; design → implement → dual review
- [x] R5-Preflight (Debug dual-gate arm + content-free logs) — **granted
  2026-07-31**; dual Arch/Quality **Pass with conditions**; implementation tip
  `87d3e7c`; optional physical path on/off **Pass** same day
  ([design](t9-responsive-pipeline-001-r5-preflight-design.md),
  [arch](t9-responsive-pipeline-001-r5-preflight-architecture-review.md),
  [quality](t9-responsive-pipeline-001-r5-preflight-quality-review.md),
  [evidence](../evidence/t9-responsive-pipeline-r5-preflight-2026-07-31.md))
- [x] Formal R5 Human Reminders A/B — **granted 2026-07-31**; **Closed direction FAIL**
  ([design](t9-responsive-pipeline-001-r5-formal-design.md),
  [evidence](../evidence/t9-responsive-pipeline-r5-formal-2026-07-31.md))
- [x] R5-Remediation **design** — **granted 2026-07-31**
  ([design](t9-responsive-pipeline-001-r5-remediation-design.md))
- [x] R5-Rem-1 + R5-Rem-2 **implementation** — **granted 2026-07-31**; Executor
  complete; dual Arch/Quality **Pass with conditions**; Arch **P1-1 Closed**
  ([evidence](../evidence/t9-responsive-pipeline-r5-rem-1-2-2026-07-31.md),
  [arch](t9-responsive-pipeline-001-r5-rem-1-2-architecture-review.md),
  [quality](t9-responsive-pipeline-001-r5-rem-1-2-quality-review.md))
- [x] R5-Rem-Device Human re-pair — **granted 2026-07-31**; **Closed direction PASS**
  ([evidence](../evidence/t9-responsive-pipeline-r5-rem-device-2026-07-31.md))
- [x] Publication — PR [#37](https://github.com/shchnk1103/Universe-Keyboard/pull/37)
  merged into preflight then [#36](https://github.com/shchnk1103/Universe-Keyboard/pull/36)
  into `main` @ `7665c64` (2026-07-31); feature branches deleted after reachability
- [x] R5-Rem-3 **design freeze** — authorized 2026-07-31; dual Arch/Quality design
  reviews **Pass with conditions** @ `617773e`; **Amendment A** closes Arch P1-1…P1-4
  ([design](t9-responsive-pipeline-001-r5-rem-3-design.md),
  [arch](t9-responsive-pipeline-001-r5-rem-3-architecture-review.md),
  [quality](t9-responsive-pipeline-001-r5-rem-3-quality-review.md))
- [x] R5-Rem-3 **implementation** — **granted 2026-07-31** (Product option 1);
  Executor complete; dual review **Pass with conditions** + **P1 remediation**;
  full KeyboardCore **852/0**
  ([evidence](../evidence/t9-responsive-pipeline-r5-rem-3-2026-07-31.md),
  [arch](t9-responsive-pipeline-001-r5-rem-3-implementation-architecture-review.md),
  [quality](t9-responsive-pipeline-001-r5-rem-3-implementation-quality-review.md))
- [x] R5-Rem-3-Device — **granted 2026-08-01**; **Closed direction PASS**
  (key-follow + L1 provisional markers) **with residual P1 chrome flicker at the
  pre-Polish-2 checkpoint**
  ([design](t9-responsive-pipeline-001-r5-rem-3-device-design.md),
  [evidence](../evidence/t9-responsive-pipeline-r5-rem-3-device-2026-08-01.md));
  teardown gate-off done; **not** Product Gate
- [x] R5-Rem-3-Polish — **granted 2026-08-01** (Product option 1); Polish-2
  host-preedit-only L1 + device re-pair **PASS** (chrome stable)
  ([evidence](../evidence/t9-responsive-pipeline-r5-rem-3-polish-2026-08-01.md));
  teardown gate-off done; current-tip independent Arch/Quality **Pass with
  conditions** triggered P1-D2 Amendment B (the stale-chrome contract is now
  product-selected and bounded-implemented)
  ([arch](t9-responsive-pipeline-001-r5-rem-3-polish-architecture-review.md),
  [quality](t9-responsive-pipeline-001-r5-rem-3-polish-quality-review.md))
- [x] P1-D2 Amendment B — Product-selected stable shadow anchor, stable stale
  chrome and fail-closed actions; Executor focused **16/0**, full **858/0**;
  final independent Architecture and Quality **Pass with conditions**; P1-1/P1-2
  closed; follow-up P2 regression matrix opened
  ([evidence](../evidence/t9-responsive-pipeline-p1-d2-amendment-b-2026-08-01.md),
  [Architecture](t9-responsive-pipeline-001-p1-d2-amendment-b-architecture-rereview-2.md),
  [Quality](t9-responsive-pipeline-001-p1-d2-amendment-b-quality-rereview-2.md))
- [x] P2-Regression-Matrix-001 — **bounded Core subset Pass with conditions**:
  stale action matrix, settled stale-chrome snapshot and epoch/abandon
  marked-text history contracts; focused **19/0**, full **861/0**; P2-EPC closed
  at bounded Core/Fake-host layer; Extension prefetch, owner-call/UI observation
  and real-device/performance evidence remain open
  ([assignment](t9-responsive-pipeline-001-p2-regression-matrix.md),
  [evidence](../evidence/t9-responsive-pipeline-p2-regression-matrix-2026-08-01.md),
  [Architecture](t9-responsive-pipeline-001-p2-regression-matrix-architecture-rereview.md),
  [Quality](t9-responsive-pipeline-001-p2-regression-matrix-quality-rereview.md))
- [ ] Release default-on / Product Gate / ADR 0025 Accept / R6 — **not granted**

### Exit Criteria — R5-Remediation design

- [x] Root-cause freeze (RC1–RC4) from Formal R5 FAIL
- [x] L0/L1/L2 layer split; presentation vs engine-apply split
- [x] Content-free felt metrics contract (accept→visible, publish lag, burst)
- [x] Ranked options O1–O3 + recommended sequence
- [x] Phase map Rem-1…Rem-Device; non-claims; Product implementation template
- [x] Implementation authorization for Rem-1+2 (2026-07-31)

### Exit Criteria — R5-Rem-1 + R5-Rem-2 (Executor)

- [x] ACCEPT / VISIBLE / PUBLISH lag / BURST markers + unit tests
- [x] Dual-gate presentation coalesce under pending threshold
- [x] MainActor R2 true latestOnly (no force everyResult)
- [x] R3 context last-head under coalesce
- [x] Focused + full KeyboardCore green (841/0)
- [x] Independent Architecture review — **Pass with conditions**
  ([review](t9-responsive-pipeline-001-r5-rem-1-2-architecture-review.md); 0 P0, **1 P1** at review time)
- [x] Independent Quality review — **Pass with conditions**
  ([review](t9-responsive-pipeline-001-r5-rem-1-2-quality-review.md); re-run 48+841/0; 0 P0, 0 P1)
- [x] Arch **P1-1 Closed** — presentation generation + live epoch gate +
  `testDualGateAbandonDropsDeferredCoalescedPresentation` (2026-07-31)
- [x] Device re-pair Rem-Device — **granted 2026-07-31**; **Closed direction PASS**
  ([evidence](../evidence/t9-responsive-pipeline-r5-rem-device-2026-07-31.md));
  dual-gate key-feel better than A; no freeze-then-burst; not Product Gate

### Exit Criteria — Formal R5

- [x] Design freeze D1–D5 recorded
  ([design](t9-responsive-pipeline-001-r5-formal-design.md))
- [x] Arm A install: Debug dual-gate OFF prepared; Human Arm A metrics recorded
- [x] Arm B install: Debug dual-gate ON prepared; Human Arm B metrics recorded
- [x] One valid Human A→B pair on frozen fixture (stop-fast; pairs 2–3 not needed)
- [x] Content-free metrics table + subjective scores
  ([evidence](../evidence/t9-responsive-pipeline-r5-formal-2026-07-31.md))
- [x] Direction verdict per D5: **FAIL** (B freeze-then-burst worse than A)
- [x] Architecture path-identity + KEY END metric honesty note
- [x] Quality evidence binding to tip `87d3e7c` + arm hashes
- [x] Teardown to gate-off; non-claims recorded
- [x] Product disposition: Formal R5 Closed as direction FAIL (not Product Gate)

### Exit Criteria — R5-Preflight

- [x] Design freeze D1–D4 (arm resolution, no dual live MainActor session,
  content-free markers, operator prep).
- [x] Implementation tip `87d3e7c` + KeyboardCore preflight tests (5 focused /
  836 full at dual review).
- [x] Independent Architecture review — **Pass with conditions**.
- [x] Independent Quality review — **Pass with conditions**.
- [x] Physical device path ON: `path=thread-affine dualGateActive=1` + READY +
  PUBLISH (iPhone 13 Pro, 2026-07-31).
- [x] Physical device path OFF after teardown: `path=sync dualGateActive=0`, no
  owner-thread READY / R5P PUBLISH.
- [x] Device restored to gate-off Debug; dualGate key false.
- [x] Explicit non-claims recorded (no formal R5 / ADR Accept / Product Gate /
  default-on / subjective non-stutter).

### Exit Criteria — Spike-P1-3

- [x] Proposed Spike design records engine creation/use/destruction on one
  dedicated thread and Sendable-only boundary payloads.
- [x] No `@unchecked Sendable`; no live `RimeEngine` crosses isolation.
- [x] MainActor accepts later keys while the owner is blocked for 150 ms+.
- [x] FIFO/no-drop/no-duplicate and thread-affinity facts are proved.
- [x] Epoch barrier resets owner state before new-epoch input; old result is
  rejected on MainActor.
- [x] Older revision cannot replace a newer applied snapshot.
- [x] Spike is not wired into controller/Extension; gate-off remains
  synchronous and equivalent to ADR 0004.
- [x] Initial checkpoint focused 5/5 and full KeyboardCore 821/821 passed.
- [x] Real librime, device and jetsam non-evidence are explicit in
  [`Spike evidence`](../evidence/t9-responsive-pipeline-spike-p1-3-2026-07-30.md).
- [x] Lifecycle P1 remediation focused/full validation — **7/7**, **823/823**.
- [x] Independent Architecture and Quality re-reviews of the remediation —
  **Pass with conditions** (lifecycle P1 Closed; Arch P2 residuals remain).

### Exit Criteria — R4-Owner

- [x] Design freezes D1 bootstrap, D2 ordered delivery, D3 bounded refuse-at-bound
  ([design](t9-responsive-pipeline-001-r4-owner-design.md)).
- [x] Implementation + focused **10/10** and full **826/826** KeyboardCore tests
  ([evidence](../evidence/t9-responsive-pipeline-r4-owner-2026-07-31.md)).
- [x] Independent Architecture review of R4-Owner — **Pass with conditions**.
- [x] Independent Quality review of R4-Owner — **Pass with conditions**.
- [x] Gate remains default-off; no Extension/`RimeEngineImpl` production wire;
  ADR 0025 remains Proposed; R4-B not claimed.

### Exit Criteria — R4-B

- [x] Config-only real `RimeEngineImpl` bootstrap on owner thread
  ([design](t9-responsive-pipeline-001-r4-b-design.md)).
- [x] Simulator RimeBridge proof: create/call off-main, FIFO delivery, shutdown
  (`ThreadAffineRimeRealEngineTests` 2/2; machine line
  `R4B_REAL_ENGINE_RESULT passed=true`).
- [x] Gate-off baseline retained; KeyboardCore ThreadAffine 10/10 + full 826/826.
- [x] Independent Architecture review of R4-B — **Pass with conditions**.
- [x] Independent Quality review of R4-B — **Pass with conditions**.
- [x] No Extension production wire; ADR 0025 remains Proposed; Product Gate not
  claimed.

### Exit Criteria — P1-D2 Amendment B

- [x] Product Decision records option B and the stable-shadow/fail-closed
  contract.
- [x] Proposed ADR/design Amendment explicitly supersedes the old D2 display
  and chrome wording without changing ADR 0025 status from Proposed.
- [x] L1 presents last stable host marked text plus pending `·` slots; no stable
  snapshot falls back to `·`×N; no internal T9 digits are written to the host.
- [x] Candidate, correction-candidate, candidate paging, Path, Space and
  Partial Commit actions fail closed while `provisionalAhead`.
- [x] Focused **16/0** and full **858/0** KeyboardCore tests pass; no
  Release/default gate change.
- [x] Independent Architecture and Quality final re-review records bounded
  Pass-with-conditions evidence; P1-1/P1-2 closed and four P2 residuals linked
  in the evidence record.

### Exit Criteria — P2-Regression-Matrix-001 (current bounded slice)

- [x] Core fail-closed action matrix covers candidate kinds, correction, page up/down,
  direct Path, Path cycle, Space and a live Partial Commit checkpoint.
- [x] Core stale-chrome test proves L1 does not mutate the settled RIME/Path/partial
  snapshot or notify Extension presentation before L2.
- [x] Epoch/abandon test checks owner epoch increase, zero post-abandon host-history
  writes and stale-work discard accounting; P2-EPC is closed at bounded Core/Fake-host
  scope.
- [x] Focused **19/0** and full **861/0** KeyboardCore tests, vendor verify and
  `git diff --check` passed.
- [ ] Extension candidate prefetch no-op has a UIKit-target test; current
  `KeyboardTests` target is Core-only, so this remains open.
- [ ] Real librime/device subjective latency, queue/memory/jetsam and Release
  evidence remain outside this test-only slice.
- [x] Independent Architecture and Quality review/re-review — **Pass with
  conditions**; P2-EPC bounded Core closed, UI/owner-call/real-performance
  residuals remain
  ([Architecture re-review](t9-responsive-pipeline-001-p2-regression-matrix-architecture-rereview.md),
  [Quality re-review](t9-responsive-pipeline-001-p2-regression-matrix-quality-rereview.md)).

### Exit Criteria — R2–R6

See plan. Shipping requires R6 independent reviews and Human Product Gate.

### Stop Conditions

Stop and escalate to Product / Architecture if work requires:

- changing Release default before Product Gate;
- unsynchronized RIME API use from multiple threads/executors;
- dropping user keys to keep the queue short;
- `@unchecked Sendable` or isolation bypass;
- logging raw input / pinyin / candidates / host text;
- host display of internal T9 digits;
- treating Executor implementation as independent Architecture/Quality pass;
- reopening auto-anchor expansion under this Assignment ID;
- proceeding past an authorized phase without a new Product instruction.

## State / event model (design contract)

### Actors and ownership

| Concern | Owner | Isolation |
|---|---|---|
| Touch, chrome, haptics/click, `UITextDocumentProxy`, marked text presentation | Keyboard UI + MainActor controller surface | MainActor |
| Action ordering, composition ledger, Path/candidate presentation state | `KeyboardController` / KeyboardCore | MainActor coordination |
| librime session + all session API calls | Single **RIME serial owner** | One serial executor/actor; never concurrent |
| Pure snapshot assembly from engine output | Serial owner or pure helpers | No second session |

### Identifiers

- **`sessionEpoch`:** increments on visibility abandon, session recreate,
  schema reselect failure/recovery, process-local full reset. Any result
  carrying an older epoch is discarded.
- **`revision`:** monotonic per accepted input/action within an epoch. Each
  enqueued RIME work item captures the revision it will produce. Results apply
  only if `result.revision == latestAppliedRevision + expected` policy defined
  below (v1: apply only if `result.revision == currentHeadRevision` when
  coalescing is off for that class; for UI publish, allow apply only if
  `result.revision >= lastPublishedRevision` and epoch matches, then set
  `lastPublishedRevision = result.revision`).
- **In-flight set:** work items with `revision > lastPublishedRevision` still
  pending or running.

### Event classes (all ordered)

1. **Immediate local feedback** (never waits for RIME): key highlight, system
   click, haptics.
2. **Enqueue RIME work** (ordered): printable T9/26 key, delete, candidate
   select, Path refine/`replaceInput`, reset, recover, page up/down, etc.
3. **Serial execute** on RIME owner: exactly one librime call stream.
4. **Publish snapshot** on MainActor: marked text + Path + candidates **atomically**
   from one `RimeOutput` generation (plus Core provenance already computed for
   that generation).
5. **Invalidate**: epoch bump clears queue and ignores late results.

### Delete semantics (v1 design)

| Case | Behavior |
|---|---|
| Pending not-yet-executed keys exist | Prefer cancel/drop **trailing** pending printable keys that delete would reverse, or enqueue a Delete work item after them with explicit composition of effects; v1 recommendation: **do not silently drop** — enqueue Delete in order after pending keys, unless a later spike proves a safe cancel protocol with tests |
| Delete while RIME running | Enqueue Delete after current head; do not apply host `deleteBackward` while composition still owns the key |
| Delete after confirmed engine state | Serial `deleteBackward` / composition-first rules unchanged |

R1 must freeze one of the two pending-delete strategies with tests; default
recommendation is **strict ordering without drop**.

### Stale candidate / Path selection

Selection carries `(sessionEpoch, revision, candidateRef or pathToken)`.
If epoch/revision no longer matches the last published snapshot, **fail closed**:
no commit, optional content-free counter `stale_selection_rejected`.

### Atomic publish rule

A single MainActor transaction updates:

- controller composition / preedit display inputs
- Path bar state
- candidate list presentation inputs
- `lastPublishedRevision`

Partial updates that leave Path from revision N and candidates from N−1 are
forbidden.

## Acceptance matrix (design)

### Frozen Human / automated sequence

- Spelling: `jintiandetianqizhenbucuowomenchuquwanba`
- Logs: fixture ID only; never the spelling string in production logs

### Automated (minimum)

| Case | Required |
|---|---|
| Fake RIME 150 ms/key | Entry accepts all keys immediately; final composition identity matches |
| No drop / no dup / order stable | Assert action IDs |
| Stale revision cannot write | Old result ignored |
| Epoch change | All prior results ignored; queue cleared |
| Coalesced UI publish | Intermediate snapshots may skip; last matches engine |
| Delete / candidate / Path / reset order | Contract tests |
| Stale candidate ref | Fail closed |
| T9 host digits | Never appear in marked text |
| 26-key path | Unchanged under gate off |
| Release default | Gate off ⇒ behavior equivalent to baseline |

### Device (Human)

- App: Reminders
- Operator: Human Product Owner
- Method: manual typing + content-free App diagnostics
- Forbidden as performance proof: coordinate XCTest / Computer Use third-party keyboard automation

### Metrics to collect (no SLO numbers yet)

- Touch/action → local feedback latency
- Touch/action → first published RIME snapshot latency
- Max revision lag (head − published)
- Max pending queue depth
- Count of discarded stale results
- Drop / dup / wrong-candidate / keyboard-exit incidents
- `process_key` segmented timings (existing Debug split)

## Handoff

### Required handoff content after R0

- Paths of new/changed docs
- Design report sections (Scope … Product Decisions Still Needed)
- Confirmation: production code untouched
- Recommended next Product instruction template for R1

### Handoff after R5-Preflight Closed (2026-07-31)

**Closed knife:** R5-Preflight only (arm + content-free logs + path on/off).

**Parent Assignment state:** remains `Active` until formal R5 / R6 / Product Gate
or Product Hold.

**Device residual for formal R5 (not open):**

- Fixed fixture / Reminders disposable list protocol (see plan acceptance matrix)
- Paired on/off or A/B order with subjective non-stutter scores
- Content-free counters (action→local feedback, action→publish lag, revision lag)
- Optional diagnostics filter for `T9RESP` (product polish; not a Gate blocker)
- Dual-gate typo sidecar residual (CandidateProvider adapter under preflight arm)

**Recommended Product instruction template — formal R5 only:**

```text
我作为 Human Product Owner / Product Lead，确认
T9-RESPONSIVE-PIPELINE-001 的 R5-Preflight 已关闭，路径 on/off 证据可读。

我授权仅正式 R5：
在同一 iPhone 上用 Reminders 可丢弃列表，按 plan 冻结拼写做 Human 手打 A/B
（gate-off baseline vs dual-gate armed Debug），收集 content-free 指标与
主观非卡顿评分；不打开 Release default-on；不 Accept ADR 0025；不宣布
Product Gate。

完成后停止，提交证据包，交独立 Architecture / Quality，再由我做是否进入 R6
的 Product 决定。
```

### Revalidation Trigger

- Product changes the responsiveness vs lag tradeoff
- Architecture rejects serial-owner model or ADR 0004 revision approach
- Evidence shows keys must be dropped to stay within Extension memory limits
- Baseline branch moves with conflicting RIME lifecycle changes
- Any required Assignment field would become `UNKNOWN` under reassignment

## Documentation Changes

| Document | Action |
|---|---|
| `docs/product-decisions/T9-RESPONSIVE-PIPELINE-001-authorization.md` | Create + R1 status |
| `docs/assignments/t9-responsive-rime-pipeline-001.md` | Create + R1 status (this file); Arch P1-2/P1-3 freeze recorded |
| `docs/plans/t9-responsive-rime-pipeline-plan.md` | Create + R1 status; P1 freeze note under R1/R2 |
| `docs/architecture/decisions/0025-responsive-rime-serial-input-pipeline.md` | Create (Proposed); + §10 isolation plan + §11 epoch mapping freezes |
| `docs/evidence/t9-responsive-pipeline-r1-2026-07-30.md` | R1 executor evidence |
| Predecessor plan / assignment / PD | Successor link only |
| `docs/KNOWLEDGE_INDEX.md` | Navigation entry |
