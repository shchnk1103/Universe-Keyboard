# Authorization: AUTH-TYPO-CORRECTION-002-INT003-CONTROLLED-CAPTURE-002

## Current Status

| Field | Value |
|---|---|
| **Status** | Consumed — smoke Pass; rapid trace ran; cadence bar inconclusive for <180 ms; evidence written |
| **Assignment** | [TYPO-CORRECTION-002-INT003-CONTROLLED-CAPTURE-002](../assignments/typo-correction-002-int003-controlled-capture-002.md) |
| **Parent** | [TYPO-CORRECTION-002](../assignments/typo-correction-002.md) |
| **Consumer** | Grok Bot iOS开发大师 |
| **Run ID** | TC2-SIM-20260922-223301-INT003-CONTROLLED-002 |

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-TYPO-CORRECTION-002-INT003-CONTROLLED-CAPTURE-002",
  "record_type": "authorization",
  "title": "INT-003 UI-arm-bound controlled capture",
  "status": "consumed",
  "updated_at": "2026-09-22T22:32:59+08:00",
  "authorization": {
    "action": "capture_int003_one_key_smoke_then_conditional_rapid_trace_ui_arm_bound",
    "target_assignment": "TYPO-CORRECTION-002-INT003-CONTROLLED-CAPTURE-002",
    "parent_assignment": "TYPO-CORRECTION-002",
    "artifact_bindings": [
      {"kind": "source_commit", "identity": "e1b28aebe8f6b2f2a8587db1e525e332aa9bfe00"},
      {"kind": "simulator", "identity": "06C5BC3E-7599-4761-A1A2-71DAEA991474"},
      {"kind": "run", "identity": "TC2-SIM-20260922-223301-INT003-CONTROLLED-002"},
      {"kind": "arm_method", "identity": "App Group container prefs equivalent to Main App DiagnosticsSettingsView; HF refreshed for this Run"},
      {"kind": "jsonl_search", "identity": "dynamic keyboard_extension-<processInstanceID>-<hour>-<part>.jsonl"}
    ],
    "allowed_external_effects": [
      "refresh_App_Group_container_diagnostics_prefs_for_arm",
      "Human_or_visible_key_UI_smoke_and_rapid_taps",
      "read_Diagnostics_JSONL_and_write_docs_evidence_under_clean_tip"
    ],
    "exclusions": [
      "reuse_of_AUTH_INT003_CONTROLLED_CAPTURE_001_or_its_Architecture_Quality",
      "production_Swift_changes",
      "typeText_pasteboard_host_injection_candidate_select",
      "home_main_or_reval08_docs_mutation",
      "commit_push_merge_Close_Gates",
      "RimeRuntimeProvenance_restore"
    ],
    "live_at": "2026-09-22T22:32:59+08:00",
    "consumption_state": "consumed",
    "decision_source": "Human: 授权由你来按照你的建议继续进行下一步 (INT-003 capture recommended)",
    "consumed_at": "2026-09-22T22:38:30+08:00",
    "consumed_artifacts": [
      "Run TC2-SIM-20260922-223301-INT003-CONTROLLED-002",
      "smoke touch.terminal on D1E2DBB9… jsonl",
      "rapid timeline on 92E7E0EA… jsonl sha256 0746d550…",
      "evidence docs/evidence/typo-correction-002-int003-controlled-capture-2026-09-22-002.md"
    ]
  }
}
```
