# Authorization: AUTH-CANDIDATE-BAR-IDLE-DISMISS-001-PRODUCT-GATE — Human Product Gate

## Current Status

| Field | Value |
|---|---|
| Status | consumed |
| Consumption | 已记录空闲关闭键盘 Product Gate；Assignment 可关闭；不授权 Device-attested、commit、push、PR、merge、TestFlight 或 Release；不授权圆角透白修复 |

Human Product Owner, current session `2026-09-28 Asia/Shanghai`, explicitly authorized:

> 接受残差，授权 Product Gate。

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-CANDIDATE-BAR-IDLE-DISMISS-001-PRODUCT-GATE",
  "record_type": "authorization",
  "title": "Human Product Gate for CANDIDATE-BAR-IDLE-DISMISS-001",
  "status": "consumed",
  "updated_at": "2026-09-28T22:10:55+08:00",
  "revalidation_triggers": ["scope_changed", "authority_revoked", "idle_dismiss_contract_changed"],
  "authorization": {
    "action": "product_gate_and_close_candidate_bar_idle_dismiss",
    "target": "CANDIDATE-BAR-IDLE-DISMISS-001",
    "artifact_bindings": [
      {"kind": "file", "identity": "Keyboard/Views/CandidateBar/CandidateBarView.swift"},
      {"kind": "file", "identity": "docs/reviews/candidate-bar-idle-dismiss-001-quality-review.md"},
      {"kind": "file", "identity": "docs/product-decisions/CANDIDATE-BAR-IDLE-DISMISS-001-product-gate.md"}
    ],
    "scope": "Accept the idle candidate-bar dismiss Product Gate using independent Quality Pass with conditions (CBID-01–CBID-04 and CBID-CORNER accept). Close the Assignment with accepted evidence conditions. Isolated worktree only. No Swift change. Do not start the rounded-corner host-bleed follow-up.",
    "exclusions": ["device_attested_upgrade", "swift_implementation", "commit", "push", "pull_request", "merge", "testflight_upload", "app_store_connect", "release", "keyboard_corner_bleed_fix"],
    "issuer_role": "Human Product Owner",
    "decision_source": "In-session 2026-09-28 Asia/Shanghai explicit Product Gate authorization: 接受残差，授权 Product Gate。",
    "issued_at": "2026-09-28T22:10:55+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "consumed"
  }
}
```

This Authorization does not authorize a new Swift change, Device-attested payload
collection, commit, push, PR, merge, TestFlight, App Store Connect, Release, or the
deferred rounded-corner follow-up.
