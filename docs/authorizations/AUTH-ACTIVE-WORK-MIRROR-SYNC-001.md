# Authorization: AUTH-ACTIVE-WORK-MIRROR-SYNC-001 — docs-only 同步 ACTIVE_WORK 过旧镜像

## Current Status

| Field | Value |
|---|---|
| Status | active |
| Consumption | unconsumed |
| Issuer | Human Product Owner |
| Decision source | 本线程 2026-10-07：「授权 docs-only 同步 ACTIVE_WORK 过旧镜像。」 |

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-ACTIVE-WORK-MIRROR-SYNC-001",
  "record_type": "authorization",
  "title": "Docs-only sync of stale ACTIVE_WORK rows #3/#9/#10 to Assignment and GitHub facts",
  "status": "active",
  "updated_at": "2026-10-07T09:26:29+08:00",
  "revalidation_triggers": ["scope_changed", "authority_revoked", "head_changed"],
  "authorization": {
    "action": "sync_active_work_stale_mirror_docs_only",
    "target": "ACTIVE-WORK-MIRROR-SYNC-001",
    "artifact_bindings": [
      {"kind": "origin_main", "identity": "e748b26a8886455eb6ecdea37896b174bc91b418"},
      {"kind": "worktree", "identity": "/private/tmp/uk-active-work-mirror-sync"},
      {"kind": "branch", "identity": "grok/active-work-mirror-sync-001"}
    ],
    "scope": "On isolated branch grok/active-work-mirror-sync-001 from origin/main e748b26, prepend one ACTIVE_WORK current-update line and rewrite table rows #3/#9/#10 so GitHub merge SHAs and Assignment Current Status match. Write this AUTH and a short evidence receipt. Scoped commit, push, open a docs-only PR, and squash-merge after hosted docs_only green. Lifecycle source of truth remains the Assignment records. GitHub is source of truth for PR mergedness.",
    "exclusions": ["rewrite_assignment_bodies", "close_assignments", "lift_partial_to_pass", "fill_m05_slot_6", "testflight_upload", "app_store_connect", "release_pass", "swift_implementation", "git_add_all", "t9_pinyin_path_tests", "delete_campaign_worktree", "force_delete", "default_branch_direct_commit", "changelog"],
    "issuer_role": "Human Product Owner",
    "decision_source": "in-session 2026-10-07 Asia/Shanghai instruction: 授权 docs-only 同步 ACTIVE_WORK 过旧镜像。",
    "issued_at": "2026-10-07T09:26:29+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "unconsumed"
  }
}
```

This Authorization does not rewrite Assignment contracts, Close children, lift Partial, fill M-05 slot 6, delete the KEEP campaign worktree, commit T9 leftovers, or grant TestFlight / Release.
