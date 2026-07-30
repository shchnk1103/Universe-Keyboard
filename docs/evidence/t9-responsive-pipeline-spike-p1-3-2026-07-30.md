# T9 responsive pipeline Spike-P1-3 evidence — 2026-07-30

**Status:** `Executor evidence complete — independent Architecture / Quality review pending`
**Assignment:** [`T9-RESPONSIVE-PIPELINE-001`](../assignments/t9-responsive-rime-pipeline-001.md)
**Spike design:** [`Spike-P1-3`](../assignments/t9-responsive-pipeline-001-spike-p1-3-design.md)
**Architecture:** [`ADR 0025`](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md) (`Proposed`)
**Baseline:** branch `codex/t9-auto-anchor-s5-checkpoint`, parent tip `3273057`

## Scope

This evidence covers only the Product-authorized thread-affine Fake proof for
Architecture residual P1-3. The Spike is not connected to
`KeyboardController`, the Extension or real `RimeEngineImpl`.

## Implementation

### `ThreadAffineRimeSpikeOwner`

- MainActor allocates epoch/revision and enqueues a Sendable process-key
  descriptor.
- One dedicated `Thread` blocks on a Sendable mailbox and executes FIFO.
- A Sendable factory recipe is invoked on that thread.
- The resulting non-Sendable engine exists only as a local variable in
  `runOwnerLoop`; it is released before the stopped barrier is signalled.
- The owner sends only `ThreadAffineRimeSpikeResult` value snapshots back to a
  `@MainActor @Sendable` handler.
- No `@unchecked Sendable` is used.

### `ThreadAffineRimeSpikeApplyGate`

- rejects epoch mismatch;
- rejects non-monotonic/older revision;
- records accepted value snapshots only;
- performs no UIKit, marked-text, candidate or Path mutation.

### Deliberate limit

Only `.processKey` is exposed. Delete, candidate/Path selection,
`replaceInput`, paging, runtime-selection callbacks, recovery and visibility
are R4 design work and are not claimed by this evidence.

## Falsifiable test results

Command:

```bash
SWIFTPM_MODULECACHE_OVERRIDE=/private/tmp/universe-spike-swift-module-cache \
CLANG_MODULE_CACHE_PATH=/private/tmp/universe-spike-clang-module-cache \
swift test --package-path Packages/KeyboardCore \
  --filter ThreadAffineRimeSpikeTests
```

Result: **5 passed / 0 failed**.

| Proof | Result |
|---|---|
| First owner engine call remains blocked at least 150 ms | PASS; test elapsed about 189 ms |
| MainActor accepts three later keys while owner is blocked | PASS; accept path stayed below its 50 ms falsification bound |
| FIFO / no drop / no duplicate | PASS; 12 action IDs and revisions preserved |
| Engine creation off MainActor | PASS |
| Every tested call stays on engine creation thread | PASS |
| Epoch barrier | PASS; old result rejected, reset precedes new-epoch key |
| Older revision after newer revision | PASS; rejected by MainActor gate |
| Spike disconnected / gate off | PASS; controller remains synchronous |

The 50 ms assertion is an experiment falsification threshold, not a Product
SLO or release claim.

## Full regression

Command:

```bash
SWIFTPM_MODULECACHE_OVERRIDE=/private/tmp/universe-spike-swift-module-cache \
CLANG_MODULE_CACHE_PATH=/private/tmp/universe-spike-clang-module-cache \
swift test --package-path Packages/KeyboardCore
```

Result: **821 passed / 0 failed**.

Static checks:

- `git diff --check`: PASS
- targeted `@unchecked Sendable` scan of Spike source/tests: no occurrence

## Proven

1. Swift 6 accepts a construction where a non-Sendable engine is created,
   called and released inside one dedicated thread without an unchecked
   conformance.
2. MainActor work acceptance can continue during a 150 ms+ owner stall.
3. Process-key inputs execute FIFO without drop/duplicate in the Fake proof.
4. Sendable snapshots can re-enter MainActor and be filtered by epoch/revision.
5. The proof does not alter current gate-off behavior.

## Not proven

- real `RimeEngineImpl` construction/destruction or real librime calls on the
  dedicated thread;
- complete RimeEngine API ownership;
- Extension integration, UIKit frame responsiveness or marked-text atomicity;
- R3 Path/auto-anchor post-processing on the off-main path;
- queue-depth policy, memory growth or jetsam behavior;
- visibility, recovery, schema/runtime-selection callbacks and process death;
- Simulator or physical-device behavior;
- Release readiness, ADR 0025 acceptance or Product Gate.

## Executor recommendation

The isolation mechanism is technically viable enough to justify an
Architecture review of an R4 production-wiring design. It is not sufficient to
authorize that wiring yet. Independent reviewers should focus on:

- whether the Sendable factory contract is strong enough for a real bridge;
- lifetime/shutdown and callback ordering;
- how all non-processKey APIs and R3 follow-up mutations enter the same owner;
- queue/jetsam bounds without dropping input;
- whether a separate RimeBridge-only real-engine fixture Spike is required
  before any Extension integration.
