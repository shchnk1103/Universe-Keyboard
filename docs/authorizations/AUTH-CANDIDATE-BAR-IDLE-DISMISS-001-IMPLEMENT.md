# Authorization: AUTH-CANDIDATE-BAR-IDLE-DISMISS-001-IMPLEMENT — 实施空闲关闭键盘

## Current Status

| Field | Value |
|---|---|
| Status | consumed |
| Consumption | 实施已交付。不授权 Quality / Product Gate / commit / push |

Human Product Owner, current session 2026-09-28 Asia/Shanghai: “确认 CANDIDATE-BAR-IDLE-DISMISS-001，AUTH 生效，按上述范围记录并实施。”

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-CANDIDATE-BAR-IDLE-DISMISS-001-IMPLEMENT",
  "record_type": "authorization",
  "title": "Implement idle candidate-bar dismiss-keyboard dual-mode button",
  "status": "consumed",
  "updated_at": "2026-09-28T21:44:08+08:00",
  "revalidation_triggers": ["scope_changed", "authority_revoked", "product_choice_changed"],
  "authorization": {
    "action": "implement_candidate_bar_idle_dismiss",
    "target": "CANDIDATE-BAR-IDLE-DISMISS-001",
    "artifact_bindings": [
      {"kind": "file", "identity": "Keyboard/Views/CandidateBar/CandidateBarView.swift"},
      {"kind": "file", "identity": "Keyboard/Controllers/KeyboardViewController+CandidateBar.swift"},
      {"kind": "file", "identity": "docs/UI_STYLE_GUIDE.md"},
      {"kind": "file", "identity": "docs/assignments/candidate-bar-idle-dismiss-001.md"}
    ],
    "scope": "Implement dual-mode trailing candidate-bar button: expand when expandable content exists, dismissKeyboard when idle. Keep width and hit outsets. Swipe-down expand only in expand mode. Update AX labels, UI_STYLE_GUIDE, tests, Assignment mirrors. Isolated worktree only.",
    "exclusions": ["second_button", "candidate_bar_height_change", "swipe_down_dismiss", "keyboard_core_candidate_generation", "app_store_connect", "testflight_upload", "product_gate", "quality_pass", "release_pass", "commit", "push", "merge", "branch_cleanup"],
    "issuer_role": "Human Product Owner",
    "decision_source": "in-session 2026-09-28 Asia/Shanghai instruction: 确认 CANDIDATE-BAR-IDLE-DISMISS-001，AUTH 生效，按上述范围记录并实施",
    "issued_at": "2026-09-28T21:40:12+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "consumed"
  }
}
```

This Authorization does not grant independent Quality, Product Gate, commit, push, merge, TestFlight, or Release.
