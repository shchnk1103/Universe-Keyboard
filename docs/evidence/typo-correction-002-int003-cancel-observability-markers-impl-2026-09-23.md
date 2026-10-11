# Evidence: INT-003 cancel observability markers implementation — 2026-09-23

## Identity

| Field | Value |
|---|---|
| **Kind** | Implementation tip receipt (markers land; observe-only) |
| **AUTH** | [`AUTH-TYPO-CORRECTION-002-INT003-CANCEL-OBSERVABILITY-MARKERS-001`](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-CANCEL-OBSERVABILITY-MARKERS-001.md) (**Consumed** at `2026-09-23T18:47:17+08:00`) |
| **Assignment** | [`TYPO-CORRECTION-002-INT003-CANCEL-OBSERVABILITY-MARKERS-001`](../assignments/typo-correction-002-int003-cancel-observability-markers-001.md) |
| **Baseline tip** | `9b8b7a73f4d373adbd7ee436d318cde3d9bc4c78` (#151 Live mark) |
| **Consume docs tip** | `70d2bf24258dacd47fda7e0c5bfdfa744befd549` |
| **Implementation tip** | `c1869cf9dda9f1643495e8ebdcfb67acc788b843` (#152 squash-merge onto main) |
| **Branch tip (historical)** | `862014483a4a879e55a159b298184c870d116124` |
| **Branch** | `codex/typo-correction-002-int003-cancel-observability-markers-impl` |
| **Executor** | Grok Bot iOS开发大师 under Human continue-auth |
| **Recorded at** | `2026-09-23T18:47:17+08:00` (consume); tip filled at land |

## What landed

### Schema (`DiagnosticEvent`, schemaVersion **3 → 4**)

**Codes**

| Raw | Swift |
|---|---|
| `typo_recall.debounce_scheduled` | `typoRecallDebounceScheduled` |
| `typo_recall.debounce_cancelled` | `typoRecallDebounceCancelled` |
| `typo_recall.epoch_bumped` | `typoRecallEpochBumped` |
| `typo_recall.fence_discarded` | `typoRecallFenceDiscarded` |
| `typo_recall.query_begin` | `typoRecallQueryBegin` |
| `typo_recall.query_outcome` | `typoRecallQueryOutcome` |

**CountMetrics:** `recall_epoch`, `composition_revision`, `operation_ordinal`, `composition_length`, `composition_fingerprint`

**Reasons (query outcome):** `typo_recall_query_succeeded`, `typo_recall_query_discarded`, `typo_recall_query_cancelled`

**Flags added:** none

### Emit points (`TypoCorrectionRecallCoordinator`)

| Path | Codes |
|---|---|
| `scheduleAfterCompositionSettled` | `debounce_cancelled` (if prior pending) → `debounce_scheduled` (if eligible) |
| `invalidateTypoCorrectionRecall` | `epoch_bumped` → optional `debounce_cancelled` |
| Fence mismatch / `.discarded` / failed yield / stale apply | `fence_discarded` |
| `performQuery` | `query_begin`; `query_outcome` + Reason |

All emits gated by `host.isHighFidelityDiagnosticsActive`. Category `.performance`. Fields via `TypoCorrectionRecallDiagnosticMarkers.fenceFields` (no composition text).

### Product rules

- Debounce remains **`0.18` s** — unchanged.
- Eligibility (letters + Chinese + length ≥ 8) — unchanged.
- No `RimeRuntimeProvenance` restore.

### Tests

| Test | Coverage |
|---|---|
| `DiagnosticEventTests.testTypoRecallCodesRoundTripWithFenceFieldsOnly` | Round-trip + no composition text in JSON |
| `DiagnosticEventTests.testTypoRecallQueryOutcomeCarriesFiniteReason` | Outcome Reason |
| `TypoCorrectionRecallDiagnosticMarkersTests` | Fingerprint stability; allowlisted field names; schemaVersion 4 |

## Local verification (this executor environment)

| Check | Result |
|---|---|
| `xcrun swift-format lint --strict` | **Skipped** — Linux box; no `xcrun` / Apple Swift toolchain |
| KeyboardCore XCTest | **Skipped locally** — no macOS/Xcode on box; hosted CI must run |
| `scripts/ci/run_lightweight_checks.sh` | Run on branch before PR |

## Field-budget

[`typo-correction-002-int003-cancel-observability-markers-field-budget-2026-09-23.md`](typo-correction-002-int003-cancel-observability-markers-field-budget-2026-09-23.md) accepted before Swift.

## Non-claims

- No Capture Live; Capture AUTH remains Proposed.
- No Product Gate / parent Close / TestFlight / Release.
- Markers landing alone do **not** prove INT-003 cancel; they enable a future Live Capture to collect positive observations.
- Implementation PR [#152](https://github.com/shchnk1103/Universe-Keyboard/pull/152) was **Human squash-merged** to main as `c1869cf9dda9f1643495e8ebdcfb67acc788b843`; executor did not merge.

## Integrity

| Field | Value |
|---|---|
| **External Run / JSONL** | **N/A** — no Simulator capture under this AUTH |
| **Consume tip** | `70d2bf24258dacd47fda7e0c5bfdfa744befd549` |
| **Implementation tip** | `c1869cf9dda9f1643495e8ebdcfb67acc788b843` (#152 squash-merge onto main) |
| **Branch tip (historical)** | `862014483a4a879e55a159b298184c870d116124` |
