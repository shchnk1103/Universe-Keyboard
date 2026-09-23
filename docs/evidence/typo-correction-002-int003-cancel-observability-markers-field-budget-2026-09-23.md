# Evidence: INT-003 cancel observability markers — ADR 0027 field-budget review

## Identity

| Field | Value |
|---|---|
| **Kind** | ADR 0027 field-budget / privacy allowlist review (docs evidence before new Codes/Flags) |
| **AUTH** | [`AUTH-TYPO-CORRECTION-002-INT003-CANCEL-OBSERVABILITY-MARKERS-001`](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-CANCEL-OBSERVABILITY-MARKERS-001.md) |
| **Assignment** | [`TYPO-CORRECTION-002-INT003-CANCEL-OBSERVABILITY-MARKERS-001`](../assignments/typo-correction-002-int003-cancel-observability-markers-001.md) |
| **ADR** | [`0027-enterprise-local-diagnostic-observability`](../architecture/decisions/0027-enterprise-local-diagnostic-observability.md) |
| **Baseline tip** | `9b8b7a73f4d373adbd7ee436d318cde3d9bc4c78` (main after #151 Live mark) |
| **Implementation / squash tip** | `c1869cf9dda9f1643495e8ebdcfb67acc788b843` (#152) |
| **Reviewer / consumer** | Grok Bot iOS开发大师 under Human continue-auth (2026-09-23 Asia/Shanghai) |
| **Recorded at** | `2026-09-23T18:47:17+08:00` |

## Decision

**Accept** a minimal additive `DiagnosticEvent` vocabulary for typo-recall cancel/debounce/epoch/fence/query observations. Observe-only; **no** 180 ms product budget or eligibility change; **no** composition text in the journal; **no** `RimeRuntimeProvenance` restore.

HF discipline: emit only when `isHighFidelityDiagnosticsActive` (same gate as candidate-touch / first-second HF probes). Ordinary / logging-off paths must not grow these events.

Schema: bump `DiagnosticEvent.schemaVersion` **3 → 4** because this lands a new event family (additive Codes + CountMetrics + Reasons). Existing readers already tolerate unknown lines best-effort; writers stamp v4.

## Proposed Codes (accepted)

| Code raw value | Swift case | Intent |
|---|---|---|
| `typo_recall.debounce_scheduled` | `typoRecallDebounceScheduled` | Debounce work-item armed (or re-armed) after eligibility |
| `typo_recall.debounce_cancelled` | `typoRecallDebounceCancelled` | Prior pending debounce cancelled (re-schedule or invalidate) |
| `typo_recall.epoch_bumped` | `typoRecallEpochBumped` | Hard invalidate bumped `recallEpoch` |
| `typo_recall.fence_discarded` | `typoRecallFenceDiscarded` | In-flight fence / yield / apply discarded as stale |
| `typo_recall.query_begin` | `typoRecallQueryBegin` | Contextual correction query about to run (no provenance restore) |
| `typo_recall.query_outcome` | `typoRecallQueryOutcome` | Query finished with finite outcome Reason |

## Proposed CountMetrics (accepted)

| Metric raw value | Swift case | Bound / privacy |
|---|---|---|
| `recall_epoch` | `recallEpoch` | Integer epoch; content-free |
| `composition_revision` | `compositionRevision` | Integer revision; content-free |
| `operation_ordinal` | `operationOrdinal` | Integer ordinal; content-free |
| `composition_length` | `compositionLength` | Length only (clamped); **not** text |
| `composition_fingerprint` | `compositionFingerprint` | FNV-1a 32-bit of normalized composition as Int; non-reversible dump of text; correlation only |

## Proposed Reasons (accepted; query outcome only)

| Reason raw value | Swift case |
|---|---|
| `typo_recall_query_succeeded` | `typoRecallQuerySucceeded` |
| `typo_recall_query_discarded` | `typoRecallQueryDiscarded` |
| `typo_recall_query_cancelled` | `typoRecallQueryCancelled` |

No new `Flag` values in this slice (existing HF / candidate flags unchanged).

## Explicitly rejected / deferred

| Item | Why |
|---|---|
| Free-text composition / preedit / candidate strings | ADR 0027 privacy; AUTH forbids PII dump |
| Composite payload struct (scheme-delivery style) | Unnecessary for this slice; Code + Field allowlist suffices |
| Changing 180 ms debounce constant | Observe-only default |
| Emitting on non-HF paths | Volume / HF discipline |
| Restoring `RimeRuntimeProvenance` | Explicit AUTH exclusion |
| Capture / Product Gate claims from markers alone | Separate AUTHs |

## Field budget summary

| Dimension | Before | After (this slice) | Budget note |
|---|---|---|---|
| `Code` cases | 23 | 29 (+6) | New family namespaced `typo_recall.*` |
| Integer field budget (`CountMetric`+`DurationMetric`) | **11** | **16** (+5) | Tip-verified at `c1869cf9…` — Quality correction vs draft 9→14; see note |
| `Reason` cases | 10 | 13 (+3) | Finite query outcomes only |
| `Flag` cases | 6 | 6 (+0) | No new flags |
| `schemaVersion` | 3 | 4 | Additive event-family bump |

### CountMetrics arithmetic correction (tip `c1869cf9…`)

Quality noted the earlier draft claimed **`CountMetric` 9→14**, but the tip baseline numeric vocabulary at `c1869cf9dda9f1643495e8ebdcfb67acc788b843` is **11→16** (+5 correct additive set). No new metric names invented.

| Bucket | Before (`9b8b7a7…`) | After (`c1869cf9…`) |
|---|---|---|
| `CountMetric` enum cases | 9 | 14 |
| `DurationMetric` enum cases (unchanged companions in the same integer-field budget) | 2 | 2 |
| **Tip baseline total (Quality reading)** | **11** | **16** |

Additive `CountMetric` set (+5): `recall_epoch`, `composition_revision`, `operation_ordinal`, `composition_length`, `composition_fingerprint`.

`DurationMetric` remains `elapsed_ms` / `presentation_age_ms` only (**2→2**). The corrected budget line uses the tip total **11→16**; the enum split above is the DiagnosticEvent vocabulary at the squash tip.

## Non-claims

- This review does **not** implement markers by itself (implementation follows consume).
- Does **not** grant Capture Live, Architecture/Quality Gate, Product Gate, parent Close, TestFlight, or Release.
- Does **not** claim journal-proven cancel until a future Live Capture AUTH collects positive observations.

## Integrity

| Field | Value |
|---|---|
| **External Run / JSONL** | **N/A** — field-budget docs review only |
| **Baseline tip** | `9b8b7a73f4d373adbd7ee436d318cde3d9bc4c78` |
| **Squash tip** | `c1869cf9dda9f1643495e8ebdcfb67acc788b843` |
