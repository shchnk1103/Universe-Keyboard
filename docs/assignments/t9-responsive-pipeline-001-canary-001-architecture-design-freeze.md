# Architecture Design Freeze: T9-RESPONSIVE-PIPELINE-001 / CANARY-001

Status: **Frozen — independent cross-review Pass for I-Ready; no implementation authorization**

Date: 2026-08-03 Asia/Shanghai

Owner: Independent Architecture & Knowledge Steward
`/root/canary_arch_review`

Parent Assignment:
[`CANARY-001`](t9-responsive-pipeline-001-production-shaped-canary-001.md)

Architecture boundary:
[`ADR 0004`](../architecture/decisions/0004-rime-runtime-session-model.md) remains
Accepted and binding;
[`ADR 0025`](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md)
remains Proposed.

Repository Change Type: `Contract` only. This record does not modify Runtime,
tests, build settings, gates, devices or evidence artifacts.

## 1. Decision boundary

This freeze defines the smallest production-shaped internal canary architecture
that can later be implemented without creating simultaneous access to a live
librime session.

For ADR authority, **production-shaped** means a dedicated internal diagnostic
artifact built from the actual Keyboard Extension target, lifecycle and real
RIME bridge. The canary capability is present only behind an explicit internal
compilation condition and a separate runtime configuration. It is absent and
unreachable in ordinary Release. While ADR 0025 remains Proposed, this is not a
production runtime path and cannot be repackaged as one without a new ADR/Product
decision.

It does not:

- accept ADR 0025 or revise ADR 0004;
- authorize implementation, build, Simulator or physical-device execution;
- enable either gate by default or add a user-facing setting;
- change Main App deployment, schema, Lua, App Group or userdb ownership;
- permit `@unchecked Sendable`, arbitrary background librime calls, accepted
  input reorder or silent evidence gaps.

The static source inventory used by this design is:
[`CANARY-001 live-session API inventory`](t9-responsive-pipeline-001-canary-001-live-session-api-inventory.md).
Any implementation-phase source change invalidates that inventory until it is
re-run against the proposed final diff.

## 2. Frozen ownership model

### MainActor owns

- the sole canary mode/gate decision;
- touch, gestures, chrome and feedback;
- `UITextDocumentProxy`, marked text and host mutation;
- acceptance of immutable work descriptors;
- validation and application of immutable snapshots/receipts.

MainActor must not hold or call a live canary engine/session.

### RIME serial owner owns

- creation, initialization, schema selection, use and destruction of the live
  canary engine/session;
- every reachable session-mutating operation and every session-dependent read;
- FIFO execution, owner-local `sessionEpoch` and revision completion;
- immutable snapshot, lifecycle and terminal receipt production.

The engine/session remains a local variable on its creation thread for its full
lifetime. Only immutable `Sendable` configuration, work, snapshot and receipt
values cross isolation. `Packages/RimeBridge` remains the only production RIME
bridge.

### Main App remains separate

Deployment, YAML/schema maintenance, cache invalidation, userdb backup/restore
and RIME smoke probes remain Main-App operations. The Extension canary never
deploys or repairs. Main-App probes are not canary session evidence and must not
be mixed with an Extension run.

## 3. Unique mode evaluator

A MainActor-isolated `CanaryModeCoordinator` is the single mode authority. The
name is descriptive, not an implementation mandate. It does not hold a live
engine/session.

It consumes one immutable, atomically evaluated internal configuration snapshot:

```text
canaryRequested =
  internalCanaryCapabilityCompiled
  && explicitInternalEnable
  && killSwitch == false
  && bootstrapAvailable
  && configurationValid
  && notExpired
```

Missing, malformed, expired, contradictory or unproven configuration resolves
to `canaryRequested=false`.

No controller extension, lifecycle callback, owner or bridge entry may read
flags independently and choose a path. The coordinator alone owns:

