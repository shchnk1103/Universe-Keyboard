# Authorization: AUTH-KEYBOARD-CORNER-BLEED-001-PUSH-PR — 推隔离分支并开 PR

## Current Status

| Field | Value |
|---|---|
| Status | active |
| Consumption | unconsumed — 推送隔离分支并开 docs-only PR；不授权 merge |

Human Product Owner, current session 2026-09-28 Asia/Shanghai: 「授权把关闭记录 commit、push 并开 PR。」

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-KEYBOARD-CORNER-BLEED-001-PUSH-PR",
  "record_type": "authorization",
  "title": "Push isolated branch and open PR for KEYBOARD-CORNER-BLEED-001 close records",
  "status": "active",
  "updated_at": "2026-09-28T22:48:18+08:00",
  "revalidation_triggers": ["scope_changed", "authority_revoked", "head_changed"],
  "authorization": {
    "action": "push_and_open_pr_keyboard_corner_bleed_close_docs",
    "target": "KEYBOARD-CORNER-BLEED-001",
    "artifact_bindings": [
      {"kind": "file", "identity": "docs/authorizations/AUTH-KEYBOARD-CORNER-BLEED-001-PUSH-PR.md"}
    ],
    "scope": "Push isolated branch grok/keyboard-corner-bleed-001 and open a GitHub pull request into origin/main for the Closed keep-transparent docs. Human observes hosted CI. No merge, TestFlight, or Release.",
    "exclusions": ["merge", "undraft_merge", "testflight_upload", "release_pass", "branch_cleanup"],
    "issuer_role": "Human Product Owner",
    "decision_source": "in-session 2026-09-28 Asia/Shanghai instruction: 授权把关闭记录 commit、push 并开 PR。",
    "issued_at": "2026-09-28T22:48:18+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "unconsumed"
  }
}
```

This Authorization does not grant merge, TestFlight, or Release.
