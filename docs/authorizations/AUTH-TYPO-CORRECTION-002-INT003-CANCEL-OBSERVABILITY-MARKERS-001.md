# Authorization: AUTH-TYPO-CORRECTION-002-INT003-CANCEL-OBSERVABILITY-MARKERS-001

## Current Status

| Field | Value |
|---|---|
| **Status** | **Live / unconsumed** (not consumed) |
| **Assignment** | [`TYPO-CORRECTION-002-INT003-CANCEL-OBSERVABILITY-MARKERS-001`](../assignments/typo-correction-002-int003-cancel-observability-markers-001.md) |
| **Parent** | [`TYPO-CORRECTION-002`](../assignments/typo-correction-002.md) (Active) |
| **Decision source** | Human authorized squash-merge #150 then mark this AUTH Live (2026-09-23 Asia/Shanghai); originally Option B (controlled journal markers) for INT-003 hard-evidence path |
| **Live at** | `2026-09-23T18:31:00+08:00` |
| **Consumed at** | — |

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-TYPO-CORRECTION-002-INT003-CANCEL-OBSERVABILITY-MARKERS-001",
  "record_type": "authorization",
  "title": "Live implementation AUTH: INT-003 cancel/debounce/epoch Diagnostics journal markers",
  "status": "live",
  "updated_at": "2026-09-23T18:31:00+08:00",
  "revalidation_triggers": [
    "docs_tip_changed_from_d74462e",
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
    "consumption_state": "unconsumed",
    "live_at": "2026-09-23T18:31:00+08:00",
    "live_gate": "Human already marked this AUTH Live after #150 squash-merge; remaining gate = consume before first Swift/ObjC/DiagnosticEvent schema change",
    "artifact_bindings": [
      {"kind": "docs_tip", "identity": "d74462ed26ec4c09cac35386ed71ec99b212aebc"},
      {"kind": "docs_tip_proposed_historical", "identity": "bf2b4c58562fbe44d61ff3938509cda8c69e2705"},
      {"kind": "case", "identity": "TC2-CASE-INT-003"},
      {"kind": "contract", "identity": "TC2-CTR-INT-002"},
      {"kind": "observability_audit", "identity": "docs/evidence/typo-correction-002-int003-stale-cancel-observability-audit-2026-09-23.md"},
      {"kind": "audit_option_chosen", "identity": "Option_B_implementation_AUTH_for_controlled_journal_markers"},
      {"kind": "gap_matrix", "identity": "docs/evidence/typo-correction-002-int003-cadence-003-to-product-gap-matrix-2026-09-23.md"},
      {"kind": "related_capture_assignment_non_authorizing", "identity": "TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001"},
      {"kind": "related_capture_auth_non_authorizing", "identity": "AUTH-TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001"},
      {"kind": "adr", "identity": "docs/architecture/decisions/0027-enterprise-local-diagnostic-observability.md"}
    ],
    "allowed_external_effects_when_live": [
      "emit_controlled_DiagnosticEvent_codes_flags_for_typo_recall_debounce_cancel_epoch_fence_query_observability",
      "edit_TypoCorrectionRecallCoordinator_swift_emit_points",
      "edit_DiagnosticEvent_swift_Code_Flag_schema_under_ADR_0027_field_budget_review",
      "thin_call_sites_in_KeyboardViewController_TypoCorrection_or_Presentation_only_if_emit_must_live_there",
      "add_focused_unit_or_contract_tests_for_emit_and_non_regression",
      "write_docs_evidence_for_implementation_tip_under_clean_tip",
      "local_commit_of_in_scope_implementation_and_tests_when_separately_asked"
    ],
    "exclusions": [
      "execute_while_status_proposed",
      "reuse_of_consumed_CADENCE_003_or_CONTROLLED_CAPTURE_002_or_STALE_CANCEL_CAPTURE_as_Live_Swift_authority",
      "RimeRuntimeProvenance_restore",
      "capture_under_this_AUTH",
      "mark_Capture_AUTH_Live",
      "Product_Gate",
      "QA001_Product_Gate",
      "parent_Close",
      "Release_TestFlight",
      "change_180ms_product_budget_or_eligibility_unless_required_for_emit_correctness",
      "ACTIVE_WORK_Live_implication_from_Proposed_docs",
      "push_PR_merge_without_separate_ask",
      "self_declare_cancel_proof_or_Product_Gate_from_markers_alone"
    ],
    "decision_source": "Human authorized squash-merge #150 then mark this AUTH Live (2026-09-23 Asia/Shanghai); still unconsumed until consume before first Swift"
  }
}
```

## Scope (activates when status → Live — now Live / unconsumed)

- Case `TC2-CASE-INT-003` / contract `TC2-CTR-INT-002`.
- Add **minimal controlled Diagnostics journal markers** so a future Live product capture can **prove** cancel / stale discard (positive observations), not infer from absence.
- Default: **observe only** — do not change 180 ms product budget or eligibility rules unless emit correctness requires it (document if so).
- ADR 0027 field-budget / privacy allowlist review **required** before landing new Codes/Flags.

### Suggested event codes / observations (name explicitly; refine under ADR 0027 when implementing)

| Observation intent | Suggested name (non-binding until Live field review) |
|---|---|
| Debounce / recall **scheduled** (or rescheduled) | `typo_recall.debounce_scheduled` |
| Debounce / pending work-item **cancelled** (re-schedule; primary rapid &lt;180 path) | `typo_recall.debounce_cancelled` |
| **`recallEpoch` bump** / hard **invalidate** | `typo_recall.epoch_bumped` / `typo_recall.invalidated` |
| Fence / yielded-token **discard** (stale in-flight) | `typo_recall.fence_discarded` |
| Contextual **query begin** / **end or outcome** (success / discarded / cancelled) | `typo_recall.query_begin` / `typo_recall.query_outcome` — only if feasible **without** provenance restore |

### Bindings / fields (design intent when implementing)

- `recallEpoch` (or equivalent)
- Composition fingerprint / fence snapshot identity (**bounded**; no PII dump)
- Correlation with existing journal process/appearance IDs
- Keep HF / schema version discipline

### Touch zones when implementing (consume AUTH first)

- `Keyboard/Controllers/TypoCorrectionRecallCoordinator.swift`
- `Packages/KeyboardCore/.../DiagnosticEvent.swift`
- Possibly thin call sites in `KeyboardViewController+TypoCorrection` / presentation if emit must live there
- Focused unit/contract tests; docs evidence for implementation tip

## Related records (non-authorizing for Swift / Capture)

- Audit + gap matrix: evidence only; do not authorize Live Swift by themselves.
- Capture Assignment/AUTH remain **Proposed** — this AUTH does **not** mark them Live and does **not** authorize capture.
- Consumed Cadence-003 / Capture-002 AUTHs must **not** be reused as Live Swift authority.

## Explicit non-goals

Product Gate; parent Close; Release/TestFlight; Capture under this AUTH; `RimeRuntimeProvenance` restore; treating unconsumed Live as already-consumed Swift authority; changing product 180 ms / eligibility by default; claiming cancel proof from markers landing alone.

## Consume rules

1. Status is now **Live / unconsumed**. Human already marked Live after #150 squash-merge tip `d74462e…`.
2. Still **no** Swift / ObjC / RIME / `DiagnosticEvent` schema edits until this AUTH is **consumed**; no Capture; no ACTIVE_WORK Live claim from this AUTH alone beyond the Live mark itself.
3. **Consume before the first Swift change**; perform only `allowed_external_effects_when_live`; complete ADR 0027 field-budget review before new Codes/Flags; write implementation tip evidence; then record consumption with tip + evidence path.
4. Consumption of this AUTH does **not** grant Capture Live, Architecture/Quality Gate, Product Gate, parent Close, publication, push, PR, or merge.
5. Do **not** reuse consumed Cadence-003 / Controlled-Capture-002 / stale-cancel Capture AUTHs as Live authority for Swift under this AUTH.

## Required Evidence

| Artifact | Requirement |
|---|---|
| Proposed binding (historical; landed via #150) | Tip `bf2b4c58562fbe44d61ff3938509cda8c69e2705` + audit Option B citation + gap matrix + Capture records cited as non-authorizing — Proposed package merged as tip `d74462ed26ec4c09cac35386ed71ec99b212aebc` (#150) |
| Live-at tip binding (now) | Tip `d74462ed26ec4c09cac35386ed71ec99b212aebc` (#150 merge); Live at `2026-09-23T18:31:00+08:00`; consumption_state still unconsumed |
| Live implementation (future, after consume) | Tip SHA of marker landing; ADR 0027 field-review note; list of Codes/Flags added; focused test summary; bounded composition fingerprint design (no PII dump) |
| Integrity if docs-only evidence | **N/A** for external Run/JSONL capture SHA when no Simulator capture was produced under this AUTH |
| Non-claims | Intact: no Capture Live, no Product Gate, no parent Close, no `RimeRuntimeProvenance` restore, no cancel proof claim from Live-unconsumed docs alone |

## Depends on / Outcome

AUTH is **Live / unconsumed**. Still no Swift until consume. Parent remains Active. Capture AUTH stays Proposed and separate.
