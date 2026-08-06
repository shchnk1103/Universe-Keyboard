# ADR 0025: Responsive Serial RIME Input Pipeline

- **Status:** **Accepted** (`2026-08-06 Asia/Shanghai`) — binding architecture
  Decision for the responsive serial RIME input pipeline design (single serial
  session owner; MainActor UI/proxy; ordered enqueue; versioned publish;
  fail-closed stale interaction; Swift 6 isolation without `@unchecked
  Sendable` shortcuts). Production enablement remains behind the explicit
  dual-gate contract in §8. **Release default remains the ADR 0004
  MainActor-synchronous session path** until a future Product Gate Decision.
  Architecture acceptance authority:
  [`ADR-0025-ACCEPT-001`](../../assignments/adr-0025-accept-001.md)
  independent Architecture review (**Conditional Accept** with named residuals)
  + Quality evidence-stack **Pass with conditions**. Does **not** authorize:
  Release default-on, Product Gate, performance SLO, or erasure of Formal R5
  FAIL history. Residuals: readiness dossier R-01…R-09;
  Architecture findings A-P2-03…A-P2-05 / A-P3-\*; Quality Q-P3-01…Q-P3-04.
- **Date:** 2026-07-30 (proposed); Accepted 2026-08-06
- **Decision owner:** 🏛️ Architecture & Knowledge Steward
- **Product authority:**
  [`PD-T9-RESPONSIVE-PIPELINE-001`](../../product-decisions/T9-RESPONSIVE-PIPELINE-001-authorization.md)
  + acceptance-review phase
  [`PD-…-ADR-0025-ACCEPT`](../../product-decisions/T9-RESPONSIVE-PIPELINE-001-ADR-0025-ACCEPT-authorization.md)
- **Assignment:**
  [`T9-RESPONSIVE-PIPELINE-001`](../../assignments/t9-responsive-rime-pipeline-001.md);
  acceptance record
  [`ADR-0025-ACCEPT-001`](../../assignments/adr-0025-accept-001.md)
- **Plan:**
  [`t9-responsive-rime-pipeline-plan.md`](../../plans/t9-responsive-rime-pipeline-plan.md)
- **Acceptance reviews:**
  [`Architecture`](../../assignments/adr-0025-accept-001-architecture-review.md) ·
  [`Quality`](../../assignments/adr-0025-accept-001-quality-review.md) ·
  [`readiness dossier`](../../assignments/adr-0025-accept-001-readiness-dossier.md)
- **Supersedes / revises (gate-on path only):** the Extension **threading locus**
  clause of [`ADR 0004`](0004-rime-runtime-session-model.md) when the responsive
  path is **enabled** under §8
- **Does not supersede:** process-local session, Main App deploy ownership,
  no Extension full deploy, recovery-without-deploy rules of ADR 0001–0004;
  **does not** change ADR 0004 gate-off / Release-default MainActor placement

## Context

librime is treated as non-thread-safe. ADR 0004 therefore requires serialized
session operations and currently places Extension session work on the main
actor/thread. That decision correctly forbids concurrent librime use, but it
also makes long `process_key` calls block MainActor input handling.

Evidence for Chinese nine-key long composition shows deterministic
`process_key` spikes on a frozen 38-key sequence. Local Path catalog work is
not the dominant stall. Auto-anchor experiments reduced unresolved ambiguity
in some configurations but failed the product direction test at S2.3; Product
Hold/harvested that route and authorized a new direction:

> Immediate key feedback must not wait for RIME; RIME may finish slightly later.

Swift 6 strict concurrency is in force. Isolation bypass via
`@unchecked Sendable` is forbidden by repository policy.

## Decision

### 1. Single serial RIME session owner

All librime session APIs used by the keyboard runtime — including at least
`processKey`, `deleteBackward`, `replaceInput`, candidate select/page,
`resetSession`, `recoverSession`, `suspendForVisibilityChange`,
`resumeAfterVisibilityChange`, and any other session-mutating bridge call —
must enter **one** serial owner (dedicated actor or equivalent serial executor
with a single consumer).

No second concurrent session is introduced for ordinary typing. No background
queue may call librime except through that owner.

### 2. MainActor remains the UI and document-proxy owner

The following stay on MainActor (or UIKit main thread equivalents):

