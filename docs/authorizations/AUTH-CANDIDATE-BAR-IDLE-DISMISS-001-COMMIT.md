# Authorization: AUTH-CANDIDATE-BAR-IDLE-DISMISS-001-COMMIT — 有界本地 commit

## Current Status

| Field | Value |
|---|---|
| Status | consumed |
| Consumption | 已在隔离分支形成实现 commit `997c56ad114a3b5335e4e883b0dee78c7678043f`；本次记录回写 SHA；push / PR 见独立 AUTH |

Human Product Owner, current session 2026-09-28 Asia/Shanghai: 「授权 commit，push，以及开 PR」

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-CANDIDATE-BAR-IDLE-DISMISS-001-COMMIT",
  "record_type": "authorization",
  "title": "Scoped local commit of CANDIDATE-BAR-IDLE-DISMISS-001",
  "status": "consumed",
  "updated_at": "2026-09-28T22:14:30+08:00",
  "revalidation_triggers": ["scope_changed", "authority_revoked"],
  "authorization": {
    "action": "scoped_commit_candidate_bar_idle_dismiss",
    "target": "CANDIDATE-BAR-IDLE-DISMISS-001",
    "artifact_bindings": [
      {"kind": "commit", "identity": "997c56ad114a3b5335e4e883b0dee78c7678043f"},
      {"kind": "file", "identity": "Keyboard/Views/CandidateBar/CandidateBarView.swift"},
      {"kind": "file", "identity": "docs/assignments/candidate-bar-idle-dismiss-001.md"}
    ],
    "scope": "On isolated branch grok/candidate-bar-idle-dismiss-001 in worktree /private/tmp/universe-keyboard-candidate-bar-idle-dismiss-001, commit only CANDIDATE-BAR-IDLE-DISMISS-001 Swift, KeyboardCore classification, tests, UI_STYLE_GUIDE/PROJECT_CONTEXT/CHANGELOG, product/assignment/review/authorization/evidence records, and assignment-only Active Work/Dashboard hunks. Include a SHA writeback commit on the same branch. Push/PR is a separate Authorization. No merge, TestFlight, or Release. Do not commit on the dirty main checkout. Do not include the rounded-corner follow-up.",
    "exclusions": ["merge", "testflight_upload", "app_store_connect", "release_pass", "default_branch_direct_commit", "keyboard_corner_bleed_fix"],
    "issuer_role": "Human Product Owner",
    "decision_source": "in-session 2026-09-28 Asia/Shanghai instruction: 授权 commit，push，以及开 PR",
    "issued_at": "2026-09-28T22:13:39+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "consumed"
  }
}
```

Push and PR require [`AUTH-CANDIDATE-BAR-IDLE-DISMISS-001-PUSH-PR`](AUTH-CANDIDATE-BAR-IDLE-DISMISS-001-PUSH-PR.md). This receipt does not grant merge, TestFlight, or Release.
