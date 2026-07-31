# Quality Review: T9-RESPONSIVE-PIPELINE-001 R2

| Field | Value |
|---|---|
| Reviewer role | 🧪 Quality, Performance & Release Maintainer (independent) |
| Date | 2026-07-30 Asia/Shanghai |
| Assignment | [`t9-responsive-rime-pipeline-001.md`](t9-responsive-rime-pipeline-001.md) |
| Product Decision | [`../product-decisions/T9-RESPONSIVE-PIPELINE-001-authorization.md`](../product-decisions/T9-RESPONSIVE-PIPELINE-001-authorization.md) |
| Executor evidence | [`../evidence/t9-responsive-pipeline-r2-2026-07-30.md`](../evidence/t9-responsive-pipeline-r2-2026-07-30.md) |
| Plan R2 section | [`../plans/t9-responsive-rime-pipeline-plan.md`](../plans/t9-responsive-rime-pipeline-plan.md) |
| Scope | R2 default-off serial owner + deferred composition `processKey` path + coordinator tests |
| Verdict | **Pass with conditions** |

**P0: 0**  
**P1: 1**  
**P2: 4**  
**P3: 2**

---

## Commands re-run and results

Independent re-run on this machine (do **not** trust Executor counts alone):

```bash
cd "/Users/doubleshy0n/Dev/Universe Keyboard/Packages/KeyboardCore" && swift test --filter ResponsiveRime
```

| Suite | Executed | Failures |
|---|---:|---:|
| `ResponsiveRimePipelineTests` (R1) | 23 | 0 |
| `ResponsiveRimeR2CoordinatorTests` (R2) | 7 | 0 |
| **Filter total** | **30** | **0** |

```bash
cd "/Users/doubleshy0n/Dev/Universe Keyboard/Packages/KeyboardCore" && swift test
```

| Suite | Executed | Failures |
|---|---:|---:|
| `KeyboardCoreTests` / All tests | **808** | **0** |

Matches Executor evidence (`30` focused / `808` full, 0 failures). No false green observed under re-run.

---

## Exit criteria coverage

R2 authorized intent (PD + plan + evidence): default-off gate; `SerialRimeSessionOwner` + `ResponsiveRimeSessionCoordinator`; composition `processKey` deferred when gate on; visibility epoch bump; tests; no Release default-on; isolation residual stated honestly.

| Criterion | Status | Independent evidence |
|---|---|---|
| `isResponsiveRimePipelineEnabled` **default false** | **Met** | Source: `KeyboardController.swift` property initializer `= false`. Grep: only test sets `= true` (`ResponsiveRimeR2CoordinatorTests`). No App / Keyboard Extension force-enable. |
| Release path = ADR 0004 sync when gate off | **Met** | `testGateDefaultIsOffAndControllerStaysSynchronous` + full suite green; gate branch skipped when false. |
| Serial owner + coordinator present | **Met** | `SerialRimeSession.swift`: `@MainActor` `SerialRimeSessionOwner` + `ResponsiveRimeSessionCoordinator`. |
| Deferred `handle` return before engine (key path) | **Met (unit)** | `testScheduleProcessKeyReturnsBeforeEngineWhenDeferredDrain` (40 ms clock, schedule &lt; 20 ms, call count 0 until drain); `testControllerGateEnablesDeferredProcessKey`. |
| Ordered multi-key composition under coordinator | **Met (weak assertion)** | `testOrderedKeysPreserveCompositionUnderGate` ends with `sessionComposition == "ni"` / `processKeyCallCount == 2` (see P2-1). |
| Epoch bump clears pending / invalidates generation | **Met** | `testEpochBumpInvalidatesInFlightGeneration`; controller `abandonCompositionForVisibilityChange` bumps coordinator epoch when gate on. |
| Fail-closed selection on owner | **Met** | `testStaleSelectionFailsClosedOnOwner`. |
| Ordered Delete on owner API surface | **Partial** | `testPerformOrderedDeleteAfterKeys` uses `performOrderedNow` only — **not** controller gate-on `handle(.deleteBackward)` (still sync `rimeEngine`). |
| Path / candidate gate-on controller wiring | **Not R2-complete** | R1 pipeline has Path/candidate matrix; controller gate-on only schedules `processKey` (+ sync `performOrderedNow` for symbol `replaceInput`). Residual documented for R3. |
| No `@unchecked Sendable` in R2 code | **Met** | Grep on R2 sources: only policy comment forbidding it; no attribute use. |
| Content-free diagnostics / no privacy log leak | **Met** | Diagnostics = fixture ID / epochs / revisions / counts / timings. No new raw-input / candidate / host logging in `SerialRimeSession` / gate branch. |
| Isolation residual honesty | **Met** | PD R2 note, `SerialRimeSession` header, evidence “Isolation honesty”: MainActor single-consumer + deferred drain; **not** off-main librime. |
| Focused + full KeyboardCore green | **Met** | 30/0 and 808/0 re-run. |
| Independent Quality review | **This document** | |
| Architecture Pass / Product Gate | **Not this review** | Explicit non-claims below. |