- touch/gesture handling and chrome visuals
- system key click / haptics policy application
- `UITextDocumentProxy` / marked-text presentation
- candidate and Path **view** updates driven by already-published Core state

MainActor may **enqueue** work and **apply** validated snapshots. It must not
perform unbounded librime work on the hot path once the responsive pipeline is
enabled.

### 3. Ordered input, optional publish coalesce

- Every user action that affects the RIME session is enqueued in order.
- v1 must not drop, merge or reorder those actions to reduce load.
- Snapshot **publication** to UI may coalesce: only the latest valid snapshot
  needs to be shown under burst typing.
- Coalesce is never a license to skip applying engine state that later actions
  depend on; the serial owner still executes every enqueued session operation.

### 4. Versioned results: `sessionEpoch` and `revision`

- `sessionEpoch` increments when the process-local session identity or
  composition authority is invalidated (see **§11 `sessionEpoch` mapping** for
  the frozen who-bumps table). Results with a mismatched epoch are discarded.
- `revision` is monotonic within an epoch for enqueued work. A result may
  publish only when its epoch matches and its revision is still eligible under
  the publish policy (latest-wins for UI; never apply older over newer).
- Candidate/Path selection carries the snapshot identity it refers to and
  **fails closed** if that identity is stale.

### 5. Atomic composition snapshot publish

One MainActor publish transaction must update together:

- composition / preedit inputs used for marked text
- Path presentation state
- candidate presentation inputs
- the recorded published revision

Cross-revision Path vs candidate mixes are architectural defects.

### 5.1 Proposed amendment: content-free completion and presentation markers

**Status: Proposed — P2-D1 diagnostic contract, not ADR acceptance**

For explicit diagnostic/preflight evidence, the observable stages are kept
separate:

```text
ACCEPT → owner completion / delivery → PUBLISH → MainActor apply → VISIBLE
                                               └→ PAINT (timing/coalescing)
```

- `ACCEPT` records MainActor enqueue of an ordered revision;
- `PUBLISH` records serial-owner completion/delivery for that revision and is
  epoch-bound; it must not carry UI timing fields;
- `VISIBLE` records the MainActor composition snapshot application;
- `PAINT` is supplementary timing/coalescing evidence and may be latest-only.

This amendment resolves the ambiguity where a coalesced UI snapshot was
previously reported as a missing owner publish. It does not require every
accepted revision to be painted, does not permit dropping or reordering input,
and does not change the Release-default gate. The alternative of using
`PUBLISH` for UI apply was rejected because it cannot distinguish owner
completion from a deliberately coalesced presentation.

### 6. Relationship to ADR 0004

**Historical (while Proposed):** until Architecture acceptance and
Product-authorized implementation phases, production code continued to follow
ADR 0004 as written (session ops on main actor/thread) for ordinary traffic.

**When this ADR is Accepted (current):**

- ADR 0004’s requirement that librime calls be **serialized** remains binding
  on **both** gate-off and gate-on paths.
- ADR 0004’s placement of Extension session operations specifically on the
  **main actor/thread** is revised **only for the responsive path when it is
  enabled** under §8: serialization may be provided by the dedicated RIME
  serial owner instead of MainActor.
- All other ADR 0004 decisions (process-local session, recovery limits,
  no durable in-memory composition across process death) remain.

**Operational note (Accepted — mandatory interpretation):**

- The revision of ADR 0004’s Extension main-actor/thread **placement** applies
  only when the responsive path is **enabled** under §8 (gate-on / Product-
  authorized diagnostic or future Product Gate enablement).
- Gate-off / Release default continues to follow ADR 0004 as written for
  session threading locus (MainActor-synchronous session ops).
- Serialization of librime remains mandatory on both paths.
- Accept of this ADR is **not** permission to change Release defaults, arm
  gates in ordinary Release builds, or claim Product Gate.

### 7. Swift 6 isolation

- Prefer an `actor` or a single-consumer serial executor with checked sendable
  payloads.
- Snapshots crossing isolation boundaries must be immutable/value-typed or
  otherwise Sendable by construction.
- `@unchecked Sendable` is not an allowed shortcut for this design.

See **§10 R2 serial owner isolation plan** for the frozen R1/R2 boundary and
owner shape required before any production concurrent wiring.

