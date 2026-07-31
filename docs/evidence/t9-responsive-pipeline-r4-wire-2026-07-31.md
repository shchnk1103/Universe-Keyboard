# T9 responsive pipeline R4-Wire evidence — 2026-07-31

**Status:** `R4-Wire dual review Pass with conditions (P1 delivery deadlock remediated); dual gate default-off`  
**Design:** [`r4-wire-design`](../assignments/t9-responsive-pipeline-001-r4-wire-design.md)  
**Product:** R4-Wire authorized 2026-07-31 (dual gate default-off)  
**Reviews:** [`architecture`](../assignments/t9-responsive-pipeline-001-r4-wire-architecture-review.md), [`quality`](../assignments/t9-responsive-pipeline-001-r4-wire-quality-review.md)

## Scope

Wire thread-affine owner into `KeyboardController` behind:

- `isResponsiveRimePipelineEnabled` (default `false`)
- `isThreadAffineRimeOwnerEnabled` (default `false`)
- `threadAffineEngineBootstrap` (required for dual-gate path)

## Results

| Suite | Result |
|---|---|
| `ThreadAffineRimeSpikeTests` | **10 / 0** |
| `ThreadAffineRimeWireTests` | **5 / 0** |
| KeyboardCore full | **831 / 0** |

### Wire proofs

| Case | Result |
|---|---|
| Dual gates default off | PASS |
| Dual-gate + Fake bootstrap: handle does not wait on blocked engine | PASS |
| ThreadAffine flag alone does not change gate-off sync path | PASS |
| Responsive-only keeps MainActor bridge | PASS |
| Dual-gate installs `ThreadAffineRimeEngineBridge`; `underlyingRimeEngine == nil` | PASS |
| Visibility suspend/resume | PASS |

### P1 remediation note

Architecture flagged MainActor pump + `performOrderedNow` sleep deadlock. Delivery
now invokes handlers **synchronously on the owner thread** so `lastPublished`
updates without scheduling a MainActor Task. UI hops via `NotificationCenter`
main queue.

## Explicit non-claims

- Neither gate default-on
- ADR 0025 Accept / Product Gate / R5
- Full Extension production enablement of dual-gate (bootstrap install site optional)
- Device non-stutter
- Closing delivery backpressure / full Path auto-anchor parity on thread-affine
