# T9 responsive pipeline R4-B evidence — 2026-07-31

**Status:** `R4-B dual independent review Pass with conditions; keep gate off; ADR 0025 Proposed; Extension wire not claimed`  
**Assignment:** [`T9-RESPONSIVE-PIPELINE-001`](../assignments/t9-responsive-rime-pipeline-001.md)  
**Design:** [`R4-B design`](../assignments/t9-responsive-pipeline-001-r4-b-design.md)  
**Product:** R4-B authorized 2026-07-31  
**Architecture:** [`ADR 0025`](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md) (`Proposed` — not Accepted)  
**Predecessor:** R4-Owner `768d680`

## Scope

Prove a **real** `RimeEngineImpl` can be constructed from config-only Sendable
paths on the R4-Owner thread-affine owner, execute a short `processKey`
sequence with FIFO delivery, and shut down — without Extension production
wiring or gate default-on.

## Artifacts

| Item | Path / note |
|---|---|
| Bootstrap | `Packages/RimeBridge/Sources/RimeBridge/ThreadAffineRimeEngineImplBootstrap.swift` |
| Tests | `Packages/RimeBridge/Tests/RimeBridgeTests/ThreadAffineRimeRealEngineTests.swift` |
| Harness | `scripts/run_t9_responsive_r4b.sh` |
| Local run dir | `docs/evidence/r4b-runtime/manual-run2/` (local only; DerivedData **not** committed) |
| Executor log SHA-256 | `77cb218ab6c7fb11bbd0bde0f56f2c80b536125971c239da1b641b0e2822c658` |
| Quality re-run log SHA-256 | `0104e2cdcf4bf7d8e5b88d01e9909ab74b03eebb02c56ae0a1061dbbea4da252` |

## Commands

### KeyboardCore (Fake owner still green; iOS availability extended)

```bash
swift test --package-path Packages/KeyboardCore --filter ThreadAffineRimeSpikeTests
swift test --package-path Packages/KeyboardCore
```

Result: ThreadAffine **10/0**; full KeyboardCore **826/0**.

### RimeBridge real engine (iOS Simulator)

```bash
scripts/run_t9_responsive_r4b.sh
```

## Results (2026-07-31 local Executor run)

| Suite | Result |
|---|---|
| `ThreadAffineRimeRealEngineTests` | **2 passed / 0 failed** |
| `testRealEngineBootstrapCreatesAndCallsOffMainThroughOwner` | **PASS** (~17.8 s incl. deploy) |
| `testGateOffDefaultUnchangedByR4BBootstrapPresence` | **PASS** |
| Machine line | `R4B_REAL_ENGINE_RESULT passed=true schema=rime_ice keys=4 delivered=4 offMain=true sameThread=true` |
| xcodebuild | **TEST SUCCEEDED** |

### Matrix vs design

| Case | Result |
|---|---|
| M1 create/call off MainActor | **PASS** (`offMain=true`, `sameThread=true`) |
| M2 FIFO actionID order | **PASS** (`rk0`…`rk3`) |
| M3 shutdown + delivery terminal | **PASS** |
| M4 skip without fixture | **Supported** (`XCTSkip` when env missing) |
| M5 gate default off | **PASS** |

## Proven

1. Config-only `ThreadAffineRimeEngineImplBootstrap` builds real
   `RimeEngineImpl` only on the owner thread.
2. Real librime `processKey` results re-enter MainActor via ordered delivery.
3. Responsive gate remains default-off; R4-B does not enable production wire.

## Not proven / not claimed

- Extension / `KeyboardController` production migration of the owner;
- ADR 0025 Accept, Product Gate, Release default-on;
- R5 device subjective non-stutter;
- Full RimeEngine API surface on the owner;
- Formal jetsam / delivery-backpressure SLOs;
- That “claiming process runtime on non-main thread” log is a product guarantee
  (observational under this fixture only).

## Independent review disposition

| Review | Document | Verdict |
|---|---|---|
| Architecture | [`r4-b-architecture-review`](../assignments/t9-responsive-pipeline-001-r4-b-architecture-review.md) | **Pass with conditions** — real bootstrap proof Closed; P2-later delivery/Extension remain |
| Quality | [`r4-b-quality-review`](../assignments/t9-responsive-pipeline-001-r4-b-quality-review.md) | **Pass with conditions** — independent 10/826 + harness TEST SUCCEEDED |

## Residual notes

- Thread Performance Checker may still warn (owner `userInitiated` vs librime
  Default helpers); residual for wiring-phase QoS policy.
- Deploy still runs before owner start (Main-App-shaped); not inside hot path.
