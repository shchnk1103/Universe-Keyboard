# Authorization: AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-F01-ENTRYPOINT-001

## Current Status

| Field | Value |
|---|---|
| Status | `consumed` — a narrow supplemental path receipt, consumed before the first source edit |
| Assignment | [`TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-001`](../assignments/typo-correction-002-runtime-integration-hardening-001.md) |
| Issuer | Human Product Owner / Product Lead, current Codex task, `2026-09-22 Asia/Shanghai` |
| Consumer | Current Codex task only |
| Relation | Supplements the already consumed Codex execution receipt; it neither replaces nor reopens it |

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-F01-ENTRYPOINT-001",
  "record_type": "authorization",
  "title": "Narrow F-01 mode-entrypoint invalidation supplement",
  "status": "consumed",
  "updated_at": "2026-09-22T09:27:00+08:00",
  "revalidation_triggers": [
    "named_mode_entrypoint_or_recall_lifecycle_changed",
    "required_test_scope_or_result_changed",
    "runtime_capture_or_publication_requested",
    "authority_revoked"
  ],
  "authorization": {
    "action": "remediate_f01_mode_entrypoint_invalidation",
    "target": "TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-001",
    "scope": "Supplement the consumed Codex hardening receipt solely because source inspection located the named page-toggle and empty-composition input-mode entry points in KeyboardViewController+ModeActions.swift rather than an already allowed file. Add invalidate-first recallEpoch calls immediately before existing page-toggle and input-mode controller actions. No other behavior, route, UI, RIME, query or persistence change is authorized.",
    "activation_gate": "The source snapshot had to match the consumed Codex execution receipt, and this supplemental receipt had to be recorded and consumed before its first source edit.",
    "artifact_bindings": [
      {"kind": "source_snapshot", "identity": "HEAD=4d1050f4b677494e06448cb40a83ef2da46d7b27; tracked_diff_sha256=d1366181e0436242211aa496934792e90a6ab1b0454608f0e1c3dd5a17ef4c1b; manifest_sha256=4b701835f070e2c337fd2d3b76b67813e7e5722bdaa7db1b82faa7e00d2c891e"}
    ],
    "allowed_paths": [
      "Keyboard/Controllers/KeyboardViewController+ModeActions.swift",
      "docs/authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-F01-ENTRYPOINT-001.md",
      "docs/assignments/typo-correction-002-runtime-integration-hardening-001.md",
      "docs/evidence/typo-correction-002-runtime-integration-hardening-001.md",
      "docs/ACTIVE_WORK.md"
    ],
    "path_constraints": [
      "Call only the existing controller-owned recall invalidator before existing .togglePage and .toggleInputMode actions.",
      "Do not add a second input, composition, query, candidate-bar, host-commit or persistence path.",
      "Do not alter KeyboardCore mode semantics, page layout, first-stage limits or RIME/session ownership."
    ],
    "required_evidence": [
      "focused source and test verification recorded with the main hardening evidence",
      "strict Swift format and lint if this path changes",
      "explicit non-claims for capture, QA-001, INT-003 and performance"
    ],
    "exclusions": [
      "RIME_schema_vendor_or_deployment_change",
      "real_RIME_query_or_product_candidate_proof",
      "Simulator_or_device_capture",
      "new_Run_ID",
      "QA-001",
      "INT-003",
      "paired_performance_or_180_ms",
      "commit_or_push",
      "PR_or_merge",
      "Product_Quality_or_Release_Gate",
      "parent_or_child_Assignment_close"
    ],
    "stop_conditions": [
      "a required change exceeds KeyboardViewController+ModeActions.swift",
      "a second input/commit/query route is required",
      "verification requires runtime capture, real RIME, publication or a Run ID"
    ],
    "issuer_role": "Human Product Owner / Product Lead",
    "decision_source": "current task instruction: 授权由你来按照你的建议继续进行下一步; implementation scope already names page and empty-composition mode invalidation",
    "issued_at": "2026-09-22T09:27:00+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "consumed",
    "consumed_at": "2026-09-22T09:27:00+08:00",
    "consumed_by": "Current Codex task",
    "consumption_record": "docs/evidence/typo-correction-002-runtime-integration-hardening-001.md"
  }
}
```

This is a scope correction for a named F-01 entry point discovered during
source inspection. It does not authorize source outside the one listed file,
runtime evidence, publication, or any Gate conclusion.
