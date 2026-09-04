# Authorization: AUTH-RIME-BUILTIN-LUNA-QUALITY-001-MERGE-98 — 合并 PR #98

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-RIME-BUILTIN-LUNA-QUALITY-001-MERGE-98",
  "record_type": "authorization",
  "title": "Merge F-02 first-launch autodeploy and fuzzy-default-off PR #98",
  "status": "active",
  "updated_at": "2026-09-04T13:10:00+08:00",
  "revalidation_triggers": ["scope_changed", "authority_revoked", "head_sha_changed"],
  "authorization": {
    "action": "merge_pr_98",
    "target": "RIME-BUILTIN-LUNA-QUALITY-001",
    "artifact_bindings": [
      {"kind": "url", "identity": "https://github.com/shchnk1103/Universe-Keyboard/pull/98"}
    ],
    "scope": "Merge PR #98 to main after Human Product Gate for this slice; run M-02 state sync; keep Assignment Active with Exit open",
    "exclusions": ["release", "testflight_upload", "testflight_external_review", "app_store_submission", "assignment_exit", "q03_four_profile_closure", "q06_strict_fault_injection", "q07_release_like_budget", "legal_sufficiency", "exact_archive", "c5_extension_process_kill"],
    "issuer_role": "Human Product Owner",
    "decision_source": "in-session 2026-09-04 Asia/Shanghai instruction 批准合并; Architecture/Quality Pass with conditions on eedc4a7; Human fresh-install pass; search-network dialog accepted as non-blocking observation",
    "issued_at": "2026-09-04T13:10:00+08:00",
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
| Consumption | unconsumed |

---

本收据只授权合并 PR #98 与合并后 M-02 状态同步。它不是 TestFlight、Release、
Assignment Exit 的 bearer token。已消耗的 `AUTH-RIME-BUILTIN-LUNA-QUALITY-001-MERGE`
只覆盖 PR #93，不能用于本 PR。
