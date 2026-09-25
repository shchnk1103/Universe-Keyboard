# Authorization: AUTH-TYPO-CORRECTION-002-INT003-QUERY-DENSITY-REMEDIATION-001

## Current Status

| Field | Value |
|---|---|
| **Status** | **Live / unconsumed** (not consumed) |
| **Assignment** | [`TYPO-CORRECTION-002-INT003-QUERY-DENSITY-REMEDIATION-001`](../assignments/typo-correction-002-int003-query-density-remediation-001.md) |
| **Parent** | [`TYPO-CORRECTION-002`](../assignments/typo-correction-002.md) (Active) |
| **Decision source** | Human authorized docs-only Live mark for narrow `query_*` remediation AUTH (2026-09-23 Asia/Shanghai) 「授权 docs-only 将 query_* remediation AUTH 标为 Live/unconsumed，开 PR，不自动合、不诊断、不改 Swift」; Human separately authorized a docs-only rebind on `2026-09-25` to the verified current main tip; this adds no consume/diagnose/Swift authority; Capture AUTH stays **Consumed**; Markers AUTH stays **Consumed** |
| **Live at** | `2026-09-23T22:10:00+08:00` |
| **Consumed at** | — |
| **Designated tip** | `1ee2728712e67a32ff908a27befad2c537445077` (verified `origin/main` before #163 merge, 2026-09-25; original Live-mark tip after #162 was `a9b82a58cac0c28e8a5d8a957d464d803d6d92d1`) |

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-TYPO-CORRECTION-002-INT003-QUERY-DENSITY-REMEDIATION-001",
  "record_type": "authorization",
  "title": "Live remediation AUTH: narrow typo_recall.query_begin / query_outcome density (diagnose-first; unconsumed)",
  "status": "live",
  "updated_at": "2026-09-25T14:24:06+08:00",
  "revalidation_triggers": [
    "docs_tip_changed_from_1ee2728",
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
    "live_at": "2026-09-23T22:10:00+08:00",
    "live_gate": "Human marked this AUTH Live after #162 with original tip a9b82a58; on 2026-09-25 Human authorized a docs-only rebind to current pre-merge main tip 1ee2728712e67a32ff908a27befad2c537445077; still unconsumed; Live alone does not authorize diagnose or Swift — consume + separate Human ask required before diagnose/Swift; revalidate after any main-tip change before consume",
    "artifact_bindings": [
      {"kind": "docs_tip_designated", "identity": "1ee2728712e67a32ff908a27befad2c537445077"},
      {"kind": "docs_tip_proposed_historical", "identity": "65a0a11d197616928c66f3c148193982c9935945"},
      {"kind": "product_residual_pr", "identity": "161"},
      {"kind": "proposed_auth_pr", "identity": "162"},
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
      "diagnose_or_Swift_from_Live_unconsumed_alone",
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
      "ACTIVE_WORK_diagnose_implication_from_Live_unconsumed_docs",
      "Swift_or_diagnose_execution_before_consume_and_separate_ask"
    ],
    "decision_source": "Human authorized docs-only Live mark 2026-09-23 Asia/Shanghai after #162; Human separately authorized the docs-only designated-tip rebind to 1ee2728712e67a32ff908a27befad2c537445077 on 2026-09-25; still unconsumed; diagnose/Swift require consume + separate Human ask"
  }
}
```

## Scope (activates when status → Live — now Live / unconsumed)

- Root-cause **`typo_recall.query_begin` / `query_outcome` density** from Capture Run `TC2-SIM-20260923-201910-INT003-STALE-CANCEL-PRODUCT-001` (**574/574**) vs Product claim of post-pause-only lookup.
- Prefer **diagnose-first**: distinguish observability over-emit vs real lookup storms in `TypoCorrectionRecallCoordinator`.
- When Live+**consumed** (consume + separate Human ask): read-only code/journal correlation; docs evidence of root-cause; **then** if Human continues, minimal emit/semantics or scheduling fixes under separate continue.
- **Live alone does not authorize diagnose or Swift.** Consume before the first non-docs remediation action; separate Human ask before diagnose/Swift.
- Default: do **not** change 180 ms product budget unless root-cause proves emit correctness requires it (document if so).

### Touch zones when implementing (consume AUTH + separate ask first)

- `Keyboard/Controllers/TypoCorrectionRecallCoordinator.swift` (primary)
- Possibly `Packages/KeyboardCore/.../TypoCorrectionRecallDiagnosticMarkers.swift` / `DiagnosticEvent.swift` if emit correctness requires it
- Focused unit/contract tests; docs evidence for remediation tip

## Related records (non-authorizing for Live remediation execution while this AUTH is unconsumed)

- Capture AUTH remains **Consumed** — not Live remediation authority.
- Markers AUTH remains **Consumed** — not reopened.
- Product residual records Human choice of Open remediation (narrow) and links here; residual alone does not authorize diagnose/Swift.
- Architecture / Quality Pass-with-conditions are package context only.

## Explicit non-goals

Product Gate; QA-001 Gate; parent Close; TestFlight/Release; `RimeRuntimeProvenance` restore; `fence_discarded` remediation in this AUTH (follow-on); Markers AUTH reopen; treating Live/unconsumed as already-consumed diagnose/Swift authority; auto Capture; merge without ask; diagnose or Swift from Live alone.

## Consume rules

1. Status is **Live / unconsumed**. Human marked Live at `2026-09-23T22:10:00+08:00`, initially bound to `a9b82a58…` (#162); Human later authorized a docs-only rebind to current pre-merge `main` tip `1ee2728712e67a32ff908a27befad2c537445077` on `2026-09-25`.
2. Still **no** Swift / ObjC / RIME; **no diagnose-as-Live execution**; no ACTIVE_WORK diagnose claim from Live alone. **Live alone does not authorize diagnose** — consume + separate Human ask are required before diagnose or Swift.
3. **Consume before the first non-docs remediation action**; perform only `allowed_external_effects_when_live`; prefer diagnose evidence before any code fix; code fixes need separate continue after diagnose unless Human's continue ask already covers both (document which).
4. Consumption does **not** grant Product Gate, QA-001 Gate, parent Close, TestFlight/Release, fence expansion, or Markers reopen.
5. Do **not** reuse Consumed Capture / Markers / Cadence AUTHs as Live authority for this remediation.

## Required Evidence

| Artifact | Requirement |
|---|---|
| Proposed binding (historical; landed via #162) | Tip `65a0a11d197616928c66f3c148193982c9935945` after #161; residual Option B narrow `query_*`; Capture/Markers cited as Consumed non-authorizing — Proposed package merged as tip `a9b82a58cac0c28e8a5d8a957d464d803d6d92d1` (#162) |
| Initial Live-at tip binding (historical) | Tip `a9b82a58cac0c28e8a5d8a957d464d803d6d92d1` (#162 merge); Live at `2026-09-23T22:10:00+08:00` |
| Current pre-merge binding | Tip `1ee2728712e67a32ff908a27befad2c537445077`; Human-authorized docs-only revalidation on `2026-09-25`; `consumption_state` still unconsumed; after #163 merge, revalidate the new main tip before consume |
| Live diagnose (future, after consume + separate ask) | Root-cause note: over-emit vs real storms; journal/code correlation; tip SHA |
| Live remediation (future, if continue) | Minimal tip SHA; tests; document any 180 ms budget necessity |
| Non-claims | Intact: not consumed; no diagnose run yet; no Swift; no Gate; Capture AUTH stays Consumed; Markers AUTH stays Consumed; Live alone ≠ diagnose authority |

## Depends on / Outcome

AUTH is **Live / unconsumed**, with current pre-merge binding `1ee2728712e67a32ff908a27befad2c537445077` after Human-authorized docs-only revalidation on `2026-09-25`. Still no diagnose / Swift until consume + separate Human ask. Parent remains Active. Capture AUTH stays **Consumed**. Markers AUTH stays **Consumed**. No Gate. PR #163 must not be merged without separate Human authorization; revalidate the new main tip after merge before consume.
