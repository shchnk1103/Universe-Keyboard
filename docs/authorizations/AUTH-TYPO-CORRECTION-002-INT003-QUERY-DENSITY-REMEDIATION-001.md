# Authorization: AUTH-TYPO-CORRECTION-002-INT003-QUERY-DENSITY-REMEDIATION-001

## Current Status

| Field | Value |
|---|---|
| **Status** | **Proposed / unconsumed** (not Live; not consumed) |
| **Assignment** | [`TYPO-CORRECTION-002-INT003-QUERY-DENSITY-REMEDIATION-001`](../assignments/typo-correction-002-int003-query-density-remediation-001.md) |
| **Parent** | [`TYPO-CORRECTION-002`](../assignments/typo-correction-002.md) (Active) |
| **Decision source** | Human after #161: merge Capture Product residual, then open narrow-scope `query_*` remediation Proposed AUTH — `2026-09-23 Asia/Shanghai` 「可以，那就先 merge #161，然后窄 scope 的 query_* remediation Proposed AUTH」 |
| **Live at** | — (not Live) |
| **Consumed at** | — |
| **Designated tip** | `65a0a11d197616928c66f3c148193982c9935945` (main after #161) |

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-TYPO-CORRECTION-002-INT003-QUERY-DENSITY-REMEDIATION-001",
  "record_type": "authorization",
  "title": "Proposed remediation: narrow typo_recall.query_begin / query_outcome density (diagnose-first)",
  "status": "proposed",
  "updated_at": "2026-09-23T21:49:00+08:00",
  "revalidation_triggers": [
    "docs_tip_changed_from_65a0a11",
    "capture_package_or_evidence_sha_superseded",
    "scope_expansion_to_fence_or_gate_or_provenance",
    "AUTH_revoked_or_executor_changed",
    "parent_close_or_int003_product_gate_granted_elsewhere",
    "180_ms_product_budget_changed_without_emit_necessity",
    "markers_auth_reopened_or_schema_contract_changed_without_rebind"
  ],
  "authorization": {
    "action": "diagnose_and_optionally_remediate_int003_query_density",
    "target_assignment": "TYPO-CORRECTION-002-INT003-QUERY-DENSITY-REMEDIATION-001",
    "parent_assignment": "TYPO-CORRECTION-002",
    "consumption_state": "unconsumed",
    "live_gate": "Human must mark this AUTH Live before any diagnose-beyond-docs or Swift change; consume before first non-docs remediation action; further continue-auth required before code fixes after diagnose",
    "artifact_bindings": [
      {"kind": "docs_tip_designated", "identity": "65a0a11d197616928c66f3c148193982c9935945"},
      {"kind": "product_residual_pr", "identity": "161"},
      {"kind": "case", "identity": "TC2-CASE-INT-003"},
      {"kind": "contract", "identity": "TC2-CTR-INT-002"},
      {"kind": "run", "identity": "TC2-SIM-20260923-201910-INT003-STALE-CANCEL-PRODUCT-001"},
      {"kind": "evidence", "identity": "docs/evidence/typo-correction-002-sim-run-2026-09-23-int003-stale-cancel-product-001.md"},
      {"kind": "evidence_sha256", "identity": "3dde0362923fb36071c611134c6c0022ce70d20839afa2dd67894260428835b4"},
      {"kind": "architecture_review", "identity": "docs/reviews/typo-correction-002-int003-stale-cancel-product-capture-2026-09-23-001-architecture-review.md"},
      {"kind": "quality_review", "identity": "docs/reviews/typo-correction-002-int003-stale-cancel-product-capture-2026-09-23-001-quality-review.md"},
      {"kind": "product_residual", "identity": "docs/product-decisions/TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001-PRODUCT-RESIDUAL.md"},
      {"kind": "related_capture_auth_consumed_non_authorizing", "identity": "AUTH-TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001"},
      {"kind": "related_markers_auth_consumed_non_authorizing", "identity": "AUTH-TYPO-CORRECTION-002-INT003-CANCEL-OBSERVABILITY-MARKERS-001"},
      {"kind": "residual_codes", "identity": "typo_recall.query_begin,typo_recall.query_outcome"},
      {"kind": "residual_counts", "identity": "574/574"}
    ],
    "allowed_external_effects_when_live": [
      "read_only_code_and_journal_correlation_for_query_density_root_cause",
      "write_docs_evidence_of_root_cause_under_clean_tip",
      "after_separate_continue_auth_post_diagnose_minimal_emit_semantics_or_scheduling_fixes_in_TypoCorrectionRecallCoordinator",
      "edit_DiagnosticEvent_or_marker_helpers_only_if_required_for_emit_correctness_under_ADR_0027",
      "add_focused_unit_or_contract_tests_for_remediation_non_regression",
      "local_commit_of_in_scope_remediation_when_separately_asked"
    ],
    "exclusions": [
      "execute_while_status_proposed",
      "reuse_of_consumed_CAPTURE_or_MARKERS_or_CADENCE_as_Live_remediation_authority",
      "Product_Gate",
      "QA001_Product_Gate",
      "parent_Close",
      "Release_TestFlight",
      "RimeRuntimeProvenance_restore",
      "fence_discarded_remediation_under_this_AUTH",
      "reopen_Markers_AUTH",
      "auto_Live_auto_Capture_merge_without_ask",
      "change_180ms_product_budget_unless_root_cause_proves_emit_correctness_requires_it",
      "ACTIVE_WORK_Live_implication_from_Proposed_docs",
      "Swift_or_diagnose_execution_before_Live_and_consume"
    ],
    "decision_source": "Human 2026-09-23 Asia/Shanghai after #161: narrow query_* remediation Proposed AUTH; status stays Proposed until separate Live ask"
  }
}
```

## Scope (activates only when status → Live; consume before first non-docs action)

- Root-cause **`typo_recall.query_begin` / `query_outcome` density** from Capture Run `TC2-SIM-20260923-201910-INT003-STALE-CANCEL-PRODUCT-001` (**574/574**) vs Product claim of post-pause-only lookup.
- Prefer **diagnose-first**: distinguish observability over-emit vs real lookup storms in `TypoCorrectionRecallCoordinator`.
- When Live+consumed: read-only code/journal correlation; docs evidence of root-cause; **then** if Human continues, minimal emit/semantics or scheduling fixes under separate continue.
- Default: do **not** change 180 ms product budget unless root-cause proves emit correctness requires it (document if so).

### Touch zones when Live (listed only; not execute now)

- `Keyboard/Controllers/TypoCorrectionRecallCoordinator.swift` (primary)
- Possibly `Packages/KeyboardCore/.../TypoCorrectionRecallDiagnosticMarkers.swift` / `DiagnosticEvent.swift` if emit correctness requires it
- Focused unit/contract tests; docs evidence for remediation tip

## Related records (non-authorizing for Live remediation while this AUTH is Proposed)

- Capture AUTH remains **Consumed** — not Live remediation authority.
- Markers AUTH remains **Consumed** — not reopened.
- Product residual records Human choice of Open remediation (narrow) and links here; residual alone does not Live-mark this AUTH.
- Architecture / Quality Pass-with-conditions are package context only.

## Explicit non-goals

Product Gate; QA-001 Gate; parent Close; TestFlight/Release; `RimeRuntimeProvenance` restore; `fence_discarded` remediation in this AUTH (follow-on); Markers AUTH reopen; treating Proposed as Live; auto Capture; merge without ask; Swift while Proposed.

## Consume rules

1. Status remains **Proposed / unconsumed** until Human explicitly marks **Live**.
2. While Proposed: **no** Swift / ObjC / RIME; no diagnose-as-Live execution; no ACTIVE_WORK Live claim from this AUTH.
3. When Live: **consume before the first non-docs remediation action**; perform only `allowed_external_effects_when_live`; prefer diagnose evidence before any code fix; code fixes need separate continue after diagnose unless Human's Live ask already covers both (document which).
4. Consumption does **not** grant Product Gate, QA-001 Gate, parent Close, TestFlight/Release, fence expansion, or Markers reopen.
5. Do **not** reuse Consumed Capture / Markers / Cadence AUTHs as Live authority for this remediation.

## Required Evidence

| Artifact | Requirement |
|---|---|
| Proposed binding (now) | Tip `65a0a11d197616928c66f3c148193982c9935945` after #161; residual Option B narrow `query_*`; Capture/Markers cited as Consumed non-authorizing |
| Live diagnose (future) | Root-cause note: over-emit vs real storms; journal/code correlation; tip SHA |
| Live remediation (future, if continue) | Minimal tip SHA; tests; document any 180 ms budget necessity |
| Non-claims | Intact: not Live now; no Swift; no Gate; no fence expansion; Capture AUTH not reused as Live |

## Depends on / Outcome

Human marking this AUTH **Live** (separate ask) before diagnose/code. Until then: **Proposed / unconsumed**. Parent remains Active. This Proposed docs PR must not be treated as Live. No Gate.
