# Authorization: AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-RIME-VENDOR-MATERIALIZATION-001

## Current Status

| Field | Value |
|---|---|
| Status | `consumed` |
| Assignment | [`TYPO-CORRECTION-002-RECALL-REMEDIATION-RIME-VENDOR-MATERIALIZATION-001`](../assignments/typo-correction-002-recall-remediation-rime-vendor-materialization-001.md) |
| Issuer | Human Product Owner / Product Lead, current Codex task, `2026-09-20 Asia/Shanghai` |
| Consumer | Current Codex executor |
| Purpose | Materialize and verify the exact pinned RIME iOS binary dependency required by the blocked local Xcode preflight |

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-RIME-VENDOR-MATERIALIZATION-001",
  "record_type": "authorization",
  "title": "Bounded RIME vendor materialization for publication preflight",
  "status": "consumed",
  "updated_at": "2026-09-20T11:46:44+08:00",
  "revalidation_triggers": [
    "vendor_manifest_changed",
    "vendor_script_changed",
    "archive_pin_changed",
    "snapshot_manifest_changed",
    "scope_changed",
    "authority_revoked"
  ],
  "authorization": {
    "action": "materialize_and_verify_pinned_rime_vendor_dependency",
    "target": "TYPO-CORRECTION-002-RECALL-REMEDIATION-PUBLICATION-PREFLIGHT-001",
    "scope": "Fetch the immutable archive declared by config/rime-vendor-manifest.env into the current isolated worktree, verify checksum, receipt, inventory and iOS slices, and write one docs-only provenance record.",
    "decision_source": "current task instruction: 授权按照建议继续进行下一步",
    "snapshot": {
      "worktree": "/private/tmp/universe-keyboard-typo-correction-002-recall-preflight-001",
      "branch": "codex/typo-correction-002-recall-preflight-001",
      "head": "d0df9a6342d8209b5aa7f9826541d0b430b9da04",
      "head_tree": "27ae44bec1b157e391ef1e0b859db3a068e21ba8",
      "remediation_manifest_sha256": "c135c78b435fb2278fc734ed354bbf9e396266cdfffe878aef8a887b22c30ac0",
      "vendor_manifest": "config/rime-vendor-manifest.env",
      "vendor_manifest_sha256": "a67cf99046a180c9e648755c793182529f2937f3d0469e3b59d6f63638802804",
      "vendor_script": "scripts/ensure_rime_vendor.sh",
      "vendor_script_sha256": "30dac2bd1166b119430da6860133cf010647f708bca87dc861ddb2349301461a"
    },
    "pin": {
      "version": "rime-vendor-ios-1.16.1-lua.1-octagram.1",
      "archive_sha256": "d17aab9a8b08b5901ab583c143b0a8a03994e36fe092309fd14c5bee31399dd9",
      "archive_url": "https://github.com/shchnk1103/Universe-Keyboard/releases/download/rime-vendor-ios-1.16.1-lua.1-octagram.1/universe-keyboard-rime-vendor-ios-1.16.1-lua.1-octagram.1.zip",
      "framework_count": 12
    },
    "allowed_external_effects": [
      "network_download_of_the_exact_pinned_archive",
      "write_scoped_temporary_archive_and_staging_paths",
      "write_scoped_ignored_vendor_directory_in_this_worktree",
      "write_scoped_vendor_receipt",
      "read_only_structural_and_slice_verification",
      "write_one_docs_only_provenance_record"
    ],
    "required_checks": [
      "archive checksum matches d17aab9a8b08b5901ab583c143b0a8a03994e36fe092309fd14c5bee31399dd9",
      "ensure_rime_vendor verify passes after fetch",
      "receipt version and sha256 match the checked-in manifest",
      "exactly 12 frameworks with valid Info.plist and static-library payloads",
      "iOS device and simulator slice contract matches docs/architecture/rime-artifacts.md",
      "source, config manifest and fetch script remain byte-identical"
    ],
    "exclusions": [
      "Swift_or_test_source_change",
      "Xcode_project_or_package_manifest_change",
      "config_rime_vendor_manifest_change",
      "vendor_script_change",
      "main_checkout_or_other_worktree_write",
      "RIME_schema_or_resource_deployment",
      "runtime_scheduler_or_controller_change",
      "Simulator_or_device_product_capture",
      "QA-001",
      "INT-003",
      "paired_performance_or_180_ms",
      "commit_or_push",
      "PR_or_merge",
      "TestFlight_or_Release",
      "parent_or_child_close"
    ],
    "consumption_rule": "Use only the checked-in immutable pin. Any checksum, inventory, slice or source identity mismatch stops the operation. Materialization does not authorize publication or reuse of the blocked preflight as green.",
    "issuer_role": "Human Product Owner / Product Lead",
    "issued_at": "2026-09-20T11:46:44+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "consumed",
    "consumed_at": "2026-09-20T11:46:44+08:00",
    "consumed_artifacts": [
      "head:d0df9a6342d8209b5aa7f9826541d0b430b9da04",
      "tree:27ae44bec1b157e391ef1e0b859db3a068e21ba8",
      "remediation-manifest:c135c78b435fb2278fc734ed354bbf9e396266cdfffe878aef8a887b22c30ac0",
      "vendor-manifest-sha256:a67cf99046a180c9e648755c793182529f2937f3d0469e3b59d6f63638802804",
      "vendor-script-sha256:30dac2bd1166b119430da6860133cf010647f708bca87dc861ddb2349301461a"
    ]
  }
}
```

本授权不允许修改源码、配置或脚本，不允许 runtime 接线、RIME schema 部署、产品取证、commit、push、PR、merge 或 Release。
