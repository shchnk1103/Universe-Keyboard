# T9-RESPONSIVE-PIPELINE-001 / R4-Wire design

**Status:** `Active — Architecture design freeze for R4-Wire`  
**Date:** `2026-07-31 Asia/Shanghai`  
**Role author:** 🏛️ Architecture & Knowledge Steward  
**Parent Assignment:** [`T9-RESPONSIVE-PIPELINE-001`](t9-responsive-rime-pipeline-001.md)  
**Product:** R4-Wire authorized 2026-07-31  
**Predecessors:** R4-Owner `768d680`, R4-B `cb45f1c`  
**ADR 0025:** remains **Proposed** (this knife does not Accept)

---

## 1. Decision boundary

### In scope

Wire the thread-affine owner into `KeyboardController` behind a **dual gate**:

| Flag | Default | Meaning |
|---|---|---|
| `isResponsiveRimePipelineEnabled` | `false` | Existing R2/R3 MainActor deferred path |
| `isThreadAffineRimeOwnerEnabled` | `false` | Off-main owner when **both** true |

When **both** are true and a Sendable bootstrap is installed:

1. Engine is created **only** on the owner thread (no MainActor live session).
2. All `ResponsiveRimeWork` enters the same owner (no dual-entry).
3. Composition `processKey` is accepted on MainActor without waiting for librime.
4. Results re-enter MainActor via ordered delivery → existing
   `applyResponsivePublishedSnapshot` presentation path (R3 context FIFO).
5. Visibility suspend uses explicit stop/epoch; deinit remains safety net only.

When only responsive is true: keep **existing** MainActor `SerialRimeSessionOwner`
path (no behaviour change).

When either gate false: ADR 0004 sync path.

### Out of scope

- Default-on either gate; ADR Accept; Product Gate; R5;
- Claiming device non-stutter;
- Full Extension chrome rewrite beyond what is required for dual-entry safety;
- Delivery-queue backpressure SLO (P2-later-2 residual may remain).

---

## 2. Frozen decisions

### D1 — Dual gate

```text
responsive=false → sync ADR 0004
responsive=true, threadAffine=false → R2/R3 MainActor deferred
responsive=true, threadAffine=true + bootstrap → thread-affine owner
responsive=true, threadAffine=true + no bootstrap → fail closed to MainActor R2
  (or refuse rebuild; do not invent a half-wired engine)
```

**Product fail-closed:** missing bootstrap with threadAffine requested must **not**
silently use a MainActor-held live engine on the owner (would shuttle). Prefer
falling back to MainActor R2 path and content-free log, or leaving coordinator
nil until bootstrap is set — implementation must document which.

**Recommended:** fall back to MainActor R2 if bootstrap missing (preserves
gate-on experiments without false off-main claim).

### D2 — Single owner for all session work

Expand thread-affine work to full `ResponsiveRimeWork` (same enum as pipeline).
`ThreadAffineRimeEngineBridge` routes every `RimeEngine` protocol mutation into
the owner; reads that need session state use last snapshot / ordered query.

### D3 — Bootstrap only

Controller holds `threadAffineBootstrap: (any ThreadAffineRimeEngineBootstrap)?`
via type-erased Sendable box. Extension may later install
`ThreadAffineRimeEngineImplBootstrap(shared:user:schema:)` when enabling
threadAffine; default path still constructs `RimeEngineImpl` on MainActor for
gate-off and MainActor-responsive modes.

### D4 — Presentation

Reuse R3 `applyResponsivePublishedSnapshot` for pk-* contexts. Engine-mutating
Path/auto-anchor follow-ups that previously used `underlyingRimeEngine` on
MainActor must either:

- enqueue as owner work, or  
- operate only on snapshot/output without MainActor engine calls.

**R4-Wire minimum:** presentation + local Path refresh from output; engine-mutating
auto-anchor follow-ups that require live MainActor engine are **suppressed** in
thread-affine mode (explicit residual) unless enqueued on owner in the same
change set.

### D5 — Lifecycle

| Event | Action |
|---|---|
| abandon / epoch | control advanceEpoch + clear contexts |
| suspend visibility | flush waiters, suspend engine on owner, or stop+rebootstrap on resume |
| resume | resume on owner or rebuild owner from bootstrap |
| disable gate | shutdown owner, unwrap bridge, restore sync engine if any |

---

## 3. Types

| Type | Role |
|---|---|
| `AnyThreadAffineRimeEngineBootstrap` | Sendable type eraser |
| `ThreadAffineRimeSessionCoordinator` | scheduleProcessKey / performOrderedNow / lifecycle |
| `ThreadAffineRimeEngineBridge` | `RimeEngine` facade → coordinator |
| Controller flags + bootstrap property | dual gate |

---

## 4. Evidence

- Gate defaults false; gate-off sync test green.
- Dual-gate + Fake bootstrap: handle returns before 150 ms stall; presentation fires.
- Dual-gate missing bootstrap: documented fail-closed behaviour.
- Full KeyboardCore suite green.
- No `@unchecked Sendable`.

---

## 5. Explicit non-claims

ADR Accept, Product Gate, Release default-on, device A/B, jetsam SLO,
complete Extension chrome RimeEngineImpl casting under thread-affine mode.
