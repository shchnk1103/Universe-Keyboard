# T9-RESPONSIVE-PIPELINE-001 / Spike-P1-3 design

**Status:** `Active — lifecycle P1 Closed (Arch/Quality re-review Pass with conditions); gate off; R4 not authorized`
**Date:** `2026-07-30 Asia/Shanghai`
**Parent Assignment:** [`T9-RESPONSIVE-PIPELINE-001`](t9-responsive-rime-pipeline-001.md)
**Architecture:** [`ADR 0025`](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md) (`Proposed`)
**Product authority:** [`PD-T9-RESPONSIVE-PIPELINE-001`](../product-decisions/T9-RESPONSIVE-PIPELINE-001-authorization.md)

## Authorization boundary

Human Product Owner / Product Lead authorized only a falsifiable proof for
Architecture residual **P1-3**:

- design a thread-affine single-consumer owner;
- prove with Fake/controlled delay that MainActor accept does not wait for a
  150 ms+ owner stall;
- preserve FIFO input, revision/epoch validation and gate-off equivalence;
- keep the Spike disconnected from real `RimeEngineImpl`, Extension Release
  defaults and user settings.

This is not R4 real-librime wiring, ADR 0025 acceptance, Human device evidence,
Product Gate or Release default-on authorization.

## Falsifiable hypothesis

> A non-Sendable `RimeEngine` can be created, used and released entirely inside
> one dedicated thread while MainActor submits only Sendable work descriptors
> and receives only Sendable snapshots. While the owner blocks for at least
> 150 ms, MainActor can continue accepting ordered key events without waiting
> for the engine.

The Spike fails if strict Swift 6 compilation requires `@unchecked Sendable`,
if a live engine must cross isolation, if FIFO cannot be preserved, or if
gate-off production behavior changes.

## Ownership model

```text
MainActor
  accept(processKey descriptor)
  allocate (sessionEpoch, revision)
  enqueue Sendable envelope
           │
           ▼
dedicated Thread / one blocking mailbox consumer
  makeEngineOnOwnerThread()
  local let engine: RimeEngine
  processKey FIFO
  produce Sendable RimeOutput snapshot
           │
           ▼
MainActor Task
  reject epoch mismatch / non-monotonic revision
  future integration: atomically apply marked text + Path + candidates
```

The mailbox contains no engine/session reference. A `Sendable` factory value is
transferred to the thread and invoked there. The resulting engine is a local
variable captured by no other closure and is destroyed when the owner thread
stops. No `@unchecked Sendable` is used.

Lifecycle contract after review remediation:

- explicit `shutdown()` remains the intended lifecycle endpoint;
- `shutdown()` and `deinit` share one idempotent, thread-safe `requestStop()`;
- deinit fallback only enqueues stop and never blocks;
- `runOwnerLoop` returns before the stopped signal, so its local engine is
  destroyed on the owner thread before `waitUntilStopped()` succeeds;
- future Extension wiring must still perform explicit visibility
  suspend/finalize; deinit fallback is not a database-lock lifecycle policy.

## Relationship to current R1–R3 path

- `ResponsiveRimePipeline` remains the pure synchronous state-machine bed.
- `SerialRimeSessionOwner` / `ResponsiveRimeSessionCoordinator` remain the
  default-off MainActor implementation from R2/R3.
- `ThreadAffineRimeSpikeOwner` is a separate proof type and is not installed in
  `KeyboardController` or `ResponsiveRimeEngineBridge`.
- Gate off therefore stays on ADR 0004's synchronous path.
- A future R4 design must port the full R3 context/presentation bridge rather
  than replacing it with this processKey-only Spike.

## Deliberately narrow work surface

The Spike accepts only `ThreadAffineRimeSpikeWork.processKey`.

Delete, candidate/Path selection, paging, `replaceInput`, recovery, visibility,
runtime selection callbacks and diagnostic session reads are intentionally not
exposed. Implementing them without the complete R3 binding/lifecycle contract
would overstate the proof and risk a second RIME entry.

## Epoch and publication proof

- MainActor allocates monotonic revisions within the current epoch.
- `advanceSessionEpoch()` enqueues an ordered reset barrier before new-epoch
  input.
- MainActor presentation authority advances immediately, so late old-epoch
  results fail closed.
- The owner executes the reset barrier before new-epoch work.
- `ThreadAffineRimeSpikeApplyGate` rejects epoch mismatch and revision rollback.

The Spike does not yet prove atomic UIKit/marked-text/Path/candidate mutation;
it proves that an accepted Sendable snapshot can reach the correct MainActor
validation boundary.

## Failure and rollback

The Spike has no production connection. Failure means:

1. remove or retain the isolated proof code as rejected evidence;
2. keep `isResponsiveRimePipelineEnabled == false`;
3. keep ADR 0004 synchronous behavior and the R2/R3 MainActor deferred path as
   the current experimental ceiling;
4. record why thread-affine ownership failed without relabeling it success.

## Risks left for R4+

- real `RimeEngineImpl` must be constructed and finalized on the owner thread;
- every read/mutation/callback API must enter the same owner;
- runtime-selection callbacks need a Sendable event representation;
- owner startup/readiness and shutdown cannot block the key hot path;
- pending queue depth and payload retention may increase Extension jetsam risk;
- Path/auto-anchor post-processing may enqueue follow-up RIME mutations and
  needs a non-reentrant asynchronous transaction contract;
- process death, visibility suspend/resume and recovery need full lifecycle
  evidence;
- real librime may have undocumented process/thread assumptions beyond the
  Fake proof.
- the generic factory contract does not prove a fresh/non-escaping real bridge
  instance; R4 needs a concrete configuration-only RimeBridge bootstrap;
- MainActor result delivery needs a single ordered channel and terminal
  callback barrier;
- the current mailbox is unbounded and stop/epoch barriers queue behind old
  work; backlog/jetsam policy remains unresolved.

## Required evidence

1. A 150 ms+ blocked owner call while later MainActor accepts return promptly.
2. FIFO action IDs, monotonic revisions, no drop/duplicate.
3. Engine created off-main and every tested call stays on its creation thread.
4. Old epoch result rejected; reset barrier precedes new-epoch engine work.
5. Non-monotonic revision rejected.
6. Spike not wired; gate-off controller remains synchronous.
7. Focused and full KeyboardCore tests.
8. Explicit list of unexecuted real-librime/device/jetsam validation.

After Executor evidence, stop for independent Architecture and Quality review.
