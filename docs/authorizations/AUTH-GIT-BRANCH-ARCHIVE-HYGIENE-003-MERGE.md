# Authorization: AUTH-GIT-BRANCH-ARCHIVE-HYGIENE-003-MERGE — 合并 #120

## Current Status

| Field | Value |
|---|---|
| Status | consumed |
| Consumption | Consumed by merge of PR [#120](https://github.com/shchnk1103/Universe-Keyboard/pull/120). Not reusable for Group B delete, Close of other Assignments, or Release |

---

Human Product Owner, session `2026-09-12 Asia/Shanghai` (instruction dated in-thread after CI green): **“CI 已全绿，批准合并 #120”**.

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-GIT-BRANCH-ARCHIVE-HYGIENE-003-MERGE",
  "record_type": "authorization",
  "title": "Merge docs-only PR 120 for Group B keep disposition",
  "status": "consumed",
  "updated_at": "2026-09-12T00:08:00+08:00",
  "revalidation_triggers": ["scope_changed", "authority_revoked", "review_finding"],
  "authorization": {
    "action": "merge_pull_request_120",
    "target": "GIT-BRANCH-ARCHIVE-HYGIENE-003",
    "artifact_bindings": [
      {"kind": "pull_request", "identity": "https://github.com/shchnk1103/Universe-Keyboard/pull/120"}
    ],
    "scope": "Merge PR 120 into main after hosted classify/lightweight/final-quality-gate SUCCESS and build-and-test SKIPPED (docs_only). Delete the feature branch once e959417 is an ancestor of origin/main.",
    "exclusions": ["group_b_delete", "scheme_platform_001", "pull_request_101", "pull_request_102", "release", "testflight", "product_gate", "adr_accept", "swift_change"],
    "issuer_role": "Human Product Owner",
    "decision_source": "in-session instruction: CI 已全绿，批准合并 #120",
    "issued_at": "2026-09-12T00:08:00+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "consumed"
  }
}
```

> **Consumed:** PR [#120](https://github.com/shchnk1103/Universe-Keyboard/pull/120) merged `04e2240` (head `e959417`).
> Engineering Close is [AUTH-…-CLOSE](AUTH-GIT-BRANCH-ARCHIVE-HYGIENE-003-CLOSE.md).