---

## Findings

### P0 — none

- No Release default-on.
- No Extension / App force-enable of the gate.
- No privacy log leak observed in R2 surfaces.
- No false green on re-run (30 + 808).
- No `@unchecked Sendable` isolation bypass in new R2 code.

### P1

1. **Gate-on hot path does not re-bridge async publish to Extension `KeyboardEffect` / `syncUI`.**  
   When `isResponsiveRimePipelineEnabled == true`, composition keys call `scheduleProcessKey` and return from `handle` with only shift / separator-side effects (`effectsAfterChineseCompositionKey` does **not** inject `.compositionChanged`). Later, `applyResponsivePublishedSnapshot` mutates Core via `applyRimeOutput` but returns no effect and has **no** callback into Extension presentation. Extension UI still keys off `syncUI(with:)` from the **synchronous** `handle` return (`KeyboardViewController+Presentation` / `+InputActions`).  
   **Impact:** enabling the gate for real Keyboard Extension typing is **not** confidence-safe for visible composition / candidates / marked-text refresh, even though Core state may update.  
   **Severity vs R2 auth:** does not break default-off Release; **blocks confidence** for any experimental gate-on device use. Treat as R3/wiring condition, not a Release regression.

### P2

1. **R2 order test’s snapshot assertion is effectively dead.**  
   `scheduleDrain` returns early when `isDraining` is already true, so a second `scheduleProcessKey`’s `onPublished` is dropped; drain continues with the **first** callback only. `testOrderedKeysPreserveCompositionUnderGate` still passes via engine composition asserts and double-fulfill on the first callback — the `"ni"` check inside the second closure never runs. Fix test (or drain API) so multi-accept publish callbacks are intentional.

2. **`testControllerGateEnablesDeferredProcessKey` relies on flaky main-async timing.**  
   Uses `DispatchQueue.main.async` + `asyncAfter(0.05)` settle hops without binding to publish callback or deterministic clock. Green now; CI load or scheduler variance could flake. Prefer fulfill-from-`scheduleProcessKey` / expectation on `completedPublishCount` or injectable drain trigger.

3. **Misleading comment vs code on symbol `replaceInput`.**  
   Gate branch comment claims “still deferred one MainActor turn via scheduleProcessKey-equivalent path”, but `performOrderedNow` **synchronously** `accept` + `processNext` and then `applyResponsivePublishedSnapshot` inline — still blocks `handle` for that branch. Correct the comment (or implement true schedule) to avoid false maintainability assumptions.

4. **Gate-on incomplete serialisation of non-key session APIs (honest residual, weak test coverage).**  
   `handleDeleteBackward` / candidate / Path still call `rimeEngine` directly. Combined with deferred key drain, gate-on multi-gesture order (key then quick delete) is **not** covered and can desync engine vs queue. Owner exposes direct APIs **and** pipeline; R2 tests cover owner Delete/`validateSelection` only via `performOrderedNow`, not controller gate-on Path/Delete. Evidence already flags R3 residual — keep residual honest; add gate-on multi-action negative/order tests before any enablement experiment.

### P3

