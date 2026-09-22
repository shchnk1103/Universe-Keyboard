# Authorization: AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-CODEX-EXECUTION-001

## Current Status

| Field | Value |
|---|---|
| Status | `consumed` — current Codex task verified and copied the exact input snapshot into a new isolated hardening worktree |
| Assignment | [`TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-001`](../assignments/typo-correction-002-runtime-integration-hardening-001.md) |
| Issuer | Human Product Owner / Product Lead, current Codex task, `2026-09-22 Asia/Shanghai` |
| Consumer | Current Codex task only |
| Supersedes | [`Grok execution receipt`](AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-001.md), which remains unconsumed and must not be reused |

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-CODEX-EXECUTION-001",
  "record_type": "authorization",
  "title": "Codex execution of bounded controller-sidecar runtime-integration hardening",
  "status": "consumed",
  "updated_at": "2026-09-22T09:19:12+08:00",
  "revalidation_triggers": [
    "source_snapshot_or_checkpoint_identity_changed",
    "accepted_residual_or_allowed_path_changed",
    "adapter_owner_or_recall_lifecycle_changed",
    "test_scope_or_result_changed",
    "runtime_capture_or_publication_requested",
    "authority_revoked"
  ],
  "authorization": {
    "action": "remediate_bounded_controller_sidecar_runtime_integration_residuals",
    "target": "TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-001",
    "scope": "In a new isolated Codex worktree copied only after exact source-snapshot verification, remediate Q-01 and the accepted F-01/F-03 residuals: remove the ActorIsolatedCall warning; make empty and budget-stop outcomes structural display no-ops; invalidate recallEpoch before the named page/install/mode entry points; and prevent the legacy hot path from writing state.typoCorrection while a recall operation is current. Add only focused tests needed to prove those contracts. F-02 adapter routes may receive only tightly coupled no-bypass contract coverage if required by the changed lifecycle; no adapter redesign. Preserve the original implementation worktree and pure-Core checkpoint unchanged.",
    "activation_gate": "Before any source edit, current Codex task must re-verify every binding below, record the new worktree path, and consume this receipt in execution evidence. Any mismatch stops the slice and returns it to Product Lead.",
    "artifact_bindings": [
      {"kind": "git_head", "identity": "4d1050f4b677494e06448cb40a83ef2da46d7b27"},
      {"kind": "git_tree", "identity": "5f864a6f6f139810ed59c7e00ab6c33caad7e500"},
      {"kind": "tracked_diff_sha256", "identity": "d1366181e0436242211aa496934792e90a6ab1b0454608f0e1c3dd5a17ef4c1b"},
      {"kind": "changed_file_manifest_sha256", "identity": "4b701835f070e2c337fd2d3b76b67813e7e5722bdaa7db1b82faa7e00d2c891e"},
      {"kind": "original_pure_core_diff_sha256", "identity": "8bb105c5381feb43fc41ec168fd239fd7c864cc0efa739cae3976beb685ebbab"}
    ],
    "allowed_paths": [
      "Keyboard/Controllers/KeyboardViewController.swift",
      "Keyboard/Controllers/KeyboardViewController+Bootstrap.swift",
      "Keyboard/Controllers/KeyboardViewController+TypoCorrection.swift",
      "Keyboard/Controllers/TypoCorrectionRecallCoordinator.swift",
      "Packages/KeyboardCore/Sources/KeyboardCore/ContextualTypoCorrection.swift",
      "Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+TypoCorrection.swift",
      "Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionRecallMaterial.swift",
      "Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionRecallPreflight.swift",
      "Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionSidecarOwner.swift",
      "Packages/RimeBridge/Sources/RimeBridge/TypoCorrectionSidecarOwnerAdapters.swift",
      "KeyboardTests/TypoCorrectionRecallRuntimeTests.swift",
      "Packages/KeyboardCore/Tests/KeyboardCoreTests/TypoCorrectionRecallPreflightTests.swift",
      "Packages/KeyboardCore/Tests/KeyboardCoreTests/TypoCorrectionRuntimeIntegrationTests.swift",
      "Packages/RimeBridge/Tests/RimeBridgeTests/TypoCorrectionSidecarOwnerAdapterTests.swift",
      "docs/authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-CODEX-EXECUTION-001.md",
      "docs/assignments/typo-correction-002-runtime-integration-hardening-001.md",
      "docs/evidence/typo-correction-002-runtime-integration-hardening-001.md",
      "docs/ACTIVE_WORK.md"
    ],
    "path_constraints": [
      "Do not alter the existing production first-stage 12/8 behavior or make 60/64 always-on.",
      "Do not add another composition, host commit, RIME session, raw-engine route, detached task, parallel query lane, candidate-bar mutation path, or persistent hot-path write.",
      "The legacy writer may be guarded or delegated, but state.typoCorrection retains exactly one effective writer while a recall operation is current.",
      "Empty, stale, cancelled and budget-stop outcomes must stop before candidate-bar refresh; tests must distinguish no display mutation from merely zero results.",
      "F-02 remains bounded to the existing adapter shape; do not broaden it into a route redesign.",
      "The original implementation worktree and original pure-Core checkpoint are read-only preservation targets."
    ],
    "required_evidence": [
      "re-verified source HEAD, tree, tracked diff and all 15 changed-file manifest entries before the copy",
      "new isolated hardening worktree path and proof neither preservation worktree changed",
      "strict Swift format and lint for each changed Swift file",
      "focused negative tests for empty/budget-stop display no-op, invalidate-first entry points and legacy-writer exclusion",
      "path-required KeyboardCore, RimeBridgeTests and App+Keyboard verification appropriate to actual changed paths",
      "Q-01 warning disposition under the strict build/test configuration",
      "explicit residual/non-claim inventory for independent Architecture and Quality review"
    ],
    "exclusions": [
      "FakeCandidateProvider_or_old_Ice_as_real_RIME_fixture",
      "RIME_schema_vendor_or_deployment_change",
      "real_RIME_query_or_product_candidate_proof",
      "Simulator_or_device_capture",
      "new_Run_ID",
      "same_package_same_phrase_QA-001_retry",
      "INT-003",
      "paired_performance_or_180_ms",
      "diagnostics_retention_or_operation_receipt_change",
      "commit_or_push",
      "PR_or_merge",
      "TestFlight_or_Release",
      "Product_Quality_or_Release_Gate",
      "parent_or_child_Assignment_close"
    ],
    "stop_conditions": [
      "any source binding or preservation-worktree identity mismatches",
      "a fix requires a path outside allowed_paths or a second input/commit/query route",
      "the ActorIsolatedCall warning cannot be resolved without weakening Swift concurrency checks",
      "proof requires real RIME, host text, clipboard, capture, publication or a new Run ID",
      "the required tests fail or identify an unbounded new residual"
    ],
    "issuer_role": "Human Product Owner / Product Lead",
    "decision_source": "current task instruction: 授权由你来按照你的建议继续进行下一步; executor reassignment AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-EXECUTOR-REASSIGNMENT-001",
    "issued_at": "2026-09-22T09:19:12+08:00",
    "expires_at": null,
    "supersedes_ref": "AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-001",
    "consumption_state": "consumed",
    "consumed_at": "2026-09-22T09:19:12+08:00",
    "consumed_by": "Current Codex task",
    "consumption_record": "docs/evidence/typo-correction-002-runtime-integration-hardening-001.md"
  }
}
```

This non-reusable receipt was consumed only after the bound snapshot copied
exactly into the new isolated worktree. It does not authorize a real RIME run,
publication, or a user-visible recovery claim.
