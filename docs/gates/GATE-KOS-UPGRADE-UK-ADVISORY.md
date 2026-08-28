# Gate: GATE-KOS-UPGRADE-UK-ADVISORY — Advisory pin structural gate

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "GATE-KOS-UPGRADE-UK-ADVISORY",
  "record_type": "gate",
  "title": "KOS 2.2 advisory pin structural gate",
  "status": "open",
  "updated_at": "2026-08-27T19:50:00+08:00",
  "revalidation_triggers": ["profile_changed", "kit_release_changed"],
  "gate": {
    "class": "architecture",
    "owner": "Architecture and Knowledge Steward",
    "evidence_reviewer": "Current Grok session",
    "close_authority": "Human Product Owner",
    "risk_acceptance_authority": "Human Product Owner",
    "required_evidence_refs": ["EVIDENCE-KOS-UPGRADE-UK-ADVISORY-VALIDATE"],
    "required_environment_ids": ["ENV.LOCAL_EXECUTOR"],
    "required_artifact_bindings": [],
    "required_claim_ids": ["CLAIM.KOS.ADVISORY_PIN"],
    "frozen_inputs": [],
    "closure_decision_ref": null,
    "risk_decision_ref": null,
    "risk_expires_at": null,
    "profile_risk_policy_ref": "POL.ARCHITECTURE",
    "substitution": {"mode": "none", "profile_policy_ref": null}
  }
}
```

## Current Status

| Field | Value |
|---|---|
| Status | open |

---

此 Gate 保持 `open`。advisory 校验证据可以引用它，但不能把它标成 Product 或 Architecture Pass。
