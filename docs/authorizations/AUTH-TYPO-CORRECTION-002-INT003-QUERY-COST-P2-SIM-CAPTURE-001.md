# Authorization: INT-003 query-cost P2 Simulator capture 001

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-P2-SIM-CAPTURE-001",
  "record_type": "authorization",
  "title": "P2 controlled Simulator capture requiring exact installed-payload freeze",
  "status": "proposed",
  "updated_at": "2026-09-26T23:16:00+08:00",
  "revalidation_triggers": [
    "P1_instrumentation_tip_or_review_changes",
    "designated_Simulator_UDID_or_OS_changes",
    "installed_App_or_Extension_payload_changes",
    "schema_access_host_or_diagnostics_arm_changes",
    "Human_operator_or_Product_evidence_scope_changes"
  ],
  "authorization": {
    "action": "capture_int003_query_cost_p2_designated_simulator",
    "target": "TYPO-CORRECTION-002-INT003-QUERY-COST-MEASUREMENT-001",
    "scope": "After a separately reviewed P1 implementation and exact installed-payload freeze, run bounded synthetic cold/warm diagnostic captures on the designated iPhone 17 Pro Max iOS 27 Simulator, preserve and hash content-free dynamic journal segments outside the repository, and publish aggregate evidence for independent Quality review",
    "exclusions": [
      "execute_while_proposed_or_unconsumed",
      "reuse_P0_or_P1_or_prior_Capture_AUTH",
      "Simulator_boot_install_arm_or_input_before_run_manifest_freeze",
      "physical_device_or_Release_like_Product_performance_claim",
      "raw_input_candidate_host_text_or_fingerprint_publication",
      "new_Swift_ObjC_source_change",
      "merge_without_separate_Human_authorization",
      "Product_or_QA001_Gate_parent_Close_TestFlight_Release_ADR_Accept",
      "RimeRuntimeProvenance_restore"
    ],
    "issuer_role": "Human Product Owner acting as Product Lead",
    "decision_source": "Human 2026-09-26 Asia/Shanghai authorized subsequent work while explicitly requiring separate P1 and P2 execution permissions and evidence environments. P2 remains Proposed because the P1 binary, installed payload and run manifest do not yet exist; this record must be rebound Live and consumed before any capture operation",
    "issued_at": "2026-09-26T23:16:00+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "unconsumed",
    "artifact_bindings": [
      {"kind": "designated_simulator_historical", "identity": "iPhone_17_Pro_Max;iOS_27;06C5BC3E-7599-4761-A1A2-71DAEA991474"},
      {"kind": "P1_source_tip_required", "identity": "PENDING_AFTER_P1_REVIEW"},
      {"kind": "installed_payload_manifest_required", "identity": "PENDING_BEFORE_LIVE"},
      {"kind": "run_id_required", "identity": "PENDING_BEFORE_LIVE"},
      {"kind": "measurement_plan", "identity": "docs/plans/typo-correction-002-int003-query-cost-measurement-001.md"}
    ]
  }
}
```

## Freeze and stop rules

P2 is **Proposed / unconsumed**, despite the Human's general authorization to continue. Its executable authority is conditional on a new Live binding and subsequent consumption; it does not inherit P0 or P1. The environment executor will be Codex for controlled Simulator discovery, install, arming, preservation and hash, with Human input only if the synthetic fixture cannot be produced without typing. The independent Test / Release reviewer owns the Quality conclusion.

Before Live, bind the exact P1 source commit and independent review, build configuration, Xcode/SDK, App and Extension hashes, designated device UDID/OS, schema and installed data, Full Access, host and field type, diagnostics settings, run ID, raw archive location and one-round stimulus. Rediscover the Simulator and verify the installed payload at the time of freeze; the historical UDID above is a target, not current proof of availability. If any required field is unknown or changes after freeze, stop and issue a new run/binding. The Debug Simulator result can validate instrumentation and comparative shape only; a Release-like Product cost judgment requires a distinct physical-device decision and AUTH.
