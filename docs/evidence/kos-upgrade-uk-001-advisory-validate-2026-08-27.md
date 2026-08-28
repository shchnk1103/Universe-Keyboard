# Evidence: EVIDENCE-KOS-UPGRADE-UK-ADVISORY-VALIDATE — advisory validator

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "EVIDENCE-KOS-UPGRADE-UK-ADVISORY-VALIDATE",
  "record_type": "evidence",
  "title": "KOS 2.2 advisory validator against v0.5.0",
  "status": "current",
  "updated_at": "2026-08-27T19:55:00+08:00",
  "revalidation_triggers": ["profile_changed", "record_set_changed"],
  "evidence": {
    "provenance": "executor_recorded",
    "environment_id": "ENV.LOCAL_EXECUTOR",
    "assignment_ref": "KOS-UPGRADE-UK-001",
    "operator_ref": "Current Grok session",
    "reviewer_ref": null,
    "coverage": "focused",
    "observed_at": "2026-08-27T19:55:00+08:00",
    "valid_until": null,
    "artifact_bindings": [
      {
        "kind": "file",
        "identity": ".kos/project.json"
      },
      {
        "kind": "commit",
        "identity": "e11cbfb1dacaadc3441b70b2362b6b96d2803385"
      }
    ],
    "permits_claim_ids": ["CLAIM.KOS.ADVISORY_PIN"],
    "prohibits_claim_ids": []
  }
}
```

## Current Status

| Field | Value |
|---|---|
| Status | current |

---

## Method and observations

Command:

```bash
KOS_AS_OF=2026-08-27T20:00:00+08:00 \
  bash /Users/doubleshy0n/Dev/kos-agent-kit/scripts/validate-kos.sh \
  "/Users/doubleshy0n/Dev/Universe Keyboard"
```

Kit tag: `v0.5.0`. Wrapper structural paths passed. Python advisory validator completed with exit 0. Output states that structural success does not approve Product, Architecture, Quality, merge or Release.

## Non-claims

This evidence does not close `GATE-KOS-UPGRADE-UK-ADVISORY`, enable `required`, or migrate remaining Markdown records.
