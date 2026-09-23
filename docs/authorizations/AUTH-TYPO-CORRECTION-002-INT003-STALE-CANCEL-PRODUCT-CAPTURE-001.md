# Authorization: AUTH-TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001

## Current Status

| Field | Value |
|---|---|
| **Status** | **Live / unconsumed** (not consumed) |
| **Assignment** | [`TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001`](../assignments/typo-correction-002-int003-stale-cancel-product-capture-001.md) |
| **Parent** | [`TYPO-CORRECTION-002`](../assignments/typo-correction-002.md) (Active) |
| **Decision source** | Human authorized docs-only Live mark for INT-003 Capture AUTH (2026-09-23 Asia/Shanghai); still do not auto-run Capture; markers already on main tip `c1869cf9…` (#152); Markers AUTH remains **Consumed** |
| **Live at** | `2026-09-23T19:39:00+08:00` |
| **Consumed at** | — |

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001",
  "record_type": "authorization",
  "title": "Live INT-003 stale-cancel product capture on designated Simulator (unconsumed)",
  "status": "live",
  "updated_at": "2026-09-23T19:39:00+08:00",
  "revalidation_triggers": [
    "docs_tip_changed_from_c1869cf",
    "observability_audit_or_gap_matrix_superseded",
    "designated_simulator_or_arm_method_changed",
    "scope_expansion_toward_implementation_or_gates",
    "AUTH_revoked_or_executor_changed",
    "parent_close_or_int003_product_gate_granted_elsewhere",
    "markers_schema_or_emit_contract_changed_without_rebind"
  ],
  "authorization": {
    "action": "capture_int003_stale_cancel_product_observation_designated_simulator",
    "target_assignment": "TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001",
    "parent_assignment": "TYPO-CORRECTION-002",
    "consumption_state": "unconsumed",
    "live_at": "2026-09-23T19:39:00+08:00",
    "live_gate": "Human already marked this AUTH Live; remaining gate = consume before first Simulator/arm/capture under this AUTH; do not auto-run Capture from Live alone",
    "artifact_bindings": [
      {"kind": "docs_tip", "identity": "c1869cf9dda9f1643495e8ebdcfb67acc788b843"},
      {"kind": "docs_tip_proposed_historical", "identity": "4a51228fc8e435d538e9a5f7342ae325502e1e66"},
      {"kind": "markers_impl_tip", "identity": "c1869cf9dda9f1643495e8ebdcfb67acc788b843"},
      {"kind": "markers_auth_consumed", "identity": "AUTH-TYPO-CORRECTION-002-INT003-CANCEL-OBSERVABILITY-MARKERS-001"},
      {"kind": "case", "identity": "TC2-CASE-INT-003"},
      {"kind": "contract", "identity": "TC2-CTR-INT-002"},
      {"kind": "simulator_designated", "identity": "06C5BC3E-7599-4761-A1A2-71DAEA991474"},
      {"kind": "observability_audit", "identity": "docs/evidence/typo-correction-002-int003-stale-cancel-observability-audit-2026-09-23.md"},
      {"kind": "gap_matrix", "identity": "docs/evidence/typo-correction-002-int003-cadence-003-to-product-gap-matrix-2026-09-23.md"},
      {"kind": "cadence_lesson", "identity": "docs/evidence/typo-correction-002-int003-cadence-2026-09-22-003.md"},
      {"kind": "cadence_arch_pass_with_conditions", "identity": "docs/reviews/typo-correction-002-int003-cadence-2026-09-22-003-architecture-review.md"},
      {"kind": "cadence_quality_bounded_pass", "identity": "docs/reviews/typo-correction-002-int003-cadence-2026-09-22-003-quality-review.md"},
      {"kind": "arm_method", "identity": "App Group container prefs + HF refresh; dynamic JSONL; even-index touch starts"},
      {"kind": "markers_impl_evidence", "identity": "docs/evidence/typo-correction-002-int003-cancel-observability-markers-impl-2026-09-23.md"}
    ],
    "allowed_external_effects_when_live": [
      "refresh_App_Group_container_diagnostics_prefs_for_arm",
      "Human_or_visible_key_UI_smoke_long_composition_rapid_taps_then_pause",
      "read_Diagnostics_JSONL_and_write_docs_evidence_under_clean_tip"
    ],
    "exclusions": [
      "execute_while_status_proposed",
      "auto_run_Capture_from_Live_unconsumed_alone",
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
      "commit_push_merge_without_separate_ask",
      "reopen_or_alter_Consumed_markers_AUTH"
    ],
    "decision_source": "Human authorized docs-only Live mark (2026-09-23 Asia/Shanghai); still unconsumed; Capture run requires separate Human ask after consume"
  }
}
```

## Scope (activates when status → Live — now Live / unconsumed)

- Case `TC2-CASE-INT-003` / contract `TC2-CTR-INT-002`.
- Designated Simulator only for any Product claim path.
- Long synthetic composition; continuous intervals &lt;180 ms; then pause.
- Prove or boundedly observe: no contextual candidate while typing; stale work cancelled; only final unchanged composition gets post-pause lookup.
- Carry Cadence-003 method lessons: container arm + HF; same-process; dynamic JSONL; even-index touch starts.
- **Markers already on main** tip `c1869cf9dda9f1643495e8ebdcfb67acc788b843` (#152). When later consumed and run, Capture **may collect positive** `typo_recall.*` cancel/debounce/epoch evidence (`debounce_scheduled`, `debounce_cancelled`, `epoch_bumped`, `fence_discarded`, `query_begin`, `query_outcome`) — still does **not** self-declare Product Gate from Capture alone.
- Cadence-003 Architecture **Pass-with-conditions** + Quality **Bounded Pass** noted as prior residual context ([Arch](../reviews/typo-correction-002-int003-cadence-2026-09-22-003-architecture-review.md), [Quality](../reviews/typo-correction-002-int003-cadence-2026-09-22-003-quality-review.md)); they do **not** authorize this Capture run or Product Gate.
- **Capture correlators must respect the post-bump epoch caveat:** on `invalidateTypoCorrectionRecall`, `epoch_bumped` is recorded **after** the epoch increment, and any paired `debounce_cancelled` carries the **post-bump** `recall_epoch` (not the cancelled work’s pre-bump epoch). Do not mis-bind invalidate-path `debounce_cancelled` to the prior epoch.

## Observation / stop rules (from audit + markers tip)

1. Collect `touch.terminal` cadence, process/appearance binding, HF/JSONL health, Human visual attestations.
2. Cancel/query/epoch journal markers are **present on tip `c1869cf9…`** (markers AUTH Consumed; impl via #152). Prefer positive `typo_recall.*` observations; absence on a Live Capture run is still **not** automatically a cancel claim — record present/absent honestly.
3. When correlating invalidate paths: `epoch_bumped` then optional `debounce_cancelled` share the **post-bump** epoch — see caveat above.
4. If stimulus, arm, or same-process binding fails → **inconclusive**; new Run ID after fix.
5. Product Gate still requires a **separate** AUTH and explicit disposition. **Do not** invent new Capture procedures beyond this AUTH’s existing Live-when-consumed scope. **Do not** authorize Swift beyond what this Capture AUTH already allows (no production Swift/ObjC/RIME).

## Explicit non-goals

QA-001 Product Gate; paired performance; physical-as-substitute; parent Close; Release/TestFlight; Swift changes; `RimeRuntimeProvenance` restore; treating unconsumed Live as already-consumed Capture authority; auto-running Capture from Live alone; reopening Consumed markers AUTH.

## Consume rules

1. Status is now **Live / unconsumed**. Human already marked Live at `2026-09-23T19:39:00+08:00` with tip binding `c1869cf9…`.
2. Still **no** Simulator, arm, capture, Run ID, or ACTIVE_WORK Capture-running claim until this AUTH is **consumed**; Live alone does **not** auto-run Capture.
3. When consuming: Executor may perform only `allowed_external_effects_when_live`; write one fresh evidence receipt; then mark **consumed** with Run ID + evidence path. Consume requires a **separate Human ask** before any Capture run.
4. Consumption of this AUTH does **not** grant Architecture, Quality, Product Gate, parent Close, implementation, or publication.
5. Do **not** reuse consumed Cadence-003 / Controlled-Capture-002 / Markers AUTHs as Live authority for this capture (Markers AUTH stays **Consumed**; its landing enables observation only).

## Required Evidence

| Artifact | Requirement |
|---|---|
| Proposed binding (historical; via #149) | Tip `4a51228fc8e435d538e9a5f7342ae325502e1e66` + [`observability audit`](../evidence/typo-correction-002-int003-stale-cancel-observability-audit-2026-09-23.md) + [`gap matrix`](../evidence/typo-correction-002-int003-cadence-003-to-product-gap-matrix-2026-09-23.md) — Proposed package landed via #149 |
| Live-at tip binding (now) | Tip `c1869cf9dda9f1643495e8ebdcfb67acc788b843` (#152 markers on main); Live at `2026-09-23T19:39:00+08:00`; `consumption_state` still unconsumed |
| Markers context | [`markers impl evidence`](../evidence/typo-correction-002-int003-cancel-observability-markers-impl-2026-09-23.md); Markers AUTH **Consumed**; post-bump epoch caveat on invalidate `debounce_cancelled` |
| Cadence residual context | Architecture Pass-with-conditions + Quality Bounded Pass on Cadence-003 — **not** Capture Live authority |
| Live capture (future, after consume) | New `docs/evidence/…` path with Run ID, UDID, process/appearance IDs, cadence table, Human attestations, present/absent `typo_recall.*` codes |
| Non-claims | Intact: no Capture run yet, no Product Gate, no parent Close, no Swift, no `RimeRuntimeProvenance` restore |

## Depends on / Outcome

AUTH is **Live / unconsumed**. Still no Capture until consume + separate Human ask to run. Parent remains Active. Markers AUTH stays **Consumed**. No Gate.
