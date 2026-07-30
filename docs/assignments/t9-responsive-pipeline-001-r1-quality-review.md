# Quality Review: T9-RESPONSIVE-PIPELINE-001 R1

| Field | Value |
|---|---|
| Reviewer role | 🧪 Quality, Performance & Release Maintainer (independent) |
| Date | 2026-07-30 Asia/Shanghai |
| Assignment | [`t9-responsive-rime-pipeline-001.md`](t9-responsive-rime-pipeline-001.md) |
| Executor evidence | [`../evidence/t9-responsive-pipeline-r1-2026-07-30.md`](../evidence/t9-responsive-pipeline-r1-2026-07-30.md) |
| Scope | R1 Fake RIME responsive state machine + tests only |
| Verdict | **Pass with conditions** |

**Non-claims:** This is **not** Architecture Pass, **not** Product Gate, and does **not** authorize R2 or any Release-default enablement.

## Commands re-run (independent)

```bash
cd Packages/KeyboardCore && swift test --filter ResponsiveRimePipelineTests
# Executed 17 tests, with 0 failures (0 unexpected)

cd Packages/KeyboardCore && swift test
# Executed 795 tests, with 0 failures (0 unexpected)
```

Matches executor evidence counts (17 / 795, 0 failures).

## Production isolation

| Check | Result |
|---|---|
| `ResponsiveRimePipeline` referenced outside its source/tests/docs | **No** production references (grep across repo; no hits under `KeyboardController*`) |
| `RimeEngineImpl` modified for this feature | **No** — git status shows only new pipeline source/tests + docs; no `RimeEngineImpl` diff |
| Runtime smoke: controller still sync RIME | `testPipelineDoesNotMutateControllerDefaultRimePath` passes (`processKeyCallCount == 2`) |
| Release default path | Unchanged; pipeline is additive pure type, not wired |

## Exit criteria matrix (R1)

| Criterion | Status | Evidence |
|---|---|---|
| Controllable delay incl. 150 ms | **Met** | `SleepingResponsiveRimeClock`; `testSimulatedOneHundredFiftyMillisecondClockHonorsDelayBudget`; 20 ms burst split |
| Accept without engine wait | **Met** | `testAcceptReceivesAllKeysWithoutCallingEngine`; wall-time accept vs drain |
| No drop / dup / reorder | **Met** | `testDrainPreservesOrderWithoutDropOrDuplicate` + fixture composition identity |
| Stale revision cannot overwrite | **Met** | `testOlderRevisionCannotOverwriteNewerPublishedSnapshot` via `tryApplyExternalSnapshot` |
| sessionEpoch invalidation | **Met** | `testSessionEpochBumpClearsPendingAndInvalidatesOldResults` |
| latestOnly coalesce | **Met** | `testLatestOnlyPublishSkipsIntermediateSnapshots` (+ everyResult contrast) |
| Delete / candidate / Path / reset | **Met** | dedicated order + fail-closed / fresh binding tests |
| Fail-closed stale selection | **Met** | candidate + Path stale; `validateSelection` epoch mismatch |
| Release default path unchanged | **Met** | isolation + controller sync smoke |
| Content-free diagnostics | **Met** | `ResponsiveRimeDiagnostics` fields are IDs/counts/timings; fixture ID assert; no raw-spelling log API |
| Focused suite green | **Met** | 17/0 re-run |
| Independent Quality review | **This document** | |
| Independent Architecture review | **Not this review** | Open |

## Findings

### P0 — none

### P1 — none that block R1 Quality acceptance

### P2

1. **Wall-clock assertions are soft and environment-sensitive.**  
   Accept/drain tests use `Thread.sleep` + factors (`0.7` min drain, accept `< 50ms` / `< delayMS`). Current machine is green; heavy CI load could theoretically flake. Prefer injectable fake clock that records wait counts for non-timing correctness, keep one optional budget test.

2. **Stale-revision overwrite is exercised mainly via test helper `tryApplyExternalSnapshot`.**  
   Serial `processNext` cannot naturally emit out-of-order revisions; helper proves `publishIfEligible` guards. Adequate for R1 single-threaded machine; R2 concurrent/async completion needs stronger late-result fixtures.

3. **Controller isolation test is a positive smoke only.**  
   Does not statically prove “no reference”; reviewer grep closed that gap. Optional future: package/architecture test or build-time allowlist.

4. **Work-item surface incompletely covered by tests:** `pageUp` / `pageDown` / `recoverSession` / `selectCandidateGlobal` share execute paths but lack dedicated cases. Acceptable under R1 scope (R3 owns recover/visibility contracts); track before wiring.

5. **Epoch bump does not re-prove discarding a fabricated old-epoch snapshot after new publish.** Logic exists (`publishIfEligible` epoch guard); add a one-liner negative test for maintainability.

### P3

1. `latestOnly` mid-policy mutation and partial `drain(limit:)` publish shape untested.
2. Unbound `replaceInput` (nil bound epoch/revision) lacks an explicit positive test.
3. Suite pays ~0.5s focused (mostly 150 ms + 20×8 sleeps); acceptable for R1, watch total suite budget if more sleep tests accumulate.

## Conditions (for R2 readiness, not R1 rework blockers)

1. Before R2 serial-owner wiring: add late-result / epoch-stale publish negatives that model async completion, not only `tryApplyExternalSnapshot`.
2. Prefer deterministic clock mock for order/revision tests; keep at most one real-sleep budget probe for the 150 ms product case.
3. Do not treat this Quality Pass as permission to change Release defaults or wire `KeyboardController` / `RimeEngineImpl`.

## Unexecuted checks and why

| Check | Why skipped |
|---|---|
| Simulator / real librime | R4 |
| Device Reminders A/B | R5 / Human |
| Production wiring / gate off equivalence under load | R2+ |
| Architecture Pass | Separate reviewer |
| Product Gate / SLO | R6 / Product |
| Release-default enablement recommendation | Explicitly out of scope |

## Explicit non-claims

- Not Architecture Pass
- Not Product Gate
- Not R2 authorization
- Not a claim that MainActor remains non-blocking under real UIKit + librime
- Not a recommendation to enable any responsive path in Release
