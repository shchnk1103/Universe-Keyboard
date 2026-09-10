# Authorization: AUTH-KOS-SUG-OBS-DEVICE-001 — SUG-07 真机 preflight

## Current Status

| Field | Value |
|---|---|
| Status | issued |
| Consumption | Issued for preflight execution only; not reusable for uninstall, SUG-08, RTRD-01 implementation, push, merge, or Release |

---

Human Product Owner, current session `2026-09-10 Asia/Shanghai`: **“批准继续SUG-07 真机执行”**.

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-KOS-SUG-OBS-DEVICE-001",
  "record_type": "authorization",
  "title": "Execute SUG-07 observability preflight for active-uninstall claims",
  "status": "issued",
  "updated_at": "2026-09-10T20:40:00+08:00",
  "revalidation_triggers": ["scope_changed", "authority_revoked", "review_finding", "diagnostics_ui_changed"],
  "authorization": {
    "action": "execute_kos_sug_07_preflight_for_active_uninstall_claims",
    "target": "KOS-SUG-OBS-DEVICE-001",
    "artifact_bindings": [
      {"kind": "file", "identity": "docs/kos/universe-keyboard-human-operated-evidence-profile.md"},
      {"kind": "file", "identity": "Universe Keyboard/Views/Diagnostics/DiagnosticsLogSource.swift"}
    ],
    "scope": "Fill the SUG-07 preflight table for functional vs trace claims using current privacy-safe diagnostics UI source. Do not instruct uninstall or read raw diagnostic directories.",
    "exclusions": ["uninstall_operator_round", "implement_sug_08", "implement_rtrd_01_swift", "raw_directory_read", "privacy_policy_change", "production_log_schema_change", "required_mode", "push", "pr", "merge", "release", "testflight"],
    "issuer_role": "Human Product Owner",
    "decision_source": "in-session 2026-09-10 Asia/Shanghai instruction: 批准继续SUG-07 真机执行",
    "issued_at": "2026-09-10T20:40:00+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "issued"
  }
}
```

> **Issued:** [KOS-SUG-OBS-DEVICE-001](../assignments/kos-sug-obs-device-001.md)
> Push, PR, uninstall operator rounds, SUG-08, and Release stay separately gated.
