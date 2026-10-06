# Authorization: AUTH-KEYBOARD-WAKE-BOUNDED-PUBLICATION-001-RESOLVE-MAIN — 把 origin/main 合并进隔离分支以处理冲突

## Current Status

| Field | Value |
|---|---|
| Status | consumed |
| Consumption | 已 merge `origin/main` `d610ce8e…` 为 `bce3b6ca62fa2a5e4ec2e605493b46780547b957`；草稿 PR [#198](https://github.com/shchnk1103/Universe-Keyboard/pull/198) 保持 draft。不授权 squash-merge |
| Issuer | Human Product Owner |
| Decision source | 本线程 2026-10-06：「授权你先处理与 origin/main 的冲突」 |

草稿 PR [#198](https://github.com/shchnk1103/Universe-Keyboard/pull/198) 对 `origin/main` 为 CONFLICTING。本 AUTH 允许在隔离功能分支上 **merge** `origin/main`（含 DELETE-KEY-SCRUB #196/#197 与 archive-pointer M-02），解决共享导航文档冲突，提交 merge，并 push 同一功能分支。

冲突处理约定：`docs/ACTIVE_WORK.md`、`docs/KNOWLEDGE_INDEX.md`、`docs/ENGINEERING_DASHBOARD.md` 以 `origin/main` 现行 IA 为底，再写入 keyboard-wake 有界完成与 PR #198 指针。不 rebase、不 reset、不 `git add -A`。不 squash-merge PR、不 undraft、不 TestFlight / Release。

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-KEYBOARD-WAKE-BOUNDED-PUBLICATION-001-RESOLVE-MAIN",
  "record_type": "authorization",
  "title": "Merge origin/main into keyboard-wake isolated branch to resolve conflicts",
  "status": "consumed",
  "updated_at": "2026-10-06T19:32:00+08:00",
  "revalidation_triggers": ["scope_changed", "authority_revoked", "head_changed"],
  "authorization": {
    "action": "merge_origin_main_into_keyboard_wake_branch",
    "target": "KEYBOARD-WAKE-BOUNDED-PUBLICATION-001",
    "artifact_bindings": [
      {"kind": "git_branch", "identity": "codex/keyboard-wake-v3-compatibility-gate"},
      {"kind": "worktree", "identity": "/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard"},
      {"kind": "starting_git_head", "identity": "4ee2b317c8537e7309a32a07a533c7f387fff953"},
      {"kind": "origin_main", "identity": "d610ce8ebdaccb3df087aa299b68c166d7759b1b"},
      {"kind": "pull_request", "identity": "https://github.com/shchnk1103/Universe-Keyboard/pull/198"},
      {"kind": "commit", "identity": "bce3b6ca62fa2a5e4ec2e605493b46780547b957"}
    ],
    "scope": "On isolated branch codex/keyboard-wake-v3-compatibility-gate, merge origin/main, resolve shared navigation conflicts using origin/main IA plus keyboard-wake PR #198 pointers, commit the merge, and push the feature branch. Leave PR #198 as draft. Human Product Owner observes hosted CI and owns squash-merge.",
    "exclusions": ["pr_squash_merge", "undraft_merge", "mark_pr_ready", "rebase", "reset", "git_add_all", "default_branch_direct_commit", "branch_cleanup", "testflight_upload", "app_store_connect", "release_pass", "full_xcodebuild_matrix", "t9_pinyin_path_tests"],
    "issuer_role": "Human Product Owner",
    "decision_source": "in-session 2026-10-06 Asia/Shanghai instruction: 授权你先处理与 origin/main 的冲突",
    "issued_at": "2026-10-06T19:26:50+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "consumed"
  }
}
```

This Authorization does not grant merging PR #198, TestFlight, or Release.
