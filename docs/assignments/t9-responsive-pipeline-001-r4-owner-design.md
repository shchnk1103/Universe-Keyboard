# T9-RESPONSIVE-PIPELINE-001 / R4-Owner design

**Status:** `Closed for R4-Owner scope — dual independent review Pass with conditions; D1–D3 implemented; gate off; R4-B not authorized`  
**Date:** `2026-07-31 Asia/Shanghai`  
**Role author:** 🏛️ Architecture & Knowledge Steward  
**Parent Assignment:** [`T9-RESPONSIVE-PIPELINE-001`](t9-responsive-rime-pipeline-001.md)  
**Product authority:** [`PD-T9-RESPONSIVE-PIPELINE-001`](../product-decisions/T9-RESPONSIVE-PIPELINE-001-authorization.md) (R4-Owner)  
**Architecture:** [`ADR 0025`](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md) (`Proposed` — this design does **not** Accept it)  
**Predecessor proof:** Spike-P1-3 @ remediation `c0e2373`  
**Closes residuals:** Arch P2-1 factory, P2-2 delivery, P2-3 mailbox bounds

---

## 1. Decision boundary

### In scope

Freeze and implement a **production-shaped thread-affine owner contract** that
closes the three Architecture residual P2 items left after Spike-P1-3:

1. concrete Sendable **bootstrap / config-only** engine construction;
2. **ordered** MainActor delivery channel with terminal acknowledgement;
3. **bounded** mailbox with refuse-at-bound and control-priority lane.

Implementation stays in `Packages/KeyboardCore`, uses Fake/probe engines for
falsifiable tests, and remains **disconnected** from `KeyboardController`,
Extension, Release defaults and real `RimeEngineImpl` production wiring.

### Out of scope (explicit non-claims)

- R4-B real librime Simulator matrix / gate-off vs on comparison;
- Extension visibility production policy as the only lifecycle owner (deinit
  remains safety net only);
- ADR 0025 Accept, Product Gate, Release default-on;
- full RimeEngine API surface production routing (Delete / Path / select / page /
  recover may be **named** for later entry rules; R4-Owner code may remain
  processKey-first);
- `@unchecked Sendable` or isolation bypass;
- dropping, merging or reordering accepted process-key work.

### Relationship to ADR 0004 / 0025

- ADR 0004 remains the production Extension session threading law until ADR
  0025 is Accepted **and** a later Product-authorized migration phase runs.
- This design amends the **Spike-P1-3 owner shape** and records R4-Owner
  contract text under ADR 0025 as **Proposed** guidance only.
- R2/R3 MainActor deferred gate path is unchanged and remains default-off.

---

## 2. Problem restatement (why Spike is not enough)

Spike-P1-3 proved:

- non-Sendable engine local to one dedicated thread;
- MainActor accept during ≥150 ms Fake stall;
- FIFO process-key + epoch/revision gate;
- lifecycle stop via `shutdown` / deinit `requestStop`.

It left open:

| Residual | Spike shape | Production risk |
|---|---|---|
| P2-1 | Open `EngineFactory` protocol | Caller could smuggle a live engine or shared mutable session into the factory |
| P2-2 | Fire-and-forget `Task { @MainActor }` per result | Delivery reorder / terminal drain undefined at shutdown |
| P2-3 | Unbounded mailbox; stop/epoch FIFO behind backlog | Jetsam under burst; stop delayed by stale work |

R4-Owner freezes replacements that remain Fake-testable without claiming real
librime readiness.

---

## 3. Frozen architecture decisions

### D1 — Bootstrap is config-only (closes P2-1)

**Decision:** Replace open-ended “factory that returns any RimeEngine” as the
**preferred production contract** with a **Sendable bootstrap value** that carries
only configuration / recipe data. The owner thread is the sole site that
materializes the non-Sendable engine.

```text
MainActor / test host
  holds: ThreadAffineRimeEngineBootstrap (Sendable value)
         │
         ▼ transfer by value into owner Thread
owner Thread
  engine = bootstrap.makeEngineOnOwnerThread()
  // engine is a local var; never stored in mailbox / MainActor / bootstrap
```

**Contract rules:**

1. Bootstrap types are `Sendable` value types (or immutable Sendable wrappers).
2. Bootstrap **must not** store a live `RimeEngine`, session handle, or any
   non-Sendable reference that outlives the call.
