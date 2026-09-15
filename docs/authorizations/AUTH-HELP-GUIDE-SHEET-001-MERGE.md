# Authorization: AUTH-HELP-GUIDE-SHEET-001-MERGE

## Current Status

| Field | Value |
|---|---|
| Status | consumed |
| Consumption | undraft + merge PR #125；随后按可达性清理功能分支。不授权 TestFlight / Release |

Human Product Owner, current session 2026-09-14 Asia/Shanghai: “CI 已全绿，合并吧，记得按照KOS设定清理分支”

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-HELP-GUIDE-SHEET-001-MERGE",
  "record_type": "authorization",
  "title": "Undraft, merge PR 125, then safe-delete feature branch",
  "status": "consumed",
  "updated_at": "2026-09-14T23:50:00+08:00",
  "revalidation_triggers": ["head_sha_changed", "ci_not_green", "authority_revoked"],
  "authorization": {
    "action": "undraft_merge_and_cleanup_help_guide_sheet",
    "target": "HELP-GUIDE-SHEET-001",
    "artifact_bindings": [
      {"kind": "pull_request", "identity": "125"},
      {"kind": "commit", "identity": "27959f983acec50a680e563d587ae60b51d6e1d2"}
    ],
    "scope": "Mark PR #125 ready, merge into main at hosted-CI-green head 27959f9, then fetch and delete local/remote feature/help-guide-sheet-001 only after origin/main can reach the merged commits. No force-delete. No TestFlight or Release.",
    "exclusions": ["testflight_upload", "app_store_connect", "release_pass", "force_delete_branch", "push_unrelated_dirty_tree"],
    "issuer_role": "Human Product Owner",
    "decision_source": "in-session 2026-09-14 Asia/Shanghai instruction: CI 已全绿，合并吧，记得按照KOS设定清理分支",
    "issued_at": "2026-09-14T23:50:00+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "consumed"
  }
}
```
