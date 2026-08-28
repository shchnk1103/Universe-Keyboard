# Product Decision: KOS-UPGRADE-UK-001 — Adopt KOS 2.2 advisory

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "PD-KOS-UPGRADE-UK-001",
  "record_type": "decision",
  "title": "Adopt KOS Agent Kit v0.5.0 in advisory mode",
  "status": "accepted",
  "updated_at": "2026-08-27T19:50:00+08:00",
  "revalidation_triggers": ["kit_release_changed", "mode_changed"],
  "decision": {
    "authority_role": "Human Product Owner",
    "decision_source": "in-session 2026-08-27 Asia/Shanghai after Kit v0.5.0 publication",
    "scope": "Universe Keyboard advisory adoption of kos-agent-kit v0.5.0",
    "outcome": "Adopt advisory envelopes for one workflow; do not enable required; do not migrate product code or merge PR 83",
    "expires_at": null
  }
}
```

## Current Status

| Field | Value |
|---|---|
| Status | accepted |

---

## Decision

Human Product Owner authorized connecting Universe Keyboard to KOS 2.2 by pinning Kit `v0.5.0` in **advisory** mode and enveloping one workflow first.

Frozen Knowledge OS 2.0 remains the constitution. KOS 2.1 ops remains in force. 2.2 does not replace either.

## Non-goals

- `record_envelopes.mode: required`
- bulk Envelope backfill
- automatic Product / Quality / merge / Release conclusions
- replacing the existing human-operated evidence profile with kit H-01 templates in this Assignment
- PR #83 merge or scheme-download code
