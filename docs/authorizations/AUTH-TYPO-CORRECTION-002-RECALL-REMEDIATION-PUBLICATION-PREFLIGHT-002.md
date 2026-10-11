# Authorization: AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-PUBLICATION-PREFLIGHT-002

## Current Status

| Field | Value |
|---|---|
| **Status** | `consumed` |
| **Assignment** | [`TYPO-CORRECTION-002-RECALL-REMEDIATION-PUBLICATION-PREFLIGHT-001`](../assignments/typo-correction-002-recall-remediation-publication-preflight-001.md) |
| **Issuer** | Human Product Owner / Product Lead, current Codex task, `2026-09-20 Asia/Shanghai` |
| **Consumer** | Current Codex Executor |
| **Purpose** | 在 test-contract/environment reconciliation 完成后，针对 parent 的精确 source allowlist 执行新的本地 CI 等价 publication preflight。 |

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-PUBLICATION-PREFLIGHT-002",
  "record_type": "authorization",
  "title": "Publication preflight revalidation after test-contract reconciliation",
  "status": "consumed",
  "updated_at": "2026-09-20T13:00:00+08:00",
  "revalidation_triggers": [
    "source_or_package_identity_changed",
    "snapshot_manifest_changed",
    "origin_main_changed",
    "scope_changed",
    "new_product_or_device_Run_requested",
    "authority_revoked"
  ],
  "authorization": {
    "action": "run_local_ci_equivalent_publication_preflight_revalidation",
    "target_assignment": "TYPO-CORRECTION-002-RECALL-REMEDIATION-PUBLICATION-PREFLIGHT-001",
    "preflight_id": "TC2-RECALL-PREFLIGHT-20260920-002",
    "scope": "只对冻结 source allowlist 执行 strict Swift lint、KeyboardCore、RimeBridgeTests、Universe Keyboard Debug tests、Release build、vendor verification 与 provenance capture，并写入一份 docs-only evidence receipt。",
    "snapshot": {
      "worktree": "/private/tmp/universe-keyboard-typo-correction-002-recall-preflight-001",
      "branch": "codex/typo-correction-002-recall-preflight-001",
      "head": "d0df9a6342d8209b5aa7f9826541d0b430b9da04",
      "head_tree": "27ae44bec1b157e391ef1e0b859db3a068e21ba8",
      "package_manifest_sha256": "9ebf33313b560b83634a074dd675211aee9cec13b1d879e9cd4f35fbb94aa764",
      "source_manifest_sha256": "bcbabcb7c7870b90691422ab7fd65f028f348921e64fc39ebaf5db94038d2e3e",
      "manifest_rule": "sorted path|sha256 lines for the five listed source/package artifacts, joined with newlines and hashed with SHA-256",
      "simulator": "iPhone 17 Pro / iOS 26.0 / 8C2943AC-AC97-432F-ACEE-BE3DA2B9ACB2",
      "derived_data": "/private/tmp/universe-keyboard-typo-correction-002-recall-preflight-002-app-derived",
      "vendor_archive_sha256": "d17aab9a8b08b5901ab583c143b0a8a03994e36fe092309fd14c5bee31399dd9",
      "vendor_tree_sha256": "d446b0a4cdd40d42f53359ba8a7677d625ac8461c60ecfe92f90ca73e8df14fd"
    },
    "source_allowlist": [
      "Packages/KeyboardCore/Package.swift",
      "Packages/KeyboardCore/Sources/KeyboardCore/ContextualTypoCorrection.swift",
      "Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionRecallPreflight.swift",
      "Packages/KeyboardCore/Tests/KeyboardCoreTests/TypoCorrectionRecallPreflightTests.swift",
      "UniverseKeyboardTests/RimeSettingsStoreTests.swift"
    ],
    "required_checks": [
      "swift-format lint --strict for all four changed Swift files without changing source bytes",
      "swift test --package-path Packages/KeyboardCore",
      "RimeBridgeTests on the bound iPhone 17 Pro iOS 26.0 simulator",
      "Universe Keyboard Debug tests on the bound iPhone 17 Pro iOS 26.0 simulator",
      "Universe Keyboard Release build on the bound iPhone 17 Pro iOS 26.0 simulator",
      "bash scripts/ensure_rime_vendor.sh verify",
      "git diff --check and final source/package/vendor provenance capture"
    ],
    "allowed_external_effects": [
      "read_only_source_git_and_vendor_identity_checks",
      "run_local_swift_format_lint_and_ci_equivalent_checks",
      "write_one_docs_only_publication_preflight_evidence_record",
      "update_parent_preflight_assignment_and_ACTIVE_WORK_mirror",
      "consume_this_authorization_after_the_evidence_receipt_is_complete"
    ],
    "exclusions": [
      "Swift_or_test_source_change",
      "Xcode_project_or_entitlement_or_signing_change",
      "RIME_schema_vendor_or_deployment_change",
      "new_product_or_device_Run",
      "INT-003",
      "QA-001",
      "paired_performance_or_180_ms",
      "Product_or_Quality_or_Release_Gate",
      "commit_or_push",
      "PR_or_merge",
      "parent_or_child_close",
      "TestFlight_or_Release"
    ],
    "consumption_rule": "所有结果必须绑定 preflight_id、HEAD、source manifest、simulator 与 DerivedData。任何 source bytes、package/vendor identity 或 scope 漂移都停止并建立新授权。绿色 preflight 不代表可发布或可合并。",
    "issuer_role": "Human Product Owner / Product Lead",
    "issued_at": "2026-09-20T13:00:00+08:00",
    "expires_at": null,
    "supersedes_ref": "AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-PUBLICATION-PREFLIGHT-001",
    "consumption_state": "consumed",
    "consumed_at": "2026-09-20T13:16:04+08:00",
    "consumed_artifacts": [
      "preflight-id:TC2-RECALL-PREFLIGHT-20260920-002",
      "head:d0df9a6342d8209b5aa7f9826541d0b430b9da04",
      "source-manifest:bcbabcb7c7870b90691422ab7fd65f028f348921e64fc39ebaf5db94038d2e3e",
      "vendor-verify:12 framework artifacts",
      "KeyboardCore:1143 passed, 0 failed",
      "RimeBridgeTests:105 total, 85 passed, 20 skipped, 0 failed",
      "Universe-Keyboard-Debug:388 total, 379 passed, 9 skipped, 0 failed",
      "Universe-Keyboard-Release:BUILD SUCCEEDED",
      "governance-validators:12/12, final-gate pass, KOS trigger paths pass",
      "residual:107 CODE_SIGNING_ALLOWED=NO entitlement warnings",
      "evidence:typo-correction-002-recall-remediation-publication-preflight-2026-09-20-002.md"
    ]
  }
}
```

本授权不允许修改源文件、不创建产品 Run、不部署设备、不提交或发布。107 条 `CODE_SIGNING_ALLOWED=NO` entitlement warning 仍按 residual 记录，不在本轮修改 entitlement。