3. `makeEngineOnOwnerThread()` is invoked **exactly once** at owner loop start
   (unless a future recover path is designed to re-bootstrap on the same thread
   after explicit destroy — not in R4-Owner).
4. Tests may ship `FakeThreadAffineRimeBootstrap` that creates a Fake engine on
   the owner thread. That is allowed because creation still happens on-owner.
5. Future R4-B real bridge must supply a bootstrap that builds `RimeEngineImpl`
   (or bridge session) from **paths / schema IDs / App Group identifiers only**,
   never from a pre-built engine on MainActor.

**Compatibility:** Existing `ThreadAffineRimeSpikeEngineFactory` may remain as a
thin adapter during migration, but new owner API surface prefers bootstrap
naming and documents the “no live engine in recipe” invariant in type docs.

### D2 — Single ordered delivery channel + terminal barrier (closes P2-2)

**Decision:** All owner → MainActor results enter **one** ordered delivery
channel. No per-result unstructured `Task` fan-out without a serial join point.

```text
owner Thread
  produce Sendable result
  delivery.enqueue(result)     // Sendable cross-isolation enqueue
           │
           ▼
MainActor serial delivery pump
  FIFO apply to ResultHandler / ApplyGate
  maintain deliveredCount / lastDeliveredRevision
  honour terminal barrier after owner stop
```

**Contract rules:**

1. Delivery preserves **completion order of owner execution** (which is process-key
   FIFO for accepted work of the current epoch).
2. Epoch/revision reject still happens on MainActor (`ApplyGate`); rejected
   results still **consume a delivery slot** so the channel does not stall.
3. **Terminal acknowledgement:** after owner loop exits (stop processed and
   local engine released), delivery signals **terminal**. Callers/tests may
   `waitUntilDeliveryDrained` / observe `isTerminal` only off the key hot path.
4. Shutdown sequence:
   1. `requestStop` (idempotent) → control lane enqueues stop;
   2. owner drains control/stop according to D3;
   3. owner releases local engine on owner thread;
   4. owner signals mailbox stopped;
   5. delivery marks terminal after the last enqueued result is delivered
      (or immediately if none pending).
5. Hot-path `accept` **never** waits on delivery drain.

**Implementation sketch (allowed):** a `Sendable` delivery mailbox + a single
MainActor scheduled pump (`Task { @MainActor in pump() }` that is coalesced so
only one pump runs), or an equivalent serial actor used only for delivery
ordering. Prefer the simplest form that preserves FIFO under Swift 6 without
`@unchecked Sendable`.

### D3 — Bounded mailbox + control priority + refuse-at-bound (closes P2-3)

**Decision:** Separate **work lane** and **control lane**.

| Lane | Contents | Ordering |
|---|---|---|
| Work | process-key envelopes | Strict FIFO among work items |
| Control | `advanceEpoch`, `stop` | Strict FIFO among control items; **control is always preferred over work** when both non-empty |

**Pending depth** counts **work** items only (control does not inflate user
queue depth diagnostics for jetsam policy).

**Bound policy (Product-locked):**

- Configure `maxPendingWorkDepth` (test default small, e.g. 64; production
  default chosen later from measurement — R4-Owner uses an explicit testable
  constant, not an invented Product SLO).
- When `accept` would exceed the bound: **refuse** — return `nil`, increment
  `rejectedAtBoundCount`, **do not** enqueue, **do not** drop existing work.
- Already-accepted work is never removed to make room.
- `advanceSessionEpoch` / `shutdown` are **not** subject to the work bound
  (control lane).

**Epoch interaction:**

- On `advanceEpoch` control: owner resets local engine session and updates
  `ownerEpoch` **before** executing later work.
- Work envelopes with `sessionEpoch != ownerEpoch` are **not executed** and
  count as `skippedStaleEpochCount` (discard of stale work, not input drop).
- Optional R4-Owner improvement: when epoch advances, owner may **drop only
  stale work already queued for old epochs** from the work lane (those items
  were accepted under the old epoch and are definitionally stale). Product
  allows stale discard of results; dropping unexecuted stale-epoch work is
  **allowed** because the epoch barrier already invalidated them. Work for the
  **new** epoch is never dropped.

