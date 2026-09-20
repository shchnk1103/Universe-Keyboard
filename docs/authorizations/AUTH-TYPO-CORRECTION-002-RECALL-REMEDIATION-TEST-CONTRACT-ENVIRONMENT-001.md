# Authorization: AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-TEST-CONTRACT-ENVIRONMENT-001

## Current Status

| Field | Value |
|---|---|
| **Status** | `consumed` |
| **Assignment** | [`TYPO-CORRECTION-002-RECALL-REMEDIATION-TEST-CONTRACT-ENVIRONMENT-001`](../assignments/typo-correction-002-recall-remediation-test-contract-environment-001.md) |
| **Issuer** | Human Product Owner / Product Lead, current Codex task, `2026-09-20 Asia/Shanghai` |
| **Consumer** | Current Codex Executor, isolated test-contract/environment remediation lane |
| **Purpose** | Diagnose and, only when confirmed, repair the test-only deployment fixture contract or test invocation environment that blocks the App + Keyboard Debug gate. |
| **Parent evidence** | [`publication preflight evidence`](../evidence/typo-correction-002-recall-remediation-publication-preflight-2026-09-20.md) |
| **Source freeze** | `d0df9a6342d8209b5aa7f9826541d0b430b9da04` / tree `27ae44bec1b157e391ef1e0b859db3a068e21ba8` |

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-TEST-CONTRACT-ENVIRONMENT-001",
  "record_type": "authorization",
  "title": "Bounded test-contract and App Group test-environment remediation",
  "status": "consumed",
  "updated_at": "2026-09-20",
  "revalidation_triggers": [
    "source_or_package_identity_changed",
    "origin_main_changed",
    "scope_changed",
    "production_contract_changed",
    "entitlement_or_signing_configuration_change_requested",
    "new_Run_requested",
    "authority_revoked"
  ],
  "authorization": {
    "action": "execute_bounded_test_contract_environment_remediation",
    "target_assignment": "TYPO-CORRECTION-002-RECALL-REMEDIATION-TEST-CONTRACT-ENVIRONMENT-001",
    "allowed_external_effects": [
      "read_failing_RimeSettingsStoreTests_and_provenance_contract",
      "read_test_invocation_and_App_Group_entitlement_diagnostics",
      "modify_test_only_fixture_or_test_source_if_contract_mismatch_is_confirmed",
      "run_App_Keyboard_Debug_tests_with_isolated_DerivedData_and_caches",
      "write_bounded_assignment_and_evidence_records"
    ],
    "required_bindings": [
      "publication preflight evidence dated 2026-09-20",
      "RimeSettingsStoreTests blob 55bd3e697da246ec2455deebb4c63dc364b40baa",
      "production librimeVersion fail-closed contract remains unchanged",
      "test-only scope",
      "no checked-in entitlement or signing configuration changes"
    ],
    "exclusions": [
      "production_SchemaManager_or_runtime_behavior",
      "KeyboardCore_or_RimeBridge_source_changes",
      "RIME_schema_vendor_or_deployment_changes",
      "checked_in_App_Group_entitlement_or_Xcode_signing_configuration_changes",
      "production_controller_or_keyboard_extension_wiring",
      "FakeCandidateProvider_or_old_Ice_directory",
      "clipboard_pasteboard_host_documentContext_or_network",
      "Simulator_or_device_product_Run",
      "INT-003",
      "QA-001",
      "paired_performance_or_180_ms",
      "Product_or_Quality_or_Release_Gate",
      "commit_or_push",
      "PR_or_merge",
      "TestFlight_or_Release",
      "parent_or_publication_preflight_close"
    ],
    "consumption_rule": "Consumed after read-only diagnosis confirmed the test fixture contract mismatch. Any production, entitlement, signing, runtime, RIME, device, evidence scope or publication change invalidates this Authorization.",
    "issuer_role": "Human Product Owner / Product Lead",
    "issued_at": "2026-09-20",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "consumed",
    "consumed_at": "2026-09-20",
    "consumed_artifacts": [
      "d0df9a6342d8209b5aa7f9826541d0b430b9da04",
      "tree:27ae44bec1b157e391ef1e0b859db3a068e21ba8",
      "UniverseKeyboardTests/RimeSettingsStoreTests.swift:55bd3e697da246ec2455deebb4c63dc364b40baa",
      "diagnosis:successful test fixture omitted librimeVersion and builtin runtimeSmokePassed; CODE_SIGNING_ALLOWED=NO App Group warning retained as separate residual",
      "UniverseKeyboardTests/RimeSettingsStoreTests.swift:git-blob:45c571adff9169331b8e43df7a900f5b8d613fa9",
      "UniverseKeyboardTests/RimeSettingsStoreTests.swift:file-sha256:788d6fd0fc814a034a61873cda6ba67432e21042f7953c8849212f350e8066f9",
      "App+Keyboard Debug:388 total, 379 passed, 0 failed, 9 skipped",
      "reconciliation:outer XcodeBuildMCP summary said 389 discovered; authoritative xcresult and raw XCTest output say 388"
    ]
  }
}
```

This Authorization was consumed after the bounded diagnosis. It does not authorize publication or weaken the production provenance requirement. If the only viable fix requires checked-in entitlement/signing changes, stop and request a new Authorization before editing those files.
