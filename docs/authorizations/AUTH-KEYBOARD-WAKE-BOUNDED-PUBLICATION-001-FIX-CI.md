# Authorization: AUTH-KEYBOARD-WAKE-BOUNDED-PUBLICATION-001-FIX-CI — 修复草稿 PR #198 的 hosted lightweight Markdown 断链

## Current Status

| Field | Value |
|---|---|
| Status | consumed |
| Consumption | 已 scoped commit `8c41f5c27787633db4dcc6085a969ef38602863f`；本次记录回写 SHA。草稿 PR [#198](https://github.com/shchnk1103/Universe-Keyboard/pull/198) 保持 draft |
| Issuer | Human Product Owner |
| Decision source | 本线程 2026-10-06：「GitHub CI 有错误，我需要你先修复一下，然后告诉我那 12 个冻结快照的断链是什么？」 |

草稿 PR [#198](https://github.com/shchnk1103/Universe-Keyboard/pull/198) 的 `lightweight-checks` 因 Markdown 本地断链失败，heavy jobs 被 skip。本 AUTH 允许在隔离功能分支上修复该 CI 门，不改冻结 Quality packet 字节，不 `git add -A`，不 squash-merge。

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-KEYBOARD-WAKE-BOUNDED-PUBLICATION-001-FIX-CI",
  "record_type": "authorization",
  "title": "Repair PR #198 lightweight Markdown-link CI without rewriting frozen packet SHA files",
  "status": "consumed",
  "updated_at": "2026-10-06T19:45:56+08:00",
  "revalidation_triggers": ["scope_changed", "authority_revoked", "head_changed"],
  "authorization": {
    "action": "repair_pr198_lightweight_markdown_link_ci",
    "target": "KEYBOARD-WAKE-BOUNDED-PUBLICATION-001",
    "artifact_bindings": [
      {"kind": "git_branch", "identity": "codex/keyboard-wake-v3-compatibility-gate"},
      {"kind": "worktree", "identity": "/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard"},
      {"kind": "starting_git_head", "identity": "c307e7395b87ae1e3e56f6a3da903f90206ffa09"},
      {"kind": "origin_main", "identity": "d610ce8ebdaccb3df087aa299b68c166d7759b1b"},
      {"kind": "pull_request", "identity": "https://github.com/shchnk1103/Universe-Keyboard/pull/198"},
      {"kind": "commit", "identity": "8c41f5c27787633db4dcc6085a969ef38602863f"}
    ],
    "scope": "On isolated branch codex/keyboard-wake-v3-compatibility-gate, skip markdown-link checking for Quality freeze snapshots, repair live-doc absolute worktree /private/tmp / untracked-target links, add checker tests, scoped commit, and push the same draft PR #198. Do not rewrite freeze-copy bytes. Do not add T9PinyinPathTests or --check-failing historical evidence. Leave PR #198 as draft.",
    "exclusions": ["pr_squash_merge", "undraft_merge", "mark_pr_ready", "rebase", "reset", "git_add_all", "default_branch_direct_commit", "branch_cleanup", "testflight_upload", "app_store_connect", "release_pass", "full_xcodebuild_matrix", "t9_pinyin_path_tests", "rewrite_frozen_quality_packet_bytes", "commit_whitespace_failing_evidence"],
    "issuer_role": "Human Product Owner",
    "decision_source": "in-session 2026-10-06 Asia/Shanghai instruction: GitHub CI 有错误，我需要你先修复一下，然后告诉我那 12 个冻结快照的断链是什么？",
    "issued_at": "2026-10-06T19:41:16+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "consumed"
  }
}
```

This Authorization does not grant merging PR #198, TestFlight, or Release.
