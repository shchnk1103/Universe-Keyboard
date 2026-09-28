# Authorization: AUTH-CANDIDATE-BAR-IDLE-DISMISS-001-QUALITY — 独立 Quality 审查

## Current Status

| Field | Value |
|---|---|
| Status | consumed |
| Consumption | 独立 Quality 已写入审查记录（Pass with conditions）。不授权 Product Gate / commit / push |

Human Product Owner, current session 2026-09-28 Asia/Shanghai: 「先保持现状，授权独立 Quality。」圆角透白保持现状，Close 之后另开。

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-CANDIDATE-BAR-IDLE-DISMISS-001-QUALITY",
  "record_type": "authorization",
  "title": "Independent Quality review of CANDIDATE-BAR-IDLE-DISMISS-001",
  "status": "consumed",
  "updated_at": "2026-09-28T22:08:00+08:00",
  "revalidation_triggers": ["scope_changed", "authority_revoked", "implementation_changed"],
  "authorization": {
    "action": "independent_quality_review_candidate_bar_idle_dismiss",
    "target": "CANDIDATE-BAR-IDLE-DISMISS-001",
    "artifact_bindings": [
      {"kind": "file", "identity": "docs/reviews/candidate-bar-idle-dismiss-001-quality-review.md"},
      {"kind": "file", "identity": "docs/reviews/candidate-bar-idle-dismiss-001-quality-review-packet.md"},
      {"kind": "file", "identity": "docs/evidence/candidate-bar-idle-dismiss-001-quality-review-usage.md"}
    ],
    "scope": "Independent Quality review of CANDIDATE-BAR-IDLE-DISMISS-001 dual-mode trailing candidate-bar button in isolated worktree /private/tmp/universe-keyboard-candidate-bar-idle-dismiss-001. Follow the frozen packet. Write review and usage records. Independently re-run Swift format lint, KeyboardCore CandidateKindTests, and Universe Keyboard Debug App+Keyboard tests on iPhone 17 id D3C353BE-3AA6-499B-8F87-349073D65BE4. Do not modify product Swift or tests. Do not grant Product Gate, commit, push, TestFlight, or Release. Do not start the deferred rounded-corner host-bleed follow-up.",
    "exclusions": ["swift_implementation", "product_gate", "commit", "push", "merge", "testflight_upload", "app_store_connect", "release_pass", "keyboard_corner_bleed_fix"],
    "issuer_role": "Human Product Owner",
    "decision_source": "in-session 2026-09-28 Asia/Shanghai instruction: 先保持现状，授权独立 Quality。",
    "issued_at": "2026-09-28T21:59:33+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "consumed"
  }
}
```

This Authorization does not grant Product Gate, commit, push, merge, TestFlight, or Release.
