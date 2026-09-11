# Authorization: AUTH-KOS-SUG-OBS-GLANCE-001-DEBUG-INSTALL

## Current Status

| Field | Value |
|---|---|
| Status | consumed |
| Consumption | Consumed after Debug install sequence `2104` and Human uninstall key glance. Not reusable for SUG-08, Product Gate, or Release |

---

Human Product Owner, current session `2026-09-10 Asia/Shanghai`: **“批准先装Debug，然后我会尝试卸载一个方案，到时候给你反馈”**.

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-KOS-SUG-OBS-GLANCE-001-DEBUG-INSTALL",
  "record_type": "authorization",
  "title": "Install origin/main Debug then Human-operated scheme uninstall observation",
  "status": "consumed",
  "updated_at": "2026-09-11T19:40:00+08:00",
  "revalidation_triggers": ["scope_changed", "authority_revoked", "review_finding"],
  "authorization": {
    "action": "install_origin_main_debug_then_human_uninstall_observation",
    "target": "KOS-SUG-OBS-GLANCE-001",
    "artifact_bindings": [
      {"kind": "commit", "identity": "36b63c729bb5f6625e45923f1b0a03fd61c7565e"},
      {"kind": "device", "identity": "00008110-000A08440198801E"}
    ],
    "scope": "One signed Debug build and install of origin/main onto the named iPhone 13 Pro. Human Device Operator may then uninstall one scheme in the Main App UI and report diagnostics list/sheet keys. Executor must not run uninstall, read App Group files, or type into a host.",
    "exclusions": ["executor_uninstall", "implement_sug_08", "raw_directory_read", "host_text_input", "required_mode", "push", "pr", "merge", "release", "testflight", "product_gate", "adr_accept"],
    "issuer_role": "Human Product Owner",
    "decision_source": "in-session 2026-09-10 Asia/Shanghai instruction: 批准先装Debug，然后我会尝试卸载一个方案，到时候给你反馈",
    "issued_at": "2026-09-10T23:50:00+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "consumed"
  }
}
```

> **Consumed:** [KOS-SUG-OBS-GLANCE-001](../assignments/kos-sug-obs-glance-001.md)
> SUG-08, Product Gate, and Release stay separately gated.
