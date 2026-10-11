# Authorization: AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-PUBLICATION-PREFLIGHT-MANIFEST-RECONCILIATION-001

## Current Status

| Field | Value |
|---|---|
| **Status** | `consumed` |
| **Assignment** | [`TYPO-CORRECTION-002-RECALL-REMEDIATION-PUBLICATION-PREFLIGHT-001`](../assignments/typo-correction-002-recall-remediation-publication-preflight-001.md) |
| **Issuer** | Human Product Owner / Product Lead, current Codex task, `2026-09-20 Asia/Shanghai` |
| **Consumer** | Current Codex Coordinator / Executor |
| **Purpose** | 在不改变源码、测试、vendor 或运行证据的前提下，修正 publication preflight 002 的 source-manifest 序列化与 provenance 对账。 |

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-PUBLICATION-PREFLIGHT-MANIFEST-RECONCILIATION-001",
  "record_type": "authorization",
  "title": "Docs-only reconciliation of the publication preflight source manifest",
  "status": "consumed",
  "updated_at": "2026-09-20T13:42:23+08:00",
  "revalidation_triggers": [
    "source_or_package_identity_changed",
    "snapshot_manifest_changed",
    "origin_main_changed",
    "scope_changed",
    "new_run_requested",
    "authority_revoked"
  ],
  "authorization": {
    "action": "docs_only_reconcile_publication_preflight_source_manifest",
    "target_assignment": "TYPO-CORRECTION-002-RECALL-REMEDIATION-PUBLICATION-PREFLIGHT-001",
    "source_snapshot": {
      "preflight_id": "TC2-RECALL-PREFLIGHT-20260920-002",
      "worktree": "/private/tmp/universe-keyboard-typo-correction-002-recall-preflight-001",
      "branch": "codex/typo-correction-002-recall-preflight-001",
      "head": "d0df9a6342d8209b5aa7f9826541d0b430b9da04",
      "head_tree": "27ae44bec1b157e391ef1e0b859db3a068e21ba8",
      "package_manifest_sha256": "9ebf33313b560b83634a074dd675211aee9cec13b1d879e9cd4f35fbb94aa764",
      "vendor_archive_sha256": "d17aab9a8b08b5901ab583c143b0a8a03994e36fe092309fd14c5bee31399dd9",
      "vendor_tree_sha256": "d446b0a4cdd40d42f53359ba8a7677d625ac8461c60ecfe92f90ca73e8df14fd"
    },
    "old_manifest": {
      "sha256": "bcbabcb7c7870b90691422ab7fd65f028f348921e64fc39ebaf5db94038d2e3e",
      "status": "superseded_not_reproducible",
      "reason": "The previously declared sorted path|sha256 aggregation does not reproduce this digest, with or without a terminal LF."
    },
    "canonical_manifest": {
      "path": "docs/evidence/typo-correction-002-recall-remediation-publication-preflight-source-manifest-2026-09-20-002.txt",
      "encoding": "UTF-8",
      "serialization": "Exactly five sorted path|sha256 lines, LF (0x0A) after every line including the final line, no code fence or extra blank line.",
      "sha256": "709370f83f819a885f95b6224a763d59712eeac93f164939c03ae31627a9f207",
      "entries": [
        "Packages/KeyboardCore/Package.swift|9ebf33313b560b83634a074dd675211aee9cec13b1d879e9cd4f35fbb94aa764",
        "Packages/KeyboardCore/Sources/KeyboardCore/ContextualTypoCorrection.swift|9fb3fdc9c4cb809cf08b098bd882226e74a1a74eef23a043bba261d017216b57",
        "Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionRecallPreflight.swift|e05488596a044e199b30fb3f262f72877ff31b172ba98638091b44ce7b030c9d",
        "Packages/KeyboardCore/Tests/KeyboardCoreTests/TypoCorrectionRecallPreflightTests.swift|9147004b425c19f2326292358f13e6db90c4d3969f2e4fb758841119991f3fd6",
        "UniverseKeyboardTests/RimeSettingsStoreTests.swift|788d6fd0fc814a034a61873cda6ba67432e21042f7953c8849212f350e8066f9"
      ]
    },
    "allowed_external_effects": [
      "read_only_recompute_of_the_five_bound_file_hashes",
      "write_one_canonical_manifest_text_artifact",
      "write_one_docs_only_reconciliation_evidence_receipt",
      "update_target_assignment_and_ACTIVE_WORK_mirror",
      "consume_this_authorization_after_all_receipts_are_consistent"
    ],
    "exclusions": [
      "Swift_or_test_source_changes",
      "Xcode_project_or_entitlement_or_signing_changes",
      "RIME_schema_vendor_or_deployment_changes",
      "build_or_test_or_install_or_deploy",
      "new_product_or_device_Run",
      "INT-003",
      "QA-001",
      "paired_performance_or_180_ms",
      "Quality_or_Product_or_Release_Gate",
      "commit_or_push",
      "PR_or_merge",
      "TestFlight_or_Release",
      "parent_or_child_close"
    ],
    "consumption_rule": "The canonical manifest must hash exactly to 709370...9f207 under the declared UTF-8/LF serialization. The old bcbabcb7... digest remains historical and superseded; it must not be silently edited in the consumed historical receipt. Any source/package/vendor drift stops this reconciliation and requires a new authorization.",
    "issuer_role": "Human Product Owner / Product Lead",
    "issued_at": "2026-09-20T13:37:29+08:00",
    "expires_at": null,
    "supersedes_ref": "AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-PUBLICATION-PREFLIGHT-ARCHITECTURE-001",
    "consumption_state": "consumed",
    "consumed_at": "2026-09-20T13:42:23+08:00",
    "consumed_artifacts": [
      "canonical-manifest:docs/evidence/typo-correction-002-recall-remediation-publication-preflight-source-manifest-2026-09-20-002.txt",
      "canonical-manifest-sha256:709370f83f819a885f95b6224a763d59712eeac93f164939c03ae31627a9f207",
      "reconciliation-evidence:typo-correction-002-recall-remediation-publication-preflight-manifest-reconciliation-2026-09-20.md",
      "old-manifest:bcbabcb7... superseded_not_reproducible",
      "source-bytes:unchanged",
      "run-id:none",
      "next:fresh-independent-architecture-and-quality-review"
    ]
  }
}
```

本授权只允许修正 manifest 序列化、生成 docs-only reconciliation receipt，并同步状态镜像。它不允许修改源码或测试、不允许重跑 CI 或建立新的 Run ID，也不授权 Quality/Product/Release、commit、push、PR、merge 或关闭任何 Assignment。
