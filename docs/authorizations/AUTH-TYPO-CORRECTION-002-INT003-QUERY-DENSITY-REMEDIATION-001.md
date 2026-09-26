# Authorization: AUTH-TYPO-CORRECTION-002-INT003-QUERY-DENSITY-REMEDIATION-001

## Current Status

| Field | Value |
|---|---|
| **Status** | **Consumed** — bounded source diagnosis and follow-up operation-level capture; the original `<180 ms` rapid-window correlation remains unresolved |
| **Assignment** | [`TYPO-CORRECTION-002-INT003-QUERY-DENSITY-REMEDIATION-001`](../assignments/typo-correction-002-int003-query-density-remediation-001.md) |
| **Parent** | [`TYPO-CORRECTION-002`](../assignments/typo-correction-002.md) (Active) |
| **Consumer** | Codex current task under Human continuation authorization |
| **Decision source** | Human: 「授权你进行接下来的所有工作」 (2026-09-25 Asia/Shanghai), including reassignment of the bounded query-density work to Codex. The AUTH was rebound to verified GitHub main and consumed before diagnosis; scope exclusions remain in force. Capture AUTH stays **Consumed**; Markers AUTH stays **Consumed** |
| **Live at** | `2026-09-23T22:10:00+08:00` |
| **Consumed at** | `2026-09-25T15:35:47+08:00` |
| **Designated tip** | `e28491a8e4ae6e5127c3241228c6fa9a1f4f082c` (verified GitHub `main` after PR #173); Capture install tip `80091f35cc5411b292eca78662f39e2b91694045` is its ancestor, and the relevant source blobs match |

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-TYPO-CORRECTION-002-INT003-QUERY-DENSITY-REMEDIATION-001",
  "record_type": "authorization",
  "title": "Consumed AUTH: narrow typo_recall.query_begin / query_outcome density diagnosis",
  "status": "consumed",
  "updated_at": "2026-09-25T16:56:41+08:00",
  "revalidation_triggers": [
    "docs_tip_changed_from_e28491a",
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
    "consumption_state": "consumed",
    "live_at": "2026-09-23T22:10:00+08:00",
    "consumed_at": "2026-09-25T15:35:47+08:00",
    "consumer": "Codex current task under Human continuation authorization",
    "live_gate": "Human marked this AUTH Live after #162; Human authorized the pre-merge docs-only rebind and PR #163 squash merge; PR #173 recorded the M-02 status sync. On 2026-09-25 Human authorized the remaining narrow work and reassigned the executor to Codex. Before diagnosis, GitHub main was verified at e28491a8e4ae6e5127c3241228c6fa9a1f4f082c and this AUTH was consumed. The capture install tip 80091f35cc5411b292eca78662f39e2b91694045 is an ancestor with matching relevant source blobs. Revalidate if GitHub main changes before the next source-bound action.",
    "artifact_bindings": [
      {"kind": "docs_tip_designated", "identity": "e28491a8e4ae6e5127c3241228c6fa9a1f4f082c"},
      {"kind": "capture_install_tip", "identity": "80091f35cc5411b292eca78662f39e2b91694045"},
      {"kind": "docs_tip_proposed_historical", "identity": "65a0a11d197616928c66f3c148193982c9935945"},
      {"kind": "product_residual_pr", "identity": "161"},
      {"kind": "proposed_auth_pr", "identity": "162"},
      {"kind": "case", "identity": "TC2-CASE-INT-003"},
      {"kind": "contract", "identity": "TC2-CTR-INT-002"},
      {"kind": "run", "identity": "TC2-SIM-20260923-201910-INT003-STALE-CANCEL-PRODUCT-001"},
      {"kind": "evidence", "identity": "docs/evidence/typo-correction-002-sim-run-2026-09-23-int003-stale-cancel-product-001.md"},
      {"kind": "evidence_sha256", "identity": "3dde0362923fb36071c611134c6c0022ce70d20839afa2dd67894260428835b4"},
      {"kind": "diagnosis_evidence", "identity": "docs/evidence/typo-correction-002-int003-query-density-diagnosis-001.md"},
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
      "reuse_of_consumed_CAPTURE_or_MARKERS_AUTH_as_Live_capture_authority",
      "new_capture_without_distinct_current_Capture_AUTH",
      "Swift_or_diagnose_execution_before_consume"
    ],
    "decision_source": "Human authorized the remaining narrow query-density work and reassigned execution to Codex with 「授权你进行接下来的所有工作」 on 2026-09-25 Asia/Shanghai. Codex acknowledged scope and dependencies. This AUTH was rebound to verified GitHub main e28491a8e4ae6e5127c3241228c6fa9a1f4f082c and consumed at 2026-09-25T15:35:47+08:00 before diagnosis. A fresh Simulator capture requires a separate Capture Assignment/AUTH.",
    "consumed_artifacts": [
      "Bounded source diagnosis recorded in docs/evidence/typo-correction-002-int003-query-density-diagnosis-001.md",
      "Source diagnosis: duplicate query_* marker emission ruled out for the captured call path; operation-level cadence unresolved because the bound raw journal is unavailable on this host"
    ]
  }
}
```

## Scope (Consumed — bounded query-density diagnosis active)

- Root-cause **`typo_recall.query_begin` / `query_outcome` density** from Capture Run `TC2-SIM-20260923-201910-INT003-STALE-CANCEL-PRODUCT-001` (**574/574**) vs Product claim of post-pause-only lookup.
- Prefer **diagnose-first**: distinguish observability over-emit vs real lookup storms in `TypoCorrectionRecallCoordinator`.
- Under the Human 2026-09-25 continuation authorization: read-only code/journal correlation and evidence; if the operation-level evidence proves a narrow source defect, continue only within the existing touch zones and scope.
- A fresh Simulator capture is **not** authorized by the already Consumed Product Capture AUTH; it requires a distinct current Capture Assignment/AUTH.
- Default: do **not** change 180 ms product budget unless root-cause proves emit correctness requires it (document if so).

### Touch zones if diagnosis proves a source defect

- `Keyboard/Controllers/TypoCorrectionRecallCoordinator.swift` (primary)
- Possibly `Packages/KeyboardCore/.../TypoCorrectionRecallDiagnosticMarkers.swift` / `DiagnosticEvent.swift` if emit correctness requires it
- Focused unit/contract tests; docs evidence for remediation tip

## Related records

- Capture AUTH remains **Consumed** — not authority for a fresh Capture.
- Markers AUTH remains **Consumed** — not reopened.
- Product residual records Human choice of Open remediation (narrow) and links here; residual alone does not authorize diagnose/Swift.
- Architecture / Quality Pass-with-conditions are package context only.

## Explicit non-goals

Product Gate; QA-001 Gate; parent Close; TestFlight/Release; `RimeRuntimeProvenance` restore; `fence_discarded` remediation in this AUTH (follow-on); Markers AUTH reopen; treating Live/unconsumed as already-consumed diagnose/Swift authority; auto Capture; merge without ask; diagnose or Swift from Live alone.

## Consume rules

1. Historical Live state: Human marked Live at `2026-09-23T22:10:00+08:00`, initially bound to `a9b82a58…` (#162); the pre-merge rebind was `1ee2728712e67a32ff908a27befad2c537445077`; after PR #163 merge, M-02 revalidated `15e2be5ef3ebdef2b07ac6ec2429a1fe8cd9436a`.
2. Current state is **Consumed** at `2026-09-25T15:35:47+08:00`, after the Human continuation authorization, executor reassignment, and revalidation to GitHub main `e28491a8e4ae6e5127c3241228c6fa9a1f4f082c`.
3. **Consume before the first non-docs remediation action**; perform only `allowed_external_effects_when_live`; prefer diagnose evidence before any code fix; code fixes need separate continue after diagnose unless Human's continue ask already covers both (document which).
4. Consumption does **not** grant Product Gate, QA-001 Gate, parent Close, TestFlight/Release, fence expansion, or Markers reopen.
5. Do **not** reuse Consumed Capture / Markers / Cadence AUTHs as Live authority for this remediation.

## Required Evidence

| Artifact | Requirement |
|---|---|
| Proposed binding (historical; landed via #162) | Tip `65a0a11d197616928c66f3c148193982c9935945` after #161; residual Option B narrow `query_*`; Capture/Markers cited as Consumed non-authorizing — Proposed package merged as tip `a9b82a58cac0c28e8a5d8a957d464d803d6d92d1` (#162) |
| Initial Live-at tip binding (historical) | Tip `a9b82a58cac0c28e8a5d8a957d464d803d6d92d1` (#162 merge); Live at `2026-09-23T22:10:00+08:00` |
| Pre-merge binding (historical) | Tip `1ee2728712e67a32ff908a27befad2c537445077`; Human-authorized docs-only revalidation on `2026-09-25`; superseded by post-merge M-02 revalidation |
| Post-#163 binding (historical) | Tip `15e2be5ef3ebdef2b07ac6ec2429a1fe8cd9436a`; PR #163 source head `079bc3c12e36756c96ace8bd0b26b7f94cffe4c2`, merged at `2026-09-25T06:54:54Z` |
| Consumed diagnosis binding | GitHub main `e28491a8e4ae6e5127c3241228c6fa9a1f4f082c`; capture install tip `80091f35cc5411b292eca78662f39e2b91694045` is an ancestor with matching relevant source blobs; consumed at `2026-09-25T15:35:47+08:00` |
| Diagnosis evidence | `docs/evidence/typo-correction-002-int003-query-density-diagnosis-001.md`; duplicate marker emission ruled out; distinct follow-up run observed 359 real calls across 12 operations (26–32 each), but manual intervals were 285–576 ms and do not reconstruct the original rapid window |
| Live remediation (future, if continue) | Minimal tip SHA; tests; document any 180 ms budget necessity |
| Non-claims | AUTH consumed; bounded source diagnosis only; operation-level cadence unresolved; no Swift; no Gate; Capture AUTH stays Consumed; Markers AUTH stays Consumed; a fresh capture needs its own AUTH |

## Depends on / Outcome

AUTH is **Consumed** at `2026-09-25T15:35:47+08:00`, bound to verified GitHub main `e28491a8e4ae6e5127c3241228c6fa9a1f4f082c`. The bounded diagnosis rules out duplicate `query_*` marker emission. A distinct follow-up Capture AUTH, bound to `4ef275b57d16f116b4edbae99a0e244a28d6bf25`, was consumed at `2026-09-25T16:06:56+08:00`; its run shows 359 real query pairs across 12 operations, with 26–32 calls per operation and first calls 219–260 ms after scheduling. The user's fastest manual input remained above 180 ms, so the original rapid-window correlation remains unresolved. No Swift change. Parent remains Active. Capture AUTHs and Markers AUTH remain **Consumed**. No Gate. Any fresh capture or source change requires its own current authorization.
