# Authorization: AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-PUBLICATION-PREFLIGHT-ARCHITECTURE-001

## Current Status

| Field | Value |
|---|---|
| **Status** | `consumed` |
| **Assignment** | [`TYPO-CORRECTION-002-RECALL-REMEDIATION-PUBLICATION-PREFLIGHT-001`](../assignments/typo-correction-002-recall-remediation-publication-preflight-001.md) |
| **Issuer** | Human Product Owner / Product Lead, current Codex task, `2026-09-20 Asia/Shanghai` |
| **Consumer** | Independent Architecture reviewer in a separate agent runtime |
| **Purpose** | 对 publication preflight 002 的精确 source/package/vendor 快照及其本地 CI 等价证据做只读架构复核。 |

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-PUBLICATION-PREFLIGHT-ARCHITECTURE-001",
  "record_type": "authorization",
  "title": "Independent Architecture review of recall remediation publication preflight",
  "status": "consumed",
  "updated_at": "2026-09-20T13:32:07+08:00",
  "revalidation_triggers": [
    "source_or_evidence_identity_changed",
    "snapshot_manifest_changed",
    "origin_main_changed",
    "scope_changed",
    "new_run_requested",
    "authority_revoked"
  ],
  "authorization": {
    "action": "independent_architecture_review_recall_remediation_publication_preflight",
    "target_assignment": "TYPO-CORRECTION-002-RECALL-REMEDIATION-PUBLICATION-PREFLIGHT-001",
    "required_bindings": {
      "preflight_id": "TC2-RECALL-PREFLIGHT-20260920-002",
      "worktree": "/private/tmp/universe-keyboard-typo-correction-002-recall-preflight-001",
      "branch": "codex/typo-correction-002-recall-preflight-001",
      "head": "d0df9a6342d8209b5aa7f9826541d0b430b9da04",
      "head_tree": "27ae44bec1b157e391ef1e0b859db3a068e21ba8",
      "package_manifest_sha256": "9ebf33313b560b83634a074dd675211aee9cec13b1d879e9cd4f35fbb94aa764",
      "source_manifest_sha256": "bcbabcb7c7870b90691422ab7fd65f028f348921e64fc39ebaf5db94038d2e3e",
      "vendor_archive_sha256": "d17aab9a8b08b5901ab583c143b0a8a03994e36fe092309fd14c5bee31399dd9",
      "vendor_tree_sha256": "d446b0a4cdd40d42f53359ba8a7677d625ac8461c60ecfe92f90ca73e8df14fd",
      "simulator": "iPhone 17 Pro / iOS 26.0 / 8C2943AC-AC97-432F-ACEE-BE3DA2B9ACB2",
      "evidence": "docs/evidence/typo-correction-002-recall-remediation-publication-preflight-2026-09-20-002.md"
    },
    "review_questions": [
      "精确 source allowlist、package/vendor provenance、HEAD、Simulator 与 evidence receipt 是否一致",
      "本地 CI 等价结果的计数口径、skipped 与 warning residual 是否被正确限定，是否存在把 preflight 写成 runtime 或 Gate 的越界",
      "recall remediation 是否仍保持 KeyboardCore 纯逻辑边界，production default contract、RIME/marked-text/UI/部署边界是否未被改变",
      "test-only fixture 修复是否仍局限于测试 provenance，是否错误放宽 production fail-closed 语义",
      "是否存在需要阻止 Quality review 或 publication decision 的 Architecture finding"
    ],
    "allowed_external_effects": [
      "read_only_source_assignment_evidence_and_git_identity_review",
      "read_only_hash_and_receipt_consistency_check",
      "write_one_architecture_review_record",
      "consume_this_authorization_after_the_review_record_is_complete"
    ],
    "exclusions": [
      "Swift_or_test_source_changes",
      "assignment_or_ACTIVE_WORK_changes_by_reviewer",
      "build_or_test_or_install_or_deploy",
      "new_product_or_device_Run",
      "INT-003",
      "QA-001",
      "paired_performance_or_180_ms",
      "RIME_schema_vendor_or_deployment_changes",
      "Quality_verdict",
      "Product_or_Quality_or_Release_Gate",
      "commit_or_push",
      "PR_or_merge",
      "parent_or_child_close",
      "TestFlight_or_Release"
    ],
    "consumption_rule": "Reviewer must use a separate runtime from the executor, bind every conclusion to the exact snapshot above, preserve UNKNOWN and non-claims, and stop on source/evidence/scope drift. A review receipt does not authorize publication or merge.",
    "issuer_role": "Human Product Owner / Product Lead",
    "issued_at": "2026-09-20T14:00:00+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "consumed",
    "consumed_at": "2026-09-20T13:32:07+08:00",
    "consumed_artifacts": [
      "architecture-review:typo-correction-002-recall-remediation-publication-preflight-architecture-review-2026-09-20.md",
      "verdict:Blocked",
      "finding:P0 source-manifest digest is not reproducible from the declared five-entry serialization rule",
      "individual-file-hashes:consistent",
      "vendor-and-simulator-records:consistent",
      "non-claims:Quality/Product/Release/publication/commit/push/PR/merge/runtime/device/performance"
    ]
  }
}
```

本授权仅允许独立 Architecture 只读复核与一份 review receipt。它不允许重跑测试、修改源码或测试、更新 Assignment/ACTIVE_WORK、commit、push、PR、merge、Product/Quality/Release Gate、设备 Run 或任何 parent/child Close。
