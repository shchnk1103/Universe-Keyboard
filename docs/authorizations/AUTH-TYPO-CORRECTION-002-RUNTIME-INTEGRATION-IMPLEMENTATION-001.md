# Authorization: AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-001

## Current Status

| Field | Value |
|---|---|
| Status | `consumed` — Human confirmed live; Grok implemented the bounded runtime slice |
| Assignment | [`TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-001`](../assignments/typo-correction-002-runtime-integration-implementation-001.md) |
| Issuer | Human Product Owner / Product Lead, current Grok session, `2026-09-21 Asia/Shanghai` |
| Consumer | Grok, only after Human confirmation that this receipt is live |
| Exact baseline/tree | `4d1050f4b677494e06448cb40a83ef2da46d7b27` / `5f864a6f6f139810ed59c7e00ab6c33caad7e500` |
| Exact pure-Core checkpoint diff | `8bb105c5381feb43fc41ec168fd239fd7c864cc0efa739cae3976beb685ebbab` |

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-001",
  "record_type": "authorization",
  "title": "Bounded controller and sidecar second-stage recall runtime implementation",
  "status": "consumed",
  "updated_at": "2026-09-21T22:14:42+08:00",
  "revalidation_triggers": [
    "source_or_checkpoint_identity_changed",
    "coverage_predicate_or_budget_changed",
    "adapter_api_or_owner_boundary_changed",
    "allowed_path_or_test_scope_changed",
    "diagnostics_or_privacy_scope_changed",
    "human_live_confirmation_absent_or_revoked",
    "authority_revoked"
  ],
  "authorization": {
    "action": "implement_controller_sidecar_second_stage_recall_runtime",
    "target": "TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-001",
    "scope": "After Human Product Owner confirms this receipt is live, copy the exact uncommitted pure-Core checkpoint into a new Grok implementation worktree and implement the reviewed controller-owned second-stage recall contract: one MainActor lifecycle, one TypoCorrectionSidecarOwner adapter over the installed query facade, yielded one-query turns, recallEpoch fences, pinned 8/8/3/4 budgets, coverage-deficit abstain, one conditional Core apply, and path-required tests/format. Do not modify the original checkpoint worktree. Do not add diagnostics receipts. Do not capture, publish or close Gates.",
    "activation_gate": "Human Product Owner must explicitly confirm this Authorization is live before Grok may consume it or edit Swift.",
    "allowed_paths": [
      "Keyboard/Controllers/KeyboardViewController.swift",
      "Keyboard/Controllers/KeyboardViewController+TypoCorrection.swift",
      "Keyboard/Controllers/KeyboardViewController+Bootstrap.swift",
      "Keyboard/Controllers/TypoCorrectionRecallCoordinator.swift",
      "Packages/KeyboardCore/Sources/KeyboardCore/ContextualTypoCorrection.swift",
      "Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+TypoCorrection.swift",
      "Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionCandidateQuery.swift",
      "Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionRecallPreflight.swift",
      "Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionSidecarOwner.swift",
      "Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionRecallMaterial.swift",
      "Packages/KeyboardCore/Tests/KeyboardCoreTests/TypoCorrectionRecallPreflightTests.swift",
      "Packages/KeyboardCore/Tests/KeyboardCoreTests/TypoCorrectionRuntimeIntegrationTests.swift",
      "Packages/RimeBridge/Sources/RimeBridge/RimeEngineImpl+CorrectionQuery.swift",
      "Packages/RimeBridge/Sources/RimeBridge/TypoCorrectionSidecarOwnerAdapters.swift",
      "Packages/RimeBridge/Tests/RimeBridgeTests/TypoCorrectionSidecarOwnerAdapterTests.swift",
      "KeyboardTests/TypoCorrectionRecallRuntimeTests.swift",
      "docs/assignments/typo-correction-002-runtime-integration-implementation-001.md",
      "docs/authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-001.md",
      "docs/evidence/typo-correction-002-runtime-integration-implementation-001.md",
      "docs/ACTIVE_WORK.md"
    ],
    "path_constraints": [
      "KeyboardViewController.swift: stored coordinator / recallEpoch properties only",
      "KeyboardViewController+Bootstrap.swift: assemble TypoCorrectionSidecarOwner onto existing typoCorrectionCandidateQuery install and responsive-rebuild sites only",
      "original preflight worktree remains read-only"
    ],
    "required_evidence": [
      "Human confirmation that this Authorization is live",
      "new worktree path plus re-verified HEAD/tree/diff SHA-256 before Swift edits",
      "strict Swift format/lint results for every changed Swift file",
      "focused and path-required KeyboardCore, RimeBridgeTests and App+Keyboard results",
      "proof of adapter no-bypass on default, MainActor-responsive and thread-affine routes",
      "proof of invalidate-first recallEpoch, yielded one-query turns, pre-query and post-return fences, coverage-deficit abstain and display no-op",
      "explicit non-claims for RIME capture, QA-001, INT-003, paired performance, publication and Gates"
    ],
    "exclusions": [
      "original_checkpoint_reset_or_commit",
      "production_12_8_first_stage_change",
      "always_on_60_64_first_stage_wiring",
      "diagnostics_operation_receipt_or_DEBUG_trace_reuse",
      "TextInputClient_insertText_setMarkedText_pasteboard_live_RIME_selection_or_direct_candidate_bar_mutation",
      "Task_detached_raw_engine_cast_second_RIME_session_or_parallel_query_lane",
      "FakeCandidateProvider_or_old_Ice_or_model_evidence",
      "RIME_query_or_deployment_as_product_proof",
      "Simulator_or_device_capture",
      "new_Run_ID",
      "QA-001",
      "INT-003",
      "paired_performance_or_180_ms",
      "commit_or_push",
      "PR_or_merge",
      "TestFlight_or_Release",
      "Product_Quality_or_Release_Gate",
      "Assignment_close"
    ],
    "stop_conditions": [
      "Human has not confirmed this receipt is live",
      "checkpoint identity mismatch",
      "required change exceeds allowed_paths or path_constraints",
      "implementation needs diagnostics, capture, publication or a second commit path",
      "tests require live RIME or host/clipboard content"
    ],
    "issuer_role": "Human Product Owner / Product Lead",
    "decision_source": "PD-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-001; current Grok session Product answers on 2026-09-21 Asia/Shanghai",
    "issued_at": "2026-09-21T21:52:00+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "consumed",
    "consumed_at": "2026-09-21T22:14:42+08:00",
    "consumed_by": "Grok",
    "consumption_record": "docs/evidence/typo-correction-002-runtime-integration-implementation-001.md"
  }
}
```

Human Product Owner confirmed this receipt live. Grok consumed it for the
bounded implementation snapshot recorded in the matching evidence file. It
does not authorize commit, capture, Gate close or Architecture/Quality
verdict.