- `modeGeneration`, incremented for enable, kill and lifecycle fences;
- unique, non-reusable `fenceID` values;
- current mode and transition state;
- the baseline-session creation permit;
- the accepted-through watermark captured at a fence.

The canary owner owns its local `sessionEpoch`. `revision` is monotonic only
within that epoch. Results and receipts carry at least `modeGeneration`,
`sessionEpoch`, `revision` and the relevant `fenceID`. MainActor rejects any
result that no longer matches current authority.

## 4. Exclusive transition state machine

```text
BaselineActive
  -> BaselineQuiescing
  -> CanaryStarting
  -> CanaryActive

CanaryActive
  -> FenceIssued
  -> CanaryDraining or CanaryAbandoningVisibility
  -> OwnerDestroyedConfirmed
  -> BaselineRecovering
  -> BaselineActive

Any unconfirmed destruction, non-terminal delivery, bootstrap failure,
recovery failure or timeout
  -> FencedUnavailable
```

### Baseline to canary

1. Stop accepting baseline session operations.
2. Clear/abandon unfinished presentation according to existing input and
   visibility contracts where applicable.
3. Destroy the baseline live session and obtain positive completion.
4. Transfer only config data to the owner thread.
5. Create and select the canary session on that owner thread.
6. Enter `CanaryActive` only after an owner-ready receipt.

Failure may recreate a baseline session only after positive proof that no
canary live session exists.

### Canary to baseline

1. Issue a fence, increment `modeGeneration`, refuse new canary acceptance and
   capture `acceptedThroughRevision`.
2. Resolve already accepted work using the transition-specific rule in §5.
3. Destroy/invalidate the engine/session on the owner thread.
4. Receive all three positive terminals:
   `ownerDestroyed`, `mailboxTerminal`, `deliveryDrained`.
5. Only then grant the baseline-session creation permit.
6. Create a new ADR 0004 process-local baseline session. Never revive the old
   session or replay abandoned composition to the host.

Timeout is not proof of owner destruction. It enters `FencedUnavailable`; it
must not create a baseline session or claim successful recovery.

Kill has two distinct evaluation points:

- before canary owner startup, asserted kill selects the baseline and creates no
  canary owner;
- after `CanaryActive`, asserted kill only issues the fence and begins the
  accepted-work drain. It does not immediately select or create the baseline.

### FencedUnavailable

This is an explicit safe failure state:

- no new RIME work is accepted;
- no baseline or canary live session is accessed;
- late results cannot mutate UI or host text;
- content-free failure reason and transition receipts remain observable;
- recovery requires a later positive lifecycle boundary, normally a fresh
  Extension presentation/process, not an assumed timeout.

## 5. Accepted-action terminal semantics

CANARY-001 distinguishes an explicit operational kill from an Accepted ADR 0002
visibility abandonment.

### Explicit kill while the presentation remains active

- Fence immediately prevents new `ACCEPT`.
- Every revision at or below `acceptedThroughRevision` drains FIFO.
- Stop/control priority must not skip the accepted backlog.
- Each accepted revision reaches owner completion and a presentation terminal,
  even if its late result is stale and forbidden from host/UI mutation.
- Baseline recovery waits for the complete terminal sequence in §4.
- A drain timeout enters `FencedUnavailable`; cancellation is not inferred.

This is the conservative Product contract selected for CANARY-001. It preserves
the Assignment non-goal that accepted live input is not silently dropped.

### Visibility disappearance or host switch

[`ADR 0002`](../architecture/decisions/0002-visibility-change-abandons-composition.md)
already requires unfinished composition to be abandoned rather than restored or
committed. Therefore:

- visibility fence stops new `ACCEPT`;
- queued accepted work may terminate as `abandonedVisibility` without execution;
- every abandoned revision receives an explicit content-free terminal receipt;
- no abandoned result may mutate host text, marked text or chrome;
- owner/session destruction remains synchronous and positive before suspension;
- return starts with a fresh session and clean composition.

`abandonedVisibility` is a lifecycle terminal authorized by ADR 0002, not a
general kill-switch shortcut. It cannot be used while the presentation remains
active.

