# Product Decision: KOS-UPGRADE-UK-003 — Adopt kit v0.6.0 advisory

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "PD-KOS-UPGRADE-UK-003",
  "record_type": "decision",
  "title": "Adopt KOS Agent Kit v0.6.0 in advisory mode",
  "status": "accepted",
  "updated_at": "2026-09-03T20:30:00+08:00",
  "revalidation_triggers": ["kit_release_changed", "mode_changed"],
  "parent_refs": ["KOS-UPGRADE-UK-003"],
  "decision": {
    "authority_role": "Human Product Owner",
    "decision_source": "in-session 2026-09-03 Asia/Shanghai instruction Adopt v0.6.0",
    "scope": "Pin kos-agent-kit v0.6.0 as Adopted while remaining advisory; do not enable required",
    "outcome": "Adopted pin becomes v0.6.0 advisory; v0.5.0 remains historical; required unauthorized",
    "expires_at": null
  }
}
```

## Current Status

| Field | Value |
|---|---|
| Status | accepted |
| Non-claims | Not `required`; not orchestration runtime; not Release |

---

## Decision

Human Product Owner 授权把 Universe Keyboard 的 KOS Agent Kit **Adopted** pin 从 `v0.5.0` 改为 **`v0.6.0`**，Envelope 模式保持 **`advisory`**。

UK-002 的 Deferred 只覆盖「当时不 Adopt」；本 Decision 取代 Adopted pin，不改写 UK-002 作为历史检查记录。

可选编排合同对新 Assignment 可用，不自动迁移既有 Active Assignment，也不在本片落地 `ORCHESTRATION_PLAN.md`。

## Non-goals

- `record_envelopes.mode: required`
- bulk Envelope backfill
- TestFlight / Release
- 把编排合同套到现有 RIME / F-02 / 输入路径工作流
