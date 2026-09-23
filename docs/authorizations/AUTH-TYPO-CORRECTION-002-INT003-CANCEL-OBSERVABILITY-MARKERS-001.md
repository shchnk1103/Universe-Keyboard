# Authorization: AUTH-TYPO-CORRECTION-002-INT003-CANCEL-OBSERVABILITY-MARKERS-001

## Current Status

| Field | Value |
|---|---|
| **Status** | **Consumed** |
| **Assignment** | [`TYPO-CORRECTION-002-INT003-CANCEL-OBSERVABILITY-MARKERS-001`](../assignments/typo-correction-002-int003-cancel-observability-markers-001.md) |
| **Parent** | [`TYPO-CORRECTION-002`](../assignments/typo-correction-002.md) (Active) |
| **Decision source** | Human authorized continue after Live mark (#151): consume then open Swift implementation PR (DiagnosticEvent / Coordinator; ADR 0027 field-budget first) — 2026-09-23 Asia/Shanghai 「授权按照你的建议继续吧」 |
| **Live at** | `2026-09-23T18:31:00+08:00` |
| **Consumed at** | `2026-09-23T18:47:17+08:00` |
| **Consumer** | Grok Bot iOS开发大师 under Human continue-auth |
| **implementation_tip** | `c1869cf9dda9f1643495e8ebdcfb67acc788b843` (#152 squash-merge onto main) |
| **Branch tip (historical)** | `862014483a4a879e55a159b298184c870d116124` (pre-squash impl branch tip) |

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-TYPO-CORRECTION-002-INT003-CANCEL-OBSERVABILITY-MARKERS-001",
  "record_type": "authorization",
  "title": "Consumed implementation AUTH: INT-003 cancel/debounce/epoch Diagnostics journal markers",
  "status": "consumed",
  "updated_at": "2026-09-23T19:33:31+08:00",
  "revalidation_triggers": [
    "docs_tip_changed_from_implementation_tip",
    "observability_audit_or_gap_matrix_superseded",
    "ADR_0027_field_budget_or_schema_policy_changed",
    "scope_expansion_toward_capture_gate_or_provenance_restore",
    "AUTH_revoked_or_executor_changed",
    "parent_close_or_int003_product_gate_granted_elsewhere",
    "180_ms_product_budget_or_eligibility_rules_changed_without_emit_necessity"
  ],
  "authorization": {
    "action": "implement_int003_cancel_observability_journal_markers",
    "target_assignment": "TYPO-CORRECTION-002-INT003-CANCEL-OBSERVABILITY-MARKERS-001",
    "parent_assignment": "TYPO-CORRECTION-002",
    "consumption_state": "consumed",
    "live_at": "2026-09-23T18:31:00+08:00",
    "consumed_at": "2026-09-23T18:47:17+08:00",
    "consumer": "Grok Bot iOS开发大师 under Human continue-auth",
    "consumed_artifacts": [
      {"kind": "baseline_tip", "identity": "9b8b7a73f4d373adbd7ee436d318cde3d9bc4c78"},
      {"kind": "field_budget_evidence", "identity": "docs/evidence/typo-correction-002-int003-cancel-observability-markers-field-budget-2026-09-23.md"},
      {"kind": "implementation_evidence", "identity": "docs/evidence/typo-correction-002-int003-cancel-observability-markers-impl-2026-09-23.md"},
      {"kind": "codes", "identity": "typo_recall.debounce_scheduled,typo_recall.debounce_cancelled,typo_recall.epoch_bumped,typo_recall.fence_discarded,typo_recall.query_begin,typo_recall.query_outcome"},
      {"kind": "count_metrics", "identity": "recall_epoch,composition_revision,operation_ordinal,composition_length,composition_fingerprint"},
      {"kind": "reasons", "identity": "typo_recall_query_succeeded,typo_recall_query_discarded,typo_recall_query_cancelled"},
      {"kind": "flags_added", "identity": "none"},
      {"kind": "schema_version", "identity": "DiagnosticEvent.schemaVersion 3->4"},
      {"kind": "implementation_tip", "identity": "c1869cf9dda9f1643495e8ebdcfb67acc788b843"},
      {"kind": "squash_merge_pr", "identity": "152"},
      {"kind": "branch_implementation_tip_historical", "identity": "862014483a4a879e55a159b298184c870d116124"}
    ],
    "artifact_bindings": [
      {"kind": "docs_tip_live_mark", "identity": "9b8b7a73f4d373adbd7ee436d318cde3d9bc4c78"},
      {"kind": "docs_tip_proposed_historical", "identity": "d74462ed26ec4c09cac35386ed71ec99b212aebc"},
      {"kind": "case", "identity": "TC2-CASE-INT-003"},
      {"kind": "contract", "identity": "TC2-CTR-INT-002"},
      {"kind": "observability_audit", "identity": "docs/evidence/typo-correction-002-int003-stale-cancel-observability-audit-2026-09-23.md"},
      {"kind": "audit_option_chosen", "identity": "Option_B_implementation_AUTH_for_controlled_journal_markers"},
      {"kind": "gap_matrix", "identity": "docs/evidence/typo-correction-002-int003-cadence-003-to-product-gap-matrix-2026-09-23.md"},
      {"kind": "related_capture_assignment_non_authorizing", "identity": "TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001"},
      {"kind": "related_capture_auth_non_authorizing", "identity": "AUTH-TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001"},
      {"kind": "adr", "identity": "docs/architecture/decisions/0027-enterprise-local-diagnostic-observability.md"},
      {"kind": "field_budget_evidence", "identity": "docs/evidence/typo-correction-002-int003-cancel-observability-markers-field-budget-2026-09-23.md"}
    ],
    "allowed_external_effects_when_live": [
      "emit_controlled_DiagnosticEvent_codes_flags_for_typo_recall_debounce_cancel_epoch_fence_query_observability",
      "edit_TypoCorrectionRecallCoordinator_swift_emit_points",
      "edit_DiagnosticEvent_swift_Code_Flag_schema_under_ADR_0027_field_budget_review",
      "thin_call_sites_in_KeyboardViewController_TypoCorrection_or_Presentation_only_if_emit_must_live_there",
      "add_focused_unit_or_contract_tests_for_emit_and_non_regression",
      "write_docs_evidence_for_implementation_tip_under_clean_tip",
      "local_commit_push_open_PR_of_in_scope_implementation_under_Human_continue_auth"
    ],
    "exclusions": [
      "reuse_of_consumed_CADENCE_003_or_CONTROLLED_CAPTURE_002_or_STALE_CANCEL_CAPTURE_as_Live_Swift_authority",
      "RimeRuntimeProvenance_restore",
      "capture_under_this_AUTH",
      "mark_Capture_AUTH_Live",
      "Product_Gate",
      "QA001_Product_Gate",
      "parent_Close",
      "Release_TestFlight",
      "change_180ms_product_budget_or_eligibility_unless_required_for_emit_correctness",
      "merge_PR_without_separate_ask",
      "self_declare_cancel_proof_or_Product_Gate_from_markers_alone"
    ],
    "decision_source": "Human continue-auth after Live #151: consume AUTH then open Swift implementation PR; consumed_at 2026-09-23T18:47:17+08:00"
  }
}
```

## Scope (consumed; markers landed; #152 squash-merged on main)

- Case `TC2-CASE-INT-003` / contract `TC2-CTR-INT-002`.
- Add **minimal controlled Diagnostics journal markers** so a future Live product capture can **prove** cancel / stale discard (positive observations), not infer from absence.
- Default: **observe only** — do not change 180 ms product budget or eligibility rules unless emit correctness requires it (document if so).
- ADR 0027 field-budget / privacy allowlist review **completed** before landing new Codes/CountMetrics/Reasons — see [`field-budget evidence`](../evidence/typo-correction-002-int003-cancel-observability-markers-field-budget-2026-09-23.md).

### Accepted event codes / observations (field-budget locked)

| Observation intent | Code |
|---|---|
| Debounce / recall **scheduled** (or rescheduled) | `typo_recall.debounce_scheduled` |
| Debounce / pending work-item **cancelled** (re-schedule; primary rapid &lt;180 path) | `typo_recall.debounce_cancelled` |
| **`recallEpoch` bump** / hard **invalidate** | `typo_recall.epoch_bumped` |
| Fence / yielded-token **discard** (stale in-flight) | `typo_recall.fence_discarded` |
| Contextual **query begin** / **outcome** | `typo_recall.query_begin` / `typo_recall.query_outcome` |

### Bindings / fields (field-budget locked)

- CountMetrics: `recall_epoch`, `composition_revision`, `operation_ordinal`, `composition_length`, `composition_fingerprint` (FNV-1a 32-bit; **no** composition text)
- Query outcome Reasons: `typo_recall_query_succeeded` / `typo_recall_query_discarded` / `typo_recall_query_cancelled`
- Correlation via existing journal `processInstanceID` / `appearanceID`; HF gate required
- `DiagnosticEvent.schemaVersion` 3 → 4

### Touch zones when implementing

- `Keyboard/Controllers/TypoCorrectionRecallCoordinator.swift`
- `Packages/KeyboardCore/.../DiagnosticEvent.swift`
- `Packages/KeyboardCore/.../TypoCorrectionRecallDiagnosticMarkers.swift` (pure field builder + fingerprint)
- Focused unit/contract tests; docs evidence for implementation tip

## Related records (non-authorizing for Capture / Gate)

- Capture Assignment/AUTH remain **Proposed** — consumption does **not** mark them Live and does **not** authorize capture.
- Consumed Cadence-003 / Capture-002 AUTHs must **not** be reused as Live Swift authority beyond this markers scope.

## Explicit non-goals

Product Gate; parent Close; Release/TestFlight; Capture under this AUTH; `RimeRuntimeProvenance` restore; merging the implementation PR without separate ask; changing product 180 ms / eligibility by default; claiming cancel proof from markers landing alone.

## Consume rules (satisfied)

1. Status was **Live / unconsumed** after #151; Human continue-auth authorized consume + implementation PR.
2. **Consume docs + ADR 0027 field-budget** recorded **before** first Swift change on this branch.
3. Perform only allowed effects; write implementation tip evidence; record `implementation_tip` SHA when markers land.
4. Consumption does **not** grant Capture Live, Architecture/Quality Gate, Product Gate, parent Close, or merge.
5. Do **not** reuse consumed Cadence-003 / Controlled-Capture-002 / stale-cancel Capture AUTHs as Live authority for out-of-scope Swift.

## Required Evidence

| Artifact | Requirement |
|---|---|
| Proposed binding (historical; #150) | Tip `d74462ed26ec4c09cac35386ed71ec99b212aebc` |
| Live-at tip binding | Tip `9b8b7a73f4d373adbd7ee436d318cde3d9bc4c78` (#151); Live at `2026-09-23T18:31:00+08:00` |
| Field-budget (now) | [`…-field-budget-2026-09-23.md`](../evidence/typo-correction-002-int003-cancel-observability-markers-field-budget-2026-09-23.md) |
| Live implementation (merged #152) | Squash tip `c1869cf9dda9f1643495e8ebdcfb67acc788b843`; historical branch tip `862014483a4a879e55a159b298184c870d116124`; Codes/CountMetrics/Reasons list; focused test summary; no PII dump |
| Non-claims | Intact: no Capture Live, no Product Gate, no parent Close, no `RimeRuntimeProvenance` restore, no cancel proof claim from markers alone |

## Depends on / Outcome

AUTH is **Consumed** at `2026-09-23T18:47:17+08:00` (status remains **Consumed** — not re-Live). Swift markers landed; Human squash-merged [#152](https://github.com/shchnk1103/Universe-Keyboard/pull/152) to main as `implementation_tip` / squash tip `c1869cf9dda9f1643495e8ebdcfb67acc788b843` (`2026-09-23T11:21:28Z` / `2026-09-23 19:21:28 CST`). Parent remains Active. Capture AUTH stays **Proposed** and untouched. This AUTH does **not** authorize Capture Live, Product Gate, parent Close, or further merges.
