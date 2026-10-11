# Authorization: AUTH-DELETE-KEY-SCRUB-001-IMPLEMENT — 实施删除键 V1 手势

## Current Status

| Field | Value |
|---|---|
| Status | `consumed` |
| Consumption | 实施已落在隔离 worktree，未 commit。KeyboardTests 合同测已在 iPhone 18 Pro `405D994F-28CB-4F89-BB22-B64AD81C05A2` 通过。不授权独立审查结论、Product Gate、commit、push、merge |

Human Product Owner, current session `2026-10-07 Asia/Shanghai`：记录 Ready + 隔离 worktree + 实施 AUTH 生效。

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-DELETE-KEY-SCRUB-001-IMPLEMENT",
  "record_type": "authorization",
  "title": "Implement DELETE-KEY-SCRUB-001 V1 delete-key gestures",
  "status": "consumed",
  "updated_at": "2026-10-07T10:17:00+08:00",
  "revalidation_triggers": ["scope_changed", "authority_revoked", "product_choice_changed"],
  "authorization": {
    "action": "implement_delete_key_scrub_v1",
    "target": "DELETE-KEY-SCRUB-001",
    "artifact_bindings": [
      {"kind": "commit", "identity": "781ca45dfe53cd8d90f49f60370a2efae9d3e749"},
      {"kind": "file", "identity": "docs/product-decisions/DELETE-KEY-SCRUB-001-product-contract.md"}
    ],
    "scope": "In isolated worktree /private/tmp/universe-keyboard-delete-key-scrub-001 on grok/delete-key-scrub-001, implement the accepted V1 product contract: press feedback without deleting, tap-on-lift, committed-text horizontal playhead scrub/restore, composing left-swipe abandon once, long-press repeat after 0.5s at 0.08s that cannot become scrub, trash-bubble overlay after extra 0.15s when documentContextBeforeInput is visible, leave-keyboard-bounds ends the session, touchDragExit must not end the hold. Keyboard UI plus KeyboardTests; bounded playhead math may live in KeyboardCore if it stays content-free. Local ignored Vendor symlink allowed only for compile. Update UI_STYLE_GUIDE and Assignment mirrors for the delivered behavior.",
    "exclusions": ["word_jump_delete", "cross_session_undo", "ledger_persistence", "host_text_logging", "selectAll", "keypopup_extraction", "space_cursor_change", "candidate_bar_swipe_dismiss", "key_touch_fill_rewrite", "rime_deploy_from_extension", "app_store_connect", "testflight_upload", "product_gate", "quality_pass", "release_pass", "commit", "push", "merge", "branch_cleanup", "profile_include", "required_mode"],
    "issuer_role": "Human Product Owner",
    "decision_source": "in-session 2026-10-07 Asia/Shanghai answers: 按建议填责任人；记录 Ready + 隔离 worktree + 实施 AUTH 生效",
    "issued_at": "2026-10-07T09:58:46+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "consumed"
  }
}
```

Independent Architecture, independent Quality, Product Gate, commit, push, merge, TestFlight, and Release require new Authorizations.
