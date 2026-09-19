# Authorization: AUTH-TYPO-CORRECTION-002-PARENT-REVALIDATION-001

## Current Status

| Field | Value |
|---|---|
| Status | active — bounded evidence revalidation only |
| Parent Assignment | [`TYPO-CORRECTION-002`](../assignments/typo-correction-002.md) |
| Issuer | Human Product Owner, current Codex task, 2026-09-19 Asia/Shanghai |
| Initial Run ID | `TC2-SIM-20260919-115054-INT003-REVAL-01` |
| Source baseline | `9eb83158e49218c1e8f75dbe7dd9e0390db81409` |
| Execution worktree | `/private/tmp/universe-keyboard-typo-correction-002-provenance-sidecar` |
| Execution branch | `codex/typo-correction-002-provenance-sidecar` |
| F-01 PR | `#139` remains open/draft/unmerged; merge is not a prerequisite for this parent slice |

Human Product Owner instruction in the current task: if F-01 merge is not a
parent prerequisite, return to the parent sidecar-observability, INT-003,
QA-001 and paired-performance evidence flow with a fresh bounded
Authorization/Run ID. The parent Assignment entry criteria do not require
F-01 to be on `main`, so this Authorization does not consume merge authority.

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-TYPO-CORRECTION-002-PARENT-REVALIDATION-001",
  "record_type": "authorization",
  "title": "Bounded parent evidence revalidation for real-RIME sidecar, INT-003, QA-001 and paired performance",
  "status": "active",
  "revalidation_triggers": [
    "source_snapshot_changed",
    "build_or_install_restarted",
    "schema_or_vendor_artifact_changed",
    "device_changed",
    "receipt_identity_changed",
    "scope_changed",
    "authority_revoked",
    "review_finding"
  ],
  "authorization": {
    "action": "collect_bounded_parent_evidence_revalidation",
    "target": "TYPO-CORRECTION-002",
    "artifact_bindings": [
      {"kind": "assignment", "identity": "docs/assignments/typo-correction-002.md"},
      {"kind": "contract", "identity": "docs/TYPO_CORRECTION.md"},
      {"kind": "registry", "identity": "docs/TYPO_BENCHMARK_REGISTRY_V2.md"},
      {"kind": "source_baseline", "identity": "9eb83158e49218c1e8f75dbe7dd9e0390db81409"},
      {"kind": "worktree", "identity": "/private/tmp/universe-keyboard-typo-correction-002-provenance-sidecar"},
      {"kind": "branch", "identity": "codex/typo-correction-002-provenance-sidecar"},
      {"kind": "tracked_worktree_diff_sha256", "identity": "e39c8e7aef52b33db6c441752532786ec3de3cbed6b8cf852d67c0317190a28f"},
      {"kind": "untracked_manifest_sha256", "identity": "a29e5dc6eaf01d66ebe233b3e9f2f76f6548da7c4a699bda20da7b8ffe9c740a"}
    ],
    "scope": "Using the exact current isolated worktree, collect fresh executor-recorded evidence for provenance-bound real-RIME sidecar observability, cancellable INT-003 stale-work behavior, a designated Device Hub QA-001 revalidation attempt, and a controlled paired performance comparison. Each build, reinstall, schema change, device change or restarted capture receives a new Run ID. Existing receipts remain historical and are not reused as new-run identity.",
    "required_evidence": [
      "fresh exact rime_ice runtime provenance receipt and archive/content SHA-256 for every device capture",
      "direct sidecar diagnostic events showing real_rime_sidecar route, result/outcome bounds, live-session identity preservation and receipt binding",
      "INT-003 cadence/cancellation evidence with the observed stimulus boundary; manual cadence below 180 ms is not claimed",
      "QA-001 candidate visibility/selection and interaction-regression observations, with an explicit inconclusive disposition if the target is outside the authorized production recall budget",
      "paired baseline/treatment performance evidence with comparable build, device, schema, warm/cold state and measurement method",
      "raw-artifact hashes, source/build identity and non-claims for every Run Receipt"
    ],
    "exclusions": [
      "merge_f01_pr_139",
      "merge",
      "pull_request_creation_or_update",
      "commit",
      "push",
      "source_code_change",
      "search_budget_change",
      "progressive_recall_production_enablement",
      "semantic_scorer_or_model",
      "rime_schema_change",
      "rime_vendor_or_archive_change",
      "fake_candidate_provider_as_runtime_evidence",
      "old_ice_directory_as_runtime_evidence",
      "physical_device_as_qa_or_performance_substitute",
      "automatic_commit_or_live_composition_mutation",
      "product_gate",
      "quality_gate",
      "testflight",
      "release",
      "assignment_closure"
    ],
    "stop_conditions": [
      "exact source/build/schema/device/receipt identity cannot be established",
      "App Group or direct sidecar observability is unavailable",
      "a capture would require the fallback provider or an old Ice directory",
      "a candidate result would require mutating the live composition",
      "the designated simulator is unavailable for QA-001 or paired performance",
      "the current production recall boundary is being changed without a separate Product/Architecture authorization",
      "a restarted capture is attempted without allocating a new Run ID"
    ],
    "run_id_policy": {
      "initial": "TC2-SIM-20260919-115054-INT003-REVAL-01",
      "qa001": "allocate a fresh TC2-SIM-20260919-<HHMMSS>-QA001-REVAL-<n> at capture start",
      "performance": "allocate a fresh TC2-PERF-20260919-<HHMMSS>-REVAL-<n> at paired capture start",
      "restart": "allocate a new Run ID before any restarted build, reinstall, schema change or capture"
    },
    "issuer_role": "Human Product Owner",
    "decision_source": "current task instruction: 不需要先 merge 时，回到 parent 的 sidecar observability、INT-003、QA-001 和性能证据流程，并使用新的 bounded Authorization/Run ID",
    "issued_at": "2026-09-19T11:50:54+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "active"
  }
}
```

## Execution boundary

This record authorizes evidence collection against the already-present dirty
isolated worktree only. It does not authorize making the current production
12-state/eight-hypothesis path larger. The canonical
`wimenjintianquhongyuan` → `womenjintianqugongyuan` recall result remains a
progressive-recall observation unless a separate Product/Architecture decision
authorizes production use and supplies real-RIME semantic and performance
evidence.

The designated Device Hub target remains the iPhone 17 Pro Max iOS 27
Simulator (`06C5BC3E-7599-4761-A1A2-71DAEA991474`). A physical device may not
replace it for QA-001 or paired performance under this record.

No gate is closed by issuing this Authorization. Completion requires fresh Run
Receipts and independent Quality/Product review; it does not itself authorize
merge, Release or Assignment closure.
