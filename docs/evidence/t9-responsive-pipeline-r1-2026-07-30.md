# T9-RESPONSIVE-PIPELINE-001 R1 evidence — Fake RIME responsive state machine

| Field | Value |
|---|---|
| Status | **Executor complete — independent Architecture/Quality review pending** |
| Date | 2026-07-30 Asia/Shanghai |
| Assignment | [`T9-RESPONSIVE-PIPELINE-001`](../assignments/t9-responsive-rime-pipeline-001.md) |
| Product Decision | [`PD-T9-RESPONSIVE-PIPELINE-001`](../product-decisions/T9-RESPONSIVE-PIPELINE-001-authorization.md) |
| Architecture | [`ADR 0025`](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md) (**Proposed**) |
| Fixture ID | `T9RESP-FIX-001` |
| Frozen spelling (tests only; not production-logged) | `jintiandetianqizhenbucuowomenchuquwanba` |

## Authorization boundary

Human Product Owner authorized **R1 only**:

- controllable-delay Fake RIME
- responsive input state machine + regression tests
- **no** real librime session migration
- **no** Release default behavior change

Executor does **not** claim Architecture Pass, Quality Pass, or Product Gate.

## Deliverables

| Path | Role |
|---|---|
| `Packages/KeyboardCore/Sources/KeyboardCore/ResponsiveRimePipeline.swift` | Pure accept/queue/drain/publish state machine |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/ResponsiveRimePipelineTests.swift` | R1 matrix (17 tests) |

Not modified for wiring:

- `KeyboardController` production handle path
- `RimeEngineImpl` / Extension session ownership
- Release build defaults

## Verification

### Initial R1 delivery

```bash
cd Packages/KeyboardCore && swift test --filter ResponsiveRimePipelineTests
# 17 tests, 0 failures

cd Packages/KeyboardCore && swift test
# 795 tests, 0 failures
```

### After Architecture P1 remediation (same day)

```bash
cd Packages/KeyboardCore && swift test --filter ResponsiveRimePipelineTests
# 23 tests, 0 failures

cd Packages/KeyboardCore && swift test
# 801 tests, 0 failures
```

Remediation: `lastAppliedRevision` / `lastPublishedRevision` split; selection
requires applied==published==bound; latestOnly catch-up; enqueued reset/recover
epoch bump; ADR 0025 §§10–11 freezes.

### Covered R1 exit criteria

| Criterion | Evidence |
|---|---|
| Controllable delay (incl. 150 ms) | `testSimulatedOneHundredFiftyMillisecondClockHonorsDelayBudget`, 20 ms burst test |
| Accept without waiting for engine | `testAcceptReceivesAllKeysWithoutCallingEngine`, wall-time split tests |
| No drop / dup / reorder | `testDrainPreservesOrderWithoutDropOrDuplicate` |
| Stale revision cannot overwrite | `testOlderRevisionCannotOverwriteNewerPublishedSnapshot` |
| Epoch invalidates pending | `testSessionEpochBumpClearsPendingAndInvalidatesOldResults` |
| Latest-only UI coalesce | `testLatestOnlyPublishSkipsIntermediateSnapshots` |
| Delete / candidate / Path / reset | dedicated order + fail-closed tests |
| Controller default path unchanged | `testPipelineDoesNotMutateControllerDefaultRimePath` |

## Not executed (R1 out of scope)

- Simulator / real librime integration (R4)
- Physical-device Reminders A/B (R5)
- Wiring serial owner into Extension production path (R2)
- Independent Architecture / Quality formal review conclusions
- Product Gate / Release enablement (R6)

## Residual risks

1. R1 proves the **state machine**, not MainActor non-blocking under real UIKit load.
2. Host digit projection remains outside the pipeline (existing T9 host safety tests).
3. Production wiring may surface isolation/Sendable issues when R2 starts.
4. Pending-queue memory policy for long stalls is deferred (measure in R2/R3).
5. ADR 0025 remains **Proposed** until Architecture acceptance.
