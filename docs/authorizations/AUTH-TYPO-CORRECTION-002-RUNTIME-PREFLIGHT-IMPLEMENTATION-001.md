# Authorization: AUTH-TYPO-CORRECTION-002-RUNTIME-PREFLIGHT-IMPLEMENTATION-001

## Current Status

| Field | Value |
|---|---|
| Status | `consumed` — execution started in the exact clean worktree |
| Assignment | [`TYPO-CORRECTION-002-RUNTIME-PREFLIGHT-IMPLEMENTATION-001`](../assignments/typo-correction-002-runtime-preflight-implementation-001.md) |
| Issuer | Human Product Owner / Product Lead, current Codex task, `2026-09-21 Asia/Shanghai` |
| Consumer | Current Codex task, Input Intelligence Maintainer |
| Exact baseline | `4d1050f4b677494e06448cb40a83ef2da46d7b27` |

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-TYPO-CORRECTION-002-RUNTIME-PREFLIGHT-IMPLEMENTATION-001",
  "record_type": "authorization",
  "title": "Bounded pure-Core second-stage recall runtime-preflight implementation",
  "status": "consumed",
  "updated_at": "2026-09-21T19:07:21+08:00",
  "revalidation_triggers": [
    "source_baseline_changed",
    "allowed_path_or_scope_changed",
    "selector_or_cap_changed",
    "test_or_review_result_changed",
    "runtime_or_RIME_action_requested",
    "authority_revoked"
  ],
  "authorization": {
    "action": "implement_and_test_pure_core_second_stage_recall_runtime_preflight",
    "target": "TYPO-CORRECTION-002-RUNTIME-PREFLIGHT-IMPLEMENTATION-001",
    "scope": "In a new clean worktree at the exact baseline, modify only ContextualTypoCorrection.swift, TypoCorrectionRecallPreflight.swift and TypoCorrectionRecallPreflightTests.swift to implement deterministic substitution-only structural selection, provisional preflight-only caps, operation-scoped opaque GroupID mapping and decision-level cancellation/stale-publish contracts. Run strict formatting and KeyboardCore tests; write evidence and status records.",
    "allowed_paths": [
      "Packages/KeyboardCore/Sources/KeyboardCore/ContextualTypoCorrection.swift",
      "Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionRecallPreflight.swift",
      "Packages/KeyboardCore/Tests/KeyboardCoreTests/TypoCorrectionRecallPreflightTests.swift",
      "docs/assignments/typo-correction-002-runtime-preflight-implementation-001.md",
      "docs/authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-PREFLIGHT-IMPLEMENTATION-001.md",
      "docs/evidence/typo-correction-002-runtime-preflight-implementation-001.md"
    ],
    "required_evidence": [
      "exact clean worktree commit/tree and changed-file manifest",
      "strict Swift format/lint results for every changed Swift file",
      "focused and full KeyboardCore test results",
      "proof that production 12/8 and controller paths are unchanged",
      "provisional selector/cap semantics and residual non-claims"
    ],
    "exclusions": [
      "Keyboard_directory_change",
      "RimeBridge_or_RIME_query_or_deployment",
      "schema_or_vendor_change",
      "production_budget_or_controller_or_runtime_wiring",
      "Simulator_or_device_capture",
      "new_Run_ID",
      "QA-001",
      "INT-003",
      "paired_performance_or_180_ms",
      "host_text_or_clipboard_or_candidate_content",
      "FakeCandidateProvider_or_old_Ice_or_model_evidence",
      "commit_or_push",
      "PR_or_merge",
      "TestFlight_or_Release",
      "Product_Quality_or_Release_Gate",
      "Assignment_close"
    ],
    "stop_conditions": [
      "required change exceeds allowed_paths",
      "worktree or baseline identity is not exact and clean",
      "selector/cap cannot remain preflight-only",
      "tests require a real-RIME/device result to pass",
      "a conclusion would claim runtime or product behavior"
    ],
    "issuer_role": "Human Product Owner / Product Lead",
    "decision_source": "current task instruction: 授权按照建议继续进行下一步",
    "issued_at": "2026-09-21T18:58:45+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "consumed",
    "consumed_at": "2026-09-21T19:07:21+08:00",
    "consumed_by": {
      "worktree": "/Users/doubleshy0n/.codex/worktrees/typo-correction-002-runtime-preflight-implementation-001/Universe Keyboard",
      "commit": "4d1050f4b677494e06448cb40a83ef2da46d7b27",
      "tree": "5f864a6f6f139810ed59c7e00ab6c33caad7e500"
    }
  }
}
```

This Authorization does not cover production runtime wiring or any external
evidence. It was consumed immediately before the first permitted Swift change.
