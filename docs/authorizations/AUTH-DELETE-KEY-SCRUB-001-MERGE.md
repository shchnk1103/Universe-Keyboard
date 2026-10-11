# Authorization: AUTH-DELETE-KEY-SCRUB-001-MERGE — squash-merge PR #196

## Current Status

| Field | Value |
|---|---|
| Status | consumed |
| Consumption | PR #196 已 squash-merge 为 `8f0fa58c57f11891f4e8c6783e7f4bce6a788984`；远端功能分支已删。不授权 TestFlight / Release / 实施 |

Human Product Owner, current session 2026-10-01 Asia/Shanghai: 「GitHub CI 已全绿，可以 merge，然后记得清理分支和worktree。」

Fresh recheck before consume:

| Binding | Value |
|---|---|
| PR | [#196](https://github.com/shchnk1103/Universe-Keyboard/pull/196) OPEN, not draft |
| Head | `130466635f3012be4db0f8be7727d65835aab694` |
| Merge state | `MERGEABLE` / `CLEAN` |
| Hosted CI | Swift 6 Quality run [36823864783](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/36823864783) `headSha` `1304666…` `success` same-head; docs_only（heavy jobs skipped） |
| `origin/main` at recheck | `4dc828ba19d53ace467eafd88991a56c8fe1d08c` |
| Squash | `8f0fa58c57f11891f4e8c6783e7f4bce6a788984` |

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-DELETE-KEY-SCRUB-001-MERGE",
  "record_type": "authorization",
  "title": "Squash-merge PR 196 DELETE-KEY-SCRUB-001 docs framework",
  "status": "consumed",
  "updated_at": "2026-10-01T14:20:00+08:00",
  "revalidation_triggers": ["head_changed", "ci_mismatch", "merge_state_changed", "authority_revoked"],
  "authorization": {
    "action": "squash_merge_pr_196_delete_key_scrub_docs",
    "target": "DELETE-KEY-SCRUB-001",
    "artifact_bindings": [
      {"kind": "commit", "identity": "130466635f3012be4db0f8be7727d65835aab694"},
      {"kind": "commit", "identity": "8f0fa58c57f11891f4e8c6783e7f4bce6a788984"},
      {"kind": "github_pr", "identity": "196"}
    ],
    "scope": "Squash-merge GitHub PR 196 into origin/main at the rechecked head 1304666 with same-head hosted docs_only CI green and CLEAN merge state. Then fetch origin/main, record the squash SHA via docs-only M-02, and safely delete the local and remote feature branch grok/delete-key-scrub-001 plus the isolated worktree. Do not force-delete. Do not TestFlight, Release, or implement.",
    "exclusions": ["testflight_upload", "app_store_connect", "release_pass", "force_delete", "default_branch_direct_commit", "swift_implementation"],
    "issuer_role": "Human Product Owner",
    "decision_source": "in-session 2026-10-01 Asia/Shanghai instruction: GitHub CI 已全绿，可以 merge，然后记得清理分支和worktree。",
    "issued_at": "2026-10-01T14:18:13+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "consumed"
  }
}
```

This Authorization does not grant TestFlight, Release, or implementation.