### 8. Feature gating

Production enablement of the responsive path remains behind an explicit gate
until Product Gate. Release default stays behavior-equivalent to the
pre-feature baseline until Product decides otherwise.

**Gate contract (frozen for implementers):**

| Gate | Production path |
|---|---|
| **Off** (Release default until Product Gate) | Today’s ADR **0004** MainActor-synchronous session path — no responsive owner required |
| **On** (Debug/internal only until Product Gate) | This ADR’s serial-owner path (enqueue on MainActor; execute on RIME owner; apply validated snapshots on MainActor) |

This table remains a binding gate contract. **This ADR is Status: Accepted** as
architecture Decision for the gated design. Gate-on **shipping / Release
default-on** still requires a separate Product Gate Decision plus independent
Quality evidence appropriate to that Decision. Do **not** treat R1 Fake RIME
work, canary evidence, or this Accept record as Product Gate or default-on.

### 9. Diagnostics

Debug/content-free metrics may include fixture IDs, epoch, revision, queue
depth, timings and reject counters. They must not include raw input, pinyin,
candidate text, committed text or host field contents (ADR 0010 boundary).

### 10. R2 serial owner isolation plan (Architecture P1-2 freeze)

Architecture R1 review finding **P1-2** required a written freeze of the
production owner shape before R2 discussion. This section is that freeze. It
does **not** authorize R2, Accept this ADR, or claim Quality/Product Gate.

#### 10.1 R1 `ResponsiveRimePipeline` is not a production concurrent owner

`Packages/KeyboardCore/Sources/KeyboardCore/ResponsiveRimePipeline.swift` is a
**single-threaded test/design bed**:

- pure KeyboardCore state machine for ordered accept → serial drain → versioned
  publish;
- intentionally a mutable non-isolated `final class` holding a non-Sendable
  `RimeEngine` reference;
- safe only when a single test/executor thread owns all `accept` / `drain` /
  `processNext` / `bumpSessionEpoch` / selection validation calls;
- **not** a production concurrent owner and **must not** be shared across
  MainActor + background (or any two isolation domains) without redesign.

R1 proved ordering, epoch discard, publish policy and fail-closed selection
under Fake RIME delay. It did **not** prove Swift 6 cross-isolation ownership
of a live librime session.

#### 10.2 R2 production owner shape

When Product authorizes R2, the production serial owner **must** be one of:

1. an `actor`, or
2. a single-consumer serial executor with checked isolation,

such that **exactly one** consumer executes session work.

Requirements:

| Concern | Owner | Rule |
|---|---|---|
| Immediate feedback (highlight, click, haptics) | **MainActor** | Never waits on librime |
| Enqueue ordered work (`revision++`, capture epoch) | **MainActor** (or MainActor-coordinated surface) | Enqueue only; no session mutation |
| All `RimeEngine` session APIs | **RIME serial owner** | Single consumer; never concurrent |
| Apply validated snapshots to composition / Path / candidates / marked text | **MainActor** | Apply only after epoch/revision eligibility checks |

#### 10.3 Session API surface that must enter the same owner

All process-local session APIs used by the keyboard runtime enter the **same**
R2 owner, including at least:

- `processKey`
- `deleteBackward` / delete
- `replaceInput`
- candidate select (page-local and global)
- candidate window / page up / page down
- `resetSession`
- `recoverSession`
- `suspendForVisibilityChange` / `resumeAfterVisibilityChange`
- any other session-mutating or session-reading bridge call that assumes a live
  session identity

No parallel “just this one call on MainActor while the queue runs elsewhere”
escape hatch. Incomplete coverage is an architectural defect (data race risk).

#### 10.4 Forbidden isolation shortcuts

- **`@unchecked Sendable`** must not be used to shuttle `RimeEngine`, session
  handles, pipeline state or other non-Sendable session/engine objects across
  isolation domains.
- Snapshots and work descriptors that cross isolation boundaries must be
  immutable/value-typed or otherwise Sendable **by construction**.
- Do not “make it compile” by weakening isolation around the live session.

#### 10.5 What this freeze does **not** claim

- Not ADR **0025 Accepted**
- Not R2+ Product authorization
- Not Quality Pass or Product Gate
- Not permission to wire `KeyboardController` / `RimeEngineImpl` without a later
  Product-named phase

