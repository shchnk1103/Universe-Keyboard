# Authorization: AUTH-KEYBOARD-WAKE-BOUNDED-PUBLICATION-001-COMMIT — 有界本地 commit

## Current Status

| Field | Value |
|---|---|
| Status | consumed |
| Consumption | 已在隔离分支形成 scoped commit `247c6aad3619d8e2f807a864ef3dbe0e9a60e185`；本次记录回写 SHA |
| Issuer | Human Product Owner |
| Decision source | 本线程 2026-10-06：「授权 Git 发布 AUTH」 |

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-KEYBOARD-WAKE-BOUNDED-PUBLICATION-001-COMMIT",
  "record_type": "authorization",
  "title": "Scoped local commit of keyboard-wake bounded completion",
  "status": "consumed",
  "updated_at": "2026-10-06T19:16:12+08:00",
  "revalidation_triggers": ["scope_changed", "authority_revoked"],
  "authorization": {
    "action": "scoped_commit_keyboard_wake_bounded",
    "target": "KEYBOARD-WAKE-BOUNDED-PUBLICATION-001",
    "artifact_bindings": [
      {"kind": "git_branch", "identity": "codex/keyboard-wake-v3-compatibility-gate"},
      {"kind": "starting_git_head", "identity": "84b9c19227330b0fe6ff391be001ee398010fd6a"},
      {"kind": "worktree", "identity": "/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard"},
      {"kind": "commit", "identity": "247c6aad3619d8e2f807a864ef3dbe0e9a60e185"}
    ],
    "scope": "On isolated branch codex/keyboard-wake-v3-compatibility-gate, stage an explicit allowlist of this worktree's keyboard-wake diagnostic producer, host-activation recovery gate, paired-rollout, completion, E1 originals ingest, backup-cleanup evidence, and matching reviews/assignments/product-decisions/authorizations/navigation mirrors. Include a SHA writeback commit. Exclude Packages/KeyboardCore/Tests/KeyboardCoreTests/T9PinyinPathTests.swift (unrelated one-line dirty; file fails swift-format lint --strict on other lines). No git add -A. Push/PR is a separate Authorization. No merge, TestFlight, or Release. Do not commit on the dirty main checkout.",
    "exclusions": ["merge", "push", "open_pr", "testflight_upload", "app_store_connect", "release_pass", "rebase", "reset", "git_add_all", "default_branch_direct_commit", "t9_pinyin_path_tests"],
    "issuer_role": "Human Product Owner",
    "decision_source": "in-session 2026-10-06 Asia/Shanghai instruction: 授权 Git 发布 AUTH",
    "issued_at": "2026-10-06T19:05:06+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "consumed"
  }
}
```

Push and PR require [`AUTH-KEYBOARD-WAKE-BOUNDED-PUBLICATION-001-PUSH-PR`](AUTH-KEYBOARD-WAKE-BOUNDED-PUBLICATION-001-PUSH-PR.md)。
