# Assignment: T9-RESPONSIVE-PIPELINE-001 — 九宫格响应式 RIME 输入管线

**Policy version:** `1.0.0`  
**Lifecycle status:** `Active — R2 P1 re-review: Arch Pass with conditions (P1-1/P1-2 Closed, P1-3 open); Quality Pass with conditions (P1 Closed); keep gate off; ADR 0025 Proposed; Product Gate not claimed`  
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
- [ ] Product Gate — **not claimed**
- [ ] R3+ authorization — **not granted**

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