### 11. `sessionEpoch` mapping table (R1-P1-3-epoch freeze)

Architecture R1 review finding **R1-P1-3-epoch** required a frozen who-bumps-epoch table
(even if some rows land as R1 remediation or R3 contract completion). This
section is the **target contract** for R1 remediation / R2 design. Implementers
align code to this table; they do not invent alternate bump sites without
Architecture revision.

#### 11.1 Target contract

| Boundary | Who bumps `sessionEpoch` | Notes |
|---|---|---|
| Visibility abandon / suspend boundary | **Caller** `bumpSessionEpoch` (or future UI lifecycle owner that invokes the same API) | Clears pending; invalidates in-flight results; optional engine reset per API flag |
| Explicit `bumpSessionEpoch()` API | **Caller** | Clears pending; optional engine reset (`resetEngineSession`) |
| Enqueued `.resetSession` | **Pipeline / serial owner after** engine `resetSession` succeeds | Remaining same-epoch pending fail closed by epoch mismatch (or cleared — implementation may clear remaining pending; either way post-reset results from the old epoch never publish) |
| Enqueued `.recoverSession` | **Pipeline / serial owner after** engine `recoverSession` succeeds | Same as reset: pipeline bumps after recover; old-epoch work cannot publish |
| Fail-closed recovery | **Bump** (caller or owner at the recovery boundary, same as visibility/recover authority) | New epoch; discard prior pending / late results |
| Process death | **N/A** (new process) | New process-local session; no cross-process epoch continuity |

**Shared effects of a bump (target):**

- `sessionEpoch &+= 1`
- clear or fail-closed remaining pending work against the new epoch
- reset revision space for the new epoch (`nextRevision` / head / published
  watermarks restart per epoch policy)
- discard late results whose captured epoch no longer matches

#### 11.2 R1 bed alignment (post P1 remediation)

As of R1 remediation (2026-07-30):

- Explicit `ResponsiveRimePipeline.bumpSessionEpoch()` bumps epoch, **clears**
  pending, resets applied/published watermarks, and optionally calls
  `engine.resetSession()` (visibility / external barrier).
- Enqueued `.resetSession` / `.recoverSession` invoke the engine, record the
  empty applied snapshot, then **bump epoch without clearing** remaining
  pending; remaining same-epoch items fail closed on the epoch guard when
  drained. Later `accept` captures the new epoch.
- Applied vs published watermarks are separate (`lastAppliedRevision` /
  `lastPublishedRevision`); selection requires both to equal the bound
  revision (see pipeline docs / tests).

Visibility/suspend continues to use the caller-driven `bumpSessionEpoch` (or
equivalent lifecycle API) in production wiring (R2+).

#### 11.3 What this freeze does **not** claim

- Not that production Extension wiring already implements every row
- Not ADR **0025 Accepted**
- Not Product Gate or R2 authorization by itself

## Alternatives considered

| Alternative | Why rejected / deferred |
|---|---|
| Keep MainActor librime; optimize schema only | Measured ineffective for frozen spikes; still freezes UI |
| Expand auto-anchor until graph is small | S2.3 direction FAIL; Product Hold/harvest |
| Concurrent multi-session RIME | librime non-thread-safe; recovery/state explosion |
| Drop keys under load | Violates product ordering contract; only revisitable with Product decision |
| Unordered async fire-and-forget | Loses delete/candidate causality |
| `@unchecked Sendable` wrappers | Violates repository concurrency policy |

## 12. Spike-P1-3 thread-affine owner amendment draft

**Status:** Proposed Spike design only. This section does not Accept ADR 0025
or revise ADR 0004 in production.

The P1-3 Spike narrows §10's “single-consumer serial executor” option to a
falsifiable construction:

1. MainActor transfers a `Sendable` engine **factory value**, not a live
   `RimeEngine`.
2. One dedicated `Thread` invokes `makeEngineOnOwnerThread()`.
3. The resulting non-Sendable engine remains a local variable in that thread's
   consumer closure for its complete lifetime.
4. MainActor enqueues only `Sendable` work descriptors.
5. The owner returns only immutable `Sendable` value snapshots.
6. Result delivery re-enters MainActor and passes epoch/revision validation
   before any future UI mutation.
