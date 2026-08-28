# Evidence: SCHEME-DELIVERY-JOURNAL-001

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "EVIDENCE-SCHEME-DELIVERY-JOURNAL-001",
  "record_type": "evidence",
  "title": "Scheme-delivery v1 journal formalization",
  "status": "current",
  "updated_at": "2026-08-28T21:10:00+08:00",
  "revalidation_triggers": ["implementation_changed", "hosted_run_available"],
  "evidence": {
    "provenance": "executor_recorded",
    "environment_id": "ENV.LOCAL_EXECUTOR",
    "assignment_ref": "SCHEME-DELIVERY-JOURNAL-001",
    "operator_ref": "Current Grok session",
    "reviewer_ref": null,
    "coverage": "focused",
    "observed_at": "2026-08-28T21:10:00+08:00",
    "valid_until": null,
    "artifact_bindings": [
      {"kind": "file", "identity": "Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEvent.swift"},
      {"kind": "file", "identity": "Universe Keyboard/Services/SchemaDeliveryDiagnostics.swift"}
    ],
    "permits_claim_ids": [],
    "prohibits_claim_ids": []
  }
}
```

## Current Status

| Field | Value |
|---|---|
| Status | current |
| Evidence grade | `Executor-recorded` |

PR #83 already records typed `scheme_delivery.*` payloads through
`DiagnosticsJournalRuntime.recordSchemeDelivery` and formats them in
`DiagnosticsEventDisplayFormatter`. 2026-08-27 Human empty-v1 observation used a
build without this path.

Added searchable-line coverage for downloading/deploying phases. Human retest
must search `scheme_delivery` or `wanxiang`, with logging and DEPLOY enabled and
high-fidelity off.
