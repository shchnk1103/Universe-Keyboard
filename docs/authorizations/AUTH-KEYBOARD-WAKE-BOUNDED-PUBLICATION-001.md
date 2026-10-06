# Authorization: AUTH-KEYBOARD-WAKE-BOUNDED-PUBLICATION-001 — 键盘唤醒有界完成 Git 发布

## Current Status

| Field | Value |
|---|---|
| Status | active |
| Consumption | unconsumed — 拆成 COMMIT 与 PUSH-PR；本伞文件不单独执行 Git |
| Issuer | Human Product Owner |
| Decision source | 本线程 2026-10-06：「授权 Git 发布 AUTH」 |

适用任务：`KEYBOARD-WAKE-LIFECYCLE-DIAGNOSTICS-001`、`KEYBOARD-WAKE-HOST-ACTIVATION-FIX-001`、`KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001` 有界完成后的隔离分支发布。

- Commit：[`AUTH-KEYBOARD-WAKE-BOUNDED-PUBLICATION-001-COMMIT`](AUTH-KEYBOARD-WAKE-BOUNDED-PUBLICATION-001-COMMIT.md)
- Push / PR：[`AUTH-KEYBOARD-WAKE-BOUNDED-PUBLICATION-001-PUSH-PR`](AUTH-KEYBOARD-WAKE-BOUNDED-PUBLICATION-001-PUSH-PR.md)

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-KEYBOARD-WAKE-BOUNDED-PUBLICATION-001",
  "record_type": "authorization",
  "title": "Keyboard-wake bounded-completion Git publication umbrella",
  "status": "active",
  "updated_at": "2026-10-06T19:05:06+08:00",
  "revalidation_triggers": ["scope_changed", "authority_revoked", "head_changed"],
  "authorization": {
    "action": "umbrella_git_publication_keyboard_wake_bounded",
    "target": "KEYBOARD-WAKE-BOUNDED-PUBLICATION-001",
    "artifact_bindings": [
      {"kind": "git_branch", "identity": "codex/keyboard-wake-v3-compatibility-gate"},
      {"kind": "starting_git_head", "identity": "84b9c19227330b0fe6ff391be001ee398010fd6a"},
      {"kind": "worktree", "identity": "/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard"}
    ],
    "scope": "Authorize writing and consuming the COMMIT and PUSH-PR child receipts for this isolated worktree. Does not itself stage, commit, push, or open a PR.",
    "exclusions": ["merge", "undraft_merge", "testflight_upload", "app_store_connect", "release_pass", "rebase", "reset", "git_add_all", "default_branch_direct_commit", "branch_cleanup", "simulator", "source_edits_beyond_required_format"],
    "issuer_role": "Human Product Owner",
    "decision_source": "in-session 2026-10-06 Asia/Shanghai instruction: 授权 Git 发布 AUTH",
    "issued_at": "2026-10-06T19:05:06+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "unconsumed"
  }
}
```

不授权 merge、TestFlight、Release。
