# Authorization: AUTH-APP-ABOUT-001-COMMIT — 有界本地 commit

## Current Status

| Field | Value |
|---|---|
| Status | active |
| Consumption | unconsumed — 隔离分支有界 commit + SHA 回写；不授权 merge / TestFlight / Release |

Human Product Owner, current session 2026-09-28 Asia/Shanghai: 「授权 commit，push，以及开 PR」

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-APP-ABOUT-001-COMMIT",
  "record_type": "authorization",
  "title": "Scoped local commit of APP-ABOUT-001",
  "status": "active",
  "updated_at": "2026-09-28T20:47:15+08:00",
  "revalidation_triggers": ["scope_changed", "authority_revoked"],
  "authorization": {
    "action": "scoped_commit_app_about",
    "target": "APP-ABOUT-001",
    "artifact_bindings": [
      {"kind": "file", "identity": "Universe Keyboard/Views/Settings/AboutSettingsView.swift"},
      {"kind": "file", "identity": "Universe Keyboard/Models/AppAboutContact.swift"},
      {"kind": "file", "identity": "docs/assignments/app-about-001.md"}
    ],
    "scope": "On isolated branch grok/app-about-001 in worktree /private/tmp/universe-keyboard-app-about-001, commit only APP-ABOUT-001 Swift, tests, UI_STYLE_GUIDE/PROJECT_CONTEXT/CHANGELOG/PRIVACY_POLICY/RELEASE_CHECKLIST, product/assignment/review/authorization/evidence records, and assignment-only Active Work/Dashboard hunks. Include a SHA writeback commit on the same branch. Push/PR is a separate Authorization. No merge, TestFlight, or Release. Do not commit on the dirty main checkout.",
    "exclusions": ["merge", "testflight_upload", "app_store_connect", "release_pass", "default_branch_direct_commit"],
    "issuer_role": "Human Product Owner",
    "decision_source": "in-session 2026-09-28 Asia/Shanghai instruction: 授权 commit，push，以及开 PR",
    "issued_at": "2026-09-28T20:47:15+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "unconsumed"
  }
}
```

Push and PR require [`AUTH-APP-ABOUT-001-PUSH-PR`](AUTH-APP-ABOUT-001-PUSH-PR.md). This receipt does not grant merge, TestFlight, or Release.
