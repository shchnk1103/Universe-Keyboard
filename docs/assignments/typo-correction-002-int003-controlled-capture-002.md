# Assignment: TYPO-CORRECTION-002-INT003-CONTROLLED-CAPTURE-002 — INT-003 one-key smoke and conditional rapid capture (UI-arm bound)

Policy version: 1.0.0

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "TYPO-CORRECTION-002-INT003-CONTROLLED-CAPTURE-002",
  "record_type": "assignment",
  "title": "INT-003 one-key smoke then conditional rapid capture with Main App UI arm binding",
  "lifecycle": "active",
  "current_phase": "Execution complete — smoke Pass; rapid trace ran; <180 ms cadence bar not met (inconclusive for that bar)",
  "authorization_action": "capture_int003_one_key_smoke_then_conditional_rapid_trace_ui_arm_bound",
  "updated_at": "2026-09-22T22:32:59+08:00",
  "authorization_refs": ["AUTH-TYPO-CORRECTION-002-INT003-CONTROLLED-CAPTURE-002"],
  "parent_refs": ["TYPO-CORRECTION-002", "TYPO-CORRECTION-002-PARENT-REVALIDATION-002"]
}
```

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | Active |
| **Phase** | Execution complete — smoke Pass; rapid timeline recorded; cadence bar inconclusive |
| **Non-claims** | No Gate; no parent Close; no global 180 ms product claim from a single Run alone |

## Authority

- **Parent:** [TYPO-CORRECTION-002](typo-correction-002.md) Active.
- **Does not reuse:** AUTH/Assignment `…-INT003-CONTROLLED-CAPTURE-001` (consumed, JSONL-absent).
- **Depends on lesson from:** [UI-arm retest](typo-correction-002-diagnostics-journal-ui-arm-retest-001.md) — Main App / App Group **container** prefs required.
- **Matching AUTH:** [AUTH-TYPO-CORRECTION-002-INT003-CONTROLLED-CAPTURE-002](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-CONTROLLED-CAPTURE-002.md).
- **Human blanket authorization:** 2026-09-22 chat — proceed with recommended INT-003 next step.

## Environment

| Item | Value |
|---|---|
| Tip | `e1b28aebe8f6b2f2a8587db1e525e332aa9bfe00` |
| Simulator | `06C5BC3E-7599-4761-A1A2-71DAEA991474` |
| Run ID | TC2-SIM-20260922-223301-INT003-CONTROLLED-002 |
| Arm | `logging_enabled` on App Group container prefs; high-fidelity window refreshed for this Run; dynamic JSONL search required |

## Scope

1. Confirm container prefs arm (logging + HF window).
2. One visible-key smoke; bind `touch.terminal` (or accepted equivalent) in **fresh** JSONL growth for this Run.
3. If smoke+JSONL OK: same-Run rapid taps (target sub-180 ms gaps as test condition; measured timestamps authoritative).
4. Evidence receipt only; Architecture/Quality need separate AUTHs later.
