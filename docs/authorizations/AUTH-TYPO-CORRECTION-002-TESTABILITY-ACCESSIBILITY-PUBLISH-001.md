# Authorization: AUTH-TYPO-CORRECTION-002-TESTABILITY-ACCESSIBILITY-PUBLISH-001 — commit / push / PR

## Current Status

| Field | Value |
|---|---|
| Status | active / unconsumed |
| Current phase | 授权在 CI 等价门禁通过后，向功能分支 commit、push 并开 PR |
| Non-claims | 不 merge、不关 parent、不 TestFlight / Release |
| Next | 门禁绿后执行；成功后将本 AUTH 标为 consumed |

Human Product Owner, current session `2026-09-19 Asia/Shanghai`: 接受残余后 **申请新的 publication Authorization**，并 **执行 commit/push/PR**；暂不关闭 parent。

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-TYPO-CORRECTION-002-TESTABILITY-ACCESSIBILITY-PUBLISH-001",
  "record_type": "authorization",
  "title": "Publish testability-accessibility child: commit, push feature branch, open PR",
  "status": "active",
  "updated_at": "2026-09-19T17:10:00+08:00",
  "revalidation_triggers": ["scope_changed", "authority_revoked", "quality_gate_failed"],
  "authorization": {
    "action": "commit_push_pr_testability_accessibility_001",
    "target": "codex/typo-correction-002-testability-accessibility-001",
    "artifact_bindings": [
      {"kind": "file", "identity": "docs/product-decisions/TYPO-CORRECTION-002-TESTABILITY-ACCESSIBILITY-PRODUCT-RESIDUAL.md"}
    ],
    "scope": "After Swift format hard gate and CI-equivalent local quality jobs pass: commit the reviewed child worktree (implementation + docs), push feature branch origin/codex/typo-correction-002-testability-accessibility-001, open a GitHub PR into the default branch. Draft PR is allowed. Do not merge, force-push, close parent TYPO-CORRECTION-002, TestFlight, or Release.",
    "exclusions": [
      "merge",
      "push_main",
      "force_push",
      "parent_typo_correction_002_close",
      "child_assignment_close",
      "testflight_upload",
      "app_store_connect",
      "release_pass",
      "int_003_claim",
      "qa_001_claim",
      "performance_claim"
    ],
    "issuer_role": "Human Product Owner",
    "decision_source": "in-session 2026-09-19 Asia/Shanghai: 接受残余后申请 publication Authorization 并执行 commit/push/PR；暂不关闭 parent",
    "issued_at": "2026-09-19T17:10:00+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "unconsumed"
  }
}
```

## Required before consume

相对默认分支的变更 `.swift` 必须 `swift-format lint --strict`；并跑与 `.github/workflows/swift6-quality.yml` 等价的本地 full 路径（format、KeyboardCore、RimeBridgeTests、App+Keyboard test、Release build）。失败则不得 commit 或 push。
