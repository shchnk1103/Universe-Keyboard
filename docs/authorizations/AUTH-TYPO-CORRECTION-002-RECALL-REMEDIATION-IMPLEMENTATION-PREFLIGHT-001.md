# Authorization: AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-IMPLEMENTATION-PREFLIGHT-001

## Current Status

| Field | Value |
|---|---|
| **Status** | `consumed` |
| **Assignment** | [`TYPO-CORRECTION-002-RECALL-REMEDIATION-IMPLEMENTATION-PREFLIGHT-001`](../assignments/typo-correction-002-recall-remediation-implementation-preflight-001.md) |
| **Issuer** | Human Product Owner / Product Lead, current Codex task, `2026-09-20 Asia/Shanghai` |
| **Consumer** | Current Codex Executor, bounded pure KeyboardCore preflight |
| **Purpose** | Authorize a non-production KeyboardCore implementation-preflight and its focused contract tests before any production wiring decision. |
| **Product basis** | [`bounded Product decision`](../product-decisions/TYPO-CORRECTION-002-RECALL-REMEDIATION-001-bounded-product-decision.md) at `a42858bf134fa51803b00460a7e3032db6b09ae0` |
| **Source implementation freeze** | `fb27b24ff85c48302e85309e834dbbe9a777871e` |
| **Preflight source commit** | `d0df9a6342d8209b5aa7f9826541d0b430b9da04` |
| **Preflight source tree** | `27ae44bec1b157e391ef1e0b859db3a068e21ba8` |
| **KeyboardCore Package.swift SHA-256** | `1a06a522f12089f3dbb2ad774d13fe9f56193d04` |

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-IMPLEMENTATION-PREFLIGHT-001",
  "record_type": "authorization",
  "title": "Bounded pure KeyboardCore recall implementation-preflight",
  "status": "consumed",
  "updated_at": "2026-09-20T09:43:55+08:00",
  "revalidation_triggers": [
    "source_or_package_identity_changed",
    "origin_main_changed",
    "scope_changed",
    "production_budget_or_default_changed",
    "keyboard_or_rime_path_touched",
    "new_run_requested",
    "authority_revoked"
  ],
  "authorization": {
    "action": "execute_bounded_keyboardcore_recall_implementation_preflight",
    "target_assignment": "TYPO-CORRECTION-002-RECALL-REMEDIATION-IMPLEMENTATION-PREFLIGHT-001",
    "allowed_external_effects": [
      "modify_pure_packages_keyboardcore_preflight_code_only",
      "modify_associated_keyboardcore_contract_tests_only",
      "run_local_keyboardcore_tests",
      "write_preflight_evidence_and_assignment_status"
    ],
    "required_bindings": [
      "Product decision a42858bf134fa51803b00460a7e3032db6b09ae0",
      "source implementation freeze fb27b24ff85c48302e85309e834dbbe9a777871e",
      "pure Packages/KeyboardCore scope",
      "no production controller or RIME wiring",
      "no new device or Simulator Run"
    ],
    "exclusions": [
      "production_12_8_budget_change",
      "production_controller_or_keyboard_extension_wiring",
      "RimeBridge_or_RIME_deployment_or_query",
      "schema_or_vendor_change",
      "local_or_cloud_model",
      "host_text_or_document_context",
      "clipboard_or_network",
      "FakeCandidateProvider_or_old_Ice_directory",
      "Simulator_or_device_capture",
      "new_Run_ID",
      "QA-001",
      "INT-003",
      "paired_performance_or_180_ms",
      "Product_or_Quality_or_Release_Gate",
      "commit_or_push",
      "PR_or_merge",
      "TestFlight_or_Release",
      "F-01_lane",
      "parent_close"
    ],
    "consumption_rule": "Consume before the first code change. Record the exact source/package identity and keep the preflight default-off and non-production. Any scope, source, budget, runtime or evidence change invalidates this Authorization.",
    "issuer_role": "Human Product Owner / Product Lead",
    "issued_at": "2026-09-20T09:33:52+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "consumed",
    "consumed_at": "2026-09-20T09:43:55+08:00",
    "consumed_artifacts": [
      "d0df9a6342d8209b5aa7f9826541d0b430b9da04",
      "tree:27ae44bec1b157e391ef1e0b859db3a068e21ba8",
      "Packages/KeyboardCore/Package.swift:sha256:1a06a522f12089f3dbb2ad774d13fe9f56193d04",
      "baseline:swift test --package-path Packages/KeyboardCore:1129 passed"
    ]
  }
}
```

This Authorization was consumed before the first code change against the
recorded source/package identity. It still does not authorize production
integration, RIME or device evidence. A separate Authorization is required
before any production wiring or publication.
