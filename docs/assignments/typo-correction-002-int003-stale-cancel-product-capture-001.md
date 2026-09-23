# Assignment: TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001 — Consumed INT-003 product capture (stale cancel)

Policy version: 1.0.0

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001",
  "record_type": "assignment",
  "title": "Consumed AUTH: INT-003 product capture — long composition, <180 cadence, stale cancel observation",
  "lifecycle": "active",
  "current_phase": "AUTH Consumed; Capture Bounded/Inconclusive for stimulus — arm+install ready; Human visual taps pending (evidence written)",
  "authorization_action": "capture_int003_stale_cancel_product_observation_designated_simulator",
  "updated_at": "2026-09-23T20:19:10+08:00",
  "revalidation_triggers": [
    "docs_tip_changed_from_c1869cf",
    "observability_audit_or_gap_matrix_superseded",
    "designated_simulator_or_arm_method_changed",
    "scope_expansion_toward_implementation_or_gates",
    "AUTH_revoked_or_executor_changed",
    "parent_close_or_int003_product_gate_granted_elsewhere",
    "markers_schema_or_emit_contract_changed_without_rebind"
  ],
  "authorization_refs": ["AUTH-TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001"],
  "parent_refs": ["TYPO-CORRECTION-002"],
  "evidence_refs": [
    "docs/evidence/typo-correction-002-int003-stale-cancel-observability-audit-2026-09-23.md",
    "docs/evidence/typo-correction-002-int003-cadence-003-to-product-gap-matrix-2026-09-23.md",
    "docs/evidence/typo-correction-002-int003-cadence-2026-09-22-003.md",
    "docs/evidence/typo-correction-002-device-hub-validation.md",
    "docs/evidence/typo-correction-002-int003-cancel-observability-markers-impl-2026-09-23.md",
    "docs/evidence/typo-correction-002-sim-run-2026-09-23-int003-stale-cancel-product-001.md",
    "docs/reviews/typo-correction-002-int003-cadence-2026-09-22-003-architecture-review.md",
    "docs/reviews/typo-correction-002-int003-cadence-2026-09-22-003-quality-review.md"
  ],
  "responsibilities": {
    "domain_owner": "Input Intelligence Maintainer",
    "executor": "Grok Bot (iOS开发大师) — AUTH Consumed under Human continue-auth; Capture on designated Simulator",
    "environment_executor": "Grok Bot — designated Device Hub Simulator arm/capture under consumed AUTH",
    "human_dependency": "Human Product Owner / Product Lead — visual attestation during Live capture (required for Product-grade claims; may be pending/absent for journal-only bounded observation)",
    "architecture_reviewer": "Not Applicable for this Capture slice — separate Architecture AUTH required after Live capture package",
    "quality_reviewer": "Not Applicable for this Capture slice — separate Quality AUTH required after Live capture package",
    "product_approver": "Human Product Owner / Product Lead"
  }
}
```

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | **Active** (AUTH **Consumed**; Capture running / evidence finalize) |
| **Phase** | AUTH Consumed; evidence `…-int003-stale-cancel-product-001.md` — Bounded/Inconclusive stimulus; Human visual pending |
| **Matching AUTH** | [`AUTH-TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001`](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001.md) — **Consumed** |
| **Parent** | [`TYPO-CORRECTION-002`](typo-correction-002.md) remains **Active** (do **not** Close) |
| **Capture install tip** | `80091f35cc5411b292eca78662f39e2b91694045` (includes markers_impl `c1869cf9…`) |
| **Markers AUTH** | [`AUTH-TYPO-CORRECTION-002-INT003-CANCEL-OBSERVABILITY-MARKERS-001`](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-CANCEL-OBSERVABILITY-MARKERS-001.md) remains **Consumed** |
| **Run ID** | `TC2-SIM-20260923-201910-INT003-STALE-CANCEL-PRODUCT-001` |
| **Evidence** | [`docs/evidence/typo-correction-002-sim-run-2026-09-23-int003-stale-cancel-product-001.md`](../evidence/typo-correction-002-sim-run-2026-09-23-int003-stale-cancel-product-001.md) |
| **Assignment Authority** | Human Product Owner / Product Lead |
| **Decision Source / Date** | Human continue-auth 「授权你按照KOS设定继续」 — `2026-09-23T20:19:10+08:00` Asia/Shanghai consume |
| **Non-claims** | Capture alone ≠ Product Gate; not parent Close; Markers AUTH stays Consumed; no Swift under this child; no `RimeRuntimeProvenance` restore |

## Authority

- **Case / contract:** `TC2-CASE-INT-003` / `TC2-CTR-INT-002`.
- **Cadence lessons:** [Cadence-003](../evidence/typo-correction-002-int003-cadence-2026-09-22-003.md) — method only; **not** Live authority reuse.
- **Observability binding:** [Stale-cancel observability audit](../evidence/typo-correction-002-int003-stale-cancel-observability-audit-2026-09-23.md).
- **Gap matrix:** [Cadence-003 → Product gap matrix](../evidence/typo-correction-002-int003-cadence-003-to-product-gap-matrix-2026-09-23.md).
- **Markers:** [Markers impl](../evidence/typo-correction-002-int003-cancel-observability-markers-impl-2026-09-23.md) — tip `c1869cf9…`.
- Does **not** reuse consumed Cadence-003 / Capture-002 / Markers AUTHs as Live authority.

## Environment

| Item | Value |
|---|---|
| Designated Simulator | Device Hub iPhone 17 Pro Max / iOS 27 / `06C5BC3E-7599-4761-A1A2-71DAEA991474` only |
| Arm | App Group **container** prefs (`logging_enabled`, category); high-fidelity window refreshed; dismiss/reopen keyboard |
| Journal | Dynamic `keyboard_extension-<processInstanceID>-…jsonl`; even-index `touch.terminal` starts for cadence math |
| Markers tip | `c1869cf9dda9f1643495e8ebdcfb67acc788b843` — positive `typo_recall.*` codes available |
| Install tip | `80091f35cc5411b292eca78662f39e2b91694045` |

## Scope (Consumed Capture)

1. Long synthetic composition via **visible-key** taps (no `typeText` / pasteboard / host injection / candidate select).
2. Continuous rapid inter-key **starts** &lt;180 ms, then pause ≥180 ms.
3. Observe: no contextual candidate while typing; stale work cancelled (prefer positive `typo_recall.*`); only final unchanged composition receives post-pause lookup.
4. Same-process smoke→rapid binding.
5. Fresh Run evidence; Architecture / Quality / Product Gate need **separate** AUTHs afterward.
6. Post-bump epoch caveat on invalidate-path `debounce_cancelled`.

## Explicit non-goals

QA-001 Product Gate; paired performance; physical substitute; parent Close; Release/TestFlight; Swift/ObjC/RIME; `RimeRuntimeProvenance` restore; reopening Markers AUTH; merge without parent/Human ask.

## Outcome (current)

AUTH **Consumed** under Human continue-auth. Capture install/arm/run authorized on designated Simulator only. Parent Active. Markers AUTH Consumed. No Gate.