### Abrupt process death

No in-process terminal can be guaranteed after process death. ADR 0004 governs:
all in-memory session/composition state is lost and a new process starts clean.
Absence of a terminal record must be classified as process termination, not
successful drain or baseline recovery.

### Capacity refusal

Mailbox capacity refusal occurs before `ACCEPT`, returns a reason such as
`atBound`, and does not remove already accepted work. The bounded depth is a
design constant chosen before implementation evidence, not a Product latency or
memory SLO.

## 6. Owner and presentation terminal receipts

Required owner/transition receipts are content-free and versioned:

- `ownerReady`
- `fenceIssued(acceptedThroughRevision)`
- per-accepted revision owner terminal
- `ownerDestroyed`
- `mailboxTerminal`
- `deliveryDrained`
- `baselineRecoveryStarted`
- `baselineReady` or explicit failure

Every transition receipt carries the same correlation key
`{runID, modeGeneration, fenceID, canarySessionInstance}`. Baseline creation
requires positively matching receipts in this order:
`ownerDestroyed -> mailboxTerminal -> deliveryDrained`. Missing, duplicate,
out-of-order or mismatched receipts enter `FencedUnavailable`.

Owner completion and presentation remain separate:

```text
ACCEPT -> PUBLISH -> VISIBILITY_DISPOSITION -> PAINT_TERMINAL
```

Each `PUBLISH` receives exactly one `PAINT_TERMINAL`:

- `painted`
- `coalesced(absorbedRevisionRange, replacementRevision)`
- `failed(reason)`

A stale epoch/mode result must not touch UI/host but still consumes its delivery
slot and receives a terminal receipt. Missing or duplicate terminal receipts are
contract failures, never inferred coalescing.

The cardinality is frozen as follows:

| ACCEPT terminal | Execution / PUBLISH | Presentation terminal |
|---|---|---|
| `published` | work executed; exactly one `PUBLISH(completion=published)` | exactly one visibility disposition, followed by exactly one matching PAINT terminal |
| `staleAfterFence` | work executed FIFO; exactly one `PUBLISH(completion=staleAfterFence)` whose payload is rejected from UI/host | exactly one `notVisible(fencedBeforeVisible)` and exactly one `PAINT_TERMINAL=failed(fencedBeforeVisible)` |
| `abandonedVisibility` | execution is not required; no `PUBLISH` | no `PAINT_TERMINAL`; ADR 0002 visibility exit only |

Every `ACCEPT` has exactly one ACCEPT terminal. Every `PUBLISH` has exactly one
presentation terminal. `abandonedVisibility` is complete at the ACCEPT layer;
it must not fabricate PUBLISH/PAINT records.

For every `PUBLISH`, exactly one visibility disposition is required:

- `visible(presentationRevision)`: emits exactly one canonical `VISIBLE` marker,
  then exactly one PAINT terminal of `painted` or bounded `failed`;
- `notVisible(coalescedInto: replacementRevision)`: emits no `VISIBLE`, then
  exactly one `PAINT_TERMINAL=coalesced(absorbedRevisionRange,
  replacementRevision)`;
- `notVisible(fencedBeforeVisible)`: emits no `VISIBLE`, then exactly one
  `PAINT_TERMINAL=failed(fencedBeforeVisible)`.

One PUBLISH can never emit more than one canonical `VISIBLE`. Repeated UIKit
layout/display callbacks are implementation detail and must not create extra
VISIBLE markers. A revision already carrying a PAINT terminal cannot later be
reclassified `staleAfterFence`; the fence affects only publication not yet
terminal at its validation point.

## 7. Live-session API closure

Before implementation `Ready`, the API inventory must classify every reachable
live-session create/read/write/recover/destroy entry as one of:

- `same-owner`: executed by the canary owner with the same ordering/epoch model;
- `fail-closed`: unavailable before any live-session access while canary owns
  the session.

Minimum families are:

