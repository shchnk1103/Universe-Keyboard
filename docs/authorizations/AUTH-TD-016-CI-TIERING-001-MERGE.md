# Authorization: AUTH-TD-016-CI-TIERING-001-MERGE — 合并堆叠 PR

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-TD-016-CI-TIERING-001-MERGE",
  "record_type": "authorization",
  "title": "Merge TD-016 stacked pull requests",
  "status": "consumed",
  "updated_at": "2026-08-28T20:30:00+08:00",
  "revalidation_triggers": ["scope_changed", "authority_revoked", "required_checks_changed"],
  "authorization": {
    "action": "merge_stacked_prs",
    "target": "TD-016-CI-TIERING-001",
    "artifact_bindings": [
      {"kind": "url", "identity": "https://github.com/shchnk1103/Universe-Keyboard/pull/86"},
      {"kind": "url", "identity": "https://github.com/shchnk1103/Universe-Keyboard/pull/87"},
      {"kind": "commit", "identity": "78ed5b5"},
      {"kind": "commit", "identity": "11fa096"}
    ],
    "scope": "Keep #86 and #87 as separate PRs; merge #86 to main then #87 to main; record post-merge status; safe branch cleanup after reachability",
    "exclusions": ["release", "branch_protection_mutation", "required_check_mutation", "pat_or_secret_addition", "weaken_full_gate", "kos_required_mode", "combine_87_into_86"],
    "issuer_role": "Human Product Owner",
    "decision_source": "in-session 2026-08-28 Asia/Shanghai instruction to merge according to KOS",
    "issued_at": "2026-08-28T20:26:00+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "consumed"
  }
}
```

## Current Status

| Field | Value |
|---|---|
| Status | consumed |
| Consumption | PR #86 merged `78ed5b5`; PR #87 merged `11fa096` |

---

本收据只授权本次堆叠 PR 合并与合并后状态同步。它不是 Release、branch protection
或 required-check 迁移的 bearer token。#86 与 #87 保持独立 diff，不把 workflow
改动静默并入 #86。