**Stop interaction:**

- `stop` is control-priority.
- In-flight `processKey` is **not** cancelled mid-call.
- After stop is observed, owner exits loop; no further work executes.
- Pre-stop work may still run if it was dequeued before stop was preferred —
  acceptable. Once stop is dequeued from control, exit without draining the
  entire historical work backlog (control priority enables timely teardown).
  Any not-yet-executed work is abandoned with `abandonedAtStopCount` diagnostic
  (lifecycle abandon, not hot-path input drop under live composition).

**Jetsam note:** R4-Owner proves the **policy hooks and counters**. It does not
claim device jetsam numbers.

---

## 4. Type surface (implementation target)

Preferred public KeyboardCore surface (names may vary slightly if clarity
requires, but semantics must match):

| Type | Role |
|---|---|
| `ThreadAffineRimeEngineBootstrap` | Protocol: Sendable recipe; `makeEngineOnOwnerThread() -> any RimeEngine` |
| `ThreadAffineRimeOwnerConfiguration` | `maxPendingWorkDepth`, optional fixture id |
| `ThreadAffineRimeOwner` | Sendable owner handle; accept / epoch / shutdown |
| `ThreadAffineRimeDelivery` (internal OK) | Ordered result channel + terminal |
| `ThreadAffineRimeOwnerDiagnostics` | depths, rejects, skips, abandons, delivered |

Spike types may be refactored into the above or kept as typealiases during
migration. Tests must continue to prove:

- accept during ≥150 ms stall;
- FIFO no-dup;
- epoch / revision gates;
- lifecycle stop with omitted shutdown;
- **new:** refuse-at-bound;
- **new:** ordered delivery under concurrent completion;
- **new:** terminal drain after stop;
- **new:** control priority stop not buried forever behind artificial backlog
  (use Fake that blocks first key, flood queue, then stop — stop must still
  complete within bound wait).

Gate-off isolation test remains: owner not wired; controller synchronous.

---

## 5. API entry map for later phases (design only)

R4-Owner does not implement full session API, but freezes the **entry rule**:

| API class | Entry |
|---|---|
| processKey | Work lane, revisioned accept |
| Delete / select / Path / page / replaceInput | Future work-lane items with same revision/epoch model (R4-B+ or R3-parity port) |
| reset / recover / visibility suspend | Control lane or dedicated lifecycle control |
| runtime-selection callback | Must be re-emitted only as Sendable snapshot onto delivery channel; never call MainActor UI from owner |

---

## 6. Evidence requirements (Quality handoff)

Executor must produce:

1. Design file (this document) linked from Assignment / plan / PD.
2. Focused tests covering D1–D3 falsifiable claims.
3. Full KeyboardCore suite green.
4. Evidence note under `docs/evidence/` with counts and non-claims.
5. Explicit statement: no production wiring, gate default false, no ADR Accept.

Independent Architecture review checks structure vs this freeze.  
Independent Quality review re-runs tests and checks evidence honesty.

---

## 7. Stop conditions

Stop and escalate to Product / Architecture if:

- Swift 6 forces `@unchecked Sendable` to meet D1–D3;
- refuse-at-bound is pressured into silent drop of accepted keys;
- implementation wants Extension / `RimeEngineImpl` wire without R4-B auth;
- ADR 0025 Accept or Release default-on is requested as a side effect;
- real librime bootstrap is required to close D1 (D1 must close with Fake
  bootstrap + contract rules; real bootstrap is R4-B).

---

## 8. Handoff

| From | To | Payload |
|---|---|---|
| 🧭 Product Lead | 🏛️ Architecture | R4-Owner authorization (done) |
| 🏛️ Architecture | 🧠 Executor | This design freeze |
| 🧠 Executor | 🏛️ + 🧪 Reviewers | Code, tests, evidence SHA |
| Reviewers | 🧭 Product Lead | Pass/Fail + residual list for optional R4-B |

---

## 9. Architecture recommendation

**Proceed to implementation** of D1–D3 inside KeyboardCore under R4-Owner
scope. Do **not** treat this design as ADR Accept or off-main product completion.
After dual Pass (or Pass with conditions that do not reopen P0/P1), Product may
authorize **R4-B** real-librime Simulator evidence as a separate knife.
