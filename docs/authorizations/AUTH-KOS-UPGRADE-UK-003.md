# Authorization: AUTH-KOS-UPGRADE-UK-003 — Adopt kit v0.6.0 and merge the pin PR

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-KOS-UPGRADE-UK-003",
  "record_type": "authorization",
  "title": "Adopt kos-agent-kit v0.6.0 advisory pin",
  "status": "active",
  "updated_at": "2026-09-03T20:30:00+08:00",
  "revalidation_triggers": ["scope_changed", "authority_revoked", "kit_release_changed"],
  "authorization": {
    "action": "adopt_kos_kit_v0.6.0",
    "target": "KOS-UPGRADE-UK-003",
    "artifact_bindings": [
      {"kind": "commit", "identity": "a16c93281718f97cb580935c5043562c39f3a1d1"}
    ],
    "scope": "Update Adopted pin to v0.6.0 advisory, keep mode advisory, record UK-003, merge the docs-only PR, run M-02, close the Assignment",
    "exclusions": ["required_mode", "bulk_envelope_migration", "active_assignment_migration", "orchestration_plan_instantiation", "testflight_upload", "release"],
    "issuer_role": "Human Product Owner",
    "decision_source": "in-session 2026-09-03 Asia/Shanghai instruction Adopt v0.6.0",
    "issued_at": "2026-09-03T20:30:00+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "unconsumed"
  }
}
```

## Current Status

| Field | Value |
|---|---|
| Status | active |
| Consumption | unconsumed; pin PR merge SHA pending |

---

本收据授权 Adopt `v0.6.0` advisory pin 与对应 docs PR 合并。它不是 `required`、编排运行时或 Release 的 bearer token。
