# Authorization: INT-003 P1 CI remediation 001

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-P1-CI-REMEDIATION-001",
  "record_type": "authorization",
  "title": "Repair compile failures found while validating INT-003 P1 PR #184",
  "status": "consumed",
  "updated_at": "2026-09-27T19:32:19+08:00",
  "authorization_action": "repair_int003_p1_ci_compile_failures",
  "target": "TYPO-CORRECTION-002-INT003-QUERY-COST-MEASUREMENT-001",
  "authorization": {
    "scope": "On the existing isolated PR #184 branch, fix the CI compile errors caused by ambiguous RimeCandidate names and the missing DiagnosticsEventDisplayFormatter case for DiagnosticEvent.Field.typoRecallQuery. Render only the closed content-free payload values already approved by the P1 schema, add focused formatter coverage, run applicable local CI gates, and update the existing Draft PR for hosted revalidation.",
    "allowed_paths": [
      "Packages/RimeBridge/Sources/RimeBridge/RimeEngineImpl+CorrectionQuery.swift",
      "Packages/RimeBridge/Tests/RimeBridgeTests/TypoCorrectionSidecarOwnerAdapterTests.swift",
      "Universe Keyboard/Views/Diagnostics/DiagnosticsLogSource.swift",
      "UniverseKeyboardTests/DiagnosticsRuntimeRouteDisplayTests.swift",
      "docs/authorizations/AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-P1-CI-REMEDIATION-001.md",
      "docs/assignments/typo-correction-002-int003-query-cost-measurement-001.md",
      "docs/ACTIVE_WORK.md",
      "docs/evidence/typo-correction-002-int003-query-cost-p1-ci-remediation-001.md"
    ],
    "publication": "Commit and push the bounded repair to existing open Draft PR #184 only; keep it Draft.",
    "exclusions": [
      "reuse_or_reconsume_the_consumed_P1_instrumentation_AUTH",
      "change_query_timing_or_instrumentation_semantics",
      "add_or_expand_diagnostic_payload_fields_or_log_user_content",
      "change_product_contract_or_performance_budget",
      "P2_Simulator_capture_or_physical_device_operation",
      "mark_PR_ready_or_merge_PR",
      "Product_or_QA001_Gate_parent_Close_TestFlight_Release_or_ADR_Accept",
      "restore_RimeRuntimeProvenance"
    ],
    "issuer_role": "Human Product Owner acting as Product Lead",
    "decision_source": "Human 2026-09-27 Asia/Shanghai instruction to repair GitHub CI for PR #184; the diagnostics renderer path was added to this bounded revalidation after local CI exposed its missing exhaustive case.",
    "issued_at": "2026-09-27T19:32:19+08:00",
    "consumption_state": "consumed",
    "consumed_at": "2026-09-27T19:32:19+08:00",
    "consumed_by": "Codex current task",
    "consumption_record": "The explicit current Human CI-repair instruction is the authority for this follow-up, not the consumed P1 instrumentation AUTH. The required CI correction is bounded to the four listed Swift files. Two RimeBridge type qualifications were already applied within the original P1 allowed-path set; this revalidation gates the newly required diagnostics-renderer/test scope and publication. No query behavior, payload schema, or Product decision changes.",
    "artifact_bindings": [
      {"kind": "pull_request", "identity": "https://github.com/shchnk1103/Universe-Keyboard/pull/184"},
      {"kind": "base_commit", "identity": "1160ac6fd8696c3036391cdf59bc9fe096d0b219"},
      {"kind": "branch_head_before_repair", "identity": "9d7739e9e43c3349da313b582551be602f99c4b7"},
      {"kind": "local_test_device", "identity": "iPhone_17_Pro_iOS_26.0_8C2943AC-AC97-432F-ACEE-BE3DA2B9ACB2"},
      {"kind": "prior_p1_authorization", "identity": "AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-P1-INSTRUMENTATION-001 (Consumed; not reused)"}
    ]
  }
}
```

## Execution boundary

- This is a narrow revalidation under the existing Active query-cost Assignment, based on the Human's direct CI-repair instruction.
- The pre-existing P1 implementation and Architecture review remain bound to their original commits. This repair does not claim a new independent Architecture or Quality verdict.
- Local Simulator CI tests may use only the listed iPhone 17 Pro / iOS 26.0 UUID to avoid the iPhone 18 Pro held by another thread. This is CI verification, not P2 capture; do not arm diagnostics or enter Product-capture input.
- Keep PR #184 Draft. Merge, Gate, parent Close and Release decisions remain separate and unauthorized.
