# Authorization: AUTH-TYPO-CORRECTION-002-INT003-QUERY-DENSITY-DIAGNOSTIC-CAPTURE-001

## Current Status

| Field | Value |
|---|---|
| **Status** | **Consumed** — distinct bounded diagnostic Capture authorization |
| **Assignment** | [`TYPO-CORRECTION-002-INT003-QUERY-DENSITY-DIAGNOSTIC-CAPTURE-001`](../assignments/typo-correction-002-int003-query-density-diagnostic-capture-001.md) |
| **Parent** | [`TYPO-CORRECTION-002`](../assignments/typo-correction-002.md) (Active) |
| **Decision source** | Human: 「授权你进行接下来的所有工作」 — `2026-09-25` Asia/Shanghai; Codex created this distinct AUTH because the prior Product Capture AUTH is Consumed |
| **Consumer** | Codex current task under the Human continuation authorization |
| **Live at** | `2026-09-25T16:01:48+08:00` |
| **Consumed at** | `2026-09-25T16:06:56+08:00` |
| **Designated source tip** | `4ef275b57d16f116b4edbae99a0e244a28d6bf25` (reverified GitHub `main` after docs-only PR #174; scoped runtime source files unchanged from `e28491a…`) |
| **Designated Simulator** | `06C5BC3E-7599-4761-A1A2-71DAEA991474` — must be rediscovered at execution |

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-TYPO-CORRECTION-002-INT003-QUERY-DENSITY-DIAGNOSTIC-CAPTURE-001",
  "record_type": "authorization",
  "title": "Consumed AUTH: bounded INT-003 query-density diagnostic recapture",
  "status": "consumed",
  "updated_at": "2026-09-25T16:56:41+08:00",
  "revalidation_triggers": [
    "github_main_tip_changed_from_4ef275b",
    "designated_simulator_unavailable_or_changed",
    "diagnostic_schema_or_marker_contract_changed",
    "raw_journal_capture_or_sha_unavailable",
    "AUTH_revoked_or_executor_changed",
    "scope_expansion_to_product_capture_or_gate_or_source_change"
  ],
  "authorization": {
    "action": "capture_int003_query_density_raw_journal_diagnostic",
    "target_assignment": "TYPO-CORRECTION-002-INT003-QUERY-DENSITY-DIAGNOSTIC-CAPTURE-001",
    "parent_assignment": "TYPO-CORRECTION-002",
    "consumption_state": "consumed",
    "live_at": "2026-09-25T16:01:48+08:00",
    "consumed_at": "2026-09-25T16:06:56+08:00",
    "consumer": "Codex current task under Human continuation authorization",
    "live_gate": "Human authorized all remaining work in the narrow query-density path on 2026-09-25 Asia/Shanghai. This distinct Capture AUTH is required because the prior Product Capture AUTH is Consumed. The initial e28491a binding was revalidated after docs-only PR #174 advanced GitHub main to 4ef275b57d16f116b4edbae99a0e244a28d6bf25; the three changed paths are unrelated KOS documents and all six scoped runtime source files are unchanged. GitHub main was verified at 4ef275b immediately before consumption. This AUTH is Consumed before any Simulator operation.",
    "artifact_bindings": [
      {"kind": "source_tip", "identity": "4ef275b57d16f116b4edbae99a0e244a28d6bf25"},
      {"kind": "previous_source_binding", "identity": "e28491a8e4ae6e5127c3241228c6fa9a1f4f082c"},
      {"kind": "source_delta_review", "identity": "docs-only PR #174; no scoped runtime source changes"},
      {"kind": "parent_assignment", "identity": "TYPO-CORRECTION-002"},
      {"kind": "query_density_assignment", "identity": "TYPO-CORRECTION-002-INT003-QUERY-DENSITY-REMEDIATION-001"},
      {"kind": "diagnosis_evidence", "identity": "docs/evidence/typo-correction-002-int003-query-density-diagnosis-001.md"},
      {"kind": "prior_run", "identity": "TC2-SIM-20260923-201910-INT003-STALE-CANCEL-PRODUCT-001"},
      {"kind": "prior_capture_auth_consumed_non_authorizing", "identity": "AUTH-TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001"},
      {"kind": "markers_auth_consumed_non_authorizing", "identity": "AUTH-TYPO-CORRECTION-002-INT003-CANCEL-OBSERVABILITY-MARKERS-001"},
      {"kind": "simulator_designated", "identity": "06C5BC3E-7599-4761-A1A2-71DAEA991474"},
      {"kind": "run", "identity": "TC2-SIM-20260925-161830-INT003-QUERY-DENSITY-DIAGNOSTIC-001"},
      {"kind": "run_evidence", "identity": "docs/evidence/typo-correction-002-sim-run-2026-09-25-int003-query-density-diagnostic-001.md"},
      {"kind": "contract", "identity": "TC2-CTR-INT-002"}
    ],
    "allowed_external_effects_when_live": [
      "explicit_github_main_revalidation_before_consume",
      "simctl_listing_for_the_designated_UDID_after_consume",
      "bounded_build_install_launch_and_simulator_arm_on_the_designated_UDID",
      "visible-key_synthetic_diagnostic_stimulus_only",
      "preserve_hash_and_summarize_the_run-specific_raw_JSONL_without_input_fields"
    ],
    "exclusions": [
      "execute_while_status_proposed_or_live_unconsumed",
      "reuse_of_consumed_product_capture_or_markers_AUTH",
      "human_visual_or_product_acceptance_claim",
      "Product_Gate",
      "QA001_Product_Gate",
      "parent_Close",
      "Release_TestFlight",
      "Swift_or_test_changes",
      "fence_discarded_remediation",
      "RimeRuntimeProvenance_restore",
      "raw_user_text_or_candidate_text_in_committed_evidence",
      "device_substitution_without_revalidation",
      "commit_push_PR_merge_without_authorization"
    ],
    "decision_source": "Human explicitly authorized all remaining work in the narrow query-density path on 2026-09-25 Asia/Shanghai. This AUTH is a new, separate Capture authorization; after PR #174 advanced GitHub main, the binding was revalidated to 4ef275b57d16f116b4edbae99a0e244a28d6bf25 and all scoped runtime source paths were verified unchanged. It was consumed at 2026-09-25T16:06:56+08:00 before any Simulator operation. It cannot be replaced by or reuse the Consumed Product Capture AUTH.",
    "required_outputs": [
      "run_header_bound_to_actual_start_and_exact_device",
      "raw_JSONL_preserved_and_SHA256_recorded_before_read",
      "operationOrdinal_and_compositionRevision_query_pair_timeline_without_input_text",
      "bounded_root_cause_status_or_explicit_unresolved_finding"
    ]
  }
}
```

## Scope

- One diagnostic-only Simulator rerun on the exact designated UDID and source tip named in the Assignment.
- Produce the raw JSONL needed to group `query_begin` / `query_outcome` by operation ordinal and compare query timing with the 180 ms debounce and visible-key window.
- Preserve and hash raw output before inspection; commit only redacted event metadata and aggregates.
- Live alone authorizes no Simulator action. Consume this AUTH after revalidating GitHub `main`, before listing or touching the Simulator.

## Explicit non-goals

Product Capture acceptance; Human visual attestation; Product Gate; QA-001 Gate; parent Close; TestFlight/Release; source changes; tests; `fence_discarded` remediation; Markers AUTH reopen; `RimeRuntimeProvenance` restore; merge.

## Outcome

AUTH is **Consumed** at `2026-09-25T16:06:56+08:00`, bound to GitHub main `4ef275b57d16f116b4edbae99a0e244a28d6bf25`. Run `TC2-SIM-20260925-161830-INT003-QUERY-DENSITY-DIAGNOSTIC-001` completed on the designated simulator. Its raw Extension JSONL was hashed before inspection (SHA-256 `aa523a6e8330b529e0ffc03283b142f842401b2321e2b323e6ce2762d5b59f84`); 359 paired query events group into 12 operations. The Human's fastest repeatable manual cadence did not reach the target `<180 ms` interval, so the original rapid-window question remains unresolved. The earlier Product Capture AUTH and Markers AUTH remain **Consumed** and were not reused. Parent `TYPO-CORRECTION-002` remains Active. No Gate or Product claim.
