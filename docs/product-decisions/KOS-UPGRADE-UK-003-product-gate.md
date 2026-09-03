# Product Decision: KOS-UPGRADE-UK-003 — Human Product Gate

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "PD-KOS-UPGRADE-UK-003-GATE",
  "record_type": "decision",
  "title": "Accept Adopt v0.6.0 advisory pin merge",
  "status": "accepted",
  "updated_at": "2026-09-03T20:30:00+08:00",
  "revalidation_triggers": ["kit_release_changed", "mode_changed"],
  "parent_refs": ["KOS-UPGRADE-UK-003"],
  "decision": {
    "authority_role": "Human Product Owner",
    "decision_source": "in-session 2026-09-03 Asia/Shanghai instruction Adopt v0.6.0",
    "scope": "Merge the docs/Profile pin to v0.6.0 advisory; close KOS-UPGRADE-UK-003 after M-02",
    "outcome": "Human Product Gate passed for Adopt v0.6.0 advisory; required remains unauthorized",
    "expires_at": null
  }
}
```

- **Decision ID:** `PD-KOS-UPGRADE-UK-003-GATE`
- **Lifecycle status:** `Accepted`
- **Date / timezone:** `2026-09-03 Asia/Shanghai`
- **Authority:** Human Product Owner
- **Assignment:** [`KOS-UPGRADE-UK-003`](../assignments/kos-upgrade-uk-003.md)
- **AUTH:** [`AUTH-KOS-UPGRADE-UK-003`](../authorizations/AUTH-KOS-UPGRADE-UK-003.md)

## Current Status

| Field | Value |
|---|---|
| Status | accepted |
| Phase | Human Product Gate Passed；PR #96 merged `41c0dc5` |
| Non-claims | Not `required`; not orchestration instantiation; not TestFlight / Release |
| Residuals | [`TD-014`](../TECH_DEBT.md#td-014-kos-22-auth-consumption_state-卫生) |

---

## Decision

Human Product Owner 授权 Adopt kos-agent-kit `v0.6.0` 作为当前 advisory pin，并授权合并对应 docs PR。Envelope 保持 `advisory`。不启用 `required`。
