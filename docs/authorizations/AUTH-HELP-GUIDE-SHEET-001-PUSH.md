# Authorization: AUTH-HELP-GUIDE-SHEET-001-PUSH

## Current Status

| Field | Value |
|---|---|
| Status | consumed |
| Consumption | 仅推送功能分支 `feature/help-guide-sheet-001`。不授权 PR / merge / 推 `main` |

Human Product Owner, current session 2026-09-14 Asia/Shanghai: “授权 push”

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-HELP-GUIDE-SHEET-001-PUSH",
  "record_type": "authorization",
  "title": "Push feature/help-guide-sheet-001 only",
  "status": "consumed",
  "updated_at": "2026-09-14T23:25:00+08:00",
  "revalidation_triggers": ["scope_changed", "authority_revoked"],
  "authorization": {
    "action": "push_feature_branch_help_guide_sheet",
    "target": "feature/help-guide-sheet-001",
    "artifact_bindings": [
      {"kind": "commit", "identity": "a894cd81dbeae6de0646e4909d1fce644cbbb398"}
    ],
    "scope": "Push local branch feature/help-guide-sheet-001 to origin. Do not push main. Do not open PR, merge, TestFlight, or Release.",
    "exclusions": ["push_main", "pull_request", "merge", "testflight_upload", "app_store_connect", "release_pass"],
    "issuer_role": "Human Product Owner",
    "decision_source": "in-session 2026-09-14 Asia/Shanghai instruction: 授权 push",
    "issued_at": "2026-09-14T23:25:00+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "consumed"
  }
}
```
