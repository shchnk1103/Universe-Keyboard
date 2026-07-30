# T9 responsive pipeline Spike-P1-3 evidence — 2026-07-30

**Status:** `Lifecycle P1 remediated — independent re-reviews Pass with conditions; keep gate off; ADR 0025 Proposed`
**Assignment:** [`T9-RESPONSIVE-PIPELINE-001`](../assignments/t9-responsive-rime-pipeline-001.md)
**Spike design:** [`Spike-P1-3`](../assignments/t9-responsive-pipeline-001-spike-p1-3-design.md)
**Architecture:** [`ADR 0025`](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md) (`Proposed`)
**Baseline:** branch `codex/t9-auto-anchor-s5-checkpoint`, Fail checkpoint `45c426f`, remediation **`c0e2373`**, parent tip `3273057`

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

### Initial Fail checkpoint (`45c426f`)

Result at Fail checkpoint: **5 passed / 0 failed** (no omitted-shutdown /
explicit lifecycle identity cases yet).

### Lifecycle remediation (`c0e2373`, re-validated 2026-07-31)

Result: **7 passed / 0 failed**.

| Proof | Result |
|---|---|
| First owner engine call remains blocked at least 150 ms | PASS; stall inside Fake `processKey`; test elapsed about 190 ms |
| MainActor accepts three later keys while owner is blocked | PASS; accept path stayed below its 50 ms falsification bound |
| FIFO / no drop / no duplicate | PASS; 12 action IDs and revisions preserved |
| Engine creation off MainActor | PASS |
| Every tested call stays on engine creation thread | PASS |
| Epoch barrier | PASS; old result rejected, reset precedes new-epoch key |
| Older revision after newer revision | PASS; rejected by MainActor gate |
| Explicit shutdown destroys engine on owner thread | PASS (`testExplicitShutdownDestroysEngineOnItsOwnerThread`) |
| Omitted shutdown: deinit still stops thread and destroys engine on owner thread | PASS (`testOwnerDeinitStopsThreadAndDestroysEngineWhenShutdownIsOmitted`) |
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

Fail checkpoint (`45c426f`): **821 passed / 0 failed**.

Lifecycle remediation re-run (2026-07-31) at `c0e2373`: **823 passed / 0 failed**
(+2 lifecycle tests).

Static checks:

- `git diff --check`: PASS
- targeted `@unchecked Sendable` scan of Spike source/tests: no occurrence

## Proven

1. Swift 6 accepts a construction where a non-Sendable engine is created,
   called and released inside one dedicated thread without an unchecked
   conformance.
2. MainActor work acceptance can continue during a 150 ms+ owner stall that
   occurs inside Fake `processKey`.
3. Process-key inputs execute FIFO without drop/duplicate in the Fake proof.
4. Sendable snapshots can re-enter MainActor and be filtered by epoch/revision.
5. The proof does not alter current gate-off behavior.
6. Explicit `shutdown()` and omitted-shutdown `deinit` both stop the owner
   thread and destroy the local engine on that same owner thread
   (`requestStop` is idempotent).

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

## Independent review disposition

### Fail at `45c426f`

Independent Architecture and Quality reviews bound to `45c426f` both returned
**Fail** with the same P1:

- omitted explicit `shutdown()` orphaned the dedicated thread and thread-local
  engine;
- tests proved only explicit shutdown, not destruction when the handle is
  dropped.

Quality also found that the 150 ms block lived in the pre-engine hook, so the
evidence wording “engine call blocked” was too strong for that checkpoint.

### Remediation

- idempotent `requestStop()` shared by explicit `shutdown()` and non-blocking
  owner `deinit`;
- controlled 150 ms blocking moved into a lifecycle-probe Fake engine's
  `processKey` (no pre-engine hook stall);
- explicit and omitted-shutdown tests observe init/process/deinit thread
  identity on the owner thread.

### Re-validation (2026-07-31)

| Suite | Result |
|---|---|
| `ThreadAffineRimeSpikeTests` | **7 / 0** |
| Full `KeyboardCore` | **823 / 0** |
| `git diff --check` | PASS (dirty tree at validation time) |
| targeted `@unchecked Sendable` scan | no occurrence in Spike source/tests |

### Re-review disposition

| Review | Document | Verdict |
|---|---|---|
| Architecture re-review | [`architecture-rereview`](../assignments/t9-responsive-pipeline-001-spike-p1-3-architecture-rereview.md) | **Pass with conditions** — lifecycle P1 Closed; P2 residuals (factory / delivery FIFO / unbounded mailbox) remain for R4 |
| Quality re-review | [`quality-rereview`](../assignments/t9-responsive-pipeline-001-spike-p1-3-quality-rereview.md) | **Pass with conditions** — lifecycle + stall P1/P2 Closed; residual P3 on 50 ms wording |

**Still not claimed:** ADR 0025 Accept, Product Gate, R4 production wiring,
real librime on dedicated thread, device/jetsam, Release default-on.
