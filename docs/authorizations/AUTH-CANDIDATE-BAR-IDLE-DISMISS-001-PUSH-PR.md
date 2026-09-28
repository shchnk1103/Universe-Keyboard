# Authorization: AUTH-CANDIDATE-BAR-IDLE-DISMISS-001-PUSH-PR — 推隔离分支并开 PR

## Current Status

| Field | Value |
|---|---|
| Status | active |
| Consumption | unconsumed — 推送隔离分支并开 PR；Human 观察 CI；不授权 merge |

Human Product Owner, current session 2026-09-28 Asia/Shanghai: 「授权 commit，push，以及开 PR」

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-CANDIDATE-BAR-IDLE-DISMISS-001-PUSH-PR",
  "record_type": "authorization",
  "title": "Push isolated branch and open PR for CANDIDATE-BAR-IDLE-DISMISS-001",
  "status": "active",
  "updated_at": "2026-09-28T22:13:39+08:00",
  "revalidation_triggers": ["scope_changed", "authority_revoked", "head_changed"],
  "authorization": {
    "action": "push_and_open_pr_candidate_bar_idle_dismiss",
    "target": "CANDIDATE-BAR-IDLE-DISMISS-001",
    "artifact_bindings": [
      {"kind": "file", "identity": "docs/authorizations/AUTH-CANDIDATE-BAR-IDLE-DISMISS-001-PUSH-PR.md"}
    ],
    "scope": "Push isolated branch grok/candidate-bar-idle-dismiss-001 from worktree /private/tmp/universe-keyboard-candidate-bar-idle-dismiss-001 and open a GitHub pull request into origin/main. Human Product Owner observes hosted CI and owns merge. No merge, undraft-as-merge, TestFlight, or Release.",
    "exclusions": ["merge", "undraft_merge", "testflight_upload", "app_store_connect", "release_pass", "default_branch_direct_commit", "branch_cleanup"],
    "issuer_role": "Human Product Owner",
    "decision_source": "in-session 2026-09-28 Asia/Shanghai instruction: 授权 commit，push，以及开 PR",
    "issued_at": "2026-09-28T22:13:39+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "unconsumed"
  }
}
```

This Authorization does not grant merge, TestFlight, or Release.
