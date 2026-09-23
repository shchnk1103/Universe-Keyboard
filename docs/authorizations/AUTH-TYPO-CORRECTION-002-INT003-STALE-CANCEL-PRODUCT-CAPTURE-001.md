# Authorization: AUTH-TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001

## Current Status

| Field | Value |
|---|---|
| **Status** | **Consumed** — Capture running / evidence finalize on designated Simulator under Human continue-auth |
| **Assignment** | [`TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001`](../assignments/typo-correction-002-int003-stale-cancel-product-capture-001.md) |
| **Parent** | [`TYPO-CORRECTION-002`](../assignments/typo-correction-002.md) (Active — do **not** Close) |
| **Consumer** | Grok Bot iOS开发大师 under Human continue-auth (KOS) |
| **Decision source** | Human: 「授权你按照KOS设定继续」 (2026-09-23 Asia/Shanghai) after Grok recommended consume Capture AUTH + run INT-003 Product Capture (HF-armed) on tip with markers — treated as separate Human ask to consume + run Capture |
| **Live at** | `2026-09-23T19:39:00+08:00` |
| **Consumed at** | `2026-09-23T20:19:10+08:00` |
| **Run ID (planned / bound)** | `TC2-SIM-20260923-201910-INT003-STALE-CANCEL-PRODUCT-001` |
| **Evidence path (planned / bound)** | [`docs/evidence/typo-correction-002-sim-run-2026-09-23-int003-stale-cancel-product-001.md`](../evidence/typo-correction-002-sim-run-2026-09-23-int003-stale-cancel-product-001.md) |

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001",
  "record_type": "authorization",
  "title": "Consumed INT-003 stale-cancel product capture on designated Simulator",
  "status": "consumed",
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
  "authorization": {
    "action": "capture_int003_stale_cancel_product_observation_designated_simulator",
    "target_assignment": "TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001",
    "parent_assignment": "TYPO-CORRECTION-002",
    "consumption_state": "consumed",
    "live_at": "2026-09-23T19:39:00+08:00",
    "consumed_at": "2026-09-23T20:19:10+08:00",
    "consumer": "Grok Bot iOS开发大师 under Human continue-auth (KOS)",
    "live_gate": "Human marked Live; then separate Human continue-auth consumed this AUTH before first Simulator/arm/capture",
    "artifact_bindings": [
      {"kind": "capture_install_tip", "identity": "80091f35cc5411b292eca78662f39e2b91694045"},
      {"kind": "live_main_tip_historical", "identity": "68223f2482125557d328ff19650d16305bd14434"},
      {"kind": "docs_tip_proposed_historical", "identity": "4a51228fc8e435d538e9a5f7342ae325502e1e66"},
      {"kind": "markers_impl_tip", "identity": "c1869cf9dda9f1643495e8ebdcfb67acc788b843"},
      {"kind": "markers_auth_consumed", "identity": "AUTH-TYPO-CORRECTION-002-INT003-CANCEL-OBSERVABILITY-MARKERS-001"},
      {"kind": "case", "identity": "TC2-CASE-INT-003"},
      {"kind": "contract", "identity": "TC2-CTR-INT-002"},
      {"kind": "simulator_designated", "identity": "06C5BC3E-7599-4761-A1A2-71DAEA991474"},
      {"kind": "run", "identity": "TC2-SIM-20260923-201910-INT003-STALE-CANCEL-PRODUCT-001"},
      {"kind": "evidence", "identity": "docs/evidence/typo-correction-002-sim-run-2026-09-23-int003-stale-cancel-product-001.md"},
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
    "decision_source": "Human continue-auth 「授权你按照KOS设定继续」 (2026-09-23 Asia/Shanghai) — separate ask to consume + run Capture",
    "consumed_artifacts": [
      "Run TC2-SIM-20260923-201910-INT003-STALE-CANCEL-PRODUCT-001 (planned at consume; finalized in evidence)",
      "capture_install_tip 80091f35cc5411b292eca78662f39e2b91694045 (includes markers_impl c1869cf9…)",
      "evidence docs/evidence/typo-correction-002-sim-run-2026-09-23-int003-stale-cancel-product-001.md"
    ]
  }
}
```

## Scope (Consumed — Capture under this AUTH only)

- Case `TC2-CASE-INT-003` / contract `TC2-CTR-INT-002`.
- Designated Simulator only for any Product claim path: `06C5BC3E-7599-4761-A1A2-71DAEA991474`.
- Long synthetic composition; continuous intervals &lt;180 ms; then pause.
- Prove or boundedly observe: no contextual candidate while typing; stale work cancelled; only final unchanged composition gets post-pause lookup.
- Carry Cadence-003 method lessons: container arm + HF; same-process; dynamic JSONL; even-index touch starts.
- **Markers on install tip** (markers_impl `c1869cf9dda9f1643495e8ebdcfb67acc788b843` via #152; capture install tip `80091f35…` descendant of Live main `68223f24…`). Prefer positive `typo_recall.*` cancel/debounce/epoch evidence — still does **not** self-declare Product Gate from Capture alone.
- Cadence-003 Architecture **Pass-with-conditions** + Quality **Bounded Pass** are prior residual context only; they do **not** authorize Product Gate.
- **Capture correlators must respect the post-bump epoch caveat:** on `invalidateTypoCorrectionRecall`, `epoch_bumped` is recorded **after** the epoch increment, and any paired `debounce_cancelled` carries the **post-bump** `recall_epoch` (not the cancelled work’s pre-bump epoch).

## Observation / stop rules

1. Collect `touch.terminal` cadence, process/appearance binding, HF/JSONL health, Human visual attestations (or explicit pending/absent).
2. Prefer positive `typo_recall.*` observations; absence is recorded honestly — not automatic cancel claim.
3. On invalidate: `epoch_bumped` then optional `debounce_cancelled` share **post-bump** epoch.
4. If stimulus, arm, or same-process binding fails → **inconclusive**; new Run ID after fix.
5. Product Gate still requires a **separate** AUTH. No production Swift/ObjC/RIME under this AUTH. Markers AUTH stays **Consumed**.

## Explicit non-goals

QA-001 Product Gate; paired performance; physical-as-substitute; parent Close; Release/TestFlight; Swift changes; `RimeRuntimeProvenance` restore; reopening Consumed markers AUTH; squash-merge without parent/Human merge ask.

## Consume rules (satisfied)

1. Status was **Live / unconsumed** at Live-at `2026-09-23T19:39:00+08:00`.
2. Separate Human ask to consume + run received (continue-auth 2026-09-23).
3. Consumed **before** first Simulator/arm/capture under this AUTH (`consumed_at` `2026-09-23T20:19:10+08:00`).
4. Consumption does **not** grant Architecture, Quality, Product Gate, parent Close, implementation, or publication.
5. Do **not** reuse consumed Cadence-003 / Controlled-Capture-002 / Markers AUTHs as Live authority.

## Required Evidence

| Artifact | Requirement |
|---|---|
| Live-at tip binding (historical) | Tip markers `c1869cf9…`; Live main mark tip `68223f24…`; Live at `2026-09-23T19:39:00+08:00` |
| Capture install tip (now) | `80091f35cc5411b292eca78662f39e2b91694045` (includes markers) |
| Markers context | Markers AUTH **Consumed**; post-bump epoch caveat intact |
| Live capture | Run `TC2-SIM-20260923-201910-INT003-STALE-CANCEL-PRODUCT-001` + evidence path above |
| Non-claims | No Product Gate; no parent Close; no Swift; no `RimeRuntimeProvenance` restore; Capture alone ≠ Gate |

## Depends on / Outcome

AUTH is **Consumed**. Capture may proceed on designated Simulator under this AUTH only. Parent remains Active. Markers AUTH stays **Consumed**. No Gate until separate Gate AUTH.