7. No `@unchecked Sendable` or parallel MainActor engine bypass is permitted.

The first Spike deliberately supports `processKey` only. This proves or
falsifies the isolation mechanism without claiming complete session API
coverage. R4 production wiring would still have to route Delete, selection,
Path/`replaceInput`, paging, lifecycle, recovery, runtime-selection callbacks
and all reads through the same owner while preserving R3 post-processing.

If this construction fails under Swift 6 or real librime prerequisites later
invalidate it, production falls back unchanged to ADR 0004. The existing
default-off MainActor deferred R2/R3 path remains an experimental ceiling, not
a subjective non-stutter claim.

Stable finding name: **`P1-3-off-main`**. This is distinct from the historical
R1 epoch-mapping finding now named `R1-P1-3-epoch`.

Independent review of checkpoint `45c426f` found one lifecycle P1: omitted
explicit shutdown orphaned the owner thread and its local engine. Remediation
adds an idempotent explicit stop plus non-blocking deinit fallback and lifecycle
probe tests. Explicit Extension visibility suspend/finalize remains mandatory
for any future R4; deinit is only a safety net.

Spike lifecycle P1 is repaired. The three Architecture residual P2 items are
frozen for closure under Product-authorized **R4-Owner** (not R4-B real
librime, not ADR Accept):

- concrete Sendable **bootstrap / config-only** construction (no live engine in
  the recipe);
- one ordered MainActor delivery channel with terminal acknowledgement;
- bounded work mailbox with refuse-at-bound, control-priority stop/epoch, and
  no drop of accepted process-key FIFO items.

Detailed designs:

- Spike: [`../../assignments/t9-responsive-pipeline-001-spike-p1-3-design.md`](../../assignments/t9-responsive-pipeline-001-spike-p1-3-design.md)
- R4-Owner: [`../../assignments/t9-responsive-pipeline-001-r4-owner-design.md`](../../assignments/t9-responsive-pipeline-001-r4-owner-design.md)
- R4-B real librime bootstrap:
  [`../../assignments/t9-responsive-pipeline-001-r4-b-design.md`](../../assignments/t9-responsive-pipeline-001-r4-b-design.md)

R4-B adds a **config-only** `ThreadAffineRimeEngineImplBootstrap` in RimeBridge
and Simulator evidence that a real engine can be created/called/released on the
owner thread. It does **not** wire Extension production paths or Accept this ADR.

## 13. Proposed Amendment B — P1-D2 visual shadow anchor and stable stale chrome

**Status:** Proposed; Product-selected implementation slice (`2026-08-01
Asia/Shanghai`). This Amendment does not Accept ADR 0025, revise ADR 0004's
production rule, enable either gate by default or create Product Gate evidence.

The Polish-2 device direction reduced candidate/Path redraw flicker but left a
contract mismatch: the frozen Rem-3 D2 text required disabled/cleared affordances,
while the current presentation kept the last engine chrome visible. Product chose
the stable-chrome alternative with explicit fail-closed input semantics.

### 13.1 Presentation contract

- L0 still accepts T9 keys without waiting for librime.
- L1 retains the latest host-visible marked text from a live L2 snapshot and
  appends one U+00B7 MIDDLE DOT (`·`) for each accepted T9 slot not yet covered by
  L2. With no stable L2 text, L1 is `·`×N.
- The retained prefix is a presentation snapshot only. It is never RIME raw
  input, a user Path choice, a candidate authority or host committed text.
- L1 does not call any RIME API, `replaceInput` or `insertText`. A live L2
  snapshot atomically replaces the complete marked text and clears the pending
  L1 ledger. An epoch/reset barrier clears both pending slots and the retained
  prefix.

### 13.2 Stable stale chrome and interaction safety

- Candidate and Path chrome may remain visually stable during `provisionalAhead`
  so the Extension does not redraw for every delayed L1 paint.
- This chrome is explicitly stale and non-authoritative.
- Candidate selection, correction-candidate selection, candidate page up/down,
  Path selection/cycling, Space selection and Partial Commit must fail closed
  before any Core state or RIME session mutation while `provisionalAhead` is true.
