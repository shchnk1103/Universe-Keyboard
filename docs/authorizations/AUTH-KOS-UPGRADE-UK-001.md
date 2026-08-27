# Authorization: AUTH-KOS-UPGRADE-UK-001 — Adopt KOS 2.2 advisory

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-KOS-UPGRADE-UK-001",
  "record_type": "authorization",
  "title": "Adopt KOS Agent Kit v0.5.0 in advisory mode",
  "status": "active",
  "updated_at": "2026-08-27T19:50:00+08:00",
  "revalidation_triggers": ["scope_changed", "authority_revoked", "kit_release_changed"],
  "authorization": {
    "action": "adopt_kos_2_2_advisory",
    "target": "KOS-UPGRADE-UK-001",
    "artifact_bindings": [
      {
        "kind": "commit",
        "identity": "e11cbfb1dacaadc3441b70b2362b6b96d2803385"
      }
    ],
    "scope": "Pin kos-agent-kit v0.5.0, add v2 Profile, and envelope one workflow. Advisory validator only.",
    "exclusions": ["required_mode", "merge", "release", "product_code", "pr_83_merge"],
    "issuer_role": "Human Product Owner",
    "decision_source": "in-session Product instruction 2026-08-27 Asia/Shanghai after Kit v0.5.0 publication",
    "issued_at": "2026-08-27T19:50:00+08:00",
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

---

本记录只证明 Human Product Owner 授权了 advisory 采用。它不是认证令牌，不能单独授权 `required`、merge、Release 或业务代码改动。
