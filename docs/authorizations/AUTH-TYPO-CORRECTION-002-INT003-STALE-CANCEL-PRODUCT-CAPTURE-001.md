# Authorization: AUTH-TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001

## Current Status

| Field | Value |
|---|---|
| **Status** | **Proposed / unconsumed** (not Live; not consumed) |
| **Assignment** | [`TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001`](../assignments/typo-correction-002-int003-stale-cancel-product-capture-001.md) |
| **Parent** | [`TYPO-CORRECTION-002`](../assignments/typo-correction-002.md) (Active) |
| **Decision source** | Docs-only preflight for Human review; Live mark required before capture |
| **Live at** | — (not Live) |
| **Consumed at** | — |

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001",
  "record_type": "authorization",
  "title": "Proposed INT-003 stale-cancel product capture on designated Simulator",
  "status": "proposed",
  "updated_at": "2026-09-23T11:21:00+08:00",
  "authorization": {
    "action": "capture_int003_stale_cancel_product_observation_designated_simulator",
    "target_assignment": "TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001",
    "parent_assignment": "TYPO-CORRECTION-002",
    "consumption_state": "unconsumed",
    "live_gate": "Human must mark this AUTH Live before any Simulator or capture",
    "artifact_bindings": [
      {"kind": "docs_tip", "identity": "4a51228fc8e435d538e9a5f7342ae325502e1e66"},
      {"kind": "case", "identity": "TC2-CASE-INT-003"},
      {"kind": "contract", "identity": "TC2-CTR-INT-002"},
      {"kind": "simulator_designated", "identity": "06C5BC3E-7599-4761-A1A2-71DAEA991474"},
      {"kind": "observability_audit", "identity": "docs/evidence/typo-correction-002-int003-stale-cancel-observability-audit-2026-09-23.md"},
      {"kind": "gap_matrix", "identity": "docs/evidence/typo-correction-002-int003-cadence-003-to-product-gap-matrix-2026-09-23.md"},
      {"kind": "cadence_lesson", "identity": "docs/evidence/typo-correction-002-int003-cadence-2026-09-22-003.md"},
      {"kind": "arm_method", "identity": "App Group container prefs + HF refresh; dynamic JSONL; even-index touch starts"}
    ],
    "allowed_external_effects_when_live": [
      "refresh_App_Group_container_diagnostics_prefs_for_arm",
      "Human_or_visible_key_UI_smoke_long_composition_rapid_taps_then_pause",
      "read_Diagnostics_JSONL_and_write_docs_evidence_under_clean_tip"
    ],
    "exclusions": [
      "execute_while_status_proposed",
      "reuse_of_consumed_CADENCE_003_or_CONTROLLED_CAPTURE_002_as_Live_authority",
      "production_Swift_ObjC_RIME_changes",
      "typeText_pasteboard_host_injection_candidate_select",
      "QA001_Product_Gate",
      "paired_performance",
      "physical_device_as_Product_substitute",
      "parent_Close",
      "Release_TestFlight",
      "RimeRuntimeProvenance_restore",
      "self_declare_Product_Gate_from_capture_alone",
      "commit_push_merge_without_separate_ask"
    ],
    "decision_source": "Preflight Proposed AUTH for Human Live gate; office-hours docs-only until Live"
  }
}
```

## Scope (activates only when status → Live)

- Case `TC2-CASE-INT-003` / contract `TC2-CTR-INT-002`.
- Designated Simulator only for any Product claim path.
- Long synthetic composition; continuous intervals &lt;180 ms; then pause.
- Prove or boundedly observe: no contextual candidate while typing; stale work cancelled; only final unchanged composition gets post-pause lookup.
- Carry Cadence-003 method lessons: container arm + HF; same-process; dynamic JSONL; even-index touch starts.

## Observation / stop rules (from audit)

1. Collect `touch.terminal` cadence, process/appearance binding, HF/JSONL health, Human visual attestations.
2. Cancel/query/epoch journal markers are **expected missing** on tip `4a51228` — absence is **not** a cancel claim.
3. If stimulus, arm, or same-process binding fails → **inconclusive**; new Run ID after fix.
4. If cancel remains unobservable → bounded Human+journal receipt only; Product Gate requires a **separate** AUTH and explicit disposition of the marker gap (docs-only condition vs future implementation AUTH). **Do not implement** markers under this AUTH.

## Explicit non-goals

QA-001 Product Gate; paired performance; physical-as-substitute; parent Close; Release/TestFlight; Swift changes; `RimeRuntimeProvenance` restore; treating Proposed status as Live.

## Consume rules

1. Status remains **Proposed / unconsumed** until Human explicitly marks **Live**.
2. While Proposed: **no** Simulator, arm, capture, Run ID, or ACTIVE_WORK Live claim.
3. When Live: Executor may perform only `allowed_external_effects_when_live`; write one fresh evidence receipt; then mark **consumed** with Run ID + evidence path.
4. Consumption of this AUTH does **not** grant Architecture, Quality, Product Gate, parent Close, implementation, or publication.
5. Do **not** reuse consumed Cadence-003 / Controlled-Capture-002 AUTHs as Live authority for this capture.

## Required Evidence (when Live)

| Artifact | Requirement |
|---|---|
| Preflight binding | Cite tip `4a51228…` + [`observability audit`](../evidence/typo-correction-002-int003-stale-cancel-observability-audit-2026-09-23.md) + [`gap matrix`](../evidence/typo-correction-002-int003-cadence-003-to-product-gap-matrix-2026-09-23.md) |
| Run receipt | New `docs/evidence/…` path with Run ID, UDID, process/appearance IDs, cadence table, Human attestations |
| Cancel observability | Record present/absent journal codes; **absence ≠ cancel claim** |
| Non-claims | Intact: no Product Gate, no parent Close, no Swift, no `RimeRuntimeProvenance` restore |

## Depends on

Human marking this AUTH **Live** before any capture. Until then: Proposed / unconsumed. Parent remains Active.