| Family | Required canary rule |
|---|---|
| bootstrap/create/schema/finalize | owner-only |
| process key, Delete, replace/Path | ordered owner work |
| local/global candidate selection and page up/down | ordered owner work |
| `candidateWindow` | immutable published snapshot only; no live query |
| `isComposing`, diagnostics and runtime selection | immutable owner-published snapshot only |
| runtime-selection callback | immutable value delivery only; callback cannot access live owner/session |
| reset/recover | ordered owner work; implicit recreation creates a new session-instance receipt |
| suspend/resume/visibility | coordinator control executed through the same owner |
| typo-correction sidecar session | fail-closed to the non-RIME provider in canary v1 |
| ObjC public highlight/current-output/commit APIs | not exposed by the canary façade and fail-closed before live access |
| deployment/files/userdb | forbidden in Extension canary; Main App-only |

No MainActor “one harmless read”, candidate prefetch hint, runtime callback,
implicit session recreation or recovery bypass is permitted. Discovery of an
unclassified entry blocks implementation `Ready`.

The current inventory findings are frozen to these implementation/test
dispositions:

| Inventory finding | Required closure |
|---|---|
| `API-P1-01 abandonAllWork` | split control paths: explicit kill uses `drainThrough(acceptedThroughRevision)`; ADR 0002 uses per-revision `abandonVisibility` |
| `API-P1-02 ignored waits` | replace Boolean/ignored waits with the positively correlated transition receipts above; timeout is `FencedUnavailable` |
| `API-P1-03 preflight fallback` | only the mode coordinator may grant the baseline creation permit after positive absence/destruction proof |
| `API-P1-04 chromeEngineHint` | prohibited in canary; use immutable published snapshot or an ordered owner query |
| `API-P1-05 typo sidecar` | canary v1 uses the non-RIME provider and fails closed; no second live session |
| `API-P1-06 implicit recreate` | owner-only recreation with a new `canarySessionInstance` and lifecycle receipt |
| reversible auto-anchor | suppressed/fail-closed in canary v1 before live-session access; focused contract test |
| ObjC public `highlightCandidateOnCurrentPage` / `currentOutput` / `commitComposition` | not exposed by the canary façade; direct Extension calls prohibited by static scan and focused test; fail closed before live access |
| Main-App smoke/deployment probes | remain separate process operations; run header records maintenance/probe state and forbids evidence mixing |

“Proven unreachable” always means unreachable through both an explicit compile
boundary and a runtime fail-closed boundary; absence of a discovered call site is
not sufficient.

## 8. Default-off and restore invariants

- Ordinary Release does not contain an armed/compiled internal canary capability
  and resolves to ADR 0004 baseline.
- In the internal artifact, missing/invalid/expired configuration or kill
  asserted before startup resolves to baseline without creating a canary owner.
- Kill asserted after `CanaryActive` fences and drains; it does not permit an
  immediate baseline owner.
- “No canary owner/thread/session/bootstrap marker exists” applies only to
  ordinary Release and internal-artifact pre-start disabled states.
- Gate-off comparison binds the same source, build configuration and provenance
  envelope required by the Quality contract.
- Canary never changes schema, deployment, Lua, user settings, App Group runtime
  files or userdb.
- Restore removes/expires internal injection, replaces with the identified
  ordinary package, binds App/Extension hashes and verifies a bounded gate-off
  smoke after a fresh Extension presentation.
- Restore smoke is not lifecycle, performance, Product Gate or Release proof.

## 9. P0/P1 stop conditions

### P0

- baseline and canary simultaneously own or can call a live RIME session;
- a live engine/session crosses isolation through capture, unsafe Sendability or
  MainActor bypass;
- ordinary Release enters canary without valid explicit internal enablement;
- ordinary Release contains a reachable canary path while ADR 0025 is Proposed;
- retained evidence contains raw input, pinyin, candidate, committed/host text,
  screenshots or UI hierarchy;
