# T9 responsive pipeline R4-Owner evidence — 2026-07-31

**Status:** `R4-Owner dual independent review Pass with conditions; keep gate off; ADR 0025 Proposed; R4-B not claimed`  
**Assignment:** [`T9-RESPONSIVE-PIPELINE-001`](../assignments/t9-responsive-rime-pipeline-001.md)  
**Design:** [`R4-Owner design`](../assignments/t9-responsive-pipeline-001-r4-owner-design.md)  
**Product:** R4-Owner authorized 2026-07-31 (Arch P2 owner contract only)  
**Architecture:** [`ADR 0025`](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md) (`Proposed` — not Accepted)  
**Predecessor:** Spike-P1-3 remediation `c0e2373`

## Scope

Close Spike-P1-3 Architecture residual **P2** items on the disconnected
thread-affine owner:

| Decision | Claim |
|---|---|
| D1 bootstrap | `ThreadAffineRimeEngineBootstrap` config-only recipe; engine local to owner |
| D2 delivery | Single ordered delivery channel + terminal drain after stop |
| D3 mailbox | Bounded work lane, refuse-at-bound, control-priority stop/epoch |

**Not claimed:** real librime, Extension wiring, gate default-on, ADR Accept,
Product Gate, device/jetsam numbers, full RimeEngine API surface.

## Commands

```bash
SWIFTPM_MODULECACHE_OVERRIDE=/private/tmp/universe-spike-swift-module-cache \
CLANG_MODULE_CACHE_PATH=/private/tmp/universe-spike-clang-module-cache \
swift test --package-path Packages/KeyboardCore \
  --filter ThreadAffineRimeSpikeTests
```

Result: **10 passed / 0 failed** (prior Spike 7 + 3 R4-Owner cases).

```bash
swift test --package-path Packages/KeyboardCore
```

Result: **826 passed / 0 failed** (+3 R4-Owner tests vs Spike remediation 823).

## New falsifiable proofs

| Proof | Result |
|---|---|
| Refuse-at-bound; accepted work still delivered | `testRefuseAtBoundDoesNotDropAcceptedWork` |
| Ordered delivery + terminal after stop | `testOrderedDeliveryAndTerminalBarrierAfterStop` |
| Control-priority stop not buried by backlog | `testControlPriorityStopIsNotBuriedBehindWorkBacklog` |
| Prior Spike isolation / lifecycle | retained green |

## Independent review disposition

| Review | Document | Verdict |
|---|---|---|
| Architecture | [`r4-owner-architecture-review`](../assignments/t9-responsive-pipeline-001-r4-owner-architecture-review.md) | **Pass with conditions** — D1/D2/D3 Closed in R4-Owner scope; later P2 for real bootstrap / delivery backpressure / full API |
| Quality | [`r4-owner-quality-review`](../assignments/t9-responsive-pipeline-001-r4-owner-quality-review.md) | **Pass with conditions** — independent re-run 10/10 and 826/826; no `@unchecked Sendable`; no production wire |

## Explicit non-claims

- R4-B Simulator real librime matrix
- `KeyboardController` / Extension / `RimeEngineImpl` production wire
- Release default-on / user settings
- ADR 0025 Accept / Product Gate
- Formal jetsam SLO (only policy hooks + counters)
- Closing global production **P1-3-off-main** readiness
