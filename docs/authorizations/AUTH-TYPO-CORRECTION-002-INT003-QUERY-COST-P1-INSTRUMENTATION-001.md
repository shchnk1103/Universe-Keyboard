# Authorization: INT-003 query-cost P1 instrumentation 001

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-P1-INSTRUMENTATION-001",
  "record_type": "authorization",
  "title": "P1 content-free query-cost instrumentation on a frozen source baseline",
  "status": "active",
  "updated_at": "2026-09-27T17:13:00+08:00",
  "revalidation_triggers": [
    "p1_source_manifest_sha256_changes_from_d8f7aa17906bfc1d6d9e1c9b39135fb71be80a94b210c81916095940a54fff5f",
    "field_semantics_or_allowed_files_change",
    "independent_Architecture_review_finds_boundary_change",
    "P1_execution_environment_or_executor_changes",
    "parent_or_Product_residual_changes"
  ],
  "authorization": {
    "action": "instrument_int003_query_cost_p1",
    "target": "TYPO-CORRECTION-002-INT003-QUERY-COST-MEASUREMENT-001",
    "scope": "In the isolated worktree, design and after independent Architecture field review implement content-free Stage 1/2, zero/nonzero and sidecar-readiness query-cost signals on the installed correction-query route; validate the diagnostic semantics and observer overhead, then publish a draft source PR",
    "exclusions": [
      "consume_P0_or_prior_markers_AUTH_as_execution_authority",
      "execute_source_change_before_Architecture_field_review",
      "P2_Simulator_or_physical_capture",
      "raw_input_candidate_host_text_or_fingerprint_logging",
      "synchronous_hot_path_persistence_or_second_RIME_route",
      "runtime_debounce_or_query_budget_change",
      "merge_without_separate_Human_authorization",
      "Product_or_QA001_Gate_parent_Close_TestFlight_Release_ADR_Accept",
      "RimeRuntimeProvenance_restore"
    ],
    "issuer_role": "Human Product Owner acting as Product Lead",
    "decision_source": "Human 2026-09-26 Asia/Shanghai explicitly authorized PR 179 merge and required separate P1 instrumentation and P2 capture execution authority and evidence environment; earlier Human authorized continuing the query-cost Assignment under KOS. Human 2026-09-27 Asia/Shanghai authorized completion of the independent Architecture review, P1 baseline update, and subsequent work under the separate P1/P2 AUTHs",
    "issued_at": "2026-09-26T23:16:00+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "unconsumed",
    "artifact_bindings": [
      {"kind": "source_baseline", "identity": "8e4ea0f1777f1175141731797afeee5ebd964c96"},
      {"kind": "source_manifest", "identity": "docs/evidence/typo-correction-002-int003-query-cost-p1-arch-source-freeze-r2.json"},
      {"kind": "source_manifest_sha256", "identity": "d8f7aa17906bfc1d6d9e1c9b39135fb71be80a94b210c81916095940a54fff5f"},
      {"kind": "source_rebind_reason", "identity": "PR_182_advanced_main_after_round_1;DiagnosticEvent_added_keychain_access_denied_without_schema_bump_and_corresponding_test;28_paths_refrozen_at_latest_main_before_P1_consumption"},
      {"kind": "architecture_review_lane", "identity": "TYPO-CORRECTION-002-INT003-QUERY-COST-P1-ARCH-001/round-2"},
      {"kind": "architecture_review_packet", "identity": "docs/reviews/typo-correction-002-int003-query-cost-p1-architecture-review-packet-r1.md"},
      {"kind": "architecture_review_round_1_result_sha256", "identity": "e0d0bc7677fa79b775a329e83b723e50cc088938f9156019164af37a91108ee1"},
      {"kind": "architecture_review_round_1_usage_sha256", "identity": "6f048595c21fcc9f28690e759fce363e7aa322dee9c1fb71abde2bd5b7b93a61"},
      {"kind": "architecture_review_round_2_packet", "identity": "docs/reviews/typo-correction-002-int003-query-cost-p1-architecture-review-packet-r2.md"},
      {"kind": "measurement_plan", "identity": "docs/plans/typo-correction-002-int003-query-cost-measurement-001.md"},
      {"kind": "field_review_packet", "identity": "docs/plans/typo-correction-002-int003-query-cost-p1-field-review-001.md"},
      {"kind": "execution_environment", "identity": "isolated_macOS_worktree;/private/tmp/universe-keyboard-int003-query-density-diagnosis-20260925;Debug_HF_only_for_journal_semantics;no_device_capture_under_P1"}
    ]
  }
}
```

## Execution boundary

| Field | Binding |
|---|---|
| Status | **Active, unconsumed**. Human issued P1 authority; the Architecture field review is an entry condition, not a substitute for consumption. |
| Executor | Codex current task in the isolated worktree above; source baseline `8e4ea0f1777f1175141731797afeee5ebd964c96` with the bound 28-file manifest. Revalidate if any bound source blob changes before execution. |
| Domain owner | Input Intelligence Maintainer; KeyboardCore, Keyboard UI and RimeBridge ownership are reviewed at their existing boundaries. |
| Architecture reviewer | Independent Architecture & Knowledge Steward for ADR 0027 field allowlist, ADR 0004 session route and privacy. Review [field packet](../plans/typo-correction-002-int003-query-cost-p1-field-review-001.md) before source edits. |
| Quality reviewer | Independent Test / Release lane after implementation evidence; P1 author does not self-declare Quality. |
| Human dependency | Product Lead issued this P1 scope; no Human typing or Simulator interaction in P1. |
| Evidence environment | Frozen source SHA and isolated macOS worktree; local format/build evidence identifies Xcode/Swift version and exact source tip. Debug high-fidelity journal can validate semantics only after P2 separately consumes its AUTH. |

Architecture round 1 (`docs/reviews/typo-correction-002-int003-query-cost-p1-architecture-review-r1.md`, SHA-256 `e0d0bc7677fa79b775a329e83b723e50cc088938f9156019164af37a91108ee1`) returned **Blocker** for the undecided DiagnosticEvent compatibility protocol and query-event cardinality. PR #182 then advanced main and added the finite `keychain_access_denied` RIME sync failure code and test without a schema bump. The 28-file P1 source baseline was refreshed to `8e4ea0f1777f1175141731797afeee5ebd964c96`; the exact manifest is bound above. P1 remains Active/unconsumed; do not edit Swift/Objective-C or consume this AUTH until the exact revised round-2 packet receives independent approval. The round-2 design keeps the existing allowed source paths and P1 scope; any scope/allowed-path/product-budget change requires Human reauthorization.

Allowed source paths after review: `Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionRecallMaterial.swift`, `TypoCorrectionSidecarOwner.swift`, `TypoCorrectionCandidateQuery.swift`, `DiagnosticEvent.swift`; `Keyboard/Controllers/TypoCorrectionRecallCoordinator.swift`; `Packages/RimeBridge/Sources/RimeBridge/RimeEngineImpl+CorrectionQuery.swift`, `Packages/RimeBridge/Sources/RimeBridgeObjC/RimeSessionManager.m` and its public header. Focused tests under the directly affected KeyboardCore/RimeBridge/Keyboard test targets and directly affected docs are allowed. Any broader path requires revalidation.

Consumption requires the independent field review to approve the finite field meanings, zero-result readiness distinction and hot-path overhead. Record `consumed_at`, consumer, reviewed baseline and evidence path **before** the first source edit. This AUTH does not authorize P2 or a Product cost verdict. Swift format strict lint is mandatory before any Swift commit or push. A source PR stays Draft until applicable local quality gates and hosted evidence are green; merging requires another Human instruction.