- Extension canary deploys, wipes App Group, resets/restores userdb or modifies
  schema/Lua.

### P1

- any live-session entry is unclassified or cannot be same-owner/fail-closed;
- timeout is treated as destruction or baseline takeover permission;
- explicit kill abandons already accepted work;
- visibility abandonment lacks per-revision terminal disposition;
- `ownerDestroyed`, `mailboxTerminal` or `deliveryDrained` is missing;
- mode decision has more than one evaluator or provenance is unbound;
- FIFO, epoch/mode fence, terminal PAINT, bounded mailbox or control behavior is
  not falsifiable;
- implementation would require ADR 0025 acceptance, default-on, Product Gate,
  invented SLO or risk acceptance.

## 10. Architecture disposition

The design direction passed independent cross-review for I-Ready, not
implementation authorization. The prior
accepted-action ambiguity is resolved as:

- explicit kill drains all accepted FIFO work;
- ADR 0002 visibility change may abandon with explicit terminal receipts;
- timeout enters `FencedUnavailable` and never proves baseline takeover.

The API design inventory, Quality contract, implementation allowlist and
baseline identity have been cross-reviewed with no P0/P1. Final implementation
diff, artifact/restore hashes and runtime proof remain E-Ready work.

## 11. Frozen implementation allowlist and baseline identity

The maximum implementation allowlist is:

Production/runtime sources:

- `Packages/KeyboardCore/Sources/KeyboardCore/ThreadAffineRimeSpike.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/ThreadAffineRimeSession.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/ResponsiveRimePreflight.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/ResponsiveRimeCanaryMode.swift`
- `Keyboard/Controllers/KeyboardViewController+Bootstrap.swift`
- `Keyboard/Controllers/KeyboardViewController.swift`, lifecycle handoff only
- `Packages/RimeBridge/Sources/RimeBridge/ThreadAffineRimeEngineImplBootstrap.swift`
  only if positive lifecycle receipts require a bridge change

Test sources:

- `Packages/KeyboardCore/Tests/KeyboardCoreTests/ThreadAffineRimeWireTests.swift`
- `Packages/KeyboardCore/Tests/KeyboardCoreTests/ResponsiveRimeCanaryContractTests.swift`
- `Packages/KeyboardCore/Tests/KeyboardCoreTests/T9ResponsiveEvidenceValidatorTests.swift`
  only if the evidence schema is implemented in this phase
- `KeyboardTests/ResponsiveRimeCanaryLifecycleTests.swift`
- `Packages/RimeBridge/Tests/RimeBridgeTests/ThreadAffineRimeRealEngineTests.swift`
  only if the bridge file above changes

Contract/navigation paths are limited to:

- `docs/assignments/t9-responsive-pipeline-001-production-shaped-canary-001.md`
- `docs/assignments/t9-responsive-pipeline-001-canary-001-architecture-design-freeze.md`
- `docs/assignments/t9-responsive-pipeline-001-canary-001-quality-evidence-freeze.md`
- `docs/assignments/t9-responsive-pipeline-001-canary-001-live-session-api-inventory.md`
- `docs/assignments/t9-responsive-pipeline-001-canary-001-architecture-review.md`
- `docs/assignments/t9-responsive-pipeline-001-canary-001-quality-review.md`
- `docs/KNOWLEDGE_INDEX.md`

Evidence records are excluded until a later evidence phase is explicitly
activated and freezes their exact paths. ObjC bridge sources, the `RimeEngine`
protocol, schema, Lua, project defaults, entitlements, App Group contents and
Main-App deployment are excluded. Any additional source or document requires
Architecture and Quality revalidation before editing.

The comparison baseline is the same frozen source with the internal canary
capability absent, built as ordinary Release with no injected canary
configuration. The current inventory HEAD/diff fingerprints identify the
pre-implementation snapshot; final source, diff, executable and restore hashes
are deliberately deferred to `E-Ready` after implementation. Ambient worktree
changes remain preserved and fingerprinted; they are never normalized away.
