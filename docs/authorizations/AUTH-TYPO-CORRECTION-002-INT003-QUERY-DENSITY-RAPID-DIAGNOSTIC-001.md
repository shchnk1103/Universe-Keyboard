# Authorization: AUTH-TYPO-CORRECTION-002-INT003-QUERY-DENSITY-RAPID-DIAGNOSTIC-001

## Current Status

| Field | Value |
|---|---|
| **Status** | **Consumed** — reserved run stopped before input after Product revised the diagnostic criterion; no further use |
| **Assignment** | [`TYPO-CORRECTION-002-INT003-QUERY-DENSITY-RAPID-DIAGNOSTIC-001`](../assignments/typo-correction-002-int003-query-density-rapid-diagnostic-001.md) |
| **Parent** | [`TYPO-CORRECTION-002`](../assignments/typo-correction-002.md) (Active) |
| **Consumer** | Codex current task under Human continuation authorization |
| **Decision source** | Human: 「授权你进行接下来的所有工作」 (`2026-09-25` Asia/Shanghai). A distinct Capture AUTH is required because earlier Capture AUTHs are Consumed |
| **Live at** | `2026-09-25T17:12:49+08:00` |
| **Consumed at** | `2026-09-25T17:13:00+08:00` |
| **Source tip** | GitHub `main` `4ef275b57d16f116b4edbae99a0e244a28d6bf25`, reverified immediately before consume |
| **Designated Simulator** | `06C5BC3E-7599-4761-A1A2-71DAEA991474` — iPhone 17 Pro Max / iOS 27 |
| **Run** | `TC2-SIM-20260925-171300-INT003-QUERY-DENSITY-RAPID-001` — no-run disposition; read-only UI snapshot only |
| **Product decision** | [Remove 180 ms hard pass condition for this follow-up](../product-decisions/TYPO-CORRECTION-002-INT003-QUERY-DENSITY-DIAGNOSTIC-CRITERION-001.md) |

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-TYPO-CORRECTION-002-INT003-QUERY-DENSITY-RAPID-DIAGNOSTIC-001",
  "record_type": "authorization",
  "title": "Consumed AUTH: prepared INT-003 rapid diagnostic stopped before input",
  "status": "consumed",
  "updated_at": "2026-09-26T10:37:24+08:00",
  "revalidation_triggers": [
    "github_main_tip_changed_from_4ef275b",
    "designated_simulator_unavailable_or_changed",
    "diagnostic_schema_or_marker_contract_changed",
    "raw_journal_capture_or_sha_unavailable",
    "AUTH_revoked_or_executor_changed",
    "scope_expansion_to_product_capture_or_gate_or_source_change"
  ],
  "authorization": {
    "action": "capture_int003_query_density_rapid_visible_key_diagnostic",
    "target_assignment": "TYPO-CORRECTION-002-INT003-QUERY-DENSITY-RAPID-DIAGNOSTIC-001",
    "parent_assignment": "TYPO-CORRECTION-002",
    "consumption_state": "consumed",
    "live_at": "2026-09-25T17:12:49+08:00",
    "consumed_at": "2026-09-25T17:13:00+08:00",
    "consumer": "Codex current task under Human continuation authorization",
    "live_gate": "Human authorized all remaining work in the narrow query-density path. GitHub main was verified at 4ef275b57d16f116b4edbae99a0e244a28d6bf25 immediately before consume. The prior manual Capture AUTH is Consumed and its fastest repeatable input did not reach 180 ms, so this is a distinct one-run AUTH for visible UI automation only. Consume before simulator inspection or interaction.",
    "artifact_bindings": [
      {"kind": "source_tip", "identity": "4ef275b57d16f116b4edbae99a0e244a28d6bf25"},
      {"kind": "installed_app_build", "identity": "1.0 (1); app SHA-256 a082030ffe68eb214251c547c3895eb9054903e27eb0e4b86efcd74437319444"},
      {"kind": "installed_keyboard_build", "identity": "extension SHA-256 d8b6e902f0bf91cb1dafd4741c126fb57ab70fc43211eb526a0f0266b4a28826"},
      {"kind": "parent_assignment", "identity": "TYPO-CORRECTION-002"},
      {"kind": "query_density_assignment", "identity": "TYPO-CORRECTION-002-INT003-QUERY-DENSITY-REMEDIATION-001"},
      {"kind": "prior_diagnostic_run", "identity": "TC2-SIM-20260925-161830-INT003-QUERY-DENSITY-DIAGNOSTIC-001"},
      {"kind": "prior_diagnostic_raw_sha256", "identity": "aa523a6e8330b529e0ffc03283b142f842401b2321e2b323e6ce2762d5b59f84"},
      {"kind": "simulator", "identity": "06C5BC3E-7599-4761-A1A2-71DAEA991474"},
      {"kind": "run", "identity": "TC2-SIM-20260925-171300-INT003-QUERY-DENSITY-RAPID-001"},
      {"kind": "contract", "identity": "TC2-CTR-INT-002"}
    ],
    "allowed_external_effects_when_live": [
      "read_only_github_main_revalidation_before_consume",
      "designated_simulator_status_inspection_after_consume",
      "refresh_existing_high_fidelity_diagnostic_window_for_this_run",
      "restart_or_launch_the_existing_4ef275b_debug_app_on_the_designated_simulator",
      "visible_on_screen_keyboard_key_taps_automated_by_XcodeBuildMCP_or_CUA_only",
      "preserve_hash_and_summarize_run_specific_raw_JSONL_without_input_fields"
    ],
    "exclusions": [
      "reuse_of_any_consumed_capture_or_markers_AUTH",
      "simulator_text_injection_type_text_clipboard_hardware_key_sequence_or_private_API",
      "device_substitution_without_revalidation",
      "Product_or_UX_acceptance_claim",
      "Product_Gate_or_QA001_Gate",
      "parent_Close",
      "Release_or_TestFlight",
      "Swift_or_test_changes",
      "fence_discarded_remediation",
      "RimeRuntimeProvenance_restore",
      "commit_push_PR_or_merge",
      "second_run_under_this_AUTH"
    ],
    "decision_source": "Human explicitly authorized all remaining work in the narrow query-density path on 2026-09-25 Asia/Shanghai. This AUTH is separate because all earlier Capture AUTHs are Consumed. It is consumed before simulator interaction and only permits one visible-key automation run.",
    "required_outputs": [
      "at_least_five_adjacent_inter_key_intervals_under_180ms_or_explicit_miss",
      "pause_interval_at_least_180ms_or_explicit_miss",
      "raw_JSONL_preserved_and_SHA256_recorded_before_read",
      "operationOrdinal_compositionRevision_and_debounce_timeline_without_input_text",
      "bounded_root_cause_or_explicit_unresolved_finding"
    ]
  }
}
```

## Scope

> **Historical scope, no longer executable:** Product removed the hard-cadence condition on 2026-09-26. The permission below remains Consumed and is not Live authority for a run.

- One bounded diagnostic-only run on the designated simulator and source tip.
- Automated input must be taps on the visible on-screen keyboard keys. This AUTH does not authorize `type_text`, hardware key sequences, clipboard insertion, test APIs, private APIs, source edits, or tests.
- Keep all input synthetic; preserve and hash raw JSONL before row inspection; commit no raw journal or input fields.
- A miss of the `<180 ms` target is a recorded limitation, not authority for additional attempts.

## Explicit non-goals

Product Capture acceptance; Human visual attestation; Product Gate; QA-001 Gate; parent Close; TestFlight/Release; Swift/tests; `fence_discarded` remediation; Markers AUTH reopen; `RimeRuntimeProvenance` restore; commit/push/PR/merge.

## Outcome

AUTH was **Consumed** at `2026-09-25T17:13:00+08:00` before simulator inspection. A read-only UI snapshot was taken; no keyboard-key tap, diagnostic re-arm, new Extension process, or run-specific raw journal followed. The Human requested a pause, then [removed the 180 ms hard pass condition](../product-decisions/TYPO-CORRECTION-002-INT003-QUERY-DENSITY-DIAGNOSTIC-CRITERION-001.md). The reserved Run ID has a no-run disposition. This AUTH remains Consumed; no repeated attempt, Product claim, or Gate follows. Parent remains Active.