1. `refreshT9PinyinPathsAfterResponsivePublish()` is a no-op stub (`_ = state.t9PinyinPathState`). Acceptable only while gate stays off; track under R3 Path atomicity.
2. R1 residual (wall-clock soft budgets / sleep clocks) still present; R2 reuses same pattern for one 40 ms case — watch suite budget.

---

## Production isolation / default-off check

| Check | Result |
|---|---|
| Default `isResponsiveRimePipelineEnabled` | **`false`** in `KeyboardController` |
| Production force-enable (`= true`) outside tests | **None** (repo grep; only R2 test) |
| Keyboard Extension / App references | **None** for this flag |
| Gate-off path | Unchanged sync `engine.processKey` / `replaceInput` after the `if isResponsiveRimePipelineEnabled` branch |
| `@unchecked Sendable` in R2 sources | **None** (comment-only forbid) |
| Off-main librime claimed? | **No** — residual explicitly MainActor + deferred drain |
| Shipping advice | **Keep default off.** This review does **not** recommend enabling the gate in Release or any user-facing build. |

---

## Unexecuted checks

| Check | Why skipped |
|---|---|
| Architecture Pass (ADR 0025 §10 “actor or serial executor” vs MainActor residual) | Separate Architecture reviewer; not claimed here |
| Product Gate / Release default-on | Explicitly unauthorized |
| Simulator / real librime R4 matrix | R4 |
| Human Reminders A/B device | R5 / Human |
| Gate-on full Delete/Path/candidate controller matrix | R3 residual; not in R2 green claims |
| Extension live typing with gate forced on | Would require intentional enable + UI effect bridge; out of R2 Quality scope and unsafe given P1 |
| xcodebuild full app target | Not required by R2 commands; KeyboardCore package suite re-run is the bound regression surface |

---

## Conditions

1. **Keep `isResponsiveRimePipelineEnabled` default off** in all shipping / Release-adjacent configurations. Do not treat this Quality verdict as enablement advice.
2. **Do not run Human or device experiments with gate forced on** until: (a) async publish re-emits a presentation bridge (effect callback / equivalent) so Extension `syncUI` can refresh; (b) Delete / candidate / Path / recover share the same ordered owner queue as `processKey` (R3); (c) multi-action order tests cover key→delete and stale selection under gate-on controller.
3. Harden R2 tests before relying on them as gate-on confidence: replace dead second-callback assert; reduce pure `asyncAfter` settle flakiness.
4. Correct the symbol-`replaceInput` “deferred” comment (or implement deferred) so docs/code stay aligned.
5. Isolation residual remains open for Architecture: R2 is **not** off-main librime; long `process_key` still occupies MainActor during drain turns.

---

## Explicit non-claims

- **Not** Architecture Pass (and not re-judging ADR 0025 Accept readiness).
- **Not** Product Gate.
- **Not** permission to set Release default on or ship gate-on behavior.
- **Not** a claim that MainActor deferred drain equals product “non-stutter” under real UIKit + librime.
- **Not** a claim that gate-on Path / Delete / candidate / UI atomic publish is complete.
- **Not** R3+ authorization.

---

## Executor P1 remediation addendum (2026-07-30)

| Item | Status |
|---|---|
| Quality P1 presentation bridge | **Remediated:** `onResponsivePresentationNeeded` → `syncUI`; test `testControllerGateEnablesDeferredProcessKeyAndPresentationBridge` |
| Dual-entry Delete order | **Remediated:** bridge + full-queue drain; `testDeleteThroughBridgeWaitsForPendingProcessKey` |
| Publish-handler multi-accept | **Remediated:** single shared `setPublishHandler` |
| Arch P1-3 off-main | Unchanged residual |

Not an independent Quality re-Pass; keep gate default off.

---

## Verdict rationale (summary)

R2 as authorized — **default-off serial owner scaffold + deferred composition key accept + honest isolation residual + green focused/full KeyboardCore** — is **Quality-acceptable with conditions**. Independent re-run confirms Executor counts. The single **P1** is gate-on presentation/order incompleteness that **must not** be read as readiness to enable the feature; Release isolation holds while the flag stays false.
