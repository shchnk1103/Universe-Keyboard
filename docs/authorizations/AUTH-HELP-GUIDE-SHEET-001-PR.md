# Authorization: AUTH-HELP-GUIDE-SHEET-001-PR

## Current Status

| Field | Value |
|---|---|
| Status | consumed |
| Consumption | 开 PR（建议草稿）。不授权 merge / 推 `main` / TestFlight / Release |

Human Product Owner, current session 2026-09-14 Asia/Shanghai: “授权开PR”

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-HELP-GUIDE-SHEET-001-PR",
  "record_type": "authorization",
  "title": "Open PR for feature/help-guide-sheet-001",
  "status": "consumed",
  "updated_at": "2026-09-14T23:30:00+08:00",
  "revalidation_triggers": ["scope_changed", "authority_revoked"],
  "authorization": {
    "action": "open_pr_help_guide_sheet",
    "target": "feature/help-guide-sheet-001",
    "artifact_bindings": [
      {"kind": "commit", "identity": "a894cd81dbeae6de0646e4909d1fce644cbbb398"}
    ],
    "scope": "Open a GitHub pull request from feature/help-guide-sheet-001 into main. Draft is allowed. Do not merge, push main, TestFlight, or Release.",
    "exclusions": ["merge", "push_main", "testflight_upload", "app_store_connect", "release_pass", "undraft"],
    "issuer_role": "Human Product Owner",
    "decision_source": "in-session 2026-09-14 Asia/Shanghai instruction: 授权开PR",
    "issued_at": "2026-09-14T23:30:00+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "consumed"
  }
}
```