- After a live L2 publish or explicit reset/epoch barrier, the existing
  revision-bound candidate/Path contracts resume.

### 13.3 Scope and non-claims

The implementation slice is limited to the Proposed Amendment/design, pure
KeyboardCore presentation/guards and focused regression tests, followed by
independent Architecture and Quality review. It does not include real-librime
Extension wiring, R4/R5/R6, auto-anchor expansion, ADR Accept, Product Gate,
Release default-on or a subjective non-stutter claim.

**Amendment B review disposition (2026-08-01):** the bounded slice has final
independent Architecture and Quality **Pass with conditions** reviews. Focused
KeyboardCore is **16/0** and full KeyboardCore is **858/0**; P1-1 candidate
prefetch bypass and P1-2 ordered Delete/restore stable-shadow residual are
closed. Four P2 evidence debts remain (UI prefetch no-op, broader stale-action/
chrome matrix, epoch/abandon host-history proof, and real-device/Release
performance). This is not an ADR 0025 acceptance or a Product Gate.

## Consequences

### Positive

- Key chrome can remain responsive while librime is slow.
- Serialization remains explicit and reviewable.
- Stale UI interactions fail closed instead of committing wrong text.

### Negative / cost

- Higher design and test complexity (queues, epochs, atomic publish).
- Result lag must be productized carefully to avoid “soft” wrong feedback.
- Extension memory pressure if the pending queue grows without bound.
- Temporary dual-path (gate off vs on) until Product Gate.

### Risks

- Incomplete API coverage leaves a parallel librime entry → data races.
- Incorrect Delete/pending interaction → lost or double deletes.
- Marked-text races with host proxy if publish is not atomic.
- Jetsam if queue + candidate payloads grow during long stalls.

## Follow-up work

1. R1 Fake RIME state machine and regression tests — **done** (Product-authorized).
2. Architecture P1-2 / P1-3 written freezes — **done** in §§10–11 of this ADR
   (historical freezes while Proposed; Decision now **Accepted**).
3. Architecture P1-1 applied vs published split + interleaving tests — **done**
   in `ResponsiveRimePipeline` R1 bed (2026-07-30 remediation).
4. Enqueued reset/recover epoch bumps aligned with §11 — **done** in R1 bed.
5. Independent Architecture **re-review** of P1 remediation (optional before
   Product considers R2) — superseded by later phase reviews where Product
   requested them; not an open Accept gate.
6. R2 serial owner behind default-off gate — **done / superseded** by later
   Product-authorized gated phases (R4/R5 remediations, dual-gate, canary);
   Release default remains **off**.
7. R3 full contract matrix (Delete, selection, recover, visibility) on wired
   path — **open residual** (not an Accept gate): remaining contract-matrix /
   evidence-debt rows under default-off maturity; see dossier R-05/R-09.
8. Independent Architecture **acceptance** after R2/R3 evidence — **done
   (Conditional Accept, 2026-08-06)** under
   [`ADR-0025-ACCEPT-001`](../../assignments/adr-0025-accept-001.md) with named
   residuals; not “still waiting.”
9. Update `swift6-migration.md` ownership table — **post-Accept hygiene** when
   gate-on path docs need refresh.
10. Update `input-pipeline-and-marked-text.md` pipeline diagram — **post-Accept
    hygiene** when the enabled path is documented for ordinary readers.

## Related documents

- [`0004-rime-runtime-session-model.md`](0004-rime-runtime-session-model.md)
- [`0010-debug-only-decision-trace-and-evidence-provenance-boundary.md`](0010-debug-only-decision-trace-and-evidence-provenance-boundary.md)
- [`0023-t9-complete-local-path-catalog-and-atomic-presentation.md`](0023-t9-complete-local-path-catalog-and-atomic-presentation.md)
- [`0024-t9-auto-anchor-shadow-observation-boundary.md`](0024-t9-auto-anchor-shadow-observation-boundary.md)
- [`../input-pipeline-and-marked-text.md`](../input-pipeline-and-marked-text.md)
- [`../shared-container-and-rime-lifecycle.md`](../shared-container-and-rime-lifecycle.md)
- [`../swift6-migration.md`](../swift6-migration.md)
- [`../../PERFORMANCE_BASELINE.md`](../../PERFORMANCE_BASELINE.md)
