# Authorization: AUTH-KEYBOARD-WAKE-BOUNDED-PUBLICATION-001-PUSH-PR — 推隔离分支并开草稿 PR

## Current Status

| Field | Value |
|---|---|
| Status | consumed |
| Consumption | 已推送 `codex/keyboard-wake-v3-compatibility-gate` 并开草稿 PR [#198](https://github.com/shchnk1103/Universe-Keyboard/pull/198)；Human 观察 CI；不授权 merge |
| Issuer | Human Product Owner |
| Decision source | 本线程 2026-10-06：「授权 Git 发布 AUTH」 |

起点 HEAD `84b9c192…` 落后 `origin/main` 4 提交。本 AUTH 允许在该功能分支上 push 并开 **draft** PR；不 rebase。Human 观察 hosted CI 并拥有 merge。草稿 PR 不声明可合并。含 Swift 故 push 前须 `swift-format lint --strict`；不因草稿而豁免格式。完整 xcodebuild 矩阵不在本 AUTH，merge 前另核。

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-KEYBOARD-WAKE-BOUNDED-PUBLICATION-001-PUSH-PR",
  "record_type": "authorization",
  "title": "Push isolated branch and open draft PR for keyboard-wake bounded completion",
  "status": "consumed",
  "updated_at": "2026-10-06T19:19:01+08:00",
  "revalidation_triggers": ["scope_changed", "authority_revoked", "head_changed"],
  "authorization": {
    "action": "push_and_open_draft_pr_keyboard_wake_bounded",
    "target": "KEYBOARD-WAKE-BOUNDED-PUBLICATION-001",
    "artifact_bindings": [
      {"kind": "git_branch", "identity": "codex/keyboard-wake-v3-compatibility-gate"},
      {"kind": "starting_git_head", "identity": "84b9c19227330b0fe6ff391be001ee398010fd6a"},
      {"kind": "commit", "identity": "247c6aad3619d8e2f807a864ef3dbe0e9a60e185"},
      {"kind": "commit", "identity": "8f1d4a3e7242abad9a1827e7f4ce326f207a57ba"},
      {"kind": "pull_request", "identity": "https://github.com/shchnk1103/Universe-Keyboard/pull/198"}
    ],
    "scope": "After AUTH-KEYBOARD-WAKE-BOUNDED-PUBLICATION-001-COMMIT is consumed, push isolated branch codex/keyboard-wake-v3-compatibility-gate to origin and open one draft pull request into origin/main. Record actual commit and PR identifiers in a bind commit. Human Product Owner observes hosted CI and owns merge. No merge, undraft-as-merge, TestFlight, or Release.",
    "exclusions": ["merge", "undraft_merge", "mark_pr_ready", "testflight_upload", "app_store_connect", "release_pass", "rebase", "reset", "default_branch_direct_commit", "branch_cleanup", "full_xcodebuild_matrix"],
    "issuer_role": "Human Product Owner",
    "decision_source": "in-session 2026-10-06 Asia/Shanghai instruction: 授权 Git 发布 AUTH",
    "issued_at": "2026-10-06T19:05:06+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "consumed"
  }
}
```

This Authorization does not grant merge, TestFlight, or Release.
