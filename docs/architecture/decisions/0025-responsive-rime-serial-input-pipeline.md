# ADR 0025: Responsive Serial RIME Input Pipeline

- **Status:** Proposed
- **Date:** 2026-07-30
- **Decision owner:** 🏛️ Architecture & Knowledge Steward (acceptance pending)
- **Product authority:**
  [`PD-T9-RESPONSIVE-PIPELINE-001`](../../product-decisions/T9-RESPONSIVE-PIPELINE-001-authorization.md)
- **Assignment:**
  [`T9-RESPONSIVE-PIPELINE-001`](../../assignments/t9-responsive-rime-pipeline-001.md)
- **Plan:**
  [`t9-responsive-rime-pipeline-plan.md`](../../plans/t9-responsive-rime-pipeline-plan.md)
- **Supersedes / revises (when Accepted):** the Extension **threading locus**
  clause of [`ADR 0004`](0004-rime-runtime-session-model.md) only
- **Does not supersede:** process-local session, Main App deploy ownership,
  no Extension full deploy, recovery-without-deploy rules of ADR 0001–0004

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

### 6. Relationship to ADR 0004

Until this ADR is **Accepted** and a Product-authorized implementation phase
lands:

- Production code continues to follow ADR 0004 as written (session ops on
  main actor/thread).

When this ADR is **Accepted**:

- ADR 0004’s requirement that librime calls be **serialized** remains binding.
- ADR 0004’s placement of Extension session operations specifically on the
  **main actor/thread** is revised: serialization may be provided by the
  dedicated RIME serial owner instead of MainActor.
- All other ADR 0004 decisions (process-local session, recovery limits,
  no durable in-memory composition across process death) remain.

This ADR must not be treated as Accepted by implementers until Architecture
records acceptance. Product authorization of R1 Fake RIME tests does not by
itself Accept this ADR.

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

This table is a design freeze only. **This ADR remains Status: Proposed.** Gate-on
shipping still requires Architecture acceptance of this ADR, authorized
implementation phases, independent Quality evidence and Product Gate. Do **not**
treat R1 Fake RIME work or this document amendment as ADR Accept.

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

### 11. `sessionEpoch` mapping table (Architecture P1-3 freeze)

Architecture R1 review finding **P1-3** required a frozen who-bumps-epoch table
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
   (Status still **Proposed**; not Accept).
3. Architecture P1-1 applied vs published split + interleaving tests — **done**
   in `ResponsiveRimePipeline` R1 bed (2026-07-30 remediation).
4. Enqueued reset/recover epoch bumps aligned with §11 — **done** in R1 bed.
5. Independent Architecture **re-review** of P1 remediation (optional before
   Product considers R2) — pending if Product requests.
6. R2 serial owner behind default-off gate — **not authorized** until Product.
7. R3 full contract matrix (Delete, selection, recover, visibility) on wired path.
8. Independent Architecture **acceptance** of this ADR after R2/R3 evidence.
9. Update `swift6-migration.md` ownership table when Accepted and implemented.
10. Update `input-pipeline-and-marked-text.md` pipeline diagram when the
    enabled path lands.

## Related documents

- [`0004-rime-runtime-session-model.md`](0004-rime-runtime-session-model.md)
- [`0010-debug-only-decision-trace-and-evidence-provenance-boundary.md`](0010-debug-only-decision-trace-and-evidence-provenance-boundary.md)
- [`0023-t9-complete-local-path-catalog-and-atomic-presentation.md`](0023-t9-complete-local-path-catalog-and-atomic-presentation.md)
- [`0024-t9-auto-anchor-shadow-observation-boundary.md`](0024-t9-auto-anchor-shadow-observation-boundary.md)
- [`../input-pipeline-and-marked-text.md`](../input-pipeline-and-marked-text.md)
- [`../shared-container-and-rime-lifecycle.md`](../shared-container-and-rime-lifecycle.md)
- [`../swift6-migration.md`](../swift6-migration.md)
- [`../../PERFORMANCE_BASELINE.md`](../../PERFORMANCE_BASELINE.md)
